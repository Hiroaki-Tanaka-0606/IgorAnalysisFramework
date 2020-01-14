#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "IAFc_SetUp"
#include "IAFc_ConfDep"
#include "IAFc_ConfChart"
#include "IAFc_DrawChart"

Menu "IAF"
	"SetUp", IAFc_SetUp(-1)
	"ConfigureName", IAFc_ConfigureNames()
	"ConfigureDependency", IAFc_ConfigureDependency()
	"ConfigureChart", IAFc_ConfigureChart()
	"CallChart", IAFc_CallChart()
End
