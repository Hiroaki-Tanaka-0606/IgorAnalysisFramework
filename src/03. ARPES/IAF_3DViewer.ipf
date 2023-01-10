#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Template 3DViewer
//argumentList:
//[0]: name of the panel(=name of the Diagram wave)
//[1]: 3D wave to use
//[2]: xLabel
//[3]: yLabel
Function IAFt_3DViewer(argumentList)
	String argumentList
	If(ItemsInList(argumentList)<4)
		Print("Error: Template 3DViewer need four arguments")
		return 0
	ENdif
	String PanelName=stringfromlist(0,argumentList)
	String WaveName=StringFromList(1,argumentList)
	String xLabelName=StringFromList(2,argumentList)
	String yLabelName=StringFromList(3,argumentList)
	Make/O/T/N=(42,29) $PanelName
	
	//diagram wave
	Wave/T D=$PanelName
	//suffix
	String S="_"+PanelName
	
	//Ex
	D[0][0]="Data";      D[0][1]="Variable";     D[0][2]="_Ex_start"+S
	D[1][0]="Data";      D[1][1]="Variable";     D[1][2]="_Ex_end"+S
	D[2][0]="Data";      D[2][1]="Wave2D";       D[2][2]="ExCut"+S
	D[3][0]="Function";  D[3][1]="ExCut";        D[3][2]="ExC"+S; D[3][3]=WaveName; D[3][4]=D[0][2]; D[3][5]=D[1][2]; D[3][6]=D[2][2]
	//Ey	
	D[4][0]="Data";      D[4][1]="Variable";     D[4][2]="_Ey_start"+S
	D[5][0]="Data";      D[5][1]="Variable";     D[5][2]="_Ey_end"+S
	D[6][0]="Data";      D[6][1]="Wave2D";       D[6][2]="EyCut"+S
	D[7][0]="Function";  D[7][1]="EyCut";        D[7][2]="EyC"+S; D[7][3]=WaveName; D[7][4]=D[4][2]; D[7][5]=D[5][2]; D[7][6]=D[6][2]
	//xy
	D[8][0]="Data";      D[8][1]="Variable";     D[8][2]="_xy_start"+S
	D[9][0]="Data";      D[9][1]="Variable";     D[9][2]="_xy_end"+S
	D[10][0]="Data";     D[10][1]="Wave2D";      D[10][2]="xyCut"+S
	D[11][0]="Function"; D[11][1]="xyCut";       D[11][2]="xyC"+S; D[11][3]=WaveName; D[11][4]=D[8][2]; D[11][5]=D[9][2]; D[11][6]=D[10][2]
	//cut lines
	D[12][0]="Data";     D[12][1]="Wave2D";      D[12][2]="_ECut"+S;
	D[13][0]="Data";     D[13][1]="Wave2D";      D[13][2]="_xCut"+S;
	D[14][0]="Data";     D[14][1]="Wave2D";      D[14][2]="_yCut"+S;
	D[15][0]="Function"; D[15][1]="CutLines3D";  D[15][2]="_CL3"+S; D[15][3]=WaveName; D[15][4]=D[8][2]; D[15][5]=D[9][2]; D[15][6]=D[4][2]; D[15][7]=D[5][2]; D[15][8]=D[0][2]; D[15][9]=D[1][2]; D[15][10]=D[12][2]; D[15][11]=D[13][2]; D[15][12]=D[14][2]
	//Waveinfo
	D[16][0]="Data";     D[16][1]="Wave1D";      D[16][2]="_EInfo"+S
	D[17][0]="Data";     D[17][1]="Wave1D";      D[17][2]="_xInfo"+S
	D[18][0]="Data";     D[18][1]="Wave1D";      D[18][2]="_yInfo"+S
	D[19][0]="Function"; D[19][1]="WaveInfo3D";  D[19][2]="_WI3"+S; D[19][3]=WaveName; D[19][4]=D[16][2]; D[19][5]=D[17][2]; D[19][6]=D[18][2];
	//Ex value2index
	D[20][0]="Data";     D[20][1]="Variable";    D[20][2]="_ExCenter"+S	
	D[21][0]="Data";     D[21][1]="Variable";    D[21][2]="_ExWidth"+S
	D[22][0]="Function"; D[22][1]="Value2Index"; D[22][2]="_yI"+S; D[22][3]=D[18][2]; D[22][4]=D[20][2]; D[22][5]=D[21][2]; D[22][6]=D[0][2]; D[22][7]=D[1][2]
	//Ey value2index
	D[23][0]="Data";     D[23][1]="Variable";    D[23][2]="_EyCenter"+S	
	D[24][0]="Data";     D[24][1]="Variable";    D[24][2]="_EyWidth"+S
	D[25][0]="Function"; D[25][1]="Value2Index"; D[25][2]="_xI"+S; D[25][3]=D[17][2]; D[25][4]=D[23][2]; D[25][5]=D[24][2]; D[25][6]=D[4][2]; D[25][7]=D[5][2]
	//xy value2index
	D[26][0]="Data";     D[26][1]="Variable";    D[26][2]="_xyCenter"+S	
	D[27][0]="Data";     D[27][1]="Variable";    D[27][2]="_xyWidth"+S
	D[28][0]="Function"; D[28][1]="Value2Index"; D[28][2]="_EI"+S; D[28][3]=D[16][2]; D[28][4]=D[26][2]; D[28][5]=D[27][2]; D[28][6]=D[8][2]; D[28][7]=D[9][2]
	//Ex centerdelta
	D[29][0]="Data";     D[29][1]="Variable";    D[29][2]="_ExCenterDelta"+S
	D[30][0]="Function"; D[30][1]="DeltaChange"; D[30][2]="_ExCC"+S; D[30][3]=D[18][2]; D[30][4]=D[29][2]; D[30][5]=D[20][2]
	//Ex widthdelta
	D[31][0]="Data";     D[31][1]="Variable";    D[31][2]="_ExWidthDelta"+S
	D[32][0]="Function"; D[32][1]="DeltaChange"; D[32][2]="_ExWC"+S; D[32][3]=D[18][2]; D[32][4]=D[31][2]; D[32][5]=D[21][2]
	//Ey centerdelta
	D[33][0]="Data";     D[33][1]="Variable";    D[33][2]="_EyCenterDelta"+S
	D[34][0]="Function"; D[34][1]="DeltaChange"; D[34][2]="_EyCC"+S; D[34][3]=D[17][2]; D[34][4]=D[33][2]; D[34][5]=D[23][2]
	//Ey widthdelta
	D[35][0]="Data";     D[35][1]="Variable";    D[35][2]="_EyWidthDelta"+S
	D[36][0]="Function"; D[36][1]="DeltaChange"; D[36][2]="_EyWC"+S; D[36][3]=D[17][2]; D[36][4]=D[35][2]; D[36][5]=D[24][2]
	//xy centerdelta
	D[37][0]="Data";     D[37][1]="Variable";    D[37][2]="_xyCenterDelta"+S
	D[38][0]="Function"; D[38][1]="DeltaChange"; D[38][2]="_xyCC"+S; D[38][3]=D[16][2]; D[38][4]=D[37][2]; D[38][5]=D[26][2]
	//xy widthdelta
	D[39][0]="Data";     D[39][1]="Variable";    D[39][2]="_xyWidthDelta"+S
	D[40][0]="Function"; D[40][1]="DeltaChange"; D[40][2]="_xyWC"+S; D[40][3]=D[16][2]; D[40][4]=D[39][2]; D[40][5]=D[27][2]
	//Panel
	D[41][0]="Panel";    D[41][1]="3DViewer";    D[41][2]=PanelName;
	D[41][3]=D[2][2];    D[41][4]=D[6][2];       D[41][5]=D[10][2];
	D[41][6]=D[0][2];    D[41][7]=D[1][2];       D[41][8]=D[4][2];
	D[41][9]=D[5][2];    D[41][10]=D[8][2];      D[41][11]=D[9][2];
	D[41][12]=D[20][2];  D[41][13]=D[21][2];     D[41][14]=D[23][2];
	D[41][15]=D[24][2];  D[41][16]=D[26][2];     D[41][17]=D[27][2];
	D[41][18]=xLabelName;D[41][19]=yLabelName;   D[41][20]=D[12][2];
	D[41][21]=D[13][2];  D[41][22]=D[14][2];     D[41][23]=D[29][2];
	D[41][24]=D[33][2];  D[41][25]=D[37][2];     D[41][26]=D[31][2];
	D[41][27]=D[35][2];  D[41][28]=D[39][2];
	
	return 1

