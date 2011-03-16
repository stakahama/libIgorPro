#pragma rtGlobals=1		// Use modern global access method.

function makedf( foldernamestr, [set])
	// makes data folder if it does not exists
	// sets current data folder to foldernamestr if set==1
	string foldernamestr
	variable set
	if( paramisdefault(set) ) 
		set = 0
	endif
	// skip if empty
	if( strlen(foldernamestr)==0 )
		return 1
	endif
	// make if it does not exist
	if( datafolderexists(foldernamestr)==0 )
		newdatafolder $foldernamestr
	endif
	// set if 'set' option = True
	if( set == 1 )
		setdatafolder $foldernamestr
	endif
	//
	return 0
end

function readlines( filenamestr,wavestr )
	//save contents of values in filenamestr to wavestr
	string filenamestr, wavestr
	//
	// make data folder for wave
	makedf( fileparts(wavestr, part="dirname") )
	// read and store
	LoadWave/J/O/K=2/A=tmpwave/Q filenamestr
	variable ix=0
	do
		string tmpwavestr = stringfromlist(ix,S_waveNames)
		if( strlen(tmpwavestr)==0 )
			break
		endif
		if( ix==0 )		
			 duplicate/o $tmpwavestr, $wavestr	
		endif
		killwaves/z $tmpwavestr
		ix += 1
	while(1)
end

// === shell utilities ===

function/s filenameasdirectory(filename)
	// return file name as directory (appends ":" if needed)
	string filename
	//
	string pathsep = ":" //Mac OS
	string dirname
	variable n = strlen(filename)-1
	if( cmpstr(filename[n],":")!=0 )
		dirname = filename + pathsep
	else
		dirname = filename
	endif
	return dirname
end

function/s fullfile(dirname,basename)
	// return path-joined filename
	string dirname, basename
	return filenameasdirectory(dirname) + basename
end

function/s fileparts(filenamestr, [part])
	// parse filenamestr into dirname, basename
	// part is one of {"dirname","basename"}, or other (e.g., "")
	// in which case the return value is list string
	string filenamestr, part
	if(paramisdefault(part))
		part=""
	endif
	//
	string pathsep = ":" //Mac OS
	string pattern
	sprintf pattern, "^((.*)[%s])?([^%s]+)$", pathsep, pathsep
	//
	string throwaway, dirname, basename 	
	splitstring/E=pattern filenamestr, throwaway, dirname, basename
	//
	string outstr = ":"
	if( cmpstr(part,"dirname")==0 )
		outstr = dirname
	elseif( cmpstr(part,"basename")==0 )
		outstr = basename
	else
		outstr = addlistitem(dirname,addlistitem(basename,""))
	endif
	return outstr
end

function/s fromroot(path)
	string path
	//
	if( cmpstr("root:",path[0,4])!=0  )
		path = fullfile("root:",path)
	endif
	return path	
end

// === getter/setter functions ===

// implement namespaces as
// assignvar(fullfile(namespace,variablename),value)
// getvar(fullfile(namespace,variablename))

function assignstr( varnamestr, value, [df] )
	// assign value to varnamestr
	string varnamestr, value
	string df
	if( !paramisdefault(df) )
		varnamestr = fullfile(df,varnamestr)
	endif
	//
	makedf( fileparts(varnamestr, part="dirname") )
	string/g $varnamestr
	svar/z vref = $varnamestr
	vref = value
end

function assignvar( varnamestr, value, [df] )
	// assign value to varnamestr
	string varnamestr
	variable value
	string df
	if( !paramisdefault(df) )
		varnamestr = fullfile(df,varnamestr)
	endif	
	//
	makedf( fileparts(varnamestr, part="dirname") )
	variable/g $varnamestr
	nvar/z vref = $varnamestr
	vref = value
end

function/s getstr( varnamestr, [df] )
	// retrieve value from varnamestr
	string varnamestr
	string df
	if( !paramisdefault(df) )
		varnamestr = fullfile(df,varnamestr)
	endif		
	svar/z value = $varnamestr
	return value
end

function getvar( varnamestr, [df] )
	// retrieve value from varnamestr
	string varnamestr
	string df
	if( !paramisdefault(df) )
		varnamestr = fullfile(df,varnamestr)
	endif			
	nvar/z value = $varnamestr
	return value
end

// === tests ===

