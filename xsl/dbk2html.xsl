<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file converts dbk files to chunked html which is used in the offline HTML zip file.
    * Modifies links to be localized for offline zip file
 -->
<xsl:import href="dbk2epub.xsl"/>
<xsl:import href="dbk2html-media.xsl"/>

<!-- Import our local translation keys -->
<xsl:import href="l10n/cnxmll10n.xsl"/>

<xsl:param name="cnx.epub.start.filename" select="concat('start', $html.ext)"/>

<!-- Discard the "unsupported media link" and convert the inner c:media element -->
<xsl:template match="db:link[c:media]">
    <xsl:apply-templates select="c:media"/>
</xsl:template>


<!-- Chunk out a separate "start.html" file just above the OEBPS dir that has a link to the TOC -->
<xsl:template match="/">
    <xsl:variable name="titleFilename">
         <xsl:call-template name="make-relative-filename">
             <xsl:with-param name="base.dir" select="$base.dir"/>
             <xsl:with-param name="base.name">
                 <xsl:value-of select="$root.filename"/>
                 <xsl:value-of select="$html.ext"/>
             </xsl:with-param>
         </xsl:call-template>
    </xsl:variable>

    <!-- It's a collection and has a TOC so make a frame -->
    <xsl:variable name="tocFilename">
        <!-- The following is taken from Docbook. Apparently this is sprinkled (~ 6 times) in the Docbook Source -->
        <xsl:call-template name="make-relative-filename">
            <xsl:with-param name="base.dir" select="$base.dir"/>
            <xsl:with-param name="base.name">
                <xsl:call-template name="toc-href"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- If it's a module, generate a static TOC -->
    <xsl:if test="db:book/@ext:element='module'">
    
        <!-- Both of these file names need to not have the base.dir prepended to them -->
        <xsl:variable name="moduleFilename">
             <xsl:call-template name="make-relative-filename">
                 <xsl:with-param name="base.name">
                     <xsl:apply-templates select=".//db:preface" mode="recursive-chunk-filename"/>
                 </xsl:with-param>
             </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="justTitleFilename">
            <xsl:value-of select="$root.filename"/>
            <xsl:value-of select="$html.ext"/>
        </xsl:variable>

        <xsl:variable name="content">
            <html>
                <head>
                    <link rel="stylesheet" href="{$html.stylesheet}" type="text/css"/>
                </head>
                <body>
                    <h1><xsl:value-of select="db:book/db:bookinfo/db:title"/></h1>
                    <div class="toc">
                        <p><b>Table of Contents</b></p>
                        <dl>
                            <dt><a href="{$justTitleFilename}" target="main">Title Page</a></dt>
                            <dt><a href="{$moduleFilename}" target="main"><xsl:value-of select="db:book/db:bookinfo/db:title"/></a></dt>
                        </dl>
                    </div>
                </body>
            </html>
        </xsl:variable>
        
        <xsl:call-template name="write.chunk"> 
	        <xsl:with-param name="filename" select="$tocFilename"/> 
	        <xsl:with-param name="method" select="'xml'" /> 
	        <xsl:with-param name="encoding" select="'utf-8'" /> 
	        <xsl:with-param name="indent" select="'yes'" /> 
	        <xsl:with-param name="quiet" select="$chunk.quietly" /> 
	        <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank --> 
	        <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank --> 
	        <xsl:with-param name="content" select="$content"/> 
        </xsl:call-template>
        
    </xsl:if>

    <xsl:variable name="content">
        <html>
            <frameset cols="20%,80%">
                <frame src="{$tocFilename}" />
                <frame src="{$titleFilename}" name="main" />
            </frameset>
        </html>
    </xsl:variable>
    
    <xsl:call-template name="write.chunk"> 
        <xsl:with-param name="filename"> 
            <xsl:value-of select="$cnx.epub.start.filename" /> 
        </xsl:with-param> 
        <xsl:with-param name="method" select="'xml'" /> 
        <xsl:with-param name="encoding" select="'utf-8'" /> 
        <xsl:with-param name="indent" select="'yes'" /> 
        <xsl:with-param name="quiet" select="$chunk.quietly" /> 
        <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank --> 
        <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank --> 
        <xsl:with-param name="content" select="$content"/> 
    </xsl:call-template>

    <xsl:apply-imports/>
</xsl:template>

<!-- In order to get the TOC frame to open links in the main window, we add a target to the <a> tag -->
<!-- TAKEN FROM: docbook-xsl/xhtml-1_1/autotoc.xsl -->
<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>

 <span>
  <xsl:attribute name="class"><xsl:value-of select="local-name(.)"/></xsl:attribute>

  <!-- * if $autotoc.label.in.hyperlink is zero, then output the label -->
  <!-- * before the hyperlinked title (as the DSSSL stylesheet does) -->
  <xsl:if test="$autotoc.label.in.hyperlink = 0">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

  <!-- START: edit -->
  <a target="main">
  <!-- END: edit -->
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="context" select="$toc-context"/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    
  <!-- * if $autotoc.label.in.hyperlink is non-zero, then output the label -->
  <!-- * as part of the hyperlinked title -->
  <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
  </a>
  </span>
</xsl:template>


<xsl:key name="id" match="*" use="@id|@xml:id"/>
<!-- Convert links to resources to be local links -->
<xsl:template match="db:link[@ext:resource!='']">
    <xsl:choose>
        <xsl:when test="@document and count(key('id', @document) )=0">
            <xsl:apply-imports/>
        </xsl:when>
		<xsl:otherwise>
		    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating local link to resource</xsl:with-param></xsl:call-template>
		    <xsl:variable name="linkend">
		        <xsl:if test="not(/db:book[@ext:element='module'])">
		            <!-- If we're generating a collection, include the module dir. -->
		            <xsl:value-of select="@ext:document"/>
		            <xsl:text>/</xsl:text>
		        </xsl:if>
		        <xsl:value-of select="@ext:resource"/>
		    </xsl:variable>
		    <xsl:variable name="content">
		        <xsl:choose>
		            <xsl:when test="text()">
		                <xsl:value-of select="text()"/>
		            </xsl:when>
		            <xsl:otherwise>
		                <xsl:value-of select="@ext:resource"/>
		            </xsl:otherwise>
		        </xsl:choose>
		    </xsl:variable>
		
		    <xsl:call-template name="simple.xlink">
		        <xsl:with-param name="node" select="."/>
		        <xsl:with-param name="linkend" select="$linkend"/>
		        <xsl:with-param name="xhref" select="$linkend"/>
		        <xsl:with-param name="content" select="$content"/>
		    </xsl:call-template>
		</xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>

