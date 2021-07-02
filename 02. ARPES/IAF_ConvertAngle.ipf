#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module ConvAngle2D: convert angle to momentum
//list of (E,k) is given through the socket
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
		if(input[i][1]/Kph>=1)
			input[i][1]=theta0+90
		Elseif(input[i][1]/Kph<=-1)
			input[i][1]=theta0-90
		Else
			input[i][1]=theta0+(180.0/pi)*asin(input[i][1]/Kph)
		Endif
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
	
	

//Module ConvEAhn: convert Energy-Angle-hn to Energy-kx-kz
//list of (E,kx,kz) is givne through the socket
//E: Energy (<0) with 0 being set to Ef
//kx: momentum along the slit direction (A^-1)
//kz: momentum perp. to the crystal surface
//
//W: Work function [eV]
//V0: Inner potential [eV]
//Energy of photoelectron: Eph=Eph_Ef+E, Eph_Ef=hn-W
//Momentum of photoelectron in vacuum: Eph=(hbar Kph_v)^2/2me <=> Kph_v=sqrt(2me Eph)/hbar
//Momentum of photoelectron in crystal: Eph=(hbar Kph_c)^2/2me - V0 <=> Kph_c=sqrt(2me Eph+V0)/hbar
//Kph_v and Kph_c have the same in-plane components (out-of-plane components are different)
// kx=Kph_v sin (theta-theta0)
// kz=sqrt(Kph_c^2-kx^2)=sqrt(2m(Eph cos^2(theta-theta0)+V0))/hbar
//
//When E, kx, and kz are given,
//Kph_c = sqrt(kx^2+kz^2)
//Eph   = (hbar Kph_c)^2/2me-V0
//hn    = Eph-E+W
//Kph_v = sqrt(2me Eph)/hbar
//theta = theta_0+asin(kx/Kph_v)

Function/S IAFm_ConvEAhn_Definition()
	return "5;0;0;0;0;2;Variable;Variable;Variable;Coordinate3D;Coordinate3D"
End	

Function/S IAFm_ConvEAhn(argumentList)
	String argumentList
	
	//0th argument: work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument: inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument: angle origin theta0 [deg]
	String theta0Arg=StringFromList(2,argumentList)
	
	//3rd argument: coordinate3D socket (E-angle-hn)
	String EAhnSocketName=StringFromList(3,argumentList)
	
	//4th argument: given coordinate list (E-kx-kz)
	String EkkListName=StringFromList(4,argumentList)
	
	NVAR W=$Warg
	NVAR V0=$V0Arg
	NVAR theta0=$theta0Arg

	Wave/D EkkList=$EkkListName
	
	Variable listSize=DimSize(EkkList,0)
	
	String inputPath="::TempData:ConvEAhn_Input"
	Duplicate/O EkkList $inputPath
	Wave/D input=$inputPath
		
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()

//When E, kx, and kz are given,
//Kph_c = sqrt(kx^2+kz^2)
//Eph   = (hbar Kph_c)^2/2me-V0
//hn    = Eph-E+W
//Kph_v = sqrt(2me Eph)/hbar
//theta = theta_0+asin(kx/Kph_v)

	For(i=0;i<listSize;i+=1)
		Variable E=input[i][0]
		Variable kx=input[i][1]
		Variable kz=input[i][2]
		Variable Kph_c=sqrt(kx^2+kz^2)
		Variable Eph=(Kph_c/E2kConstant)^2-V0
		Variable hn=Eph-E+W
		Variable Kph_v=sqrt(Eph)*E2kConstant
		Variable theta=theta0+asin(kx/Kph_v)*(180.0/pi)
		input[i][1]=theta
		input[i][2]=hn
	Endfor
	
	return IAFc_CallSocket(EAhnSocketName, inputPath)
	
End

Function/S IAFf_ConvEAhn_F_Definition()
	return "9;0;0;0;0;0;0;1;1;1;Variable;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
End	

Function IAFf_ConvEAhn_F(argumentList)
	String argumentList
	
	//0th argument: work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument: inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument: angle origin theta0 [deg]
	String theta0Arg=StringFromList(2,argumentList)
	
	//3rd,4th,5th arguments: EnergyInfo,AngleInfo,hnInfo
	String EnergyInfoArg=StringFromList(3,argumentList)
	String AngleInfoArg=StringFromList(4,argumentList)
	String hnInfoArg=StringFromList(5,argumentList)
	
	//6th,7th,8th arguments: EnergyInfo,kxInfo,kzInfo
	String EnergyInfo2Arg=StringFromList(6,argumentList)
	String kxInfoArg=StringFromList(7,argumentList)
	String kzInfoArg=StringFromList(8,argumentList)

	NVAR W=$WArg
	NVAR V0=$V0Arg
	NVAR theta0=$theta0Arg
	Duplicate/O $EnergyInfoArg $EnergyInfo2Arg
	Wave/D EnergyInfo=$EnergyInfoArg
	Wave/D AngleInfo=$AngleInfoArg
	Wave/D hnInfo=$hnInfoArg

