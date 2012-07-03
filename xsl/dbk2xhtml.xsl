<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/xhtml-1_1/docbook.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>

<xsl:output indent="no" method="xml" />

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->
<xsl:param name="cnx.svg.compat">ONLY_USE_THE_RASTER_FIEL</xsl:param>
<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.master">8.5</xsl:param>
<xsl:param name="body.start.indent">0px</xsl:param>

<xsl:param name="header.rule" select="0"/>

<xsl:param name="generate.toc">
appendix  toc,title
chapter   toc,title
book      toc,title
</xsl:param>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!-- simplified math generates a c:span[@class="simplemath"] or db:token[@class="simplemath"] with a mml:math in it. for epubs, discard the simplemath -->
<xsl:template match="db:token[@class='simplemath' and db:inlinemediaobject]">
  <xsl:message>INFO: Discarding simplemath in favor of MathML/SVG</xsl:message>
  <xsl:apply-templates select="db:inlinemediaobject"/>
</xsl:template>
<!-- simplified math generates a c:span[@class="simplemath"] or db:token[@class="simplemath"] with a mml:math in it. for epubs, discard the mml:math 
<xsl:template match="db:token[@class='simplemath']/db:inlinemediaobject">
  <xsl:message>INFO: Discarding MathML in favor of simplemath</xsl:message>
</xsl:template>
<xsl:template match="db:token[@class='simplemath']/db:inlinemediaobject">
  <xsl:message>INFO: Discarding MathML SVG in favor of simplemath</xsl:message>
</xsl:template>
-->

<!-- The PDF has a nice way of handling footnotes so override Docbook's method -->
<xsl:template match="db:footnote">
  <div class="footnote" id="{@xml:id}">
    <xsl:apply-templates select="node()"/>
  </div>
</xsl:template>

<!-- from docbook-xsl/xhtml/footnote.xsl. Docbook adds a "[#]" in front of the para -->
<xsl:template match="d:footnote/d:para[1]|d:footnote/d:simpara[1]" priority="2">
  <p><xsl:call-template name="common.html.attributes"/>
    <xsl:attribute name="id">
		  <xsl:call-template name="object.id"/>
    </xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </p>
</xsl:template>


<!-- Wrapp glossterms with a span tag so we retain the @id (so the index can link to it) -->
<xsl:template match="d:glossentry/d:glossterm">
  <span class="glossterm" id="{@xml:id}">
    <xsl:apply-templates select="node()"/>
  </span>
  <xsl:if test="following-sibling::d:glossterm">, </xsl:if>
</xsl:template>

</xsl:stylesheet>
