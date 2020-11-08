#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Module CorrectInt_fx3D: return intensity of fixed 3D data [i][j][k] normalized by 2D normalization reference [i][j]
Function/S IAFm_CorrectInt_fx3D_Definition()
	return "3;0;0;2;Wave3D;Wave2D;Index3D"
End

Function/S IAFm_CorrectInt_fx3D(argumentList)
	String argumentList
	
	//0th argument: raw data
	String rawArg=StringFromList(0,argumentList)
	
	//1st argument: normalization reference
	String refArg=StringFromList(1,argumentList)
	
	//2nd argument: indices wave passed through socket
	String indicesArg=StringFromList(2,argumentList)
	
	Wave/D raw=$rawArg
	Wave/D ref=$refArg
	
	//size check
	if(DimSize(raw,0)!=DimSize(ref,0) || DimSize(raw,1)!=DimSize(ref,1))
		// if ref is larger than raw only warning (without abort) is sent
		if(DimSize(raw,0)>DimSize(ref,0) || DimSize(raw,1)>DimSize(ref,1))
			print("CorrectInt_fx3D Error: sizes of raw is larger than that of ref")
			abort
		Else
			print("CorrectInt_fx3D Warning: sizes of ref is larger than that of raw")
		Endif
	Endif
	
	Variable size1=DimSize(raw,0)
	Variable size2=DimSize(raw,1)
	Variable size3=DimSize(raw,2)
	
	Wave/D indices=$indicesArg
	Variable dataSize=DimSize(indices,0)
	
	//output wave (the name of it is returned)
	String outputPath="::TempData:CorrectInt_fx3D_Output"
	Make/O/D/N=(dataSize) $outputPath
	Wave/D output=$outputPath
	
	Variable i
	Variable index1,index2,index3
	For(i=0;i<dataSize;i+=1)
		index1=indices[i][0]
		index2=indices[i][1]
		index3=indices[i][2]
		//range check
		If(index1<0 || size1<=index1 || index2<0 || size2<=index2 || index3<0 || size3<=index3)
			output[i]=0
		Else
			//MCP validity check
			If(ref[index1][index2]>=0)
				output[i]=raw[index1][index2][index3]/ref[index1][index2]
			Else
				output[i]=0
			Endif
		Endif
	Endfor
	return outputPath
End


//Module Read3D: return intensity of 3D data [i][j][k]
Function/S IAFm_Read3D_Definition()
	return "2;0;2;Wave3D;Index3D"
End

Function/S IAFm_Read3D(argumentList)
	String argumentList
	
	//0th argument: raw data
	String rawArg=StringFromList(0,argumentList)
	
	//1st argument: indices wave passed through socket
	String indicesArg=StringFromList(1,argumentList)
	
	Wave/D raw=$rawArg
	
	Variable size1=DimSize(raw,0)
	Variable size2=DimSize(raw,1)
	Variable size3=DimSize(raw,2)
	
	Wave/D indices=$indicesArg
	Variable dataSize=DimSize(indices,0)
	
	//output wave (the name of it is returned)
	String outputPath="::TempData:CorrectInt_fx3D_Output"
	Make/O/D/N=(dataSize) $outputPath
	Wave/D output=$outputPath
	
	Variable i
	Variable index1,index2,index3
	For(i=0;i<dataSize;i+=1)
		index1=indices[i][0]
		index2=indices[i][1]
		index3=indices[i][2]
		//range check
		If(index1<0 || size1<=index1 || index2<0 || size2<=index2 || index3<0 || size3<=index3)
			output[i]=0
		Else
			output[i]=raw[index1][index2][index3]
		Endif
	Endfor
	return outputPath
End

//Function TotalIntensity: sum up the intensity of each pixel in Wave2D[][]
Function/S IAFf_TotalIntensity_Definition()
	return "2;0;1;Wave2D;Variable"
End

Function IAFf_TotalIntensity(argumentList)
	String argumentList
	
	//0th argument: input Wave2D
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: output total intensity
	String totalIntArg=StringFromList(1,argumentList)
	
	Wave/D input=$inputArg
	NVAR totalInt=$totalIntArg
	
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	
	Variable i,j
	totalInt=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			totalInt+=input[i][j]
		Endfor
	Endfor
End

//Function SliceNormalize: Normalize Wave2D[][] (to be gathered into Wave3D[][][i]) by averaged total intensity
Function/S IAFf_SliceNormalize_Definition()
	return "4;0;0;0;1;Wave2D;Wave1D;Variable;Wave2D"
