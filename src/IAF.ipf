#pragma rtGlobals=3		// Use modern global access method and strict wave access.


#include "IAFc_CleanData"
#include "IAFc_ConfChart"
#include "IAFc_ConfDep"
#include "IAFc_CreateData"
#include "IAFc_DrawChart"
#include "IAFc_DrawPanel"
#include "IAFc_Execute"
#include "IAFc_LoadTemplate"
#include "IAFc_SetUp"
#include "IAFc_VerifyKindType"

#include "IAF_Fundamental"

Menu "IAF"
	"SetUp", IAFc_SetUp(-1)
	"ConfigureNames", IAFc_ConfigureNames()
	"ConfigureDependency", IAFc_ConfigureDependency()
	"ConfigureChart", IAFc_ConfigureChart()
	"CallChart", IAFc_CallChart()
	"CallPanel", IAFc_CallPanelDialog()
	"ReCallPanel", IAFc_ReCallPanelDialog()
	"ExecuteAll", IAFc_ExecuteAll()
	"CreateData", IAFc_CreateData()
	"LoadTemplate", IAFc_LoadTemplateDialog()
	"CleanData", IAFc_CleanData()
End
