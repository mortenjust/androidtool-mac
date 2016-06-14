#!/bin/sh

#  convertMovieFiletoGif.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 5/7/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

thisdir=$1
inputFile=$3
outputFile=$4
scale=$5
screenRecFolder=$6

ConvertFile(){
    $thisdir/ffmpeg -i $inputFile -vf scale=iw*$scale:ih*$scale $outputFile
}

echo "###### $screenRecFolder"
mkdir -p "$screenRecFolder"
cd "$screenRecFolder"

ConvertFile
