<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  version="1.0">

<!-- This file converts dbk files to chunked epub files.
    * Generates TOC information for epubs
    * Sets chunking settings
    * Embeds STIX fonts
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/epub/docbook.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>

<xsl:param name="cnx.svg.compat">ONLY_USE_THE_RASTER_FIEL</xsl:param>

<xsl:param name="epub.oebps.dir" select="'content/'"/>

<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>
<xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
<xsl:param name="chunker.output.encoding" select="'ASCII'"/>

<!-- Embedded fonts are passed in from the dbk2epub script.
    This is necessary because the script adds the fonts into the epub manually
 -->
<!-- xsl:param name="epub.embedded.fonts" select="'fonts/STIXGeneral.ttf,fonts/STIXGeneralBol.ttf,fonts/STIXGeneralBolIta.ttf,fonts/STIXGeneralItalic.ttf,fonts/STIXSiz1Sym.ttf,fonts/STIXSiz1SymBol.ttf'"/ -->


<!-- Defined in docbook-xsl/epub/docbook.xsl but the default does not use the $html.ext defined in docbook -->
<xsl:param name="epub.cover.html" select="concat('cover', $html.ext)" />


<!-- Fix up TOC-generation for the ncx file.
    Overrides code in docbook-xsl/docbook.xsl using code from docbook-xsl/xhtml-1_1/autotoc.xsl
 -->
  <xsl:template match="db:book|
                       db:article|
                       db:part|
                       db:reference|
                       db:preface|
                       db:chapter|
                       db:bibliography|
                       db:appendix|
                       db:glossary|
                       db:section|
                       db:sect1|
                       db:sect2|
                       db:sect3|
                       db:sect4|
                       db:sect5|
                       db:refentry|
                       db:colophon|
                       db:bibliodiv[db:title]|
                       db:setindex|
                       db:index"
                mode="ncx">
    <xsl:variable name="depth" select="count(ancestor::*)"/>
    <xsl:variable name="title">
      <xsl:if test="$epub.autolabel != 0">
        <xsl:variable name="label.markup">
          <xsl:apply-templates select="." mode="label.markup" />
        </xsl:variable>
        <xsl:if test="normalize-space($label.markup)">
          <xsl:value-of
            select="concat($label.markup,$autotoc.label.separator)" />
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="." mode="title.markup" />
    </xsl:variable>

    <xsl:variable name="href">
      <xsl:call-template name="href.target.with.base.dir">
        <xsl:with-param name="context" select="/" />
        <!-- Generate links relative to the location of root file/toc.xml file -->
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>
    <xsl:variable name="order">
      <xsl:value-of select="$depth +
                                  count(preceding::db:part|
                                  preceding::db:reference|
                                  preceding::db:book[parent::db:set]|
                                  preceding::db:preface|
                                  preceding::db:chapter|
                                  preceding::db:bibliography|
                                  preceding::db:appendix|
                                  preceding::db:article|
                                  preceding::db:glossary|
                                  preceding::db:section[not(parent::db:partintro)]|
                                  preceding::db:sect1[not(parent::db:partintro)]|
                                  preceding::db:sect2|
                                  preceding::db:sect3|
                                  preceding::db:sect4|
                                  preceding::db:sect5|
                                  preceding::refentry|
                                  preceding::db:colophon|
                                  preceding::db:bibliodiv[db:title]|
                                  preceding::db:index)"/>
    </xsl:variable>


  <xsl:variable name="depth2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'section'">
        <xsl:value-of select="count(ancestor::db:section) + 1"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'sect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'sect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'sect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'sect4'">4</xsl:when>
      <xsl:when test="local-name(.) = 'sect5'">5</xsl:when>
      <xsl:when test="local-name(.) = 'refsect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'refsect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'refsect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'simplesect'">
        <!-- sigh... -->
        <xsl:choose>
          <xsl:when test="local-name(..) = 'section'">
            <xsl:value-of select="count(ancestor::db:section)"/>
          </xsl:when>
          <xsl:when test="local-name(..) = 'sect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'sect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'sect3'">4</xsl:when>
          <xsl:when test="local-name(..) = 'sect4'">5</xsl:when>
          <xsl:when test="local-name(..) = 'sect5'">6</xsl:when>
          <xsl:when test="local-name(..) = 'refsect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'refsect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'refsect3'">4</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

    <xsl:if test="not(local-name()='section' or local-name()='simplesect') or $toc.section.depth &gt; $depth2">

    <xsl:element name="ncx:navPoint">
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>

      <xsl:attribute name="playOrder">
        <xsl:choose>
          <xsl:when test="/*[self::db:set]">
            <xsl:value-of select="$order"/>
          </xsl:when>
          <xsl:when test="$root.is.a.chunk != '0'">
            <xsl:value-of select="$order + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$order - 0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:element name="ncx:navLabel">
        <xsl:element name="ncx:text"><xsl:value-of select="normalize-space($title)"/> </xsl:element>
      </xsl:element>
      <xsl:element name="ncx:content">
        <xsl:attribute name="src">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="db:book[parent::db:set]|db:part|db:reference|db:preface|db:chapter|db:bibliography|db:appendix|db:article|db:glossary|db:section|db:sect1|db:sect2|db:sect3|db:sect4|db:sect5|db:refentry|db:colophon|db:bibliodiv[db:title]|db:setindex|db:index" mode="ncx"/>
    </xsl:element>

    </xsl:if>

  </xsl:template>


