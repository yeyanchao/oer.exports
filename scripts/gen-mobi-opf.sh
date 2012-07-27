#!/bin/bash
HTML_FILE=$1
WORKING_DIR=$2
str1="<x-metadata><EmbeddedCover>cover.png</EmbeddedCover></x-metadata></metadata>"
str2='<manifest><item id="item1" media-type="text/x-oeb1-document" href="'${HTML_FILE}'"></item></manifest><spine><itemref idref="item1"/></spine><guide><reference href="'${HTML_FILE}'#toc" type="toc" title="Table of Contents"/></guide></package>'
sed -i "s,<\/metadata>,${str1}," ${WORKING_DIR}/content.opf
sed -i "s,<\/package>,${str2},"  ${WORKING_DIR}/content.opf
