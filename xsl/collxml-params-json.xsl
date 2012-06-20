<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  version="1.0">

  <xsl:output method="text"/>

<!-- Given the collxml extract XSLT parameters as a JSON dictionary
    to be used by etree.XSLT transforms.
-->

<xsl:template match="col:collection">
  <root>
  <xsl:text>{</xsl:text>
  <xsl:apply-templates select="node()"/>
  <xsl:text>"PLACEHOLDER":"JUST_HERE_SO_THE_LAST_JSON_COMMA_DOESNT_CAUSE_AN_ERROR"</xsl:text> <xsl:text>}</xsl:text>
  </root>
</xsl:template>
  
  <!-- This file outputs the col:parameters to be used as args to xsltproc -->
  <xsl:template match="col:parameters/col:param">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>":</xsl:text>
        <!-- Wrap the value in single quotes so it is treated as a string by xsltproc -->
        <xsl:text> "'</xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>'"</xsl:text>
        <xsl:text>,</xsl:text>
  </xsl:template>

  <!-- This file outputs the md:repository to be used as args to xsltproc -->
  <xsl:template match="col:metadata/md:repository">
        <xsl:text>"cnx.url":</xsl:text>
        <!-- Wrap the value in single quotes so it is treated as a string by xsltproc -->
        <xsl:text> "'</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>/</xsl:text>
        <xsl:text>'"</xsl:text>
        <xsl:text>,</xsl:text>
  </xsl:template>

  <!-- Recurse -->
  <xsl:template match="@*|node()">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
</xsl:stylesheet>
