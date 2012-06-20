<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
    exclude-result-prefixes="c">

<!-- This file:
	* Massages the MathML so it is suitable for conversion to SVG (ensures mml:mo contains only 1 character, all mml:mtr have the same number of columns, etc)
	* Prints out when Content MathML was not converted to Presentation MathML
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="no" method="xml"/>

<!-- Remove empty mml:mo -->
<xsl:template match="mml:mo[normalize-space(text())='']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Removing whitespace mml:mo from c2p transform</xsl:with-param></xsl:call-template>
</xsl:template>


<!-- pmml2svg chokes on this -->
<xsl:template match="mml:mo[string-length(normalize-space(text())) > 1]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: mml:mo contains more than 1 character and pmml2svg doesn't like that. '<xsl:value-of select="normalize-space(text())"/>'</xsl:with-param></xsl:call-template>
	<mml:mtext>
		<xsl:apply-templates select="@*|node()"/>
	</mml:mtext>
</xsl:template>

<!-- pmml2svg chokes on this.
	See: m21852
	Can't just remove mml:mi because it could be in a mml:msub
 -->
<xsl:template match="mml:mi[count(*)=0 and normalize-space(text())='']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Converting empty mml:mi to a mml:mspace</xsl:with-param></xsl:call-template>
	<mml:mspace />
</xsl:template>


<!-- pmml2svg Does not support certain nodes yet. Display an error and use the non-embellished child.
	See: m21852
 -->
<xsl:template match="mml:mmultiscripts|mml:mlabeledtr|mml:mpadded|mml:mglyph|mml:mprescripts|mml:none">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Cannot convert this MathML node to SVG (for image generation). Please try to use something else. Name=<xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
	<xsl:apply-templates select="mml:*[1]"/>
</xsl:template>


<!-- Make sure only Presentation MathML is left. All presentation MathML starts with 'm' or is the element 'none'
	Unfortunately, pmml2svg can't handle the element mml:none. so, we'll convert mml:none to mml:mspace
    match="*[namespace-uri(.)='http://www.w3.org/1998/Math/MathML' and (not(starts-with(local-name(.), 'm')) or 'none'=local-name(.))]"
    See: m21852
-->
<xsl:template match="mml:none" priority="100">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Converting mml:none to a mml:mspace</xsl:with-param></xsl:call-template>
	<mml:mi>.</mml:mi>
</xsl:template>
<!-- Make sure only Presentation MathML is left. All presentation MathML starts with 'm' or is the element 'none'
-->
<xsl:template match="*[namespace-uri(.)='http://www.w3.org/1998/Math/MathML' and not(starts-with(local-name(.), 'm') or local-name(.)='semantics' or local-name(.)='annotation-xml') or local-name(.)='max' or local-name(.)='min' or local-name(.)='minus']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Found some Content MathML that seeped through. <xsl:value-of select="local-name(.)"/></xsl:with-param></xsl:call-template>
	<mml:mi>
		<xsl:apply-templates select="@*|node()"/>
	</mml:mi>
</xsl:template>

<xsl:template match="mml:apply" priority="100">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Found some Content MathML that seeped through. mml:apply</xsl:with-param></xsl:call-template>
	<mml:mspace/>
</xsl:template>

<xsl:template match="mml:cn" priority="100">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Found some Content MathML that seeped through. mml:cn</xsl:with-param></xsl:call-template>
	<mml:mn>
		<xsl:apply-templates select="text()"/>
	</mml:mn>
</xsl:template>

<!-- For some reason the mml:* pass the RNG but still only have 1 child.
-->
<xsl:template match="mml:munder[count(*)=1]" priority="100">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: mml:munder only has 1 child. Unwrapping the element</xsl:with-param></xsl:call-template>
	<xsl:apply-templates/>
</xsl:template>

<!-- 
	pmml2svg cannot handle mml:mtable with different numbers of mml:mtd.
	So, pad them.
	See: m21927
 -->
<xsl:template match="mml:mtable">
	<xsl:if test="count(.//mml:mtr) > 50">
		<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: An mml:mtable with more than 50 rows may not convert to an image.</xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:variable name="maxCols">
		<xsl:call-template name="findMaxCols">
			<xsl:with-param name="list" select="mml:mtr"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="maxRow" select="mml:mtr[count(mml:mtd) = $maxCols][1]"/>
	<xsl:if test="$maxCols = 0">
		<!-- Discard empty tables. See: m30615 -->
		<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Discarding mml:mtable with no mml:mtd</xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:if test="$maxCols > 0">
		<mml:mtable>
			<xsl:apply-templates select="@*"/>
			<!-- For-each row, make sure it has the same number of mml:mtd's by filling in empty ones -->
			<xsl:for-each select="mml:mtr">
				<xsl:variable name="currentRow" select="."/>
				<xsl:if test="$maxCols != count(mml:mtd)">
					<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Mismatched number of mml:mtd in the mml:mtable. Adding an empty mml:mtd</xsl:with-param></xsl:call-template>
				</xsl:if>
				<mml:mtr>
					<xsl:apply-templates select="@*"/>
					<xsl:for-each select="$maxRow/mml:mtd">
						<xsl:variable name="pos" select="position()"/>
						<xsl:choose>
							<xsl:when test="$pos > count($currentRow/mml:mtd)">
								<mml:mtd><mml:mrow/></mml:mtd>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$currentRow/mml:mtd[$pos]"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</mml:mtr>
			</xsl:for-each>
		</mml:mtable>
	</xsl:if>
