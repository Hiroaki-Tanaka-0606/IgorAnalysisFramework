#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IFAc_ConfigureNames: check names of parts
Function IAFc_ConfigureNames()
	Print("[IAFc_ConfigureNames]")
	
	String currentFolder=GetDataFolder(1)
	
	String nameList="" //list of names already verified
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
				If(cmpstr(Name_ij, "", 1)==0 || WhichListItem(Name_ij,nameList)!=-1)
					//Name is blank ("") or duplicated
					//so, create new name
					String newName=IAFcu_CreateNewName(Type_ij,nameList)
					Printf "Replace name \"%s\" to \"%s\" in row %d of Diagram Wave \"%d\"", Diagram_i[j][2], newName, j, DiagramWaveName
					Diagram_i[j][2]=newName
				Endif
				nameList=AddListItem(Diagram_i[j][2],nameList)
			Else
				Printf "Skip row %d of Diagram Wave \"%s\" (Kind: \"%s\", Type: \"%s\"", j, DiagramWaveName, Kind_ij, Type_ij
			Endif
		Endfor
	Endfor
	
	cd $currentFolder
End

//IAFcu_CreateNewName: create new name as type+[integer], not duplicating with any other name in nameList
Function/S IAFcu_CreateNewName(type, nameList)
	String type, nameList
	String newName
	Variable suffix=0
	do
		newName=type+num2str(suffix)
		If(WhichListItem(newName,nameList)==-1)
			return newName
		Else
			suffix+=1
		Endif
	While(1)
End

