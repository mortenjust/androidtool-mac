# --------------------
#
# This file will be reset upon every update of the app.
# Please copy and backup any of your personal changes.
#
# --------------------

#!/bin/bash
# see `AT Template.sh` for usage instructions
declare -a arr
thisdir=$1
serial=$2

source $thisdir/androidtool_prefix.sh


TakeBugReport(){
	ldap=$(whoami)
	now=$(date +"%m-%d-%Y-%H-%M-%S")
	devicename=$($adb -s $serial shell getprop ro.product.name)
	finalFilename=$devicename-$ldap-$now.png
	finalFilename="${finalFilename//[$'\t\r\n ']}"

	$adb -s $serial bugreport > $finalFilename".txt"
	}

mkdir -p ~/Desktop/AndroidTool
cd ~/Desktop/AndroidTool
TakeBugReport
open . #opens the Android Tool folder in Finder after executing. Could be annoying
