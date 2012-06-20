<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xi='http://www.w3.org/2001/XInclude'
  xmlns:ext="http://cnx.org/ns/docbook+"
  exclude-result-prefixes="col md"
  >
<xsl:include href="cnxml2dbk.xsl"/>

<xsl:output indent="no"/>

<xsl:template match="col:*/@*">
	<xsl:copy/>
</xsl:template>

<xsl:template match="col:collection">
	<xsl:variable name="url">
		<xsl:value-of select="col:metadata/md:content-url/text()"/>
	</xsl:variable>
	<xsl:variable name="id">
		<xsl:value-of select="col:metadata/md:content-id/text()"/>
	</xsl:variable>
	<db:book ext:url="{col:metadata/md:content-url/text()}" ext:id="{col:metadata/md:content-id/text()}" ext:repository="{col:metadata/md:repository/text()}" ext:site-type="{$cnx.site-type}">
		<xsl:apply-templates select="@*|node()"/>
	</db:book>
</xsl:template>

<xsl:template match="col:metadata">
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

<!-- Modules before the first subcollection are preface frontmatter -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(preceding-sibling::col:subcollection)]" priority="100">
	<db:preface>
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
	</db:preface>
</xsl:template>

<!-- Modules after the last subcollection are appendices -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(following-sibling::col:subcollection)]" priority="100">
  <db:appendix>
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
  </db:appendix>
</xsl:template>


<!-- Free-floating Modules in a col:collection should be treated as Chapters -->
<xsl:template match="col:collection/col:content/col:module"> 
	<!-- TODO: Convert the db:section root of the module to a chapter. Can't now because we create xinclude refs to it -->
	<db:chapter>
		<xsl:apply-templates select="@*|node()"/>
		<xsl:call-template name="cnx.xinclude.module"/>
	</db:chapter>
</xsl:template>

<xsl:template match="col:collection/col:content/col:subcollection">
	<db:chapter><xsl:apply-templates select="@*|node()"/></db:chapter>
</xsl:template>

<!-- Subcollections in a chapter should be treated as a section -->
<xsl:template match="col:subcollection/col:content/col:subcollection">
	<db:section><xsl:apply-templates select="@*|node()"/></db:section>
</xsl:template>

<xsl:template match="col:content">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="col:module">
    <db:section>
        <xsl:apply-templates select="@*|node()"/>
        <xsl:call-template name="cnx.xinclude.module"/>
    </db:section>
</xsl:template>


<xsl:template match="md:title">
	<db:title><xsl:apply-templates/></db:title>
</xsl:template>



<xsl:template match="@id|@xml:id|comment()|processing-instruction()">
    <xsl:copy/>
</xsl:template>

<xsl:template name="cnx.xinclude.module">
    <xi:include href="{@document}/index.included.dbk"/>
</xsl:template>

</xsl:stylesheet>
