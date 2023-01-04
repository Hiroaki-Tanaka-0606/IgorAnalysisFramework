#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function LoadWave1D: load 1D wave using relative path from the current folder
Function/S IAFf_LoadWave1D_Definition()
	return "2;0;1;String;Wave1D"
End

Function IAFf_LoadWave1D(argumentList)
	String argumentList
	
	//0th argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument (output): Wave name
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
	
	//0th argument (input): wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): info wave
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
	
	//0th argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument (output): Wave name
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
	
	//0th argument (input): wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): x info wave
	String xoutputArg=StringFromList(1,argumentList)
	
	//2nd argument (output): y info wave
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
	
	//0th argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument (output): Wave name
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
	
	//0th argument (input): wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): x info wave
	String xoutputArg=StringFromList(1,argumentList)
	
	//2nd argument (output): y info wave
	String youtputArg=StringFromList(2,argumentList)
	
	//3rd argument (output): z info wave
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


//Function LoadWave4D: load 4D wave using relative path from the current folder
Function/S IAFf_LoadWave4D_Definition()
	return "2;0;1;String;Wave4D"
End

Function IAFf_LoadWave4D(argumentList)
	String argumentList
	
	//0th argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument (output): Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("LoadWave4D Error: Wave "+wavePath+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)>0 && DimSize(loadedWave,3)>0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("LoadWave4D Error: Wave "+wavePath+" is not four-dimensional")
		return 0
	Endif
End


//Function WaveInfo4D: create wave containing [offset,delta,size]
Function/S IAFf_WaveInfo4D_Definition()
	return "5;0;1;1;1;1;Wave4D;Wave1D;Wave1D;Wave1D;Wave1D"
End

Function IAFf_WaveInfo4D(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): x info wave
	String xoutputArg=StringFromList(1,argumentList)
	
	//2nd argument (output): y info wave
	String youtputArg=StringFromList(2,argumentList)
	
	//3rd argument (output): z info wave
	String zoutputArg=StringFromList(3,argumentList)
	
	//4th argument (output): t info wave
	String toutputArg=StringFromList(4,argumentList)
	
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
	
	Make/O/D/N=3 $toutputArg
	Wave/D toutput=$toutputArg
	toutput[0]=DimOffset(input,3)
	toutput[1]=DimDelta(input,3)
	toutput[2]=DimSize(input,3)
End

//Function LoadTextWave: load textwave using relative path from the current folder
Function/S IAFf_LoadTextWave_Definition()
	return "2;0;1;String;TextWave"
End

Function IAFf_LoadTextWave(argumentList)
	String argumentList
	
	//0th argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(0,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	//1st argument (output): Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/T loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("LoadTextWave Error: Wave "+wavePath+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)==0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("LoadTextWave Error: Wave "+wavePath+" is not one-dimensional")
		return 0
	Endif
End


//Function WaveInfoText: create wave containing [offset,delta,size]
Function/S IAFf_WaveInfoText_Definition()
	return "2;0;1;TextWave;Wave1D"
End

Function IAFf_WaveInfoText(argumentList)
	String argumentList
	
	//0th argument (input): wave
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument (output): info wave
	String outputArg=StringFromList(1,argumentList)
	
	Wave/T input=$inputArg
	Make/O/D/N=3 $outputArg
	Wave/D output=$outputArg
	output[0]=DimOffset(input,0)
	output[1]=DimDelta(input,0)
	output[2]=DimSize(input,0)
End

//Function FullRange: return first and last index from InfoWave
Function/S IAFf_FullRange_Definition()
	return "3;0;1;1;Wave1D;Variable;Variable"
End

Function IAFf_FullRange(argumentList)
	String argumentList
	
	//0th argument (input): InfoWave
	String infoArg=StringFromList(0,argumentList)
	
	//1st argument (output): first index
	String firstIndexArg=StringFromList(1,argumentList)
	
	//2nd argument (output): last index
	String lastIndexArg=StringFromList(2,argumentList)
	
	Wave/D info=$infoArg
	
	Variable/G $firstIndexArg=0
	Variable/G $lastIndexArg=info[2]-1
