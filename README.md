Igor Pro (Wavemetrics, Inc.) is a software used by many members of the atmospheric aerosol community (among others). 

Challenges:
- "Waves are global objects" (Igor manual Version 6.1, p. IV-48).
- Data structure definitions exist only locally within functions.
- "Operations" produce side effects (create variables that are not returned values).

Remedies:
- Use data folders to implement namespaces for waves and other data (not for functions).
- Use data folders or "string list of waves" to implement data structures that persist across functions.
- Wrap operations in functions to contain side effects.

The ipf file(s) in this project can be included in 
~/Documents/WaveMetrics/Igor Pro 6 User Files/ (Mac), or 
C:/Documents and Settings/username/My Documents/WaveMetrics/Igor Pro 6 User Files/ (Windows) 
to have these functions available for every Igor program.
(On a Mac, can set 'ln -s stlib.ipf "~/Documents/WaveMetrics/Igor Pro 6 User Files/"';
on Windows this can also be handled through a shortcut.
In a procedure window, use '#include "stlib"' statement.

Addtionally, local environments can also be implemented within functions as shown in the following examples:

    function foo()
    	variable output
    	newdatafolder/s local
    		... make waves, compute ...
    		... assign computed value to 'output' ...
    	killdatafolder : // this will kill any waves still residing in 'local'
    	return output
    end

    function bar1()
    	newdatafolder/s local
    		make localwave = {1}
    		make/n=(numpnts(localwave)) transformed = fn(localwave[p])
    		duplicate transformed root:mynamespace:mywave
    		... and so on ...
    	killdatafolder : // this will kill any waves still residing in 'local'
    end

    function bar2()
    	newdatafolder/s local
    		make localwave = {1}
    		make/n=(numpnts(localwave)) root:mynamespace:mywave
    		wave transformed = root:mynamespace:mywave
    		transformed = fn(localwave[p])
    		... and so on ...
    	killdatafolder : // this will kill any waves still residing in 'local'
    end

    function bar3(wavefullname) // defined closer to a fortran subroutine but not really
    	string wavefullname
    	newdatafolder/s local
    		make localwave = {1}
    		make/n=(numpnts(localwave)) $wavefullname
    		wave transformed = $wavefullname
    		transformed = fn(localwave[p])
    		... and so on ...
    	killdatafolder : // this will kill any waves still residing in 'local'
    end

    function twonorm(wavereference) // defined more like a fortran subroutine
    	wave wavereference
    	newdatafolder/s local
    		make/n=(numpnts(wavereference)) wavesq = wavereference[p]^2
    		wavereference = wavereference[p]/sqrt(sum(wavesq))
    	killdatafolder :
    end

Require HDF5 module (comment out ExportHDF5 if not desired). From the IGOR Manual (pp. II-47 to II-48 in Version 6.2):

[T]he HDF5 file loader package consists of an extension named HDF5.xop, a help file named "HDF5 Help.ihf" and a procedure file named "HDF5 Browser.ipf". Here is how you would activate these files:
1. Press the shift key and choose Help→Show Igor Pro Folder and User
   Files. This displays the Igor Pro Folder and the Igor Pro User
   Files folder on the desktop.
2. Make an alias/shortcut for "Igor Pro Folder/More Extensions/File
   Loaders/HDF5.xop" and put it in "Igor Pro User Files/Igor
   Extensions". This causes Igor to load the extension the next time
   Igor is launched.
3. Make an alias/shortcut for "Igor Pro Folder/More Extensions/File
   Loaders/HDF5 Help.ihf" and put it in "Igor Pro User Files/Igor Help
   Files". This causes Igor to automatically open the help file the
   next time Igor is launched. This step is necessary only if you want
   the help file to be automatically opened.
4. Make an alias/shortcut for "Igor Pro Folder/WaveMetrics
   Procedures/File Input Output/HDF5 Browser.ipf" and put it in "Igor
   Pro User Files/Igor Procedures". This causes Igor to load the
   proce- dure the next time Igor is launched and to keep it open
   until you quit Igor.
5. Restart Igor.
You can verify that the HDF5 extension and the HDF5 Browser procedure
file were loaded by choosing Data→Load Waves→New HDF5 Browser. You can
verify that the HDF5 Help file was opened by choosing Windows→Help
Windows→HDF5 Help.ihf.
