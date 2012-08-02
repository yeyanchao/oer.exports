<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  version="1.0">

<xsl:import href="debug.xsl"/>
<!--Customize the docbook.xsl to generate opf file for kindle -->
<xsl:import href="../docbook-xsl/epub/docbook-opf.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>

  <xsl:param name="opfpath" />
  <xsl:template match="/">
    <xsl:message>Generating opf file for mobi!</xsl:message>
    <xsl:call-template name="opf" />      

  </xsl:template>
   
</xsl:stylesheet>

