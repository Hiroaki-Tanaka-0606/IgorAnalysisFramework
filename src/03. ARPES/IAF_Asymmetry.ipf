#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/S IAFf_Asymmetry2DX_Definition()
	return "2;0;1;Wave2D;Wave2D"
End

Function IAFf_Asymmetry2DX(argumentList)
	String argumentList
	
	// 0th argument: input
	String inArg=stringfromlist(0, argumentList)
	
	// 1st argument: output
	String outArg=stringfromlist(1, argumentList)
	
	wave/d in=$inArg
	
	variable xSize=dimsize(in, 0)
	
	duplicate/o in $outArg
	wave/d out=$outArg
	
	out[][]=(in[p][q]-in[xSize-p-1][q])/(in[p][q]+in[xSize-p-1][q])
end