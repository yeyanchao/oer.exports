#!/bin/bash

###################################################
# This script performs an xpath query on a module
#
# There are 4 different things that can be output:
# - The moduleId when an xpath matches
# - The node that matched
# - The result of another xpath
#   - ie: match "/" and then match "count(//mml:math)"
# - The debug string that provides an XPath to the matched node
#
# Additionally, a regular expression to grep for can be provided
#   as a quick-fail so xsltproc does not have to be called on every module
#

XPATH=$1
COL_PATH=$2
MODULE=$3
GREP_STR=$4
OUTPUT_TYPE=$5
XPATH2=$6

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

MOD_PATH=$COL_PATH/$MODULE/index.cnxml
ORIG_MODULE_XPATH_XSL=$ROOT/xsl/module-xpath.xsl
MODULE_XPATH_XSL=$ROOT/xsl/_$MODULE.tmp.xsl

# Escape double quotes with &quot; and < with &lt;
XPATH=`echo $XPATH | sed 's/\"/&quot;/g'`
XPATH=`echo $XPATH | sed 's/</&lt;/g'`

# Escape double quotes with &quot; and < with &lt;
XPATH2=`echo $XPATH2 | sed 's/\"/&quot;/g'`
XPATH2=`echo $XPATH2 | sed 's/</&lt;/g'`


XSLTPROC="xsltproc --stringparam cnx.module.id $MODULE"
if [ ".$OUTPUT_TYPE" != "." ]; then
  XSLTPROC="$XSLTPROC --stringparam output $OUTPUT_TYPE"
fi

echo "Checking $MODULE" 1>&2

if [ ".$GREP_STR" != "." ]; then
  GREP_FOUND=`grep "$GREP_STR" $MOD_PATH`
  if [ ".$GREP_FOUND" == "." ]; then exit 0; fi
fi

sed "s/__XPATH__/$XPATH/g" $ORIG_MODULE_XPATH_XSL > $MODULE_XPATH_XSL
if [ ".$XPATH2" != "." ]; then
  sed -i "s/__XPATH2__/$XPATH2/g" $MODULE_XPATH_XSL
fi
$XSLTPROC $MODULE_XPATH_XSL $MOD_PATH

rm $MODULE_XPATH_XSL
