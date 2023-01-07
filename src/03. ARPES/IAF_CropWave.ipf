#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// CropWave2D: crop 2D waves
Function/S IAFf_CropWave2D_Definition()
	return "6;0;0;0;0;0;1;Wave2D;Variable;Variable;Variable;Variable;Wave2D"
End

Function IAFf_CropWave2D(argumentList)
	String argumentList
	
	//0th (input): input
	String inputArg=StringFromList(0, argumentList)
	
	//1st, 2nd (input): 1st axis index (both included)
	String Ax1MinArg=StringFromList(1, argumentList)
	String Ax1MaxArg=StringFromList(2, argumentList)
	
	//3rd, 4th (input): 2nd axis indices (both included)
	String Ax2MinArg=StringFromList(3, argumentList)
	String Ax2MaxArg=StringFromList(4, argumentList)
	
	//5th (output): output
	String outputArg=StringFromList(5, argumentList)
	
	Wave/D input=$inputArg
	NVAR Ax1Min=$Ax1MinArg
	NVAR Ax1Max=$Ax1MaxArg
	NVAR Ax2Min=$Ax2MinArg
	NVAR Ax2Max=$Ax2MaxArg
	
	Variable size1=Ax1Max-Ax1Min+1
	Variable size2=Ax2Max-Ax2Min+1
	
	Variable offset1=dimoffset(input, 0)
	Variable delta1=dimdelta(input, 0)
	
	Variable offset2=dimoffset(input, 1)
	variable delta2=dimdelta(input, 1)
	
	Variable newOffset1=offset1+delta1*Ax1Min
	Variable newOffset2=offset2+delta2*Ax2Min
	
	Make/O/D/N=(size1, size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, newOffset1, delta1, output
	SetScale/P y, newOffset2, delta2, output
	
	output[][]=input[p+Ax1Min][q+Ax2Min]
	
	
End
