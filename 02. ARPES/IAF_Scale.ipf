#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//function scale2d: change the scale of x and y axes
Function/S IAFf_Scale2D_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_Scale2D(argumentList)
	String argumentList
	
	//0th: input wave 
	String inputArg=StringFromList(0,argumentList)
	
	//1st: scaling factor
	String scaleArg=StringFromList(1,argumentList)
	
	//2nd: output wave
	String outputArg=StringFromList(2,argumentList)
	
	Duplicate/O $inputArg $outputArg
	Wave/D output=$outputArg
	NVAR scale=$scaleArg
	
	Variable offset1=DimOffset(output,0)
	Variable delta1=DimDelta(output,0)

	Variable offset2=DimOffset(output,1)
	Variable delta2=DimDelta(output,1)
	
	SetScale/P x, offset1*scale, delta1*scale, output
	SetScale/P y, offset2*scale, delta2*scale, output
End
	

//function scale2dx: change the scale of x axis
Function/S IAFf_Scale2DX_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_Scale2DX(argumentList)
	String argumentList
	
	//0th: input wave 
	String inputArg=StringFromList(0,argumentList)
	
	//1st: scaling factor
	String scaleArg=StringFromList(1,argumentList)
	
	//2nd: output wave
	String outputArg=StringFromList(2,argumentList)
	
	Duplicate/O $inputArg $outputArg
	Wave/D output=$outputArg
	NVAR scale=$scaleArg
	

	Variable offset1=DimOffset(output,0)
	Variable delta1=DimDelta(output,0)
	
	SetScale/P x, offset1*scale, delta1*scale, output
End
		
	
//function scale2dy: change the scale of y axis
Function/S IAFf_Scale2DY_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_Scale2DY(argumentList)
	String argumentList
	
	//0th: input wave 
	String inputArg=StringFromList(0,argumentList)
	
	//1st: scaling factor
	String scaleArg=StringFromList(1,argumentList)
	
	//2nd: output wave
	String outputArg=StringFromList(2,argumentList)
	
	Duplicate/O $inputArg $outputArg
	Wave/D output=$outputArg
	NVAR scale=$scaleArg
	

	Variable offset2=DimOffset(output,1)
	Variable delta2=DimDelta(output,1)
	
	SetScale/P y, offset2*scale, delta2*scale, output
End
	