//When E, hn, and theta are given,
//Eph=Eph_Ef+E, Eph_Ef=hn-W
//Kph_v=sqrt(2me Eph)/hbar
//Kph_c=sqrt(2me Eph+V0)/hbar
//kx=Kph_v sin (theta-theta0)
//kz=sqrt(Kph_c^2-kx^2)=sqrt(2m(Eph cos^2(theta-theta0)+V0))/hbar
//

	Variable E
	Variable theta
	Variable hn
	
	Variable Eph
	Variable Kph_v
	Variable Kph_c
	Variable E2kConstant=IAFu_E2kConstant()
	Variable kx
	Variable kz
	//kx min: largest E, smallest theta, largest hn
	E=EnergyInfo[0]+EnergyInfo[1]*EnergyInfo[2]
	theta=AngleInfo[0]
	hn=hnInfo[0]+hnInfo[1]*hnInfo[2]
	//common part
	Eph=E+hn-W
	Kph_v=sqrt(Eph)*E2kConstant
	Kph_c=sqrt(Eph+V0)*E2kConstant
	kx=Kph_v*sin(pi/180.0*(theta-theta0))
	kz=sqrt(Kph_c^2-kx^2)
	//
	Variable kxMin=kx
	
	//kx max: largest E, largest theta, largest hn
	theta=AngleInfo[0]+AngleInfo[1]*AngleInfo[2]
	kx=Kph_v*sin(pi/180.0*(theta-theta0))
	Variable kxMax=kx
	
	//kz min: smallest E, largest or smallest theta, smallest hn
	E=EnergyInfo[0]
	theta=AngleInfo[0]
	hn=hnInfo[0]
	//common part
	Eph=E+hn-W
	Kph_v=sqrt(Eph)*E2kConstant
	Kph_c=sqrt(Eph+V0)*E2kConstant
	kx=Kph_v*sin(pi/180.0*(theta-theta0))
	kz=sqrt(Kph_c^2-kx^2)
	//
	Variable kzMin1=kz
	theta=AngleInfo[0]+AngleInfo[1]*AngleInfo[2]
	kx=Kph_v*sin(pi/180.0*(theta-theta0))
	kz=sqrt(Kph_c^2-kx^2)
	Variable kzMin2=kz
	Variable kzMin=min(kzMin1,kzMin2)
	
	//kz max: largest E, 0, largest hn
	E=EnergyInfo[0]+EnergyInfo[1]*EnergyInfo[2]
	theta=0
	hn=hnInfo[0]+hnInfo[1]*hnInfo[2]
	
	//common part
	Eph=E+hn-W
	Kph_v=sqrt(Eph)*E2kConstant
	Kph_c=sqrt(Eph+V0)*E2kConstant
	kx=0
	kz=sqrt(Kph_c^2-kx^2)
	//
	Variable kzMax=kz
	
	Make/O/D/N=3 $kxInfoArg
	Wave/D kxInfo=$kxInfoArg
	Make/O/D/N=3 $kzInfoArg
	Wave/D kzInfo=$kzInfoArg
	
	kxInfo[0]=kxMin
	kxInfo[1]=(kxMax-kxMin)/AngleInfo[2]
	kxInfo[2]=AngleInfo[2]
	
	kzInfo[0]=kzMin
	kzInfo[1]=(kzMax-kzMin)/hnInfo[2]
	kzInfo[2]=hnInfo[2]
	
	
End


Function/S IAFm_LoadkzMap_Definition()
	return "4;0;0;0;2;TextWave;Variable;Variable;Coordinate3D"
End

