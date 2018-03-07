#!/bin/sh

#  installZip.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

thisdir=$1
serial=$2
filename=$3

fastboot=$1/fastboot
adb=$1/adb

echo "Flashing with fastboot"

echo "$adb" -s $serial reboot-bootloader
"$adb" -s $serial reboot-bootloader

echo "$fastboot" -s $serial update "$filename"
"$fastboot" -s $serial update "$filename"