#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// subtract the Shirley background from the XPS spectrum
function/S IAFf_SubtractShirley_definition()
	return "5;0;0;0;1;1;Wave1D;Variable;Variable;Wave1D;Wave1D"
end

function IAFf_SubtractShirley(argumentList)
	String argumentList
	
	// 0th argument: input (XPS spectrum)
	String inArg=stringfromlist(0, argumentList)
	
	// 1st and 2nd arguments: energy min and max
	String EminArg=stringfromlist(1, argumentList)
	String EmaxArg=stringfromlist(2, argumentList)
	
	// 3rd argument: background function
	String BGArg=stringfromlist(3, argumentList)
	
	// 4th argument: spectrum without background
	String outArg=stringfromlist(4, argumentList)
	
	wave/d in=$inArg
	variable size=dimsize(in, 0)
	variable offset=dimoffset(in, 0)
	variable delta=dimdelta(in, 0)
	
	NVAR Emin=$EminArg
	NVAR Emax=$EmaxArg
	
	variable EminIndex=round((Emin-offset)/delta)
	variable EmaxIndex=round((Emax-offset)/delta)
	
	if(EminIndex<0 || EmaxIndex<0 || EminIndex>=size || EmaxIndex>=size || EminIndex>=EmaxIndex)
		print("SubtractShirley error: wrong range")
		abort
	endif
	
	duplicate/o in $BGArg
	wave/d bg=$BGArg
	
	string bgTemp_path="::TempData:ShirleyBG"
	duplicate/o in $bgTemp_path
	wave/d bgTemp=$bgTemp_path
	
	variable Int1=in[EminIndex]
	variable Int2=in[EmaxIndex]
	
	// initial guess: linear
	variable i
	for(i=0; i<size; i++)
		if(i<=EminIndex)
			bg[i]=Int1
		elseif(i<EmaxIndex)
			bg[i]=(Int1*(EmaxIndex-i)+Int2*(i-EminIndex))/(EmaxIndex-EminIndex)
		else
			bg[i]=Int2
		endif
	endfor

	Variable diff_max
	Variable j
	
	do
		diff_max=-1
		for(i=EminIndex; i<=EmaxIndex; i++)
			variable Area1=0
			variable Area2=0
			for(j=EminIndex; j<=EmaxIndex; j++)
				if(j<i)
					Area1+=in[j]-bg[j]
				elseif(j>i)
					Area2+=in[j]-bg[j]
				endif
			endfor
			bgTemp[i]=Int1+(Int2-Int1)*Area1/(Area1+Area2)
			if(abs(bgTemp[i]-bg[i])>diff_max)
				diff_max=abs(bgTemp[i]-bg[i])
			endif
		endfor
		
		for(i=EminIndex; i<=EmaxIndex; i++)
			bg[i]=bgTemp[i]
		endfor		
	while(diff_max>abs(Int1-Int2)*0.01)
	
	duplicate/o in $outArg
	wave/d out=$outArg
	out[]=in[p]-bg[p]
	
end