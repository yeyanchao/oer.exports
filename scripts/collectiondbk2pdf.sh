#!/bin/sh -xv

COL_PATH=$1
# The filename matches a file in $ROOT/xsl/
PRINT_STYLE=$2

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

EXIT_STATUS=0

#declare -x FOP_OPTS=-Xmx14000M # FOP Needs a lot of memory (4+Gb for Elementary Algebra)
DOCBOOK=$COL_PATH/collection.dbk
DOCBOOK2=$COL_PATH/collection.cleaned.dbk
UNALIGNED=$COL_PATH/collection.fo
FO=collection.aligned.fo
ABSTRACT_TREE=collection.at.xml
ABSTRACT_TREE_2=collection.at2.xml
PDF=collection.pdf

if [ ! -s $DOCBOOK ]; then
  DOCBOOK=$COL_PATH/index.dbk
fi


XSLTPROC="xsltproc --param cnx.output.fop 1"
FOP="sh $ROOT/fop/fop -c $ROOT/lib/fop.xconf"

# XSL files
DOCBOOK2FO_XSL=$ROOT/xsl/${PRINT_STYLE}.xsl
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
ALIGN_XSL=$ROOT/xsl/fo-align-math.xsl
MARGINALIA_XSL=$ROOT/xsl/fo-marginalia.xsl

if [ ! -s ${DOCBOOK2FO_XSL} ]; then
  echo "ERROR: Could not find style-specific XSLT file named 'epub/xsl/${PRINT_STYLE}"
  exit 1
fi

echo "Step 1 (Cleaning up Docbook)"
$XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_CLEANUP_XSL $DOCBOOK
EXIT_STATUS=$EXIT_STATUS || $?

echo "Step 2 (Docbook to XSL:FO)"
$XSLTPROC -o $UNALIGNED $DOCBOOK2FO_XSL $DOCBOOK2
EXIT_STATUS=$EXIT_STATUS || $?

echo "Step 3 (Aligning math in XSL:FO)"
$XSLTPROC -o $COL_PATH/$FO $ALIGN_XSL $UNALIGNED
EXIT_STATUS=$EXIT_STATUS || $?

echo "Step 4 Converting XSL:FO to PDF (using Apache FOP)"
# Change to the collection dir so the relative paths to images work
cd $COL_PATH
#time $FOP $FO $PDF
$FOP $FO -at "application/pdf" $ABSTRACT_TREE
EXIT_STATUS=$EXIT_STATUS || $?

# Retry a couple of times before failing
sleep 1
RET=0
for i in {1..6}
do
  echo "Step 5 Converting serialized tree to PDF (Using Apache FOP)"
  $FOP -atin $ABSTRACT_TREE $PDF
  RET=$?
  if [ $RET = 0 ]; then
    break
  fi
done
EXIT_STATUS=$EXIT_STATUS || $RET

cd $ROOT

exit $EXIT_STATUS
