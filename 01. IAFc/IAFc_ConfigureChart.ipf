#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "IAFcu_VerifyKindType"

//IAFc_ConfigureChart: create ChartIndex & ChartPosition in folder "Configurations"
Function IAFc_ConfigureChart()
	Print("[IAFc_ConfigureChart]")
	
	String currentFolder=GetDataFolder(1)
	
	
	
	cd $currentFolder

End