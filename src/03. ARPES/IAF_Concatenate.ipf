#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module Concat2D: concatenate A and B, B being with offset
Function/S IAFm_Concat2D_Definition()
	return "7;0;0;0;0;0;0;2;Variable;Coordinate2D;Coordinate2D;Wave1D;Variable;Variable;Coordinate2D"
End

Function/S IAFm_Concat2D(argumentList)
	String argumentList
	
	//0th argument: concatenation mode
	//0: half & half
	//1: linearly gradual
	String concatModeArg=StringFromList(0,argumentList)
	
	//1st argument: a socket corresponding to wave A
	String AName=StringFromList(1,argumentList)
	
	//2nd argument: a socket corresponding to wave B
	String BName=StringFromList(2,argumentList)
	
	//3rd argument: angleInfo
	String angleInfoArg=StringFromList(3,argumentList)
	
	//4th argument: offset of B
	String offsetArg=StringFromList(4,argumentList)
	
	//5th argument: calculation parameter
	//mode 0: not used
	//mode 1: this width from the end or the start of the waves is neglected for the gradation
	String ParamArg=StringFromList(5,argumentList)
	
	//6th argument: coordinates wave passed through socket
	String coordsArg=StringFromList(6,argumentList)
	
	NVAR concatMode=$concatModeArg
	Wave/D angleInfo=$angleInfoArg
	NVAR Boffset=$offsetArg
	Wave/D coordinates=$coordsArg
	Variable NumPoints=DimSize(coordinates,0)
	NVAR Param=$ParamArg
	
	String socketAInputPath="::TempData:Concat2D_InputA"
	String socketBInputPath="::TempData:Concat2D_InputB"
	
	Duplicate/O coordinates $socketAInputPath
	Duplicate/O coordinates $socketBInputPath
	
	Wave/D socketAInput=$socketAInputPath
	Wave/D socketBInput=$socketBInputPath
	socketAInput[][]=0
	socketBInput[][]=0
	
	// list of indices in the passed coordinates wave corresponding to socketAInput and socketBInput
	String indexAPath="::TempData:Concat2D_indexA"
	String indexBPath="::TempData:Concat2D_indexB"
	Make/O/D/N=(NumPoints) $indexAPath
	Make/O/D/N=(NumPoints) $indexBPath
	Wave/D indexA=$indexAPath
	Wave/D indexB=$indexBPath
	
	Variable NumPoints_A=0
	Variable NumPoints_B=0
	
	Variable i
	Variable AngleOffset=angleInfo[0]
	Variable AngleDelta=angleInfo[1]
	Variable AngleSize=angleInfo[2]
	
	Variable energy_i,angle_i
	
	// for mode 0
	Variable borderAngle
	// for mode 1
	Variable borderAngle1
	Variable borderAngle2
	Variable NumPoints_Between=0
	// borderAreaInfo
	//[0]: indices in the passed coordinates wave
	//[1]: index in inputA
	//[2]: index in inputB
	String borderAreaInfoPath="::Tempdata:Concat2D_borderAreaInfo"
	Make/O/D/N=(NumPoints,3) $borderAreaInfoPath
	Wave/D borderAreaInfo=$borderAreaInfoPath
	borderAreaInfo[][]=0
	

	
	// distribute coordinates into A and B
	switch(concatMode)
		case 0:
			// half & half
			if(Boffset>0)
				// offset>0 
				// [    A  | ]
				//       [ |  B    ]
				// | is the border position
				borderAngle=AngleOffset+(AngleDelta*AngleSize+Boffset)/2
				
				For(i=0; i<NumPoints; i+=1)
					energy_i=coordinates[i][0]
					angle_i=coordinates[i][1]
					if(angle_i<borderAngle)
						socketAInput[NumPoints_A][0]=energy_i
						socketAInput[NumPoints_A][1]=angle_i
						indexA[NumPoints_A]=i
						NumPoints_A+=1
					else
						socketBInput[NumPoints_B][0]=energy_i
						socketBInput[NumPoints_B][1]=angle_i-Boffset
						indexB[NumPoints_B]=i
						NumPoints_B+=1
					endif
				Endfor
				
			else
				// offset<0 
				//       [ |  A    ]
				// [    B  | ]
				
			endif
			break
		Case 1:
			//linearly gradual
			if(Boffset>0)
				// offset>0 
				// [      A  | |X]
				//         [X| |  B      ]
				// | is the border position (1 and 2 in this order), X is no-use area
				borderAngle2=AngleOffset+AngleDelta*AngleSize-Param
				borderAngle1=AngleOffset+BOffset+Param
				//print(num2str(borderAngle1)+" "+num2str(borderAngle2))
				if(borderAngle2<borderAngle1)
					print("Concat2D error: wrong order of borders")
					abort
				endif
				
				For(i=0; i<NumPoints; i+=1)
					energy_i=coordinates[i][0]
					angle_i=coordinates[i][1]
					if(angle_i<borderAngle1)
						//only A
						socketAInput[NumPoints_A][0]=energy_i
						socketAInput[NumPoints_A][1]=angle_i
						indexA[NumPoints_A]=i
						NumPoints_A+=1
					elseif(angle_i>borderAngle2)
						//only B
						socketBInput[NumPoints_B][0]=energy_i
						socketBInput[NumPoints_B][1]=angle_i-Boffset
						indexB[NumPoints_B]=i
						NumPoints_B+=1
					else
						//between
						socketAInput[NumPoints_A][0]=energy_i
						socketAInput[NumPoints_A][1]=angle_i
						socketBInput[NumPoints_B][0]=energy_i
						socketBInput[NumPoints_B][1]=angle_i-Boffset
						indexA[NumPoints_A]=-1
						indexB[NumPoints_B]=-1
						borderAreaInfo[NumPoints_Between][0]=i
						borderAreaInfo[NumPoints_Between][1]=NumPoints_A
						borderAreaInfo[NumPoints_Between][2]=NumPoints_B
						NumPoints_A+=1
						NumPoints_B+=1
						NumPoints_Between+=1
					endif
				Endfor
				
			else
				// offset<0 
				//       [ |  A    ]
				// [    B  | ]
				
			endif
	endswitch
	
	// remove unnecessary space in socketAInput and socketBInput
	DeletePoints NumPoints_A, (NumPoints-NumPoints_A), socketAInput
	DeletePoints NumPoints_B, (NumPoints-NumPoints_B), socketBInput
	DeletePoints NumPoints_Between, (NumPoints-NumPoints_Between), borderAreaInfo
	
	//call socket A and B
	String socketOutputA=IAFc_CallSocket(AName, socketAInputPath)
	String AOutputPath="::TempData:Concat2D_AOutput"
	Duplicate/O $socketOutputA $AOutputPath
	Wave/D AOutput=$AOutputPath
	
	String socketOutputB=IAFc_CallSocket(BName, socketBInputPath)
	String BOutputPath="::TempData:Concat2D_BOutput"
	Duplicate/O $socketOutputB $BoutputPath
	Wave/D Boutput=$BoutputPath
	
	String outputPath="::TempData:Concat2D_output"
	Make/O/D/N=(NumPoints) $outputPath
	Wave/D Output=$outputPath
	
	For(i=0;i<NumPoints_A;i+=1)
		if(indexA[i]>=0)
			//if indexA[i] is -1, it means that the point is between two borders
			Output[indexA[i]]=AOutput[i]
		endif
	Endfor
	For(i=0;i<NumPoints_B;i+=1)
		if(indexB[i]>=0)
			Output[indexB[i]]=Boutput[i]
		endif
	Endfor
	
	For(i=0;i<NumPoints_Between;i+=1)
		angle_i=coordinates[borderAreaInfo[i][0]][1]
		Variable intensityA=AOutput[borderAreaInfo[i][1]]
		Variable intensityB=BOutput[borderAreaInfo[i][2]]
		Variable borderWidth=borderAngle2-borderAngle1
		Output[borderAreaInfo[i][0]]=intensityA*(borderAngle2-angle_i)/borderWidth+intensityB*(angle_i-borderAngle1)/borderWidth
	Endfor
	
	
	//KillWaves socketAInput, socketBInput, indexA, indexB, Aoutput, Boutput
	
	return outputPath
