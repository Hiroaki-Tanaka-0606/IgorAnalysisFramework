#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_LoadTemplate: execute IAFt_#{PanelType}
Function IAFc_Template_Prototype(argumentList)
	String argumentList
	Print("Error: No such template")
	return 0
End

Function IAFc_LoadTemplate(TemplateType, argumentList)
	String TemplateType, argumentList
	
	If(!DataFolderExists("Diagrams"))
		Print("Error: folder Diagrams does not exist")
		return 0
	Endif
	
	cd Diagrams
	String FuncFullName="IAFt_"+TemplateType
	FUNCREF IAFc_Template_Prototype f = $FuncFullName
	Variable result=f(argumentList)
	cd ::
	If(result==1)
		IAFc_CreateData()
		IAFc_ConfigureDependency()
		IAFc_ConfigureChart()
		IAFc_CallChart()
		IAFc_CreateData()
		IAFc_ExecuteAll()
	Endif
End

Function IAFc_LoadTemplateDialog()
	String TemplateType
	String argumentList
	Prompt TemplateType, "Template"
	Prompt argumentList, "List of arguments"
	DoPrompt "Input Template type and list of arguments", TemplateType, argumentList
	If(V_Flag==0)
		IAFc_LoadTemplate(TemplateType,argumentList)
	Endif
End
		