function fileexistsp(filename)
	string filename
	// filename is file or path name
	getfilefolderinfo/z=1/q filename
	if( V_flag==0 )
		return 1
	else
		return 0
	endif
end

// Function fileopenerror(pathName, fileName)
// 	// checks if fileName in pathName exists on disk
// 	// must have copied this from igor manual -- search for "error in demoopen"
// 	// returns 0 if file exists, !0 otherwise.
// 	String pathName // Name of symbolic path or "" for dialog.
// 	String fileName // File name, partial path, full path or "" for dialog.
// 	Variable refNum
// 	//
// 	Variable err
// 	String fullName
// 	// Open file for read.
// 	Open/R/Z=1/P=$pathName refNum as fileName
// 	// Store results from Open in a safe place.
// 	err = V_flag
// 	fullName = S_fileName
// 	if (err == -1)
// 		return -1
// 	endif
// 	if (err != 0)
// 		//DoAlert 0, "Error in DemoOpen"
// 		return err
// 	endif
// 	Close refNum
// 	print fullName + " exists"
// 	return 0
// End

function isstringinwavep(strval,txtwave)
	// tests if strval is in list
	string strval
	wave/t txtwave
	//
	// match
	variable ix = 0
	variable match = 0
	for( ix=0;ix<(numpnts(txtwave));ix+=1)
		match += stringmatch(txtwave[ix],strval)
	endfor	
	
	return min(match,1)
end

function iswaveinrangep(waveref,minval,maxval)
	//tests if all values in waveref are between minval, maxval (inclusive)
	wave waveref
	variable minval,maxval
	//
	variable truefalse = 0	
	wavestats/q waveref
	if( V_min >= minval && V_max <= maxval )
		truefalse = 1
	else
		truefalse = 0
	endif
	return truefalse
end

// === wave to liststr

function/s wave2liststr(txtwave)
	// takes a text wave and concatenates elements into a list string
	// will ignore empty strings ("")
	wave/t txtwave
	//
	string liststr=""
	variable itemcount
	variable ix
	for( ix=0; ix<(numpnts(txtwave)); ix+=1 )
		if( strlen(txtwave[ix])==0 )
			continue
		endif
		liststr = addlistitem(txtwave[ix],liststr,";",itemcount)
		itemcount += 1
	endfor
	
	return liststr
end

function readlines2liststr(filenamestr,liststr)
	// read contents of file to liststr
	string filenamestr,liststr
	string wavestr = "tmpwave"
	newdatafolder/s local	
		readlines(filenamestr,wavestr)
		assignstr(liststr,wave2liststr($wavestr))
	killdatafolder :
end

Function/s datafolderwavesasliststr(datafoldername)
	string datafoldername
	//
	string liststr = ""
	String objName
	Variable index = 0
	do
		objName = GetIndexedObjName(datafoldername, 1, index)
		if (strlen(objName) == 0)
			break
		endif
		liststr = addlistitem(objName,liststr,";",index)
		index += 1
	while(1)
	return liststr
End

function fileerrorp(filenamestr)
	string filenamestr
	variable refnum=-999
	open/z=1/r refnum as filenamestr
	if( refnum==-999 )
		return 0
	else
		close refnum
		return 1
	endif
end

function asdatetime(wv)
	wave wv
	setscale d 0, 0, "dat", wv
end

function killloadedwaves(s_wavenames)
	string s_wavenames
	string elem
	variable ix=0
	do
		elem = stringfromlist(ix,s_wavenames)
		if( strlen(elem)==0 )
			break
		endif
		print "killing "+ elem
		wave waveref = $elem
		killwaves/z waveref
		ix += 1
	while(1)
end

function killwindows(typestr)
	string typestr
	newdatafolder/s local0987asdfzcxv
		make/o mapping = {1,2,4}
		setdimlabel 0, 0, Graph, mapping
		setdimlabel 0, 1, Table, mapping
		setdimlabel 0, 3, Layout, mapping
	
		string wlist = winlist("*",";","WIN:"+num2str(mapping[finddimlabel(mapping, 0, typestr)]))
		variable i=0
		string windowname = ""
		do
		windowname = stringfromlist(i,wlist)
		if( strlen(windowname)==0 )
			break
		endif
		dowindow/k $windowname
		i += 1
		while(1 )
	killdatafolder :
end

function killgraphs()
	killwindows("Graph")
end