End
	

//Function ExCut: create Energy-x (k_x or theta_x) map wave[][][i,j]
Function/S IAFf_ExCut_Definition()
	return "4;0;0;0;1;Wave3D;Variable;Variable;Wave2D"
End

Function IAFf_ExCut(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument (input): end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument (output): ExCut wave
	String ExArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable size3=DimSize(input,2)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size3)
		Print("ExCut Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset1=DimOffset(input,0)
	Variable offset2=DimOffset(input,1)
	Variable delta1=DimDelta(input,0)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size1,size2) $ExArg
	Wave/D Ex=$ExArg
	SetScale/P x, offset1,delta1, Ex
	SetScale/P y, offset2,delta2, Ex
	Ex[][]=0

	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		Ex[][]+=input[p][q][i]
	Endfor
End

//Function EyCut: create Energy-y (k_y or theta_y) map wave[][i,j][]
Function/S IAFf_EyCut_Definition()
	return "4;0;0;0;1;Wave3D;Variable;Variable;Wave2D"
End

Function IAFf_EyCut(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument (input): end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument (output): EyCut wave
	String EyArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable size3=DimSize(input,2)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size2)
		Print("EyCut Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset1=DimOffset(input,0)
	Variable offset3=DimOffset(input,2)
	Variable delta1=DimDelta(input,0)
	Variable delta3=DimDelta(input,2)
	
	Make/O/D/N=(size1,size3) $EyArg
	Wave/D Ey=$EyArg
	SetScale/P x, offset1,delta1, Ey
	SetScale/P y, offset3,delta3, Ey
	Ey[][]=0

	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		Ey[][]+=input[p][i][q]
	Endfor
End

//Function xyCut: create x-y (k or theta) map wave[i,j][][] = Constant-energy mapping
Function/S IAFf_xyCut_Definition()
	return "4;0;0;0;1;Wave3D;Variable;Variable;Wave2D"
End

Function IAFf_xyCut(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument (input): end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument (output): xyCut wave
	String xyArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable size3=DimSize(input,2)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size1)
		Print("xyCut Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset2=DimOffset(input,1)
	Variable offset3=DimOffset(input,2)
	Variable delta2=DimDelta(input,1)
	Variable delta3=DimDelta(input,2)
	
	Make/O/D/N=(size2,size3) $xyArg
	Wave/D xy=$xyArg
	SetScale/P x, offset2,delta2, xy
	SetScale/P y, offset3,delta3, xy
	xy[][]=0

	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		xy[][]+=input[i][p][q]
	Endfor
End

//Function CutLines3D: create Energy and momentum-x and momentum-y cut lines
Function/S IAFf_CutLines3D_Definition()
	return "10;0;0;0;0;0;0;0;1;1;1;Wave3D;Variable;Variable;Variable;Variable;Variable;Variable;Wave2D;Wave2D;Wave2D"
End

Function IAFf_CutLines3D(argumentList)
	String argumentList
	
	//0th argument (input): 3D wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument (input): E start index (energy axis)
	String EStartIndexArg=StringFromList(1,argumentList)
	
	//2nd argument (input): E end index (energy axis)
	String EEndIndexArg=StringFromList(2,argumentList)
	
	//3rd argument (input): x start index (momentum-x axis)
	String xStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument (input): x end index (momentum-x axis)
	String xEndIndexArg=StringFromList(4,argumentList)
	
	//5th argument (input): y start index (momentum-y axis)
	String yStartIndexArg=StringFromList(5,argumentList)
	
	//6th argument (input): y end index (momentum-y axis)
	String yEndIndexArg=StringFromList(6,argumentList)
	
	//7th argument (output): E cut (appear on Ex and Ey map)
	String EWaveArg=StringFromList(7,argumentList)
	
	//8th argument (output): x cut (appear on Ex and xy map)
	String xWaveArg=StringFromList(8,argumentList)
	
	//9th argument (output): y cut (appear on Ey and xy map)
	String yWaveArg=StringFromList(9,argumentList)
	
	Wave/D input=$waveArg
	NVAR EStartIndex=$EStartIndexArg
	NVAR EEndIndex=$EEndIndexArg
	NVAR xStartIndex=$xStartIndexArg
	NVAR xEndIndex=$xEndIndexArg
	NVAR yStartIndex=$yStartIndexArg
	NVAR yEndIndex=$yEndIndexArg
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Variable offset3=Dimoffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	Variable EStartValue=offset1+delta1*(EStartIndex-0.5)
	Variable EEndValue=offset1+delta1*(EEndIndex+0.5)
	
	Variable xStartValue=offset2+delta2*(xStartIndex-0.5)
	Variable xEndValue=offset2+delta2*(xEndIndex+0.5)
	
	Variable yStartValue=offset3+delta3*(yStartIndex-0.5)
	Variable yEndValue=offset3+delta3*(yEndIndex+0.5)
	
	Make/O/D/N=(4,2) $EWaveArg
	Wave/D ECut=$EWaveArg
	ECut[0][0]=EStartValue
	ECut[0][1]=-inf
	ECut[1][0]=EStartValue
	ECut[1][1]=inf
	ECut[2][0]=EEndValue
	ECut[2][1]=inf
	ECut[3][0]=EEndValue
	ECut[3][1]=-inf
	
	Make/O/D/N=(4,2) $xWaveArg
	Wave/D xCut=$xWaveArg
	xCut[0][0]=xStartValue
	xCut[0][1]=-inf
	xCut[1][0]=xStartValue
	xCut[1][1]=inf
	xCut[2][0]=xEndValue
	xCut[2][1]=inf
	xCut[3][0]=xEndValue
	xCut[3][1]=-inf
	
	Make/O/D/N=(4,2) $yWaveArg
	Wave/D yCut=$yWaveArg
	yCut[0][0]=yStartValue
	yCut[0][1]=-inf
	yCut[1][0]=yStartValue
	yCut[1][1]=inf
	yCut[2][0]=yEndValue
	yCut[2][1]=inf
	yCut[3][0]=yEndValue
	yCut[3][1]=-inf
End

//Panel 3DViewer: xyCut (right-top) & ExCut (right-bottom) & EyCut(left-top)
Function/S IAFp_3DViewer_Definition()
	return "26;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;Wave2D;Wave2D;Wave2D;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;String;String;Wave2D;Wave2D;Wave2D;Variable;Variable;Variable;Variable;Variable;Variable"
End

Function IAFp_3DViewer(argumentList,PanelName,PanelTitle)
	String argumentList,PanelName,PanelTitle
	
	//0th argument (input): ExCut
	String ExArg=StringFromList(0,argumentList)
	
	//1st argument (input): EyCut
	String EyArg=StringFromList(1,argumentList)
	
	//2nd argument (input): xyCut
	String xyArg=StringFromList(2,argumentList)
	
	//3rd argument (input): Ex Start Index
	String ExStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument (input): Ex End Index
	String ExEndIndexArg=StringFromList(4,argumentList)
	
	//5th argument (input): Ey Start Index
	String EyStartIndexArg=StringFromList(5,argumentList)
	
	//6th argument (input): Ey End Index
	String EyEndIndexArg=StringFromList(6,argumentList)
	
	//7th argument (input): xy Start Index
	String xyStartIndexArg=StringFromList(7,argumentList)
	
	//8th argument (input): xy End Index
	String xyEndIndexArg=StringFromList(8,argumentList)
	
	//9th argument (input): Ex center
	String ExCenterArg=StringFromList(9,argumentList)
	
	//10th argument (input): Ex width
	String ExWidthArg=StringFromList(10,argumentList)
	
	//11th argument (input): Ey center
	String EyCenterArg=StringFromList(11,argumentList)
	
	//12th argument (input): Ey width
	String EyWidthArg=StringFromList(12,argumentList)
	
	//13th argument (input): xy center
	String xyCenterArg=StringFromList(13,argumentList)
	
	//14th argument (input): xy width
	String xyWidthArg=StringFromList(14,argumentList)
	
	//15th argument (input): x label
	String xLabelArg=StringFromList(15,argumentList)
	
	//16th argument (input): y label
	String yLabelArg=StringFromList(16,argumentList)
	
	//17th argument (input): E cut
	String ECutArg=StringFromList(17,argumentList)
	
	//18th argument (input): x cut
	String xCutArg=StringFromList(18,argumentList)
	
	//19th argument (input): y cut
	String yCutArg=StringFromList(19,argumentList)
	
	//20th argument (input): Ex center delta
	//21st argument (input): Ey center delta
	//22nd argument (input): xy center delta
	
	//23rd argument (input): Ex width delta
	//24th argument (input): Ey width delta
	//25th argument (input): xy width delta
	
	Wave/D Ex=$ExArg
	Wave/D Ey=$EyArg
	Wave/D xy=$xyArg
	NVAR ExStartIndex=$ExStartIndexArg
	NVAR ExEndIndex=$ExEndIndexArg
	NVAR EyStartIndex=$EyStartIndexArg
	NVAR EyEndIndex=$EyEndIndexArg
	NVAR xyStartIndex=$xyStartIndexArg
	NVAR xyEndIndex=$xyEndIndexArg
	SVAR xLabel=$xLabelArg
	SVAR yLabel=$yLabelArg
	Wave/D ECut=$ECutArg
	Wave/D xCut=$xCutArg
	Wave/D yCut=$yCutArg
	
	//empty graph
	NewPanel/K=1/W=(0,0,700,500) as PanelTitle
	
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
		
	//Control bar (not actual ControlBar created by the command "ControlBar")
	Variable ControlsHeight=18
	Variable ControlBarHeight=ControlsHeight*4	
	
	IAFu_DrawSetVariable(30,0,"Ex Start",4,ExStartIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(200,0,"End",4,ExEndIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(300,0,"Center",5,ExCenterArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(450,0,"Width",5,ExWidthArg,1,1,-inf,inf,0)

	IAFu_DrawSetVariable(30,ControlsHeight,"Ey Start",4,EyStartIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(200,ControlsHeight,"End",4,EyEndIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(300,ControlsHeight,"Center",5,EyCenterArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(450,ControlsHeight,"Width",5,EyWidthArg,1,1,-inf,inf,0)
	
	IAFu_DrawSetVariable(30,ControlsHeight*2,"xy Start",4,xyStartIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(200,ControlsHeight*2,"End",4,xyEndIndexArg,0,1,-inf,inf,1)
	IAFu_DrawSetVariable(300,ControlsHeight*2,"Center",5,xyCenterArg,1,1,-inf,inf,0)
	IAFu_DrawSetVariable(450,ControlsHeight*2,"Width",5,xyWidthArg,1,1,-inf,inf,0)
	
	//Wide & Narrow button
	Variable fs=IAFc_FontSize()
	String fn=IAFc_FontName()
	
	Variable width=IAFc_CalcChartWidth(1)
	Variable height=IAFc_CalcChartHeight(1)
	String command
	String format
	
	sprintf format "Button %%s pos={%%g,%%g},font=\"%s\",fsize=%g,title=\"%%s\",proc=%s,size={%g,%g}",fn,fs,"IAFu_3DViewer_Button",width,height
	
	sprintf command format,"ExWide",610,0,"+"
	Execute command
	
	sprintf command format,"ExNarrow",580,0,"-"
	Execute command
		
	sprintf command format,"EyWide",610,ControlsHeight,"+"
	Execute command
	
	sprintf command format,"EyNarrow",580,ControlsHeight,"-"
	Execute command
	
	sprintf command format,"xyWide",610,ControlsHeight*2,"+"
	Execute command
	
	sprintf command format,"xyNarrow",580,ControlsHeight*2,"-"
	Execute command
	
	Variable sliderInitial=0.4
	
	Slider vertSlider pos={0,ControlsHeight},size={ControlsHeight*1.5,ControlsHeight*1.5},limits={0,1,0},ticks=0,vert=1,side=1,value=sliderInitial,proc=IAFu_Guide_Slider
	Slider horizSlider pos={0,ControlsHeight*3},size={ControlsHeight*1.5,ControlsHeight*1.5},limits={0,1,0},ticks=0,vert=0,side=2,value=sliderInitial,proc=IAFu_Guide_Slider
	
	//Define Guide
	DefineGuide vertTop={FT,ControlBarHeight}
	DefineGuide horizCenter={FL,sliderInitial,FR}
	DefineGuide vertCenter={FT,1-sliderInitial,FB}
	
	Variable margin1=60 //outside, with axis
	Variable margin2=50 //inside, with axis
	Variable margin3=10 //outside, without axis
	Variable margin4=5  //inside, without axis
	Variable gfSize=18 //font size

	//Ex
	Display/HOST=$parentPanelName/FG=(horizCenter,vertCenter,FR,FB)/N=Ex
	AppendImage Ex
	ModifyGraph swapXY=1,margin(left)=margin2,margin(bottom)=margin1,margin(right)=margin3,margin(top)=margin4
	ModifyGraph tick=2,axThick=0.5,zero=1
	Label left "\\f02E\\f00 - \\f02E\\f00\\BF\\M (eV)"
	Label bottom xLabel
	ModifyImage $exArg ctab={*,*,Terrain,1}
	ModifyGraph gfSize=gfSize
	//cut: be careful that swapXY=1
	AppendToGraph ECut[*][1] vs ECut[*][0]
	AppendToGraph xCut[*][0] vs xCut[*][1]
	
	//Ey
	Display/HOST=$parentPanelName/FG=(FL,vertTop,horizCenter,vertCenter)/N=Ey
	AppendImage Ey
	ModifyGraph margin(left)=margin1,margin(bottom)=margin2,margin(right)=margin4,margin(top)=margin3
	ModifyGraph tick=2,axThick=0.5,zero=1
	Label bottom "\\f02E\\f00 - \\f02E\\f00\\BF\\M (eV)"
	Label left yLabel
	ModifyImage $eyArg ctab={*,*,Terrain,1}
	ModifyGraph gfSize=gfSize
	AppendToGraph ECut[*][1] vs ECut[*][0]
	AppendToGraph yCut[*][0] vs yCut[*][1]
	
	//xy
	Display/HOST=$parentPanelName/FG=(horizCenter,vertTop,FR,vertCenter)/N=xy
	AppendImage xy
	ModifyGraph margin(left)=margin2,margin(bottom)=margin2,margin(right)=margin3,margin(top)=margin3
	ModifyGraph tick=2,axThick=0.5,zero=1
	ModifyImage $xyArg ctab={*,*,Terrain,1}
	ModifyGraph gfSize=gfSize, noLabel=2

	AppendToGraph xCut[*][1] vs xCut[*][0]
	AppendToGraph yCut[*][0] vs yCut[*][1]
	
	//keyboard hook (for center change)
	SetWindow $parentPanelName hook(viewer3d_hook)=IAFu_3DViewer_Keyboard
End



Function IAFu_3DViewer_Button(BS): ButtonControl
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
		
		String ExDeltaArg=""
		String EyDeltaArg=""
		String xyDeltaArg=""
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
						ExDeltaArg=Diagram_i[j][26]
						EyDeltaArg=Diagram_i[j][27]
						xyDeltaArg=Diagram_i[j][28]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data
				
		Variable delta=0
		strswitch(BS.ctrlName)
			case "ExWide":
				delta=1
			case "ExNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR ExDelta=$ExDeltaArg
				ExDelta=delta
				cd ::
				IAFc_Update(ExDeltaArg)
				break
			case "EyWide":
				delta=1
			case "EyNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR EyDelta=$EyDeltaArg
				EyDelta=delta
				cd ::
				IAFc_Update(EyDeltaArg)
				break
			case "xyWide":
				delta=1
			case "xyNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR xyDelta=$xyDeltaArg
				xyDelta=delta
				cd ::
				IAFc_Update(xyDeltaArg)
				break
		Endswitch
		cd $currentFolder
	Endif
	return 1
End

Function IAFu_3DViewer_Keyboard(s)
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
		String graphName=StringFromList(1,SWpath,"#")
		
		If(cmpstr(graphName,"Ex")!=0 && cmpstr(graphName,"Ey")!=0 && cmpstr(graphName,"xy")!=0)
			return 0
		ENdif
		//Print(graphName)
		
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
		
		String ExDeltaArg=""
		String EyDeltaArg=""
		String xyDeltaArg=""
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
						ExDeltaArg=Diagram_i[j][23]
						EyDeltaArg=Diagram_i[j][24]
						xyDeltaArg=Diagram_i[j][25]
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
			If(cmpstr(graphName,"Ey")==0)
				//Ey -> xyDelta
				NVAR xyDelta=$xyDeltaArg
				xyDelta=delta
				cd ::
				IAFc_Update(xyDeltaArg)
			Else
				//Ex or xy -> EyDelta
				NVAR EyDelta=$EyDeltaArg
				EyDelta=delta
				cd ::
				IAFc_Update(EyDeltaArg)
			Endif
			break
		case 30:
			//up
			delta=1
		case 31:
			//down
			If(delta==0)
				delta=-1
			Endif
			If(cmpstr(graphname,"Ex")==0)
				//Ex ->xyDelta
				NVAR xyDelta=$xyDeltaArg
				xyDelta=delta
				cd ::
				IAFc_Update(xyDeltaArg)
			Else
				//Ey or Ey -> ExDelta
				NVAR ExDelta=$ExDeltaArg
				ExDelta=delta
				cd ::
				IAFc_Update(ExDeltaArg)
			ENdif
			break
		endswitch
		cd $currentFolder			
	Endif
	return 0
End