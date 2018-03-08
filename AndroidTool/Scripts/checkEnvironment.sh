#!/bin/sh

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh

echo ""
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "adb             : $adb"
echo "fastboot        : $fastboot"
echo "aapt            : $aapt"
echo ""
