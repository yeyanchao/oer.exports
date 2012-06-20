<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  version="1.0">

  <xsl:output method="text"/>
  
  <!-- This file outputs the col:parameters to be used as args to xsltproc -->
  <xsl:template match="col:parameters/col:param">
        <xsl:value-of select="@name"/>
        <!-- Wrap the value in single quotes so it is treated as a string by xsltproc -->
        <xsl:text> "</xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>"</xsl:text>
        <!-- Print a newline -->
        <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- This file outputs the md:repository to be used as args to xsltproc -->
  <xsl:template match="col:metadata/md:repository">
        <xsl:text>cnx.url</xsl:text>
        <!-- Wrap the value in single quotes so it is treated as a string by xsltproc -->
        <xsl:text> "</xsl:text>
        <xsl:value-of select="text()"/>
        <xsl:text>/</xsl:text>
        <xsl:text>"</xsl:text>
        <!-- Print a newline -->
        <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- Recurse -->
  <xsl:template match="@*|node()"> 
    <xsl:apply-templates select="node()"/>
  </xsl:template>
</xsl:stylesheet>
