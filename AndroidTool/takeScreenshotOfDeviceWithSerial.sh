#!/bin/sh

#  takeScreenshotOfDeviceWithSerial.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/23/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

#!/bin/bash

declare -a arr

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
screenshotFolder=$3
activityName=$4
adb=$thisdir/adb

TakeScreenshot(){
    deviceName=$("$adb" -s $serial shell getprop ro.product.name)
    buildId=$("$adb" -s $serial shell getprop ro.build.id)
    ldap=$(whoami)
    now=$(date +'%m%d%Y%H%M%S')
    if [ -n "$activityName" ]; then
        finalFileName=$activityName-$now.png
    else
        finalFileName=$deviceName$buildId$ldap$now.png
    fi
    finalFileName="${finalFileName//[$'\t\r\n ']}"
    echo "Taking screenshot of $serial"

    "$adb" -s $serial shell screencap -p /sdcard/$finalFileName
    "$adb" -s $serial pull /sdcard/$finalFileName
    "$adb" -s $serial shell rm /sdcard/$finalFileName

    open $finalFileName
}

echo "###### $screenshotFolder"
mkdir -p "$screenshotFolder"
cd "$screenshotFolder"
TakeScreenshot