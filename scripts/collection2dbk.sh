#!/bin/sh

CNX_OR_RHAPTOS=$1 # either "Connexions" or something else (we do something special for Connexions)
WORKING_DIR=$2
ID=$3

DEBUG=$4

if [ "." = ".${CNX_OR_RHAPTOS}" ]; then
  echo "Please provide 3 arguments:"
  echo "1. 'Connexions' or 'Rhaptos'"
  echo "2. The working directory (should have a collection.xml)"
  echo "3. An id"
  exit 1
fi

SKIP_MODULE_CONVERSION=0

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

WORKING_DIR=`cd $WORKING_DIR; pwd`

COLLXML=$WORKING_DIR/collection.xml
PARAMS=$WORKING_DIR/_params.txt
DOCBOOK=$WORKING_DIR/_collection1.dbk
DOCBOOK2=$WORKING_DIR/_collection2.normalized.dbk
DOCBOOK3=$WORKING_DIR/_collection3.dbk
DBK_FILE=$WORKING_DIR/collection.dbk

XSLTPROC="xsltproc --stringparam cnx.site-type $CNX_OR_RHAPTOS"
COLLXML_PARAMS=$ROOT/xsl/collxml-params.xsl
COLLXML2DOCBOOK_XSL=$ROOT/xsl/collxml2dbk.xsl

DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK_NORMALIZE_PATHS_XSL=$ROOT/xsl/dbk2epub-normalize-paths.xsl
DOCBOOK_NORMALIZE_GLOSSARY_XSL=$ROOT/xsl/dbk-clean-whole-remove-duplicate-glossentry.xsl

MODULE2DOCBOOK=$ROOT/scripts/module2dbk.sh

# remove all the temp files first so we don't accidentally use old ones
[ -a $DOCBOOK ] && rm $DOCBOOK
[ -a $DOCBOOK2 ] && rm $DOCBOOK2
[ -a $DOCBOOK3 ] && rm $DOCBOOK3
[ -a $DBK_FILE ] && rm $DBK_FILE


echo "LOG: INFO: ------------ Starting on $WORKING_DIR --------------"

# Pull out the custom params (mostly math-related) stored inside the collxml 
$XSLTPROC -o $PARAMS $COLLXML_PARAMS $COLLXML
EXIT_STATUS=$EXIT_STATUS || $?

# Load up the custom params to xsltproc:
if [ -s $PARAMS ]; then
    #echo "Using custom params in params.txt for xsltproc."
    # cat $PARAMS
    OLD_IFS=$IFS
    IFS="
"
    XSLTPROC_ARGS=""
    for ARG in `cat $PARAMS`; do
      if [ ".$ARG" != "." ]; then
        XSLTPROC_ARGS="$XSLTPROC_ARGS --param $ARG"
      fi
    done
    IFS=$OLD_IFS
    XSLTPROC="$XSLTPROC $XSLTPROC_ARGS"
fi

# Convert to Docbook
$XSLTPROC -o $DOCBOOK $COLLXML2DOCBOOK_XSL $COLLXML
EXIT_STATUS=$EXIT_STATUS || $?



# For each module, generate a docbook file
if [ "$SKIP_MODULE_CONVERSION" = "0" ]; then
  for MODULE in `ls $WORKING_DIR`
  do
    if [ -d $WORKING_DIR/$MODULE ];
    then
      bash $MODULE2DOCBOOK $CNX_OR_RHAPTOS $WORKING_DIR/$MODULE $MODULE $ID $DEBUG
      EXIT_STATUS=$EXIT_STATUS || $?
    fi
  done
else
  echo "LOG: INFO: Skipping module conversion"
fi


# Combine into a single large file
# and clean up image paths
$XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_NORMALIZE_PATHS_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $DOCBOOK3 $DOCBOOK_CLEANUP_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?

$XSLTPROC -o $DBK_FILE $DOCBOOK_NORMALIZE_GLOSSARY_XSL $DOCBOOK3
EXIT_STATUS=$EXIT_STATUS || $?

# Create cover SVG and convert it to an image
bash $ROOT/scripts/dbk2cover.sh $CNX_OR_RHAPTOS $DBK_FILE $DEBUG


# remove all the temp files so the complete zip doesn't contain them
if [ ".$DEBUG" == "." ]; then
  [ -a $PARAMS ] && rm $PARAMS
  [ -a $DOCBOOK ] && rm $DOCBOOK
  [ -a $DOCBOOK2 ] && rm $DOCBOOK2
  [ -a $DOCBOOK3 ] && rm $DOCBOOK3
fi

exit $EXIT_STATUS
