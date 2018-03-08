#!/bin/sh

#  launchActivity.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.
# am start -n yourpackagename/.activityname
# adb shell am start com.mortenjust.streamvsd/com.mortenjust.streamvsd.GridActivity

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1
serial=$2
packageAndActivity=$3

echo "$adb" -s $serial shell am start $packageAndActivity
"$adb" -s $serial shell am start $packageAndActivity

# alternative method to be tested
# "$adb" -s $serial shell monkey -p $package -c android.intent.category.LAUNCHER 1
