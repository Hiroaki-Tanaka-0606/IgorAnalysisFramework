#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFcu_FontSize: return font size
Function IAFcu_FontSize()
	return 16
End

//IAFcu_HeightRatio: return height/fontSize of a letter
Function IAFcu_HeightRatio()
	return 1.44
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
		IAFc_UpdateChart(1)
	Endif
End

//Update Flowchart (with control objects)
Function IAFc_UpdateChart(updateControl)
	Variable updateControl
	
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