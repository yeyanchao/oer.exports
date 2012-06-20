<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file: Converts a module docbook file (root is a db:section) into a db:book
     with one db:preface (db:preface instead of db:chapter to prevent labeling and numbering). 
     This is done so we generate a title page and cover image.
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>
<xsl:import href="dbk-link-externalizer.xsl"/>

<xsl:template match="/db:section">
    <db:book ext:site-type="{$cnx.site-type}">
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="db:sectioninfo" mode="cnx.bookify"/>
        <db:preface>
            <xsl:apply-templates select="node()"/>
        </db:preface>
    </db:book>
</xsl:template>

<xsl:template mode="cnx.bookify" match="/db:section/db:sectioninfo">
    <db:bookinfo>
        <xsl:apply-templates select="@*|node()"/>
        <!-- Add in the cover page image. Used by dbk2epub.xsl -->
        <db:mediaobject role="cover">
            <db:imageobject>
                <db:imagedata format="{$cnx.cover.format}" fileref="{$cnx.cover.image}"/>
            </db:imageobject>
        </db:mediaobject>
    </db:bookinfo>
</xsl:template>

<xsl:template match="/db:section/db:sectioninfo">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Discarding module-as-a-book metadata (except for the title)</xsl:with-param></xsl:call-template> 
    <db:prefaceinfo>
        <xsl:apply-templates select="@*|db:title|db:abstract"/>
    </db:prefaceinfo>
</xsl:template>

<!-- Discard all people except maintainers -->
<xsl:template match="db:sectioninfo/db:authorgroup/db:othercredit[db:contrib/text()='maintainer']"/>
</xsl:stylesheet>
