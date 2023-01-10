#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Template 2DViewer
//argumentList:
//[0]: name of the panel(=name of the Diagram wave)
//[1]: 2D wave to show
//[2]: xLabel
Function IAFt_2DViewer(argumentList)
	String argumentList
	If(ItemsInList(argumentList)<3)
		Print("Error: Template 2DViewer need three arguments")
		return 0
	Endif
	String PanelName=stringfromlist(0,argumentList)
	String WaveName=StringFromList(1,argumentList)
	String xLabelName=StringFromList(2,argumentList)
	Make/O/T/N=(29,21) $PanelName
	
	//diagram wave
	Wave/T D=$PanelName
	//suffix
	String S="_"+PanelName
	//EDC
	D[0][0]="Data";      D[0][1]="Variable";     D[0][2]="_edc_start"+S
	D[1][0]="Data";      D[1][1]="Variable";     D[1][2]="_edc_end"+S
	D[2][0]="Data";      D[2][1]="Wave1D";       D[2][2]="EDC"+S
	D[3][0]="Function";  D[3][1]="EDC";          D[3][2]="E"+S; D[3][3]=WaveName; D[3][4]=D[0][2]; D[3][5]=D[1][2]; D[3][6]=D[2][2]
	//MDC
	D[4][0]="Data";      D[4][1]="Variable";     D[4][2]="_mdc_start"+S
	D[5][0]="Data";      D[5][1]="Variable";     D[5][2]="_mdc_end"+S
	D[6][0]="Data";      D[6][1]="Wave1D";       D[6][2]="MDC"+S
	D[7][0]="Function";  D[7][1]="MDC";          D[7][2]="M"+S; D[7][3]=WaveName; D[7][4]=D[4][2]; D[7][5]=D[5][2]; D[7][6]=D[6][2]
	//EDC & MDC cut
	D[8][0]="Data";      D[8][1]="Wave2D";       D[8][2]="_edccut"+S
	D[9][0]="Data";      D[9][1]="Wave2D";       D[9][2]="_mdccut"+S
	D[10][0]="Function"; D[10][1]="CutLines2D";    D[10][2]="_CL"+S; D[10][3]=WaveName; D[10][4]=D[0][2]; D[10][5]=D[1][2]; D[10][6]=D[4][2]; D[10][7]=D[5][2]; D[10][8]=D[8][2]; D[10][9]=D[9][2]
	//WaveInfo
	D[11][0]="Data";     D[11][1]="Wave1D";      D[11][2]="_energyinfo"+S
	D[12][0]="Data";     D[12][1]="Wave1D";      D[12][2]="_momentuminfo"+S
	D[13][0]="Function"; D[13][1]="WaveInfo2D";  D[13][2]="_WI"+S; D[13][3]=WaveName; D[13][4]=D[11][2]; D[13][5]=D[12][2];
	//EDC value2index
	D[14][0]="Data";     D[14][1]="Variable";    D[14][2]="_edccenter"+S
	D[15][0]="Data";     D[15][1]="Variable";    D[15][2]="_edcwidth"+S
	D[16][0]="Function"; D[16][1]="Value2Index"; D[16][2]="_EI"+S; D[16][3]=D[12][2]; D[16][4]=D[14][2]; D[16][5]=D[15][2]; D[16][6]=D[0][2]; D[16][7]=D[1][2]
	//MDC value2index
	D[17][0]="Data";     D[17][1]="Variable";    D[17][2]="_mdccenter"+S
	D[18][0]="Data";     D[18][1]="Variable";    D[18][2]="_mdcwidth"+S
	D[19][0]="Function"; D[19][1]="Value2Index"; D[19][2]="_MI"+S; D[19][3]=D[11][2]; D[19][4]=D[17][2]; D[19][5]=D[18][2]; D[19][6]=D[4][2]; D[19][7]=D[5][2]
	//EDC centerdelta
	D[20][0]="Data";     D[20][1]="Variable";    D[20][2]="_edccenterdelta"+S;
	D[21][0]="Function"; D[21][1]="DeltaChange"; D[21][2]="_ECC"+S; D[21][3]=D[12][2]; D[21][4]=D[20][2]; D[21][5]=D[14][2]
	//EDC widthdelta
	D[22][0]="Data";     D[22][1]="Variable";    D[22][2]="_edcwidthdelta"+S;
	D[23][0]="Function"; D[23][1]="DeltaChange"; D[23][2]="_EWC"+S; D[23][3]=D[12][2]; D[23][4]=D[22][2]; D[23][5]=D[15][2]
	//MDC centerdelta
	D[24][0]="Data";     D[24][1]="Variable";    D[24][2]="_mdccenterdelta"+S;
	D[25][0]="Function"; D[25][1]="DeltaChange"; D[25][2]="_MCC"+S; D[25][3]=D[11][2]; D[25][4]=D[24][2]; D[25][5]=D[17][2]
	//MDC widthdelta
	D[26][0]="Data";     D[26][1]="Variable";    D[26][2]="_mdcwidthdelta"+S;
	D[27][0]="Function"; D[27][1]="DeltaChange"; D[27][2]="_MWC"+S; D[27][3]=D[11][2]; D[27][4]=D[26][2]; D[27][5]=D[18][2]
	//Panel
	D[28][0]="Panel";    D[28][1]="2DViewer";    D[28][2]=PanelName;
	D[28][3]=WaveName;   D[28][4]=D[2][2];       D[28][5]=D[6][2];
	D[28][6]=D[0][2];    D[28][7]=D[1][2];       D[28][8]=D[4][2];
	D[28][9]=D[5][2];    D[28][10]=D[14][2];     D[28][11]=D[15][2];
	D[28][12]=D[17][2];  D[28][13]=D[18][2];     D[28][14]=xLabelName;
	D[28][15]=D[8][2];   D[28][16]=D[9][2];      D[28][17]=D[20][2];
	D[28][18]=D[24][2];  D[28][19]=D[22][2];     D[28][20]=D[26][2];

	return 1
