#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "IAF_Viewer"
	"View it", IAFc_Viewit()
	"Update it", IAFc_Updateit()
End

//Make Viewer of the selected wave(s)
Function IAFc_Viewit()
	String wavepath=GetBrowserSelection(0)
	Wave targetWave=$wavepath
	if(WaveExists(targetWave))
		Variable dim=WaveDims(targetWave)
		Variable waveType=NumberByKey("NUMTYPE", WaveInfo(targetWave,0))
	else
		print("Error: Selected object is not a wave")
		return 0
	endif
	
	print(num2str(dim)+" dimensional wave is selected")
	if(dim<2 || dim>4)
		print("Error: only 2, 3, 4, dimsional waves are valid")
		return 0
	endif
	
	print("NUMTYPE is "+num2str(waveType))
	if(waveType<1 || waveType>=256)
		print("Error: Selected wave is not a number wave")
		return 0
	Endif
	
	String CurrentDirectory=GetDataFolder(1)
	cd root:
	NVAR viewerIndex=IAF_ViewerIndex
	if(NVAR_Exists(viewerIndex)==0)
		Variable/G IAF_ViewerIndex=-1
		NVAR viewerIndex=IAF_ViewerIndex
	Endif
	viewerIndex+=1
	NewDataFolder/O/S $("Viewer"+num2str(viewerIndex))
	
	IAFc_setup(-1)
	Wave/T Diagram=:Diagrams:Diagram0
	Redimension/N=(dim+2, 10) Diagram
	Diagram[0][0]="Data"; Diagram[0][1]="String"; Diagram[0][2]="WavePath"
	Diagram[1][0]="Data"; Diagram[1][1]="Wave"+num2str(dim)+"D"; Diagram[1][2]="WaveObj"
	Diagram[2][0]="Function"; Diagram[2][1]="LoadWave"+num2str(dim)+"D"; Diagram[2][2]="LW"; Diagram[2][3]="WavePath"; Diagram[2][4]="WaveObj"
	if(dim==2)
		Diagram[3][0]="Data"; Diagram[3][1]="String"; Diagram[3][2]="ALabel"
	elseif(dim==3)
		Diagram[3][0]="Data"; Diagram[3][1]="String"; Diagram[3][2]="AxLabel"
		Diagram[4][0]="Data"; Diagram[4][1]="String"; Diagram[4][2]="AyLabel"
	else
		Diagram[3][0]="Data"; Diagram[3][1]="String"; Diagram[3][2]="ALabel"
		Diagram[4][0]="Data"; Diagram[4][1]="String"; Diagram[4][2]="XLabel"
		Diagram[5][0]="Data"; Diagram[5][1]="String"; Diagram[5][2]="YLabel"
	endif
	
	IAFc_CreateData()
	cd :Data
	String TemplateType, argumentList
	if(dim==2)
		SVAR al=ALabel; al="Angle (deg)"
		TemplateType="2DViewer"
		argumentList="Viewer;WaveObj;ALabel"
	elseif(dim==3)
		SVAR axl=AxLabel; axl="XAngle (deg)"
		SVAR ayl=AyLabel; ayl="YAngle (deg)"
		TemplateType="3DViewer"
		argumentList="Viewer;WaveObj;AxLabel;AyLabel"
	else
		SVAR al=ALabel; al="Angle (deg)"
		SVAR xl=XLabel; xl="X Position"
		SVAR yl=yLabel; yl="Y Position"
		TemplateType="4DViewer"
		argumentList="Viewer;WaveObj;ALabel;XLabel;YLabel"
	endif
	SVAR wp=WavePath; wp=ReplaceString("root:", wavepath, ":")
	cd ::Diagrams
	
	String FuncFullName="IAFt_"+TemplateType
	FUNCREF IAFc_Template_Prototype f = $FuncFullName
	Variable result=f(argumentList)
	cd ::
	If(result!=1)
		print("Error in LoadTemplate")
		return 0
	Endif
	IAFc_CreateData()
	IAFc_ConfigureDependency()
	IAFc_ConfigureChart()
	IAFc_CreateData()
	IAFc_ExecuteAll()
	IAFc_CallPanel("Viewer")
	
	cd $CurrentDirectory
End

Function IAFc_Updateit()
	String currentFolder=getDataFolder(1)
		
	Execute "GetWindow kwTopWin,activeSW"
	//if there is no subwindow, SWpath is the name of the window
	SVAR SWpath=S_value
		
	If(!SVAR_exists(SWpath))
		return 0
	Endif
		
	//Get Parent window name
	String windowName=StringFromList(0,SWpath,"#")
		
	//Get Parent window title
	Execute "GetWindow "+windowName+",title"
	SVAR winTitle=S_value
	If(!SVAR_exists(winTitle))
		return 0
	Endif
	
	
	//winTitle="panelName in DataFolder"
	Variable inIndex=strsearch(winTitle," in ",0)
	If(inIndex==-1)
		return 0
	Endif
	String DataFolder=winTitle[inIndex+4,strlen(winTitle)-1]
	
	cd $DataFolder
	IAFc_ExecuteAll()
	
	cd $CurrentFolder

End