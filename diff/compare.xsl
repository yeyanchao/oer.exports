<xsl:stylesheet 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:exslt="http://exslt.org/common"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

<xsl:param name="cssPath" select="''" />
<xsl:param name="oldPath" select="'INVALID_VALUE._NEED_TO_SET_oldPath'" />

<xsl:template match="/">
  <xsl:variable name="old" select="document($oldPath)"/>
  <xsl:choose>
    <xsl:when test="$oldPath = '' or count($old) = 0">
      <xsl:message> oldPath currently set to "<xsl:value-of select="$oldPath"/>" and csspath="<xsl:value-of select="$cssPath"/>"</xsl:message>
      <xsl:message>You must set the XSL param oldPath to point to a valid document to compare against</xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="children">
        <xsl:with-param name="old" select="$old"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="children">
  <xsl:param name="old"/>
  <xsl:variable name="newCount" select="count(node())"/>
  <xsl:for-each select="node()">
    <xsl:variable name="pos" select="position()"/>
    <xsl:apply-templates select=".">
      <xsl:with-param name="old" select="$old/node()[$pos]"/>
    </xsl:apply-templates>
  </xsl:for-each>
  <xsl:if test="count($old/node()) &gt; $newCount">
    <span class="removed">
      <span class="message">[DIFF: <xsl:value-of select="count($old/node()) - $newCount"/> Nodes were removed]</span>
      <xsl:apply-templates mode="ident" select="$old/node()[position() &gt; $newCount]"/>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template match="@*">
  <xsl:copy/>
</xsl:template>
<xsl:template match="node()">
  <xsl:param name="old"/>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:call-template name="children">
      <xsl:with-param name="old" select="$old"/>
    </xsl:call-template>
  </xsl:copy>
</xsl:template>

<xsl:template mode="ident" match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates mode="ident" select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Inject a style so the Report is "colorful" -->
<xsl:template match="h:head">
  <xsl:copy>
    <xsl:apply-templates mode="ident" select="node()"/>
    <xsl:choose>
      <xsl:when test="$cssPath != ''">
        <link rel="stylesheet" href="{$cssPath}"/>
      </xsl:when>
      <xsl:otherwise>
        <base href=".."/>
      </xsl:otherwise>
    </xsl:choose>
    <style>
      .mismatch { background-color: #ffffcc !important; border: 1px dashed; display: inherit; }
      .added    { background-color: #ccffcc !important; border: 1px dashed; display: inherit; }
      .removed  { background-color: #ffcccc !important; border: 1px dashed; display: inherit; }
      .mismatch * { margin-left: 2em; }
      .pseudo-before,   .pseudo-after   { color: #cccccc; }
      .pseudo-before *, .pseudo-after * { color: black; }
    </style>
  </xsl:copy>
</xsl:template>

<xsl:template match="*">
  <xsl:param name="old"/>
  <xsl:choose>
    <xsl:when test="not($old)">
      <span class="added tag">
        <span class="message">[DIFF: New element: <xsl:value-of select="name(.)"/><xsl:if test="@class"> class="<xsl:value-of select="@class"/>"</xsl:if><xsl:if test="@style"> style="<xsl:value-of select="@style"/>"</xsl:if>]</span>
        <xsl:apply-templates mode="ident" select="."/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="name(.) != name($old)">
        <span class="mismatch tag">[DIFF: The tags mismatch: old="<xsl:value-of select="name($old)"/>" and new="<xsl:value-of select="name(.)"/>"]</span>
      </xsl:if>
      
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:if test="string(./@class) != string($old/@class)">
          <span class="mismatch class">[DIFF: Classes mismatch: old="<xsl:value-of select="$old/@class"/>" and new="<xsl:value-of select="./@class"/>"]</span>
        </xsl:if>
        <xsl:if test="string(./@style) != string($old/@style)">
          <span class="mismatch style">[DIFF: Styles mismatch: old="<xsl:value-of select="$old/@style"/>" and new="<xsl:value-of select="./@style"/>"]</span>
        </xsl:if>
        <xsl:call-template name="children">
          <xsl:with-param name="old" select="$old"/>
        </xsl:call-template>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()">
  <xsl:param name="old"/>
  <xsl:choose>
    <xsl:when test="normalize-space(string(.)) != normalize-space(string($old))">
      <span class="mismatch text">[DIFF: Text mismatch. old="<xsl:value-of select="$old"/>"]</span>
      <xsl:copy/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>