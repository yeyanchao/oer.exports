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

<!-- This file converts local links to external ones if the target isn't in the collection/module.
    It:
	* Converts links to content not included in the book into external links
 -->

<xsl:key name="id" match="*[@id or @xml:id]" use="@id|@xml:id"/>
<!-- Make links to unmatched ids external -->
<xsl:template match="db:xref[@document]|db:link[@document]">
	<xsl:choose>
		<!-- if the target (or module) is in the document, then all is well -->
		<xsl:when test="id(@linkend)">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="url">
				<xsl:call-template name="cnx.repository.url"/>
				<xsl:value-of select="@document"/>
				<xsl:text>/</xsl:text>
				<xsl:choose>
					<xsl:when test="@version">
						<xsl:value-of select="@version"/>
					</xsl:when>
					<xsl:when test="key('id', @document)">
		  			   <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Making external link to a resource and using the contained module version</xsl:with-param></xsl:call-template>
					   <xsl:value-of select="key('id', @document)/@ext:version"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>latest</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>/</xsl:text>
                                <xsl:value-of select="@resource"/>
				<xsl:if test="@target-id">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="@target-id"/>
				</xsl:if>
			</xsl:variable>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Making external link to content</xsl:with-param></xsl:call-template>
			<db:link xlink:href="{$url}" type="external-content" class="external-content">
				<xsl:if test="not(text())">
					<xsl:value-of select="@document"/>
				</xsl:if>
                <xsl:apply-templates select="node()"/>
			</db:link>
		</xsl:otherwise>
	</xsl:choose>
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

</xsl:stylesheet>
