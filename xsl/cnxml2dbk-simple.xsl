<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- 
	Much of cnxml can be converted to docbook just by converting element names
	and attribute values. This file contains the straightforward conversions
 -->
<xsl:import href="debug.xsl"/>

<!-- Block elements in docbook cannot have free-floating text. they need to be wrapped in a db:para -->
<xsl:template name="block-id-and-children">
	<xsl:apply-templates select="@*"/>
	
	<!-- If something like a note has a label, add it. -->
	<xsl:if test="(c:title or c:label) and not(c:title and c:label != '')">
    	<db:title>
    		<xsl:apply-templates select="c:title/@*|c:title/node()"/>
    		<xsl:apply-templates select="c:label/@*|c:label/node()"/>
    	</db:title>
	</xsl:if>
	<xsl:if test="c:title and c:label">
		<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: c:label and c:title found in <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
	</xsl:if>
	
	<xsl:choose>
		<xsl:when test="normalize-space(text()) != ''">
			<db:para>
				<xsl:apply-templates select="node()[not(self::c:label or self::c:title)]"/>
			</db:para>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="node()[not(self::c:label or self::c:title)]"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="c:span">
	<db:token>
		<xsl:apply-templates select="@*|node()"/>
	</db:token>
</xsl:template>

<xsl:template match="c:note">
    <db:note><xsl:call-template name="block-id-and-children"/></db:note>
</xsl:template>
<xsl:template match="c:note[@type='warning']">
    <db:warning><xsl:call-template name="block-id-and-children"/></db:warning>
</xsl:template>
<xsl:template match="c:note[@type='tip' or @type='Tip']">
    <db:tip><xsl:call-template name="block-id-and-children"/></db:tip>
</xsl:template>
<xsl:template match="c:note/@*">
    <xsl:attribute name="{local-name()}">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>
<xsl:template match="c:footnote">
    <db:footnote><xsl:apply-templates select="@*|node()"/></db:footnote>
</xsl:template>
<xsl:template match="c:footnote[text()]">
    <db:footnote><xsl:apply-templates select="@*"/><db:para><xsl:apply-templates select="node()"/></db:para></db:footnote>
</xsl:template>
<xsl:template match="c:section">
    <db:section><xsl:call-template name="block-id-and-children"/></db:section>
</xsl:template>
<xsl:template match="c:equation">
	<db:equation><xsl:call-template name="block-id-and-children"/></db:equation>
</xsl:template>
<xsl:template match="c:equation[not(c:title)]">
	<db:informalequation><xsl:call-template name="block-id-and-children"/></db:informalequation>
</xsl:template>
<xsl:template match="c:para//c:equation[not(c:title)]">
	<db:inlineequation><xsl:call-template name="block-id-and-children"/></db:inlineequation>
</xsl:template>
<xsl:template match="c:example">
	<db:example><xsl:call-template name="block-id-and-children"/></db:example>
</xsl:template>
<xsl:template match="c:example[not(c:title)]">
	<db:informalexample><xsl:call-template name="block-id-and-children"/></db:informalexample>
</xsl:template>

<!-- Support c:rule (with c:statement and c:proof) -->
<xsl:template match="c:rule">
	<ext:rule>
		<xsl:if test="@type">
			<xsl:attribute name="type">
				<xsl:value-of select="@type"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*|node()"/>
	</ext:rule>
</xsl:template>

<xsl:template match="c:proof">
    <db:section ext:element="proof">
    	<xsl:apply-templates select="@*"/>
    	<db:title>
    		<xsl:apply-templates select="c:title/@*"/>
    		<xsl:if test="not(@type)">
    			<xsl:text>Proof</xsl:text>
    		</xsl:if>
    		<xsl:value-of select="@type"/>
    		<xsl:if test="c:title">
    			<xsl:text>: </xsl:text>
    			<xsl:apply-templates select="c:title/node()"/>
    		</xsl:if>
    	</db:title>
    	<xsl:apply-templates select="*[not(self::c:title)]"/>
    </db:section>
