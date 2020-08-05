#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module Smoothing2D: remove noise
Function/S IAFm_Smoothing2D_Definition()
	return "5;0;0;0;0;2;Variable;Variable;Variable;Index2D;Index2D"
End

Function/S IAFm_Smoothing2D(argumentList)
	String argumentList
	
	//0th argument: smoothing type
	//0: box
	String typeArg=StringFromList(0,argumentList)
	
	//1st argument: length along 1st index
	//length 1:     X  (only itself)
	//length 2:    XX  (itself and smaller by 1)
	//length 3:    XXX (itself and smaller and larger by 1)
	//length 4:   XXXX (itself, smaller by 1, smaller by 2, larger by 1)
	String length1Arg=StringFromList(1,argumentList)
	
	//2nd argument: length along 2nd index
	String length2Arg=StringFromList(2,argumentList)
	
	//3rd argument: index socket, to which indices wave is passed
	String inSocketName=StringFromList(3,argumentList)
	
	//4th argument: list of indices passed through a socket
	String indicesWaveArg=StringFromList(4,argumentList)
	
	NVAR type=$typeArg
	NVAR length1=$length1Arg
	NVAR length2=$length2Arg
	Wave/D indicesWave=$indicesWaveArg
	
	type=round(type)
	length1=round(length1)
	length2=round(length2)
	
	//validation
	if(type!=0)
		print("Smoothing2D Error: invalid type of smoothing")
		abort
	Endif
	if(length1<1 || length2<1)
		print("Smoothing2D Error: lengthes must be equal to or greater than 1")
		abort
	Endif
	
	Variable indicesSize=DimSize(indicesWave,0)
	Variable numDataPerPixel=length1*length2
	String socketInputPath="::TempData:Smoothing2D_Input"
	Make/O/D/N=(indicesSize*numDataPerPixel,2) $socketInputPath
	Wave/D socketInput=$socketInputPath
	
	//if length is odd, range is [-(length-1)/2, (length-1)/2]
	//if length is even, range is [-length/2, length/2-1]
	Variable start1,end1
	If(round(length1/2)*2==length1)
		//even
		start1=-round(length1/2)
		end1=-start1-1
	else
		//odd
		start1=-round((length1-1)/2)
		end1=-start1
	Endif
	
	Variable start2,end2
	If(round(length2/2)*2==length2)
		//even
		start2=-round(length2/2)
		end2=-start2-1
	else
		//odd
		start2=-round((length2-1)/2)
		end2=-start2
	Endif
	
	//print(num2str(start1)+" "+num2str(end1)+", "+num2str(start2)+" "+num2str(end2))
	
	Variable inputIndex=0
	Variable i,j,k
	For(i=0;i<indicesSize;i+=1)
		For(j=start1;j<=end1;j+=1)
			For(k=start2;k<=end2;k+=1)
				socketInput[inputIndex][0]=indicesWave[i][0]+j
				socketInput[inputIndex][1]=indicesWave[i][1]+k
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	
	String socketOutputPath=IAFc_CallSocket(inSocketName, socketInputPath)
	Wave/D socketOutput=$socketOutputPath
	String outputPath="::TempData:Smoothing2D_Output"
	Make/O/D/N=(indicesSize) $outputPath
	Wave/D output=$outputPath
	output[]=0
	Variable socketOutputIndex=0
	For(i=0;i<indicesSize;i+=1)
		For(j=start1;j<=end1;j+=1)
			For(k=start2;k<=end2;k+=1)
				output[i]+=socketOutput[socketOutputIndex]
				socketOutputIndex+=1
			Endfor
		Endfor
		output[i]/=numDataPerPixel
	Endfor
	
	KillWaves socketInput,socketOutput
	return outputPath
End

//Function Smoothing2D_F: Format of Module Smoothing2D
Function/S IAFf_Smoothing2D_F_Definition()
	return "8;0;0;0;0;0;0;1;1;Variable;Variable;Variable;Wave1D;Wave1D;Variable;Wave1D;Wave1D"
End