End

Function IAFf_SliceNormalize(argumentList)
	String argumentList
	
	//0th argument: input Wave2D
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: intensity wave ([i] corresponds total intensity of Wave3D[][][i])
	String intWaveArg=StringFromList(1,argumentList)
	
	//2nd argument: index i
	String indexArg=StringFromList(2,argumentList)
	
	//3rd argument: output Wave2D (input[p][q]/(averaged intensity))
	String outputArg=StringFromList(3,argumentList)
	
	Wave/D input=$inputArg
	Wave/D intWave=$intWaveArg
	NVAR index=$indexArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	
	//get average of intWave
	Variable total=0
	Variable i
	Variable size1=DimSize(intWave,0)
	For(i=0;i<size1;i+=1)
		total+=intWave[i]
	Endfor
	Variable average=total/size1
	if(average==0)
		print("SliceNormalize Error: total intensity is zero")
		abort
	Endif
	output[][]=input[p][q]/intWave[index]*average
End

//Module ConvertIndex3D: convert index to coordinate
Function/S IAFm_ConvertIndex3D_Definition()
	return "6;0;0;0;0;0;2;Variable;Wave1D;Wave1D;Wave1D;Index3D;Coordinate3D"
End

Function/S IAFm_ConvertIndex3D(argumentList)
	String argumentList
	
	//0th argument: convert mode
	//0: nearest point
	//1: interpolation of surrounding 8 points
	String convertModeArg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for first index
	String waveInfo1Arg=StringFromList(1,argumentList)
	
	//2nd argument: WaveInfo for second index
	String waveInfo2Arg=StringFromList(2,argumentList)
	
	//3nd argument: WaveInfo for third index
	String waveInfo3Arg=StringFromList(3,argumentList)
	
	//4th argument: socket to which an indices wave is passed
	String indicesSocketName=StringFromList(4,argumentList)
	
	//5th argument: coordinates wave passed through socket
	String coordinatesArg=StringFromList(5,argumentList)
	
	NVAR convertMode=$convertModeArg
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	Wave/D coordinates=$coordinatesArg
	Variable coordinatesSize=DimSize(coordinates,0)
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	
	String indicesPath="::TempData:ConvertIndex3D_Input"
	String fracIndicesPath="::TempData:ConvertIndex3D_frac"
	Variable i=0 //for indices
	Variable j=0 //for coordinates
	//make indices wave
	If(convertMode==1)
		//interpolation
		Make/O/D/N=(coordinatesSize*8,3) $indicesPath
		Wave/D indices=$indicesPath
		Make/O/D/N=(coordinatesSize,3) $fracIndicesPath
		Wave/D fracIndices=$fracIndicesPath
		For(j=0;j<coordinatesSize;j+=1)
			fracIndices[j][0]=(coordinates[j][0]-offset1)/delta1
			fracIndices[j][1]=(coordinates[j][1]-offset2)/delta2
			fracIndices[j][2]=(coordinates[j][2]-offset3)/delta3
			Variable index1_floor=floor(fracIndices[j][0])
			Variable index2_floor=floor(fracIndices[j][1])
			Variable index3_floor=floor(fracIndices[j][2])
			fracIndices[j][0]-=index1_floor
			fracIndices[j][1]-=index2_floor
			fracIndices[j][2]-=index3_floor
			// 43 (z=index3_floor)  87 (z=index3_floor+1)
			// 12                   56 
			indices[i][0]=index1_floor
			indices[i][1]=index2_floor
			indices[i][2]=index3_floor
			indices[i+1][0]=index1_floor+1
			indices[i+1][1]=index2_floor
			indices[i+1][2]=index3_floor
			indices[i+2][0]=index1_floor+1
			indices[i+2][1]=index2_floor+1
			indices[i+2][2]=index3_floor
			indices[i+3][0]=index1_floor
			indices[i+3][1]=index2_floor+1
			indices[i+3][2]=index3_floor
			
			indices[i+4][0]=index1_floor
			indices[i+4][1]=index2_floor
			indices[i+4][2]=index3_floor+1
			indices[i+5][0]=index1_floor+1
			indices[i+5][1]=index2_floor
			indices[i+5][2]=index3_floor+1
			indices[i+6][0]=index1_floor+1
			indices[i+6][1]=index2_floor+1
			indices[i+6][2]=index3_floor+1
			indices[i+7][0]=index1_floor
			indices[i+7][1]=index2_floor+1
			indices[i+7][2]=index3_floor+1

			i+=8
		Endfor
	Else
		//nearest
		Make/O/D/N=(coordinatesSize,3) $indicesPath
		Wave/D indices=$indicesPath
		For(j=0;j<coordinatesSize;j+=1)
			indices[i][0]=round((coordinates[j][0]-offset1)/delta1)
			indices[i][1]=round((coordinates[j][1]-offset2)/delta2)
			indices[i][2]=round((coordinates[j][2]-offset3)/delta3)
			i+=1
		Endfor
	Endif
	
	String socketOutputPath=IAFc_CallSocket(indicesSocketName,indicesPath)
	Wave/D socketOutput=$socketOutputPath
	
	//make the output
	String outputPath="::TempData:ConvertIndex3D_Output"
	Make/O/D/N=(coordinatesSize) $outputPath
	Wave/D output=$outputPath
	i=0
	j=0
	If(convertMode==1)
		//interpolation
		For(;j<coordinatesSize;j+=1)
			Variable int_000=socketOutput[i]
			Variable int_100=socketOutput[i+1]
			Variable int_110=socketOutput[i+2]
			Variable int_010=socketOutput[i+3]
			Variable int_001=socketOutput[i+4]
			Variable int_101=socketOutput[i+5]
			Variable int_111=socketOutput[i+6]
			Variable int_011=socketOutput[i+7]
			i+=8
			output[j]=int_000*(1-fracIndices[j][0])*(1-fracIndices[j][1])*(1-fracIndices[j][2])
			output[j]+=int_100*(fracIndices[j][0])*(1-fracIndices[j][1])*(1-fracIndices[j][2])
			output[j]+=int_110*(fracIndices[j][0])*(fracIndices[j][1])*(1-fracIndices[j][2])
			output[j]+=int_010*(1-fracIndices[j][0])*(fracIndices[j][1])*(1-fracIndices[j][2])
			output[j]+=int_001*(1-fracIndices[j][0])*(1-fracIndices[j][1])*fracIndices[j][2]
			output[j]+=int_101*(fracIndices[j][0])*(1-fracIndices[j][1])*fracIndices[j][2]
			output[j]+=int_111*(fracIndices[j][0])*(fracIndices[j][1])*fracIndices[j][2]
			output[j]+=int_011*(1-fracIndices[j][0])*(fracIndices[j][1])*fracIndices[j][2]
		Endfor
	Else
		//nearest
		output[]=socketOutput[p]
	Endif
	
	killwaves indices, socketOutput
	if(waveexists(fracIndices)==1)
		killwaves fracIndices
	Endif
	return outputPath
