#!/bin/sh

#  takeScreenshotForDeviceWithUUID.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 5/4/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
imobile=$1
uuid=$2
screenshotFolder=$3

now=$(date +'%m%d%Y%H%M%S')
ldap=$(whoami)
finalFilename=iOS$ldap$now.png #todo: we could pass iosversion and model as $3. It's in the data model
echo "ready to shoot to $finalFilename"

TakeScreenshot(){
    export DYLD_LIBRARY_PATH=$imobile
    $imobile/idevicescreenshot -u $uuid rawiosshot.tiff
    sips -s format png rawiosshot.tiff --out $finalFilename
    rm rawiosshot.tiff
    open $finalFilename
}

echo "###### $screenshotFolder"
mkdir -p "$screenshotFolder"
cd "$screenshotFolder"
TakeScreenshot