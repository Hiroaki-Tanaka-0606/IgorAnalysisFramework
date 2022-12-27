#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/S IAFc_Prototype_Definition()
End

Function IAFc_Prototype(argumentList)
	String argumentList
End

Function/S IAFc_Prototype_Module(argumentList)
	String argumentList
	return ""
End


Function IAFc_Panel_Prototype(argumentList,PanelName,PanelTitle)
	String argumentList,PanelName,PanelTitle
End

Function/S IAFc_Function_Definition(FuncType)
	String FuncType
	String FuncFullName="IAFf_"+FuncType+"_Definition"
	FUNCREF IAFc_Prototype_Definition f = $FuncFullName
	return f()
End

Function/S IAFc_Module_Definition(ModuleType)
	String ModuleType
	String ModuleFullName="IAFm_"+ModuleType+"_Definition"
	FUNCREF IAFc_Prototype_Definition f = $ModuleFullName
	return f()
End

Function/S IAFc_Panel_Definition(PanelType)
	String PanelType
	String PanelFullName="IAFp_"+PanelType+"_Definition"
	FUNCREF IAFc_Prototype_Definition f=$PanelFullName
	return f()
End

//IFAc_Execute: execute a Function
Function IAFc_Execute(FuncName)
	String FuncName
	//Print(FuncName)
	//currentFolder is root folder of the framework
		
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
			If(IAFc_VerifyKindType(Kind_ij,Type_ij))
				If(cmpstr(Name_ij,FuncName,1)==0 && cmpstr(Kind_ij,"Function",1)==0)
					String Definition=IAFc_Function_Definition(Type_ij)					
					String FuncFullName="IAFf_"+Type_ij
					FUNCREF IAFc_Prototype f = $FuncFullName
					
					//check variables exist
					cd ::
					If(!DataFolderExists("Data"))
						Print("Error: folder Data does not exist")
						return 0
					Endif
					cd Data
					
					Variable numArgs=str2num(StringFromList(0,Definition))
					Variable k
					For(k=0;k<numArgs;k+=1)
						If(cmpstr(StringFromList(1+k,Definition),"0",1)==0)
							String Type_k=StringFromList(1+numArgs+k,Definition)
							if(cmpstr(Type_k, "Variable", 1)==0)
								NVAR v=$Diagram_i[j][k+3]
								If(!NVAR_exists(v))
									Printf "Error: Variable \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "String", 1)==0)
								SVAR s=$Diagram_i[j][k+3]
								If(!SVAR_exists(s))
									Printf "Error: String \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "Wave1D", 1)==0 || \
									cmpstr(Type_k, "Wave2D", 1)==0 || \
									cmpstr(Type_k, "Wave3D", 1)==0 || \
									cmpstr(Type_k, "Wave4D", 1)==0)
								Wave/D w=$Diagram_i[j][k+3]
								If(!WaveExists(w))
									Printf "Error: Variable Wave \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "TextWave", 1)==0)
								Wave/T t=$Diagram_i[j][k+3]
								If(!WaveExists(t))
									Printf "Error: Text Wave \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							endif
						Endif
						
					Endfor
					
					//execute
					String argumentsList=""
					For(k=0;k<numArgs;k+=1)
						argumentsList=addListItem(Diagram_i[j][numArgs-k+2],argumentsList)
					Endfor
					f(argumentsList)
					cd ::
					return 0
				Endif
			Endif
		Endfor
	Endfor	
	Printf "Error: Function Part \"%s\" does not exist", FuncName
	cd ::
	return 0
End

