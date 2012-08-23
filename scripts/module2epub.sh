#!/bin/sh -x -v

# 1st arg is either "Connexions" or any other string indicating if this is a cnx site or a rhaptos site
# 2nd arg is the path to the collection
# 3rd arg is the epub zip file
# 4th arg is the content id and version
# 5th arg is the path to the dbk2___.xsl file ("epub" for epub generation, and "html" for the html zip)
# 6th arg is the path to the included CSS file
# 7th arg is optional and if non-empty signifies that we do not need to recreate the dbk files 

CNX_OR_RHAPTOS=$1
WORKING_DIR=$2
EPUB_FILE=$3
CONTENT_ID_AND_VERSION=$4
DBK_TO_HTML_XSL=$5
CSS_FILE=$6

SKIP_DBK_GENERATION=$7

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT/.."; pwd) # .. since we live in scripts/

CWD=$(pwd)

RUBY=$(which ruby)

EXIT_STATUS=0

if [ -s $WORKING_DIR/index.cnxml ]; then 
  DBK_FILE=$WORKING_DIR/index.dbk
  MODULE=$CONTENT_ID_AND_VERSION
  MODULE=${MODULE%%_*}


  cd ${ROOT}
  python content2epub.py -t "module" -i ${MODULE} -c ${CSS_FILE} -e ${DBK_TO_HTML_XSL} -o ${EPUB_FILE} ${WORKING_DIR}
  EXIT_STATUS=$EXIT_STATUS || $?
  cd ${CWD}

elif [ -s $WORKING_DIR/collection.xml ]; then
  DBK_FILE=$WORKING_DIR/collection.dbk
  
  cd ${ROOT}
  python content2epub.py -t "collection" -c ${CSS_FILE} -e ${DBK_TO_HTML_XSL} -o ${EPUB_FILE} ${WORKING_DIR}
  EXIT_STATUS=$EXIT_STATUS || $?
  cd ${CWD}

  EXIT_STATUS=$EXIT_STATUS || $?
  
else
  echo "ERROR: The first argument does not point to a directory containing a 'index.cnxml' or 'collection.xml' file" 1>&2
  exit 1
fi


exit $EXIT_STATUS