End

Function/S IAFf_Concat2D_F_Definition()
	return "5;0;0;0;1;1;Wave1D;Wave1D;Variable;Wave1D;Wave1D"
End

Function IAFf_Concat2D_F(argumentList)
	String argumentList
	
	//0th argument: EnergyInfo (to be copied)
	String EnergyInfoArg=StringFromList(0,argumentList)
	
	//1st argument: AngleInfo
	String AngleInfoArg=StringFromList(1,argumentList)
	
	//2nd argument: OffsetAngle
	String BOffsetArg=StringFromList(2,argumentList)
	
	//3rd argument: output EnergyInfo (=0th)
	String EnergyInfo2Arg=StringFromList(3,argumentList)
	
	//4th argument: output AngleInfo
	String AngleInfo2Arg=StringFromList(4,argumentList)
	
	Duplicate/O $EnergyInfoArg $EnergyInfo2Arg
	Duplicate/O $AngleInfoArg $AngleInfo2Arg
	Wave/D AngleInfo2=$AngleInfo2Arg
	
	
	NVAR Boffset=$BOffsetArg
	
	Variable AStart=AngleInfo2[0]
	Variable AEnd=AngleInfo2[0]+AngleInfo2[1]*AngleInfo2[2]
	Variable BStart=AStart+Boffset
	Variable BEnd=AEnd+Boffset
	Variable AngleStart=min(Astart,BStart)
	Variable AngleEnd=max(AEnd,BEnd)
	
	AngleInfo2[0]=AngleStart
	AngleInfo2[2]=ceil((AngleEnd-AngleStart)/AngleInfo2[1])
End