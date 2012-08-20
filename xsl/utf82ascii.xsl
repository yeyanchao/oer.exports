<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <!-- Convert unicode characters to their escaped ASCII equivalents (ie &#8842; instead of a non-ASCII character) -->
  <xsl:output encoding="ASCII"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
