#!/bin/sh

#  launchActivity.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.
# am start -n yourpackagename/.activityname
# adb shell am start com.mortenjust.streamvsd/com.mortenjust.streamvsd.GridActivity

thisdir=$1
serial=$2
packageAndActivity=$3
adb=$thisdir/adb

echo "$adb" -s $serial shell am start $packageAndActivity
"$adb" -s $serial shell am start $packageAndActivity