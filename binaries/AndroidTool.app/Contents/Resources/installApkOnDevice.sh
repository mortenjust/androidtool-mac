#!/bin/sh

#  installApkOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/24/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.


thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serialAndInstallAndPath=$2
adb=$thisdir/adb

$adb -s $serialAndInstallAndPath > $thisdir/installog.txt

#open $thisdir/installog.txt
# > $thisdir/installlog.txt