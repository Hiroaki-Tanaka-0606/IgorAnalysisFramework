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
	
	//0th argument (input): hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument (input): origin of theta (deg)
	String theta0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): coordinate2D socket (E-deg)
	String EdegSocketName=StringFromList(2,argumentList)
	
	//3rd argument (waiting socket): coordinate list passed through coordinate2D socket(E-k)
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
	
	//0th argument (input): hn-W
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument (input): theta0
	String theta0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): EnergyInfo
	String EnergyInfoArg=StringFromList(2,argumentList)
	
	//3rd argument (input): AngleInfo
	String AngleInfoArg=StringFromList(3,argumentList)
	
	//4th argument (output): output EnergyInfo (same as the 2nd argument)
	String EnergyInfo2Arg=StringFromList(4,argumentList)
	
	//5th argument (output): output MomentumInfo
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
	
	//0th argument (input): work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument (input): inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): angle origin theta0 [deg]
	String theta0Arg=StringFromList(2,argumentList)
	
	//3rd argument (input): coordinate3D socket (E-angle-hn)
	String EAhnSocketName=StringFromList(3,argumentList)
	
	//4th argument (waiting socket): given coordinate list (E-kx-kz)
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


//Module ConvEAhn2: convert Energy-kx-hn to Energy-kx-kz
//list of (E,kx,kz) is givne through the socket
//E: Energy (<0) with 0 being set to Ef
//kx: momentum along the slit direction (A^-1)
//kz: momentum perp. to the crystal surface
//When E, kx, and kz are given,
//Kph_c = sqrt(kx^2+kz^2)
//Eph   = (hbar Kph_c)^2/2me-V0
//hn    = Eph-E+W

Function/S IAFm_ConvEAhn2_Definition()
	return "5;0;0;0;0;2;Variable;Variable;Variable;Coordinate3D;Coordinate3D"
End	

Function/S IAFm_ConvEAhn2(argumentList)
	String argumentList
	
	//0th argument (input): work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument (input): inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): angle origin theta0 [deg] -> not used
	String theta0Arg=StringFromList(2,argumentList)
	
	//3rd argument (input): coordinate3D socket (E-kx-hn)
	String EAhnSocketName=StringFromList(3,argumentList)
	
	//4th argument (waiting socket): given coordinate list (E-kx-kz)
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

	For(i=0;i<listSize;i+=1)
		Variable E=input[i][0]
		Variable kx=input[i][1]
		Variable kz=input[i][2]
		Variable Kph_c=sqrt(kx^2+kz^2)
		Variable Eph=(Kph_c/E2kConstant)^2-V0
		Variable hn=Eph-E+W
		input[i][1]=kx
		input[i][2]=hn
	Endfor
	
	return IAFc_CallSocket(EAhnSocketName, inputPath)
	
End

//Function ConvEAhn_F: format function for ConvEAhn
Function/S IAFf_ConvEAhn_F_Definition()
	return "9;0;0;0;0;0;0;1;1;1;Variable;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
End	

Function IAFf_ConvEAhn_F(argumentList)
	String argumentList
	
	//0th argument (input): work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument (input): inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): angle origin theta0 [deg]
	String theta0Arg=StringFromList(2,argumentList)
	
	//3rd,4th,5th arguments (output): EnergyInfo,AngleInfo,hnInfo
	String EnergyInfoArg=StringFromList(3,argumentList)
	String AngleInfoArg=StringFromList(4,argumentList)
	String hnInfoArg=StringFromList(5,argumentList)
	
	//6th,7th,8th arguments (output): EnergyInfo,kxInfo,kzInfo
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

//Module LoadkzMap: return the values (smoothing applied) at given E-angle-hn from the list of kz maps
Function/S IAFm_LoadkzMap_Definition()
	return "4;0;0;0;2;TextWave;Variable;Variable;Coordinate3D"
End

