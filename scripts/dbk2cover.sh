#!/bin/sh

CNX_OR_RHAPTOS=$1

WORKING_DIR=`dirname $2`
DBK_FILE=$2

DEBUG=$2

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0


XSLTPROC="xsltproc --stringparam cnx.site-type $CNX_OR_RHAPTOS"
DBK2SVG_COVER_XSL=$ROOT/xsl/dbk2svg-cover.xsl

COVER_PREFIX=cover
COLLECTION_COVER_PREFIX=_collection_$COVER_PREFIX
COVER_SVG=$WORKING_DIR/$COVER_PREFIX.svg
COVER_PNG=$WORKING_DIR/$COVER_PREFIX.png

INKSCAPE=`which inkscape`
if [ ".$INKSCAPE" == "." ]; then
  # Try to use the Mac version of Inkscape
  INKSCAPE=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
  if [ ! -e $INKSCAPE ]; then
    echo "LOG: ERROR: Inkscape not found." 1>&2
    exit 1
  fi
fi

[ -a $COVER_SVG ] && rm $COVER_SVG
[ -a $COVER_PNG ] && rm $COVER_PNG

# Create cover SVG and convert it to an image
COVER_FILES=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.??g | sort -r`
if [ "$COVER_FILES." == "." ]; then
  echo "LOG: DEBUG: Creating cover page"
  $XSLTPROC -o $COVER_SVG $DBK2SVG_COVER_XSL $DBK_FILE
  EXIT_STATUS=$EXIT_STATUS || $?
  
  if [ -s $COVER_SVG ]; then
    echo "LOG: DEBUG: Converting SVG Cover Page to PNG"
    ($INKSCAPE $COVER_SVG --export-png=$COVER_PNG 2>&1) > $WORKING_DIR/__err.txt
    EXIT_STATUS=$EXIT_STATUS || $?
  else
    # Print saner error messages.
    echo "LOG: ERROR: Converting Cover page: SVG file not found" 1>&2
    EXIT_STATUS=$EXIT_STATUS || 1
  fi
else
  echo "LOG: DEBUG: Converting existing cover image"
  COVER_FILES_SVG=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.svg | sort -r`
  COVER_FILES_PNG=`find $WORKING_DIR -name $COLLECTION_COVER_PREFIX.png | sort -r`
  if [ "$COVER_FILES_SVG." != "." ]; then
    echo "LOG: DEBUG: Converting existing cover SVG named ${COVER_FILES_SVG[0]}"
    ($INKSCAPE ${COVER_FILES_SVG[0]} --export-png=$COVER_PNG 2>&1) > $WORKING_DIR/__err.txt
    EXIT_STATUS=$EXIT_STATUS || $?
  else
    echo "LOG: DEBUG: Converting existing cover PNG named ${COVER_FILES_PNG[0]}"
    cp $COVER_FILES_PNG $COVER_PNG
    EXIT_STATUS=$EXIT_STATUS || $?
  fi
fi

# remove all the temp files so the complete zip doesn't contain them
if [ ".$DEBUG" == "." ]; then
  [ -a $WORKING_DIR/__err.txt ] && rm $WORKING_DIR/__err.txt
fi
exit $EXIT_STATUS