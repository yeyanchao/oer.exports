<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file is run once all modules are converted and once all module dbk files are XIncluded.
	See the docs/link-checker.txt for info on how to use this alpha-level script
	It:
	* Prints out statistics for every link in the module/collection
	* Most importantly, it prints an xpath to broken links.
 -->

<xsl:import href="../debug.xsl"/>

<xsl:output indent="yes"/>

<!-- Note: To integrate with the website, this should probably be JSON (easy to do using the xml2json.xsl found in CNXMLTransform) -->
<xsl:template match="/">
    <link-stats>
        <xsl:apply-templates select="node()"/>
    </link-stats>
</xsl:template>

<xsl:key name="id" match="*[@id or @xml:id]" use="@id|@xml:id"/>
<!-- Make links to unmatched ids external -->
<xsl:template match="db:xref|db:link[@linkend]">
    <xsl:variable name="from" select="ancestor-or-self::*[@ext:element='module']/@xml:id"/>
    <xsl:variable name="to" select="@linkend"/>
    <xsl:variable name="xpath" select="@ext:xpath"/>
    <xsl:choose>
        <xsl:when test="id(@linkend)">
            <matched from="{$from}" to="{$to}" xpath="{$xpath}"/>
        </xsl:when>
        <xsl:otherwise>
            <unmatched from="{$from}" to="{$to}" xpath="{$xpath}"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
</xsl:template>

<!-- Print external links too! -->
<xsl:template match="db:link[@xlink:href]">
    <xsl:variable name="from" select="ancestor-or-self::*[@ext:element='module']/@xml:id"/>
    <xsl:variable name="to" select="@xlink:href"/>
    <xsl:variable name="xpath" select="@ext:xpath"/>
    <external from="{$from}" to="{$to}" xpath="{$xpath}"/>
    <xsl:apply-templates/>
</xsl:template>

<!-- Catch-all that just recurses -->
<xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
</xsl:template>

</xsl:stylesheet>
