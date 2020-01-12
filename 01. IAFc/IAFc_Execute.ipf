#pragma rtGlobals=3		// Use modern global access method and strict wave access.

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

Function/S IAFf_Execute_Definition(FuncName)
	String FuncName
	String FuncFullName="IAFf_"+FuncName+"_Definition"
	FUNCREF IAFf_Prototype_Definition f = $FuncFullName
	return f()
End

Function/S IAFm_Execute_Definition(ModuleName)
	String ModuleName
	String ModuleFullName="IAFm_"+ModuleName+"_Definition"
	FUNCREF IAFm_Prototype_Definition f = $ModuleFullName
	return f()
End