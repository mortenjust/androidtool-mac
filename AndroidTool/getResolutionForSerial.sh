#!/bin/bash

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
adb=$thisdir/adb #Xcode
#adb="adb" #CL

declare -a arr

GetResolution(){
$adb -s $serial shell wm size
}

GetResolution