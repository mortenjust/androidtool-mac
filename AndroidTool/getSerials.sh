#!/bin/sh

#  getSerials.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/23/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
adb=$thisdir/adb #Xcode
#adb="adb" #CL
let deviceCount=0

declare -a arr

GetSerials(){
    while read line
    do
        if [ -n "$line" ] && [ "`echo $line | awk '{print $2}'`" == "device" ]
        then
            let deviceCount=$deviceCount+1
            serial="`echo $line | awk '{print $1}'`"

            if (( deviceCount > 1 ))
            then
                serials=$serials";"
            fi

            serials=$serials$serial
        fi
    done < <("$adb" devices)
echo $serials
}

GetSerials