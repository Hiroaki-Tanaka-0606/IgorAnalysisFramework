#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Panel Sequence: sequentially change an index parameter
Function/S IAFp_Sequence_Definition()
	return "3;0;0;0;Variable;Variable;Variable"
End

Function IAFp_Sequence(argumentList,PanelName,PanelTitle)
	String argumentList, Panelname, PanelTitle
	
	//0th argument: index parameter
	String indexArg=StringFromList(0,argumentList)
	
	//1st argument: min of index
	String minIndexArg=StringFromList(1,argumentList)
	
	//2nd argument: max of index
	String maxIndexArg=StringFromList(2,argumentList)
	
	NVAR index=$indexArg
	NVAR minIndex=$minIndexArg
	NVAR maxIndex=$maxIndexArg
	
	//create a panel
	NewPanel/K=1/W=(0,0,300,60) as PanelTitle
		
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
	
	//put a setvariable
	IAFu_DrawSetVariable(0,0,indexArg,4,indexArg,1,1,minIndex,maxIndex,1)
	
	//sequentially increase, decrease buttons
	Variable fs=IAFc_FontSize()
	String fn=IAFc_FontName()
	
	Variable width=IAFc_CalcChartWidth(1)
	Variable height=IAFc_CalcChartHeight(1)
	
	String command
	String format
	sprintf format "Button %%s pos={%%g,%%g},font=\"%s\",fsize=%g,title=\"%%s\",proc=%s,size={%g,%g}",fn,fs,"IAFu_Sequence_Button",width,height
	
	sprintf command format,"SeqDecrease",50,30,"\W523"
	Execute command

	sprintf command format,"SeqIncrease",100,30,"\W517"
	Execute command

End


Function IAFu_Sequence_Button(BS): ButtonControl
	STRUCT WMButtonAction &BS
	If(BS.eventCode==1)
		String currentFolder=getDataFolder(1)
		
		Execute "GetWindow kwTopWin,activeSW"
		//if there is no subwindow, SWpath is the name of the window
		SVAR SWpath=S_value
		
		If(!SVAR_exists(SWpath))
			return 0
		Endif
		
		//Get Parent window name
		String windowName=StringFromList(0,SWpath,"#")
		
		//Get Parent window title
		Execute "GetWindow "+windowName+",title"
		SVAR winTitle=S_value
		If(!SVAR_exists(winTitle))
			return 0
		Endif
		
		
		//winTitle="panelName in DataFolder"
		Variable inIndex=strsearch(winTitle," in ",0)
		If(inIndex==-1)
			return 0
		Endif
		String DataFolder=winTitle[inIndex+4,strlen(winTitle)-1]
		String panelName=winTitle[0,inIndex-1]
		
		String indexArg=""
		String minIndexArg=""
		String maxIndexArg=""
		cd $DataFolder
		
		cd Diagrams
		String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")

		Variable numWaves=ItemsInList(DiagramWaveList)
		Variable i
		For(i=0;i<numWaves;i+=1)
			String DiagramWaveName=StringFromList(i,DiagramWaveList)
			Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
			Variable WaveSize=DimSize(Diagram_i,0)
			Variable j
			For(j=0;j<WaveSize;j+=1)
				String Kind_ij=Diagram_i[j][0]
				String Type_ij=Diagram_i[j][1]
				String Name_ij=Diagram_i[j][2]
				If(IAFc_VerifyKindType(Kind_ij,Type_ij))
					If(cmpstr(Kind_ij,"Panel")==0 && cmpstr(Name_ij,panelName)==0)
						indexArg=Diagram_i[j][3]
						minIndexArg=Diagram_i[j][4]
						maxIndexArg=Diagram_i[j][5]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data
		
		NVAR index=$indexArg
		NVAR minIndex=$minIndexArg
		NVAR maxIndex=$maxIndexArg
		cd ::
				
		strswitch(BS.ctrlName)
			case "SeqDecrease":
				For(;index>=minIndex;index-=1)
					IAFc_Update(indexArg)
				Endfor
				index=minIndex
				break
			case "SeqIncrease":
				For(;index<=maxIndex;index+=1)
					IAFc_Update(indexArg)
				Endfor
				index=maxIndex
				break
		Endswitch
		cd $currentFolder
	Endif
	return 1
End

//Function ExtractVariable: get a value from a Wave1D
Function/S IAFf_ExtractVariable_Definition()
	return "3;0;0;1;Wave1D;Variable;Variable"
End

Function IAFf_ExtractVariable(argumentList)
	String argumentList
	
	//0th argument: input wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: index
	String indexArg=StringFromList(1,argumentList)
	
	//2nd argument: value
	String valueArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	NVAR index=$indexArg
	Variable/G $valueArg=input[index]
	
End


//Function ExtractWave1D: get a Wave1D input[index][] from a Wave2D 
Function/S IAFf_ExtractWave1DX_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave1D"
End

