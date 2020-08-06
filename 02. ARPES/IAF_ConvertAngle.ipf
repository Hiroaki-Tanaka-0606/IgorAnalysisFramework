#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module ConvAngle2D: convert angle to momentum
//list of (E,k) is givne through the socket
//E: Energy (<0) with 0 being set to Ef
//k: momentum (A^-1)
//
//Energy of photoelectron: Eph=Eph_Ef+E
//Momentum of phoelectron in vacuum: Eph=(hbar Kph)^2/2me <=> Kph=sqrt(2me Eph)/hbar
//Angle corresponding to momentum k: Kph sin(theta-theta0)=k <=> theta=theta0+asin(k/Kph)

//physical constants from https://physics.nist.gov

Function/S IAFm_ConvAngle2D_Definition()
	return "4;0;0;0;2;Variable;Variable;Coordinate2D;Coordinate2D"
End	

Function/S IAFm_ConvAngle2D(argumentList)
	String argumentList
	
	//0th argument: hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: origin of theta (deg)
	String theta0Arg=StringFromList(1,argumentList)
	
	//2nd argument: coordinate2D socket (E-deg)
	String EdegSocketName=StringFromList(2,argumentList)
	
	//3rd argument: coordinate list passed through coordinate2D socket(E-k)
	String EkListArg=StringFromList(3,argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR theta0=$theta0Arg
	Wave/D EkList=$EkListArg
	
	Variable listSize=DimSize(EkList,0)
	
	String inputPath="::TempData:ConvertAngle2D_Input"
	Duplicate/O EkList $inputPath
	Wave/D input=$inputPath
		
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()
	For(i=0;i<listSize;i+=1)
		Variable Kph=sqrt(Eph_Ef+input[i][0])*E2kConstant
		input[i][1]=theta0+(180.0/pi)*asin(input[i][1]/Kph)
	Endfor
	
	return IAFc_CallSocket(EdegSocketName, inputPath)
End

//calculate sqrt(2me)/hbar part
//    Kph/(m-1) = sqrt(2me/(kg) Eph/(J))/hbar(J s)
//<=> Kph/(A-1) = sqrt(2me/(kg) Eph/(eV) eV/J)/hbar(J s) (m-1)/(A-1)
//
//eV/J corresponds to the value of elementary charge (in unit of Coulomb)
//m-1/A-1=10^-10
//
//E2KConstant=sqrt(2me/(kg) eV/J)/(hbar/(J s)) (m-1)/A-1)
//sqrt(2 me/(kg) 10^31 ec/(C) e^19)/(hbar/(J s) e^34)=sqrt(2me/(kg) eV/J)/(hbar/(J s)) 10^-9

Function IAFu_E2kConstant()
	Variable hbar_e34=1.054571 //hbar*10^34
	Variable me_e31=9.109383 //me*10^31
	Variable ec_e19=1.602176 //corresponding to (eV/J)*10^19
	return sqrt(2.0*me_e31*ec_e19)/(hbar_e34*10.0)
End	
	
//Function ConvAngle2D_F: example format for ConvertAngle2D
//covers the same range ([anglemin,anglemax] corresponds to [kmin,kmax]), with same number of points
Function/S IAFf_ConvAngle2D_F_Definition()
	return "6;0;0;0;0;1;1;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D;"
End	

Function IAFf_ConvAngle2D_F(argumentList)
	String argumentList
	
	//0th argument: hn-W
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: theta0
	String theta0Arg=StringFromList(1,argumentList)
	
	//2nd argument: EnergyInfo
	String EnergyInfoArg=StringFromList(2,argumentList)
	
	//3rd argument: AngleInfo
	String AngleInfoArg=StringFromList(3,argumentList)
	
	//4th argument: output EnergyInfo (same as the 2nd argument)
	String EnergyInfo2Arg=StringFromList(4,argumentList)
	
	//5th argument: output MomentumInfo
	String MomentumInfoArg=StringFromList(5,argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR theta0=$theta0Arg
	Duplicate/O $EnergyInfoArg $EnergyInfo2Arg
	Wave/D AngleInfo=$AngleInfoArg
	Make/O/D/N=3 $MomentumInfoArg
	Wave/D MomentumInfo=$MomentumInfoArg
	
	//number of points is kept
	MomentumInfo[2]=AngleInfo[2]
	
	Variable thetaMin=AngleInfo[0]-theta0 //[deg]
	Variable thetaMax=AngleInfo[0]+AngleInfo[1]*(AngleInfo[2]-1)-theta0 //[deg]
	Variable E2kConstant=IAFu_E2kConstant()
	Variable Kph_Ef=sqrt(Eph_Ef)*E2kConstant
	Variable kmin=Kph_Ef*sin(pi/180.0*thetaMin)
	Variable kmax=Kph_Ef*sin(pi/180.0*thetaMax)
	MomentumInfo[0]=kmin
	MomentumInfo[1]=(kmax-kmin)/(AngleInfo[2]-1)
End
	