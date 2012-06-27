#!/bin/sh

#./module2mobi.sh test-ccap outputfile-name ccap-physics.css
# 1st arg is the path to the collection
# 2nd arg is the name of the mobi file
# 3rd arg is the style file ccap-physics.css 

WORKING_DIR=$1
OUTPUT=$2
CSS_FILE=$3 


ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) # .. since we live in scripts/

CWD=$(pwd)

EXIT_STATUS=0

cd ${ROOT}

if [ -s $WORKING_DIR/collection.xml ]; then

  XHTML_FILE=$WORKING_DIR/"$OUTPUT.xhtml"

  python collectiondbk2mobi.py -d ${WORKING_DIR} -o ${XHTML_FILE}

  echo "Done building xhtml content"

  EXIT_STATUS=$EXIT_STATUS || $?

  HTML_FILE=$WORKING_DIR/"$OUTPUT.html"

  python epubcss.py ${XHTML_FILE} -c css/${CSS_FILE} -o ${HTML_FILE}

  EXIT_STATUS=$EXIT_STATUS || $?

  echo "Done styling xhtml to html"

  MOBI_FILE="$OUTPUT.mobi"
 
  kindlegen ${HTML_FILE}  -o ${MOBI_FILE} #-verbose 

  EXIT_STATUS=$EXIT_STATUS || $?

  echo "Done converting html to mobi "

  cd ${CWD}

  EXIT_STATUS=$EXIT_STATUS || $?
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi

exit $EXIT_STATUS
