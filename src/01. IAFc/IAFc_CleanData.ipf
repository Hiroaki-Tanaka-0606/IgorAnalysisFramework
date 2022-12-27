#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_CleanData: remove unused Variable(s) and String(s) in Data folder
Function IAFc_CleanData()
	Print("[IAFc_CleanData]")
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
	cd Diagrams
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Print("Diagram Waves to be verified: "+DiagramWaveList)
	
	String StringsList=""
	String VariablesList=""
	String WavesList=""
	
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
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Data", 1)==0)
				if(cmpstr(Type_ij, "String", 1)==0)
					StringsList=addlistitem(Name_ij,StringsList)
				elseif(cmpstr(Type_ij, "Variable", 1)==0)
					VariablesList=addListItem(Name_ij,VariablesList)
				elseif(cmpstr(Type_ij, "Wave1D", 1)==0 || \
						cmpstr(Type_ij, "Wave2D", 1)==0 || \
						cmpstr(Type_ij, "Wave3D", 1)==0 || \
						cmpstr(Type_ij, "Wave4D", 1)==0 || \
						cmpstr(Type_ij, "TextWave", 1)==0)
					WavesList=addListItem(Name_ij,WavesList)
				endif
			Endif
		Endfor
	Endfor
	cd ::
	If(!DataFolderExists("Data"))
		Print("Error: folder Data does not exist")
		return 0
	Endif
	
	cd Data
	//list of existing data
	String existVariables=VariableList("*",";",4)
	String existStrings=StringList("*",";")
	String existWaves=WaveList("*",";","")
	

	Variable size=ItemsInList(existVariables)
	For(i=0;i<size;i+=1)
		String variableName=StringFromList(i,existVariables)
		If(FindListItem(variableName,VariablesList)==-1)
			//the variable is not necessary for current diagram
			Print("Remove Variable "+variableName)
			KillVariables $variableName
		Endif
	Endfor
	
	size=ItemsInList(existStrings)
	For(i=0;i<size;i+=1)
		String stringName=StringFromList(i,existStrings)
		If(FindListItem(stringName,StringsList)==-1)
			//the string is not necessary for current diagram
			Print("Remove String "+stringName)
			KillStrings $stringName
		Endif
	Endfor
		
	size=ItemsInList(existWaves)
	For(i=0;i<size;i+=1)
		String waveName=StringFromList(i,existWaves)
		If(FindListItem(waveName,WavesList)==-1)
			//the wave is not necessary for current diagram
			Print("Remove Wave "+waveName)
			KillWaves $waveName
		Endif
	Endfor

	cd ::
	
End