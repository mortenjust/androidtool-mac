#!/bin/sh

#  installApkOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/24/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
apkPath=$3

"$adb" -s $serial install -r "$3" 
