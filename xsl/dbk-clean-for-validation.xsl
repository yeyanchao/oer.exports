<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<xsl:template mode="copy" match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates mode="copy" select="@*|node()"/>
    </xsl:copy>
</xsl:template>


<!-- @linkend can't be resolved for links to other modules. So, turn it into a xlink:href -->
<xsl:template match="db:link[@linkend]">
	<xsl:copy>
		<xsl:attribute name="xlink:href">
			<xsl:value-of select="@linkend"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>
<xsl:template match="db:xref[@linkend]">
	<xsl:copy>
		<xsl:attribute name="xlink:href">
			<xsl:value-of select="@linkend"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>


<!-- CALS Tables require a db:title. See m21870 -->
<xsl:template match="db:table[not(db:title)]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<db:title>INJECTED_TITLE</db:title>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<!-- For RNG. Whenever a non-db:section follows a section, wrap it in one
	since the children for db:section is (non-section*) followed by (section*)
 -->
<xsl:template match="*[preceding-sibling::db:section|preceding-sibling::db:simplesect]">
	<xsl:choose>
		<xsl:when test="local-name()!='section' and local-name()!='simplesect'">
    		<db:simplesect>
				<xsl:apply-templates select="@*"/>
    			<db:title>INJECTED_TITLE</db:title>
    			<xsl:apply-templates mode="copy" select="."/>
    		</db:simplesect>
    	</xsl:when>
    	<xsl:otherwise>
    		<xsl:apply-templates mode="copy" select="."/>
    	</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="db:section[not(db:title)]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">VALIDATION: Found a section without a title</xsl:with-param></xsl:call-template> 
	<db:simplesect>
		<xsl:apply-templates select="@*"/>
		<db:title>INJECTED_TITLE2</db:title>
		<xsl:apply-templates/>
	</db:simplesect>
</xsl:template>

<!-- The XSLT files and the RNG for storing SVG elements do not match. -->
<xsl:template match="db:imageobject[svg:*]">
	<db:imageobject>
		<db:imagedata format="SVG">
			<xsl:apply-templates select="@*|node()"/>
		</db:imagedata>
	</db:imageobject>
</xsl:template>

</xsl:stylesheet>
