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
adb=$thisdir/adb

TakeScreenshot(){
    deviceName=$($adb -s $serial shell getprop ro.product.name)
    buildId=$($adb -s $serial shell getprop ro.build.id)
    ldap=$(whoami)
    now=$(date +'%m%d%Y%H%M%S')
    finalFileName=$deviceName$buildId$ldap$now.png
    finalFileName="${finalFileName//[$'\t\r\n ']}"
    echo "Taking screenshot of $serial"

    $adb -s $serial shell screencap -p /sdcard/$finalFileName
    $adb -s $serial pull /sdcard/$finalFileName
    $adb -s $serial shell rm /sdcard/$finalFileName

    open $finalFileName
}

mkdir -p ~/Desktop/AndroidTool
cd ~/Desktop/AndroidTool
TakeScreenshot