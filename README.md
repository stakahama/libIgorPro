Igor Pro (Wavemetrics, Inc.) is a software used by many members of the atmospheric aerosol community (among others). The included programming language grew out of a set of macro routines and displays its operational heritage.

Challenges:
- "Waves are global objects" (Igor manual Version 6.1, p. IV-48).
- Data structure definitions exist only locally within functions.
- "Operations" produce side effects (create variables that are not returned values).

Remedies:
- Use data folders to implement namespaces for waves and other data (not for functions).
- Use data folders or "string list of waves" to implement data structures that persist across functions.
- Wrap operations in functions to contain side effects.

The ipf file(s) in this project can be included in 
`~/Documents/WaveMetrics/Igor Pro 6 User Files/` (Mac), or `C:/Documents and Settings/username/My Documents/WaveMetrics/Igor Pro 6 User Files/` (Windows) to have these functions available for every Igor program.
On a Mac, can set `ln -s stlib.ipf "~/Documents/WaveMetrics/Igor Pro 6 User Files/"`; on Windows this can also be handled through a shortcut. In a procedure window, use `#include "stlib"` statement to use functions from the library.

*Local environments.* Local function environments can be implemented using data folders as shown in the following example; we define a function to calculate the two-norm distance of a vector.
```
function twonormdist(waveref)
    wave waveref // this is just a reference to the wave
    variable value
    newdatafolder/s local
    	make/n=(numpnts(waveref)) wavesq = waveref[p]^2
        value = sqrt(sum(wavesq))
    killdatafolder : 
    return value
end

•make/o vector = {1,0.5,0.5}
•print twonormdist(vector)
  1.22474
```
`newdatafolder/s local` creates a new data folder and immediately sets this context as the new working scope. `killdatafolder :` kills all waves created in `local` data folder. Without using such a data folder, any waves created within the function can conflict with an existing wave (in the global scope), and temporary waves will have to be killed explicitly with `killwaves/z waveseq,...` and so on. I cannot speak to the efficiency of this approach of creating temporary data folders within each function, but computationally expensive operations will hopefully be handled by an XOP (external operating procedure, e.g., a C program) in any case.

*Computing on waves with functions.* An Igor Pro function serves as both function and subroutine (in Fortran parlance); side effects in functions are not discouraged as in most other languages but used as a necessary tool for computation. To compute the normed vector, a Fortran-esque solution is to define the array outside of the function definition and to pass the reference so that its values are overwritten:
```
function normalizewave(inpwave,outwave)
    wave inpwave
    wave outwave
    outwave = inpwave[p]/twonormdist(inpwave)
end

•make/o/n=(numpnts(vector)) newvector = NaN
•print newvector
  newvector[0]= {NaN,NaN,NaN}
•normalizewave(vector,newvector)
•print newvector
  newvector_[0]= {0.816497,0.408248,0.408248}
```

The following solution also works and is more appropriate when the length of output wave is unknown (in this case, it is obvious), though this style adds an element of unpredictability. (Sizes of waves can be changed any time using `redimension`, but this operation should also be used with much caution).

```
function normalizewave_(inpwave,outwave)
    wave inpwave
    string outwave // name of new wave as a string variable
    make/n=(numpnts(inpwave)) $outwave
    wave outwaveref = $outwave
    outwaveref = inpwave[p]/twonormdist(inpwave)
end

•normalizewave_(vector,"newvector_")
•print newvector_
  newvector_[0]= {0.816497,0.408248,0.408248}
```
It is possible to create waves in the global or any other namespace at any time from within functions; this flexibility is dangerous as it results in "spaghetti code" or something possibly worse.


Require HDF5 module (comment out ExportHDF5 if not desired). From the IGOR Manual (pp. II-47 to II-48 in Version 6.2):

[T]he HDF5 file loader package consists of an extension named "HDF5.xop", a help file named "HDF5 Help.ihf" and a procedure file named "HDF5 Browser.ipf". Here is how you would activate these files:

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

This is automated in `setup.sh` for Mac/Linux (though paths may need to be changed).
