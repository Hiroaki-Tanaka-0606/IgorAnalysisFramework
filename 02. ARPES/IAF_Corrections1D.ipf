#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function CorrectEf1D: correct Ef of 1D wave (EDC or XPS spectra)
Function/S IAFf_CorrectEf1D_Definition()
	return "3;0;0;1;Wave1D;Variable;Wave1D"
End

Function IAFf_CorrectEf1D(argumentList)
	String argumentList
	
	//0th argument: input 1D wave
	String inWaveArg=StringFromList(0,argumentList)
	
	//1st argument: Ef value
	String EfValueArg=StringFromList(1,argumentList)
	
	//2nd argument: output 1D wave
	String outWaveArg=StringFromList(2,argumentList)
	
	NVAR EfValue=$EfValueArg
	Duplicate/O $inWaveArg $outWaveArg
	Wave/D outWave=$outWaveArg
	Variable offset1=DimOffset(outWave,0)
	Variable delta1=DimDelta(outWave,0)
	SetScale/P x, (offset1-EfValue), delta1, outWave
End

