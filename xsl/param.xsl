<?xml version="1.0" encoding="ASCII"?>
<!-- All the parameters the XSLT files can take. Most transforms will only use a subset -->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

<!-- Sprinkle in useful debugging information to the content (like module id in titles) -->
<xsl:param name="cnx.debug" select="0"/>

<!-- Is this a cnx site or a Rhaptos site? -->
<xsl:param name="cnx.site-type" select="'Connexions'"></xsl:param>

<!-- Used to update the ids so they are unique within a collection -->
<xsl:param name="cnx.module.id"/>
<xsl:param name="cnx.repository.url">http://cnx.org/content/</xsl:param>
<!-- Possible options for this param:
	* "" to disable chunking
	* "svg" to chunk but not convert
	* "png" to chunk and (later) convert to PNG using the stderr from this xsl and imagemagick's convert
	* "jpg" to chunk and (later) convert to JPEG using the stderr from this xsl and imagemagick's convert
 -->
<xsl:param name="cnx.svg.extension">png</xsl:param>
<!-- Used to set whether or not <html:object/> should be generated as a fallback. -->
<xsl:param name="cnx.svg.compat">raw-svg</xsl:param>
<xsl:param name="cnx.svg.chunk" select="1"/>

<!-- Do not add the URL if we are generating a HTML zip -->
<xsl:param name="cnx.resource.local" select="0"/>

<!-- Used when converting the mdml:license -->
<xsl:param name="cnx.license">It is licensed under the Creative Commons Attribution License: </xsl:param>

<!-- The following parameters are used for debugging and gathering statistics -->
<xsl:param name="cnx.log.onlybugs" select="0"/> 
<xsl:param name="cnx.log.onlyaggregate" select="1"/>
<xsl:param name="cnx.log.nowarn" select="0"/> 

<!-- When generating id's we need to prefix them with a module id. 
	This is the text between the module, and the module-specific id. -->
<xsl:param name="cnx.module.separator">-</xsl:param>
<!-- HACK: FOP generation requires that db:imagedata be missing but epub/html needs it -->
<xsl:param name="cnx.output.fop" select="0"/>

<!-- Used for including the coverpage image -->
<xsl:param name="cnx.cover.image">cover.png</xsl:param>
<xsl:param name="cnx.cover.format">PNG</xsl:param>


<!-- Parameters used by the MathML Content-to-presentation XSL -->
  <xsl:param name="meannotation" select="''"/>
  <xsl:param name="forallequation" select="0"/>
  <xsl:param name="vectornotation" select="''"/>
  <xsl:param name="andornotation" select="''"/>
  <xsl:param name="realimaginarynotation" select="''"/>
  <xsl:param name="scalarproductnotation" select="''"/>
  <xsl:param name="vectorproductnotation" select="''"/>

  <xsl:param name="conjugatenotation" select="''"/>
  <xsl:param name="curlnotation" select="''"/>
  <xsl:param name="gradnotation" select="''"/>
  <xsl:param name="remaindernotation" select="''"/>
  <xsl:param name="complementnotation" select="''"/>
  <xsl:param name="imaginaryi" select="'&#x2148;'" />

<!-- Parameters used by the cnxml0.5 to 0.6 XSL -->
  <xsl:param name="moduleid"/>

<!-- Parameters used by the cnxmlL10n.xsl -->
  <xsl:param name="output-l10n-keys" select="'0'"/> 
<!-- 
  <xsl:param name="l10n.xml"/> 
  <xsl:param name="local.l10n.xml"/> 
 -->

<!-- Docbook parameters -->
<xsl:param name="chunk.quietly">1</xsl:param>
<xsl:param name="svg.doctype-public">-//W3C//DTD SVG 1.1//EN</xsl:param>
<xsl:param name="svg.doctype-system">http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd</xsl:param>
<xsl:param name="svg.media-type">image/svg+xml</xsl:param>
<xsl:param name="runinhead.default.title.end.punct" /> <!-- Don't add periods after para titles. -->

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>

<!-- Generate @id attributes instead of anchor tags -->
<xsl:param name="generate.id.attributes" select="1"/>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="xref.with.number.and.title">0</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>


<!-- Use .html for viewing in IE
     Use .xhtml so browsers are in XML-mode (and render inline SVG). -->
<xsl:param name="html.ext">.html</xsl:param>
<xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>

<!-- There are 2 namespaces for mdml, so we convert the old one to the new one, and process it -->
<xsl:param name="exsl.node.set.available"> 
  <xsl:choose>
    <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo="" test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'),                          'Apache Software Foundation')">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<!-- Used for case-insensitive matching of c:rule/@type -->
<xsl:param name="cnx.upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
<xsl:param name="cnx.lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

<!-- Putting this here since it's used in more than one file. -->
<xsl:param name="attribution.section.id" select="'book-attribution'"/>

<!-- FOP stuff -->
<!-- When numbering exercises, only use the last number.
     Otherwise, things like "1.2.3.4.10" end up being the label
     see col10614 -->
<xsl:param name="qanda.inherit.numeration">0</xsl:param>
<!-- 
<xsl:param name="insert.xref.page.number">yes</xsl:param>
-->

<!-- Page Headers should be marked as all-uppercase.
     Since XSLT1.0 doesn't have fn:uppercase, we'll translate()
-->
<xsl:variable name="cnx.smallcase" select="'abcdefghijklmnopqrstuvwxyz&#228;&#235;&#239;&#246;&#252;&#225;&#233;&#237;&#243;&#250;&#224;&#232;&#236;&#242;&#249;&#226;&#234;&#238;&#244;&#251;&#229;&#248;&#227;&#245;&#230;&#339;&#231;&#322;&#241;'"/>
<xsl:variable name="cnx.uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ&#196;&#203;&#207;&#214;&#220;&#193;&#201;&#205;&#211;&#218;&#192;&#200;&#204;&#210;&#217;&#194;&#202;&#206;&#212;&#219;&#197;&#216;&#195;&#213;&#198;&#338;&#199;&#321;&#209;'"/>

</xsl:stylesheet>