End

//Module CorrectEf3D: set fermi energy to zero
Function/S IAFm_CorrectEf3D_Definition()
	return "4;0;0;0;2;Variable;Wave1D;Coordinate3D;Coordinate3D"
End

Function/S IAFm_CorrectEf3D(argumentList)
	String argumentList
	
	//0th argument: fermi edge calculation mode
	//0: nearest point
	//1: interpolation of surrounding 2 points
	//in case of out-of-range, Ef is substituted by Ef[0] or Ef[-1]
	String calculateModeArg=StringFromList(0,argumentList)
	
	//1st argument: Ef wave
	String EfWaveArg=StringFromList(1,argumentList)

	//2nd argument: socket to which an coordinates wave is passed
	String coordsSocketName=StringFromList(2,argumentList)
	
	//3rd argument: coordinates wave passed through socket
	String coordsArg=StringFromList(3,argumentList)
	
	NVAR calculateMode=$calculateModeArg
	Wave/D EfWave=$EfWaveArg
	Variable EfOffset=DimOffset(EfWave,0)
	Variable EfDelta=DimDelta(EfWave,0)
	Variable EfSize=DimSize(EfWave,0)
	Wave/D coordinates=$coordsArg
	Variable coordinatesSize=DimSize(coordinates,0)
	
	String socketInputPath="::TempData:CorrectEf3D_Input"
	Duplicate/O coordinates $socketInputPath
	Wave/D socketInput=$socketInputPath
	
	Variable i
	For(i=0;i<coordinatesSize;i+=1)
		Variable fracIndex=(socketInput[i][1]-EfOffset)/EfDelta
		If(calculateMode==1)
			//interpolation
			Variable floorIndex=floor(fracIndex)
			if(floorIndex<0)
				socketInput[i][0]+=EfWave[0]
				continue
			Endif
			if(floorIndex>=EfSize-1)
				socketInput[i][0]+=EfWave[EfSize-1]
				continue
			Endif
			Variable fracPart=fracIndex-floorIndex
			socketInput[i][0]+=(1-fracPart)*EfWave[floorIndex]+fracPart*EfWave[floorIndex+1]
		Else
			//nearest
			Variable intIndex=round(fracIndex)
			if(intIndex<0)
				intIndex=0
			Endif
			if(intIndex>=EfSize)
				intIndex=EfSize-1
			Endif
			socketInput[i][0]+=EfWave[intIndex]
		Endif
	Endfor
	
	String socketOutputPath=IAFc_CallSocket(coordsSocketName, socketInputPath)
	killWaves socketInput
	return socketOutputPath
	
