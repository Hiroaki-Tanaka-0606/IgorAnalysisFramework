#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "IAFcu_VerifyKindType"

//IAFcu_FontSize: return font size
Function IAFcu_FontSize()
	return 16
End

//IAFcu_HeightRatio: return height/fontSize of a letter
Function IAFcu_HeightRatio()
	return 1
End

//IAFcu_WidthRatio: return width/fontSize of a letter
Function IAFcu_WidthRatio()
	return 0.8
End

//IAFcu_FontName: return font name
Function/S IAFcu_FontName()
	return "Courier New"
End

//IAFcu_CalcChartWidth: calculate width of chart from length of letter
Function IAFcu_CalcChartWidth(length)
	Variable length
	Variable margin=1
	
	Variable fs=IAFcu_FontSize()
	Variable wr=IAFcu_WidthRatio()
	return fs*wr*(length+margin)	
End

//IAFcu_CalcChartHeight: calculate height
Function IAFcu_CalcChartHeight(rows)
	Variable rows
	Variable margin=0.5
	Variable fs=IAFcu_FontSize()
	Variable hr=IAFcu_HeightRatio()
	return fs*hr*(rows+margin)
End

//IAFcu_CalcUnitHeight: height of one row
Function IAFcu_CalcUnitHeight()
	Variable fs=IAFcu_FontSIze()
	Variable hr=IAFcu_HeightRatio()
	return fs*hr
End

//IAFc_CallChart: Call Flowchart panel
Function IAFc_CallChart()
	Print("[IAFc_CallChart]")
	String currentFolder=GetDataFolder(1)
	
	String PanelTitle="Flowchart for "+currentFolder
	SVAR PanelName=IAF_FlowchartPanel
	Variable needCreation=0
	If(SVAR_Exists(PanelName))
		DoWindow $PanelName
		If(V_flag==0)
			needCreation=1
		Endif
	Else
		needCreation=1
	Endif
	
	If(needCreation==1)
		NewPanel/K=1 as PanelTitle
		String/G IAF_FlowchartPanel=S_name
	Endif
	
	SVAR PanelName=IAF_FlowchartPanel	
	DoWindow/F $PanelName
	
	If(needCreation==1)
		//set background white and add Update button
		//65535,65535,65535 is not white but transparent?
		ModifyPanel cbRGB=(65534,65535,65535)
		SetWindow $PanelName,hook(flowHook)=IAFcu_Flowchart_Hook
		IAFc_UpdateChart(1)
	Else
		IAFc_UpdateChart(0)
	Endif
End

