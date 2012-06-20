<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xi='http://www.w3.org/2001/XInclude'
  xmlns:ext="http://cnx.org/ns/docbook+"
  exclude-result-prefixes="col md"
  >
<xsl:output omit-xml-declaration="yes"/>

<xsl:template match="col:param[@name='print-style']">
  <xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="col:*">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