//IAFc_ConfigureDependency: check names and types of the arguments, create Configuration Waves
//Return 1 when ok, 0 when not
Function IAFc_ConfigureDependency()
	Print("[IAFc_ConfigureDependency]")
	String currentFolder=GetDataFolder(1)
	Variable numErrors=0
	
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
	cd Diagrams
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Print("Diagram Waves to be verified: "+DiagramWaveList)
	
	//1. create first and second column of "DataOrigin" (=list of all Data names and types)
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i, j, k, WaveSize_i
	String DiagramWaveName, Kind_ij, Type_ij, Name_ij
	Variable numData=0
	For(i=0;i<numWaves;i+=1)
		DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		WaveSize_i=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize_i;j+=1)
			Kind_ij=Diagram_i[j][0]
			Type_ij=Diagram_i[j][1]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr("Data",Kind_ij,1)==0)
				numData+=1
			Endif
		Endfor
	Endfor
	cd $currentFolder	
	If(!DataFolderExists("Configurations"))
		Print("Error: folder Configurations does not exist")
		return 0
	Endif
	cd Configurations
	Make/O/T/N=(numData,3) DataOrigin
	Wave/T DataOrigin=DataOrigin
	DataOrigin[][]=""
	cd $currentFolder
	cd Diagrams
	Variable index=0
	For(i=0;i<numWaves;i+=1)
		DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		WaveSize_i=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize_i;j+=1)
			Kind_ij=Diagram_i[j][0]
			Type_ij=Diagram_i[j][1]
			Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr("Data",Kind_ij,1)==0)
				DataOrigin[index][0]=Type_ij
				DataOrigin[index][1]=Name_ij
				index+=1
			Endif
		Endfor
	Endfor

	String inout_k //from Definition
	String Type_k //from Definition
	String Name_ijk //from Diagram
	String Type_ijk //from Diagram
	Variable DataOriginIndex
	Variable numFunctions=0
	//2. check names and types of the arguments
	For(i=0;i<numWaves;i+=1)
		DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		WaveSize_i=DimSize(Diagram_i,0)
		Variable numArgs
		For(j=0;j<WaveSize_i;j+=1)
			Kind_ij=Diagram_i[j][0]
			Type_ij=Diagram_i[j][1]
			Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij))
				if(cmpstr(Kind_ij, "Data", 1)==0)
					//nothing to be verified
				elseif(cmpstr(Kind_ij, "Function", 1)==0)
					numFunctions+=1
					String FuncDef=IAFc_Function_Definition(Type_ij)
					//Verify Definition of the Function
					If(IAFc_VerifyFunctionDefinition(FuncDef)==0)
						//ill-defined
						Printf "Error: Function \"%s\" is ill-defined", Type_ij
						numErrors+=1
						break
					Endif
					//well-defined
					numArgs=str2num(StringFromList(0,FuncDef))
					For(k=0;k<numArgs;k+=1)
						inout_k=StringFromList(k+1,FuncDef)
						Type_k=StringFromList(numArgs+k+1,FuncDef)
						Name_ijk=Diagram_i[j][k+3]
						Switch(IAFc_JudgeDataSocket(Type_k))
						Case 1:
							//data
							DataOriginIndex=IAFcu_GetDataOriginIndex(Name_ijk,currentFolder)
							If(DataOriginIndex==-1)
								//Data does not exist
								Printf "Error: argument[%d]=\"%s\" does not exist (row %d, Diagram Wave \"%s\")", k, Name_ijk, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//Data exists
							Type_ijk=DataOrigin[DataOriginIndex][0]
							If(cmpstr(Type_k,Type_ijk,1)!=0)
								//types do not match
								Printf "Error: invalid type of data argument[%d] (row %d, Diagram Wave \"%s\")", k, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//types match
							if(cmpstr(inout_k, "0", 1)==0)
								//input, do nothing
							elseif(cmpstr(inout_k, "1", 1)==0)
								//output, write column 2 in DataOrigin
								If(cmpstr(DataOrigin[DataOriginIndex][2],"", 1)==0)
									//not filled
									DataOrigin[DataOriginIndex][2]=Name_ij
								Else
									//already filled, conflict
									Printf "Error: Data \"%s\" is output by multiple Functions", Name_ijk
									numErrors+=1
								Endif
							else
								//something strange
								Print("Unexpected error")
								numErrors+=1
								break
							endif
							break
						Case 2:
							//(data-sending) socket
							If(cmpstr(inout_k,"0", 1)!=0)
								Print("Unexpected error")
								numErrors+=1
								break
							Endif
							//find the type of the socket to receive the data
							Type_ijk=IAFcu_GetSocketType(Name_ijk)
							If(cmpstr(Type_ijk,"module not found", 1)==0)
								//Module Name_ijk does not exist
								Printf "Error: argument[%d]=\"%s\" does not exist (row %d, Diagram Wave \"%s\")", k, Name_ijk, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							If(cmpstr(Type_ijk,"socket not found", 1)==0)
								//the Module does not have a socket
								Printf "Error: Module \"%s\" in argument[%d] does not have a socket (row %d, Diagram Wave \"%s\")", Name_ijk, k, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							If(cmpstr(Type_ijk,Type_k,1)!=0)
								//types do not match
								Printf "Error: invalid type of socket argument[%d] (row %d, Diagram Wave \"%s\")", k, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//types match
							break
						Endswitch
					Endfor
				elseif(cmpstr(Kind_ij, "Module", 1)==0)
					String ModuleDef=IAFc_Module_Definition(Type_ij)
					//Verify Definition of the Module
					If(IAFc_VerifyModuleDefinition(ModuleDef)==0)
						//ill-defined
						Printf "Error: Module \"%s\" is ill-defined", Type_ij
						numErrors+=1
						break
					Endif
					//well-defined
					numArgs=str2num(StringFromList(0,ModuleDef))
					For(k=0;k<numArgs;k+=1)
						inout_k=StringFromList(k+1,ModuleDef)
						Type_k=StringFromList(numArgs+k+1,ModuleDef)
						Name_ijk=Diagram_i[j][k+3]
						Switch(IAFc_JudgeDataSocket(Type_k))
						Case 1:
							//data (input, not output)
							DataOriginIndex=IAFcu_GetDataOriginIndex(Name_ijk,currentFolder)
							If(DataOriginIndex==-1)
								//Data does not exist
								Printf "Error: argument[%d]=\"%s\" does not exist (row %d, Diagram Wave \"%s\")", k, Name_ijk, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//Data exists
							Type_ijk=DataOrigin[DataOriginIndex][0]
							If(cmpstr(Type_k,Type_ijk,1)!=0)
								//types do not match
								Printf "Error: invalid type of data argument[%d] (row %d, Diagram Wave \"%s\")", k, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//types match
							if(cmpstr(inout_k, "0", 1)==0)
								//input, do nothing
							elseif(cmpstr(inout_k, "1", 1)==0)
								//output, error
								Printf "Error: Module \"%s\" has output data", Type_ij
								numErrors+=1
							else
								//something strange
								Print("Unexpected error")
								numErrors+=1
							endif
							break
						Case 2:
							//socket
							if(cmpstr(inout_k, "0", 1)==0)
								//data-sending
								//find the type of the socket to receive the data
								Type_ijk=IAFcu_GetSocketType(Name_ijk)
								If(cmpstr(Type_ijk,"module not found", 1)==0)
									//Module Name_ijk does not exist
									Printf "Error: argument[%d]=\"%s\" does not exist (row %d, Diagram Wave \"%s\")", k, Name_ijk, j, DiagramWaveName
									numErrors+=1
									break
								Endif
								If(cmpstr(Type_ijk,"socket not found", 1)==0)
									//the Module does not have a socket
									Printf "Error: module \"%s\" in argument[%d] does not have a socket (row %d, Diagram Wave \"%s\")", Name_ijk, k, j, DiagramWaveName
									numErrors+=1
									break
								Endif
								If(cmpstr(Type_ijk,Type_k,1)!=0)
									//types do not match
									Printf "Error: invalid type of socket argument[%d] (row %d, Diagram Wave \"%s\")", k, j, DiagramWaveName
									numErrors+=1
									break
								Endif
								//types match -> ok
							elseif(cmpstr(inout_k, "2", 1)==0)
								//data-receiving
							else
								//something strange
								Print("Unexpected error")
								numErrors+=1
							endif
							break
						Endswitch
					Endfor
				elseif(cmpstr(Kind_ij, "Panel", 1)==0)
					String PanelDef=IAFc_Panel_Definition(Type_ij)
					//Verify Definition of the Panel
					If(IAFc_VerifyPanelDefinition(PanelDef)==0)
						//ill-defined
						Printf "Error: Panel \"%s\" is ill-defined", Type_ij
						numErrors+=1
						break
					Endif
					//well-defined
					numArgs=str2num(StringFromList(0,PanelDef))
					For(k=0;k<numArgs;k+=1)
						inout_k=StringFromList(k+1,PanelDef)
						Type_k=StringFromList(numArgs+k+1,PanelDef)
						Name_ijk=Diagram_i[j][k+3]
						Switch(IAFc_JudgeDataSocket(Type_k))
						Case 1:
							//data (input, not output)
							DataOriginIndex=IAFcu_GetDataOriginIndex(Name_ijk,currentFolder)
							If(DataOriginIndex==-1)
								//Data does not exist
								Printf "Error: argument[%d]=\"%s\" does not exist (row %d, Diagram Wave \"%s\")", k, Name_ijk, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//Data exists
							Type_ijk=DataOrigin[DataOriginIndex][0]
							If(cmpstr(Type_k,Type_ijk,1)!=0)
								//types do not match
								Printf "Error: invalid type of data argument[%d] (row %d, Diagram Wave \"%s\")", k, j, DiagramWaveName
								numErrors+=1
								break
							Endif
							//types match
							if(cmpstr(inout_k, "0", 1)==0)
								//input, do nothing
							elseif(cmpstr(inout_k, "1", 1)==0)
								//output, error
								Printf "Error: Panel \"%s\" has output data", Type_ij
								numErrors+=1
							else
								//something strange
								Print("Unexpected error")
								numErrors+=1
							endif
							break
						Case 2:
							//socket
							Printf "Error: Panel \"%s\" has socket", Type_ij
							numErrors+=1
							break
						Endswitch
					Endfor
				else
					//never occur (already verified by IAFcu_VerifyKindType)
					Print("Unexpected error")
					numErrors+=1
				endif
			Else
				Printf "Skip row %d of Diagram Wave \"%s\" (Kind: \"%s\", Type: \"%s\" is ill-defined)", j, DiagramWaveName, Kind_ij, Type_ij
			Endif
		Endfor
	Endfor
	cd $currentFolder
	If(numErrors>0)
		Print(num2str(numErrors)+" Error(s) exist")
		return 0
	Endif
	//Create Descend
	cd "Configurations"
	Make/O/T/N=(numData,2) Descend
	Wave/T Descend=Descend
	Descend[][]=""
	cd $currentFolder
	cd "Diagrams"
	
	Descend[][0]=DataOrigin[p][1]
	String Data_i
	String DescendData, DescendFunctions, DescendModules, DescendFunctions_all
	String DescendData_new, DescendFunctions_new, DescendModules_new
	Variable numList
	For(i=0;i<numData;i+=1)
		Data_i=Descend[i][0]
		DescendFunctions_all=""
		
		DescendData=Data_i
		DescendFunctions=""
		DescendModules=""
		
		DescendData_new=""
		DescendFunctions_new=""
		DescendModules_new=""
		
		do
			//Data -> Function or Module
			DescendData_new=""
			DescendFunctions_new=""
			DescendModules_new=""
			numList=ItemsInList(DescendData)
			For(j=0;j<numList;j+=1)
				DescendFunctions_new=DescendFunctions_new+IAFcu_InputParts_Function(StringFromList(j,DescendData))
				DescendModules_new=DescendModules_new+IAFcu_InputParts_Module(StringFromList(j,DescendData))
			Endfor
			//Function -> Data
			numList=ItemsInList(DescendFunctions)
			For(j=0;j<numList;j+=1)
				DescendData_new=DescendData_new+IAFcu_OutputParts(StringFromList(j,DescendFunctions))
			Endfor
			//Module -> Function or Module
			numList=ItemsInList(DescendModules)
			For(j=0;j<numList;j+=1)
				DescendFunctions_new=DescendFunctions_new+IAFcu_InputParts_Function(StringFromList(j,DescendModules))
				DescendModules_new=DescendMOdules_new+IAFcu_InputParts_Module(StringFromList(j,DescendModules))
			Endfor
			
			DescendFunctions_all=IAFcu_RemoveDuplicity(DescendFunctions_all+DescendFunctions)
			
			DescendData=IAFcu_RemoveDuplicity(DescendData_new)
			DescendFunctions=IAFcu_RemoveDuplicity(DescendFunctions_new)
			DescendModules=IAFcu_RemoveDuplicity(DescendModules_new)
			
			If(cmpstr(DescendData,"",1)==0 && cmpstr(DescendFunctions,"",1)==0 && cmpstr(DescendModules,"",1)==0)
				break
			Endif
		while(1)
		Descend[i][1]=DescendFunctions_all
	Endfor

	//Create Ascend
	cd $currentFolder
	cd "Configurations"
	Make/O/T/N=(numFunctions,2) Ascend
	Wave/T Ascend=Ascend
	Ascend[][]=""
	cd $currentFolder
	cd "Diagrams"

	index=0
	//list two-dimensional text waves in Diagrams folder
	For(i=0;i<numWaves;i+=1)
		DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		WaveSize_i=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize_i;j+=1)
			Kind_ij=Diagram_i[j][0]
			Type_ij=Diagram_i[j][1]
			Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Function",1)==0)
				Ascend[index][0]=Name_ij
				For(k=0;k<numData;k+=1)
					If(WhichListItem(Name_ij,Descend[k][1])!=-1)
						Ascend[index][1]=AddListItem(Descend[k][0],Ascend[index][1])
					Endif
				Endfor
				index+=1
			Endif
		Endfor
	Endfor

	cd $currentFolder
