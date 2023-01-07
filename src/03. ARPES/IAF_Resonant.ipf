#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function MakeResMap: make resonant map (E-hn)
Function/S IAFf_MakeResMap_Definition()
	return "3;0;0;1;TextWave;Wave1D;Wave2D"
End

Function IAFf_MakeResMap(argumentList)
	String argumentList
	
	//0th argument (input): list of EDCs
	//scale(offset, delta) is interpreted as hn
	String ListArg=StringFromList(0,argumentList)
	
	//1st argument (input): list of Ef values
	//scale is not used
	String EfArg=StringFromList(1,argumentList)
	
	//2nd argument (output): output resonant map (E-hn)
	String ResMapArg=StringFromList(2,argumentList)
	
	Wave/T list=$ListArg
	Wave/D Ef=$EfArg
	
	//size check
	Variable hnOffset=DimOffset(list,0)
	Variable hnDelta=DimDelta(list,0)
	Variable hnSize=DimSize(list,0)
	Variable hnSize2=DImSize(Ef,0)
	if(hnsize!=hnsize2)
		print("MakeResMap Error: lists of EDCs and Ef values have different number of elements")
		abort
	Endif
	
	//using the first element, get waveinfo of EDC
	Wave/D map0=$("::"+list[0])
	Variable mapDelta=DimDelta(map0,0)
	Variable mapSize=DimSize(map0,0)
	
	//get the average of offset (after correcting Ef position)
	Variable offsetSum=0
	Variable i
	For(i=0;i<hnSize;i+=1)
		Wave/D map_i=$("::"+list[i])
		Variable offset_i=DimOffset(map_i,0)
		Variable ef_i=Ef[i]
		offsetSum+=(offset_i-ef_i)
	Endfor
	Variable offsetAverage=offsetSum/hnSize
	
	//get the min, max of pixel shift
	Variable minShift=0
	Variable maxShift=0
	For(i=0;i<hnSize;i+=1)
		Wave/D map_i=$("::"+list[i])
		offset_i=DimOffset(map_i,0)
		ef_i=Ef[i]
		Variable shift_i=round((offset_i-ef_i-offsetAverage)/mapDelta)
		if(shift_i<minShift)
			minShift=shift_i
		Endif
		if(shift_i>maxShift)
			maxShift=shift_i
		Endif
	Endfor
	
	//make map
	Make/O/D/N=(mapSize-minShift+maxShift,hnSize) $ResMapArg
	Wave/D ResMap=$ResMapArg
	SetScale/P x, offsetAverage+minShift*mapDelta, mapDelta, ResMap
	SetScale/P y, hnOffset, hnDelta, ResMap
	ResMap[][]=0
	
	//set values
	Variable j
	For(i=0;i<hnSize;i+=1)
		Wave/D map_i=$("::"+list[i])
		offset_i=DimOffset(map_i,0)
		ef_i=Ef[i]
		shift_i=round((offset_i-ef_i-offsetAverage)/mapDelta)
		For(j=0;j<mapSize;j+=1)
			ResMap[j+shift_i-minShift][i]=map_i[j]
		Endfor
	Endfor
End