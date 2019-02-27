#!/bin/sh

if [ -z "$ANDROID_SDK_ROOT" ]
then
    printf "ANDROID_SDK_ROOT not defined. See\nhttps://developer.android.com/studio/command-line/variables.html\nfor more information"
    exit 1
fi

function findLastModifiedAapt {
    version=$(ls -t $ANDROID_SDK_ROOT/build-tools | head -1)
    echo $ANDROID_SDK_ROOT/build-tools/$version/aapt
}

adb=$ANDROID_SDK_ROOT/platform-tools/adb
fastboot=$ANDROID_SDK_ROOT/platform-tools/fastboot

aapt=$(findLastModifiedAapt)
