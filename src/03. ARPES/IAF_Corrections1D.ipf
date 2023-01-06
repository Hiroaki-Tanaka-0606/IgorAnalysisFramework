#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function CorrectEf1D: correct Ef of 1D wave (EDC or XPS spectra)
Function/S IAFf_CorrectEf1D_Definition()
	return "3;0;0;1;Wave1D;Variable;Wave1D"
End

Function IAFf_CorrectEf1D(argumentList)
	String argumentList
	
	//0th argument (input): input 1D wave
	String inWaveArg=StringFromList(0,argumentList)
	
	//1st argument (input): Ef value
	String EfValueArg=StringFromList(1,argumentList)
	
	//2nd argument (output): output 1D wave
	String outWaveArg=StringFromList(2,argumentList)
	
	NVAR EfValue=$EfValueArg
	Duplicate/O $inWaveArg $outWaveArg
	Wave/D outWave=$outWaveArg
	Variable offset1=DimOffset(outWave,0)
	Variable delta1=DimDelta(outWave,0)
	SetScale/P x, (offset1-EfValue), delta1, outWave
End


//Function Normalize1D: normalize data points so that the average of them is 1
Function/S IAFf_Normalize1D_Definition()
	return "2;0;1;Wave1D;Wave1D"
End

Function	IAFf_Normalize1D(argumentList)
	String argumentList
	
	//0th argument (input): input
	String inputArg=StringFromList(0, argumentList)
	
	//1st argument (output): normalized output
	String outputArg=StringFromList(1, argumentList)
	
	Wave/D input=$inputArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	
	Variable sum=0
	Variable i
	for(i=0; i<dimsize(input, 0); i++)
		sum+=input[i]
	endfor
	Variable ave=sum/dimsize(input, 0)
	output/=ave
End