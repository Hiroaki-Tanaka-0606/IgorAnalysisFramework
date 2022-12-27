#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//IAFc_SetUp: create necessary folders, waves
//Usage:
//numArgs: estimated max number of arguments of Modules, Functions
//if numArgs<0, default value (10) is used for setup
Function IAFc_SetUp(numArgs)
	Variable numArgs
	
	Print("[IAFc_SetUp]")
	If(numArgs<0)
		numArgs=10
	Endif
	numArgs=round(numArgs)
	
	String currentFolder=GetDataFolder(1)
	Print("Folder path: "+currentFolder)
	Print("Number of arguments: "+num2str(numArgs))
	
	//create folders
	IAFu_createFolder("Diagrams")
	IAFu_createFolder("Data")
	IAFu_createFolder("Configurations")
	IAFu_createFolder("TempData")
	
	//create sample of Diamgram wave named "Diagram0"
	//if it exists, do nothing
	cd Diagrams
	Wave/T d0=Diagram0
	If(WaveExists(d0)==0)
		Print("Create 2D text Wave \"Diagram0\" in folder Diagrams")
		Make/T/N=(1,3+numArgs) Diagram0
	Endif
	
	cd $currentFolder
End

//IAFu_createFolder: check existence and create folder in the current folder
Function IAFu_createFolder(folderName)
	String folderName
	If(DataFolderExists(folderName))
		Print("Warning: Data Folder \""+folderName+"\" already exists.")
		return 0
	Else
		NewDataFolder $folderName
	Endif
End