End

//get index of Data in DataOrigin (use first and second column)
//suppose currentFolder="Diagrams"
Function IAFcu_GetDataOriginIndex(name,currentFolder)
	String name,currentFolder
	cd $currentFolder
	cd "Configurations"
	Wave/T DataOrigin=DataOrigin
	cd $currentFolder
	cd "Diagrams"
	Variable numData=DimSize(DataOrigin,0)
	Variable i
	For(i=0;i<numData;i+=1)
		If(cmpstr(DataOrigin[i][1],name,1)==0)
			return i
		Endif
	Endfor
	return -1
End

//find the type of socket to receive the data
//suppose currentFolder="Diagrams"
Function/S IAFcu_GetSocketType(name)
	String name
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i,j
	For(i=0;i<numWaves;i+=1)
		String DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		Variable WaveSize=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize;j+=1)
			String Kind_ij=Diagram_i[j][0]
			String Type_ij=Diagram_i[j][1]
			String Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Name_ij,name,1)==0)
				String ModuleDef=IAFc_Module_definition(Type_ij)
				Variable numArgs=str2num(StringFromList(0,ModuleDef))
				Variable k
				For(k=0;k<numArgs;k+=1)
					If(cmpstr(StringFromList(k+1,ModuleDef),"2",1)==0)
						return StringFromList(numArgs+k+1,ModuleDef)
					Endif
				Endfor
				return "socket not found"
			Endif
		Endfor
	Endfor
	return "module not found"
