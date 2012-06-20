<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:bib="http://bibtexml.sf.net/"
  version="1.0">

<!-- A cute little stylesheet that performs an arbitrary Xpath evaluation on XML.
	Used mostly for development to find out things like:
	* Which modules contain a pesky MathML structure
	* How many instances of a c:figure//c:table are there
	* What are all the MathML nodes
 -->

	<xsl:import href="debug.xsl"/>
	<!-- Required -->
	<xsl:param name="cnx.module.id"/>
	<!-- Can be one of "module", "node", "xpath", or "" -->
	<xsl:param name="output" />

	<!-- The __XPATH variable will be dynamically replaced by a script -->
	<xsl:template match="__XPATH__">
		<xsl:choose>
			<xsl:when test="$output = 'module'">
				<xsl:value-of select="$cnx.module.id"/>
			</xsl:when>
			<xsl:when test="$output = 'node'">
				<xsl:apply-templates mode="copy" select="."/>
			</xsl:when>
			<xsl:when test="$output = 'xpath'">
				<xsl:value-of select="__XPATH2__"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">XPath Match</xsl:with-param></xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<xsl:template match="/|*">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- Don't render arbitrary text() nodes -->
	<xsl:template match="text()"/>
	
	<!-- For outputting an entire node -->
	<xsl:template mode="copy" match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates mode="copy" select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>