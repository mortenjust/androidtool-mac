#!/bin/bash

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2

declare -a arr

GetDetails(){
    "$adb" -s $serial shell getprop
}

GetDetails
