#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "IAFcu_VerifyKindType"


Function/S IAFf_Prototype_Definition()
End

Function IAFf_Prototype_Execution(argumentList)
	String argumentList
End

Function/S IAFm_Prototype_Definition()
End

Function/D IAFm_Prototype_Execution(argumentList)
	String argumentList
	return 0
End

Function/S IAFc_Function_Definition(FuncType)
	String FuncType
	String FuncFullName="IAFf_"+FuncType+"_Definition"
	FUNCREF IAFf_Prototype_Definition f = $FuncFullName
	return f()
End

Function/S IAFc_Module_Definition(ModuleType)
	String ModuleType
	String ModuleFullName="IAFm_"+ModuleType+"_Definition"
	FUNCREF IAFm_Prototype_Definition f = $ModuleFullName
	return f()
End

Function IAFc_Execute(FuncName)
	String FuncName
	
	String currentFolder=GetDataFolder(1)
		
	//find Diagram info	
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
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
				If(cmpstr(Name_ij,FuncName)==0 && cmpstr(Kind_ij,"Function")==0)
					String Definition=IAFc_Function_Definition(Type_ij)					
					String FuncFullName="IAFf_"+Type_ij
					FUNCREF IAFf_Prototype_Execution f = $FuncFullName
					
					//check variables exist
					cd $currentFolder
					If(!DataFolderExists("Data"))
						Print("Error: folder Data does not exist")
						cd $currentFolder
						return 0
					Endif
					cd Data
					
					Variable numArgs=str2num(StringFromList(0,Definition))
					Variable k
					For(k=0;k<numArgs;k+=1)
						If(cmpstr(StringFromList(1+k,Definition),"0")==0)
							StrSwitch(StringFromList(1+numArgs+k,Definition))
							Case "Variable":
								NVAR v=$Diagram_i[j][k+3]
								If(!NVAR_exists(v))
									Print("Error: Variable \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									cd $currentFolder
									return 0
								Endif
								break
							Case "String":
								SVAR s=$Diagram_i[j][k+3]
								If(!SVAR_exists(s))
									Print("Error: String \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									cd $currentFolder
									return 0
								Endif
								break
							Case "Wave1D":
							Case "Wave2D":
							Case "Wave3D":
								Wave/D w=$Diagram_i[j][k+3]
								If(!WaveExists(w))
									Print("Error: Variable Wave \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									cd $currentFolder
									return 0
								Endif
								break
							Case "TextWave":
								Wave/T t=$Diagram_i[j][k+3]
								If(!WaveExists(t))
									Print("Error: Text Wave \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									cd $currentFolder
									return 0
								Endif
								break
							Default:
							Endswitch
						Endif
					Endfor
					
					//execute
					String argumentsList=""
					For(k=0;k<numArgs;k+=1)
						argumentsList=addListItem(Diagram_i[j][numArgs-k+2],argumentsList)
					Endfor
					f(argumentsList)
					cd $currentFolder
					return 0
				Endif
			Endif
		Endfor
	Endfor	
	Print("Error: Function Part \""+FuncName+"\" does not exist")
	cd $currentFolder
	return 0
End