Function/S IAFm_LoadkzMap(argumentList)
	String argumentList
	//0th argument (input): List of kz map names, with the current folder being the relative origin
	String kzListArg=StringFromList(0,argumentList)
	
	//1st argument (input): smoothing size along the 1st axis (energy)
	//Also see IAF_Smoothing.ipf for rule to determine the smoothing range
	String EWidthArg=StringFromList(1,argumentList)
	
	//2nd argument (input): smoothing size along the 2nd axis (angle)
	String AWidthArg=StringFromList(2,argumentList)
	
	//3rd argument (waiting socket): List of coordinates(E-angle-hn)
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

//Function LoadkzMap_F: format function for LoadkzMap
Function/S IAFf_LoadkzMap_F_Definition()
	return "6;0;0;0;1;1;1;TextWave;Variable;Variable;Wave1D;Wave1D;Wave1D"
End

Function IAFf_LoadkzMap_F(argumentList)
	String argumentList
	//0th argument (input): List of kz map names, with the current folder being the relative origin
	String kzListArg=StringFromList(0,argumentList)
	
	//1st argument (input): smoothing size along the 1st axis (energy)
	//Also see IAF_Smoothing.ipf for rule to determine the smoothing range
	String EWidthArg=StringFromList(1,argumentList)
	
	//2nd argument (input): smoothing size along the 2nd axis (angle)
	String AWidthArg=StringFromList(2,argumentList)
	
	//3rd argument (output): output EnergyInfo
	String EInfoArg=StringFromList(3,argumentList)
	
	//4th argument (output): output AngleInfo
	String AInfoArg=StringFromList(4,argumentList)
	
	//5th argument (output): output hnInfo
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
	

//Function ConvPeaks: convert peak positions (Energy,hn) to (Energy,kz), where kx is given
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
	
	//0th argument (input): work function W [eV]
	String WArg=StringFromList(0,argumentList)
	
	//1st argument (input): inner potential V0 [eV]
	String V0Arg=StringFromList(1,argumentList)
	
	//2nd argument (input): list of peak positions (hn-E)
	String Peaks_hnArg=StringFromList(2,argumentList)
	
	//3rd argument (input): kx
	String kxArg=StringFromList(3,argumentList)
	
	//4th argument (output): output peak positions (E-kz)
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

//ConvAngle3D_M: Convert E-angle(slit)-angle(manipulator) to E-kx-ky
Function/S IAFm_ConvAngle3D_M_Definition()
	return "9;0;0;0;0;0;0;0;0;2;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Coordinate3D;Coordinate3D"
end

