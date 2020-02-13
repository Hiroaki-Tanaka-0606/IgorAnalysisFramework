#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_CreateData: create Variable(s) and String(s) in Data folder
Function IAFc_CreateData()
	Print("[IAFc_CreateData]")
	
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
			If(IAFcu_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Data")==0)
				strswitch(Type_ij)
				case "String":
					StringsList=addlistitem(Name_ij,StringsList)
					break
				Case "Variable":
					VariablesList=addListItem(Name_ij,VariablesList)
				Default:
					//wave, do nothing
					break
				endswitch
			Endif
		Endfor
	Endfor
	cd ::
	If(!DataFolderExists("Data"))
		Print("Error: folder Data does not exist")
		return 0
	Endif
	
	cd Data
	Variable numStrings=itemsinlist(StringsList)
	Variable numVariables=itemsinlist(VariablesList)
	
	For(i=0;i<numStrings;i+=1)
		String String_i=stringfromlist(i,StringsList)
		SVAR a=$String_i
		If(!SVAR_exists(a))
			String/G $String_i=""
		Endif
	Endfor
	
	For(i=0;i<numVariables;i+=1)
		String Variable_i=stringfromlist(i,VariablesList)
		NVAR b=$Variable_i
		If(!NVAR_exists(b))
			Variable/G $Variable_i=0
		Endif
	Endfor
	
	cd ::
	
End