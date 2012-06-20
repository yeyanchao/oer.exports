#!/bin/sh

# See the docs/link-checker.txt for info on how to use this alpha-level script

DBK_FILE=$1

ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.."; pwd` # .. since we live in scripts/

XSLTPROC="xsltproc"

LINK_CHECKER_XSL=$ROOT/xsl/debug/link-checker.xsl

$XSLTPROC $LINK_CHECKER_XSL $DBK_FILE 
