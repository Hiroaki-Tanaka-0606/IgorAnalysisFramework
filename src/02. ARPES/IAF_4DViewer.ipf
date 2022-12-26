#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Template 4DViewer
//argumentList:
//[0]: name of the panel(=name of the Diagram wave)
//[1]: 4D wave to use
//[2]: angleLabel
//[3]: xLabel
//[4]: yLabel
Function IAFt_4DViewer(argumentList)
	String argumentList
	If(ItemsInList(argumentList)<5)
		Print("Error: Template 4DViewer need five arguments")
		return 0
	ENdif
	String PanelName=stringfromlist(0,argumentList)
	String WaveName=StringFromList(1,argumentList)
	String angleLabelName=StringFromList(2,argumentList)
	String xLabelName=StringFromList(3,argumentList)
	String yLabelName=StringFromList(4,argumentList)
	Make/O/T/N=(49,34) $PanelName
	
	//diagram wave
	Wave/T D=$PanelName
	//suffix
	String S="_"+PanelName
	
	//EAxy start and end
	D[0][0]="Data";      D[0][1]="Variable";     D[0][2]="_E_start"+S
	D[1][0]="Data";      D[1][1]="Variable";     D[1][2]="_E_end"+S
	D[2][0]="Data";      D[2][1]="Variable";     D[2][2]="_A_start"+S
	D[3][0]="Data";      D[3][1]="Variable";     D[3][2]="_A_end"+S
	D[4][0]="Data";      D[4][1]="Variable";     D[4][2]="_x_start"+S
	D[5][0]="Data";      D[5][1]="Variable";     D[5][2]="_x_end"+S
	D[6][0]="Data";      D[6][1]="Variable";     D[6][2]="_y_start"+S
	D[7][0]="Data";      D[7][1]="Variable";     D[7][2]="_y_end"+S
	
	//EAMap
	D[8][0]="Data";      D[8][1]="Wave2D";       D[8][2]="Map_EA"+S
	D[9][0]="Function";  D[9][1]="EAMap";        D[9][2]="EAM"+S;
	D[9][3]=WaveName; D[9][4]=D[4][2]; D[9][5]=D[5][2]; D[9][6]=D[6][2]; D[9][7]=D[7][2]; D[9][8]=D[8][2]
	
	//xyMap
	D[10][0]="Data";     D[10][1]="Wave2D";      D[10][2]="Map_xy"+S
	D[11][0]="Function"; D[11][1]="xyMap";       D[11][2]="xyM"+S;
	D[11][3]=WaveName; D[11][4]=D[0][2]; D[11][5]=D[1][2]; D[11][6]=D[2][2]; D[11][7]=D[3][2]; D[11][8]=D[10][2]

	//cut rects
	D[12][0]="Data";     D[12][1]="Wave2D";      D[12][2]="_EARect"+S;
	D[13][0]="Data";     D[13][1]="Wave2D";      D[13][2]="_xyRect"+S;
	D[14][0]="Function"; D[14][1]="CutRects";    D[14][2]="_CR"+S;
	D[14][3]=WaveName; D[14][4]=D[0][2]; D[14][5]=D[1][2]; D[14][6]=D[2][2]; D[14][7]=D[3][2]; D[14][8]=D[4][2];
	D[14][9]=D[5][2]; D[14][10]=D[6][2]; D[14][11]=D[7][2]; D[14][12]=D[12][2]; D[14][13]=D[13][2]
	
	//Waveinfo
	D[15][0]="Data";     D[15][1]="Wave1D";      D[15][2]="_EInfo"+S
	D[16][0]="Data";     D[16][1]="Wave1D";      D[16][2]="_AInfo"+S
	D[17][0]="Data";     D[17][1]="Wave1D";      D[17][2]="_xInfo"+S
	D[18][0]="Data";     D[18][1]="Wave1D";      D[18][2]="_yInfo"+S
	D[19][0]="Function"; D[19][1]="WaveInfo4D";  D[19][2]="_WI4"+S; 
	D[19][3]=WaveName; D[19][4]=D[15][2]; D[19][5]=D[16][2]; D[19][6]=D[17][2]; D[19][7]=D[18][2];
	
	//E value2index
	D[20][0]="Data";     D[20][1]="Variable";    D[20][2]="_ECenter"+S	
	D[21][0]="Data";     D[21][1]="Variable";    D[21][2]="_EWidth"+S
	D[22][0]="Function"; D[22][1]="Value2Index"; D[22][2]="_EI"+S;
	D[22][3]=D[15][2]; D[22][4]=D[20][2]; D[22][5]=D[21][2]; D[22][6]=D[0][2]; D[22][7]=D[1][2]
	
	//A value2index
	D[23][0]="Data";     D[23][1]="Variable";    D[23][2]="_ACenter"+S	
	D[24][0]="Data";     D[24][1]="Variable";    D[24][2]="_AWidth"+S
	D[25][0]="Function"; D[25][1]="Value2Index"; D[25][2]="_AI"+S;
	D[25][3]=D[16][2]; D[25][4]=D[23][2]; D[25][5]=D[24][2]; D[25][6]=D[2][2]; D[25][7]=D[3][2]
	
	//x value2index
	D[26][0]="Data";     D[26][1]="Variable";    D[26][2]="_xCenter"+S	
	D[27][0]="Data";     D[27][1]="Variable";    D[27][2]="_xWidth"+S
	D[28][0]="Function"; D[28][1]="Value2Index"; D[28][2]="_xI"+S;
	D[28][3]=D[17][2]; D[28][4]=D[26][2]; D[28][5]=D[27][2]; D[28][6]=D[4][2]; D[28][7]=D[5][2]
	
	//x value2index
	D[29][0]="Data";     D[29][1]="Variable";    D[29][2]="_yCenter"+S	
	D[30][0]="Data";     D[30][1]="Variable";    D[30][2]="_yWidth"+S
	D[31][0]="Function"; D[31][1]="Value2Index"; D[31][2]="_yI"+S;
	D[31][3]=D[18][2]; D[31][4]=D[29][2]; D[31][5]=D[30][2]; D[31][6]=D[6][2]; D[31][7]=D[7][2]

	//E centerdelta
	D[32][0]="Data";     D[32][1]="Variable";    D[32][2]="_ECenterDelta"+S
	D[33][0]="Function"; D[33][1]="DeltaChange"; D[33][2]="_ECC"+S; D[33][3]=D[15][2]; D[33][4]=D[32][2]; D[33][5]=D[20][2]
	//E widthdelta
	D[34][0]="Data";     D[34][1]="Variable";    D[34][2]="_EWidthDelta"+S
	D[35][0]="Function"; D[35][1]="DeltaChange"; D[35][2]="_EWC"+S; D[35][3]=D[15][2]; D[35][4]=D[34][2]; D[35][5]=D[21][2]

	//A centerdelta
	D[36][0]="Data";     D[36][1]="Variable";    D[36][2]="_ACenterDelta"+S
	D[37][0]="Function"; D[37][1]="DeltaChange"; D[37][2]="_ACC"+S; D[37][3]=D[16][2]; D[37][4]=D[36][2]; D[37][5]=D[23][2]
	//A widthdelta
	D[38][0]="Data";     D[38][1]="Variable";    D[38][2]="_AWidthDelta"+S
	D[39][0]="Function"; D[39][1]="DeltaChange"; D[39][2]="_AWC"+S; D[39][3]=D[16][2]; D[39][4]=D[38][2]; D[39][5]=D[24][2]
		
	//x centerdelta
	D[40][0]="Data";     D[40][1]="Variable";    D[40][2]="_xCenterDelta"+S
	D[41][0]="Function"; D[41][1]="DeltaChange"; D[41][2]="_xCC"+S; D[41][3]=D[17][2]; D[41][4]=D[40][2]; D[41][5]=D[26][2]
	//x widthdelta
	D[42][0]="Data";     D[42][1]="Variable";    D[42][2]="_xWidthDelta"+S
	D[43][0]="Function"; D[43][1]="DeltaChange"; D[43][2]="_xWC"+S; D[43][3]=D[17][2]; D[43][4]=D[42][2]; D[43][5]=D[27][2]

	//y centerdelta
	D[44][0]="Data";     D[44][1]="Variable";    D[44][2]="_yCenterDelta"+S
	D[45][0]="Function"; D[45][1]="DeltaChange"; D[45][2]="_yCC"+S; D[45][3]=D[18][2]; D[45][4]=D[44][2]; D[45][5]=D[29][2]
	//y widthdelta
	D[46][0]="Data";     D[46][1]="Variable";    D[46][2]="_yWidthDelta"+S
	D[47][0]="Function"; D[47][1]="DeltaChange"; D[47][2]="_yWC"+S; D[47][3]=D[18][2]; D[47][4]=D[46][2]; D[47][5]=D[30][2]
		
	//Panel
	D[48][0]="Panel";    D[48][1]="4DViewer";    D[48][2]=PanelName;
	D[48][3]=D[8][2];    D[48][4]=D[10][2];      D[48][5]=D[0][2];
	D[48][6]=D[1][2];    D[48][7]=D[2][2];       D[48][8]=D[3][2];
	D[48][9]=D[4][2];    D[48][10]=D[5][2];      D[48][11]=D[6][2];
	D[48][12]=D[7][2];   D[48][13]=D[20][2];     D[48][14]=D[21][2];
	D[48][15]=D[23][2];  D[48][16]=D[24][2];     D[48][17]=D[26][2];
	D[48][18]=D[27][2];  D[48][19]=D[29][2];     D[48][20]=D[30][2];
	D[48][21]=angleLabelName;   D[48][22]=xLabelName;     D[48][23]=yLabelName;
	D[48][24]=D[12][2];  D[48][25]=D[13][2];     D[48][26]=D[32][2];
	D[48][27]=D[34][2];  D[48][28]=D[36][2];     D[48][29]=D[38][2];
	D[48][30]=D[40][2];  D[48][31]=D[42][2];     D[48][32]=D[44][2];
	D[48][33]=D[46][2];
	return 1

