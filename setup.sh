#!/bin/sh

############
## For OS X, sets up link to this library, and also HDF5 XOP.
## Verbose
############

## May need to change these
IGORLIB=~/git/projects/igorlib
IGORFOLDER=/Applications/Igor\ Pro\ 6.2\ Folder
USERFILES=~/Documents/WaveMetrics/Igor\ Pro\ 6\ User\ Files

USERPROCS="$USERFILES/User Procedures"
EXTENSIONS="$USERFILES/Igor Extensions"
HELPFILES="$USERFILES/Igor Help Files"
PROCEDURES="$USERFILES/Igor Procedures"

if [ ! -d "$USERPROCS" ];then
    mkdir -v "$USERPROCS"
fi && \
ln -svf "$IGORLIB/stlib.ipf" "$USERPROCS"

if [ ! -d "$EXTENSIONS" ];then
    mkdir -v "$EXTENSIONS"
fi && \
cp -rpv "$IGORFOLDER/More Extensions/File Loaders/HDF5.xop" "$EXTENSIONS"

if [ ! -d "$HELPFILES" ];then
    mkdir -v "$HELPFILES"
fi && \
ln -svf "$IGORFOLDER/More Extensions/File Loaders/HDF5 Help.ihf" "$HELPFILES"

if [ ! -d "$PROCEDURES" ];then
    mkdir -v "$PROCEDURES" 
fi && \
ln -svf "$IGORFOLDER/WaveMetrics Procedures/File Input Output/HDF5 Browser.ipf" "$PROCEDURES"


