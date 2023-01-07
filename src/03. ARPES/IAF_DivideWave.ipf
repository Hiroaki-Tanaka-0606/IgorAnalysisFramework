#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function DivideWave2D: return a[i][j]/b[i][j] if b[i][j]>threshold, 0 otherwise
Function/S IAFf_DivideWave2D_Definition()
	return "4;0;0;0;1;Wave2D;Wave2D;Variable;Wave2D"
End

Function IAFf_DivideWave2D(argumentList)
	String argumentList

	//0th argument (input): a[][]
	String aWaveArg=StringFromList(0,argumentList)
	
	//1st argument (input): b[][]
	String bWaveArg=StringFromList(1,argumentList)
	
	//2nd argument (input): threshold for b[i][j]
	String thresholdArg=StringFromList(2,argumentList)
	
	//3rd argument (output): output a[][]/b[][]
	String cWaveArg=StringFromList(3,argumentList)
	
	Wave/D aWave=$aWaveArg
	Wave/D bWave=$bWaveArg
	NVAR threshold=$thresholdArg
	
	//size check
	if(DimSize(aWave,0)!=DimSize(bWave,0) || DimSize(aWave,1)!=DimSize(bWave,1))
		print ("DivideWave2D Error: size mismatch")
		abort
	endif
	
	Variable size1=DimSize(aWave,0)
	Variable size2=DimSize(aWave,1)
	
	Duplicate/O aWave $cWaveArg
	Wave/D cWave=$cWaveArg
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			if(bWave[i][j]>threshold)
				cWave[i][j]=aWave[i][j]/bWave[i][j]
			Else
				cWave[i][j]=0
			Endif
		Endfor
	Endfor
	
End

//Function DivideWave21DX: divide a[i][j] by b[i]
Function/S IAFf_DivideWave21DX_Definition()
	return "3;0;0;1;Wave2D;Wave1D;Wave2D"
End

Function IAFf_DivideWave21DX(argumentList)
	String argumentList
	
	//0th argument (input): a[][]
	String aWaveArg=StringFromList(0, argumentList)
	
	//1st argument (input): b[]
	String bWaveArg=StringFromList(1, argumentList)
	
	//2nd argument (output): output
	String cWaveArg=StringFromList(2, argumentList)
	
	Wave/D aWave=$aWaveArg
	Wave/D bWave=$bWaveArg
	
	//size check
	if(DimSize(aWave,0)!=DimSize(bWave,0))
		print("DivideWave21DX error: size mismatch")
		abort
	Endif
	
	Duplicate/O aWave $cWaveArg
	Wave/D cWave=$cWaveArg
	
	cWave[][]/=bWave[p]
	
End

//Function DivideWave21DY: divide a[i][j] by b[j]
Function/S IAFf_DivideWave21DY_Definition()
	return "3;0;0;1;Wave2D;Wave1D;Wave2D"
End

Function IAFf_DivideWave21DY(argumentList)
	String argumentList
	
	//0th argument (input): a[][]
	String aWaveArg=StringFromList(0, argumentList)
	
	//1st argument (input): b[]
	String bWaveArg=StringFromList(1, argumentList)
	
	//2nd argument (output): output
	String cWaveArg=StringFromList(2, argumentList)
	
	Wave/D aWave=$aWaveArg
	Wave/D bWave=$bWaveArg
	
	//size check
	if(DimSize(aWave,1)!=DimSize(bWave,0))
		print("DivideWave21DY error: size mismatch")
		abort
	Endif
	
	Duplicate/O aWave $cWaveArg
	Wave/D cWave=$cWaveArg
	
	cWave[][]/=bWave[q]
	
End

//Function DivideByFD: divide by Fermi-Dirac distribution 1/(exp(beta(e-EF))+1)
Function/S IAFf_DivideByFD_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_DivideByFD(argumentList)
	String argumentList
	
	//0th argument (input): input
	String inputArg=StringFromList(0, argumentList)
	
	//1st argument (input): temperature(K)
	String tempArg=StringFromList(1, argumentList)
	
	//2nd argument (output): output
	String outputArg=StringFromList(2, argumentList)
	
	Wave/D input=$inputArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	NVAR temp=$tempArg
	
	Variable beta=11604.53/temp
	output[][]*=(exp(beta*x)+1)
End

//Function DivideByFDGauss: divide by Fermi-Dirac distribution convolved by Gaussian
//see IAF_FermiEdgeFit.ipf for IAFu_GaussianWave
Function/S IAFf_DivideByFDGauss_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave2D"
End

Function IAFf_DivideByFDGauss(argumentList)
	String argumentList
	//0th argument (input): input
	String inputArg=StringFromList(0, argumentList)
	
	//1st argument (input): temperature(K)
	String tempArg=StringFromList(1, argumentList)
	
	//2nd argument (input): dE (eV, FWHM)
	String dEArg=StringFromList(2, argumentList)
	
	//3rd argument (output): output
	String outputArg=StringFromList(3, argumentList)
	
	Wave/D input=$inputArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	NVAR temp=$tempArg
	NVAR dE=$dEArg
	
	Variable EOffset=DimOffset(output, 0)
	Variable EDelta=DimDelta(output, 0)
	Variable ESize=DimSize(output, 0)
	
	Variable beta=11604.53/temp
	cd ::TempData
	Variable gaussianRange=5
	Variable gaussianWidth=IAFu_GaussianWave(dE/(2*sqrt(2*ln(2))*EDelta),gaussianRange,"tempGaussian")
	
	Variable EStart=EOffset-gaussianWidth*EDelta
	Make/O/D/N=(ESize+2*gaussianWidth) tempTrial
	Wave/D FDTrial=tempTrial
	SetScale/P x, EStart,EDelta,FDTrial
	
	FDTrial[]=1.0/(1+exp(beta*x))
	
	Convolve/A $"tempGaussian" FDTrial
	
	Make/O/D/N=(ESize) FD
	Wave/D FD=FD
	SetScale/P x, EOffset, EDelta, FD
	FD[]=FDTrial[gaussianWidth+p]
	cd ::Data
	
	output[][]/=FD[p]
	
	KillWaves FD, FDTrial
	
End