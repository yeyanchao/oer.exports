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
  xmlns:cnxorg="http://cnx.rice.edu/system-info"
  version="1.0">

<!-- This file:
     * Ensures paths to images inside modules are correct (using @xml:base)
     //* Adds a @ext:first-letter attribute to glossary entries so they can be organized into a book-level glossary 
     * Adds an Attribution section at the end of the book
     * Uses ext:persons element to eventually call docbook-xsl/common/common.xsl:"person.name.list" and render the names
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<!-- Strip 'em for html generation -->
<xsl:template match="@xml:base"/>

<!-- Make image (media) paths point into the module directory -->
<xsl:template match="@fileref|c:*[(self::c:audio or self::c:flash or self::c:video or self::c:java-applet or self::c:labview or self::c:download) and not(contains(@src, '/'))]/@src">
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="ancestor::db:section[@xml:base]">
          <xsl:value-of select="substring-before(ancestor::db:section[@xml:base]/@xml:base, '/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::*[@document]/@document"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:attribute name="{name(.)}">
        <xsl:if test="$prefix != ''">
            <xsl:value-of select="$prefix"/>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>

<!-- Creating an authors list for collections (STEP 1). Just collect all the authors (with duplicates) -->
<!-- Create 3 authorgroups for all authors, only collection authors, and for module authors (preserve ordering) -->
<xsl:template match="/db:book/db:bookinfo">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating 3 book-level db:authorgroups @role="all|collection|module"</xsl:with-param></xsl:call-template>
    <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating db:authorgroup @role="all"</xsl:with-param></xsl:call-template>
        <db:authorgroup role="all">
            <xsl:for-each select="..//db:authorgroup[not(ancestor::db:bibliography)]/db:*">
                <xsl:call-template name="ident"/>
            </xsl:for-each>
        </db:authorgroup>
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating db:authorgroup @role="collection"</xsl:with-param></xsl:call-template>
        <db:authorgroup role="collection">
            <xsl:for-each select="db:authorgroup/db:*">
                <xsl:call-template name="ident"/>
            </xsl:for-each>
        </db:authorgroup>
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating db:authorgroup @role="module"</xsl:with-param></xsl:call-template>
        <db:authorgroup role="module">
            <xsl:for-each select="..//db:authorgroup[not(parent::db:bookinfo) and not(parent::db:biblioentry)]/db:*">
                <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating db:authorgroup @role="module" db:author</xsl:with-param></xsl:call-template>

                <xsl:call-template name="ident"/>
            </xsl:for-each>
        </db:authorgroup>
        <xsl:apply-templates select="node()"/>
    </xsl:copy>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Done Generating 3 book-level db:authorgroups @role="all|collection|module"</xsl:with-param></xsl:call-template>

</xsl:template>

<!-- DEAD: Removed in favor of module-level glossaries
<!- - Overloading the file to add glossary metadata - ->
<xsl:template match="db:glossentry">
    <!- - Find the 1st character. Used later in the transform to generate a glossary alphbetically - ->
    <xsl:variable name="letters">
        <xsl:apply-templates mode="glossaryletters" select="db:glossterm/node()"/>
    </xsl:variable>
    <xsl:variable name="firstLetter" select="translate(substring(normalize-space($letters),1,1),'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: firstLetter="<xsl:value-of select="$firstLetter"/>" of "<xsl:value-of select="normalize-space($letters)"/>"</xsl:with-param></xsl:call-template>
    <db:glossentry ext:first-letter="{$firstLetter}">
        <xsl:apply-templates select="@*|node()"/>
    </db:glossentry>
</xsl:template>
<!- - Helper template to recursively find the text in a glossary term - ->
<xsl:template mode="glossaryletters" select="*">
    <xsl:apply-templates mode="glossaryletters"/>
</xsl:template>
<xsl:template mode="glossaryletters" select="text()">
    <xsl:value-of select="."/>
</xsl:template>
-->


<!-- Some modules don't have md:version set, so pull it from the collection -->
<xsl:template match="db:*[contains(local-name(), 'info') and parent::*[@cnxorg:version-at-this-collection-version] and not(db:edition)]">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Setting version of module using @cnxorg:version-at-this-collection-version since none was set</xsl:with-param></xsl:call-template>
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <db:edition>
            <xsl:value-of select="../@cnxorg:version-at-this-collection-version"/>
        </db:edition>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