Function IAFf_ExtractWave1DX(argumentList)
	String argumentList
	
	//0th argument: input wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: index
	String indexArg=StringFromList(1,argumentList)
	
	//2nd argument: outputWave
	String outputArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	NVAR index=$indexArg
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	Variable size2=DimSize(input,1)
	Make/O/D/N=(size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset2, delta2, output
	output[]=input[index][p]
End


//Function StoreVariable: save a value in a Wave1D
Function/S IAFf_StoreVariable_Definition()
	return "4;0;0;0;1;Wave1D;Variable;Variable;Wave1D"
End

Function IAFf_StoreVariable(argumentList)
	String argumentList
	
	//0th argument: waveinfo of the output wave
	String outputInfoArg=StringFromList(0,argumentList)
	
	//1st argument: index
	String indexArg=StringFromList(1,argumentList)
	
	//2nd argument: value
	String valueArg=StringFromList(2,argumentList)
	
	//3rd argument: output wave
	String outputArg=StringFromList(3,argumentList)
	
	Wave/D outputInfo=$outputInfoArg
	NVAR index=$indexArg
	NVAR value=$valueArg
	
	Wave/D output=$outputArg
	//check the existence of the output with the same size specified by waveinfo input
	If(Waveexists(output)==0 || DimSize(output,0)!=outputInfo[2])
		Make/O/D/N=(outputInfo[2]) $outputArg
		Wave/D output=$outputArg
		SetScale/P x, outputInfo[0], outputInfo[1], output
	Endif
	output[index]=value
	
End


//Function StoreVariable2D: save a value in a Wave2D
Function/S IAFf_StoreVariable2D_Definition()
	return "6;0;0;0;0;0;1;Wave1D;Wave1D;Variable;Variable;Variable;Wave2D"
End

Function IAFf_StoreVariable2D(argumentList)
	String argumentList
	
	//0th argument: waveinfo of the output wave 1st axis
	String xInfoArg=StringFromList(0,argumentList)
	
	//1st argument: waveinfo of 2nd axis
	String yInfoArg=StringFromList(1,argumentList)
	
	//2nd argument: x index
	String xIndexArg=StringFromList(2,argumentList)
	
	//3rd argument: y index
	String yIndexArg=StringFromList(3,argumentList)
	
	//4th argument: value
	String valueArg=StringFromList(4,argumentList)
	
	//3rd argument: output wave
	String outputArg=StringFromList(5,argumentList)
	
	Wave/D xInfo=$xInfoArg
	Wave/D yInfo=$yInfoArg
	NVAR xIndex=$xIndexArg
	NVAR yIndex=$yIndexArg
	NVAR value=$valueArg
	
	Wave/D output=$outputArg
	
	//check the existence of the output with the same size specified by waveinfo input
	If(Waveexists(output)==0 || DimSize(output,0)!=xInfo[2] || DimSize(output,1)!=yInfo[2])
		Make/O/D/N=(xInfo[2],yInfo[2]) $outputArg
		Wave/D output=$outputArg
		SetScale/P x, xInfo[0], xInfo[1], output
		SetScale/P y, yInfo[0], yInfo[1], output
	Endif
	output[xIndex][yIndex]=value
End

//Function ExtractString: get a value from a TextWave
Function/S IAFf_ExtractString_Definition()
	return "3;0;0;1;TextWave;Variable;String"
End

Function IAFf_ExtractString(argumentList)
	String argumentList
	
	//0th argument: input wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: index
	String indexArg=StringFromList(1,argumentList)
	
	//2nd argument: value
	String valueArg=StringFromList(2,argumentList)
	
	Wave/T input=$inputArg
	NVAR index=$indexArg
	String/G $valueArg=input[index]
	
End

//Function StoreWave13D: save Wave1D[] in a Wave3D[][i][j]
Function/S IAFf_StoreWave13D_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Wave1D;Wave3D"
End

Function IAFf_StoreWave13D(argumentList)
	String argumentList
	
	//0th argument: waveinfo of the output wave 1st index
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: waveinfo of the output wave 2nd index
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: waveinfo of the output wave 3rd index
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3rd argument: 2nd index 
	String index2Arg=StringFromList(3,argumentList)
	
	//4th argument: 3rd index 
	String index3Arg=StringFromList(4,argumentList)
	
	//5th argument: wave to be stored
	String valueWaveArg=StringFromList(5,argumentList)
	
	//6th argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	
	NVAR index2=$index2Arg
	NVAR index3=$index3Arg
	Wave/D valueWave=$valueWaveArg
	
	Wave/D output=$outputArg
	//check the existence of the output with the same size specified by waveinfo input
	If(Waveexists(output)==0 || DimSize(output,0)!=waveInfo1[2] || DimSize(output,1)!=waveInfo2[2]|| DimSize(output,2)!=waveInfo3[2])
		Make/O/D/N=(waveInfo1[2], waveInfo2[2], waveInfo3[2]) $outputArg
		Wave/D output=$outputArg
		SetScale/P x, waveInfo1[0], waveInfo1[1], output
		SetScale/P y, waveInfo2[0], waveInfo2[1], output
		SetScale/P z, waveInfo3[0], waveInfo3[1], output
	Endif
	If(DimSize(valueWave,0)!=waveInfo1[2])
		Print("StoreWave13D Error: size mismatch")
		abort
	Endif
	output[][index2][index3]=valueWave[p]
	
End

//Function mod: return remainder
Function/S IAFf_Mod_Definition()
	return "3;0;0;1;Variable;Variable;Variable"
End

Function IAFf_Mod(argumentList)
	String argumentList
	
	//0th argument: a
	String aArg=StringFromList(0,argumentList)
	
	//1st argument: b
	String bArg=StringFromList(1,argumentList)
	
	//2nd argument: c=a%b
	String cArg=StringFromList(2,argumentList)
	NVAR a=$aArg
	NVAR b=$bArg
	Variable/G $cArg=mod(a,b)
	
End

//Function quotient: return quotient
Function/S IAFf_Quotient_Definition()
	return "3;0;0;1;Variable;Variable;Variable"
End

Function IAFf_Quotient(argumentList)
	String argumentList
	
	//0th argument: a
	String aArg=StringFromList(0,argumentList)
	
	//1st argument: b
	String bArg=StringFromList(1,argumentList)
	
	//2nd argument: c=floor(a/b)
	String cArg=StringFromList(2,argumentList)
	
	NVAR a=$aArg
	NVAR b=$bArg
	Variable/G $cArg=floor(a*1.0/b)
	
End


//Function StoreWave12D: save Wave1D[] in a Wave2D[][i]
Function/S IAFf_StoreWave12D_Definition()
	return "5;0;0;0;0;1;Wave1D;Wave1D;Variable;Wave1D;Wave2D"
End

Function IAFf_StoreWave12D(argumentList)
	String argumentList
	
	//0th argument: waveinfo of the output wave 1st index
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: waveinfo of the output wave 2nd index
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: 2nd index 
	String index2Arg=StringFromList(2,argumentList)
	
	//3rd argument: wave to be stored
	String valueWaveArg=StringFromList(3,argumentList)
	
	//4th argument: output wave
	String outputArg=StringFromList(4,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	
	NVAR index2=$index2Arg
	Wave/D valueWave=$valueWaveArg
	
	Wave/D output=$outputArg
	//check the existence of the output with the same size specified by waveinfo input
	If(Waveexists(output)==0 || DimSize(output,0)<waveInfo1[2] || DimSize(output,1)!=waveInfo2[2])
		Make/O/D/N=(waveInfo1[2], waveInfo2[2]) $outputArg
		Wave/D output=$outputArg
		SetScale/P x, waveInfo1[0], waveInfo1[1], output
		SetScale/P y, waveInfo2[0], waveInfo2[1], output
	Endif
	If(DimSize(valueWave,0)!=waveInfo1[2])
		Print("StoreWave12D Error: size mismatch")
		abort
	Endif
	variable jmax=min(dimsize(output,0), dimsize(valuewave,0))
	variable j
	output[][index2]=0
	for(j=0; j<jmax; j++)
		output[j][index2]=valueWave[j]
	endfor
	
End


//Function StoreWave23D: save Wave2D[][] in a Wave3D[][][i]
Function/S IAFf_StoreWave23D_Definition()
	return "6;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Wave2D;Wave3D"
End

Function IAFf_StoreWave23D(argumentList)
	String argumentList
	
	//0th argument: waveinfo of the output wave 1st index
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: waveinfo of the output wave 2nd index
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: waveinfo of the output wave 3rd index
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3rd argument: 3rd index 
	String index3Arg=StringFromList(3,argumentList)
	
	//4th argument: wave to be stored
	String valueWaveArg=StringFromList(4,argumentList)
	
	//5th argument: output wave
	String outputArg=StringFromList(5,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	
	NVAR index3=$index3Arg
	Wave/D valueWave=$valueWaveArg
	
	Wave/D output=$outputArg
	//check the existence of the output with the same size specified by waveinfo input
	If(Waveexists(output)==0 || DimSize(output,0)!=waveInfo1[2] || DimSize(output,1)!=waveInfo2[2] || DimSize(output,2)!=waveInfo3[2])
		Make/O/D/N=(waveInfo1[2], waveInfo2[2], waveInfo3[2]) $outputArg
		Wave/D output=$outputArg
		SetScale/P x, waveInfo1[0], waveInfo1[1], output
		SetScale/P y, waveInfo2[0], waveInfo2[1], output
		SetScale/P z, waveInfo3[0], waveInfo3[1], output

	Endif
	If(DimSize(valueWave,0)!=waveInfo1[2] || DimSize(valueWave,1)!=waveInfo2[2])
		Print("StoreWave23D Error: size mismatch")
		abort
	Endif
	output[][][index3]=valueWave[p][q]
	
End