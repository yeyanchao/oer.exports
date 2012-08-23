#!/bin/sh

# This script is used to generate mobi file from a unzipped collection.

# 1st arg is the path to the collection
# 2nd arg is the name of the mobi file
# 3rd arg is the css file eg:ccap-physics.css 

WORKING_DIR=$1
OUTPUT=$2
CSS_FILE=$3

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) 
CWD=$(pwd)

KINDLEGEN=$(which kindlegen)
PHANTOMJS=$(which phantomjs)
XSLTPROC=$(which xsltproc)

XHTML_FILE=$WORKING_DIR/"$OUTPUT.xhtml"
HTML_FILE=$WORKING_DIR/"$OUTPUT.html"
MOBI_FILE="$OUTPUT.mobi"
EXIT_STATUS=0

DEBUG=false
#DEBUG=true

cd ${ROOT}

if [ -s $WORKING_DIR/collection.xml ]; then

  echo "Building xhtml content and opf file..."
  python collection2mobixhtml.py -d ${WORKING_DIR} -o ${XHTML_FILE} 
  EXIT_STATUS=$EXIT_STATUS || $?

  #Modify the opf file to add cover and "toc" entry...
  echo "Modifing opf..."
  ./scripts/opf-modifier.sh "$OUTPUT.html" ${WORKING_DIR}
  EXIT_STATUS=$EXIT_STATUS || $?

  echo "Styling xhtml..."
  ${PHANTOMJS} epubcss/phantom-harness.coffee css/${CSS_FILE} ${ROOT}/${XHTML_FILE} ./_temp.html ./output.css 1>&2
  EXIT_STATUS=$EXIT_STATUS || $?

  #Change the encoding
  ${XSLTPROC} xsl/utf82ascii.xsl _temp.html > ${HTML_FILE}

  echo "Coverting transparent png to non-transparent png..."
  ./scripts/convertpng.sh ${WORKING_DIR}
  EXIT_STATUS=$EXIT_STATUS || $?

  #Replace <p>,</p> in listitem/abstract to <a>,</a>
  echo "Replacing <p></p>..."
  sed -i -f scripts/tagp2a-listitem.sed ${HTML_FILE}
  sed -i -f scripts/tagp2a-abstract.sed ${HTML_FILE}

  #Insert pagebreaks between chapters,before toc and other sections
  echo "Inserting pagebreaks..."
  sed -i 's/\(<h1\)/\1 style="page-break-before:always;text-align:center;"/g' ${HTML_FILE}
  sed -i 's/\(<h2\)\( class="title autogen\)/\1 style="page-break-before:always;"\2/g' ${HTML_FILE}
  sed -i 's/\(<h3\)\( class="title autogen\)/\1 style="page-break-before:always;"\2/g' ${HTML_FILE}
  sed -i 's/\(<div\)\( class="titlepage autogen\)/\1 style="page-break-before:always;"\2/g' ${HTML_FILE}
  sed -i 's/\(<div\)\( class="toc\)/\1 style="page-break-before:always;"\2/g' ${HTML_FILE}

  #Equations centered
  echo "Equations centered "
  sed -i 's/\(<div\)\( class="mediaobject"\)/\1 style="text-align:center;"\2/g' ${HTML_FILE}

  #TOC centered
  echo "TOC centered "
  sed -i 's/\(Table of Contents\)/<h3 style="text-align:center;">\1<\/h3>/' ${HTML_FILE}

  #Insert the toc mark,only to the first match(because there are othere tocs)
  echo "Inserting toc mark..."
  sed -i '1,/<div style="page-break-before:always;" class="toc/s/\(<div style="page-break-before:always;" class="toc\)/<a name="toc"\/>\1/' ${HTML_FILE}

  #Replace the extra 0 with
  sed -i 's/\(<span class="pseudo-element after debug-epubcss">\) . 0\(<\/span>\)/\1#\2/g' ${HTML_FILE}

  #Build the mobi from the .opf file
  echo "Generating .mobi..."
  ${KINDLEGEN} ${WORKING_DIR}/content.opf -o ${MOBI_FILE} 1>&2 #-verbose
  EXIT_STATUS=$EXIT_STATUS || $?

  if [ -s ${WORKING_DIR}/${MOBI_FILE} ];then
    echo "DONE: MOBI built succiessfully."
  else
    echo "DONE: MOBI built Failed."
  fi

  if ! $DEBUG; then
    rm ${XHTML_FILE}
    rm ${HTML_FILE}
    rm ${WORKING_DIR}/content.opf
    rm ./output.css
    rm ./_temp.html
  fi

  cd ${CWD}

  if [ $EXIT_STATUS -ne 0 ];then
    echo "ERROR OCCURS." 1>&2
    exit 1
  fi
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi
exit $EXIT_STATUS