End
	
//Function CorrectEf3D_F: Format function of Module CorrectEf3D
Function/S IAFf_CorrectEf3D_F_Definition()
	return "7;0;0;0;0;1;1;1;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
End

Function IAFf_CorrectEf3D_F(argumentList)
	String argumentList
	
	//0th argument: input WaveInfo for 1st index
	String inWaveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: input WaveInfo for 2nd index
	String inWaveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: input WaveInfo for 3rd index
	String inWaveInfo3Arg=StringFromList(2,argumentList)
	
	//3rd argument: Ef wave
	String EfWaveArg=StringFromList(3,argumentList)

	//4td argument: output WaveInfo for 1st index
	String outWaveInfo1Arg=StringFromList(4,argumentList)
	
	//5th argument: output WaveInfo for 2nd index (same as inWaveInfo2)
	String outWaveInfo2Arg=StringFromList(5,argumentList)
	
	//6th argument: output WaveInfo for 3rd index (same as inWaveInfo3)
	String outWaveInfo3Arg=StringFromList(6,argumentList)
	
	Wave/D inWaveInfo1=$inWaveInfo1Arg
	Wave/D inWaveInfo2=$inWaveInfo2Arg
	Wave/D inWaveInfo3=$inWaveInfo3Arg
	Wave/D EfWave=$EfWaveArg
	
	//Angle: kept same
	Duplicate/O inWaveInfo2 $outWaveInfo2Arg
	Duplicate/O inWaveInfo3 $outWaveInfo3Arg
	
	//Energy: to be modified
	Duplicate/O inWaveInfo1 $outWaveInfo1Arg
	Wave/D outWaveInfo1=$outWaveInfo1Arg
	
	//calculate average Ef
	Variable totalEf=0
	Variable i
	Variable EfWaveSize=DimSize(EfWave,0)
	For(i=0;i<EfWaveSize;i+=1)
		totalEf+=EfWave[i]
	Endfor
	Variable averageEf=totalEf/EfWaveSize
	
	//calculate shift (in unit of index)
	//averageEf position has zero shift
	String TempShiftPath="::TempData:CorrectEf3D_F_shift"
	Duplicate/O EfWave $TempShiftPath
	Wave/D TempShift=$TempShiftPath
	TempShift[]=round((EfWave[p]-averageEf)/inWaveInfo1[1])
	//obtain min and max shifts
	Variable minShift=TempShift[0]
	Variable maxShift=TempShift[0]
	For(i=1;i<EfWaveSIze;i+=1)
		If(TempShift[i]<minShift)
			minShift=TempShift[i]
		Endif
		if(TempShift[i]>maxShift)
			maxShift=TempShift[i]
		Endif
	Endfor
	//!!minShift<0!!
	outWaveInfo1[0]=outWaveInfo1[0]-averageEf+minShift*inWaveInfo1[1]
	outWaveInfo1[2]=outWaveInfo1[2]+maxShift-minShift
	
	killwaves TempShift
End


//Function MakeEx_Index: make E-x cut (2D map) of 3D cube using Index3D socket
Function/S IAFf_MakeEx_Index_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Index3D;Wave2D"
End

