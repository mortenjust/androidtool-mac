#!/bin/sh

#  uninstallPackageOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 12/5/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
packageName=$3

adb=$thisdir/adb


# uninstall -k ..would keep cache and data files
echo "$adb" -s $serial uninstall -r "$3"
"$adb" -s $serial uninstall "$3"