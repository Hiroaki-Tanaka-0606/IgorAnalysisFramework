#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_FontSize: return font size
Function IAFc_FontSize()
	return 16
End

//IAFc_HeightRatio: return height/fontSize of a letter
Function IAFc_HeightRatio()
	return 1
End

//IAFc_WidthRatio: return width/fontSize of a letter
Function IAFc_WidthRatio()
	return 0.7
End

//IAFc_FrameMargin: return margin of the frame of the flowchart [px]
Function IAFc_FrameMargin()
	return 10
End

//IAFc_FontName: return font name
Function/S IAFc_FontName()
	return "Courier New"
End

//IAFc_CalcChartWidth: calculate width of chart based on the length of the string
Function IAFc_CalcChartWidth(length)
	Variable length
	Variable margin=1
	
	Variable fs=IAFc_FontSize()
	Variable wr=IAFc_WidthRatio()
	return fs*wr*(length+margin)	
End

//IAFc_CalcChartHeight: calculate height
Function IAFc_CalcChartHeight(rows)
	Variable rows
	Variable margin=0.5
	Variable fs=IAFc_FontSize()
	Variable hr=IAFc_HeightRatio()
	return fs*hr*(rows+margin)
End

//IAFc_CalcUnitHeight: height of one row
Function IAFc_CalcUnitHeight()
	Variable fs=IAFc_FontSIze()
	Variable hr=IAFc_HeightRatio()
	return fs*hr
End

//IAFc_CallChart: Call Flowchart panel
Function IAFc_CallChart()
	Print("[IAFc_CallChart]")
	String currentFolder=GetDataFolder(1)
	
	String PanelTitle="Flowchart for "+currentFolder
	SVAR PanelName=IAF_Flowchart_Name
	Variable needCreation=0
	If(SVAR_Exists(PanelName))
		DoWindow $PanelName
		If(V_flag==0)
			needCreation=1
		Else
			//There is possibility where another panel named $PanelName exists
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
			
			If(cmpstr(winTitle,PanelTitle,1)==0)
				//The intended window exists
			Else
				//not exist
				needCreation=1
			Endif
		endif
	Else
		needCreation=1
	Endif
	
	If(needCreation==1)
		NewPanel/K=1 as PanelTitle
		String/G IAF_Flowchart_Name=S_name
	Endif
	
	SVAR PanelName=IAF_Flowchart_Name	
	DoWindow/F $PanelName
	
	If(needCreation==1)
		//set background white and add Update button
		//65535,65535,65535 is not white but transparent?
		ModifyPanel cbRGB=(65534,65535,65535)
		SetWindow $PanelName,hook(flowHook)=IAFc_Flowchart_Hook
		IAFc_UpdateChart(1)
	Else
		IAFc_UpdateChart(0)
	Endif
End

