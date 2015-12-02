#!/bin/sh

#  getCurrentActivityForIdentifier.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 12/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

thisdir=$1 # $1 is the bundle resources path directly from the calling script file
identifier=$2
adb=$thisdir/adb

