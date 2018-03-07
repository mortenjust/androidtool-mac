#!/bin/sh

#  startrecording.sh
#  Bugs
#
#  Created by Morten Just Petersen on 4/10/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
width=$3
height=$4
bitrate=$5

adb=$thisdir/adb

chara=$($adb -s $serial shell getprop ro.build.characteristics)
if [[ $chara == *"watch"* ]]
then
    echo "Recording from watch..."
    # Get resolution if no custom res was specified
    if [[ ! $width ]]
    then
        width=`"$adb" -s $serial shell dumpsys display | grep mDisplayWidth | awk -F '=' '{ print $2 }' | tr -d '\r\n'`
    fi
    if [[ ! $height ]]
    then
        height=`"$adb" -s $serial shell dumpsys display | grep mDisplayHeight | awk -F '=' '{ print $2 }' | tr -d '\r\n'`
    fi
    sizeopt=""
    # Put a --size option only if both params are available
    if [[ $width && $height ]]
    then
        sizeopt=${width}x${height}
    fi

    "$adb" -s $serial shell screenrecord --size $sizeopt --o raw-frames /sdcard/screencapture.raw
else
    echo "Recording from phone..."
    orientation=$("$adb" -s $serial shell dumpsys input | grep 'SurfaceOrientation' | awk '{ print $2 }')
    if [[ "${orientation//[$'\t\r\n ']}" != "0" ]]
    then
        "$adb" -s $serial shell screenrecord --bit-rate $bitrate --verbose --size $height"x"$width /sdcard/capture.mp4 # > $1/reclog.txt
    else
        "$adb" -s $serial shell screenrecord --bit-rate $bitrate --verbose --size $width"x"$height /sdcard/capture.mp4 # > $1/reclog.txt
    fi
fi
