#!/bin/sh

#  uninstallPackageOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 12/5/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
packageName=$3

# uninstall -k ..would keep cache and data files
echo "$adb" -s $serial uninstall -r "$3"
"$adb" -s $serial uninstall "$3"
