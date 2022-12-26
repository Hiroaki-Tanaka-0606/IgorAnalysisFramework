#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function ColorTable: create color table
Function/S IAFf_ColorTable_Definition()
	return "6;0;0;0;0;0;1;Wave2D;Variable;Variable;Variable;Variable;Wave2D"
End

Function IAFf_ColorTable(argumentList)
	String argumentList
	
	//0th argument: relative gradation wave
	//[][0]: relative coordinate
	//[][1]: R
	//[][2]: G
	//[][3]: B
	String relGradationArg=StringFromList(0,argumentList)
	
	//1st argument: intensity min
	String minIntensityArg=StringFromList(1,argumentList)
	
	//2nd argument: intensity max
	String maxIntensityArg=StringFromList(2,argumentList)
	
	//3rd argument: gamma value
	String gammaValueArg=StringFromList(3,argumentList)
	
	//4th argument: number of steps
	String numStepsArg=StringFromList(4,argumentList)
	
	//5th argument: output colorTable
	String colorTableArg=StringFromList(5,argumentList)
	
	Wave/D relGradation=$relGradationArg
	NVAR minIntensity=$minIntensityArg
	NVAR maxIntensity=$maxIntensityArg
	NVAR gammaValue=$gammaValueArg
	NVAR numSteps=$numStepsArg
	
	//validation
	if(gammaValue<0)
		Print("ColorTable Error: gamma must be positive")
	Endif
	
	//gradation normalized to [0,1]
	String normGradationPath="::TempData:ColorTable_grad"
	Duplicate/O $relGradationArg $normGradationPath
	Wave/D normGradation=$normGradationPath
	
	//normalization and validation
	Variable gradLength=DimSize(normGradation,0)
	Variable relCoordStart=normGradation[0][0]
	Variable relCoordEnd=normGradation[gradLength-1][0]
	Variable i
	normGradation[][0]=(normGradation[p][0]-relCoordStart)/(relCoordEnd-relCoordStart)
	For(i=0;i<gradLength-1;i+=1)
		If(normGradation[i][0]>normGradation[i+1][0])
			Print("ColorTable Error: relative coordinate order")
		Endif
	Endfor		
	
	Make/O/D/N=(numSteps+1,3) $colorTableArg
	Wave/D colorTable=$colorTableArg
	SetScale/I x, minIntensity, maxIntensity, colorTable
	
	Variable j,k
	For(i=0;i<=numSteps;i+=1)
		//coordinate corrected by power series of gamma
		Variable normCoordinate=(i*1.0/numSteps)^gammaValue
		For(j=0;j<gradLength-1;j+=1)
			If(normGradation[j][0] <= normCoordinate && normCoordinate <= normGradation[j+1][0])
				For(k=0;k<3;k+=1)
					colorTable[i][k]=normGradation[j][k+1]*(normGradation[j+1][0]-normCoordinate)
					colorTable[i][k]+=normGradation[j+1][k+1]*(normCoordinate-normGradation[j][0])
					colorTable[i][k]/=(normGradation[j+1][0]-normGradation[j][0])
				Endfor
				continue
			Endif
		Endfor
	Endfor
	
	KillWaves normGradation
	
End

//Function IntRange2D: get intensity range of 2D wave
Function/S IAFf_IntRange2D_Definition()
	return "3;0;1;1;Wave2D;Variable;Variable"
End

Function IAFf_IntRange2D(argumentList)
	String argumentList
	
	//0th argument: input 2D wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: min
	String minIntensityArg=StringFromList(1,argumentList)
	
	//2nd argument: max
	String maxIntensityArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	
	Variable i,j
	Variable minIntensity=NaN
	Variable maxIntensity=NaN
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			if(numtype(input[i][j])!=0)
				continue
			Endif
			if(input[i][j]<minIntensity || numtype(minIntensity)!=0)
				minIntensity=input[i][j]
			Endif
			if(input[i][j]>maxIntensity || numtype(maxIntensity)!=0)
				maxIntensity=input[i][j]
			Endif
		Endfor
	Endfor
	
	Variable/G $minIntensityArg=minIntensity
	Variable/G $maxIntensityArg=maxIntensity
End

//Panel ColorTableCtrl: control min, max, gamma, step
Function/S IAFp_ColorTableCtrl_Definition()
	return "6;0;0;0;0;0;0;Variable;Variable;Variable;Variable;Variable;Variable"
End	

Function IAFp_ColorTableCtrl(argumentList,PanelName,PanelTitle)
	String argumentList,PanelName,PanelTitle
	
	//0th argument: data min (as reference)
	String dataMinArg=StringFromList(0,argumentList)
	
	//1st argument: data max (as reference)
	String dataMaxArg=StringFromList(1,argumentList)
	
	//2nd argument: colortable min
	String colorMinArg=StringFromList(2,argumentList)
	
	//3rd argument: colorTable max
	String colorMaxArg=StringFromList(3,argumentList)
	
	//4th argument: gamma
	String gammaValueArg=StringFromList(4,argumentList)
	
	//5th argument: step
	String numStepsArg=StringFromList(5,argumentList)
	
		
	//create a panel
	NewPanel/K=1/W=(0,0,400,90) as PanelTitle
		
	cd ::
	String gPanelName="IAF_"+PanelName+"_Name"
	String/G $gPanelName=S_Name
	String ParentPanelName=S_Name
	cd Data
	
	//put a setvariable
	IAFcu_DrawSetVariable(0,0,"Data Min",6,dataMinArg,0,0,-inf,inf,0)
	IAFcu_DrawSetVariable(200,0,"Data Max",6,dataMaxArg,0,0,-inf,inf,0)
	
	IAFcu_DrawSetVariable(0,30,"Color Min",6,colorMinArg,1,1,-inf,inf,0)
	IAFcu_DrawSetVariable(200,30,"Color Max",6,colorMaxArg,1,1,-inf,inf,0)
	
	
	IAFcu_DrawSetVariable(0,60,"Gamma",6,gammaValueArg,1,1,0,inf,0)
	IAFcu_DrawSetVariable(200,60,"Steps",6,numStepsArg,1,1,0,inf,1)

End