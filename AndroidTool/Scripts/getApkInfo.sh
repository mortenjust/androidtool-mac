#!/bin/sh

#  getApkInfo.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

echo "get apk info"

dir=$(dirname "$0")
source $dir/androidtool_prefix.sh
thisdir=$1
filename=$2

echo "$aapt" dump badging "$filename"

"$aapt" dump badging "$filename"