</xsl:template>

<xsl:template match="c:statement">
    <db:section ext:element="statement">
    	<xsl:apply-templates select="@*|node()"/>
    </db:section>
</xsl:template>


<xsl:template match="c:para">
    <db:para><xsl:apply-templates select="@*|node()"/></db:para>
</xsl:template>

<xsl:template match="c:caption">
	<db:caption>
                <xsl:if test="parent::c:subfigure">
                        <db:emphasis role="bold">
                                <xsl:number count="c:subfigure" format="(a) "/>
                        </db:emphasis>
                </xsl:if>
                <xsl:apply-templates select="@*|node()"/>
        </db:caption>
</xsl:template>
<xsl:template match="c:title">
	<db:title><xsl:apply-templates select="@*|node()"/></db:title>
</xsl:template>
<xsl:template match="c:item/c:title">
    <db:emphasis role="bold" ext:element="title"><xsl:apply-templates select="@*|node()"/></db:emphasis>
</xsl:template>

<xsl:template match="c:sub">
    <db:subscript><xsl:apply-templates select="@*|node()"/></db:subscript>
</xsl:template>
<xsl:template match="c:sup">
    <db:superscript><xsl:apply-templates select="@*|node()"/></db:superscript>
</xsl:template>

<xsl:template match="c:list">
    <db:itemizedlist><xsl:apply-templates select="@*|node()"/></db:itemizedlist>
</xsl:template>
<xsl:template match="c:list[@list-type='labeled-item']">
    <db:simplelist><xsl:apply-templates select="@*|node()"/></db:simplelist>
</xsl:template>
<xsl:template match="c:item/c:label">
	<xsl:variable name="markSuffix">
		<xsl:choose>
			<xsl:when test="../../@mark-suffix">
				<xsl:value-of select="../../@mark-suffix"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<db:emphasis role="bold">
		<xsl:apply-templates select="@*|node()"/>
		<xsl:value-of select="$markSuffix"/>
	</db:emphasis>
	<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="c:emphasis[not(@effect) or @effect='bold']">
    <db:emphasis role="bold"><xsl:apply-templates select="@*|node()"/></db:emphasis>
</xsl:template>
<xsl:template match="c:emphasis[@effect='italics']">
    <db:emphasis><xsl:apply-templates select="@*|node()"/></db:emphasis>
</xsl:template>
<xsl:template match="c:emphasis[@effect='normal']">
    <xsl:apply-templates select="node()"/>
