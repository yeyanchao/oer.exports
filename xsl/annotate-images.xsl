<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
>

<!-- This file:
	* Up-converts some cnxml0.5 (c:cnxn to c:link, or @src to @url)
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="no" method="xml"/>

<xsl:param name="image-sizes-xml-path"/>

<xsl:variable name="images" select="document($image-sizes-xml-path)"/>

<xsl:template match="db:imagedata[@fileref]">
  <xsl:variable name="name" select="@fileref"/>
  <xsl:variable name="info" select="$images/images/image[@name=$name]"/>
	<xsl:copy>
    <xsl:if test="$info">
      <xsl:attribute name="_actual-width">
        <xsl:value-of select="$info/@width"/>
      </xsl:attribute>
      <xsl:attribute name="_actual-height">
        <xsl:value-of select="$info/@height"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not($info)">
      <xsl:attribute name="_IMAGE_NOT_FOUND">true</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