Function/S IAFm_LoadkzMap(argumentList)
	String argumentList
	//0th argument: List of kz map names, with the current folder being the relative origin
	//kz maps are assumed to have the same EDelta, ESize, AngleInfo, but not the same EOffset
	String kzListArg=StringFromList(0,argumentList)
	
	//1st argument: smoothing size along the 1st axis (energy)
	//Also see IAF_Smoothing.ipf for rule to determine the smoothing range
	String EWidthArg=StringFromList(1,argumentList)
	
	//2nd argument: smoothing size along the 2nd axis (angle)
	String AWidthArg=StringFromList(2,argumentList)
	
	//3rd argument: List of coordinates(E-angle-hn)
	String EAhnListName=StringFromList(3,argumentList)
	
	Wave/T kzList=$kzListArg
	NVAR EWidth=$EWidthArg
	NVAR AWidth=$AWidthArg
	Wave/D EAhnList=$EAhnListName
	
	Variable kzOffset=DimOffset(kzList,0)
	Variable kzDelta=DimDelta(kzList,0)
	Variable kzSize=DimSize(kzList,0)
	
	Variable listSize=DimSize(EAhnList,0)
	String outputPath="::TempData:LoadkzMap_Output"
	Make/O/D/N=(listSize) $outputPath
	Wave/D output=$outputPath
	
	//validation
	if(EWidth<1 || AWidth<1)
		print("LoadkzMap Error: Smoothing lengthes must be greater than 0")
		abort
	Endif
	
	//determine the start and end offsets for the smoothing
	Variable EStart,EEnd
	Variable AStart,AEnd
	If(round(EWidth/2)*2==EWidth)
		//even
		EStart=-round(EWidth/2)
		EEnd=-EStart-1
	Else
		//odd
		EStart=-round((EWidth-1)/2)
		EEnd=-EStart
	Endif
	
	If(round(AWidth/2)*2==AWidth)
		//even
		AStart=-round(AWidth/2)
		AEnd=-AStart-1
	Else
		//odd
		AStart=-round((AWidth-1)/2)
		AEnd=-AStart
	Endif
	
	Variable i,j,k
	For(i=0;i<listSize;i+=1)
		Variable E=EAhnList[i][0]
		Variable theta=EAhnList[i][1]
		Variable hn=EAhnList[i][2]
		
		Variable hnIndex=round((hn-kzOffset)/kzDelta)
		if(hnIndex<0 || hnIndex>=kzSize)
			output[i]=0
			continue
		Endif
		
		Wave/D Map=$"::"+kzList[hnIndex]
		
		Variable EOffset=DimOffset(Map,0)
		Variable EDelta=DimDelta(Map,0)
		Variable ESize=DimSize(Map,0)
		
		Variable AOffset=DimOffset(Map,1)
		Variable ADelta=DimDelta(Map,1)
		Variable ASize=DimSize(Map,1)
		Variable EIndex=round((E-EOffset)/EDelta)
		Variable AIndex=round((theta-AOffset)/ADelta)
		
		output[i]=0
		For(j=EStart;j<=EEnd;j+=1)
			For(k=AStart;k<=AEnd;k+=1)
				Variable EIndex2=EIndex+j
				Variable AIndex2=AIndex+k
				if(!(EIndex2<0 || EIndex2>=ESize || AIndex2<0 || AIndex2>=ASize))
					output[i]+=Map[EIndex2][AIndex2]
					
				Endif
			Endfor
		Endfor

	Endfor
	return outputPath
End


Function/S IAFf_LoadkzMap_F_Definition()
	return "6;0;0;0;1;1;1;TextWave;Variable;Variable;Wave1D;Wave1D;Wave1D"
End