</xsl:template>
<xsl:template match="c:emphasis">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Removing emphasis with @effect=<xsl:value-of select="@effect"/></xsl:with-param></xsl:call-template>
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="c:link" name="cnx.link">
    <xsl:param name="label">
        <xsl:apply-templates select="node()"/>
    </xsl:param>
    <xsl:variable name="document">
        <xsl:choose>
            <xsl:when test="@document">
                <xsl:value-of select="@document"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$cnx.module.id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="version">
        <xsl:choose>
            <xsl:when test="@version">
                <xsl:value-of select="@version"/>
            </xsl:when>
            <xsl:when test="not(@document) or @document=$cnx.module.id">
                <xsl:value-of select="/c:document/c:metadata/md:version/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>latest</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Either it's a db:link (outside Docbook) or a db:xref (inside Docbook) -->
    <xsl:choose>
        <xsl:when test="@url or @resource">
            <xsl:variable name="href">
                <!-- either use the @url or construct one (if it's a resource) -->
                <xsl:choose>
                    <xsl:when test="@url">
                        <xsl:value-of select="@url"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$cnx.resource.local = 0">
                            <xsl:call-template name="cnx.repository.url"/>
                        </xsl:if>
                        <xsl:value-of select="$document"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$version"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="@resource"/>    		
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <db:link xlink:href="{$href}" ext:document="{$document}" ext:resource="{@resource}">
                <xsl:apply-templates select="@*"/>
                <xsl:copy-of select="$label"/>
            </db:link>
        </xsl:when>
        <xsl:otherwise>
            <!-- These links may or may not end up being local but we won't know until the final stage
                (ie once all the modules are included)
             -->
            <xsl:variable name="href">
                <xsl:value-of select="$document"/>
                <xsl:if test="@target-id">
                    <xsl:value-of select="$cnx.module.separator"/>
                    <xsl:value-of select="@target-id"/>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$label!=''">
                    <db:link linkend="{$href}">
                        <xsl:apply-templates select="@*"/>
                        <xsl:copy-of select="$label"/>
                    </db:link>
                </xsl:when>
                <xsl:otherwise>
                    <db:xref linkend="{$href}">
                        <xsl:apply-templates select="@*"/>
                    </db:xref>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="c:code" name="cnx.convert.code">
    <db:code><xsl:apply-templates select="@*|node()"/></db:code>
</xsl:template>
<xsl:template match="c:code[c:title]">
    <db:formalpara>
        <xsl:apply-templates select="@*|c:title"/>
        <db:screen>
            <xsl:apply-templates select="node()[not(self::c:title)]"/>
        </db:screen>
    </db:formalpara>
</xsl:template>
<xsl:template match="c:code[not(c:title) and @display='block']">
    <db:screen><xsl:apply-templates select="@*|node()"/></db:screen>
    <!-- db:programlisting or db:literallayout/db:code are two potential alterantives to db:screen -->
</xsl:template>

<xsl:template match="c:preformat">
    <db:literallayout><xsl:apply-templates select="@*|node()"/></db:literallayout>
</xsl:template>
<xsl:template match="c:preformat[@display='inline']">
    <db:literal><xsl:apply-templates select="@*|node()"/></db:literal>
    <!-- Not sure if docbook has a better fit than db:literal for our inline c:preformat -->
</xsl:template>

<xsl:template match="c:quote[@display='inline']">
    <db:quote><xsl:apply-templates select="@*|node()"/></db:quote>
</xsl:template>
<xsl:template match="c:quote">
    <db:blockquote><xsl:apply-templates select="@*|node()"/></db:blockquote>
</xsl:template>

<xsl:template match="c:figure[not(c:title) and c:media/c:image]">
	<db:informalfigure><xsl:apply-templates select="@*|node()"/></db:informalfigure>
</xsl:template>
<xsl:template match="c:figure[c:title and c:media/c:image]">
	<db:figure><xsl:apply-templates select="@*|node()"/></db:figure>
</xsl:template>


<!-- Convert CALS Table -->
<xsl:template match="c:table">
	<db:table><xsl:apply-templates select="@*|node()"/></db:table>
</xsl:template>
<xsl:template match="c:tgroup">
	<db:tgroup><xsl:apply-templates select="@*|node()"/></db:tgroup>
</xsl:template>
<xsl:template match="c:thead">
	<db:thead><xsl:apply-templates select="@*|node()"/></db:thead>
</xsl:template>
<xsl:template match="c:tfoot">
	<db:tfoot><xsl:apply-templates select="@*|node()"/></db:tfoot>
</xsl:template>
<xsl:template match="c:tbody">
	<db:tbody><xsl:apply-templates select="@*|node()"/></db:tbody>
</xsl:template>
<xsl:template match="c:colspec">
	<db:colspec><xsl:apply-templates select="@*|node()"/></db:colspec>
</xsl:template>
<xsl:template match="c:row">
	<db:row><xsl:apply-templates select="@*|node()"/></db:row>
</xsl:template>
<xsl:template match="c:entry">
	<db:entry><xsl:apply-templates select="@*|node()"/></db:entry>
</xsl:template>
<xsl:template match="c:entrytbl">
	<db:entrytbl><xsl:apply-templates select="@*|node()"/></db:entrytbl>
</xsl:template>

<!-- Handle citations -->
<xsl:template match="c:cite">
	<!-- db:citation -->
	<xsl:apply-templates select="node()"/>
	<!-- /db:citation -->
</xsl:template>
<xsl:template match="c:cite[@url or @document or @target-id or @resource]">
	<xsl:variable name="label">
		<xsl:choose>
			<xsl:when test="@url">
				<xsl:text>url</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>link</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- db:citation -->
	<xsl:apply-templates select="node()"/>
	<!-- TODO: Treat it like a link....  -->
	<xsl:text> [</xsl:text>
	<xsl:call-template name="cnx.link">
		<xsl:with-param name="label">
			<xsl:value-of select="$label"/>
		</xsl:with-param>
	</xsl:call-template>
	<xsl:text>]</xsl:text>
	<!-- /db:citation -->
</xsl:template>
<xsl:template match="c:cite-title">
	<!-- db:citetitle -->
	<db:emphasis class="cite-title">
		<xsl:apply-templates select="@*|node()"/>
	</db:emphasis>
	<!-- /db:citetitle -->
</xsl:template>
<!-- 
	c: @pub-type (optional): The type of publication cited. May be any of the following: "article", "book", "booklet", "conference",
	   "inbook", "incollection", "inproceedings", "mastersthesis", "manual", "misc", "phdthesis", "proceedings", "techreport", "unpublished".
	db: @pubwork (enumeration)

    * "article"
    * "bbs"
    * "book"
    * "cdrom"
    * "chapter"
    * "dvd"
    * "emailmessage"
    * "gopher"
    * "journal"
    * "manuscript"
    * "newsposting"
    * "part"
    * "refentry"
    * "section"
    * "series"
    * "set"
    * "webpage"
    * "wiki"
 --> 
<xsl:template match="c:cite-title/@pub-type">
	<xsl:variable name="pubwork">
		<xsl:choose>
			<xsl:when test="@pub-type = 'article'">article</xsl:when>
			<xsl:when test="@pub-type = 'book'">book</xsl:when>
			<xsl:when test="@pub-type = 'booklet'">journal</xsl:when>
			<xsl:when test="@pub-type = 'conference'">journal</xsl:when>
			<xsl:when test="@pub-type = 'inbook'">journal</xsl:when>
			<xsl:when test="@pub-type = 'incollection'">webpage</xsl:when>
			<xsl:when test="@pub-type = 'inproceedings'">journal</xsl:when>
			<xsl:when test="@pub-type = 'mastersthesis'">manuscript</xsl:when>
			<xsl:when test="@pub-type = 'phdthesis'">manuscript</xsl:when>
			<xsl:when test="@pub-type = 'proceedings'">journal</xsl:when>
			<xsl:when test="@pub-type = 'techreport'">journal</xsl:when>
			<!--
			<xsl:when test="@pub-type = 'manual'"></xsl:when>
			<xsl:when test="@pub-type = 'misc'"></xsl:when>
			<xsl:when test="@pub-type = 'unpublished'"></xsl:when>
			-->
			<xsl:when test="not(@pub-type)"></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Unmatched c:cite-title type</xsl:with-param></xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:if test="$pubwork != ''">
		<xsl:attribute name="pubwork"><xsl:value-of select="$pubwork"/></xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- Prevent empty CNXML elements from getting into docbook.  Elements not listed here should either not be able to be empty or should have valid uses as an empty element. -->
<xsl:template match="c:title[not(node())]|
                     c:emphasis[not(node())]|
                     c:quote[not(node())]|
                     c:foreign[not(node())]|
                     c:code[not(node())]|
                     c:term[not(node())]|
                     c:meaning[not(node())]|
                     c:span[not(node())]|
                     c:div[not(node())]|
                     c:para[not(node())]|
                     c:cite-title[not(node())]|
                     c:footnote[not(node())]|
                     c:caption[not(node())]|
                     c:preformat[not(node())]|
                     c:sup[not(node())]|
                     c:sub[not(node())]">
    <xsl:comment> empty <xsl:value-of select="local-name()"/> tag </xsl:comment>
</xsl:template>

</xsl:stylesheet>