Function IAFf_MakeEx_Index(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: yStart index (include)
	String yStartArg=StringFromList(3,argumentList)
	
	//4th argument: yEnd index(include)
	String yEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR yStart=$yStartArg
	NVAR yEnd=$yEndArg
	If(yEnd<yStart)
		print("MakeEk_Index Error: yStart <= yEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output

	//make a list of indices
	String inputPath="::TempData:MakeEx_Index_Input"
	Make/O/D/N=(size1*size2*(yEnd-yStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			For(k=yStart;k<=yEnd;k+=1)
				input[inputIndex][0]=i
				input[inputIndex][1]=j
				input[inputIndex][2]=k
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			output[i][j]=0
			For(k=yStart;k<=yEnd;k+=1)
				output[i][j]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End


//Function MakeEy_Index: make E-y cut (2D map) of 3D cube using Index3D socket
Function/S IAFf_MakeEy_Index_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Index3D;Wave2D"
End

Function IAFf_MakeEy_Index(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: xStart index (include)
	String xStartArg=StringFromList(3,argumentList)
	
	//4th argument: xEnd index(include)
	String xEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR xStart=$xStartArg
	NVAR xEnd=$xEndArg
	If(xEnd<xStart)
		print("MakeEy_Index Error: xStart <= xEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset3, delta3, output

	//make a list of indices
	String inputPath="::TempData:MakeEy_Index_Input"
	Make/O/D/N=(size1*size3*(xEnd-xStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size3;j+=1)
			For(k=xStart;k<=xEnd;k+=1)
				input[inputIndex][0]=i
				input[inputIndex][1]=k
				input[inputIndex][2]=j
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size3;j+=1)
			output[i][j]=0
			For(k=xStart;k<=xEnd;k+=1)
				output[i][j]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End


//Function Makexy_Index: make x-y cut (2D map) of 3D cube using Index3D socket
Function/S IAFf_Makexy_Index_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Index3D;Wave2D"
End

Function IAFf_Makexy_Index(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: EStart index (include)
	String EStartArg=StringFromList(3,argumentList)
	
	//4th argument: EEnd index(include)
	String EEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR EStart=$EStartArg
	NVAR EEnd=$EEndArg
	If(EEnd<EStart)
		print("Makexy_Index Error: EStart <= EEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size2,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset2, delta2, output
	SetScale/P y, offset3, delta3, output

	//make a list of indices
	String inputPath="::TempData:Makexy_Index_Input"
	Make/O/D/N=(size2*size3*(EEnd-EStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			For(k=EStart;k<=EEnd;k+=1)
				input[inputIndex][0]=k
				input[inputIndex][1]=i
				input[inputIndex][2]=j
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			output[i][j]=0
			For(k=EStart;k<=EEnd;k+=1)
				output[i][j]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End



//Function Make3D_Index: make 3D cube using Index3D socket
Function/S IAFf_Make3D_Index_Definition()
	return "5;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Index3D;Wave3D"
End

Function IAFf_Make3D_Index(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(3,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(4,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size2,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output
	SetScale/P z, offset3, delta3, output

	//make a list of indices
	String inputPath="::TempData:Make3D_Index_Input"
	Make/O/D/N=(size1*size2,3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k	
	For(k=0;k<size3;k+=1)
		Variable inputIndex=0
		For(i=0;i<size1;i+=1)
			For(j=0;j<size2;j+=1)
				input[inputIndex][0]=i
				input[inputIndex][1]=j
				input[inputIndex][2]=k
				inputIndex+=1
			Endfor
		Endfor
		//call the socket
		String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
		Wave/D socketOutput=$socketOutputPath
		//get data
		Variable outputIndex=0
		For(i=0;i<size1;i+=1)
			For(j=0;j<size2;j+=1)
				output[i][j][k]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End



//Function MakeEx_Coord: make E-x cut (2D map) of 3D cube using Coordinate3D socket
Function/S IAFf_MakeEx_Coord_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Coordinate3D;Wave2D"
End

Function IAFf_MakeEx_Coord(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: yStart index (include)
	String yStartArg=StringFromList(3,argumentList)
	
	//4th argument: yEnd index(include)
	String yEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR yStart=$yStartArg
	NVAR yEnd=$yEndArg
	If(yEnd<yStart)
		print("MakeEk_Coord Error: yStart <= yEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output

	//make a list of indices
	String inputPath="::TempData:MakeEx_Index_Input"
	Make/O/D/N=(size1*size2*(yEnd-yStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			For(k=yStart;k<=yEnd;k+=1)
				input[inputIndex][0]=offset1+delta1*i
				input[inputIndex][1]=offset2+delta2*j
				input[inputIndex][2]=offset3+delta3*k
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			output[i][j]=0
			For(k=yStart;k<=yEnd;k+=1)
				output[i][j]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End


//Function MakeEy_Coord: make E-y cut (2D map) of 3D cube using Coordinate3D socket
Function/S IAFf_MakeEy_Coord_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Coordinate3D;Wave2D"
End

Function IAFf_MakeEy_Coord(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: xStart index (include)
	String xStartArg=StringFromList(3,argumentList)
	
	//4th argument: xEnd index(include)
	String xEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR xStart=$xStartArg
	NVAR xEnd=$xEndArg
	If(xEnd<xStart)
		print("MakeEy_Coord Error: xStart <= xEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset3, delta3, output

	//make a list of indices
	String inputPath="::TempData:MakeEy_Index_Input"
	Make/O/D/N=(size1*size3*(xEnd-xStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size3;j+=1)
			For(k=xStart;k<=xEnd;k+=1)
				input[inputIndex][0]=offset1+delta1*i
				input[inputIndex][1]=offset2+delta2*k
				input[inputIndex][2]=offset3+delta3*j
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size3;j+=1)
			output[i][j]=0
			For(k=xStart;k<=xEnd;k+=1)
				output[i][j]=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End


//Function Makexy_Coord: make x-y cut (2D map) of 3D cube using Coordinate3D socket
Function/S IAFf_Makexy_Coord_Definition()
	return "7;0;0;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Coordinate3D;Wave2D"
End

Function IAFf_Makexy_Coord(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3th argument: EStart index (include)
	String EStartArg=StringFromList(3,argumentList)
	
	//4th argument: EEnd index(include)
	String EEndArg=StringFromList(4,argumentList)
	
	//5th argument: socket name
	String socketName=StringFromList(5,argumentList)
	
	//6rd argument: output wave
	String outputArg=StringFromList(6,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	NVAR EStart=$EStartArg
	NVAR EEnd=$EEndArg
	If(EEnd<EStart)
		print("Makexy_Index Error: EStart <= EEnd must be satisfied")
		abort
	Endif
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size2,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset2, delta2, output
	SetScale/P y, offset3, delta3, output

	//make a list of indices
	String inputPath="::TempData:Makexy_Index_Input"
	Make/O/D/N=(size2*size3*(EEnd-EStart+1),3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	Variable inputIndex=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			For(k=EStart;k<=EEnd;k+=1)
				input[inputIndex][0]=offset1+delta1*k
				input[inputIndex][1]=offset2+delta2*i
				input[inputIndex][2]=offset3+delta3*j
				inputIndex+=1
			Endfor
		Endfor
	Endfor
	//call the socket
	String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
	Wave/D socketOutput=$socketOutputPath
	//get data
	Variable outputIndex=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			output[i][j]=0
			For(k=EStart;k<=EEnd;k+=1)
				output[i][j]+=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End



//Function Make3D_Coord: make 3D cube using Coordinate3D socket
Function/S IAFf_Make3D_Coord_Definition()
	return "5;0;0;0;0;1;Wave1D;Wave1D;Wave1D;Coordinate3D;Wave3D"
End

Function IAFf_Make3D_Coord(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index (E)
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index (x)
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2rd argument: WaveInfo for 3rd index (y)
	String waveInfo3Arg=StringFromList(2,argumentList)
	
	//3rd argument: socket name
	String socketName=StringFromList(3,argumentList)
	
	//4th argument: output wave
	String outputArg=StringFromList(4,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D waveInfo3=$waveInfo3Arg
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]
	Variable offset3=waveInfo3[0]
	Variable delta3=waveInfo3[1]
	Variable size3=waveInfo3[2]

	Make/O/D/N=(size1,size2,size3) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output
	SetScale/P z, offset3, delta3, output

	//make a list of indices
	//to reduce memory, each slice [][][k] is passed to the socket
	String inputPath="::TempData:Make3D_Index_Input"
	Make/O/D/N=(size1*size2,3) $inputPath
	Wave/D input=$inputPath
	
	Variable i,j,k
	For(k=0;k<size3;k+=1)
		Variable inputIndex=0
		For(i=0;i<size1;i+=1)
			For(j=0;j<size2;j+=1)
				input[inputIndex][0]=offset1+delta1*i
				input[inputIndex][1]=offset2+delta2*j
				input[inputIndex][2]=offset3+delta3*k
				inputIndex+=1
			Endfor
		Endfor
		
		//call the socket
		String socketOutputPath=IAFc_CallSocket(socketName,inputPath)
		Wave/D socketOutput=$socketOutputPath
		//get data
		Variable outputIndex=0
		For(i=0;i<size1;i+=1)
			For(j=0;j<size2;j+=1)
				output[i][j][k]=socketOutput[outputIndex]
				outputIndex+=1
			Endfor
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End

