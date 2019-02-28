# --------------------
#
# This file will be reset upon every update of the app.
# Please copy and backup any of your personal changes.
#
# --------------------

#!/bin/bash
thisdir=$1 # the bundle resources path directly from the calling script file
serial=$2 # the serial of the selected device, if it applies

# sets up $appt, $adb, and $fastboot, the ANDROID_SDK_ROOT env variable should be set.
source $thisdir/androidtool_prefix.sh

echo "Hello World!"

$adb devices

echo "Farewell World!"

# you can see the output at `tools > terminal output`