Function IAFf_Smoothing2D_F(argumentList)
	String argumentList
	
	//0th argument: smoothing type
	//0: box
	String typeArg=StringFromList(0,argumentList)
		
	//1st argument: length along 1st index
	String length1Arg=StringFromList(1,argumentList)
	
	//2nd argument: length along 2nd index
	String length2Arg=StringFromList(2,argumentList)
	
	//3rd argument: WaveInfo for 1st index
	String inWaveInfo1Arg=StringFromList(3,argumentList)
	
	//4th argument: WaveInfo for 2nd index
	String inWaveInfo2Arg=StringFromList(4,argumentList)
	
	//5th argument: no overlap (1) or overlap (0 or otherwise)
	String noOverlapArg=StringFromList(5,argumentList)
	
	//6th argument: Modified WaveInfo for 1st index
	String outWaveInfo1Arg=StringFromList(6,argumentList)
	
	//7th argument: Modified WaveInfo for 2nd index
	String outWaveInfo2Arg=StringFromList(7,argumentList)
		
	NVAR type=$typeArg
	NVAR length1=$length1Arg
	NVAR length2=$length2Arg
	Wave/D inWaveInfo1=$inWaveInfo1Arg
	Wave/D inWaveInfo2=$inWaveInfo2Arg
	NVAR noOverlap=$noOverlapArg
	
	type=round(type)
	length1=round(length1)
	length2=round(length2)
	
	//validation
	if(type!=0)
		print("Smoothing2D Error: invalid type of smoothing")
		abort
	Endif
	if(length1<1 || length2<1)
		print("Smoothing2D Error: lengthes must be equal to or greater than 1")
		abort
	Endif
	
	//if length is odd, range is [-(length-1)/2, (length-1)/2]
	//if length is even, range is [-length/2, length/2-1]
	Variable start1,end1
	If(round(length1/2)*2==length1)
		//even
		start1=-round(length1/2)
		end1=-start1-1
	else
		//odd
		start1=-round((length1-1)/2)
		end1=-start1
	Endif
	
	Variable start2,end2
	If(round(length2/2)*2==length2)
		//even
		start2=-round(length2/2)
		end2=-start2-1
	else
		//odd
		start2=-round((length2-1)/2)
		end2=-start2
	Endif

	Duplicate/O inWaveInfo1 $outWaveInfo1Arg
	Duplicate/O inWaveInfo2 $outWaveInfo2Arg
	Wave/D outWaveInfo1=$outWaveInfo1Arg
	Wave/D outWaveInfo2=$outWaveInfo2Arg
	outWaveInfo1[2]-=(length1-1)
	outWaveInfo2[2]-=(length2-1)
	outWaveInfo1[0]+=outWaveInfo1[1]*(-start1)
	outWaveInfo2[0]+=outWaveInfo2[1]*(-start2)
	
	if(noOverlap==1)
		outWaveInfo1[1]*=length1
		outWaveInfo1[2]=ceil(outWaveInfo1[2]/length1)
		outWaveInfo2[1]*=length2
		outWaveInfo2[2]=ceil(outWaveInfo2[2]/length2)
	Endif
End

//Panel SmoothingCtrl2D: change length1 and length2
Function/S IAFp_SmoothingCtrl2D_Definition()
	return "3;0;0;0;Variable;Variable;Variable"
End

Function IAFp_SmoothingCtrl2D(argumentList, PanelName, PanelTitle)
	String argumentList, PanelName, PanelTitle
	
	//0th argument: length1
	String length1Arg=StringFromList(0,argumentList)
	
	//1st argument: length2
	String length2Arg=StringFromList(1,argumentList)
	
	//2nd argument: noOverlap
	String noOverlapArg=StringFromList(2,argumentList)
	
		
	//create a panel
	NewPanel/K=1/W=(0,0,200,90) as PanelTitle
		
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
	
	//put a setvariable
	IAFcu_DrawSetVariable(0,0,length1Arg,4,length1Arg,1,1,1,inf,1)
	IAFcu_DrawSetVariable(0,30,length2Arg,4,length2Arg,1,1,1,inf,1)
	IAFcu_DrawSetVariable(0,60,noOverlapArg,4,noOverlapArg,1,1,0,1,1)

End