End
	

//Function EAMap: create Energy-angle map wave[][][i,j][k,l]
Function/S IAFf_EAMap_Definition()
	return "6;0;0;0;0;0;1;Wave4D;Variable;Variable;Variable;Variable;Wave2D"
End

Function IAFf_EAMap(argumentList)
	String argumentList
	
	//0th argument: wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: x start index (include)
	String xStartArg=StringFromList(1,argumentList)
	
	//2nd argument: x end index (include)
	String xEndArg=StringFromList(2,argumentList)
	
	//3rd argument: y start index (include)
	String yStartArg=StringFromList(3,argumentList)
	
	//4th argument: y end index (iniclude)
	String yEndArg=StringFromList(4,argumentList)
	
	//5rd argument: EAMap wave
	String EAArg=StringFromList(5,argumentList)
	
	Wave/D input=$waveArg
	NVAR xStartIndex=$xStartArg
	NVAR xEndIndex=$xEndArg
	NVAR yStartIndex=$yStartArg
	NVAR yEndIndex=$yEndArg
	
	
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable size3=DimSize(input,2)
	Variable size4=DimSize(input,3)
	If(xStartIndex>xEndIndex || xStartIndex<0 || xEndIndex>=size3)
		Print("EAMap Error: x index ["+num2str(xStartIndex)+","+num2str(xEndIndex)+"] is out of range")
		return 0
	Endif
	If(yStartIndex>yEndIndex || yStartIndex<0 || yEndIndex>=size4)
		Print("EAMap Error: y index ["+num2str(yStartIndex)+","+num2str(yEndIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset1=DimOffset(input,0)
	Variable offset2=DimOffset(input,1)
	Variable delta1=DimDelta(input,0)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size1,size2) $EAArg
	Wave/D EA=$EAArg
	SetScale/P x, offset1,delta1, EA
	SetScale/P y, offset2,delta2, EA
	EA[][]=0

	Variable i,j
	For(i=xStartIndex;i<=xEndIndex;i+=1)
		For(j=yStartIndex;j<=yEndIndex;j+=1)
			EA[][]+=input[p][q][i][j]
		Endfor
	Endfor
End


//Function xyMap: create Energy-angle map wave[i,j][k,l][][]
Function/S IAFf_xyMap_Definition()
	return "6;0;0;0;0;0;1;Wave4D;Variable;Variable;Variable;Variable;Wave2D"
End

Function IAFf_xyMap(argumentList)
	String argumentList
	
	//0th argument: wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: E start index (include)
	String EStartArg=StringFromList(1,argumentList)
	
	//2nd argument: E end index (include)
	String EEndArg=StringFromList(2,argumentList)
	
	//3rd argument: A start index (include)
	String AStartArg=StringFromList(3,argumentList)
	
	//4th argument: A end index (iniclude)
	String AEndArg=StringFromList(4,argumentList)
	
	//5rd argument: xyMap wave
	String xyArg=StringFromList(5,argumentList)
	
	Wave/D input=$waveArg
	NVAR EStartIndex=$EStartArg
	NVAR EEndIndex=$EEndArg
	NVAR AStartIndex=$AStartArg
	NVAR AEndIndex=$AEndArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable size3=DimSize(input,2)
	Variable size4=DimSize(input,3)
	If(EStartIndex>EEndIndex || EStartIndex<0 || EEndIndex>=size1)
		Print("EAMap Error: Energy index ["+num2str(EStartIndex)+","+num2str(EEndIndex)+"] is out of range")
		return 0
	Endif
	If(AStartIndex>AEndIndex || AStartIndex<0 || AEndIndex>=size2)
		Print("EAMap Error: Angle index ["+num2str(AStartIndex)+","+num2str(AEndIndex)+"] is out of range")
		return 0
	Endif
	
	Variable offset3=DimOffset(input,2)
	Variable offset4=DimOffset(input,3)
	Variable delta3=DimDelta(input,2)
	Variable delta4=DimDelta(input,3)
	
	Make/O/D/N=(size3,size4) $xyArg
	Wave/D xy=$xyArg
	SetScale/P x, offset3,delta3, xy
	SetScale/P y, offset4,delta4, xy
	xy[][]=0

	Variable i,j
	For(i=EStartIndex;i<=EEndIndex;i+=1)
		For(j=AStartIndex;j<=AEndIndex;j+=1)
			xy[][]+=input[i][j][p][q]
		Endfor
	Endfor
End


//Function CutRects: create Energy-Angle and x-y cut rectangulars
Function/S IAFf_CutRects_Definition()
	return "11;0;0;0;0;0;0;0;0;0;1;1;Wave4D;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Wave2D;Wave2D"
End

Function IAFf_CutRects(argumentList)
	String argumentList
	
	//0th argument: 4D wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: E start index (energy axis)
	String EStartIndexArg=StringFromList(1,argumentList)
	
	//2nd argument: E end index (energy axis)
	String EEndIndexArg=StringFromList(2,argumentList)
	
	//3rd argument: A start index (Angle axis)
	String AStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument: A end index (Angle axis)
	String AEndIndexArg=StringFromList(4,argumentList)
	
	//5td argument: x start index (x axis)
	String xStartIndexArg=StringFromList(5,argumentList)
	
	//6th argument: x end index (x axis)
	String xEndIndexArg=StringFromList(6,argumentList)
	
	//7th argument: y start index (y axis)
	String yStartIndexArg=StringFromList(7,argumentList)
	
	//8th argument: y end index (y axis)
	String yEndIndexArg=StringFromList(8,argumentList)
	
	//9th argument: EA cut (appear on EA map)
	String EAWaveArg=StringFromList(9,argumentList)
	
	//10th argument: xy cut (appear on xy map)
	String xyWaveArg=StringFromList(10,argumentList)
	
	Wave/D input=$waveArg
	NVAR EStartIndex=$EStartIndexArg
	NVAR EEndIndex=$EEndIndexArg
	NVAR AStartIndex=$AStartIndexArg
	NVAR AEndIndex=$AEndIndexArg
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
	
	Variable offset4=DimOffset(input,3)
	Variable delta4=DimDelta(input,3)
	
	Variable EStartValue=offset1+delta1*(EStartIndex-0.5)
	Variable EEndValue=offset1+delta1*(EEndIndex+0.5)
	
	Variable AStartValue=offset2+delta2*(AStartIndex-0.5)
	Variable AEndValue=offset2+delta2*(AEndIndex+0.5)
	
	Variable xStartValue=offset3+delta3*(xStartIndex-0.5)
	Variable xEndValue=offset3+delta3*(xEndIndex+0.5)
	
	Variable yStartValue=offset4+delta4*(yStartIndex-0.5)
	Variable yEndValue=offset4+delta4*(yEndIndex+0.5)
	
	Make/O/D/N=(5,2) $EAWaveArg
	Wave/D EARect=$EAWaveArg
	EARect[0][0]=EStartValue
	EARect[0][1]=AStartValue
	EARect[1][0]=EEndValue
	EARect[1][1]=AStartValue
	EARect[2][0]=EEndValue
	EARect[2][1]=AEndValue
	EARect[3][0]=EStartValue
	EARect[3][1]=AEndValue
	EARect[4][0]=EStartValue
	EARect[4][1]=AStartValue
	
	Make/O/D/N=(5,2) $xyWaveArg
	Wave/D xyRect=$xyWaveArg
	xyRect[0][0]=xStartValue
	xyRect[0][1]=yStartValue
	xyRect[1][0]=xEndValue
	xyRect[1][1]=yStartValue
	xyRect[2][0]=xEndValue
	xyRect[2][1]=yEndValue
	xyRect[3][0]=xStartValue
	xyRect[3][1]=yEndValue
	xyRect[4][0]=xStartValue
	xyRect[4][1]=yStartValue
End

//Panel 4DViewer: EAmap (left) & xyMap (right)
Function/S IAFp_4DViewer_Definition()
	return "31;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;Wave2D;Wave2D;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable;String;String;String;Wave2D;Wave2D;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Variable"
End

Function IAFp_4DViewer(argumentList,PanelName,PanelTitle)
	String argumentList,PanelName,PanelTitle
	
	//0th argument: EAmap
	String EAArg=StringFromList(0,argumentList)
	
	//1st argument: xymap
	String xyArg=StringFromList(1,argumentList)
	
	//2nd & 3rd arguments: E Indices
	String EStartIndexArg=StringFromList(2,argumentList)
	String EEndIndexArg=StringFromList(3,argumentList)
	
	//4th & 5th arguments: A Indices
	String AStartIndexArg=StringFromList(4,argumentList)
	String AEndIndexArg=StringFromList(5,argumentList)
	
	//6th & 7th arguments: x Indices
	String xStartIndexArg=StringFromList(6,argumentList)
	String xEndIndexArg=StringFromList(7,argumentList)
	
	//8th & 9th arguments: y Indices
	String yStartIndexArg=StringFromList(8,argumentList)
	String yEndIndexArg=StringFromList(9,argumentList)
	
	//10th & 11th arguments: E center & width
	String ECenterArg=StringFromList(10,argumentList)
	String EWidthArg=StringFromList(11,argumentList)
	
	//12th & 13th arguments: A center & width
	String ACenterArg=StringFromList(12,argumentList)
	String AWidthArg=StringFromList(13,argumentList)
	
	//14th & 15th arguments: x center & width
	String xCenterArg=StringFromList(14,argumentList)
	String xWidthArg=StringFromList(15,argumentList)
	
	//16th & 17th arguments: y center & width
	String yCenterArg=StringFromList(16,argumentList)
	String yWidthArg=StringFromList(17,argumentList)
	
	//18th & 19th & 20th arguments: A, x, y labels
	String ALabelArg=StringFromList(18,argumentList)
	String xLabelArg=StringFromList(19,argumentList)
	String yLabelArg=StringFromList(20,argumentList)
	
	//21st argument: EA rect
	String EARectArg=StringFromList(21,argumentList)
	
	//22nd argument: xy rect
	String xyRectArg=StringFromList(22,argumentList)
		
	//23rd argument: E center delta
	//24th argument: A center delta
	//25th argument: x center delta
	//26th argument: y center delta
	
	//27th argument: E width delta
	//28th argument: A width delta
	//29th argument: x width delta
	//30th argument: y width delta
	
	Wave/D EA=$EAArg
	Wave/D xy=$xyArg
	NVAR EStartIndex=$EStartIndexArg
	NVAR EEndIndex=$EEndIndexArg
	SVAR ALabel=$ALabelArg
	SVAR xLabel=$xLabelArg
	SVAR yLabel=$yLabelArg
	Wave/D EARect=$EARectArg
	Wave/D xyRect=$xyRectArg
	
	//empty graph
	NewPanel/K=1/W=(0,0,800,500) as PanelTitle
	
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
		
	//Control bar (not actual ControlBar created by the command "ControlBar")
	Variable ControlBarHeight=150
	
	//setvariables
	IAFcu_DrawSetVariable(30,0,"E Start",4,EStartIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(200,0,"End",4,EEndIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(300,0,"Center",5,ECenterArg,1,1,-inf,inf,0)
	IAFcu_DrawSetVariable(450,0,"Width",5,EWidthArg,1,1,-inf,inf,0)
	
	IAFcu_DrawSetVariable(30,30,"A Start",4,AStartIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(200,30,"End",4,AEndIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(300,30,"Center",5,ACenterArg,1,1,-inf,inf,0)
	IAFcu_DrawSetVariable(450,30,"Width",5,AWidthArg,1,1,-inf,inf,0)

	IAFcu_DrawSetVariable(30,60,"x Start",4,xStartIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(200,60,"End",4,xEndIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(300,60,"Center",5,xCenterArg,1,1,-inf,inf,0)
	IAFcu_DrawSetVariable(450,60,"Width",5,xWidthArg,1,1,-inf,inf,0)
		
	IAFcu_DrawSetVariable(30,90,"y Start",4,yStartIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(200,90,"End",4,yEndIndexArg,0,1,-inf,inf,1)
	IAFcu_DrawSetVariable(300,90,"Center",5,yCenterArg,1,1,-inf,inf,0)
	IAFcu_DrawSetVariable(450,90,"Width",5,yWidthArg,1,1,-inf,inf,0)
	
	//Wide & Narrow button
	Variable fs=IAFcu_FontSize()
	String fn=IAFcu_FontName()
	
	Variable width=IAFcu_CalcChartWidth(1)
	Variable height=IAFcu_CalcChartHeight(1)
	String command
	String format
	
	sprintf format "Button %%s pos={%%g,%%g},font=\"%s\",fsize=%g,title=\"%%s\",proc=%s,size={%g,%g}",fn,fs,"IAFu_4DViewer_Button",width,height
	
	sprintf command format,"EWide",610,0,"+"
	Execute command
	sprintf command format,"ENarrow",580,0,"-"
	Execute command
		
	sprintf command format,"AWide",610,30,"+"
	Execute command
	sprintf command format,"ANarrow",580,30,"-"
	Execute command
		
	sprintf command format,"xWide",610,60,"+"
	Execute command
	sprintf command format,"xNarrow",580,60,"-"
	Execute command
		
	sprintf command format,"yWide",610,90,"+"
	Execute command
	sprintf command format,"yNarrow",580,90,"-"
	Execute command
	
	//slider
	Variable sliderInitial=0.5
	
	Slider horizSlider pos={0,120},size={50,50},limits={0,1,0},ticks=0,vert=0,side=2,value=sliderInitial,proc=IAFu_Guide_Slider
	DefineGuide horizCenter={FL,sliderInitial,FR}
	DefineGuide vertTop={FT,ControlBarHeight}
	
	Variable margin1=60 //left
	Variable margin2=50 //bottom
	Variable margin3=10 //right
	Variable margin4=10  //top
	Variable gfSize=18 //font size

	//EA
	Display/HOST=$parentPanelName/FG=(FL,vertTop,horizCenter,FB)/N=EA
	AppendImage EA
	ModifyGraph swapXY=1,margin(left)=margin1,margin(bottom)=margin2,margin(right)=margin3,margin(top)=margin4
	ModifyGraph tick=2,axThick=0.5,zero=1
	Label left "\\f02E\\f00 - \\f02E\\f00\\BF\\M (eV)"
	Label bottom ALabel
	ModifyImage $EAArg ctab={*,*,Terrain,1}
	ModifyGraph gfSize=gfSize
	AppendToGraph EArect[*][1] vs EArect[*][0]
	
	//xy
	Display/HOST=$parentPanelName/FG=(horizCenter,vertTop,FR,FB)/N=xy
	AppendImage xy
	ModifyGraph margin(left)=margin1,margin(bottom)=margin2,margin(right)=margin3,margin(top)=margin4
	ModifyGraph tick=2,axThick=0.5,zero=1
	Label left yLabel
	Label bottom xLabel
	ModifyImage $xyArg ctab={*,*,Terrain,1}
	ModifyGraph gfSize=gfSize
	AppendToGraph xyrect[*][1] vs xyrect[*][0]


	//keyboard hook (for center change)
	SetWindow $parentPanelName hook(viewer4d_hook)=IAFu_4DViewer_Keyboard
End



Function IAFu_4DViewer_Button(BS): ButtonControl
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
		
		String EDeltaArg=""
		String ADeltaArg=""
		String xDeltaArg=""
		String yDeltaArg=""
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
						EDeltaArg=Diagram_i[j][27]
						ADeltaArg=Diagram_i[j][29]
						xDeltaArg=Diagram_i[j][31]
						yDeltaArg=Diagram_i[j][33]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data
				
		Variable delta=0
		strswitch(BS.ctrlName)
			case "EWide":
				delta=1
			case "ENarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR EDelta=$EDeltaArg
				EDelta=delta
				cd ::
				IAFc_Update(EDeltaArg)
				break
				
			case "AWide":
				delta=1
			case "ANarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR ADelta=$ADeltaArg
				ADelta=delta
				cd ::
				IAFc_Update(ADeltaArg)
				break
				
			case "xWide":
				delta=1
			case "xNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR xDelta=$xDeltaArg
				xDelta=delta
				cd ::
				IAFc_Update(xDeltaArg)
				break
				
			case "yWide":
				delta=1
			case "yNarrow":
				If(delta==0)
					delta=-1
				Endif
				NVAR yDelta=$yDeltaArg
				yDelta=delta
				cd ::
				IAFc_Update(yDeltaArg)
				break
		Endswitch
		cd $currentFolder
	Endif
	return 1
End

Function IAFu_4DViewer_Keyboard(s)
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
		
		If(cmpstr(graphName,"EA")!=0 && cmpstr(graphName,"xy")!=0)
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
		
		String EDeltaArg=""
		String ADeltaArg=""
		String xDeltaArg=""
		String yDeltaArg=""
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
						EDeltaArg=Diagram_i[j][26]
						ADeltaArg=Diagram_i[j][28]
						xDeltaArg=Diagram_i[j][30]
						yDeltaArg=Diagram_i[j][32]
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
			If(cmpstr(graphName,"EA")==0)
				//EA -> ADelta
				NVAR ADelta=$ADeltaArg
				ADelta=delta
				cd ::
				IAFc_Update(ADeltaArg)
			Else
				//xy -> xDelta
				NVAR xDelta=$xDeltaArg
				xDelta=delta
				cd ::
				IAFc_Update(xDeltaArg)
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
			If(cmpstr(graphname,"EA")==0)
				//EA ->EDelta
				NVAR EDelta=$EDeltaArg
				EDelta=delta
				cd ::
				IAFc_Update(EDeltaArg)
			Else
				//xy -> yDelta
				NVAR yDelta=$yDeltaArg
				yDelta=delta
				cd ::
				IAFc_Update(yDeltaArg)
			ENdif
			break
		endswitch
		cd $currentFolder			
	Endif
	return 0
End