End

//find Functions use "name" as input
Function/S IAFcu_InputParts_Function(name)
	String name
	String FunctionList=""
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i,j,k
	For(i=0;i<numWaves;i+=1)
		String DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		Variable WaveSize=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize;j+=1)
			String Kind_ij=Diagram_i[j][0]
			String Type_ij=Diagram_i[j][1]
			String Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Function",1)==0)
				String FuncDef=IAFc_Function_definition(Type_ij)
				Variable numArgs=str2num(StringFromList(0,FuncDef))
				For(k=0;k<numArgs;k+=1)
					If(cmpstr(Diagram_i[j][k+3],name,1)==0 && cmpstr(StringFromList(k+1,FuncDef),"0",1)==0)
						FunctionList=AddListItem(Name_ij,FunctionList)
						break
					Endif
				Endfor
			Endif
		Endfor
	Endfor
	return FunctionList
End

//find Modules use "name" as input
Function/S IAFcu_InputParts_Module(name)
	String name
	String ModuleList=""
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i,j,k
	For(i=0;i<numWaves;i+=1)
		String DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		Variable WaveSize=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize;j+=1)
			String Kind_ij=Diagram_i[j][0]
			String Type_ij=Diagram_i[j][1]
			String Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Module",1)==0)
				String ModuleDef=IAFc_Module_definition(Type_ij)
				Variable numArgs=str2num(StringFromList(0,ModuleDef))
				For(k=0;k<numArgs;k+=1)
					If(cmpstr(Diagram_i[j][k+3],name,1)==0 && cmpstr(StringFromList(k+1,ModuleDef),"0",1)==0)
						ModuleList=AddListItem(Name_ij,ModuleList)
						break
					Endif
				Endfor
			Endif
		Endfor
	Endfor
	return ModuleList
