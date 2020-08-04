#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function PolyFit: fit by a polynomial
Function/S IAFf_PolyFit_Definition()
	return "4;0;0;1;1;Wave1D;Variable;Wave1D;Wave1D"
End

Function IAFf_PolyFit(argumentList)
	String argumentList
	
	//0th argument: a wave to be fitted
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: dimension of a fitting polynomial
	//1 -> line (k_0 + k_1 x)
	//2 -> quadratic polynomial (k_0 + k_1 x + k_1 x^2)
	//and so on
	String dimArg=StringFromList(1,argumentList)
	
	//2nd argument: a wave of fitting parameters k_i (i=[0,dim])
	String paramsArg=StringFromList(2,argumentList)
	
	//3rd argument: fitted curve
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