#!/bin/bash

######################################################################
#
# 
# Obb script
# Thanks, Farhad Khairzad!
#
#
######################################################################

#Set up for AndroidTool
thisdir=$1 # $1 is the bundle resources path directly from the calling script file
serial=$2
file=$3
adb=$thisdir/adb

#wiring up
obb_type="main"


#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`
SVERSION='1.1b' #modified for AndroidTool

#Set fonts for Help.
#NORM=`tput sgr0`
#BOLD=`tput bold`
#REV=`tput smso`


#NUMARGS=$#
#file=$@
#if [ $NUMARGS -eq 0 ]; then
#  HELP
#fi
#if [ $NUMARGS -eq 2 ]; then
#  file=$2
#fi 
#if [ $NUMARGS -gt 2 ]; then
#  echo "Option not allowed. Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."
#fi

function MAIN_PROCESS {
    file_name=$(basename "$file")
    dir_name=$(dirname "$file")

    echo "0.01m ready to do stuff with $file"
    echo "0.m cd into $dir_name where we find $file_name"
    cd "$dir_name"
    echo "1.m file_name: $file_name"

  if [[ ${file_name:0:5} = "main." ]]; then
    pkg_name=$(echo $file_name | perl -nle 'm/([^main\.\d+].+?(?=.obb))/; print $1')
    echo 'Copying' $file_name 'to obb/'$pkg_name'/'
    "$adb" shell mkdir -p sdcard/Android/obb/$pkg_name
    "$adb" push $file sdcard/Android/obb/$pkg_name/
  elif [[ ${file_name:0:6} = "patch." ]]; then
    pkg_name=$(echo $file_name | perl -nle 'm/([^patch\.\d+].+?(?=.obb))/; print $1')
    echo 'Copying' $file_name 'to obb/'$pkg_name'/'
    "$adb" shell mkdir -p sdcard/Android/obb/$pkg_name
    "$adb" push $file sdcard/Android/obb/$pkg_name/
  else
    echo "2.m no indication of patch/main, using main"
    pkg_name=$(echo "$file_name" | perl -nle 'm/(^[^-]+)/; print $1')
    obb_build=$(echo "$file_name" | perl -nle 'm/(?<=\-)(.*?)(?=\.)/; print $1')
    new_name=$obb_type.$obb_build.$pkg_name.obb
    echo "3.m creating local temp folder with package name: .tmp-obb/$pkg_name"
    mkdir -p ".tmp-obb/$pkg_name"
    echo "4.m Copying $new_name to obb/$pkg_name/"
    cp "$file" ".tmp-obb/$pkg_name/$new_name"
    echo "5. creating directory on device: $adb shell mkdir -p sdcard/Android/obb/$pkg_name"
    "$adb" shell mkdir -p "sdcard/Android/obb/$pkg_name"
    echo "6. pushing file to device: $adb push .tmp-obb/$pkg_name/$new_name sdcard/Android/obb/$pkg_name/"
    "$adb" push ".tmp-obb/$pkg_name/$new_name" "sdcard/Android/obb/$pkg_name/"
    echo "7. removing local temp folder"
    rm -r .tmp-obb
  fi
  exit
}

function VERIFY_FILE {
echo $file
echo $FILE_EXT
TEMPFILE=`basename $file`
FILE_BASE=`echo "${TEMPFILE%.*}"`  #file without extension
FILE_EXT="${TEMPFILE##*.}"  #file extension

if [ -z "$file" ]; then
    echo "Select a .obb file"
  else
    if [ $FILE_EXT == "obb" ]; then
    MAIN_PROCESS
    else
    echo "Select a valid .obb file"
    fi
  fi

exit
}
### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

#obb_type="main"

#while getopts :m:p:h opt; do
#  case $opt in
#    m)  #set option "a"
#      obb_type="main"
#      ;;
#    p)  #set option "b"
#      obb_type="patch"
#      ;;
#    h)  #set option "b"
#      HELP
#      ;;  
#    \?) #unrecognized option - show help
#      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
#      HELP
#      #If you just want to display a simple error message instead of the full
#      #help, remove the 2 lines above and uncomment the 2 lines below.
#      #echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
#      #exit 2
#      ;;
#
#  esac
#done

#if [ $# -eq 1 ] || [ $# -eq 2 ]; then
#  if [ ! -f $file ]; then
#    echo "File not found!"
#  else
  VERIFY_FILE
#  fi
#fi