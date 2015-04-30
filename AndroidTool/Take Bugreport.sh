#!/bin/bash
declare -a arr
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2 # 
adb=$thisdir/adb


# --------------------
#
# Add your script below. When sending adb commands to the user-selected device, use "$adb -s $serial"
# 
# --------------------

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