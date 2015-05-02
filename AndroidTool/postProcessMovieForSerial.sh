#!/bin/sh

#  postprocessmovie.sh
#  Bugs
#
#  Created by Morten Just Petersen on 4/10/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.


#adb="/usr/local/bin/adb"

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
width=$3
height=$4
adb=$thisdir/adb

deviceName=$($adb -s $serial shell getprop ro.product.name)
buildId=$($adb -s $serial shell getprop ro.build.id)
ldap=$(whoami)
now=$(date +'%m%d%Y%H%M%S')
finalFileName=$deviceName$buildId$ldap$now
finalFileName="${finalFileName//[$'\t\r\n ']}"

mkdir -p ~/Desktop/AndroidTool
cd ~/Desktop/AndroidTool

chara=$($adb -s $serial shell getprop ro.build.characteristics)
if [[ $chara == *"watch"* ]]

then # -- Watch ---
    echo 'Copying from watch...'
    $adb -s $serial pull /sdcard/screencapture.raw
    $adb -s $serial shell rm /sdcard/screencapture.raw

    echo '#Converting...'

    $thisdir/ffmpeg -f rawvideo -vcodec rawvideo -s $width"x"$height -pix_fmt rgb24 -r 10 -i screencapture.raw  -an -c:v libx264 -pix_fmt yuv420p $finalFileName.mp4

    #    $thisdir/ffmpeg -f rawvideo -vcodec rawvideo -pix_fmt rgb24 -r 10 -i screencapture.raw  -an -c:v libx264 -pix_fmt yuv420p $finalFileName.mp4


    $thisdir/ffmpeg -i $finalFileName.mp4 $finalFileName.gif

    echo 'Cleaning up...'
    rm screencapture.raw

else # -- Phone ---
    echo 'copying from phone...'
    $adb -s $serial pull /sdcard/capture.mp4
    mv capture.mp4 $finalFileName.mp4
    $thisdir/ffmpeg -i $finalFileName.mp4 $finalFileName.gif

    echo 'cleaning up'
    $adb -s $serial shell rm /sdcard/capture.mp4
fi

echo 'Opening file...'
open $finalFileName.mp4
