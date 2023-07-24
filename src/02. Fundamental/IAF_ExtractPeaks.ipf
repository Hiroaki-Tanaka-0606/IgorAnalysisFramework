#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// extract maxima from slices along x
Function/S IAFf_ExtractPeaks2DX_Definition()
	return "2;0;1;Wave2D;Wave1D"
	
end

Function IAFf_ExtractPeaks2DX(argumentList)
	String argumentList
	
	// 0th argument: input (2D wave)
	String inArg=stringfromlist(0, argumentList)
	
	// 1st argument: peak positions
	String outArg=stringFromList(1, argumentList)
	
	wave/D input=$inArg
	
	Variable size0=dimsize(input, 0)
	Variable offset0=dimoffset(input, 0)
	Variable delta0=dimdelta(input, 0)
	Variable size1=dimsize(input, 1)
	Variable offset1=dimoffset(input, 1)
	Variable delta1=dimdelta(input, 1)
	
	make/o/d/n=(size1) $outArg
	Wave/D output=$outArg
	setscale/p x, offset1, delta1, output
	
	Variable i
	Variable j
	for(i=0; i<size1; i++)
		Variable maxValue=0
		Variable maxIndex=-1
		for(j=0; j<size0; j++)
			if(maxIndex<0 || maxValue<input[j][i])
				maxIndex=j
				maxValue=input[j][i]
			endif
		endfor
		output[i]=offset0+delta0*maxIndex
	endfor
end

// extract maxima from slices along y
Function/S IAFf_ExtractPeaks2DY_Definition()
	return "2;0;1;Wave2D;Wave1D"
	
end

Function IAFf_ExtractPeaks2DY(argumentList)
	String argumentList
	
	// 0th argument: input (2D wave)
	String inArg=stringfromlist(0, argumentList)
	
	// 1st argument: peak positions
	String outArg=stringFromList(1, argumentList)
	
	wave/D input=$inArg
	
	Variable size0=dimsize(input, 0)
	Variable offset0=dimoffset(input, 0)
	Variable delta0=dimdelta(input, 0)
	Variable size1=dimsize(input, 1)
	Variable offset1=dimoffset(input, 1)
	Variable delta1=dimdelta(input, 1)
	
	make/o/d/n=(size0) $outArg
	Wave/D output=$outArg
	setscale/p x, offset0, delta0, output
	
	Variable i
	Variable j
	for(i=0; i<size0; i++)
		Variable maxValue=0
		Variable maxIndex=-1
		for(j=0; j<size1; j++)
			if(maxIndex<0 || maxValue<input[i][j])
				maxIndex=j
				maxValue=input[i][j]
			endif
		endfor
		output[i]=offset1+delta1*maxIndex
	endfor
end