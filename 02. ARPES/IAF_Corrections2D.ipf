#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function AveragedMDC: normalized MDC, in which the average is 1
Function/S IAFf_AveragedMDC_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave1D"
End

Function IAFf_AveragedMDC(argumentList)
	String argumentList
	
	//0th argument: wave
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: start index (include)
	String startArg=StringFromList(1,argumentList)
	
	//2nd argument: end index (include)
	String endArg=StringFromList(2,argumentList)
	
	//3rd argument: normalized MDC wave
	String mdcArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR startIndex=$startArg
	NVAR endIndex=$endArg
	
	Variable size1=DimSize(input,0)
	If(startIndex>endIndex || startIndex<0 || endIndex>=size1)
		Print("AveragedMDC Error: index ["+num2str(startIndex)+","+num2str(endIndex)+"] is out of range")
		return 0
	Endif
	
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size2) $mdcArg
	Wave/D mdc=$mdcArg
	SetScale/P x, offset2, delta2, mdc
	mdc[]=0
	
	Variable i
	//get MDC
	For(i=startIndex;i<=endIndex;i+=1)
		mdc[]+=input[i][p]
	Endfor
	
	//normalization
	Variable totalIntensity=0
	For(i=0;i<size2;i+=1)
		totalIntensity+=mdc[i]
	Endfor
	
	Variable averageIntensity=totalIntensity/size2
	mdc[]=mdc[p]/averageIntensity
End

//Function MCPHistogram: histogram of intensity from each pixel
//to determine the valid range for MCP intensity correction in fixed mode
Function/S IAFf_MCPHistogram_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave1D"
End

Function IAFf_MCPHistogram(argumentList)
	String argumentList
	
	//0th argument: wave for MCP intensity correction
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: number of bins of the output histogram
	String numBinsArg=StringFromList(1,argumentList)
	
	//2nd argument: histogram
	String histoArg=StringFromList(2,argumentList)
	
	Wave/D input=$waveArg
	NVAR numBins=$numBinsArg
	Make/O/D/N=(numBins) $histoArg
	
	Histogram/B=1 input $histoArg
End

//Function AveragedInt: normalize MCP intensity so that the average is 1
//The intensities of invalid pixels are set to -1
Function/S IAFf_AveragedInt_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave2D"
End

Function IAFf_AveragedInt(argumentList)
	String argumentList
	
	//0th argument: wave to be averaged
	String waveArg=StringFromList(0,argumentList)
	
	//1st argument: minimum intensity of valid range (include)
	String minIntArg=StringFromList(1,argumentList)
	
	//2nd argument: maximum intensity of valid range (include)
	String maxIntArg=StringFromList(2,argumentList)
	
	//3rd argument: wave of avareged intensity
	String averagedWaveArg=StringFromList(3,argumentList)
	
	Wave/D input=$waveArg
	NVAR minInt=$minIntArg
	NVAR maxInt=$maxIntArg
	
	Variable xSize=DimSize(input,0)
	Variable ySize=DimSize(input,1)
	Variable i,j
	//distinguish valid and invalid pixels and calculate total intensity of valid pixels
	Variable numValidPixels=0
	Variable totalInt=0
	For(i=0;i<xSize;i+=1)
		For(j=0;j<ySize;j+=1)
			if(minInt <= input[i][j] && input[i][j] <= maxInt)
				totalInt+=input[i][j]
				numValidPixels+=1
			Endif
		Endfor
	Endfor
	Duplicate/O input $averagedWaveArg
	Wave/D output=$averagedWaveArg
	Variable averagedInt=totalInt/numValidPixels
	//normalization of intensity of averagedInt
	For(i=0;i<xSize;i+=1)
		For(j=0;j<ySize;j+=1)
			if(minInt <= input[i][j] && input[i][j] <= maxInt)
				output[i][j]=input[i][j]/averagedInt
			Else
				output[i][j]=-1
			Endif
		Endfor
	Endfor
	
End

//Module CorrectInt_sw2D: return intensity of swept 2D data [i][j] normalized by 1D normalization reference [j]
Function/S IAFm_CorrectInt_sw2D_Definition()
	return "3;0;0;2;Wave2D;Wave1D;Index2D"
End

Function/S IAFm_CorrectInt_sw2D(argumentList)
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
	if(DimSize(raw,1)!=DimSize(ref,0))
		print("CorrectInt_sw2D Error: sizes of raw and reference are different")
		abort
	Endif
	
	Variable size1=DimSize(raw,0)
	Variable size2=DimSize(raw,1)
	
	Wave/D indices=$indicesArg
	Variable dataSize=DimSize(indices,0)
	
	//output wave (the name of it is returned)
	String outputPath="::TempData:CorrectInt_sw2D_Output"
	Make/O/D/N=(dataSize) $outputPath
	Wave/D output=$outputPath
	
	Variable i
	Variable index1,index2
	For(i=0;i<dataSize;i+=1)
		index1=indices[i][0]
		index2=indices[i][1]
		//range check
		If(index1<0 || size1<=index1 || index2<0 || size2<=index2)
			output[i]=0
		Else
			output[i]=raw[index1][index2]/ref[index2]
		Endif
	Endfor
	return outputPath
