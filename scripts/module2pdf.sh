#!/bin/sh -xv

# 1st arg is the path to the collection
# 2nd arg (optional) is the module name

echo "NOTE: You will need to change lib/fop.xconf to point to absolute paths!"
echo "      Otherwise, errors will arise below!!!"

COL_PATH=$1

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

declare -x FOP_OPTS=-Xmx512M

XSLTPROC="xsltproc"
FOP="bash $ROOT/fop/fop -c $ROOT/lib/fop.xconf"

# XSL files
DOCBOOK_CLEANUP_XSL=$ROOT/xsl/dbk-clean-whole.xsl
DOCBOOK2FO_XSL=$ROOT/xsl/dbk2fo.xsl
ALIGN_XSL=$ROOT/xsl/fo-align-math.xsl


# Load up the custom params to xsltproc:
if [ -s $ROOT/params.txt ]; then
    #echo "Using custom params in params.txt for xsltproc."
    # cat $ROOT/params.txt
    OLD_IFS=$IFS
    IFS="
"
    XSLTPROC_ARGS=""
    for ARG in `cat $ROOT/params.txt`; do
      XSLTPROC_ARGS="$XSLTPROC_ARGS --param $ARG"
    done
    IFS=$OLD_IFS
    XSLTPROC="$XSLTPROC $XSLTPROC_ARGS"
fi

MODULES=`ls $COL_PATH`
if [ ".$2" != "." ]; then MODULES=$2; fi

for MODULE in $MODULES
do
    if [ -d $COL_PATH/$MODULE ]; then
        echo "Converting $MODULE"
        if [ ! -d $COL_PATH/$MODULE/index.dbk ]; then
            bash $ROOT/scripts/module2dbk.sh $COL_PATH $MODULE 2> /dev/null > /dev/null
            DOCBOOK_ERR=$?
            if [ $DOCBOOK_ERR -ne 0 ]; then
                echo "Error creating docbook (probably MathML to SVG). Continuing..." 1>&2
            fi
        fi

        DOCBOOK=$COL_PATH/$MODULE/index.dbk
        DOCBOOK2=$COL_PATH/$MODULE/index.cleaned.dbk
        UNALIGNED=$COL_PATH/$MODULE/index.fo
        FO=index.aligned.fo
        PDF=index.pdf

        echo "LOG: --------- Starting on Module $MODULE ------------"
        $XSLTPROC --xinclude -o $DOCBOOK2 $DOCBOOK_CLEANUP_XSL $DOCBOOK
        
        $XSLTPROC -o $UNALIGNED $DOCBOOK2FO_XSL $DOCBOOK2  2> $COL_PATH/$MODULE/_err.log
        $XSLTPROC -o $COL_PATH/$MODULE/$FO $ALIGN_XSL $UNALIGNED 2> /dev/null
        
        # Change to the collection dir so the relative paths to images work
        cd $COL_PATH/$MODULE
        $FOP $FO $PDF > _fop.log 2> _fop.err.log
        ERR_CODE=$?
        cd $ROOT

        if [ $ERR_CODE -eq 0 ];
        then
            rm $COL_PATH/$MODULE/_err.log 2> /dev/null
            rm $COL_PATH/$MODULE/_fop.log 2> /dev/null
            rm $COL_PATH/$MODULE/_fop.err.log 2> /dev/null
            rm $DOCBOOK2 2> /dev/null
            rm $UNALIGNED 2> /dev/null
            rm $FO 2> /dev/null
        fi
        if [ $ERR_CODE -ne 0 ];
        then
            echo "Error generating pdf"
        fi
    fi
done
