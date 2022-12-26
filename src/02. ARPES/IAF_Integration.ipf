#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function Integrate1D: integrate pixels
Function/S IAFf_Integrate1D_Definition()
	return "4;0;0;0;1;Wave1D;Variable;Variable;Wave1D"
End

Function IAFf_Integrate1D(argumentList)
	String argumentList
	
	//0th argument: input wave
	String inWaveArg=StringFromList(0,argumentList)
	
	//1st argument: integration size
	String intSizeArg=StringFromList(1,argumentList)
	
	//2nd argument: integration offset
	String intOffsetArg=StringFromList(2,argumentList)
	
	//3rd argument: output wave
	String outWaveArg=StringFromList(3,argumentList)
	
	Wave/D input=$inWaveArg
	NVAR intSize=$intSizeArg
	NVAR intOffset=$intOffsetArg
	
	intSize=round(intSize)
	intOffset=round(intOffset)
	
	//validation
	if(intSize<1)
		print("Integrate1D Error: integration size must be positive")
		abort
	Endif

	Variable inDelta=DimDelta(input,0)
	Variable outDelta=inDelta*intSize

	Variable inOffset=DimOffset(input,0)
	Variable outOffset=inOffset+inDelta*intOffset

	Variable inSize=DimSize(input,0)
	Variable outSize=floor((inSize-intOffset)/intSize)

	Make/O/D/N=(outSize) $outWaveArg
	Wave/D output=$outWaveArg
	SetScale/P x, outOffset, outDelta, output
	
	Variable i
	Variable inputIndex=intOffset
	Variable j
	For(i=0;i<outSize;i+=1)
		output[i]=0
		For(j=0;j<intSize;j+=1)
			output[i]+=input[inputIndex]
			inputIndex+=1
		Endfor
	Endfor	
End