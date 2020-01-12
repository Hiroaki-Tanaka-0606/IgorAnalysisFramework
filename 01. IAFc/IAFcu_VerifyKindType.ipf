#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFcu_VerifyKindType: verify a pair of Kind and Type
//Usage:
//kind, type: kind, type of a part
//Return 1 when valid, 0 when invalid
Function IAFcu_VerifyKindType(kind,type)
	String kind, type
	
	StrSwitch(kind)
	Case "Data":
		String DataTypeList="Variable;String;Wave1D;Wave2D;Wave3D;TextWave"
		If(WhichListItem(type,DataTypeList)==-1)
			return 0 //invalid type
		Else
			return 1 //valid type
		Endif
		break
	Case "Function":
		Variable FuncDefinition=Exists("IAFf_"+type+"_Definition")
		Variable FuncExecution=Exists("IAFf_"+type)
		If(FuncDefinition==6 && FuncExecution==6)
			return 1 //both definition and execution exist
		Else
			return 0 //not both exist
		Endif
		break
	Case "Module":
		Variable ModuleDefinition=Exists("IAFm_"+type+"_Definition")
		Variable ModuleExecution=Exists("IAFm_"+type)
		//In the verification, we don't check existence of IAFm_[ModuleName]_Format
		If(ModuleDefinition==6 && ModuleExecution==6)
			return 1 //both definition and execution exist
		Else
			return 0 //not both exist
		Endif
		break
	Case "Panel":
		//under construction
		break
	Default:
		return 0
	Endswitch
	
End

//judge whether the type is data or socket
//return 1 when data, 2 when socket, 0 otherwise
Function IAFcu_JudgeDataSocket(type)
	String type
	
	String DataTypeList="Variable;String;Wave1D;Wave2D;Wave3D;TextWave"		
	String SocketTypeList="Coordinate1D;Coordinate2D;Coordinate3D;Index1D;Index2D;Index3D"
	
	If(WhichListItem(type, DataTypeList)!=-1)
		return 1
	Elseif(WhichListItem(type, SocketTypeList)!=-1)
		return 2
	Else
		return 0
	Endif
End

//Verify Definition of the Function
//return 0 when not ok, 1 when ok
Function IAFcu_VerifyFunctionDefinition(FuncDef)
	String FuncDef
	Variable i
	Variable numArgs=str2num(StringFromList(0,FuncDef))
	Variable inout_i
	String Type_i
	For(i=0;i<numArgs;i+=1)
		inout_i=str2num(StringFromList(i+1,FuncDef))
		Type_i=StringFromList(numArgs+i+1,FuncDef)
		Switch(IAFcu_JudgeDataSocket(Type_i))
		Case 1:
			//data
			//input or output
			If(inout_i!=0 && inout_i!=1)
				return 0
			Endif
			break
		Case 2:
			//socket
			//input (data-receiving socket does not exist in Function)
			If(inout_i!=0)
				return 0
			Endif
			break
		Default:
			//otherwise
			return 0
			break
		Endswitch
	Endfor
	return 1
End


//Verify Definition of the Module
//return 0 when not ok, 1 when ok
Function IAFcu_VerifyModuleDefinition(ModuleDef)
	String ModuleDef
	Variable i
	Variable numArgs=str2num(StringFromList(0,ModuleDef))
	Variable inout_i
	String Type_i
	Variable numReceiveSocket=0
	For(i=0;i<numArgs;i+=1)
		inout_i=str2num(StringFromList(i+1,ModuleDef))
		Type_i=StringFromList(numArgs+i+1,ModuleDef)
		Switch(IAFcu_JudgeDataSocket(Type_i))
		Case 1:
			//data
			//input (data output does not exist in Module
			If(inout_i!=0)
				return 0
			Endif
			break
		Case 2:
			//socket
			//input or data-receiving
			If(inout_i!=0 && inout_i!=2)
				return 0
			Endif
			If(inout_i==2)
				numReceiveSocket+=1
			Endif
			break
		Default:
			//otherwise
			return 0
			break
		Endswitch
	Endfor
	If(numReceiveSocket==1)
		return 1
	Else
		return 0
	Endif
End