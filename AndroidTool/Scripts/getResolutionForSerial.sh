#!/bin/bash

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2

declare -a arr

GetResolution(){
echo "doing this:-------"
echo "$adb" -s $serial shell wm size
echo "-----------"

"$adb" -s $serial shell wm size
}

GetResolution
