#!/bin/sh

#  installZip.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

thisdir=$1
filename=$2

fastboot=$1/fastboot
adb=$1/adb

echo "$adb" reboot-bootloader
"$adb" reboot-bootloader

echo "$fastboot" update "$filename"
"$fastboot" update "$filename"