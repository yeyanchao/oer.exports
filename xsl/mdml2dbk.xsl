<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns="http://cnx.rice.edu/mdml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:ext="http://cnx.org/ns/docbook+"
  exclude-result-prefixes="c xlink db md exsl"
  version="1.0">

<!-- This file converts module and collection mdml to elements Docbook understands. -->

<!-- Convert the roles to individual author/maintainer/etc elements -->
<xsl:template match="md:roles">
	<db:authorgroup>
		<xsl:apply-templates select="@*|node()"/>
	</db:authorgroup>
</xsl:template>
<xsl:template match="md:role[text()]">
	<xsl:call-template name="cnx.lookup.people">
		<xsl:with-param name="ids"><xsl:apply-templates select="text()"/><xsl:text> </xsl:text></xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template name="cnx.lookup.people">
	<xsl:param name="ids"/>
	<xsl:variable name="first" select="substring-before($ids,' ')"/>
	<xsl:variable name="rest" select="substring-after($ids,' ')"/>
	<xsl:choose>
		<xsl:when test="@type = 'author'">
			<db:author>
                <xsl:call-template name="cnx.lookup.person">
                    <xsl:with-param name="id" select="$first"/>
			    </xsl:call-template>
			</db:author>
		</xsl:when>
		<xsl:when test="@type = 'editor'">
			<db:editor>
                <xsl:call-template name="cnx.lookup.person">
                    <xsl:with-param name="id" select="$first"/>
                </xsl:call-template>
			</db:editor>
		</xsl:when>
		<xsl:when test="@type = 'translator'">
			<db:othercredit class="translator">
                <xsl:call-template name="cnx.lookup.person">
                    <xsl:with-param name="id" select="$first"/>
                </xsl:call-template>
			</db:othercredit>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: converting role to db:othercredit[@class='other'] <xsl:value-of select="@type"/></xsl:with-param></xsl:call-template>
			<db:othercredit class="other">
                <xsl:call-template name="cnx.lookup.person">
                    <xsl:with-param name="id" select="$first"/>
                </xsl:call-template>
				<db:contrib><xsl:value-of select="@type"/></db:contrib>
			</db:othercredit>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$rest != ''">
		<xsl:call-template name="cnx.lookup.people">
			<xsl:with-param name="ids" select="$rest"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="cnx.lookup.person">
    <xsl:param name="id"/>
    <xsl:param name="role" select="@type"/>
    <xsl:attribute name="ext:user-id">
        <xsl:value-of select="$id"/>
    </xsl:attribute>
    <xsl:attribute name="ext:role">
        <xsl:value-of select="$role"/>
    </xsl:attribute>
    <xsl:apply-templates select="../../md:actors/md:*[@userid=$id]"/>
</xsl:template>

<xsl:template match="md:license">
	<db:legalnotice>
		<xsl:value-of select="$cnx.license"/>
		<db:ulink url="{@url}"><xsl:value-of select="@url"/></db:ulink>
		<xsl:apply-templates/>
	</db:legalnotice>
</xsl:template>


<!-- Simple transforms: -->
<xsl:template match="md:person"><xsl:apply-templates/></xsl:template>
<xsl:template match="md:organization"><xsl:apply-templates/></xsl:template>
<xsl:template match="md:organization/md:fullname">
	<db:firstname><xsl:apply-templates/></db:firstname>
</xsl:template>
<xsl:template match="md:firstname">
	<db:firstname><xsl:apply-templates/></db:firstname>
</xsl:template>
<xsl:template match="md:othername">
	<db:othername><xsl:apply-templates/></db:othername>
</xsl:template>
<xsl:template match="md:surname">
	<db:surname><xsl:apply-templates/></db:surname>
</xsl:template>
<xsl:template match="md:email">
	<db:email><xsl:apply-templates/></db:email>
</xsl:template>
<xsl:template match="md:revised">
	<db:pubdate><xsl:apply-templates/></db:pubdate>
</xsl:template>
<xsl:template match="md:version">
	<db:edition><xsl:apply-templates/></db:edition>
</xsl:template>
<xsl:template match="md:keywordlist">
	<db:keywordset><xsl:apply-templates/></db:keywordset>
</xsl:template>
<xsl:template match="md:keyword">
	<db:keyword><xsl:apply-templates/></db:keyword>
</xsl:template>
<xsl:template match="md:subjectlist">
	<db:subjectset><xsl:apply-templates/></db:subjectset>
</xsl:template>
<xsl:template match="md:subject">
	<db:subject><xsl:apply-templates/></db:subject>
</xsl:template>
<xsl:template match="md:abstract">
	<db:abstract><db:para><xsl:apply-templates/></db:para></db:abstract>
</xsl:template>

<xsl:template match="md:derived-from">
	<ext:derived-from>
		<xsl:apply-templates select="@*|node()"/>
	</ext:derived-from>
</xsl:template>

<!-- Ignore the following metadata elements -->
<!-- Ignore actors. they're only used by md:roles -->
<xsl:template match="md:title|md:content-id|md:created|md:language|md:fullname|md:actors|md:repository|md:content-url"/>

<xsl:template match="md:derived-from/md:title">
    <db:title>
        <xsl:apply-templates select="@*|node()"/>
    </db:title>
</xsl:template>
 
</xsl:stylesheet>
