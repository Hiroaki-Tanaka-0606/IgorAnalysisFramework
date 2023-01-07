#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module Invert2D: invert axes
Function/S IAFm_Invert2D_Definition()
	return "4;0;0;0;2;Variable;Variable;Coordinate2D;Coordinate2D"
End

Function/S IAFm_Invert2D(argumentList)
	String argumentList
	
	//0th argument (input): invert 1st axis (1) or not (0)
	String invert1Arg=StringFromList(0,argumentList)
	
	//1st argument (input): invert 2nd axis (1) or not (0)
	String invert2Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): input socket
	String inSocketName=StringFromList(2,argumentList)
	
	//3rd argument (waiting socket): list of coordinates
	String coordsListArg=StringFromList(3,argumentList)
	
	NVAR invert1=$invert1Arg
	NVAR invert2=$invert2Arg
	
	String inputPath="::TempData:Invert2D_Input"
	Duplicate/O $coordsListArg $inputPath
	Wave/D input=$inputPath
	
	If(invert1==1)
		input[][0]=-input[p][0]
	Endif
	
	if(invert2==1)
		input[][1]=-input[p][1]
	Endif
	
	String outputPath=IAFc_CallSocket(inSocketName, inputPath)
	KillWaves input
	return outputPath
End

//Function Invert2D_F: format for Invert2D
Function/S IAFf_Invert2D_F_Definition()
	return "6;0;0;0;0;1;1;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D"
End

Function IAFf_Invert2D_F(argumentList)
	String argumentList
	
	//0th argument (input): invert 1st axis (1) or not (0)
	String invert1Arg=StringFromList(0,argumentList)
	
	//1st argument (input): invert 2nd axis (1) or not (0)
	String invert2Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): input infowave for 1st index
	String inWaveInfo1Arg=StringFromList(2,argumentList)
	
	//3rd argument (input): input infowave for 2nd index
	String inWaveInfo2Arg=StringFromList(3,argumentList)
	
	//4th argument (output): output infowave for 1st index
	String outWaveInfo1Arg=StringFromList(4,argumentList)
	
	//5th argument (output): output infowave for 2nd index
	String outWaveInfo2Arg=StringFromList(5,argumentList)
	
	NVAR invert1=$invert1Arg
	NVAR invert2=$invert2Arg
	
	Duplicate/O $inWaveInfo1Arg $outWaveInfo1Arg
	Duplicate/O $inWaveInfo2Arg $outWaveInfo2Arg
	
	Wave/D outWaveInfo1=$outWaveInfo1Arg
	Wave/D outWaveInfo2=$outWaveInfo2Arg
	
	if(invert1==1)
		outWaveInfo1[0]=-(outWaveInfo1[0]+outWaveInfo1[1]*(outWaveInfo1[2]-1))
	Endif
	
	if(invert2==1)
		outWaveInfo2[0]=-(outWaveInfo2[0]+outWaveInfo2[1]*(outWaveInfo2[2]-1))
	Endif
End