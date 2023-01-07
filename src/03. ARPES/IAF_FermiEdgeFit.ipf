#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function FermiEdgeFit: fit the input wave by Fermi edge convolved with gaussian fluctuation

//Fitting function (same as InoMacro Ver3.124 and IgorMacro/01. Fundamental/FermiEdgeFitting.ipf in https://github.com/Hiroaki-Tanaka-0606)
//=p[0]*convolve((1+p[1]x)/(exp(beta(p[6])*x)+1),gaussian(p[5]))+p[2]+p[3]*x
//x=energy-p[4]

//Output (6th argument): fitting parameters
//p[0]: Scale of Intensity
//p[1]: Slope of Intensity [/eV]
//p[2]: Background
//p[3]: Slope of Background [/eV]
//p[4]: Ef [eV]
//p[5]: sigma(FWHM) [eV]

//p[6] is the temperature, given as the input parameter

Function/S IAFf_FermiEdgeFit_Definition()
	return "8;0;0;0;0;0;0;1;1;Wave1D;Variable;Variable;Variable;Variable;String;Wave1D;Wave1D"
End

Function IAFf_FermiEdgeFit(argumentList)
	String argumentList
	
	//0th argument (input): wave 
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (input): initial value of Ef [eV]
	String initialEfArg=StringFromList(1,argumentList)
	
	//2nd argument (input): fitting range (min, including itself) [index]
	String fitMinArg=StringFromList(2,argumentList)
	
	//3rd argument (input): fitting range (max, including itself) [index]
	String fitMaxArg=StringFromList(3,argumentList)
	
	//4th argument (input): temperature [K]
	String temperatureArg=StringFromList(4,argumentList)
	
	//5th argument (input): holdParams 
	// a string of 6 letters ("0" or "1"), which determines each parameter is hold constant ("1") or not ("0")
	String holdParamsArg=StringFromList(5,argumentList)
	
	//6th argument (output): fitting parameters
	String paramsArg=StringFromList(6,argumentList)
	
	//7th argument (output): fitted curve
	String fitCurveArg=StringFromList(7,argumentList)
	
	Wave/D input=$inputArg
	NVAR initialEf=$initialEfArg
	NVAR fitMin=$fitMinArg
	NVAR fitMax=$fitMaxArg
	NVAR temperature=$temperatureArg
	SVAR holdParams=$holdParamsArg
	
	Make/O/D/N=6 $paramsArg
	Wave/D params=$paramsArg

	//set initial values to a parameters wave
	params[0]=input[fitMin] // intensity
	params[1]=0 //slope of intensity
	params[2]=0 //background
	params[3]=0 //slope of background
	params[4]=initialEf //Ef
	params[5]=DimDelta(input,0)*5 //FWHM
	
	//share the value of temperature by a global variable in TempData
	cd ::TempData
	//Variable/G temperature=temperature
	Variable/G FEF_temperature=temperature
	
	//duplicate the input in the range of [fitMin, fitMax]
	Duplicate/O/R=[fitMin,fitMax] input yTemp
	FuncFit/H=(holdParams)/Q/W=2/N IAFu_EfTrialFunc params yTemp
	
	//go back to Data folder
	cd ::Data
	
	//output fitCurve
	Duplicate/O input $fitCurveArg
	Wave/D fitCurve=$fitCurveArg
	IAFu_EfTrialFunc(params, fitCurve,fitCurve)
End

Function IAFu_EfTrialFunc(params, ywave, xwave): FitFunc
	Wave/D params, ywave, xwave
	Variable gaussianRange=5

	Variable delta=DimDelta(ywave,0)
	Variable size=DimSize(ywave,0)
	Variable offset=DimOffset(ywave,0)
	cd ::TempData
	NVAR temperature=FEF_temperature
	cd ::Data
	Variable beta=11604.53/temperature //1/k_B T
	
	params[5]=abs(params[5])
	
	Variable gaussianWidth=IAFu_GaussianWave(params[5]/(2*sqrt(2*ln(2))*delta),gaussianRange,"tempGaussian")
	Variable xStart=offset-gaussianWidth*delta
	Make/O/D/N=(size+2*gaussianWidth) $"tempTrial"
	SetScale/P x xStart,delta,$"tempTrial"
	
	Wave/D tempTrial=$"tempTrial"
	tempTrial=(1+(x-params[4])*params[1])/(1+exp(beta*(x-params[4])))
	Convolve/A $"tempGaussian" tempTrial
	tempTrial*=params[0]
	tempTrial+=params[2]+params[3]*(x-params[4])
	
	//set to ywave
	ywave[]=tempTrial[gaussianWidth+p]
	
	KillWaves tempTrial
End

Function IAFu_GaussianWave(sigma, maxRange, waveName)
	//sigma: standard deviation [index]
	Variable sigma, maxRange
	String waveName
	//hwpoints: half number of points
	Variable hwpoints=ceil(sigma*maxRange)
	Variable xrange=hwpoints/sigma
	Make/O/D/N=(2*hwpoints+1) $waveName
	Wave/D gaussian=$waveName
	SetScale/I x -hwpoints, hwpoints, $waveName
	Make/O/D gaussianParams={0,1/(sqrt(2*pi)*sigma),0,sqrt(2)*sigma}
	
	gaussian=Gauss1D(gaussianParams,x)
	
	return hwpoints
End