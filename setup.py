#!/usr/bin/python

## For OS X, sets up link to this library, and also HDF5 XOP.
## Verbose
## UNTESTED

import os
import subprocess

IGORLIB = os.path.join(os.environ['HOME'],'git/projects/igorlib')
USERFILES = os.path.join(os.environ['HOME'],'Documents/WaveMetrics/Igor Pro 6 User Files')
IGORFOLDER = '/Applications/Igor Pro 6.2 Folder'

assoc = [
    ('cp','More Extensions/File Loaders/HDF5.xop','Igor Extensions'),
    ('ln','More Extensions/File Loaders/HDF5 Help.ihf','Igor Help Files'),
    ('ln','WaveMetrics Procedures/File Input Output/HDF5 Browser.ipf','Igor Procedures')
    ]
    
command = {
    'ln':'ln -svf',
    'cp':'cp -rpv'
    }

subprocess.call([command['ln'],
                 os.path.join(IGORLIB,'stlib.ipf'),
                 os.path.join(USERFILES,'User Procedures')])

for elem in assoc:
    userdir = os.path.join(USERFILES,elem[-1])
    if not os.path.exists(userdir):
        os.mkdir(userdir)
    subproces.call([command[elem[0]],
                    os.path.join(IGORFOLDER,elem[1]),
                    userdir])