Function IAFf_LoadkzMap_F(argumentList)
	String argumentList
	
	//0th argument: List of kz map names, with the current folder being the relative origin
	//kz maps are assumed to have the same EDelta, ESize, AngleInfo, but not the same EOffset
	String kzListArg=StringFromList(0,argumentList)
	
	//1st argument: smoothing size along the 1st axis (energy)
	//Also see IAF_Smoothing.ipf for rule to determine the smoothing range
	String EWidthArg=StringFromList(1,argumentList)
	
	//2nd argument: smoothing size along the 2nd axis (angle)
	String AWidthArg=StringFromList(2,argumentList)
	
	//3rd argument: output EnergyInfo
	String EInfoArg=StringFromList(3,argumentList)
	
	//4th argument: output AngleInfo
	String AInfoArg=StringFromList(4,argumentList)
	
	//5th argument: output hnInfo
	String hnInfoArg=StringFromList(5,argumentList)
	
	Wave/T kzList=$kzListArg
	NVAR EWidth=$EWidthArg
	NVAR AWidth=$AWidthArg
	
	Make/O/D/N=3 $EInfoArg
	Wave/D EInfo=$EInfoArg
	Make/O/D/N=3 $AInfoArg
	Wave/D AInfo=$AInfoArg
	Make/O/D/N=3 $hnInfoArg
	Wave/D hnInfo=$hnInfoArg
	
	//AngleInfo: from [0]
	Wave/D kzMap0=$"::"+kzList[0]
	AInfo[0]=DimOffset(kzMap0,1)
	AInfo[1]=DimDelta(kzMap0,1)
	AInfo[2]=DimSize(kzMap0,1)
	Variable EDelta=DimDelta(kzMap0,0)
	Variable ESize=DimSize(kzMap0,0)
	
	//hnInfo: from kzList
	hnInfo[0]=DimOffset(kzList,0)
	hnInfo[1]=DimDelta(kzList,0)
	hnInfo[2]=DimSize(kzList,0)
	
	//EnergyInfo
	//Take average of EOffset
	Variable EOffsetSum=0
	Variable i
	Variable ListSize=DimSize(kzList,0)
	For(i=0;i<ListSize;i+=1)
		Wave/D kzMap=$"::"+kzList[i]
		EOffsetSum+=DimOffset(kzMap,0)
	Endfor
	Variable EOffsetAverage=EOffsetSum/ListSize
	
	//determine min and max shift from the average
	Variable minShift=0
	Variable maxShift=0
	For(i=0;i<ListSize;i+=1)
		Wave/D kzMap=$"::"+kzList[i]
		Variable shift=round((DimOffset(kzMap,0)-EOffsetAverage)/EDelta)
		if(shift<minShift)
			minShift=shift
		Endif
		if(shift>maxShift)
			maxShift=shift
		Endif
	Endfor
	EInfo[0]=EOffsetAverage+minShift*EDelta
	EInfo[1]=EDelta
	EInfo[2]=ESize-minShift+maxShift
	
	//resize by smoothing
	
	//validation
	if(EWidth<1 || AWidth<1)
		print("LoadkzMap Error: Smoothing lengthes must be greater than 0")
		abort
	Endif
		
	//determine the start and end offsets for the smoothing
	Variable EStart,EEnd
	Variable AStart,AEnd
	If(round(EWidth/2)*2==EWidth)
		//even
		EStart=-round(EWidth/2)
		EEnd=-EStart-1
	Else
		//odd
		EStart=-round((EWidth-1)/2)
		EEnd=-EStart
	Endif
	
	If(round(AWidth/2)*2==AWidth)
		//even
		AStart=-round(AWidth/2)
		AEnd=-AStart-1
	Else
		//odd
		AStart=-round((AWidth-1)/2)
		AEnd=-AStart
	Endif
	
	EInfo[0]-=EInfo[1]*EStart
	EInfo[1]*=EWidth
	EInfo[2]=ceil(EInfo[2]/EWidth)
	
	AInfo[0]-=AInfo[1]*AStart
	AInfo[1]*=AWidth
	AInfo[2]=ceil(AInfo[2]/AWidth)
	
End
	

//Module ConvPeaks: convert peak positions (Energy,hn) to (Energy,kz), where kx is given
//E: Energy (<0) with 0 being set to Ef
//kx: momentum along the slit direction (A^-1)
//kz: momentum perp. to the crystal surface
//
//W: Work function [eV]
//V0: Inner potential [eV]
//Energy of photoelectron: Eph=Eph_Ef+E, Eph_Ef=hn-W
//Momentum of photoelectron in crystal: Eph=(hbar Kph_c)^2/2me - V0 <=> Kph_c=sqrt(2me Eph+V0)/hbar
// kz=sqrt(Kph_c^2-kx^2)=sqrt((2me/hbar^2 (Eph+V0)) - kx^2)

Function/S IAFf_ConvPeaks_Definition()
	return "5;0;0;0;0;1;Variable;Variable;Wave2D;Variable;Wave2D"
End	

Function IAFf_ConvPeaks(argumentList)
	String argumentList
	
	//0th argument: work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument: inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument: list of peak positions (hn-E)
	String Peaks_hnArg=StringFromList(2,argumentList)
	
	//3rd argument: kx
	String kxArg=StringFromList(3,argumentList)
	
	//4th argument: output peak positions (E-kz)
	String Peaks_kzArg=StringFromList(4,argumentList)
	
	NVAR W=$WArg
	NVAR V0=$V0Arg
	NVAR kx=$kxArg
	Wave/D Peaks_hn=$Peaks_hnArg
	Duplicate/O Peaks_hn $Peaks_kzArg
	Wave/D Peaks_kz=$Peaks_kzArg
	
	
	Variable E2kConstant=IAFu_E2kConstant()
	
	Peaks_kz[][0]=Peaks_hn[p][1]
	Peaks_kz[][1]=sqrt((Peaks_hn[p][0]+Peaks_hn[p][1]-W+V0)*(E2kConstant^2)-kx^2)
End