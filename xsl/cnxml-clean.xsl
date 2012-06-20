<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
xmlns:md="http://cnx.rice.edu/mdml" xmlns:bib="http://bibtexml.sf.net/"
    exclude-result-prefixes="c">

<!-- This file:
	* Up-converts some cnxml0.5 (c:cnxn to c:link, or @src to @url)
	* Sets the @mime-type for c:media
	* Removes c:div from c:para
	* Upgrades lists
	* Detects Word-imported lists and converts them
	* Adds mml:mtd to mml:mrow when missing
	* Converts QML (Quiz Markup) to cnxml
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>
<!-- Convert all QML to cnxml -->
<xsl:import href="qml2cnxml.xsl"/>

<xsl:output indent="no" method="xml"/>

<!-- Convert Content MathML to Presentation MathML -->
<xsl:include href="c2p.xsl"/>

<xsl:template match="root">
	<xsl:apply-templates/>
</xsl:template>

<!--  Fix some CNXML 0.5 stuff -->
<xsl:template match="c:link[@src]">
	<c:link url="{@src}">
		<xsl:apply-templates/>
	</c:link>
</xsl:template>

<!-- Some modules (like m11938) have a c:link/@document=''. Replace it with the current module id -->
<xsl:template match="c:link[@document='']/@document">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: replacing c:link/@document='' with the current module id</xsl:with-param></xsl:call-template>
    <xsl:attribute name="document">
        <xsl:value-of select="$cnx.module.id"/>
    </xsl:attribute>
</xsl:template>

<!-- Some modules (like m12669) have a c:link/@url="file.pdf" (use the URL attribute to point to a resource) -->
<xsl:template match="c:link[not(contains(@url, '/'))]/@url">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: replacing c:link/@url='resource.file' with @resource='resource.file'</xsl:with-param></xsl:call-template>
    <xsl:attribute name="resource">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>


<xsl:template match="c:media[@src]">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:if test="c:param[@name='alt']">
			<xsl:attribute name="alt"><xsl:value-of select="c:param[@name='alt']/@value"/></xsl:attribute>
		</xsl:if>
		<c:image>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="c:param[@name='print-width']">
				<xsl:attribute name="print-width"><xsl:value-of select="c:param[@name='print-width']/@value"/></xsl:attribute>
			</xsl:if>
		</c:image>
	</xsl:copy>
</xsl:template>

<xsl:template match="c:media/@type|c:image/@type">
	<xsl:call-template name="cnx.mime-type">
		<xsl:with-param name="mime-type" select="@type"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="cnx.mime-type" match="c:image/@mime-type">
	<xsl:param name="mime-type" select="@mime-type"/>
	<xsl:attribute name="mime-type">
		<xsl:choose>
			<xsl:when test="$mime-type='image/jpg'">image/jpeg</xsl:when>
			<xsl:when test="$mime-type=''">image/jpeg</xsl:when>
			<xsl:otherwise><xsl:value-of select="$mime-type"/></xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>


<xsl:template match="c:cnxn">
	<c:link>
		<xsl:apply-templates select="@*"/>
		<xsl:if test="@target"><xsl:attribute name="target-id">
			<xsl:value-of select="@target"/></xsl:attribute></xsl:if>
		<xsl:apply-templates/>
	</c:link>
</xsl:template>

<xsl:template match="c:name">
	<c:title>
		<xsl:apply-templates select="@*|node()"/>
	</c:title>
</xsl:template>


<xsl:template match="c:list[@type='inline']">
	<xsl:copy>
		<xsl:attribute name="display">inline</xsl:attribute>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="c:para//c:div">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Removing c:div</xsl:with-param></xsl:call-template>
	<xsl:apply-templates/> 
</xsl:template>

<!-- Word importer does not detect these. -->
<!-- 
<xsl:template match="c:list[c:item[1]/c:label/text()='a']">
	<xsl:call-template name="format-list"><xsl:with-param name="numberStyle">lower-alpha</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template match="c:list[c:item[1]/c:label/text()='A']">
	<xsl:call-template name="format-list"><xsl:with-param name="numberStyle">upper-alpha</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template match="c:list[c:item[1]/c:label/text()='i']">
	<xsl:call-template name="format-list"><xsl:with-param name="numberStyle">lower-roman</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template match="c:list[c:item[1]/c:label/text()='I']">
	<xsl:call-template name="format-list"><xsl:with-param name="numberStyle">upper-roman</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template name="format-list">
	<xsl:param name="numberStyle">arabic</xsl:param>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Inferring the @number-style on a list (probably imported from Word)</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:attribute name="list-type">enumerated</xsl:attribute>
		<xsl:attribute name="number-style"><xsl:value-of select="$numberStyle"/></xsl:attribute>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>
<xsl:template match="c:list[c:item[1]/c:label[text()='A' or text()='a' or text()='I' or text()='i']]/c:item/c:label"></xsl:template>
 -->

<!-- Word importer generates mml:mtr with no mml:mtd. This causes errors for the mathml2svg conversion -->
<xsl:template match="mml:mtr/mml:mrow">
	<mml:mtd>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</mml:mtd>
</xsl:template>

<!-- The attribute to denote an enumerated list changed between cnxml0.5 and cnxml0.6 -->
<xsl:template match="c:list/@type">
	<xsl:variable name="old" select="not(/c:document/@cnxml-version) or /c:document/@cnxml-version='0.5'"/>
	<xsl:choose>
		<xsl:when test=".='enumerated' and $old">
			<xsl:attribute name="list-type">
				<xsl:text>enumerated</xsl:text>
			</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="node()"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Sometimes (as in col10522/m17208) The number of columns defined does not match the actual number of columns. -->
<xsl:template match="@cols">
	<xsl:variable name="maxCols">
		<xsl:call-template name="cnx.findMaxCols">
			<xsl:with-param name="list" select="..//c:row"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:if test=". != $maxCols">
		<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: c:table @cols does not match actual number of columns. using actual number.</xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:attribute name="cols">
		<xsl:value-of select="$maxCols"/>
	</xsl:attribute>
</xsl:template>

<!-- Helper for mml:mtable fixing -->
<xsl:template name="cnx.findMaxCols">
	<xsl:param name="list" />
	<xsl:choose>
		<xsl:when test="$list">
			<xsl:variable name="first" select="count($list[1]/*)" />
			<xsl:variable name="max-of-rest">
				<xsl:call-template name="cnx.findMaxCols">
					<xsl:with-param name="list" select="$list[position()!=1]" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$first > $max-of-rest">
					<xsl:value-of select="$first" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$max-of-rest" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="md:version[text()='**new**' or text()='None']">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding md:version since it is set to "<xsl:value-of select="text()"/>"</xsl:with-param></xsl:call-template>
</xsl:template>

</xsl:stylesheet>
