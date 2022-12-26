#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/S IAFf_SecondDeriv2D_E_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_SecondDeriv2D_E(argumentList)
	String argumentList
	
	//0th: input
	String inputArg=StringFromList(0, argumentList)
	
	//1st: smoothing width
	String widthArg=StringFromList(1, argumentList)
	
	//2nd: output
	String outputArg=StringFromList(2, argumentList)
	
	Wave/D input=$inputArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	NVAR width=$widthArg
	
	Variable eSize=DimSize(input, 0)
	Variable kSize=dimsize(input, 1)
	Variable de=dimdelta(input, 0)
	Variable i, j
	for(j=0; j<kSize; j++)
		for(i=0; i<eSize; i++)
			if(i<1+width || i+1+width>=eSize)
				output[i][j]=0
				continue
			endif
			
			Variable left=0
			Variable center=0
			Variable right=0
			
			Variable k
			for(k=-width; k<=width; k++)
				left+=input[i-1+k][j]
				center+=input[i+k][j]
				right+=input[i+1+k][j]
			endfor
			left/=(2*width+1)
			center/=(2*width+1)
			right/=(2*width+1)
		
			output[i][j]=-(left-2*center+right)/(de^2)
		endfor
	endfor
End