End

//find output of Function "name"
Function/S IAFcu_OutputParts(name)
	String name
	String DataList=""
	//list two-dimensional text waves in Diagrams folder
	String DiagramWaveList=WaveList("*",";","TEXT:1,DIMS:2")
	Variable numWaves=ItemsInList(DiagramWaveList)
	Variable i,j,k
	For(i=0;i<numWaves;i+=1)
		String DiagramWaveName=StringFromList(i,DiagramWaveList)
		Wave/T Diagram_i=$DiagramWaveName //i-th wave in the list
		Variable WaveSize=DimSize(Diagram_i,0)
		For(j=0;j<WaveSize;j+=1)
			String Kind_ij=Diagram_i[j][0]
			String Type_ij=Diagram_i[j][1]
			String Name_ij=Diagram_i[j][2]
			If(IAFc_VerifyKindType(Kind_ij,Type_ij) && cmpstr(Kind_ij,"Function",1)==0 && cmpstr(Name_ij,name,1)==0)
				String FuncDef=IAFc_Function_definition(Type_ij)
				Variable numArgs=str2num(StringFromList(0,FuncDef))
				For(k=0;k<numArgs;k+=1)
					If(cmpstr(StringFromList(k+1,FuncDef),"1",1)==0)
						DataList=AddListItem(Diagram_i[j][k+3],DataList)
					Endif
				Endfor
				return DataList
			Endif
		Endfor
	Endfor
	return ""
End

//remove duplicated items from list
Function/S IAFcu_RemoveDuplicity(list)
	String list
	String newList=""
	Variable numList=ItemsInList(list)
	Variable i
	String item_i
	For(i=0;i<numList;i+=1)
		item_i=StringFromList(i,list)
		If(WhichListItem(item_i,newList)==-1)
			newList=AddListItem(item_i,newList)
		Endif
	Endfor
	return newList
End