<!-- Make the title page show up first in readers.
    Originally in docbook-xsl/epub/docbook.xsl
 -->
  <xsl:template name="opf.spine">

    <xsl:element namespace="http://www.idpf.org/2007/opf" name="spine">
      <xsl:attribute name="toc">
        <xsl:value-of select="$epub.ncx.toc.id"/>
      </xsl:attribute>
      
      <!-- Put cover image first -->
      <xsl:if test="/*/*[db:cover or contains(name(.), 'info')]//db:mediaobject[@role='cover' or ancestor::db:cover]"> 
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref">
            <xsl:value-of select="$epub.cover.id"/>
          </xsl:attribute>
          <xsl:attribute name="linear">
          <xsl:choose>
            <xsl:when test="$epub.cover.linear">
              <xsl:text>yes</xsl:text>
            </xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
          </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>

      <!-- Make sure the title page is the 1st item in the spine after the cover -->
      <xsl:if test="db:book">
          <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
            <xsl:attribute name="idref">
              <xsl:value-of select="generate-id(db:book)"/>
            </xsl:attribute>
          </xsl:element>
      </xsl:if>

      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref"> <xsl:value-of select="$epub.html.toc.id"/> </xsl:attribute>
          <xsl:attribute name="linear">yes</xsl:attribute>
        </xsl:element>
      </xsl:if>  

      <!-- TODO: be nice to have a idref="titlepage" here -->
      <xsl:choose>
        <xsl:when test="$root.is.a.chunk != '0'">
          <xsl:apply-templates select="/*" mode="opf.spine"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/*/*" mode="opf.spine"/>
        </xsl:otherwise>
      </xsl:choose>
                                   
    </xsl:element>
  </xsl:template>


<!-- Customize the metadata generated for the epub.
    Originally from docbook-xsl/epub/docbook.xsl -->
<xsl:template mode="opf.metadata" match="db:authorgroup[@role='all' or not(@role)]">
    <xsl:apply-templates mode="opf.metadata" select="node()"/>
</xsl:template>



<!-- Add any embedded TrueType fonts (allow support for TTF in addition to opentype) -->
<!-- Originally taken from docbook-xsl/epub/docbook.xsl -->
  <xsl:template name="embedded-font-item"> 
    <xsl:param name="font.file"/> 
    <xsl:param name="font.order" select="1"/> 
 
    <xsl:element namespace="http://www.idpf.org/2007/opf" name="item"> 
      <xsl:attribute name="id"> 
        <xsl:value-of select="concat('epub.embedded.font.', $font.order)"/> 
      </xsl:attribute> 
      <xsl:attribute name="href"><xsl:value-of select="$font.file"/></xsl:attribute> 
      <xsl:choose> 
        <xsl:when test="contains($font.file, 'otf')"> 
          <xsl:attribute name="media-type">font/opentype</xsl:attribute> 
        </xsl:when> 
<!-- SSTART: edit -->
        <xsl:when test="contains($font.file, 'ttf')">
            <xsl:attribute name="media-type">font/truetype</xsl:attribute>
        </xsl:when>
<!-- END: edit -->
        <xsl:otherwise> 
          <xsl:message> 
            <xsl:text>WARNING: OpenType fonts should be supplied! (</xsl:text> 
            <xsl:value-of select="$font.file"/> 
            <xsl:text>)</xsl:text> 
          </xsl:message> 
        </xsl:otherwise>  
      </xsl:choose> 
    </xsl:element> 
  </xsl:template> 


<!-- simplified math generates a c:span[@class="simplemath"] or db:token[@class="simplemath"] with a mml:math in it. for epubs, discard the mml:math -->
<xsl:template match="db:token[@class='simplemath']/db:inlinemediaobject">
  <xsl:message>INFO: Discarding MathML in favor of simplemath</xsl:message>
</xsl:template>
<xsl:template match="db:token[@class='simplemath']/db:inlinemediaobject">
  <xsl:message>INFO: Discarding MathML SVG in favor of simplemath</xsl:message>
</xsl:template>



  <!-- OVERRIDES xhtml-1_1/chunk-code.xsl   -->
  <!-- Add chunking for bibliography as root element -->
  <!-- AN OVERRIDE --> 
  <xsl:template match="d:chapter|
                       d:appendix"
                priority="1">       
  <!-- END OF OVERRIDE --> 
    <xsl:choose>
      <xsl:when test="$onechunk != 0 and parent::*">
        <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process-chunk-element"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

