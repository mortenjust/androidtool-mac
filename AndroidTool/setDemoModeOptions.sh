#!/bin/sh

#  setDemoModeOptions.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 11/16/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.


thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
adb=$thisdir/adb
settings=$3
allcmds=""

"$adb" -s $serial shell settings put global sysui_demo_allowed 1
echo "$adb" -s $serial shell settings put global sysui_demo_allowed 1

"$adb" -s $serial shell am broadcast -a com.android.systemui.demo -e command enter
echo "$adb" -s $serial shell am broadcast -a com.android.systemui.demo -e command enter

IFS='~' read -ra ADDR <<< "$settings"
for command in "${ADDR[@]}"; do
    echo "$adb" -s $serial shell "am broadcast -a com.android.systemui.demo -e command $command"
    "$adb" -s $serial shell "am broadcast -a com.android.systemui.demo -e command $command"
done