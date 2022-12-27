#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_ConfigureChart: create ChartIndex & ChartPosition in folder "Configurations"
Function IAFc_ConfigureChart()
	Print("[IAFc_ConfigureChart]")
	
	String currentFolder=GetDataFolder(1)
	
	//get names of all parts
	//assuming duplication is already verified
	String TypeList=""
	String NameList=""
	String OriginList=""
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
	cd Diagrams
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Print("Diagram Waves to be verified: "+DiagramWaveList)
	
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
				TypeList=AddListItem(Type_ij,TypeList)
				NameList=AddListItem(Name_ij,NameList)
				OriginList=AddListItem(DiagramWaveName,OriginList)
			Endif
		Endfor
	Endfor
	
	//Print(PartsList)
	Variable numParts=ItemsInList(NameList)
	//list of parts not yet added to newChartIndex
	String remainingPartsList=NameList
	
	cd $currentFolder
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	cd Configurations
	//create new ChartIndex & ChartPosition
	Make/O/T/N=(numParts,2) newChartIndex
	Make/O/D/N=(numParts,4) newChartPosition
	
	//copy ChartIndex & ChartPosition
	Wave/T ChartIndex=ChartIndex
	Wave/D ChartPosition=ChartPosition
	Wave/T newChartIndex=newChartIndex
	Wave/D newChartPosition=newChartPosition
	
	Variable ChartIndexSize=DimSize(ChartIndex,0)
	Variable newIndex=0
	If(ChartIndexSize==DimSize(ChartPosition,0))
		For(i=0;i<ChartIndexSize;i+=1)
			String PartName=ChartIndex[i][0]
			If(WhichListItem(PartName,remainingPartsList)!=-1)
				//exist
				newChartIndex[newIndex][]=ChartIndex[i][q]
				newChartPosition[newIndex][]=ChartPosition[i][q]
				newIndex+=1
				remainingPartsList=RemoveFromList(PartName,remainingPartsList)
			Endif
		Endfor
	Endif
	
	//add remaining Parts
	Variable remainingNumParts=ItemsInList(remainingPartsList)
	
	//also see IAFc_DrawChart()
	Variable offsetX=10
	Variable offsetY=(IAFc_CalcChartHeight(1)+10)*2
	
	For(i=0;i<remainingNumParts;i+=1)
		PartName=StringFromList(i,remainingPartsList)
		Variable index=WhichListItem(PartName,NameList)
		String TypeName=StringFromList(index,TypeList)
		newChartIndex[newIndex][0]=PartName
		String OriginName=StringFromList(index,OriginList)
		newChartIndex[newIndex][1]=OriginName
		Variable LetterLength=max(strlen(PartName),strlen(TypeName))
		Variable width=IAFc_CalcChartWidth(LetterLength)
		Variable height=IAFc_CalcChartHeight(2)
		newChartPosition[newIndex][0]=offsetX+width/2
		newChartPosition[newIndex][1]=offsetY+height/2
		newChartPosition[newIndex][2]=width
		newChartPosition[newIndex][3]=height
		newIndex+=1
	Endfor
	
	//replace ~~ by new~~
	Killwaves ChartIndex,ChartPosition
	Duplicate/O newChartIndex,$"ChartIndex"
	Duplicate/O newChartPosition,$"ChartPosition"
	KillWaves newChartIndex,newChartPosition
	
	cd $currentFolder
End
