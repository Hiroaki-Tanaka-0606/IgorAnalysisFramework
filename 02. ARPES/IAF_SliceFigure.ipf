#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function CalcMinOffset_E: calculate minimum offset, by which two adjacent slices (input[][i]) do not touch
Function/S IAFf_CalcMinOffset_E_Definition()
	return "3;0;0;1;Wave2D;Variable;Variable"
End

Function IAFf_CalcMinOffset_E(argumentList)
	String argumentList
	
	//0th argument: input wave2D
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: offset direction
	//0: input[][j+1] is above input[][j]
	//1: input[][j] is above input[][j+1]
	String directionArg=StringFromList(1,argumentList)
	
	//2nd argument: output minimum offset
	String minOffsetArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	NVAR direction=$directionArg
	NVAR minOffset=$minOffsetArg
	
	Variable size1=Dimsize(input,0)
	Variable size2=DimSize(input,1)
	
	minOffset=0
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2-1;j+=1)
			if(direction!=1)
				//input[][j+1] is above input[][j]
				Variable offset=input[i][j]-input[i][j+1]
				if(offset>minOffset)
					minOffset=offset
				Endif
			Else
				//input[][j] is above input[][j+1]
				offset=input[i][j+1]-input[i][j]
				if(offset>minOffset)
					minOffset=offset
				Endif
			Endif
		Endfor
	Endfor
End

//Function OffsetFigure_E: Add offset to each slice input[][i]
Function/S IAFf_OffsetFigure_E_Definition()
	return "5;0;0;0;0;1;Wave2D;Variable;Variable;Variable;Wave2D"
End

Function IAFf_OffsetFigure_E(argumentList)
	String argumentList
	
	//0th argument: input
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: direction
	String directionArg=StringFromList(1,argumentList)
	
	//2nd argument: minimum offset
	String minOffsetArg=StringFromList(2,argumentList)
	
	//3rd argument: margin factor
	String marginArg=StringFromList(3,argumentList)
	
	//4th argument: output
	String outputArg=StringFromList(4,argumentList)
	
	Wave/D input=$inputArg
	NVAR direction=$directionArg
	NVAR minOffset=$minOffsetArg
	NVAR margin=$marginArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	If(direction!=1)
		output[][]+=minOffset*(1.0+margin)*q
	Else
		output[][]-=minOffset*(1.0+margin)*q
	Endif
End

//Panel SliceFigure_E: make a figure of input[][i]s with offset
Function/S IAFp_SliceFigure_E_Definition()
	return "4;0;0;0;0;Variable;Variable;Variable;Wave2D"
End

Function IAFp_SliceFigure_E(argumentList, PanelName, PanelTitle)
	String argumentList, Panelname, PanelTitle
	
	//0th argument: direction
	String directionArg=StringFromList(0,argumentList)
	
	//1st argument: minOffset (displayed only)
	String minOffsetArg=StringFromList(1,argumentList)
	
	//2nd argument: margin
	String marginArg=StringFromList(2,argumentList)
	
	//3rd argument: name of map with offset
	String mapArg=StringFromList(3,argumentList)
	
	//create a panel
	NewPanel/K=1/W=(0,0,300,120) as PanelTitle
		
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
	
	//put a setVariable
	IAFcu_DrawSetVariable(0,0,directionArg,2,directionArg,1,1,0,1,1)
	IAFcu_DrawSetVariable(0,30,minOffsetArg,6,minOffsetArg,0,0,0,inf,0)
	IAFcu_DrawSetVariable(0,60,marginArg,4,marginArg,1,1,-1,inf,0)
	
	//put a "draw graph" button
	Variable fs=IAFcu_FontSize()
	String fn=IAFcu_FontName()
	
	Variable width=IAFcu_CalcChartWidth(12)
	Variable height=IAFcu_CalcChartHeight(1)
	
	String command
	String format
	sprintf format "Button %%s pos={%%g,%%g},font=\"%s\",fsize=%g,title=\"%%s\",proc=%s,size={%g,%g}",fn,fs,"IAFu_SliceFigure_Button",width,height
	
	sprintf command format,"DrawGraph_E",0,90,"Draw a Graph"
	Execute command

End

Function IAFu_SliceFigure_Button(BS): ButtonControl
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
		
		String offsetMapArg=""
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
						offsetMapArg=Diagram_i[j][6]
						break
					Endif
				ENdif
			Endfor
		Endfor
		cd ::Data
		Wave/D offsetMap=$offsetMapArg
		Variable size1=DimSize(offsetMap,0)
		Variable size2=DimSize(offsetMap,1)
		String format1="Display "+offsetMapArg+"[%s][%s]"
		String format2="AppendToGraph "+offsetMapArg+"[%s][%s]"
		String command
		strswitch(BS.ctrlName)
			case "DrawGraph_E":
				sprintf command,format1,"*","0"
				execute command
				For(i=1;i<size2;i+=1)
					sprintf command format2,"*",num2str(i)
					execute command
				Endfor
				break
		Endswitch
		cd $currentFolder
	Endif
	return 1
End