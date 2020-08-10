#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function DivideWave2D: return a[i][j]/b[i][j] if b[i][j]>threshold, 0 otherwise
Function/S IAFf_DivideWave2D_Definition()
	return "4;0;0;0;1;Wave2D;Wave2D;Variable;Wave2D"
End

Function IAFf_DivideWave2D(argumentList)
	String argumentList

	//0th argument: a[][]
	String aWaveArg=StringFromList(0,argumentList)
	
	//1st argument: b[][]
	String bWaveArg=StringFromList(1,argumentList)
	
	//2nd argument: threshold for b[i][j]
	String thresholdArg=StringFromList(2,argumentList)
	
	//3rd argument: output a[][]/b[][]
	String cWaveArg=StringFromList(3,argumentList)
	
	Wave/D aWave=$aWaveArg
	Wave/D bWave=$bWaveArg
	NVAR threshold=$thresholdArg
	
	//size check
	if(DimSize(aWave,0)!=DimSize(bWave,0) || DimSize(aWave,1)!=DimSize(bWave,1))
		print ("DivideWave2D Error: size mismatch")
		abort
	endif
	
	Variable size1=DimSize(aWave,0)
	Variable size2=DimSize(aWave,1)
	
	Duplicate/O aWave $cWaveArg
	Wave/D cWave=$cWaveArg
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			if(bWave[i][j]>threshold)
				cWave[i][j]=aWave[i][j]/bWave[i][j]
			Else
				cWave[i][j]=0
			Endif
		Endfor
	Endfor
	
End
