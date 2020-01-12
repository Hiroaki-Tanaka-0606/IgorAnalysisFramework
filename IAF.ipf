#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "IAFc_SetUp"
#include "IAFc_ConfDep"


Menu "IAF"
	"SetUp", IAFc_SetUp(-1)
	"ConfigureName", IAFc_ConfigureNames()
	"ConfigureDependency", IAFc_ConfigureDependency()
End