End


//Function StoreWave1D: Store 1D wave using relative path from the current folder
Function/S IAFf_StoreWave1D_Definition()
	return "2;0;0;Wave1D;String"
End

Function IAFf_StoreWave1D(argumentList)
	String argumentList
	
	//0th argument (input): Wave name
	String waveNameArg=StringFromList(0,argumentList)
	
	//1st argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(1,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	Wave/D loadedWave=$waveNameArg
	If(!WaveExists(loadedWave))
		Print("StoreWave1D Error: Wave "+waveNameArg+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)==0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $relativeWavePath
	Else
		//not ok
		Print("StoreWave1D Error: Wave "+waveNameArg+" is not one-dimensional")
		return 0
	Endif
End


//Function StoreWave2D: Store 2D wave using relative path from the current folder
Function/S IAFf_StoreWave2D_Definition()
	return "2;0;0;Wave2D;String"
End

Function IAFf_StoreWave2D(argumentList)
	String argumentList
	
	//0th argument (input): Wave name
	String waveNameArg=StringFromList(0,argumentList)
	
	//1st argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(1,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	Wave/D loadedWave=$waveNameArg
	If(!WaveExists(loadedWave))
		Print("StoreWave2D Error: Wave "+waveNameArg+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $relativeWavePath
	Else
		//not ok
		Print("StoreWave2D Error: Wave "+waveNameArg+" is not two-dimensional")
		return 0
	Endif
End



//Function StoreWave3D: Store 3D wave using relative path from the current folder
Function/S IAFf_StoreWave3D_Definition()
	return "2;0;0;Wave3D;String"
End

Function IAFf_StoreWave3D(argumentList)
	String argumentList
	
	//0th argument (input): Wave name
	String waveNameArg=StringFromList(0,argumentList)
	
	//1st argument (input): wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathArg=StringFromList(1,argumentList)
	
	SVAR wavePath=$wavePathArg
	String relativeWavePath="::"+wavePath
	
	Wave/D loadedWave=$waveNameArg
	If(!WaveExists(loadedWave))
		Print("StoreWave3D Error: Wave "+waveNameArg+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)>0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $relativeWavePath
	Else
		//not ok
		Print("StoreWave3D Error: Wave "+waveNameArg+" is not two-dimensional")
		return 0
	Endif
End

//Function CombineWave1D: load 1D waves using relative path from the current folder, combine them
Function/S IAFf_CombineWave1D_Definition()
	return "2;0;1;TextWave;Wave1D"
End

Function IAFf_CombineWave1D(argumentList)
	String argumentList
	
	//0th argument (input): list of wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathsArg=StringFromList(0,argumentList)
	
	Wave/T wavePaths=$wavePathsArg
	String wavePath0=wavePaths[0]
	String relativeWavePath="::"+wavePath0
		
	//1st argument (output): Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("CombineWave1D Error: Wave "+wavePath0+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)==0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("CombineWave1D Error: Wave "+wavePath0+" is not one-dimensional")
		return 0
	Endif
	
	Wave/D output=$waveNameArg
	Variable i
	for(i=1; i<DimSize(wavePaths,0); i+=1)
		relativeWavePath="::"+wavePaths[i]
		Wave/D loadedWave=$relativeWavePath
		If(!WaveExists(loadedWave))
			Print("CombineWave1D Error: wave "+wavePaths[i]+" does not exist")
			return 0
		endif
		//dimension check
		If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)==0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
			// size check
			if(DimSize(loadedWave, 0)==DimSize(output, 0))
				//add to the output
				output[]+=loadedWave[p]
			else
				Print("CombineWave1D error: Size error in wave "+wavePaths[i])
				return 0
			endif
		else
			Print("CombineWave1D error: Wave "+wavePaths[i]+" is not one-dimensional")
		endif
	endfor
