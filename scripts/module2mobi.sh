#!/bin/sh

# This script is used to generate mobi file out of a collection using kindlegen

#eg:./module2mobi.sh test-ccap outputfile-name ccap-physics.css

# 1st arg is the path to the collection
# 2nd arg is the name of the mobi file
# 3rd arg is the style file eg:ccap-physics 

WORKING_DIR=$1
OUTPUT=$2
CSS_FILE=$3 


ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) 
KINDLEGEN=$(which kindlegen)

CWD=$(pwd)

EXIT_STATUS=0

cd ${ROOT}

if [ -s $WORKING_DIR/collection.xml ]; then
XHTML_FILE=$WORKING_DIR/"$OUTPUT.xhtml"

  python collectiondbk2mobi.py -d ${WORKING_DIR} -o ${XHTML_FILE}

  echo "Done building xhtml content"

  EXIT_STATUS=$EXIT_STATUS || $?

  HTML_FILE=$WORKING_DIR/"$OUTPUT.html"

  python epubcss.py ${XHTML_FILE} -c css/${CSS_FILE}.css -o ${HTML_FILE}

  #rm ${XHTML_FILE}

  echo "Done styling xhtml to html"

  EXIT_STATUS=$EXIT_STATUS || $?

  ./scripts/convertpng.sh ${WORKING_DIR}

  #echo "Done coverting transparent png to non-transparent png"

  EXIT_STATUS=$EXIT_STATUS || $?

  #convert the transparent png to non-transparent png
  #so that kindle can support the equations.
  sed -i -f scripts/tagp2a-listitem.sed ${HTML_FILE}
  sed -i -f scripts/tagp2a-abstract.sed ${HTML_FILE}

  #insert pagebreaks between chapters,before toc and other sections
  sed -i '/class="titlepage"/i<mbp:pagebreak \/>' ${HTML_FILE}
  sed -i '/class="colophon"/i<mbp:pagebreak \/>' ${HTML_FILE}
  sed -i '/class="toc"/i<mbp:pagebreak \/>' ${HTML_FILE}
  sed -i 's/\(Table of Contents\)/<h3>\1<\/h3>/' ${HTML_FILE}
  sed -i "s/title>\(.*\)<\/title/title>\1-${OUTPUT}<\/title/" ${HTML_FILE}

  EXIT_STATUS=$EXIT_STATUS || $?

  #Insert the toc mark,only to the first match(because there are othere tocs)
  sed -i '1,/<div class="toc">/s/<div class="toc">/<a name="toc"\/><div class="toc">/' ${HTML_FILE}
  
  #Generate the opf file for mobi
  ./scripts/gen-mobi-opf.sh "$OUTPUT.html" ${WORKING_DIR}


  MOBI_FILE="$OUTPUT.mobi"
 
  #Build the mobi from the .opf file
  ${KINDLEGEN} ${WORKING_DIR}/content.opf -o ${MOBI_FILE} #-verbose 

  EXIT_STATUS=$EXIT_STATUS || $?

  echo "Done converting html to mobi "

  cd ${CWD}

  EXIT_STATUS=$EXIT_STATUS || $?
  
  if [ $EXIT_STATUS -ne 0 ];then
    echo "ERROR: not recorded error" 1>&2 # add test in the future
    exit 1
  fi
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi
#  copy the file to kindle for testing
#  cp ${ROOT}/${WORKING_DIR}/${MOBI_FILE} /media/Kindle/documents/${MOBI_FILE}
exit $EXIT_STATUS