Function/S IAFm_ConvAngle3D_M(argumentList)
	String argumentList
	
	//0th argument: hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: phi1 (polar angle, deg)
	String phi1Arg=StringFromList(1, argumentList)
	
	//2nd argument: theta0 (tilt offset, deg)
	String theta0Arg=StringFromList(2, argumentList)
	
	//3rd argument: phi2 (polar error, deg)
	String phi2Arg=StringFromList(3, argumentList)
	
	//4th argument: delta (azimuth error, deg)
	String deltaArg=StringFromList(4, argumentList)
	
	//5th argument: thetaInverse (inverted if greater than 0)
	String thetaInverseArg=StringFromList(5, argumentList)
	
	//6th argument: alphaInverse (inverted if grater than 0)
	String alphaInverseArg=StringFromList(6, argumentList)
	
	//7th coordinate3D socket (E-deg-deg)
	String EdegSocketName=StringFromList(7,argumentList)
	
	//8th argument: coordinate list passed through coordinate3D socket(E-k-k)
	String EkListArg=StringFromList(8,argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR phi1=$phi1Arg
	NVAR theta0=$theta0Arg
	NVAR phi2=$phi2Arg
	NVAR delta=$deltaArg
	NVAR thetaInverse=$thetaInverseArg
	NVAR alphaInverse=$alphaInverseArg
	Wave/D EkList=$EkListArg
	
	Variable listSize=DimSize(EkList,0)
	
	String inputPath="::TempData:ConvAngle3D_Input"
	Duplicate/O EkList $inputPath
	Wave/D input=$inputPath
		
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()
	
	String MdInv_path="::TempData:ConvAngle3D_delta"
	String Mp2Inv_path="::TempData:ConvAngle3D_phi2"
	String Mp2dInv_path="::TempData:ConvAngle3D_phi2delta"
	
	String Mp1Inv_path="::TempData:ConvAngle3D_phi1"
	
	IAFu_RotMatrix3D(2, -delta, MdInv_path)
	IAFu_RotMatrix3D(1, -phi2, Mp2Inv_path)
	IAFu_RotMatrix3D(1, -phi1, Mp1Inv_path)
	
	IAFu_MatrixProd(Mp2Inv_path, MdInv_path, Mp2dInv_path)
	
	String beforePath="::TempData:ConvertAngle3D_beforeConv"
	String afterPath="::TempData:ConvertAngle3D_afterConv"
	Make/o/d/n=3 $beforePath
	Make/o/d/n=3 $afterPath
	Wave/d v_before=$beforePath
	Wave/d v_after=$afterPath
	
	Variable theta, alpha
	Variable coef_t=1.0
	Variable coef_a=1.0
	if(thetaInverse>0)
		coef_t=-1.0
	endif
	if(alphaInverse>0)
		coef_a=-1.0
	endif
	For(i=0;i<listSize;i+=1)
		//printf "E, kx, ky = %.2f %.2f %.2f\n", input[i][0], input[i][1], input[i][2]
		Variable Kph=sqrt(Eph_Ef+input[i][0])*E2kConstant
		v_before[0]=input[i][1]
		v_before[1]=input[i][2]
		Variable kz2=Kph^2-v_before[0]^2-v_before[1]^2
		if(kz2<0)
			input[i][1]=90
			input[i][2]=90
			print("!!")
			continue
		endif
		v_before[2]=sqrt(kz2)
		IAFu_MVProd(Mp2dInv_path, beforePath, afterPath)
		if(v_after[2]<0)
			input[i][1]=90
			input[i][2]=90
			print("!!")
			continue
		endif
		input[i][2]=coef_t*atan(v_after[1]/v_after[2])*180/pi+theta0
		v_before[0]=v_after[0]
		v_before[1]=0
		v_before[2]=sqrt(v_after[1]^2+v_after[2]^2)
		
		IAFu_MVProd(Mp1Inv_path, beforePath, afterPath)
		if(v_after[2]<0)
			input[i][1]=90
			input[i][2]=90
			print("!!")
			continue
		endif
		input[i][1]=coef_a*atan(v_after[0]/v_after[2])*180/pi
		//printf "E, t, a = %.2f %.2f %.2f\n", input[i][0], input[i][1], input[i][2]

	Endfor
	
	return IAFc_CallSocket(EdegSocketName, inputPath)
End

//ConvAngle3D_M_F: Format of ConvAngle3D_M
Function/S IAFf_ConvAngle3D_M_F_Definition()
	return "13;0;0;0;0;0;0;0;0;0;0;1;1;1;Variable;Variable;Variable;Variable;Variable;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
end

Function IAFf_ConvAngle3D_M_F(argumentList)
	String argumentList
	
	//0th argument: hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: phi1 (polar angle, deg)
	String phi1Arg=StringFromList(1, argumentList)
	
	//2nd argument: theta0 (tilt offset, deg)
	String theta0Arg=StringFromList(2, argumentList)
	
	//3rd argument: phi2 (polar error, deg)
	String phi2Arg=StringFromList(3, argumentList)
	
	//4th argument: delta (azimuth error, deg)
	String deltaArg=StringFromList(4, argumentList)
	
	//5th argument: thetaInverse (inverted if greater than 0)
	String thetaInverseArg=StringFromList(5, argumentList)
	
	//6th argument: alphaInverse (inverted if grater than 0)
	String alphaInverseArg=StringFromList(6, argumentList)
	
	//7th-9th: input waveinfo
	String EInfoArg=StringFromList(7, argumentList)
	String alphaInfoArg=StringFromList(8, argumentList)
	String thetaInfoArg=StringFromList(9, argumentList)
	
	//10th-12th: output waveinfo
	String out_EInfoArg=StringFromList(10, argumentList)
	String out_kxInfoArg=StringFromList(11, argumentList)
	String out_kyInfoArg=StringFromList(12, argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR phi1=$phi1Arg
	NVAR theta0=$theta0Arg
	NVAR phi2=$phi2Arg
	NVAR delta=$deltaArg
	NVAR thetaInverse=$thetaInverseArg
	NVAR alphaInverse=$alphaInverseArg
	
	duplicate/o $EInfoArg $out_EInfoArg
	duplicate/o $alphaInfoArg $out_kxInfoArg
	duplicate/o $thetaInfoArg $out_kyInfoArg
	
	Wave/d EInfo=$EInfoArg
	Wave/d alphaInfo=$alphaInfoArg
	Wave/d thetaInfo=$thetaInfoArg
	Wave/d kxInfo=$out_kxInfoArg
	Wave/d kyInfo=$out_kyInfoArg
	
	Variable EMax=EInfo[0]+EInfo[1]*EInfo[2]
	Variable alphaMin=alphaInfo[0]
	Variable alphaMax=alphaInfo[0]+alphaInfo[1]*alphaInfo[2]
	Variable thetaMin=thetaInfo[0]
	Variable thetaMax=thetaInfo[0]+thetaInfo[1]*thetaInfo[2]
	
	String Eat_path="::TempData:ConvAngle3D_Eat"
	make/o/d/n=(4,3) $Eat_path
	Wave/d Eat=$Eat_path
	Eat[][0]=EMax
	Eat[0][1]=alphaMin
	Eat[0][2]=thetaMin
	Eat[1][1]=alphaMin
	Eat[1][2]=thetaMax
	Eat[2][1]=alphaMax
	Eat[2][2]=thetaMax
	Eat[3][1]=alphaMax
	Eat[3][2]=thetaMin
	
	
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()
	
	String Md_path="::TempData:ConvAngle3D_delta"
	String Mp2_path="::TempData:ConvAngle3D_phi2"
	String Mdp2_path="::TempData:ConvAngle3D_deltaphi2"
	String Mt_path="::TempData:ConvAngle3D_theta"
	
	String Mp1_path="::TempData:ConvAngle3D_phi1"
	
	String Mtp1_path="::TempData:ConvAngle3D_thetaphi1"
	
	String M_path="::TempData:ConvAngle3D_deltaphi2thetaphi1"
	
	IAFu_RotMatrix3D(2, delta, Md_path)
	IAFu_RotMatrix3D(1, phi2, Mp2_path)
	IAFu_RotMatrix3D(1, phi1, Mp1_path)
	
	IAFu_MatrixProd(Md_path, Mp2_path, Mdp2_path)
	
	String beforePath="::TempData:ConvertAngle3D_beforeConv"
	String afterPath="::TempData:ConvertAngle3D_afterConv"
	Make/o/d/n=3 $beforePath
	Make/o/d/n=3 $afterPath
	Wave/d v_before=$beforePath
	Wave/d v_after=$afterPath
	
	Variable theta, alpha
	Variable coef_t=1.0
	Variable coef_a=1.0
	if(thetaInverse>0)
		coef_t=-1.0
	endif
	if(alphaInverse>0)
		coef_a=-1.0
	endif
	
	Variable Kph=sqrt(Eph_Ef+EMax)*E2kConstant
	
	Variable kxMin=inf
	Variable kxMax=-inf
	Variable kyMin=inf
	Variable kyMax=-inf
	For(i=0;i<4;i+=1)
		// printf "E, a, t = %.2f %.2f %.2f\n", Eat[i][0], Eat[i][1], Eat[i][2]
		v_before[0]=Kph*sin(coef_a*Eat[i][1]*pi/180)
		v_before[1]=0
		v_before[2]=Kph*cos(coef_a*Eat[i][1]*pi/180)
		
		IAFu_RotMatrix3D(0, coef_t*(Eat[i][2]-theta0), Mt_path)
		IAFu_MatrixProd(Mt_path, Mp1_path, Mtp1_path)
		IAFu_MatrixProd(Mdp2_path, Mtp1_path, M_path)
		
		
		IAFu_MVProd(M_path, beforePath, afterPath)
		if(kxMin>v_after[0])
			kxMin=v_after[0]
		endif
		if(kxMax<v_after[0])
			kxMax=v_after[0]
		endif
		if(kyMin>v_after[1])
			kyMin=v_after[1]
		endif
		if(kyMax<v_after[1])
			kyMax=v_after[1]
		endif
	Endfor
	//printf "kxMin, kxMax, kyMin, kyMax = %.2f %.2f %.2f %.2f\n", kxMin, kxMax, kyMin, kyMax
	kxInfo[0]=kxMin
	kxInfo[1]=(kxMax-kxMin)/(kxInfo[2]-1)
	kyInfo[0]=kyMin
	kyInfo[1]=(kyMax-kyMin)/(kyInfo[2]-1)
End


//ConvAngle3D_D: Convert E-angle(slit)-angle(deflector) to E-kx-ky
Function/S IAFm_ConvAngle3D_D_Definition()
	return "8;0;0;0;0;0;0;0;2;Variable;Variable;Variable;Variable;Variable;Variable;Coordinate3D;Coordinate3D"
end

Function/S IAFm_ConvAngle3D_D(argumentList)
	String argumentList
	
	//0th argument: hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: phi1 (polar angle, deg)
	String phi1Arg=StringFromList(1, argumentList)
	
	//2nd argument: theta1 (tilt angle, deg)
	String theta1Arg=StringFromList(2, argumentList)
	
	//3rd argument: phi2 (polar error, deg)
	String phi2Arg=StringFromList(3, argumentList)
	
	//4th argument: theta2 (tilt error, deg)
	String theta2Arg=StringFromList(4, argumentList)
	
	//5th argument: delta (azimuth error, deg)
	String deltaArg=StringFromList(5, argumentList)
		
	//7th coordinate3D socket (E-deg-deg)
	String EdegSocketName=StringFromList(6,argumentList)
	
	//8th argument: coordinate list passed through coordinate3D socket(E-k-k)
	String EkListArg=StringFromList(7,argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR phi1=$phi1Arg
	NVAR theta1=$theta1Arg
	NVAR phi2=$phi2Arg
	NVAR theta2=$theta2Arg
	NVAR delta=$deltaArg
	Wave/D EkList=$EkListArg
	
	Variable listSize=DimSize(EkList,0)
	
	String inputPath="::TempData:ConvAngle3D_Input"
	Duplicate/O EkList $inputPath
	Wave/D input=$inputPath
		
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()
	
	String MdInv_path="::TempData:ConvAngle3D_delta"
	String Mt2Inv_path="::TempData:ConvAngle3D_theta2"
	String Mp2Inv_path="::TempData:ConvAngle3D_phi2"
	String Mt1Inv_path="::TempData:ConvAngle3D_theta1"
	String Mp1Inv_path="::TempData:ConvAngle3D_phi1"
	
	String Mt2dInv_path="::TempData:ConvAngle3D_theta2delta"
	String MerrInv_path="::TempData:ConvAngle3D_phi2theta2delta"
	String MsysInv_path="::TempData:ConvAngle3D_phi1theta1"
	
	String MInv_path="::TempData:ConvAngle3D_phi1theta1phi2theta2delta"
	
	IAFu_RotMatrix3D(2, -delta, MdInv_path)
	IAFu_RotMatrix3D(0, -theta2, Mt2Inv_path)
	IAFu_RotMatrix3D(1, -phi2, Mp2Inv_path)
	IAFu_RotMatrix3D(0, -theta1, Mt1Inv_path)
	IAFu_RotMatrix3D(1, -phi1, Mp1Inv_path)
	
	IAFu_MatrixProd(Mt2Inv_path, MdInv_path, Mt2dInv_path)
	IAFu_MatrixProd(Mp2Inv_path, Mt2dInv_path, MerrInv_path)
	IAFu_MatrixProd(Mp1Inv_path, Mt1Inv_path, MsysInv_path)
	IAFu_MatrixProd(MsysInv_path, MerrInv_path, MInv_path)
	
	String beforePath="::TempData:ConvertAngle3D_beforeConv"
	String afterPath="::TempData:ConvertAngle3D_afterConv"
	Make/o/d/n=3 $beforePath
	Make/o/d/n=3 $afterPath
	Wave/d v_before=$beforePath
	Wave/d v_after=$afterPath
	
	For(i=0;i<listSize;i+=1)
		//printf "E, kx, ky = %.2f %.2f %.2f\n", input[i][0], input[i][1], input[i][2]
		Variable Kph=sqrt(Eph_Ef+input[i][0])*E2kConstant
		v_before[0]=input[i][1]
		v_before[1]=input[i][2]
		Variable kz2=Kph^2-v_before[0]^2-v_before[1]^2
		if(kz2<0)
			input[i][1]=90
			input[i][2]=90
			print("!!")
			continue
		endif
		v_before[2]=sqrt(kz2)
		IAFu_MVProd(MInv_path, beforePath, afterPath)
		if(v_after[2]<0)
			input[i][1]=90
			input[i][2]=90
			print("!!")
			continue
		endif
		Variable eta_rad=acos(v_after[2]/Kph)
		input[i][1]=v_after[0]/Kph*eta_rad/sin(eta_rad)*180/pi
		input[i][2]=v_after[1]/Kph*eta_rad/sin(eta_rad)*180/pi
		//printf "E, a, b = %.2f %.2f %.2f\n", input[i][0], input[i][1], input[i][2]
	Endfor
	
	return IAFc_CallSocket(EdegSocketName, inputPath)
End


//ConvAngle3D_M_F: Format of ConvAngle3D_M
Function/S IAFf_ConvAngle3D_D_F_Definition()
	return "12;0;0;0;0;0;0;0;0;0;1;1;1;Variable;Variable;Variable;Variable;Variable;Variable;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
end

Function IAFf_ConvAngle3D_D_F(argumentList)
	String argumentList
	
	//0th argument: hn-W (energy of photoelectron irradiated from Ef state)
	String Eph_EfArg=StringFromList(0,argumentList)
	
	//1st argument: phi1 (polar angle, deg)
	String phi1Arg=StringFromList(1, argumentList)
	
	//2nd argument: theta1 (tilt angle, deg)
	String theta1Arg=StringFromList(2, argumentList)
	
	//3rd argument: phi2 (polar error, deg)
	String phi2Arg=StringFromList(3, argumentList)
	
	//4th argument: theta2 (tilt error, deg)
	String theta2Arg=StringFromList(4, argumentList)
	
	//5th argument: delta (azimuth error, deg)
	String deltaArg=StringFromList(5, argumentList)
	
	//6th-8th: input waveinfo
	String EInfoArg=StringFromList(6, argumentList)
	String alphaInfoArg=StringFromList(7, argumentList)
	String thetaInfoArg=StringFromList(8, argumentList)
	
	//9th-11th: output waveinfo
	String out_EInfoArg=StringFromList(9, argumentList)
	String out_kxInfoArg=StringFromList(10, argumentList)
	String out_kyInfoArg=StringFromList(11, argumentList)
	
	NVAR Eph_Ef=$Eph_EfArg
	NVAR phi1=$phi1Arg
	NVAR theta1=$theta1Arg
	NVAR phi2=$phi2Arg
	NVAR theta2=$theta2Arg
	NVAR delta=$deltaArg
	
	duplicate/o $EInfoArg $out_EInfoArg
	duplicate/o $alphaInfoArg $out_kxInfoArg
	duplicate/o $thetaInfoArg $out_kyInfoArg
	
	Wave/d EInfo=$EInfoArg
	Wave/d alphaInfo=$alphaInfoArg
	Wave/d thetaInfo=$thetaInfoArg
	Wave/d kxInfo=$out_kxInfoArg
	Wave/d kyInfo=$out_kyInfoArg
	
	Variable EMax=EInfo[0]+EInfo[1]*EInfo[2]
	Variable alphaMin=alphaInfo[0]
	Variable alphaMax=alphaInfo[0]+alphaInfo[1]*alphaInfo[2]
	Variable thetaMin=thetaInfo[0]
	Variable thetaMax=thetaInfo[0]+thetaInfo[1]*thetaInfo[2]
	
	String Eat_path="::TempData:ConvAngle3D_Eat"
	make/o/d/n=(4,3) $Eat_path
	Wave/d Eat=$Eat_path
	Eat[][0]=EMax
	Eat[0][1]=alphaMin
	Eat[0][2]=thetaMin
	Eat[1][1]=alphaMin
	Eat[1][2]=thetaMax
	Eat[2][1]=alphaMax
	Eat[2][2]=thetaMax
	Eat[3][1]=alphaMax
	Eat[3][2]=thetaMin
	
	
	Variable i
	Variable E2kConstant=IAFu_E2kConstant()
	
	String Md_path="::TempData:ConvAngle3D_delta"
	String Mt2_path="::TempData:ConvAngle3D_theta2"
	String Mp2_path="::TempData:ConvAngle3D_phi2"
	String Mt1_path="::TempData:ConvAngle3D_theta1"
	String Mp1_path="::TempData:ConvAngle3D_phi1"
	
	String Mdt2_path="::TempData:ConvAngle3D_deltatheta2"
	String Merr_path="::TempData:ConvAngle3D_deltatheta2phi2"
	String Msys_path="::TempData:ConvAngle3D_theta1phi1"
	
	String M_path="::TempData:ConvAngle3D_deltatheta2phi2theta1phi1"
	
	IAFu_RotMatrix3D(2, delta, Md_path)
	IAFu_RotMatrix3D(0, theta2, Mt2_path)
	IAFu_RotMatrix3D(1, phi2, Mp2_path)
	IAFu_RotMatrix3D(0, theta1, Mt1_path)
	IAFu_RotMatrix3D(1, phi1, Mp1_path)
	
	IAFu_MatrixProd(Md_path, Mt2_path, Mdt2_path)
	IAFu_MatrixProd(Mdt2_path, Mp2_path,  Merr_path)
	IAFu_MatrixProd(Mt1_path, Mp1_path, Msys_path)
	IAFu_MatrixProd(Merr_path, Msys_path, M_path)
	
	String beforePath="::TempData:ConvertAngle3D_beforeConv"
	String afterPath="::TempData:ConvertAngle3D_afterConv"
	Make/o/d/n=3 $beforePath
	Make/o/d/n=3 $afterPath
	Wave/d v_before=$beforePath
	Wave/d v_after=$afterPath
	
	
	Variable Kph=sqrt(Eph_Ef+EMax)*E2kConstant
	
	Variable kxMin=inf
	Variable kxMax=-inf
	Variable kyMin=inf
	Variable kyMax=-inf
	For(i=0;i<4;i+=1)
		// printf "E, a, t = %.2f %.2f %.2f\n", Eat[i][0], Eat[i][1], Eat[i][2]
		Variable alpha_rad=Eat[i][1]*pi/180
		Variable beta_rad=Eat[i][2]*pi/180
		Variable eta_rad=sqrt(alpha_rad^2+beta_rad^2)
		v_before[0]=Kph*alpha_rad*sin(eta_rad)/eta_rad
		v_before[1]=Kph*beta_rad*sin(eta_rad)/eta_rad
		v_before[2]=Kph*cos(eta_rad)
				
		IAFu_MVProd(M_path, beforePath, afterPath)
		if(kxMin>v_after[0])
			kxMin=v_after[0]
		endif
		if(kxMax<v_after[0])
			kxMax=v_after[0]
		endif
		if(kyMin>v_after[1])
			kyMin=v_after[1]
		endif
		if(kyMax<v_after[1])
			kyMax=v_after[1]
		endif
	Endfor
	//printf "kxMin, kxMax, kyMin, kyMax = %.2f %.2f %.2f %.2f\n", kxMin, kxMax, kyMin, kyMax
	kxInfo[0]=kxMin
	kxInfo[1]=(kxMax-kxMin)/(kxInfo[2]-1)
	kyInfo[0]=kyMin
	kyInfo[1]=(kyMax-kyMin)/(kyInfo[2]-1)
End

//Conversion matrix of the vector t(p, q, r) in the C1 coordinate axes to t(s, t, u) in the C2 coordinate
//C2 coordinate is rotated along the {direction} axis by {angle} deg (counterclockwise)
//t(s, t, u)={matrix} * t(p, q, r)
//direction=0 (x), 1 (y), 2(z)
Function IAFu_RotMatrix3D(direction, angle, matrixPath)
	Variable direction, angle
	String matrixPath
	
	Variable a_rad=angle*pi/180
	Variable c=cos(a_rad)
	Variable s=sin(a_rad)
	
	make/o/d/n=(3,3) $matrixPath
	Wave/d matrix=$matrixPath
	matrix[][]=0
	
	if(direction==0)
		// x
		matrix[0][0]=1
		matrix[1][1]=c
		matrix[1][2]=s
		matrix[2][1]=-s
		matrix[2][2]=c
	elseif(direction==1)
		//y
		matrix[1][1]=1
		matrix[2][2]=c
		matrix[2][0]=s
		matrix[0][2]=-s
		matrix[0][0]=c
	elseif(direction==2)
		//z
		matrix[2][2]=1
		matrix[0][0]=c
		matrix[0][1]=s
		matrix[1][0]=-s
		matrix[1][1]=c
	endif
end
	
//m3=m1*m2
Function IAFu_MatrixProd(m1, m2, m3)
	String m1, m2, m3
	
	Wave/d mat1=$m1
	Wave/d mat2=$m2
	
	Variable size11=dimsize(mat1, 0)
	Variable size12=dimsize(mat1, 1)
	
	Variable size21=dimsize(mat2, 0)
	Variable size22=dimsize(mat2, 1)
	
	if(size12==size21)
		make/o/d/n=(size11, size22) $m3
		Wave/d mat3=$m3
		
		mat3[][]=0
		Variable i, j, k
		for(i=0; i<size11; i++)
			for(j=0; j<size22; j++)
				for(k=0; k<size12; k++)
					mat3[i][j]+=mat1[i][k]*mat2[k][j]
				endfor
			endfor
		endfor
	else
		print("MatrixProd: size error")
		abort
	endif
end


//m3=m1*m2
Function IAFu_MVProd(m1, m2, m3)
	String m1, m2, m3
	
	Wave/d mat1=$m1
	Wave/d mat2=$m2
	
	Variable size11=dimsize(mat1, 0)
	Variable size12=dimsize(mat1, 1)
	
	Variable size21=dimsize(mat2, 0)
	
	if(size12==size21)
		make/o/d/n=(size11) $m3
		Wave/d mat3=$m3
		
		mat3[]=0
		Variable i, j
		for(i=0; i<size11; i++)
			for(j=0; j<size12; j++)
				mat3[i]+=mat1[i][j]*mat2[j]
			endfor
		endfor
	else
		print("MVProd: size error")
		abort
	endif
end