End

//Function EDC: create Energy distribution curve (wave[][i,j])
Function/S IAFf_EDC_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave1D"
End

Function IAFf_EDC(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument (input): end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument (output): EDC wave
	String edcArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size2)
		Print("EDC Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	
	Make/O/D/N=(size1) $edcArg
	Wave/D edc=$edcArg
	SetScale/P x, offset1, delta1, edc
	edc[]=0
	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		edc[]+=input[p][i]
	Endfor	
End
	
	
//Function MDC: create Momentum distribution curve (wave[i,j][])
Function/S IAFf_MDC_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave1D"
End

Function IAFf_MDC(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument (input): end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument (output): MDC wave
	String mdcArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size1)
		Print("MDC Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size2) $mdcArg
	Wave/D mdc=$mdcArg
	SetScale/P x, offset2, delta2, mdc
	mdc[]=0
	
	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		mdc[]+=input[i][p]
	Endfor
End

//Function CutLines2D: create Energy cut and Momentum cut lines
Function/S IAFf_CutLines2D_Definition()
	return "7;0;0;0;0;0;1;1;Wave2D;Variable;Variable;Variable;Variable;Wave2D;Wave2D"
End

Function IAFf_CutLines2D(argumentList)
	String argumentList
		
	//0th argument (input): 2D wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): EDC start index
	String edcStartIndexArg=StringFromList(1,argumentList)
	
	//2nd argument (input): EDC end index
	String edcEndIndexArg=StringFromList(2,argumentList)
	
	//3rd argument (input): MDC start index
	String mdcStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument (input): MDC end index
	String mdcEndIndexArg=StringFromList(4,argumentList)
	
	//5th argument (output): EDC cut
	String edcWaveArg=StringFromList(5,argumentList)
	
	//6th argument (output): MDC cut
	String mdcWaveArg=StringFromList(6,argumentList)
	
	Wave/D input=$waveArg
	NVAR edcStartIndex=$edcStartIndexArg
	NVAR edcEndIndex=$edcEndIndexArg
	NVAR mdcStartIndex=$mdcStartIndexArg
	NVAR mdcEndIndex=$mdcEndIndexArg
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Variable edcStartValue=offset2+delta2*(edcStartIndex-0.5)
	Variable edcEndValue=offset2+delta2*(edcEndIndex+0.5)
	
	Variable mdcStartValue=offset1+delta1*(mdcStartIndex-0.5)
	Variable mdcEndValue=offset1+delta1*(mdcEndIndex+0.5)
	
	Make/O/D/N=(4,2) $edcWaveArg
	Wave/D edcCut=$edcWaveArg
	edcCut[0][0]=-inf
	edcCut[0][1]=edcStartValue
	edcCut[1][0]=inf
	edcCut[1][1]=edcStartValue
	edcCut[2][0]=inf
	edcCut[2][1]=edcEndValue
	edcCut[3][0]=-inf
	edcCut[3][1]=edcEndValue
	
	Make/O/D/N=(4,2) $mdcWaveArg
	Wave/D mdcCut=$mdcWaveArg
	mdcCut[0][1]=-inf
	mdcCut[0][0]=mdcStartValue
	mdcCut[1][1]=inf
	mdcCut[1][0]=mdcStartValue
	mdcCut[2][1]=inf
	mdcCut[2][0]=mdcEndValue
	mdcCut[3][1]=-inf
	mdcCut[3][0]=mdcEndValue

End

//Function Value2Index: calculate startIndex and endIndex from center and width
Function/S IAFf_Value2Index_Definition()
	return "5;0;0;0;1;1;Wave1D;Variable;Variable;Variable;Variable;"
End

Function IAFf_Value2Index(argumentList)
	String argumentList
		
	//0th argument (input): InfoWave [offset,delta,size]
	String infoArg=StringFromList(0,argumentList)
	
	//1st argument (input): center (input, but possibly changed by this function)
	String centerArg=StringFromList(1,argumentList)
	//2nd argument (input): width (input, but possibly chaned by this function)
	String widthArg=StringFromList(2,argumentList)
	
	//3rd argument (output): startIndex
	String startIndexArg=StringFromList(3,argumentList)
	//4tg argument (output): endIndex
	String endIndexArg=StringFromList(4,argumentList)
	
	Wave/D info=$infoArg
	Variable offset=info[0]
	Variable delta=info[1]
	Variable size=info[2]
	
	NVAR center=$centerArg
	NVAR width=$widthArg
	
	//Validate width
	Variable widthIndex=round(width/delta)
	If(widthIndex<=0)
		widthIndex=1
	Endif
	If(widthIndex>size)
		widthIndex=size
	Endif
	width=widthIndex*delta

	//Validate center
	Variable centerIndex_frac=(center-offset)/delta
	Variable startIndex,endIndex
	Variable deltaIndex
	Switch(mod(widthIndex,2))
	case 1:
		//widthIndex is odd
		//centerIndex is an integer
		Variable centerIndex_int=round(centerIndex_frac)
		startIndex=centerIndex_int-round((widthIndex-1)/2)
		endIndex=centerIndex_int+round((widthIndex-1)/2)
		If(startIndex<0)
			deltaIndex=-startIndex
			startIndex+=deltaIndex
			endIndex+=deltaIndex
			centerIndex_int+=deltaIndex
		Endif
		If(endIndex>=size)
			deltaIndex=endIndex-size+1
			startIndex-=deltaIndex
			endIndex-=deltaIndex
			centerIndex_int-=deltaIndex
		Endif
		center=offset+centerIndex_int*delta
		break
	case 0:
		//widthIndex is even
		//centerIndex is a half-integer (int.+1/2)
		Variable centerIndex_hint=round(centerIndex_frac-0.5)
		startIndex=centerIndex_hint-round(widthIndex/2-1)
		endIndex=centerIndex_hint+round(widthIndex/2)
		
		If(startIndex<0)
			deltaIndex=-startIndex
			startIndex+=deltaIndex
			endIndex+=deltaIndex
			centerIndex_hint+=deltaIndex
		Endif
		If(endIndex>=size)
			deltaIndex=endIndex-size+1
			startIndex-=deltaIndex
			endIndex-=deltaIndex
			centerIndex_hint-=deltaIndex
		Endif
		center=offset+(centerIndex_hint+0.5)*delta
		break
	Endswitch
	Variable/G $startIndexArg=startIndex
	Variable/G $endIndexArg=endIndex
End

//Function DeltaChange: change +-1*delta
Function/S IAFf_DeltaChange_Definition()
	return "3;0;0;1;Wave1D;Variable;Variable"
End

Function IAFf_DeltaChange(argumentList)
	String argumentList
	
	//0th argument: wave info
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: delta
	String deltaArg=StringFromList(1,argumentList)
	
	//2nd argument: value
	String valueArg=StringFromList(2,argumentList)
	
	Wave/D input=$waveArg
	NVAR delta=$deltaArg
	NVAR value=$valueArg
	
	If(!NVAR_exists(value))
		return 0
	Endif
	
	If(delta==1 || delta==-1)
		value+=delta*input[1]
	Endif
	delta=0
End

//Panel 2DViewer: 2D image & EDC & MDC
Function/S IAFp_2DViewer_Definition()
	return "18;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;Wave2D;Wave1D;Wave1D;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;String;Wave2D;Wave2D;Variable;Variable;Variable;Variable"
End

Function IAFp_2DViewer(argumentList,PanelName,PanelTitle)
	String argumentList, PanelName, PanelTitle
	
	//0th argument (input): 2D wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): 1D wave (EDC)
	String edcArg=StringFromList(1,argumentList)
	
	//2nd argument (input): 1D wave (MDC)
	String mdcArg=StringFromList(2,argumentList)
	
	//3rd argument (input): EDC start index
	String edcStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument (input): EDC end index
	String edcEndIndexArg=StringFromList(4,argumentList)
	
	//5th argument (input): MDC start index
	String mdcStartIndexArg=StringFromList(5,argumentList)
	
	//6th argument (input): MDC end index
	String mdcEndIndexArg=StringFromList(6,argumentList)
	
	//7th argument (input): EDC center
	String edcCenterArg=StringFromList(7,argumentList)
	
	//8th argument (input): EDC width
	String edcWidthArg=StringFromList(8,argumentList)

	//9th argument (input): MDC center
	String mdcCenterArg=StringFromList(9,argumentList)
	
	//10th argument (input): MDC width
	String mdcWidthArg=StringFromList(10,argumentList)
	
	//11th argument (input): x axis label
	String xLabelArg=StringFromList(11,argumentList)
	
	//12th argument (input): EDC cut
	String edcCutArg=StringFromList(12,argumentList)
	
	//13th argument (input): MDC cut
	String mdcCutArg=StringFromList(13,argumentList)
	
	//14th argument (input): EDC center delta
	//15th argument (input): MDC center delta
	//16th argument (input): EDC width delta
	//17th argument (input): MDC width delta
	
	Wave/D input=$waveArg
	Wave/D edc=$edcArg
	Wave/D mdc=$mdcArg
	NVAR edcStartIndex=$edcStartIndexArg
	NVAR edcEndIndex=$edcEndIndexArg
	NVAR mdcStartIndex=$mdcStartIndexArg
	NVAR mdcEndIndex=$mdcEndIndexArg
	NVAR edcCenter=$edcCenterArg
	NVAR edcWidth=$edcWidthArg
	NVAR mdcCenter=$mdcCenterArg
	NVAR mdcWidth=$mdcWidthArg
	SVAR xLabel=$xLabelArg
	Wave/D edcCut=$edcCutArg
	Wave/D mdcCut=$mdcCutArg
	
	
	//empty graph
	NewPanel/K=1/W=(0,0,700,500) as PanelTitle
	
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
		
	//Control bar (not actual ControlBar created by the command "ControlBar")
	Variable ControlsHeight=18
	Variable ControlBarHeight=ControlsHeight*3
	IAFu_DrawSetVariable(30,0,"EDC Start",4,edcStartIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(200,0,"End",4,edcEndIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(300,0,"Center",5,edcCenterArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(450,0,"Width",5,edcWidthArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(30,ControlsHeight,"MDC Start",4,mdcStartIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(200,ControlsHeight,"End",4,mdcEndIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(300,ControlsHeight,"Center",5,mdcCenterArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(450,ControlsHeight,"Width",5,mdcWidthArg,1,1,-inf,inf,0)
	
	String command
	String format
	
	//Wide & Narrow button
	Variable fs=IAFc_FontSize()
	String fn=IAFc_FontName()
	
	Variable width=IAFc_CalcChartWidth(1)
	Variable height=IAFc_CalcChartHeight(1)
	
	sprintf format "Button %%s pos={%%g,%%g},font=\"%s\",fsize=%g,title=\"%%s\",proc=%s,size={%g,%g}",fn,fs,"IAFu_2DViewer_Button",width,height
	
	sprintf command format,"EDCWide",610,0,"+"
	Execute command
	
	sprintf command format,"EDCNarrow",580,0,"-"
	Execute command
		
	sprintf command format,"MDCWide",610,ControlsHeight,"+"
	Execute command
	
	sprintf command format,"MDCNarrow",580,ControlsHeight,"-"
	Execute command

	Variable sliderInitial=0.6
	
	Slider vertSlider pos={0,0},size={ControlsHeight*1.5,ControlsHeight*1.5},limits={0,1,0},ticks=0,vert=1,side=1,value=sliderInitial,proc=IAFu_Guide_Slider
	Slider horizSlider pos={0,ControlsHeight*2},size={ControlsHeight*1.5,ControlsHeight*1.5},limits={0,1,0},ticks=0,vert=0,side=2,value=sliderInitial,proc=IAFu_Guide_Slider
	
	//Define Guide
	DefineGuide vertTop={FT,ControlBarHeight}
	DefineGuide horizCenter={FL,sliderInitial,FR}
	DefineGuide vertCenter={vertTop,1-sliderInitial,FB}

	
	Variable margin1=50 //outside, with axis
	Variable margin2=5 //inside
	Variable margin3=10 //outside, without axis
	Variable gfSize=18
	
	//2D plot
	Display/HOST=$parentPanelName/FG=(FL,vertCenter,horizCenter,FB)
	AppendImage input
	ModifyGraph swapXY=1,margin(left)=margin1,margin(bottom)=margin1,margin(right)=margin2,margin(top)=margin2
	ModifyGraph tick=2,axThick=0.5,zero(left)=1
	Label left "\\f02E\\f00 - \\f02E\\f00\\BF\\M (eV)"
	Label bottom xLabel
	ModifyImage $waveArg ctab={*,*,Terrain,1}
	AppendToGraph edcCut[*][1] vs edcCut[*][0]
	AppendToGraph mdcCut[*][1] vs mdcCut[*][0]
	ModifyGraph gfSize=gfSize
	
	//MDC
	Display/HOST=$ParentPanelName/FG=(FL,vertTop,horizCenter,vertCenter) mdc
	ModifyGraph margin(left)=margin1,margin(bottom)=margin2,margin(right)=margin2,margin(top)=margin3
	ModifyGraph nticks=0,axThick=0.5,noLabel(bottom)=2,mirror(left)=1
	Label left "MDC (arb. units)"
	ModifyGraph gfSize=gfSize
		
	//EDC
	Display/HOST=$ParentPanelName/FG=(horizCenter,vertCenter,FR,FB)/VERT edc
	ModifyGraph margin(left)=margin2,margin(bottom)=margin1,margin(right)=margin3,margin(top)=margin2
	ModifyGraph nticks=0,axThick=0.5,noLabel(left)=2,mirror(bottom)=1,zero(left)=1
	Label bottom "EDC (arb. units)"
	ModifyGraph gfSize=gfSize	
	
	//keyboard hook (for center change)
	SetWindow $parentPanelName hook(viewer2d_hook)=IAFu_2DViewer_Keyboard
	
End

Function IAFu_2DViewer_Keyboard(s)
	STRUCT WMWinHookStruct &s
	Variable delta=0
	If(s.eventCode==11)
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
		
		String edcDeltaArg=""
		String mdcDeltaArg=""
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
						edcDeltaArg=Diagram_i[j][17]
						mdcDeltaArg=Diagram_i[j][18]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data

		switch(s.keyCode)
		case 28:
			//left
			delta=-1
		case 29:
			//right
			If(delta==0)
				delta=1
			Endif
			NVAR edcDelta=$edcDeltaArg
			edcDelta=delta
			cd ::
			IAFc_Update(edcDeltaArg)
			break
		case 30:
			//up
			delta=1
		case 31:
			//down
			If(delta==0)
				delta=-1
			Endif
			NVAR mdcDelta=$mdcDeltaArg
			mdcDelta=delta
			cd ::
			IAFc_Update(mdcDeltaArg)
			break
		endswitch
		cd $currentFolder			
	Endif
	return 0
End

Function IAFu_Guide_slider(name,value,event): SliderControl
	String name
	Variable value
	Variable event
			
		Execute "GetWindow kwTopWin,activeSW"
		//if there is no subwindow, SWpath is the name of the window
		SVAR SWpath=S_value
		
		If(!SVAR_exists(SWpath))
			return 0
		Endif
		
		//Get Parent window name
		String windowName=StringFromList(0,SWpath,"#")
		

	strswitch(name)
		case "horizSlider":
			DefineGuide/W=$windowName horizCenter={FL,value,FR}
			break
		case "vertSlider":
			DefineGuide/W=$windowName vertCenter={vertTop,1-value,FB}
			break
		default:
			break
	endswitch
	return 0
End

Function IAFu_2DViewer_Button(BS): ButtonControl
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
		
		String edcDeltaArg=""
		String mdcDeltaArg=""
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
						edcDeltaArg=Diagram_i[j][19]
						mdcDeltaArg=Diagram_i[j][20]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data
				
		Variable delta=0
		strswitch(BS.ctrlName)
			case "EDCWide":
				delta=1
			case "EDCNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR edcDelta=$edcDeltaArg
				edcDelta=delta
				cd ::
				IAFc_Update(edcDeltaArg)
				break
			case "MDCWide":
				delta=1
			case "MDCNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR mdcDelta=$mdcDeltaArg
				mdcDelta=delta
				cd ::
				IAFc_Update(mdcDeltaArg)
				break
		Endswitch
		cd $currentFolder
	Endif
	return 1
End