Function IAFcu_Flowchart_Hook(s)
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
		If(!DataFolderExists("Configurations"))
			cd dataFolder
			return 0
		Endif
		Wave/D ChartPosition=$":Configurations:ChartPosition"
		Variable size=DimSize(ChartPosition,0)
		Variable selectedIndex=-1
		Variable i
		NVAR zoom=IAF_FlowchartZoom
		For(i=0;i<size;i+=1)
			Variable left  =(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
			Variable top   =(ChartPosition[i][1]-ChartPosition[i][3]/2)*zoom
			Variable right =(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
			Variable bottom=(ChartPosition[i][1]+ChartPosition[i][3]/2)*zoom
			If(left<IAF_Flowchart_MouseLeft && IAF_Flowchart_MouseLeft<right && top<IAF_Flowchart_MouseTop && IAF_Flowchart_MouseTop<bottom)
				selectedIndex=i
			Endif
		Endfor
		If(selectedIndex>=0)
			Variable/G IAF_Flowchart_Selected=selectedIndex
			Variable/G IAF_Flowchart_ChartLeft=ChartPosition[selectedIndex][0]
			Variable/G IAF_Flowchart_ChartTop=ChartPosition[selectedIndex][1]
		Endif
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
		NVAR zoom=IAF_FlowchartZoom
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
		ChartPosition[oldSelectedIndex][0]=oldChartLeft+(mouseLeft-oldMouseLeft)/zoom
		ChartPosition[oldSelectedIndex][1]=oldChartTop+(mouseTop-oldMouseTop)/zoom
		IAFc_UpdateChart(0)
		cd $dataFolder
		break
	Case 5: //mouseup
		cd $path
		Variable/G IAF_Flowchart_Clicked=0
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
	
	String fn=IAFcu_FontName()
	NVAR zoom=IAF_FlowchartZoom
	If(!NVAR_Exists(zoom))
		Variable/G IAF_FlowchartZoom=1
	Endif
	NVAR zoom=IAF_FlowchartZoom
	Variable fs=IAFcu_FontSize()*zoom
	
	If(updateControl==1)
		//remove controls
		KillControl updateButton
		KillControl zoomVariable
		//create controls
		Variable margin=10*zoom
		Variable width1=IAFcu_CalcChartWidth(6)*zoom
		Variable width2=IAFcu_CalcChartWidth(10)*zoom
		Variable height=IAFcu_CalcChartHeight(1)*zoom
		String command
		sprintf command,"Button updateButton pos={%g,%g},font=\"%s\", fsize=%g, size={%g,%g}, title=\"Update\",proc=IAFcu_Flowchart_Update",margin,margin,fn,fs,width1,height
		//Print(command)
		Execute command
		sprintf command,"SetVariable zoomVariable pos={%g,%g},font=\"%s\",fsize=%g, size={%g,%g},title=\"Zoom:\",limits={0.1,10,0.05},value=IAF_FlowchartZoom,proc=IAFcu_Flowchart_zoomUpdate",margin,margin*2+height,fn,fs,width2,height
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
	
	Variable unitHeight=IAFcu_CalcUnitHeight()
	Variable i
	String PartsList=""
	For(i=numParts-1;i>=0;i-=1)
		PartsList=AddListItem(ChartIndex[i],PartsList)
	Endfor
	//Print(PartsList)
	cd $path
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	cd Diagrams
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	cd $path
	cd Configurations	
	For(i=0;i<numParts;i+=1)
		String partName=ChartIndex[i]
		String DiagramInfoList=IAFcu_DiagramInfo(partName,DiagramWaveList)
		If(cmpstr(DiagramInfoList,"Diagram not found")==0)
			Print("Error: Diagram \""+partName+"\" not found")
			continue
		Endif
		String partKind=StringFromList(0,DiagramInfoList)
		String partType=StringFromList(1,DiagramInfoList)
		//rectangle
		SetDrawEnv linethick=2 //for parts rectangles
		StrSwitch(partKind)
		Case "Data":
			SetDrawEnv linefgc=(0,0,0) //black
			break
		Case "Function":
			SetDrawEnv linefgc=(0,0,65535) //blue
			break
		Case "Module":
			SetDrawEnv linefgc=(65535,0,0) //red
			break
		Case "Panel":
			SetDrawEnv linefgc=(0,65535,0) //green
			break
		EndSwitch
		//rectangle
		Variable left  =(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
		Variable top   =(ChartPosition[i][1]-ChartPosition[i][3]/2)*zoom
		Variable right =(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
		Variable bottom=(ChartPosition[i][1]+ChartPosition[i][3]/2)*zoom
		DrawRect left,top,right,bottom
		
		//upper row: type
		DrawText ChartPosition[i][0]*zoom,(ChartPosition[i][1]-unitHeight/2)*zoom,partType
		//lower row: name
		DrawText ChartPosition[i][0]*zoom,(ChartPosition[i][1]+unitHeight/2)*zoom,partName
		
		//connections
		SetDrawEnv linethick=3 //for parts connections
		SetDrawEnv arrow=1
		
		SetDrawEnv save
		String Definition=""
		//Print("\""+partName+"\"")
		StrSwitch(partKind)
		Case "Data":
			//no connection
			break
		Case "Function":
			Definition=IAFc_Function_Definition(partType)
		Case "Module":
			If(cmpstr(Definition,"")==0)
				Definition=IAFc_Module_Definition(partType)
			Endif
			Variable numArgs=str2num(StringFromList(0,Definition))
			Variable j
			For(j=0;j<numArgs;j+=1)
				//Print(StringFromList(1+j,Definition))
				StrSwitch(StringFromList(1+j,Definition))
					Case "0":
						//input
						Switch(IAFcu_JudgeDataSocket(StringFromList(1+numArgs+j,Definition)))
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
						//Print("startPart "+startPartName)
						Variable start_index=WhichListItem(startPartName,PartsList)
						Variable start_left=(ChartPosition[start_index][0]+ChartPosition[start_index][2]/2)*zoom
						Variable start_top=(ChartPosition[start_index][1])*zoom
						Variable end_left=(ChartPosition[i][0]-ChartPosition[i][2]/2)*zoom
						Variable end_top=ChartPosition[i][1]*zoom
						DrawLine start_left,start_top,end_left,end_top
						break
					Case "1":
						//output
						SetDrawEnv linefgc=(0,0,0)
						Variable end_index=WhichListItem(StringFromList(3+j,DiagramInfoList),PartsList)
						end_left=(ChartPosition[end_index][0]-ChartPosition[end_index][2]/2)*zoom
						end_top=(ChartPosition[end_index][1])*zoom
						start_left=(ChartPosition[i][0]+ChartPosition[i][2]/2)*zoom
						start_top=ChartPosition[i][1]*zoom
						DrawLine start_left,start_top,end_left,end_top
						break
				EndSwitch
			Endfor
			break
		Case "Panel":
			break
		Endswitch
		
	Endfor
	
	cd $currentFolder
End


//called when updatebutton is clicked (mouse-up)
Function IAFcu_Flowchart_Update(BV): ButtonControl
	STRUCT WMButtonAction &BV
	If(BV.eventCode==2)
		IAFc_UpdateChart(1)
	Endif
End

//called when zoom setvariable is updated
Function IAFcu_Flowchart_zoomUpdate(SV): SetVariableControl
	STRUCT WMSetVariableAction &SV
	If(SV.eventCode==1 || SV.eventCode==2)
		IAFc_UpdateChart(1)
	Endif
End

//IAFcu_DiagramInfo: find infomation in Diagrams
//currentFolder is Configurations
Function/S IAFcu_DiagramInfo(partName,DiagramWaveList)
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
			If(IAFcu_VerifyKindType(Kind_ij,Type_ij))
				If(cmpstr(Name_ij,partName)==0)
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