End

//Function ConstantWave1D: make a constant wave
Function/S IAFf_ConstantWave1D_Definition()
	return "3;0;0;1;Variable;Wave1D;Wave1D"
End

Function IAFf_ConstantWave1D(argumentList)
	String argumentList
	
	//0th argument: constant value
	String constValueArg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo
	String waveInfoArg=StringFromList(1,argumentList)
	
	//2nd argument: output
	String outputArg=StringFromList(2,argumentList)
	
	NVAR constValue=$constValueArg
	Wave/D waveInformation=$waveInfoArg
	Variable offset=waveInformation[0]
	Variable delta=waveInformation[1]
	Variable size=waveInformation[2]
	
	
	Make/O/D/N=(size) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset, delta, output
	output[]=constValue
End

//Module ConvertIndex2D: convert index to coordinate
Function/S IAFm_ConvertIndex2D_Definition()
	return "5;0;0;0;0;2;Variable;Wave1D;Wave1D;Index2D;Coordinate2D"
End

Function/S IAFm_ConvertIndex2D(argumentList)
	String argumentList
	
	//0th argument: convert mode
	//0: nearest point
	//1: interpolation of surrounding 4 points
	String convertModeArg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for first index
	String waveInfo1Arg=StringFromList(1,argumentList)
	
	//2nd argument: WaveInfo for second index
	String waveInfo2Arg=StringFromList(2,argumentList)
	
	//3rd argument: socket to which an indices wave is passed
	String indicesSocketName=StringFromList(3,argumentList)
	
	//4th argument: coordinates wave passed through socket
	String coordinatesArg=StringFromList(4,argumentList)
	
	NVAR convertMode=$convertModeArg
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	Wave/D coordinates=$coordinatesArg
	Variable coordinatesSize=DimSize(coordinates,0)
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	
	String indicesPath="::TempData:ConvertIndex2D_Input"
	String fracIndicesPath="::TempData:ConvertIndex2D_frac"
	Variable i=0 //for indices
	Variable j=0 //for coordinates
	//make indices wave
	If(convertMode==1)
		//interpolation
		Make/O/D/N=(coordinatesSize*4,2) $indicesPath
		Wave/D indices=$indicesPath
		Make/O/D/N=(coordinatesSize,2) $fracIndicesPath
		Wave/D fracIndices=$fracIndicesPath
		For(j=0;j<coordinatesSize;j+=1)
			fracIndices[j][0]=(coordinates[j][0]-offset1)/delta1
			fracIndices[j][1]=(coordinates[j][1]-offset2)/delta2
			Variable index1_floor=floor(fracIndices[j][0])
			Variable index2_floor=floor(fracIndices[j][1])
			fracIndices[j][0]-=index1_floor
			fracIndices[j][1]-=index2_floor
			// 43
			// 12
			indices[i][0]=index1_floor
			indices[i][1]=index2_floor
			indices[i+1][0]=index1_floor+1
			indices[i+1][1]=index2_floor
			indices[i+2][0]=index1_floor+1
			indices[i+2][1]=index2_floor+1
			indices[i+3][0]=index1_floor
			indices[i+3][1]=index2_floor+1
			i+=4
		Endfor
	Else
		//nearest
		Make/O/D/N=(coordinatesSize,2) $indicesPath
		Wave/D indices=$indicesPath
		For(j=0;j<coordinatesSize;j+=1)
			indices[i][0]=round((coordinates[j][0]-offset1)/delta1)
			indices[i][1]=round((coordinates[j][1]-offset2)/delta2)
			i+=1
		Endfor
	Endif
	
	String socketOutputPath=IAFc_CallSocket(indicesSocketName,indicesPath)
	Wave/D socketOutput=$socketOutputPath
	
	//make the output
	String outputPath="::TempData:ConvertIndex2D_Output"
	Make/O/D/N=(coordinatesSize) $outputPath
	Wave/D output=$outputPath
	i=0
	j=0
	If(convertMode==1)
		//interpolation
		For(;j<coordinatesSize;j+=1)
			Variable int_00=socketOutput[i]
			Variable int_10=socketOutput[i+1]
			Variable int_11=socketOutput[i+2]
			Variable int_01=socketOutput[i+3]
			i+=4
			output[j]=int_00*(1-fracIndices[j][0])*(1-fracIndices[j][1])
			output[j]+=int_10*(fracIndices[j][0])*(1-fracIndices[j][1])
			output[j]+=int_11*(fracIndices[j][0])*(fracIndices[j][1])
			output[j]+=int_01*(1-fracIndices[j][0])*(fracIndices[j][1])
		Endfor
	Else
		//nearest
		output[]=socketOutput[p]
	Endif
	
	killwaves indices,socketOutput
	if(waveexists(fracIndices)==1)
		killwaves fracIndices
	Endif
	return outputPath
