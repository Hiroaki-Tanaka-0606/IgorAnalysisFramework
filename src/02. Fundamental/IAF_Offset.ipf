#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/S IAFf_Offset2D_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave2D"
End

Function IAFf_Offset2D(argumentList)
	String argumentList
	
	// 0th argument: input
	String inArg=stringfromlist(0, argumentList)
	
	// 1st and 2nd arguments: offsets for 1st and 2nd axes
	String offset1Arg=stringfromlist(1, argumentList)
	String offset2Arg=stringfromlist(2, argumentList)
	
	// 3rd argument: output
	String outArg=stringfromlist(3, argumentList)
	
	NVAR offset1=$offset1Arg
	NVAR offset2=$offset2Arg
	
	duplicate/o/d $inArg $outArg
	Wave/d out=$outArg
	
	variable offset=dimoffset(out, 0)
	variable delta=dimdelta(out, 0)
	
	setscale/p x, offset+offset1, delta, out
	
	offset=dimoffset(out, 1)
	delta=dimdelta(out, 1)
	
	setscale/p y, offset+offset2, delta, out

End