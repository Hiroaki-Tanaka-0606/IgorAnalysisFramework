#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function PolyFit: fit by a polynomial
Function/S IAFf_PolyFit_Definition()
	return "4;0;0;1;1;Wave1D;Variable;Wave1D;Wave1D"
End

Function IAFf_PolyFit(argumentList)
	String argumentList
	
	//0th argument (input): a wave to be fitted
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): dimension of a fitting polynomial
	//1 -> line (k_0 + k_1 x)
	//2 -> quadratic polynomial (k_0 + k_1 x + k_1 x^2)
	//and so on
	String dimArg=StringFromList(1,argumentList)
	
	//2nd argument (output): a wave of fitting parameters k_i (i=[0,dim])
	String paramsArg=StringFromList(2,argumentList)
	
	//3rd argument (output): fitted curve
	String fitCurveArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR dim=$dimArg
	dim=round(dim)
	if(dim<1)
		print("PolyFit Error: dimension must be a positive integer")
		abort
	endif
	
	Make/O/D/N=(dim+1) $paramsArg
	Wave/D params=$paramsArg

	if(dim==1)
		//linear fit
		CurveFit/Q line, kwCWave=$paramsArg, input
	Else
		//polynomial fit
		CurveFit/Q poly (dim+1), kwCWave=$paramsArg, input
	Endif
	
	
	//generate fitted curve
	Duplicate/O input $fitCurveArg
	Wave/D fitCurve=$fitCurveArg
	fitCurve[]=0
	Variable i
	For(i=0;i<=dim;i+=1)
		fitCurve[]+=params[i]*(x^i)
	Endfor
	
End


//Function PolyFit2: fit by a polynomial
//When the x coordinates of data points are not equally separated
Function/S IAFf_PolyFit2_Definition()
	return "5;0;0;0;1;1;Wave1D;Wave1D;Variable;Wave1D;Wave1D"
End

Function IAFf_PolyFit2(argumentList)
	String argumentList
	
	//0th argument (input): a wave of Y values to be fitted
	String yWaveArg=StringFromList(0,argumentList)
	
	//1st argument (input): a wave of X values to be fitted
	String xWaveArg=StringFromList(1,argumentList)
	
	//2nd argument (input): dimension of a fitting polynomial
	//1 -> line (k_0 + k_1 x)
	//2 -> quadratic polynomial (k_0 + k_1 x + k_1 x^2)
	//and so on
	String dimArg=StringFromList(2,argumentList)
	
	//3rd argument (output): a wave of fitting parameters k_i (i=[0,dim])
	String paramsArg=StringFromList(3,argumentList)
	
	//4th argument (output): fitted curve points, with the same X values
	String fitCurveArg=StringFromList(4,argumentList)
	
	Wave/D inputY=$yWaveArg
	Wave/D inputX=$xWaveArg
	NVAR dim=$dimArg
	dim=round(dim)
	if(dim<1)
		print("PolyFit2 Error: dimension must be a positive integer")
		abort
	endif
	
	Make/O/D/N=(dim+1) $paramsArg
	Wave/D params=$paramsArg

	if(dim==1)
		//linear fit
		CurveFit/Q line, kwCWave=$paramsArg, inputY /X=inputX
	Else
		//polynomial fit
		CurveFit/Q poly (dim+1), kwCWave=$paramsArg, inputY /X=inputX
	Endif
	
	
	//generate fitted curve
	Duplicate/O inputY $fitCurveArg
	Wave/D fitCurve=$fitCurveArg
	fitCurve[]=0
	Variable i
	For(i=0;i<=dim;i+=1)
		fitCurve[]+=params[i]*(inputX[p]^i)
	Endfor
	
End

//Function ValidPoints1D: extract valid (>0) points in Wave1D
Function/S IAFf_ValidPoints1D_Definition()
	return "3;0;1;1;Wave1D;Wave1D;Wave1D"
End

Function IAFf_ValidPoints1D(argumentList)
	String argumentList
	
	//0th argument (input): input
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): X coordinates of valid points
	String outputXArg=StringFromList(1,argumentList)
	
	//2nd argument (output): Y coordinates of valid points
	String outputYArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	Variable offset=DimOffset(input,0)
	Variable delta=DimDelta(input,0)
	Variable size=DimSize(input,0)
	
	Make/O/D/N=(size) $outputXArg
	Make/O/D/N=(size) $outputYArg
	
	Wave/D outputX=$outputXArg
	Wave/D outputY=$outputYArg
	
	Variable numPoints=0
	Variable i
	
	For(i=0;i<size;i+=1)
		if(input[i]>0)
			outputX[numPoints]=offset+delta*i
			outputY[numPoints]=input[i]
			numPoints+=1
		Endif
	Endfor
	
	DeletePoints numPoints, size-numPoints, outputX
	DeletePoints numPoints, size-numPoints, outputY
End

//Function PolyCurve: generate polynomial curve
Function/S IAFf_PolyCurve_Definition()
	return "3;0;0;1;Wave1D;Wave1D;Wave1D"
End

Function IAFf_PolyCurve(argumentList)
	String argumentList
	
	//0th argument (input): infowave of output
	String waveInfoArg=StringFromList(0,argumentList)
	
	//1st argument (input): FitParams
	String fitParamsArg=StringFromList(1,argumentList)
	
	//2nd argument (output): output
	String outputArg=StringFromList(2,argumentList)
	
	Wave/D outputInfo=$waveInfoArg
	Wave/D fitParams=$fitParamsArg
	
	Variable offset=outputInfo[0]
	Variable delta=outputInfo[1]
	Variable size=outputInfo[2]
	
	Make/O/D/N=(size) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset, delta, output
	
	Variable i
	Variable dim=DimSize(fitParams,0)
	output[]=0
	For(i=0;i<dim;i+=1)
		output[]+=FitParams[i]*(x^i)
	Endfor
End