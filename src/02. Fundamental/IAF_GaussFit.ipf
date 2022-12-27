#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function GaussFit: fit the input wave by multiple Gauss functions

//=p[0]+p[1]*x+Gauss(x-p[3], p[2])*p[4]+Gauss(x-p[5], p[2])*p[6]+...

//Output (6th argument): fitting parameters
//param[0]: Background
//param[1]: Slope of Background [/eV]
//param[2]: gaussian width [eV]
//param[3], param[4]: center and height of gaussian 1
//param[5], param[6]: those of gaussian 2

Function/S IAFf_GaussFit_Definition()
	return "8;0;0;0;0;0;0;1;1;Wave1D;Variable;Variable;Wave1D;Variable;String;Wave1D;Wave1D"
End

Function IAFf_GaussFit(argumentList)
	String argumentList
	
	//0th argument: wave 
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: fitting range (min, including itself) [index]
	String fitMinArg=StringFromList(1,argumentList)
	
	//2nd argument: fitting range (max, including itself) [index]
	String fitMaxArg=StringFromList(2,argumentList)
	
	//3rd argument: initial gaussian info
	String peakInfoArg=StringFromList(3, argumentList)
	
	//4th argument: initial sigma [eV]
	String sigmaArg=StringFromList(4, argumentList)
	
	//5th argument: holdParams 
	// a string of letters ("0" or "1"), which determines each parameter is hold constant ("1") or not ("0")
	String holdParamsArg=StringFromList(5,argumentList)
	
	//6th argument: fitting parameters
	String paramsArg=StringFromList(6,argumentList)
	
	//7th argument: fitted curve
	String fitCurveArg=StringFromList(7,argumentList)
	
	Wave/D input=$inputArg
	NVAR fitMin=$fitMinArg
	NVAR fitMax=$fitMaxArg
	NVAR sigma=$sigmaArg
	SVAR holdParams=$holdParamsArg
	
	Wave/D peakInfo=$peakInfoArg
	Variable peakInfoSize=dimsize(peakInfo, 0)
	if(mod(peakInfoSize, 2)!=0)
		print("PeakInfo should contain even numbers of paramters")
		print(peakInfoSize)
		return 0
	endif
	
	variable validPeakSize=0
	
	Variable i
	for(i=0; i<peakInfoSize; i+=2)
		if(peakInfo[i+1]>0)
			validPeakSize+=1
		endif
	endfor
	
	cd ::TempData
	Make/O/D/N=(validPeakSize*2) tempPeakInfo
	Wave/D peakInfo2=tempPeakInfo
	
	variable j=0
	for(i=0; i<peakInfoSize; i+=2)
		if(peakInfo[i+1]>0)
			peakInfo2[j]=peakInfo[i]
			peakInfo2[j+1]=peakInfo[i+1]
			j+=2
		endif
	endfor
	cd ::Data
	
	// set the initial values
	Make/O/D/N=(3+2*validPeakSize) $paramsArg
	Wave/D params=$paramsArg
	params[0]=0 //background
	params[1]=0 //slope of background
	params[2]=sigma // gaussian width
	for(i=0; i<validPeakSize; i+=1)
		params[3+2*i]=peakInfo2[2*i]
		params[4+2*i]=peakInfo2[2*i+1]
	endfor
		
	//duplicate the input in the range of [fitMin, fitMax]
	Duplicate/O/R=[fitMin,fitMax] input yTemp
	FuncFit/H=(holdParams)/Q/W=2/N IAFu_GaussTrialFunc params yTemp
	
	killwaves peakInfo2
	
	//output fitCurve
	Duplicate/O input $fitCurveArg
	Wave/D fitCurve=$fitCurveArg
	fitCurve[]=IAFu_GaussTrialFunc(params, x)
End

Function IAFu_GaussTrialFunc(params, x): FitFunc
	Wave/D params
	Variable x
	variable paramsSize=dimsize(params, 0)
	variable ret=params[0]+params[1]*x
	
	variable sigma=params[2]
	
	variable i
	for(i=3; i<paramsSize; i+=2)
		variable center=params[i]
		variable height=params[i+1]
		
		ret+=height*exp(-((x-center)/sigma)^2/2)
	endfor
	
	return ret
End