</xsl:template>
<!-- Helper for mml:mtable fixing -->
<xsl:template name="findMaxCols">
	<xsl:param name="list" />
	<xsl:choose>
		<xsl:when test="$list">
			<xsl:variable name="first" select="count($list[1]/mml:mtd)" />
			<xsl:variable name="max-of-rest">
				<xsl:call-template name="findMaxCols">
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


<!-- mml:msup or mml:msub with 1 child causes SVG generation to choke. -->
<xsl:template match="mml:msub[2 > count(*)]|mml:msup[2 > count(*)]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: MathML contains a subscript or superscript with only 1 child. Removing the tag and continuing.</xsl:with-param></xsl:call-template>
	<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="mml:msub[count(*) > 2]|mml:msup[count(*) > 2]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: MathML contains a subscript or superscript with too many children. Using only the first ones and discarding the rest.</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="*[1]"/>
		<xsl:apply-templates select="*[2]"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="mml:maligngroup">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: MathML to SVG conversion does not support the following element. Skipping <xsl:value-of select="local-name()"/>.</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- QML to cnxml creates c:div tags which are done right before this step. -->
<xsl:template match="c:para//c:div">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Unwrapping c:div inside a c:para and adding c:newline around it</xsl:with-param></xsl:call-template>
	<xsl:comment>c:div</xsl:comment>
	<c:newline>
		<xsl:apply-templates select="@*"/>
	</c:newline>
	<xsl:apply-templates select="node()"/>
	<c:newline/>
	<xsl:comment>/c:div</xsl:comment>
</xsl:template>
<xsl:template match="c:div">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Converting c:div into a c:para</xsl:with-param></xsl:call-template>
	<c:para>
		<xsl:apply-templates select="@*|node()"/>
	</c:para>
</xsl:template>

<!-- Convert an empty mml:msqrt into a character. See: m31126 -->
<xsl:template match="mml:msqrt[count(*)=0]">
	<mml:mtext>&#8730;<!-- sqrt --></mml:mtext>
</xsl:template>

<!-- Convert an empty mml:mfrac into a simple dash. See col10823/m30403 -->
<xsl:template match="mml:mfrac[count(*)=0]">
	<mml:mi>-</mml:mi>
</xsl:template>


<!-- @fontstyle and @fontweight are deprecated in MathML 2 in favor of @mathvariant -->
<xsl:template match="@fontstyle[not(../@fontweight)]|@fontweight">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Upgrading MathML1 @fontstyle or @fontweight to MathML2 @mathvariant="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
  <xsl:attribute name="mathvariant">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- Match when there is a @fontstyle and @fontweight -->
<xsl:template match="@fontweight[../@fontstyle]">
  <xsl:variable name="variant">
    <xsl:call-template name="cnx.mathvariant">
      <xsl:with-param name="weight" select="."/>
      <xsl:with-param name="style" select="../@fontstyle"/>
    </xsl:call-template>
  </xsl:variable>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Upgrading MathML1 @fontstyle AND @fontweight to MathML2 @mathvariant="<xsl:value-of select="$variant"/>"</xsl:with-param></xsl:call-template>
  <xsl:attribute name="mathvariant">
    <xsl:value-of select="$variant"/>
  </xsl:attribute>
</xsl:template>

<xsl:template name="cnx.mathvariant">
  <xsl:param name="weight"/>
  <xsl:param name="style"/>
  <!-- weight/style could be empty; if so make them 'normal' -->
  <xsl:variable name="w">
    <xsl:value-of select="$weight"/>
    <xsl:if test="$weight = ''">
      <xsl:text>normal</xsl:text>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="s">
    <xsl:value-of select="$style"/>
    <xsl:if test="$style = ''">
      <xsl:text>normal</xsl:text>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="'normal' = $w and 'normal' = $s">
      <xsl:text>normal</xsl:text>
    </xsl:when>
    <xsl:when test="'normal' = $w">
      <xsl:value-of select="$s"/>
    </xsl:when>
    <xsl:when test="'normal' = $s">
      <xsl:value-of select="$w"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$w"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$s"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="mml:mstyle[@fontstyle|@fontweight]//mml:mi">
  <xsl:variable name="variant">
    <xsl:call-template name="cnx.mathvariant">
      <xsl:with-param name="weight" select="mml:mstyle[@fontstyle|@fontweight][1]/@fontweight"/>
      <xsl:with-param name="style" select="mml:mstyle[@fontstyle|@fontweight][1]/@fontstyle"/>
    </xsl:call-template>
  </xsl:variable>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Upgrading MathML1 @fontstyle or @fontweight on a mml:mi with mml:mstyle ancestor to MathML2 @mathvariant="<xsl:value-of select="$variant"/>"</xsl:with-param></xsl:call-template>

  <xsl:copy>
    <xsl:attribute name="mathvariant">
      <xsl:value-of select="$variant"/>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
