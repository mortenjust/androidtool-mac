#!/bin/sh

#  startrecording.sh
#  Bugs
#
#  Created by Morten Just Petersen on 4/10/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
adb=$thisdir/adb

chara=$($adb -s $serial shell getprop ro.build.characteristics)
if [[ $chara == *"watch"* ]]
then
echo "Recording from watch..."
$adb -s $serial shell screenrecord --o raw-frames /sdcard/screencapture.raw
else
echo "Recording from phone..."
#open .
$adb -s $serial shell screenrecord --bit-rate 2000000 --verbose --size 540x960 /sdcard/capture.mp4 > $1/reclog.txt
#$adb -s $serial shell screenrecord /sdcard/capture.mp4 > $1/reclog.txt
fi