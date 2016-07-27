aapt=$1
apk=$2

preview-android-icon () { 	
	iconFile=$($aapt d --values badging "$apk" | sed -n "/^application: /s/.*icon='\([^']*\).*/\1/p")
	echo "extracting $iconFile from $apk with $aapt"
	unzip -p $apk $iconFile > /tmp/icon.png
	open /tmp/icon.png
}

preview-android-icon