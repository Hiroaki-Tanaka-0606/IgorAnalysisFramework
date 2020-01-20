#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_CallPanel: Call Panel, if it does not exist then create
Function IAFc_CallPanel(PanelName)
	String PanelName
	String currentFolder=GetDataFolder(1)
	Print("[IAFc_CallPanel]")
	
	String SVARName="IAF_"+PanelName+"_Name"
	SVAR gPanelName=$SVARName
	Variable needCreation=0
	If(SVAR_Exists(gPanelName))
		DoWindow/F $gPanelName
		If(V_flag==0)
			needCreation=1
		Endif
	Else
		needCreation=1
	Endif
	
	If(needCreation==1)
		String PanelTitle=PanelName+" in "+currentFolder
		IAFc_DrawPanel(PanelName,PanelTitle)
	Endif
End

//IAFc_CallPanelDialog: Call Panel, with dialog to choose which Panel to draw
Function IAFc_CallPanelDialog()
	String PanelList=""
	
	//find Diagram info	
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
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
				If(cmpstr(Kind_ij,"Panel")==0)
					PanelList=AddListItem(Name_ij,PanelList)
				Endif
			ENdif
		Endfor
	Endfor
	
	cd ::
	
	String PanelName
	Prompt PanelName, "Panel", popup, PanelList
	DoPrompt "Select Panel", PanelName
	If(V_flag!=0)
		return 0
	Endif
	
	IAFc_CallPanel(PanelName)	
End

//IAFc_ReCallPanel: Re-create Panel, even if it exists
Function IAFc_ReCallPanel(PanelName)
	String PanelName
	String currentFolder=GetDataFolder(1)
	Print("[IAFc_CallPanel]")
	
	String SVARName="IAF_"+PanelName+"_Name"
	SVAR gPanelName=$SVARName
	Variable needCreation=0
	If(SVAR_Exists(gPanelName))
		DoWindow/F $gPanelName
		If(V_flag==1)
			KillWindow $gPanelName
		Endif
	Endif
	
	String PanelTitle=PanelName+" in "+currentFolder
	IAFc_DrawPanel(PanelName,PanelTitle)
End

//IAFc_ReCallPanelDialog: Re-create Panel, with dialog to choose which Panel to draw
Function IAFc_ReCallPanelDialog()
	String PanelList=""
	
	//find Diagram info	
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
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
				If(cmpstr(Kind_ij,"Panel")==0)
					PanelList=AddListItem(Name_ij,PanelList)
				Endif
			ENdif
		Endfor
	Endfor
	
	cd ::
	
	String PanelName
	Prompt PanelName, "Panel", popup, PanelList
	DoPrompt "Select Panel", PanelName
	If(V_flag!=0)
		return 0
	Endif
	
	IAFc_ReCallPanel(PanelName)	
End

Function IAFcu_DrawSetVariable(x,y,title,variableName,visibility,autoUpdate)
	Variable x,y,visibility,autoUpdate
	String title,variableName
	
	Variable fs=IAFcu_FontSize()
	String fn=IAFcu_FontName()
	
	Variable width=IAFcu_CalcChartWidth(strlen(title)+5)
	Variable height=IAFcu_CalcChartHeight(1)
	
	String command
	sprintf command, "SetVariable %s pos={%g,%g},font=\"%s\",fsize=%g,size={%g,%g},value=%s,title=\"%s\"",variableName,x,y,fn,fs,width,height,variableName,title
	If(visibility==0)
		command=command+",disable=2"
	Endif
	If(autoUpdate==1)
		command=command+",proc=IAFcu_Panel_SetVariable"
	Endif
	
	Execute command
End

Function IAFcu_DrawUpdateButton(x,y)
	Variable x,y
	
	Variable fs=IAFcu_FontSize()
	String fn=IAFcu_FontName()
	
	Variable width=IAFcu_CalcChartWidth(6)
	Variable height=IAFcu_CalcChartHeight(1)
	
	String command
	sprintf command, "Button updateButton pos={%g,%g},font=\"%s\",fsize=%g,size={%g,%g},title=\"Update\",proc=IAFcu_Panel_Button",x,y,fn,fs,width,height
	Execute command
End

Function IAFcu_Panel_SetVariable(SV): SetVariableControl
	STRUCT WMSetVariableAction &SV
	If(SV.eventCode==1 || SV.eventCode==2)
		String currentFolder=getDataFolder(1)
		
		Execute "GetWindow kwTopWin,title"
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
		
		cd $DataFolder
		
		String ControlName=SV.ctrlName
		
		IAFc_Update(ControlName)
		
		cd $currentFolder
	Endif
End

Function IAFcu_Panel_Button(BV): ButtonControl
	STRUCT WMButtonAction &BV
	If(BV.eventCode==2)
		String currentFolder=getDataFolder(1)
		
		Execute "GetWindow kwTopWin,title"
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
		String PanelName=winTitle[0,inIndex-1]
		
		cd $DataFolder
		
		//list Variables and Strings on the Panel
		String DataList=""
		
		//find Diagram info	
		If(!DataFolderExists("Diagrams"))
			Print("Error: folder Diagrams does not exist")
			cd $currentFolder
			return 0
		Endif
		
		cd Diagrams
		String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")	

		Variable numWaves=ItemsInList(DiagramWaveList)
		Variable i,j,k
		For(i=0;i<numWaves;i+=1)
			String DiagramWaveName=StringFromList(i,DiagramWaveList)
			Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
			Variable WaveSize=DimSize(Diagram_i,0)
			For(j=0;j<WaveSize;j+=1)
				String Kind_ij=Diagram_i[j][0]
				String Type_ij=Diagram_i[j][1]
				String Name_ij=Diagram_i[j][2]
				If(IAFcu_VerifyKindType(Kind_ij,Type_ij))
					If(cmpstr(Kind_ij,"Panel")==0 && cmpstr(Name_ij,PanelName)==0)
						String Definition=IAFc_Panel_Definition(Type_ij)
						Variable numArgs=str2num(StringFromList(0,Definition))
						For(k=0;k<numArgs;k+=1)
							If(IAFcu_JudgeDataSocket(StringFromList(1+numArgs+k,Definition))==1)
								DataList=AddListItem(Diagram_i[j][k+3],DataList)
							Endif
						Endfor
						break
					Endif
				Endif
			Endfor
		Endfor
		cd ::
		IAFc_Update(DataList)
		cd $currentFolder

	Endif
ENd