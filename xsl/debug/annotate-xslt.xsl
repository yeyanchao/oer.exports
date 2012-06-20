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


<!-- ================================================================
     This bad boy takes any xslt file and annotates every call to
     xsl:template, xsl:apply-templates, or xsl:call-template
     with comments that are generated in the resulting XML document
     effectively giving a stack trace of which templates were called.
     
     It also attempts to print out values of parameters passed.
     
     This file should be used like this:
     svn revert $XSLT && xsltproc xsl/debug/annotate-xslt.xsl $XSLT > $XSLT.new && mv $XSLT.new $XSLT
     ============================================================= -->


<xsl:import href="../ident.xsl"/>
<xsl:import href="annotate-attribute-sets.xsl"/>

<xsl:template match="xsl:template[@match and not(contains(@match,'@'))]">
  <xsl:copy>
    <xsl:apply-templates select="@*|xsl:param"/>
    <xsl:call-template name="comment"/>
    <xsl:apply-templates select="node()[not(self::xsl:param)]"/>
    <xsl:call-template name="comment">
      <xsl:with-param name="end" select="true()"/>
    </xsl:call-template>
  </xsl:copy>
</xsl:template>

<xsl:template name="comment">
  <xsl:param name="end" select="0"/>
	<xsl:variable name="v">
    <xsl:text> </xsl:text>
    <xsl:if test="$end != 0">
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:if test="$end = 0">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="name(.)"/>
    <xsl:apply-templates mode="comment" select="@*"/>
    <xsl:apply-templates mode="comment" select="xsl:param|xsl:with-param"/>
    <xsl:text> </xsl:text>
	</xsl:variable>
  <xsl:element name="xsl:comment">
  	<xsl:copy-of select="$v"/>
  </xsl:element>
</xsl:template>

<xsl:template mode="comment" match="@*">
  <xsl:text> </xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>="</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template mode="comment" match="xsl:param">
  <xsl:call-template name="param-pair">
    <xsl:with-param name="value">
      <xsl:element name="xsl:value-of">
        <xsl:attribute name="select">
          <xsl:text>substring(normalize-space($</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>),1,20)</xsl:text>
        </xsl:attribute>
      </xsl:element>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template mode="comment" match="xsl:with-param">
  <xsl:call-template name="param-pair">
    <xsl:with-param name="value">
      <xsl:choose>
        <xsl:when test="@select">
          <!-- <choose>
                  <when test="$select = node()">
                   [print-the-name-of-the-element]
                  </when>
                  <otherwise>
                    [print-the-value]
                  <otherwise>
                </choose>
          -->
          <xsl:element name="xsl:choose">
            <xsl:element name="xsl:when">
              <xsl:attribute name="test">
                <xsl:text>string-length(normalize-space(</xsl:text>
                <xsl:value-of select="@select"/>
                <xsl:text>)) &gt; 20</xsl:text>
              </xsl:attribute>
              <xsl:element name="xsl:value-of">
                <xsl:attribute name="select">
                  <xsl:text>substring(normalize-space(</xsl:text>
                  <xsl:value-of select="@select"/>
                  <xsl:text>),1,20)</xsl:text>
                </xsl:attribute>
              </xsl:element>
            </xsl:element>
            <xsl:element name="xsl:otherwise">
              <xsl:element name="xsl:value-of">
                <xsl:attribute name="select">
                	<xsl:text>substring(normalize-space(</xsl:text>
                  <xsl:value-of select="@select"/>
                  <xsl:text>),1,20)</xsl:text>
                </xsl:attribute>
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>NOSELECT</xsl:text>
          <!-- <xsl:copy-of select="*"/> -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="param-pair">
  <xsl:param name="name" select="@name"/>
  <xsl:param name="value"/>
  <xsl:text> {</xsl:text>
  <xsl:value-of select="$name"/>
  <xsl:text>="</xsl:text>
  <xsl:copy-of select="$value"/>
  <xsl:text>"}</xsl:text>
</xsl:template>

</xsl:stylesheet>
