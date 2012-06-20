<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

<!-- This file just performs an identity transform on elements.
	Some of the conversion steps only convert parts of XML and let the rest pass through unchanged.
	They include this file.
 -->

<xsl:output method="xml" encoding="ASCII"/>

<xsl:template name="ident" match="@*|node()|comment()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()|comment()|processing-instruction()"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