End

//Function CombineWave2D: load 2D waves using relative path from the current folder, combine them
Function/S IAFf_CombineWave2D_Definition()
	return "2;0;1;TextWave;Wave2D"
End

Function IAFf_CombineWave2D(argumentList)
	String argumentList
	
	//0th argument (input): list of wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathsArg=StringFromList(0,argumentList)
	
	Wave/T wavePaths=$wavePathsArg
	String wavePath0=wavePaths[0]
	String relativeWavePath="::"+wavePath0
		
	//1st argument (output): Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("CombineWave2D Error: Wave "+wavePath0+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("CombineWave2D Error: Wave "+wavePath0+" is not two-dimensional")
		return 0
	Endif
	
	Wave/D output=$waveNameArg
	Variable i
	for(i=1; i<DimSize(wavePaths,0); i+=1)
		relativeWavePath="::"+wavePaths[i]
		Wave/D loadedWave=$relativeWavePath
		If(!WaveExists(loadedWave))
			Print("CombineWave2D Error: wave "+wavePaths[i]+" does not exist")
			return 0
		endif
		//dimension check
		If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)==0 && DimSize(loadedWave,3)==0)
			// size check
			if(DimSize(loadedWave, 0)==DimSize(output, 0) && DimSize(loadedWave, 1)==DimSize(output,1))
				//add to the output
				output[][]+=loadedWave[p][q]
			else
				Print("CombineWave2D error: Size error in wave "+wavePaths[i])
				return 0
			endif
		else
			Print("CombineWave2D error: Wave "+wavePaths[i]+" is not two-dimensional")
		endif
	endfor
End

//Function CombineWave3D: load 3D waves using relative path from the current folder, combine them
Function/S IAFf_CombineWave3D_Definition()
	return "2;0;1;TextWave;Wave3D"
End

Function IAFf_CombineWave3D(argumentList)
	String argumentList
	
	//0th argument (input): list of wavePath
	//starts from the foldername (or directly waveName), not starts from ":"
	String wavePathsArg=StringFromList(0,argumentList)
	
	Wave/T wavePaths=$wavePathsArg
	String wavePath0=wavePaths[0]
	String relativeWavePath="::"+wavePath0
		
	//1st argument (output): Wave name
	String waveNameArg=StringFromList(1,argumentList)
	
	Wave/D loadedWave=$relativeWavePath
	If(!WaveExists(loadedWave))
		Print("CombineWave3D Error: Wave "+wavePath0+" does not exist")
		return 0
	Endif
	
	//dimension check
	If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)>0 && DimSize(loadedWave,3)==0)
		//ok
		Duplicate/O loadedWave $waveNameArg
	Else
		//not ok
		Print("CombineWave3D Error: Wave "+wavePath0+" is not three-dimensional")
		return 0
	Endif
	
	Wave/D output=$waveNameArg
	Variable i
	for(i=1; i<DimSize(wavePaths,0); i+=1)
		relativeWavePath="::"+wavePaths[i]
		Wave/D loadedWave=$relativeWavePath
		If(!WaveExists(loadedWave))
			Print("CombineWave3D Error: wave "+wavePaths[i]+" does not exist")
			return 0
		endif
		//dimension check
		If(DimSize(loadedWave,0)>0 && DimSize(loadedWave,1)>0 && DimSize(loadedWave,2)>0 && DimSize(loadedWave,3)==0)
			// size check
			if(DimSize(loadedWave, 0)==DimSize(output, 0) && DimSize(loadedWave, 1)==DimSize(output,1) && DimSize(loadedWave, 2)==DimSize(output,2))
				//add to the output
				output[][][]+=loadedWave[p][q][r]
			else
				Print("CombineWave3D error: Size error in wave "+wavePaths[i])
				return 0
			endif
		else
			Print("CombineWave3D error: Wave "+wavePaths[i]+" is not three-dimensional")
		endif
	endfor
End