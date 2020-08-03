#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function LoadWave1D: load 1D wave using relative path from the current folder
Function/S IAFf_LoadWave1D_Definition()
	return "2;0;1;String;Wave1D"
End

Function IAFf_LoadWave1D(argumentList)
	String argumentList
	
	//0th argument: wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument: Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("LoadWave1D Error: Wave "+wavePath+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)==0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("LoadWave1D Error: Wave "+wavePath+" is not one-dimensional")
		return 0
	Endif
End

//Function WaveInfo1D: create wave containing [offset,delta,size]
Function/S IAFf_WaveInfo1D_Definition()
	return "2;0;1;Wave1D;Wave1D"
End

Function IAFf_WaveInfo1D(argumentList)
	String argumentList
	
	//0th argument: wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: info wave
	String outputArg=StringFromList(1,argumentList)
	
	Wave/D input=$inputArg
	Make/O/D/N=3 $outputArg
	Wave/D output=$outputArg
	output[0]=DimOffset(input,0)
	output[1]=DimDelta(input,0)
	output[2]=DimSize(input,0)
End

//Function LoadWave2D: load 2D wave using relative path from the current folder
Function/S IAFf_LoadWave2D_Definition()
	return "2;0;1;String;Wave2D"
End

Function IAFf_LoadWave2D(argumentList)
	String argumentList
	
	//0th argument: wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument: Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("LoadWave2D Error: Wave "+wavePath+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("LoadWave2D Error: Wave "+wavePath+" is not two-dimensional")
		return 0
	Endif
End

//Function WaveInfo2D: create wave containing [offset,delta,size]
Function/S IAFf_WaveInfo2D_Definition()
	return "3;0;1;1;Wave2D;Wave1D;Wave1D"
End

Function IAFf_WaveInfo2D(argumentList)
	String argumentList
	
	//0th argument: wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: x info wave
	String xoutputArg=StringFromList(1,argumentList)
	
	//2nd argument: y info wave
	String youtputArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	Make/O/D/N=3 $xoutputArg
	Wave/D xoutput=$xoutputArg
	xoutput[0]=DimOffset(input,0)
	xoutput[1]=DimDelta(input,0)
	xoutput[2]=DimSize(input,0)
	
	Make/O/D/N=3 $youtputArg
	Wave/D youtput=$youtputArg
	youtput[0]=DimOffset(input,1)
	youtput[1]=DimDelta(input,1)
	youtput[2]=DimSize(input,1)
	
End

//Function LoadWave3D: load 3D wave using relative path from the current folder
Function/S IAFf_LoadWave3D_Definition()
	return "2;0;1;String;Wave3D"
End

Function IAFf_LoadWave3D(argumentList)
	String argumentList
	
	//0th argument: wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument: Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("LoadWave3D Error: Wave "+wavePath+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)>0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("LoadWave3D Error: Wave "+wavePath+" is not three-dimensional")
		return 0
	Endif
End


//Function WaveInfo3D: create wave containing [offset,delta,size]
Function/S IAFf_WaveInfo3D_Definition()
	return "4;0;1;1;1;Wave3D;Wave1D;Wave1D;Wave1D"
End

Function IAFf_WaveInfo3D(argumentList)
	String argumentList
	
	//0th argument: wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: x info wave
	String xoutputArg=StringFromList(1,argumentList)
	
	//2nd argument: y info wave
	String youtputArg=StringFromList(2,argumentList)
	
	//3rd argument: z info wave
	String zoutputArg=StringFromList(3,argumentList)
	
	Wave/D input=$inputArg
	Make/O/D/N=3 $xoutputArg
	Wave/D xoutput=$xoutputArg
	xoutput[0]=DimOffset(input,0)
	xoutput[1]=DimDelta(input,0)
	xoutput[2]=DimSize(input,0)
	
	Make/O/D/N=3 $youtputArg
	Wave/D youtput=$youtputArg
	youtput[0]=DimOffset(input,1)
	youtput[1]=DimDelta(input,1)
	youtput[2]=DimSize(input,1)
	
	
	Make/O/D/N=3 $zoutputArg
	Wave/D zoutput=$zoutputArg
	zoutput[0]=DimOffset(input,2)
	zoutput[1]=DimDelta(input,2)
	zoutput[2]=DimSize(input,2)
End

//Function FullRange: return first and last index from WaveInfo
Function/S IAFf_FullRange_Definition()
	return "3;0;1;1;Wave1D;Variable;Variable"
End

Function IAFf_FullRange(argumentList)
	String argumentList
	
	//0th argument: WaveInfo
	String infoArg=StringFromList(0,argumentList)
	
	//1st argument: first index
	String firstIndexArg=StringFromList(1,argumentList)
	
	//2nd argument: last index
	String lastIndexArg=StringFromList(2,argumentList)
	
	Wave/D info=$infoArg
	
	Variable/G $firstIndexArg=0
	Variable/G $lastIndexArg=info[2]-1
End