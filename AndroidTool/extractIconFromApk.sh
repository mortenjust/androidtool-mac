thisdir=$1 # $1 is the bundle resources path directly from the calling script file
aapt="$thisdir/aapt"
apk=$2

preview-android-icon () { 	
	iconFile=$("$aapt" d --values badging "$apk" | sed -n "/^application: /s/.*icon='\([^']*\).*/\1/p")
#echo "extracting $iconFile from $apk with $aapt"
	unzip -p $apk $iconFile > /tmp/icon.png
    echo "/tmp/icon.png"
}

preview-android-icon