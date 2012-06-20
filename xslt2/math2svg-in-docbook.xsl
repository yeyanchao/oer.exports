<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:math="http://www.w3.org/1998/Math/MathML"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:svg="http://www.w3.org/2000/svg"
		xmlns:t="http://localhost/tmp"
		xmlns:func="http://localhost/functions"
		xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
		exclude-result-prefixes="math t xs func svg pmml2svg">

  <xsl:import href="../xsl/ident.xsl"/>
 
  <!-- Import pMML2SVG stylesheet -->
  <xsl:import href="math2svg-customized/pmml2svg.xsl"/>

  <!-- Output for svg -->
  <xsl:output method="xml" indent="no" version="1.0"
	      omit-xml-declaration="no"
	      cdata-section-elements="style"/>

  <!-- ####################################################################
       ROOT ELEMENT
       #################################################################### -->
  <xsl:template match="math:math">
    <xsl:variable name="idNode" select="ancestor::*[@xml:id or @id][1]"/>
    <xsl:variable name="idNode2" select="ancestor::*[@xml:id or @id][2]"/>
    <xsl:message>LOG: INFO: MathML2SVG id="<xsl:value-of select="concat($idNode2/@xml:id, $idNode2/@id,'//', $idNode/@xml:id, $idNode/@id)"/>"</xsl:message>
    <xsl:variable name="size" select="ancestor::*[@font-size][1]/@font-size"/>
    <!-- FOP can have @font-size="small" for example -->
    <xsl:variable name="sizeNumber">
      <xsl:choose>
        <xsl:when test="'' = replace($size, '[A-Za-z%]', '')">10pt</xsl:when>
        <xsl:otherwise><xsl:value-of select="$size"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sizeFromContext" select="number(replace($sizeNumber, '[A-Za-z%]', ''))"/>
    <xsl:variable name="masterUnit" select="replace($sizeNumber, '[0-9.]', '')"/>

    <!-- Is element embedded in text -->
    <xsl:variable name="embedded" select="string-length(normalize-space(string-join(parent::*/parent::*/text(), ''))) != 0"/>

    <xsl:variable name="svgOutput">
      <xsl:apply-imports>
	<xsl:with-param name="initSize" select="$sizeFromContext" tunnel="yes"/>
	<xsl:with-param name="svgMasterUnit" select="$masterUnit" tunnel="yes"/>
	<!-- Set display style from context -->
	<xsl:with-param name="displayStyle" select="if ($embedded) then 'false' else 'true'" tunnel="yes"/>
      </xsl:apply-imports>
    </xsl:variable>

    
    <xsl:copy-of select="$svgOutput"/>
    <xsl:copy-of select="."/><!-- Keep the original MathML -->
  </xsl:template>

<!-- ignore annotation elements -->
<xsl:template match="math:annotation|math:annotation-xml" mode="formatting"/>
</xsl:stylesheet>