End

//Module CorrectEf2D: set fermi energy to zero
Function/S IAFm_CorrectEf2D_Definition()
	return "4;0;0;0;2;Variable;Wave1D;Coordinate2D;Coordinate2D"
End

Function/S IAFm_CorrectEf2D(argumentList)
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
	
	String socketInputPath="::TempData:CorrectEf2D_Input"
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
	
//Function CorrectEf2D_F: Format function of Module CorrectEf2D
Function/S IAFf_CorrectEf2D_F_Definition()
	return "5;0;0;0;1;1;Wave1D;Wave1D;Wave1D;Wave1D;Wave1D"
End

Function IAFf_CorrectEf2D_F(argumentList)
	String argumentList
	
	//0th argument: input WaveInfo for 1st index
	String inWaveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: input WaveInfo for 2nd index
	String inWaveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: Ef wave
	String EfWaveArg=StringFromList(2,argumentList)
	
	//3rd argument: output WaveInfo for 1st index
	String outWaveInfo1Arg=StringFromList(3,argumentList)
	
	//4th argument: output WaveInfo for 2nd index (same as inWaveInfo2)
	String outWaveInfo2Arg=StringFromList(4,argumentList)
	
	Wave/D inWaveInfo1=$inWaveInfo1Arg
	Wave/D inWaveInfo2=$inWaveInfo2Arg
	Wave/D EfWave=$EfWaveArg
	
	//Angle: kept same
	Duplicate/O inWaveInfo2 $outWaveInfo2Arg
	
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
	String TempShiftPath="::TempData:CorrectEf2D_F_shift"
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


//Function Make2D_Index: make 2D map using Index2D socket
Function/S IAFf_Make2D_Index_Definition()
	return "4;0;0;0;1;Wave1D;Wave1D;Index2D;Wave2D"
End

Function IAFf_Make2D_Index(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: socket name
	String socketName=StringFromList(2,argumentList)
	
	//3rd argument: output wave
	String outputArg=StringFromList(3,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]

	Make/O/D/N=(size1,size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output

	//make a list of indices
	String inputPath="::TempData:Make2D_Index_Input"
	Make/O/D/N=(size1*size2,2) $inputPath
	Wave/D input=$inputPath
		
	Variable i,j
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			input[inputIndex][0]=i
			input[inputIndex][1]=j
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
			output[i][j]=socketOutput[outputIndex]
			outputIndex+=1
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End


//Function Make2D_Coord: make 2D map using Coordinate2D socket
Function/S IAFf_Make2D_Coord_Definition()
	return "4;0;0;0;1;Wave1D;Wave1D;Coordinate2D;Wave2D"
End

Function IAFf_Make2D_Coord(argumentList)
	String argumentList
	
	//0th argument: WaveInfo for 1st index
	String waveInfo1Arg=StringFromList(0,argumentList)
	
	//1st argument: WaveInfo for 2nd index
	String waveInfo2Arg=StringFromList(1,argumentList)
	
	//2nd argument: socket name
	String socketName=StringFromList(2,argumentList)
	
	//3rd argument: output wave
	String outputArg=StringFromList(3,argumentList)
	
	Wave/D waveInfo1=$waveInfo1Arg
	Wave/D waveInfo2=$waveInfo2Arg
	
	Variable offset1=waveInfo1[0]
	Variable delta1=waveInfo1[1]
	Variable size1=waveInfo1[2]
	Variable offset2=waveInfo2[0]
	Variable delta2=waveInfo2[1]
	Variable size2=waveInfo2[2]

	Make/O/D/N=(size1,size2) $outputArg
	Wave/D output=$outputArg
	SetScale/P x, offset1, delta1, output
	SetScale/P y, offset2, delta2, output

	//make a list of indices
	String inputPath="::TempData:Make2D_Coord_Input"
	Make/O/D/N=(size1*size2,2) $inputPath
	Wave/D input=$inputPath
		
	Variable i,j
	Variable inputIndex=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			input[inputIndex][0]=offset1+delta1*i
			input[inputIndex][1]=offset2+delta2*j
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
			output[i][j]=socketOutput[outputIndex]
			outputIndex+=1
		Endfor
	Endfor
	
	KillWaves socketOutput,input
End

