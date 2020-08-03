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
	IAFcu_DrawSetVariable(0,0,indexArg,4,indexArg,1,1,minIndex,maxIndex,1)
	
	//sequentially increase, decrease buttons
	Variable fs=IAFcu_FontSize()
	String fn=IAFcu_FontName()
	
	Variable width=IAFcu_CalcChartWidth(1)
	Variable height=IAFcu_CalcChartHeight(1)
	
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
				If(IAFcu_VerifyKindType(Kind_ij,Type_ij))
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
	NvAR index=$indexArg
	Variable/G $valueArg=input[index]
	
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