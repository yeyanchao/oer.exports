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
	It:
	* unwraps a module (whose root is db:section) and puts it in a db:preface, db:chapter, db:section
	* puts in empty db:title elements for informal equations (TODO: Not sure why, maybe for labeling and linking)
	* generates a per-chapter glossary instead of a module-wide one
	* Converts links to content not included in the book to external links
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>
<xsl:import href="param.xsl"/>
<xsl:import href="dbk-link-externalizer.xsl"/>

<xsl:output indent="no" method="xml"/>

<!-- Because FOP is picky with directories inject the absolute dir to images:
     * If the current dir is the tempdir then the fop.xconf file needs absolute paths to fonts
     * If the current dir is FOP then the images (this XML) needs absolute paths.
-->
<xsl:param name="cnx.tempdir.path"/>


<!-- TODO: No longer discards solutions from the docbook. Fix epub generation
<xsl:template match="ext:solution[not(@print-placement='here')]">
</xsl:template>
-->

<xsl:template match="@class">
  <xsl:attribute name="class">
    <xsl:choose>
      <xsl:when test=". = 'homework'">problems-exercises</xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>


<!-- Collapse XIncluded modules -->
<xsl:template match="db:section[@document][db:section and count(*[not(self::db:title)])=1]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Removing wrapper element around Xincluded module inside a <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*|db:section/@*"/>
		<xsl:element name="db:{local-name()}info">
			<xsl:apply-templates select="db:title"/>
			<xsl:apply-templates select="db:section/db:sectioninfo/node()"/>
		</xsl:element>
		<xsl:apply-templates select="node()[not(self::db:section or self::db:title)]"/>
		<xsl:apply-templates select="db:section/node()[not(self::db:sectioninfo)]"/>
	</xsl:copy>
</xsl:template>

<!-- Save the original title for attribution later. -->
<xsl:template match="db:*[(local-name()='preface' or local-name()='chapter' or local-name()='appendix' or local-name()='section') and db:title and count(db:section)=1]/db:section/db:sectioninfo/db:title">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding original title</xsl:with-param></xsl:call-template>
    <ext:original-title>
        <xsl:apply-templates select="@*|node()"/>
    </ext:original-title>
</xsl:template>



<!-- Boilerplate -->
<xsl:template match="/">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="db:informalequation">
	<db:equation>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:equation>
</xsl:template>

<xsl:template match="db:informalexample">
	<db:example>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:example>
</xsl:template>

<!-- Convert informalfigures (that aren't subfigures) into figures so they are numbered -->
<xsl:template match="db:informalfigure[not(ancestor::db:figure)]">
	<db:figure>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:figure>
</xsl:template>



<!-- Combine all module glossaries into an end-of-chapter glossary -->
<!-- We can't just apply-templates on glossary entries because there are duplicates -->
<xsl:template match="db:chapter">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
		<xsl:if test=".//db:glossentry">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: creating</xsl:with-param></xsl:call-template>
			<db:glossary>
				<xsl:variable name="letters">
					<xsl:for-each select=".//db:glossentry/db:glossterm">
						<xsl:sort select="translate(substring(normalize-space(text()), 1, 1), $cnx.smallcase, $cnx.uppercase)"/>
						<xsl:variable name="char" select="substring(normalize-space(text()), 1, 1)"/>
						<xsl:variable name="letter" select="translate($char, $cnx.smallcase, $cnx.uppercase)"/>
						<xsl:value-of select="$letter"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: letters="<xsl:value-of select="$letters"/>"</xsl:with-param></xsl:call-template>
				<xsl:call-template name="cnx.glossary">
					<xsl:with-param name="letters" select="$letters"/>
				</xsl:call-template>
			</db:glossary>
		</xsl:if>
	</xsl:copy>
</xsl:template>
<xsl:template mode="glossaryletters" match="@*">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template name="cnx.glossary">
	<xsl:param name="letters"/>
	<xsl:variable name="letter" select="substring($letters, 1, 1)"/>
	
	<!-- Skip all duplicates of letters until the last one, which we process -->
	<xsl:if test="string-length($letters) = 1 or $letter != substring($letters,2,1)">
    <xsl:apply-templates select=".//db:glossentry[$letter=translate(substring(db:glossterm/text(), 1, 1), $cnx.smallcase, $cnx.uppercase)]">
      <xsl:sort select="concat(db:glossterm/text(), db:glossterm//text())"/>
    </xsl:apply-templates>
	</xsl:if>

	<xsl:if test="string-length($letters) > 1">
		<xsl:call-template name="cnx.glossary">
			<xsl:with-param name="letters" select="substring($letters, 2)"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Discard the module-level glossary -->
<xsl:template match="db:glossary">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding module-level glossary and combining into book-level glossary</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Creating an authors list for collections (STEP 2). Remove duplicates -->
<xsl:template match="db:authorgroup/db:*">
	<xsl:variable name="userId" select="@ext:user-id"/>
    <xsl:variable name="role" select="@ext:role"/>
	<xsl:variable name="name" select="local-name()"/>
	<xsl:choose>
		<xsl:when test="not(preceding-sibling::db:*[local-name()=$name and @ext:user-id=$userId and @ext:role=$role])">
			<xsl:call-template name="ident"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding duplicate author and editor</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Convert db:anchor elements and links to them to point to the parent figure.
	They were added to preserve id's of subfigures (for linking)
 -->
<xsl:key name="id" match="*[@id or @xml:id]" use="@id|@xml:id"/>
<xsl:template match="@linkend">
	<xsl:variable name="target" select="key('id', .)"/>
	<xsl:attribute name="linkend">
		<xsl:choose>
            <!-- Can't link to a db:imageobject (Docbook doesn't generate a img/@id for it) so link to the parent db:mediaobject -->
			<xsl:when test="'anchor' = local-name($target) or 'imageobject' = local-name($target)">
			     <xsl:variable name="ancestor" select="$target/ancestor::*[@xml:id][1]"/>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Relinking db:anchor to <xsl:value-of select="local-name($ancestor)"/></xsl:with-param></xsl:call-template>
				<xsl:value-of select="$ancestor/@xml:id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="db:anchor">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Removing db:anchor and relinking db:anchor (probably created by converting c:subfigure)</xsl:with-param></xsl:call-template>
</xsl:template>


<!-- Because FOP is picky with directories inject the absolute dir to images:
     * If the current dir is the tempdir then the fop.xconf file needs absolute paths to fonts
     * If the current dir is FOP then the images (this XML) needs absolute paths.
-->
<xsl:template match="@fileref">
  <xsl:attribute name="fileref">
    <xsl:if test="string-length($cnx.tempdir.path) != 0">
      <xsl:value-of select="$cnx.tempdir.path"/>
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

</xsl:stylesheet>