// Event handler for the Flowchart
Function IAFc_Flowchart_Hook(s)
	STRUCT WMWinHookStruct &s
	STRUCT Point mouseLoc
	mouseLoc=s.mouseLoc
	Execute "GetWindow kwTopWin,title"
	SVAR winTitle=S_value
	If(!SVAR_exists(winTitle))
		return 0
	Endif
	Variable titleLen=strlen(winTitle)
	//winTitle="Flowchart for **"
	If(titleLen<15)
		return 0
	Endif
	String path=winTitle[14,titleLen-1]
	If(!DataFolderExists(path))
		return 0
	Endif
	
	String dataFolder=getDataFolder(1)
	Switch(s.eventCode)
	Case 3: //mousedown
		cd $path
		Variable/G IAF_Flowchart_Clicked=1
		Variable/G IAF_Flowchart_MouseLeft=mouseLoc.h
		Variable/G IAF_Flowchart_MouseTop=mouseLoc.v
		// printf "Mouse %d %d\n", IAF_Flowchart_MouseLeft, IAF_Flowchart_MouseTop
		If(!DataFolderExists("Configurations"))
			cd dataFolder
			return 0
		Endif
		Wave/D ChartPosition=$":Configurations:ChartPosition"
		Wave/T ChartIndex=$":Configurations:ChartIndex"
		Variable size=DimSize(ChartPosition,0)
		Variable selectedIndex=-1
		Variable i
		NVAR zoom=IAF_Flowchart_Zoom
		NVAR visibility=IAF_Flowchart_Visibility
		
		String OriginList=""
		For(i=size-1;i>=0;i-=1)
			If(whichlistitem(ChartIndex[i][1],OriginList)==-1)
				OriginList=AddListItem(ChartIndex[i][1],OriginList)
			Endif
		Endfor
		Make/O/D/N=(itemsInList(OriginList),4) FrameCoordinate
		//[left,top,right,bottom]
		Wave/D FrameCoordinate=FrameCoordinate
		FrameCoordinate[][]=NaN
		
		For(i=0;i<size;i+=1)
			If(visibility==0 && cmpstr((ChartIndex[i][0])[0,0],"_",1)==0)
				continue
			Endif
			Variable left  =(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
			Variable top   =(ChartPosition[i][1]-ChartPosition[i][3]/2)*zoom
			Variable right =(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
			Variable bottom=(ChartPosition[i][1]+ChartPosition[i][3]/2)*zoom
			If(left<IAF_Flowchart_MouseLeft && IAF_Flowchart_MouseLeft<right && top<IAF_Flowchart_MouseTop && IAF_Flowchart_MouseTop<bottom)
				selectedIndex=i
			Endif
			//check frame
			String partOrigin=ChartIndex[i][1]
			String partName=ChartIndex[i][0]
			Variable FrameIndex=whichlistitem(partOrigin,OriginList)
			If(FrameIndex==-1)
				Printf "Error: origin of \"%s\" not found\n", partName
				continue
			Endif
			//update frame coordinate
			If(numtype(FrameCoordinate[FrameIndex][0])==2 || FrameCoordinate[FrameIndex][0]>left)
				FrameCoordinate[FrameIndex][0]=left
			Endif
			If(numtype(FrameCoordinate[FrameIndex][1])==2 || FrameCoordinate[FrameIndex][1]>top)
				FrameCoordinate[FrameIndex][1]=top
			Endif
			If(numtype(FrameCoordinate[FrameIndex][2])==2 || FrameCoordinate[FrameIndex][2]<right)
				FrameCoordinate[FrameIndex][2]=right
			Endif
			If(numtype(FrameCoordinate[FrameIndex][3])==2 || FrameCoordinate[FrameIndex][3]<bottom)
				FrameCoordinate[FrameIndex][3]=bottom
			Endif
		Endfor
		If(selectedIndex>=0)
			//a part is selected
			Variable/G IAF_Flowchart_Selected=selectedIndex
			Variable/G IAF_Flowchart_ChartLeft=ChartPosition[selectedIndex][0]
			Variable/G IAF_Flowchart_ChartTop=ChartPosition[selectedIndex][1]
		Else
			//check whethehr a frame is selected
			Variable selectedFrameIndex=-1
			Variable margin=IAFc_FrameMargin()*zoom
			For(i=0;i<DimSize(FrameCoordinate,0);i+=1)
				If(numtype(FrameCoordinate[i][0])==2)
					continue
				Endif
				left=FrameCoordinate[i][0]-margin
				top=FrameCoordinate[i][1]-margin
				right=FrameCoordinate[i][2]+margin
				bottom=FrameCoordinate[i][3]+margin
				If(left<IAF_Flowchart_MouseLeft && IAF_Flowchart_MouseLeft<right && top<IAF_Flowchart_MouseTop && IAF_Flowchart_MouseTop<bottom)
					selectedFrameIndex=i
				Endif
			Endfor
			If(selectedFrameIndex>=0)
				Variable/G IAF_Flowchart_Selected=-1
				String/G IAF_Flowchart_SelectedFrame=StringFromList(selectedFrameIndex,originList)
				duplicate ChartPosition $":Configurations:oldChartPosition"
			Endif
			
		Endif
		KillWaves FrameCoordinate
		cd $dataFolder
		break
	Case 4: //mousemove
		cd $path
		NVAR clicked=IAF_Flowchart_Clicked
		If(!NVAR_exists(clicked) || clicked!=1)
			cd $dataFolder
			return 0
		Endif
		NVAR oldMouseLeft=IAF_Flowchart_MouseLeft
		NVAR oldMouseTop=IAF_Flowchart_MouseTop
		NVAR oldChartLeft=IAF_Flowchart_ChartLeft
		NVAR oldChartTop=IAF_Flowchart_ChartTop
		NVAR oldSelectedIndex=IAF_Flowchart_Selected
		SVAR oldSelectedFrame=IAF_Flowchart_SelectedFrame
		NVAR zoom=IAF_Flowchart_Zoom
		If(!NVAR_exists(oldMouseLeft) || !NVAR_exists(oldMouseTop) || !NVAR_exists(oldChartLeft) || !NVAR_exists(oldChartTop) || !NVAR_exists(oldSelectedIndex) || !NVAR_exists(zoom))
			cd $dataFolder
			return 0
		Endif
		Variable mouseLeft=mouseLoc.h
		Variable mouseTop=mouseLoc.v
		If(!DataFolderExists("Configurations"))
			cd $dataFolder
			return 0
		Endif
		Wave/D ChartPosition=$":Configurations:ChartPosition"
		If(oldSelectedIndex>=0)
			ChartPosition[oldSelectedIndex][0]=oldChartLeft+(mouseLeft-oldMouseLeft)/zoom
			ChartPosition[oldSelectedIndex][1]=oldChartTop+(mouseTop-oldMouseTop)/zoom
		Elseif(oldSelectedIndex==-1)
			Wave/T ChartIndex=$":Configurations:ChartIndex"
			Wave/D oldChartPosition=$":Configurations:oldChartPosition"
			If(!SVAR_exists(oldSelectedFrame) || cmpstr(oldSelectedFrame,"",1)==0)
				cd $datafolder
				return 0
			Endif
			For(i=0;i<DimSize(ChartIndex,0);i+=1)
				if(cmpstr(oldSelectedFrame,ChartIndex[i][1],1)==0)
					ChartPosition[i][0]=oldChartPosition[i][0]+(mouseLeft-oldMouseLeft)/zoom
					ChartPosition[i][1]=oldChartPosition[i][1]+(mouseTop-oldMouseTop)/zoom
				Endif
			Endfor
			
		Endif
		IAFc_UpdateChart(0)
		cd $dataFolder
		break
	Case 5: //mouseup
		cd $path
		Variable/G IAF_Flowchart_Clicked=0
		String/G IAF_Flowchart_SelectedFrame=""
		Wave/D a=$":Configurations:oldChartPosition"
		If(WaveExists(a))
			KillWaves a
		Endif
		cd $dataFolder
		break
	Endswitch
End

//Update Flowchart (with control objects)
Function IAFc_UpdateChart(updateControl)
	Variable updateControl
	
	String currentFolder=GetDataFolder(1)
	
	Execute "GetWindow kwTopWin,title"
	SVAR winTitle=S_value
	If(!SVAR_exists(winTitle))
		return 0
	Endif
	Variable titleLen=strlen(winTitle)
	//winTitle="Flowchart for **"
	If(titleLen<15)
		return 0
	Endif
	String path=winTitle[14,titleLen-1]
	If(!DataFolderExists(path))
		return 0
	Endif
	cd $path
	
	String fn=IAFc_FontName()
	NVAR zoom=IAF_Flowchart_Zoom
	If(!NVAR_Exists(zoom))
		Variable/G IAF_Flowchart_Zoom=1
	Endif
	NVAR zoom=IAF_Flowchart_Zoom
	NVAR visibility=IAF_Flowchart_Visibility
	If(!NVAR_Exists(visibility))
		Variable/G IAF_Flowchart_Visibility=0
	Endif
	NVAR visibility=IAF_Flowchart_Visibility
	
	Variable fs=IAFc_FontSize()*zoom
	
	If(updateControl==1)
		//remove controls
		KillControl updateButton
		KillControl zoomVariable
		KillControl visibilityCheckBox
		//create controls
		Variable margin=10*zoom
		Variable width1=IAFc_CalcChartWidth(6)*zoom
		Variable width2=IAFc_CalcChartWidth(10)*zoom
		Variable width3=IAFc_CalcChartWidth(15)*zoom
		Variable height=IAFc_CalcChartHeight(1)*zoom
		String command
		sprintf command,"Button updateButton pos={%g,%g},font=\"%s\", fsize=%g, size={%g,%g}, title=\"Update\",proc=IAFc_Flowchart_Update",margin,margin,fn,fs,width1,height
		//Print(command)
		Execute command
		sprintf command,"SetVariable zoomVariable pos={%g,%g},font=\"%s\",fsize=%g, size={%g,%g},title=\"Zoom:\",limits={0.1,10,0.05},value=IAF_Flowchart_Zoom,proc=IAFc_Flowchart_zoomUpdate",margin*2+width1,margin,fn,fs,width2,height
		Execute command
		sprintf command,"CheckBox visibilityCheckBox pos={%g,%g},font=\"%s\",fsize=%g,size={%g,%g},title=\"Show all parts\",variable=IAF_Flowchart_Visibility,proc=IAFc_Flowchart_visibUpdate",margin*4+width1+width2,margin,fn,fs,width3,height
		Execute command
	Endif
	
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	cd Configurations
	
	//remove flowchart
	DrawAction delete
	
	//create flowchart
	Wave/T ChartIndex=ChartIndex
	Wave/D ChartPosition=ChartPosition
	Variable numParts=DimSize(ChartIndex,0)
	Variable numParts2=DimSize(ChartPosition,0)
	If(numParts!=numParts2)
		Print("Error: number of parts doesn't coincide between ChartIndex and ChartPosition")
		return 0
	Endif
	
	sprintf command,"SetDrawEnv fname=\"%s\"",fn
	Execute command
	sprintf command,"SetDrawEnv fsize=%d",fs
	Execute command
	SetDrawEnv textxjust=1
	SetDrawEnv textyjust=1
	SetDrawEnv fillfgc=(65535,65535,65535)
	SetDrawEnv save
	
	Variable unitHeight=IAFc_CalcUnitHeight()
	Variable i
	String PartsList=""
	String OriginList=""
	For(i=numParts-1;i>=0;i-=1)
		PartsList=AddListItem(ChartIndex[i][0],PartsList)
		If(whichlistitem(ChartIndex[i][1],OriginList)==-1)
			OriginList=AddListItem(ChartIndex[i][1],OriginList)
		Endif
	Endfor
	//Print(OriginList)
	Make/O/D/N=(itemsInList(OriginList),4) FrameCoordinate
	//[left,top,right,bottom]
	Wave/D FrameCoordinate=FrameCoordinate
	FrameCoordinate[][]=NaN
	
	//Print(PartsList)
	cd $path
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	cd Diagrams
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2") 
	cd $path
	NVAR visibility=IAF_Flowchart_Visibility
	If(!NVAR_exists(visibility))
		Variable/G IAF_Flowchart_Visibility=0
	Endif
	NVAR visibility=IAF_Flowchart_Visibility
	cd Configurations	
	For(i=0;i<numParts;i+=1)
		String partName=ChartIndex[i][0]
		String partOrigin=ChartIndex[i][1]
		if(cmpstr(partName[0,0],"_",1)==0 && visibility==0)
			continue
		Endif

		String DiagramInfoList=IAFc_DiagramInfo(partName,DiagramWaveList)
		If(cmpstr(DiagramInfoList,"Diagram not found",1)==0)
			Printf "Error: Diagram \"%s\" not found\n", partName
			continue
		Endif
		String partKind=StringFromList(0,DiagramInfoList)
		String partType=StringFromList(1,DiagramInfoList)		
		//rectangle
		SetDrawEnv linethick=2 //for parts rectangles
		if(cmpstr(partKind, "Data", 1)==0)
			SetDrawEnv linefgc=(0,0,0) //black
		elseif(cmpstr(partKind, "Function", 1)==0)
			SetDrawEnv linefgc=(0,0,65535) //blue
		elseif(cmpstr(partKind, "Module", 1)==0)
			SetDrawEnv linefgc=(65535,0,0) //red
		elseif(cmpstr(partKind, "Panel", 1)==0)
			SetDrawEnv linefgc=(0,65535,0) //green
		endif
		//rectangle
		Variable left  =(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
		Variable top   =(ChartPosition[i][1]-ChartPosition[i][3]/2)*zoom
		Variable right =(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
		Variable bottom=(ChartPosition[i][1]+ChartPosition[i][3]/2)*zoom

		//check frame
		Variable FrameIndex=whichlistitem(partOrigin,OriginList)
		If(FrameIndex==-1)
			Printf "Error: origin of \"%s\" not found\n", partName
			continue
		Endif
		//update frame coordinate
		If(numtype(FrameCoordinate[FrameIndex][0])==2 || FrameCoordinate[FrameIndex][0]>left)
			FrameCoordinate[FrameIndex][0]=left
		Endif
		If(numtype(FrameCoordinate[FrameIndex][1])==2 || FrameCoordinate[FrameIndex][1]>top)
			FrameCoordinate[FrameIndex][1]=top
		Endif
		If(numtype(FrameCoordinate[FrameIndex][2])==2 || FrameCoordinate[FrameIndex][2]<right)
			FrameCoordinate[FrameIndex][2]=right
		Endif
		If(numtype(FrameCoordinate[FrameIndex][3])==2 || FrameCoordinate[FrameIndex][3]<bottom)
			FrameCoordinate[FrameIndex][3]=bottom
		Endif
		
		//draw rectangle	
		DrawRect left,top,right,bottom		
		//upper row: type
		DrawText ChartPosition[i][0]*zoom,(ChartPosition[i][1]-unitHeight/2)*zoom,partType
		//lower row: name
		DrawText ChartPosition[i][0]*zoom,(ChartPosition[i][1]+unitHeight/2)*zoom,partName
		
		//connections
		SetDrawEnv linethick=1 //for parts connections
		SetDrawEnv arrow=1
		
		SetDrawEnv save
		String Definition=""
		//Print("\""+partName+"\"")
		if(cmpstr(partKind, "Data", 1)==0)
			//no connection
		else
			if(cmpstr(partKind, "Function", 1)==0)
				Definition=IAFc_Function_Definition(partType)
			elseif(cmpstr(partKind, "Module", 1)==0)
				Definition=IAFc_Module_Definition(partType)
			elseif(cmpstr(partKind, "Panel", 1)==0)
				Definition=IAFc_Panel_Definition(partType)
			else
				continue
			endif
			
			Variable numArgs=str2num(StringFromList(0,Definition))
			Variable j
			For(j=0;j<numArgs;j+=1)
				//Print(StringFromList(1+j,Definition))
				String inout_j=StringFromList(1+j,Definition)
				if(cmpstr(inout_j, "0", 1)==0)
					//input
					Switch(IAFc_JudgeDataSocket(StringFromList(1+numArgs+j,Definition)))
					Case 1:
						//data
						SetDrawEnv linefgc=(0,0,0)
						break
					Case 2:
						//socket
						SetDrawEnv linefgc=(65535,0,65535)
						break
					Endswitch
					String startPartName=StringFromList(3+j,DiagramInfoList)
					If(cmpstr(startPartName[0,0],"_",1)==0 && visibility==0)
						continue
					endif
					//Print("startPart "+startPartName)
					Variable start_index=WhichListItem(startPartName,PartsList)
					Variable start_left=(ChartPosition[start_index][0]+ChartPosition[start_index][2]/2)*zoom
					Variable start_top=(ChartPosition[start_index][1])*zoom
					Variable end_left=(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
					Variable end_top=ChartPosition[i][1]*zoom
					DrawLine start_left,start_top,end_left,end_top
				elseif(cmpstr(inout_j, "1", 1)==0)
					//output
					SetDrawEnv linefgc=(0,0,0)
					String endPartName=StringFromList(3+j,DiagramInfoList)
					If(cmpstr(endPartName[0,0],"_",1)==0 && visibility==0)
						continue
					endif
					Variable end_index=WhichListItem(StringFromList(3+j,DiagramInfoList),PartsList)
					end_left=(ChartPosition[end_index][0]-ChartPosition[end_index][2]/2)*zoom
					end_top=(ChartPosition[end_index][1])*zoom
					start_left=(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
					start_top=ChartPosition[i][1]*zoom
					DrawLine start_left,start_top,end_left,end_top
				endif
			Endfor
		Endif
		
	Endfor
	
	//draw frame
	SetDrawEnv linethick=1
	SetDrawEnv linefgc=(32768,32768,32768) //gray
	SetDrawEnv fillpat=0
	SetDrawEnv save
	margin=IAFc_FrameMargin()*zoom
	For(i=0;i<DimSize(FrameCoordinate,0);i+=1)
		If(numtype(FrameCoordinate[i][0])==2)
			continue
		Endif
		// printf "Frame %d %d %d %d\n", FrameCoordinate[i][0], FrameCoordinate[i][1], FrameCoordinate[i][2], FrameCoordinate[i][3]
		DrawRect FrameCoordinate[i][0]-margin, FrameCoordinate[i][1]-margin, FrameCoordinate[i][2]+margin, FrameCoordinate[i][3]+margin
	Endfor
	KillWaves FrameCoordinate
	cd $currentFolder
End


//called when updatebutton is clicked (mouse-up)
Function IAFc_Flowchart_Update(BV): ButtonControl
	STRUCT WMButtonAction &BV
	If(BV.eventCode==2)
		IAFc_UpdateChart(1)
	Endif
End

//called when zoom setvariable is updated
Function IAFc_Flowchart_zoomUpdate(SV): SetVariableControl
	STRUCT WMSetVariableAction &SV
	If(SV.eventCode==1 || SV.eventCode==2)
		IAFc_UpdateChart(1)
	Endif
End

//called when zoom setvariable is updated
Function IAFc_Flowchart_visibUpdate(CB): CheckBoxControl
	STRUCT WMCheckboxAction &CB
	If(CB.eventCode==2)
		IAFc_UpdateChart(0)
	Endif
End

//IAFc_DiagramInfo: find infomation in Diagrams
//currentFolder is Configurations
Function/S IAFc_DiagramInfo(partName,DiagramWaveList)
	String partname,DiagramWaveList
	
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i,j,k
	String InfoList=""
	Variable size1,size2
	For(i=0;i<numWaves;i+=1)
		String DiagramWavePath="::Diagrams:"+StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWavePath
		size1=DimSize(Diagram_i,0)
		size2=DimSize(Diagram_i,1)
		For(j=0;j<size1;j+=1)
			String Kind_ij=Diagram_i[j][0]
			String Type_ij=Diagram_i[j][1]
			String Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij))
				If(cmpstr(Name_ij,partName,1)==0)
					For(k=size2-1;k>=0;k-=1)
						InfoList=AddListItem(Diagram_i[j][k],InfoList)
					Endfor
					return InfoList
				Endif
			Endif
		Endfor
	Endfor
	
	return "Diagram not found"
End