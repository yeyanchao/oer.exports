#!/bin/bash
 
#  This scritp is used to convert transparent png format image to non-transparent 
#  png format image Because Kindle does **not** support transparent png
#  Scritp uses 'convert' to do the conversion, so you should install ImageMagick first.

#1st parameter is the working dir

WORKING_DIR=$1

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) 
CONVERT=$(which convert)
CWD=$(pwd)

cd ${ROOT}/${WORKING_DIR}

for d in $(ls .)
do
  if [ -d "$d" ];then
    cd $d
    if ls *.png >/dev/null 2>&1;then #Some modules don't contain any png file
      for f in $(ls *.png)
      do
        ${CONVERT} $f -background white $f
      done
    fi
    cd ..
  fi
done

cd ${CWD}

exit 0
