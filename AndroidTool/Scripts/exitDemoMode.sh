#!/bin/sh

#  startDemoMode.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 11/16/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2

"$adb" -s $serial shell am broadcast -a com.android.systemui.demo -e command exit
