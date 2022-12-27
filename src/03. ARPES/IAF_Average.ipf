#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function Average1D: calculate average and stddev
Function/S IAFf_Average1D_Definition()
	return "5;0;0;0;1;1;String;Variable;Variable;Wave1D;Wave1D"
End

Function IAFf_Average1D(argumentList)
	String argumentList
	
	//0th argument: prefix of wave path
	String prefixArg=StringFromList(0, argumentList)
	
	//1st and 2nd: minimum (include) and maximum (include) number in average calculation
	String aveMinArg=StringFromList(1, argumentList)
	String aveMaxArg=StringFromList(2, argumentList)
	
	//3rd: output Average 
	String averageArg=StringFromList(3, argumentList)
	
	//4th: output Standard deviation
	String stddevArg=StringFromList(4, argumentList)
	
	SVAR prefix=$prefixArg
	NVAR aveMin=$aveMinArg
	NVAR aveMax=$aveMaxArg
	
	//copy the 0th 
	String zeroth=prefix+num2str(aveMin)
	Wave/D zerothW=$zeroth
	Duplicate/O zerothW $averageArg
	Duplicate/O zerothW $stddevArg
	
	Wave/D average=$averageArg
	Wave/D stddev=$stddevArg
	
	Variable size=dimsize(zerothW, 0)
	Variable i
	
	// initialization
	for(i=0; i<size; i++)
		average[i]=0
		stddev[i]=0
	endfor
	
	for(i=aveMin; i<=aveMax; i++)
		String wavepath=prefix+num2str(i)
		Wave/D input=$wavepath
		if(dimsize(input, 0)!=size)
			print("Average error: size mismatch")
			return 0
		endif
		average[]+=input[p]
		stddev[]+=input[p]*input[p]
	endfor
	average[]/=size
	stddev[]/=size
	stddev[]-=average[p]*average[p]
End

//Function Average2D: calculate average and stddev
Function/S IAFf_Average2D_Definition()
	return "5;0;0;0;1;1;String;Variable;Variable;Wave2D;Wave2D"
End

Function IAFf_Average2D(argumentList)
	String argumentList
	
	//0th argument: prefix of wave path
	String prefixArg=StringFromList(0, argumentList)
	
	//1st and 2nd: minimum (include) and maximum (include) number in average calculation
	String aveMinArg=StringFromList(1, argumentList)
	String aveMaxArg=StringFromList(2, argumentList)
	
	//3rd: output Average 
	String averageArg=StringFromList(3, argumentList)
	
	//4th: output Standard deviation
	String stddevArg=StringFromList(4, argumentList)
	
	SVAR prefix=$prefixArg
	NVAR aveMin=$aveMinArg
	NVAR aveMax=$aveMaxArg
	
	//copy the 0th 
	String zeroth="::"+prefix+num2str(aveMin)
	Wave/D zerothW=$zeroth
	Duplicate/O zerothW $averageArg
	Duplicate/O zerothW $stddevArg
	
	Wave/D average=$averageArg
	Wave/D stddev=$stddevArg
	
	Variable size1=dimsize(zerothW, 0)
	Variable size2=dimsize(zerothW, 1)
	Variable i, j
	
	average[][]=0
	stddev[][]=0
	

	
	for(i=aveMin; i<=aveMax; i++)
		String wavepath="::"+prefix+num2str(i)
		// print(wavepath)
		Wave/D input=$wavepath
		if(dimsize(input, 0)!=size1 || dimsize(input, 1)!=size2)
			print("Average error: size mismatch")
			print(num2str(dimsize(input, 0))+" "+num2str(size1))
			print(num2str(dimsize(input, 1))+" "+num2str(size2))
			return 0
		endif
		average[][]+=input[p][q]
		stddev[][]+=input[p][q]*input[p][q]
	endfor
	average[][]/=(aveMax-aveMin+1)
	stddev[][]=sqrt(stddev[p][q]/(aveMax-aveMin+1)-average[p][q]*average[p][q])
End