//IAFc_CallSocket: call socket
Function/S IAFc_CallSocket(ModuleName,valueWaveName)
	String ModuleName,valueWaveName
	
	//currentFolder is Data
	//find Diagram info	
	cd ::
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		cd currentFolder
		return ""
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
			If(IAFc_VerifyKindType(Kind_ij,Type_ij))
				If(cmpstr(Name_ij,ModuleName,1)==0 && cmpstr(Kind_ij,"Module",1)==0)
					String FuncFullName="IAFm_"+Type_ij
					String Definition=IAFc_Module_Definition(Type_ij)	
					FUNCREF IAFc_Prototype_Module f = $FuncFullName			
					//check variables exist
					cd ::
					If(!DataFolderExists("Data"))
						Print("Error: folder Data does not exist")
						cd Data
						return ""
					Endif
					cd Data
					
					Variable numArgs=str2num(StringFromList(0,Definition))
					Variable k
					String argumentsList=""
					For(k=0;k<numArgs;k+=1)
						If(cmpstr(StringFromList(1+k,Definition),"0",1)==0)
							String Type_k=StringFromList(1+numArgs+k, Definition)
							if(cmpstr(Type_k, "Variable", 1)==0)
								NVAR v=$Diagram_i[j][k+3]
								If(!NVAR_exists(v))
									Print("Error: Variable \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									return ""
								Endif
							elseif(cmpstr(Type_k, "String", 1)==0)
								SVAR s=$Diagram_i[j][k+3]
								If(!SVAR_exists(s))
									Print("Error: String \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									return ""
								Endif
								break
							elseif(cmpstr(Type_k, "Wave1D", 1)==0 || \
								cmpstr(Type_k, "Wave2D", 1)==0 || \
								cmpstr(Type_k, "Wave3D", 1)==0 || \
								cmpstr(Type_k, "Wave4D", 1)==0)
								Wave/D w=$Diagram_i[j][k+3]
								If(!WaveExists(w))
									Print("Error: Variable Wave \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									return ""
								Endif
							elseif(cmpstr(Type_k, "TextWave", 1)==0)
								Wave/T t=$Diagram_i[j][k+3]
								If(!WaveExists(t))
									Print("Error: Text Wave \""+Diagram_i[j][k+3]+"\" does not exist in folder Data")
									return ""
								Endif
							endif
						Endif
					Endfor
					
					//get argumentsList
					For(k=0;k<numArgs;k+=1)
						If(cmpstr(StringFromList(1+(numArgs-k-1),Definition),"2",1)==0)
							//socket
							argumentsList=addListItem(valueWaveName,argumentsList)
						Else
							//data
							argumentsList=addListItem(Diagram_i[j][3+(numArgs-k-1)],argumentsList)
						Endif
					Endfor
					return f(argumentsList)
				Endif
			Endif
		Endfor
	Endfor
	
	Printf "Error: Module Part \"%s\" does not exist", ModuleName
	cd ::Data
	return ""
End

//IAFc_ExecuteList: Execute Functions in FuncList according to the order taking into account the dependency
Function IAFc_ExecuteList(FuncList)
	String FuncList
	Variable i
	Variable numFuncs
	//Print(FuncList)
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	
	Wave/T DataOrigin=:Configurations:DataOrigin
	Variable DataOriginSize=DimSize(DataOrigin,0)
	Wave/T Ascend=:Configurations:Ascend
	Variable AscendSize=DimSize(Ascend,0)
	Wave/T Descend=:Configurations:Descend
	Variable DescendSize=DimSize(Descend,0)
	
	If(!WaveExists(DataOrigin) || !WaveExists(Ascend) || !WaveExists(Descend))
		Print("Error: Invalid configurations")
		return 0
	Endif
	
	String Function_i
	String inputs_i,input_ij,Function_ij
	Variable j,k
	Variable flag,flag2
	Variable inputSize
	do
		numFuncs=ItemsInList(FuncList)
		If(numFuncs==0)
			break
		Endif
		For(i=0;i<numFuncs;i+=1)
			Function_i=StringFromList(i,FuncList)
			inputs_i="" //input of Function_i
			flag=0
			For(j=0;j<AscendSize;j+=1)
				If(cmpstr(Ascend[j][0],Function_i,1)==0)
					inputs_i=Ascend[j][1]
					flag=1
					break
				Endif
			Endfor
			If(flag==0)
				//not found
				Printf "Error: Function \"%s\" does not exist in Ascend", Function_i
				return 0
			Endif
			inputSize=ItemsInList(inputs_i)
			
			flag=1
			For(j=0;j<inputSize;j+=1)
				input_ij=StringFromList(j,inputs_i)
				flag2=0
				For(k=0;k<DataOriginSize;k+=1)
					If(cmpstr(input_ij,DataOrigin[k][1],1)==0)
						Function_ij=DataOrigin[k][2]
						flag2=1
						If(WhichListItem(Function_ij,FuncList)!=-1)
							//now we can not execute Function_i because of dependency
							flag=0
							break
						Endif
					Endif
				Endfor
				If(flag2==0)
					//not found
					Printf "Error: Data\"%s\" does not exist in DataOrigin", input_ij
					return 0
				Endif
				If(flag==0)
					break
				Endif
			Endfor
			
			If(flag==0)
				continue
			Else
				//execute
				FuncList=RemoveFromList(Function_i,FuncList)
				IAFc_Execute(Function_i)
				break
			Endif
		Endfor
	while(1)
End

//IAFc_ExecuteAll: Execute all Functions
Function IAFc_ExecuteAll()
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	
	Wave/T Ascend=:Configurations:Ascend
	Variable AscendSize=DimSize(Ascend,0)
	
	String AllFuncList=""
	Variable i
	For(i=0;i<AscendSize;i+=1)
		AllFuncList=AddListItem(Ascend[i][0],AllFuncList)
	Endfor
	
	IAFc_ExecuteList(AllFuncList)
End

//IAFc_Update: Execute Function necessary to execute because of the updates of data
Function IAFc_Update(DataList)
	String DataList
	
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	
	Wave/T Descend=:Configurations:Descend
	Variable DescendSize=DimSize(Descend,0)
	Variable i,j
	Variable DataListSize=ItemsInList(DataList)
	
	String FuncList=""
	String Data_i
	Variable flag
	String Funcs_i,Func_ij
	Variable FuncSize
	For(i=0;i<DataListSize;i+=1)
		Data_i=StringFromList(i,DataList)
		flag=0
		For(j=0;j<DescendSize;j+=1)
			If(cmpstr(Data_i,Descend[j][0],1)==0)
				Funcs_i=Descend[j][1]
				flag=1
				break
			Endif
		Endfor
		If(flag==0)
			Printf "Error: Data \"%s\" does not exist in Descend", Data_i
			return 0
		Endif
		FuncSize=ItemsInList(Funcs_i)
		For(j=0;j<FuncSize;j+=1)
			Func_ij=StringFromList(j,Funcs_i)
			If(WhichListItem(Func_ij,FuncList)==-1)
				FuncList=AddListItem(Func_ij,FuncList)
			Endif
		ENdfor
	Endfor
	IAFc_ExecuteList(FuncList)
End


//IFAc_DrawPanel: execute a Panel drawing function
Function IAFc_DrawPanel(PanelName,PanelTitle)
	String PanelName,PanelTitle
	
	//currentFolder is root folder of the framework
		
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
			If(IAFc_VerifyKindType(Kind_ij,Type_ij))
				If(cmpstr(Name_ij,PanelName,1)==0 && cmpstr(Kind_ij,"Panel",1)==0)
					String Definition=IAFc_Panel_Definition(Type_ij)					
					String FuncFullName="IAFp_"+Type_ij
					FUNCREF IAFc_Panel_Prototype f = $FuncFullName
					
					//check variables exist
					cd ::
					If(!DataFolderExists("Data"))
						Print("Error: folder Data does not exist")
						return 0
					Endif
					cd Data
					
					Variable numArgs=str2num(StringFromList(0,Definition))
					Variable k
					For(k=0;k<numArgs;k+=1)
						If(cmpstr(StringFromList(1+k,Definition),"0",1)==0)
							String Type_k=StringFromList(1+numArgs+k,Definition)
							if(cmpstr(Type_k, "Variable", 1)==0)
								NVAR v=$Diagram_i[j][k+3]
								If(!NVAR_exists(v))
									Printf "Error: Variable \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "String", 1)==0)
								SVAR s=$Diagram_i[j][k+3]
								If(!SVAR_exists(s))
									Printf "Error: String \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "Wave1D", 1)==0 || \
									cmpstr(Type_k, "Wave2D", 1)==0 || \
									cmpstr(Type_k, "Wave3D", 1)==0 || \
									cmpstr(Type_k, "Wave4D", 1)==0)
								Wave/D w=$Diagram_i[j][k+3]
								If(!WaveExists(w))
									Printf "Error: Variable Wave \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							elseif(cmpstr(Type_k, "TextWave", 1)==0)
								Wave/T t=$Diagram_i[j][k+3]
								If(!WaveExists(t))
									Printf "Error: Text Wave \"%s\" does not exist in folder Data", Diagram_i[j][k+3]
									cd ::
									return 0
								Endif
							endif
						Endif
						
					Endfor
					
					//execute
					String argumentsList=""
					For(k=0;k<numArgs;k+=1)
						argumentsList=addListItem(Diagram_i[j][numArgs-k+2],argumentsList)
					Endfor
					f(argumentsList,PanelName,PanelTitle)
					cd ::
					return 0
				Endif
			Endif
		Endfor
	Endfor	
	Printf "Error: Panel Part \"%s\" does not exist", PanelName
	cd ::
	return 0
End
