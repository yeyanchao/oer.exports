<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="c mml">

<!-- Converts MathML that could otherwise be expressed in cnxml (using things like c:sup, c:emphasis) -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:param name="cnx.log.onlyaggregate">yes</xsl:param>

<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>

<xsl:template match="mml:math">
	<!-- Check if we can simplify it (convert the math to cnxml) -->
	<xsl:variable name="isComplex">
		<xsl:apply-templates mode="cnx.iscomplex" select="."/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="normalize-space($isComplex)!=''">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: MathML too complex because of <xsl:value-of select="$isComplex"/></xsl:with-param></xsl:call-template>
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: MathML is simple!</xsl:with-param></xsl:call-template>
			<xsl:apply-templates mode="cnx.simplify" select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="ident" match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates mode="ident" select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<!-- Terminal nodes that we don't need to recurse down and are NOT complex -->
<xsl:template mode="cnx.iscomplex" match="text()|mml:annotation-xml"/>

<!-- Terminal nodes that are NOT complex but we should recurse just to be safe -->
<xsl:template mode="cnx.iscomplex" match="mml:mn|mml:mi|mml:mo|mml:mtext|mml:mspace[@width='.3em' and count(@*)=1]">
	<xsl:apply-templates mode="cnx.iscomplex"/>
</xsl:template>

<!-- Non-terminal nodes that MAY be complex, but that we support -->
<xsl:template mode="cnx.iscomplex" match="mml:mrow|mml:semantics
                                  |mml:msub|mml:msup|mml:msubsup[*[position()>1 and contains('mi mo mn', local-name())]]
                                  |mml:math|mml:mfenced
                                  |mml:mstyle[@fontsize and count(@*)=1]
                                  |mml:mstyle[@fontstyle='italic' and count(@*)=1]"> 
	<xsl:apply-templates mode="cnx.iscomplex"/>
</xsl:template>

<!-- Non-terminal nodes that MUST be complex -->
<!-- This one would need stretchy parentheses and so, should NOT be converted -->
<xsl:template mode="cnx.iscomplex" match="mml:*[
				mml:mo[
					contains('[]{}()',normalize-space(text()))
					and not(@stretchy='false')
				] and (descendant::mml:msub
					 or descendant::mml:msup
					 or descendant::mml:msubsup)
			]">
	<xsl:text>|(stretchy-paren)</xsl:text>
</xsl:template>

<!-- Non-terminal nodes that MUST be complex (everything else) -->
<xsl:template mode="cnx.iscomplex" match="*">
	<xsl:text>|</xsl:text>
	<xsl:value-of select="local-name()"/>
</xsl:template>




<!-- Below are the conversions -->


<xsl:template mode="cnx.simplify" match="mml:math">
	<c:span class="simplemath">
		<xsl:apply-templates mode="cnx.simplify" select="node()"/>
		<xsl:copy>
		  <xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</c:span>
</xsl:template>


<!-- Only infinity is not italicized -->
<xsl:template mode="cnx.simplify" match="mml:mi">
    <!-- Default mathvariant is normal except for mi 
	 with one letter which is italic (except infinite character) -->
	<xsl:variable name="str" select="normalize-space(text())"/>
	<xsl:variable name="strLen" select="string-length($str)"/>
    <xsl:variable name="defaultmathvariant">
		<xsl:choose>
			<xsl:when test="$strLen=1 and $str != '&#8734;'">
				<xsl:text>italic</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>normal</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- mathvariant options: normal | bold | italic | bold-italic | double-struck | bold-fraktur | script | bold-script | fraktur | sans-serif | bold-sans-serif | sans-serif-italic | sans-serif-bold-italic | monospace  -->
	<xsl:variable name="mathVariant">
		<xsl:if test="not(@mathvariant)">
			<xsl:value-of select="$defaultmathvariant"/>
		</xsl:if>
		<xsl:value-of select="@mathvariant"/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$mathVariant='normal' or $mathVariant='bold'">
			<c:emphasis effect="{$mathVariant}">
				<xsl:apply-templates mode="cnx.simplify" select="node()"/>
			</c:emphasis>
		</xsl:when>
		<xsl:when test="$mathVariant='italic'">
			<c:emphasis class="mathml-mi" effect="italics">
				<xsl:apply-templates mode="cnx.simplify" select="node()"/>
			</c:emphasis>
		</xsl:when>
		<xsl:when test="$mathVariant='bold-italic'">
			<c:emphasis effect="bold">
				<c:emphasis class="mathml-mi" effect="italics">
					<xsl:apply-templates mode="cnx.simplify" select="node()"/>
				</c:emphasis>
			</c:emphasis>
		</xsl:when>
		<xsl:when test="$mathVariant='double-struck'">
			<c:emphasis effect="normal">
				<xsl:apply-templates mode="cnx.simplify" select="node()"/>
			</c:emphasis>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Ignoring @mathvariant</xsl:with-param></xsl:call-template>
			<c:emphasis effect="normal">
				<xsl:apply-templates mode="cnx.simplify" select="node()"/>
			</c:emphasis>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:mn|mml:mtext">
	<xsl:apply-templates mode="cnx.simplify" select="node()"/>
</xsl:template>

<!-- Just discard the little space -->
<xsl:template mode="cnx.simplify" match="mml:mspace[@width='.3em' and count(@*)=1]"/>

<xsl:template mode="cnx.simplify" match="mml:mstyle[@fontstyle='italic' and count(@*)=1]">
  <c:emphasis effect="italics">
    <xsl:apply-templates mode="cnx.simplify" select="node()"/>
  </c:emphasis>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:mo">
	<xsl:variable name="operator" select="normalize-space(text())"/>

	<!-- Retrieve all operator entries from operator dictionary -->
	<xsl:variable name="opEntries" select="document('../xslt2/math2svg-customized/operator-dictionary.xml')/math:operators/math:mo[@op = $operator]"/>

	<xsl:if test="count($opEntries)>0">
	   <xsl:choose>
	       <xsl:when test="not($opEntries[1]/@lspace)"/>
	       <xsl:when test="$opEntries[1]/@lspace = '0em'"/>
           <xsl:when test="$opEntries[1]/@lspace = 'veryverythinmathspace'"/>
           <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:comment>$opEntries[1]/@lspace = '<xsl:value-of select="$opEntries[1]/@lspace"/>'</xsl:comment>
           </xsl:otherwise>
	   </xsl:choose>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="$operator='-'">
			<xsl:text>&#8211;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$operator"/>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:if test="count($opEntries)>0">
       <xsl:choose>
           <xsl:when test="not($opEntries[1]/@lspace)"/>
           <xsl:when test="$opEntries[1]/@lspace = '0em'"/>
           <xsl:when test="$opEntries[1]/@lspace = 'veryverythinmathspace'"/>
           <xsl:otherwise>
               <xsl:text> </xsl:text>
               <xsl:comment>$opEntries[1]/@rspace = '<xsl:value-of select="$opEntries[1]/@rspace"/>'</xsl:comment>
           </xsl:otherwise>
       </xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:msup">
	<xsl:apply-templates mode="cnx.simplify" select="*[1]"/>
	<c:sup>
		<xsl:apply-templates mode="cnx.simplify" select="*[2]"/>
	</c:sup>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:msub">
	<xsl:apply-templates mode="cnx.simplify" select="*[1]"/>
	<c:sub>
		<xsl:apply-templates mode="cnx.simplify" select="*[2]"/>
	</c:sub>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:msubsup">
	<xsl:apply-templates mode="cnx.simplify" select="*[1]"/>
	<xsl:choose>
		<xsl:when test="*[position()=2 and contains('mi mo mn', local-name())]">
			<c:sub>
				<xsl:apply-templates mode="cnx.simplify" select="*[2]"/>
			</c:sub>
			<c:sup>
				<xsl:apply-templates mode="cnx.simplify" select="*[3]"/>
			</c:sup>
		</xsl:when>
		<xsl:otherwise>
			<c:sup>
				<xsl:apply-templates mode="cnx.simplify" select="*[3]"/>
			</c:sup>
			<c:sub>
				<xsl:apply-templates mode="cnx.simplify" select="*[2]"/>
			</c:sub>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="cnx.simplify" match="mml:mfenced">
    <!-- Retrieve open glyph, default is ( -->
    <xsl:variable name="openGlyph">
      <xsl:choose>
		<xsl:when test="@open"><xsl:value-of select="normalize-space(@open)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="'('"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve close glyph, default is ) -->
    <xsl:variable name="closeGlyph">
      <xsl:choose>
      	<xsl:when test="@close"><xsl:value-of select="normalize-space(@close)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="')'"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve separators list, default is , -->
    <xsl:variable name="separators">
      <xsl:choose>
		<xsl:when test="@separators"><xsl:value-of select="@separators"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="','"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="children" select="child::*"/>

    <xsl:value-of select="$openGlyph"/>
	<xsl:choose>
	  <xsl:when test="count($children) > 1">
	    <xsl:call-template name="mfencedCompose">
	      <xsl:with-param name="elements" select="$children"/>
	      <xsl:with-param name="separators" select="$separators"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates mode="cnx.simplify" select="child::*"/>
	  </xsl:otherwise>
	</xsl:choose>
    <xsl:value-of select="$closeGlyph"/>

  </xsl:template>

  <xsl:template name="mfencedCompose">
    <xsl:param name="elements"/>
    <xsl:param name="separators"/>
    <xsl:param name="index" select="1"/>

    <xsl:apply-templates mode="cnx.simplify" select="$elements[$index]"/>

    <xsl:if test="count($elements) &gt; $index">
	<xsl:value-of select="substring($separators, 1, 1)"/>
	<xsl:text> </xsl:text>

      <xsl:call-template name="mfencedCompose">
	<xsl:with-param name="elements" select="$elements"/>
	<xsl:with-param name="index" select="$index+1"/>
	<xsl:with-param name="separators">
	   <xsl:choose>
	       <xsl:when test="string-length($separators) = 1">
	           <xsl:value-of select="$separators"/>
	       </xsl:when>
	       <xsl:otherwise>
	           <xsl:value-of select="substring($separators, 2)"/>
	       </xsl:otherwise>
	   </xsl:choose>
    </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


<!-- Word-importing things like f_out create mml:mi for each char in "out" -->
<xsl:template mode="cnx.simplify" match="mml:mrow[count(*)=count(mml:mi) and count(*)>1]">
	<c:emphasis class="mathml-mi">
		<xsl:apply-templates mode="cnx.simplify" select="*/node()"/>
	</c:emphasis>
</xsl:template>


<!-- Just pass through -->
<xsl:template mode="cnx.simplify" match="mml:mrow|mml:semantics|mml:mstyle[@fontsize and count(@*)=1]">
	<xsl:apply-templates mode="cnx.simplify"/>
</xsl:template>

</xsl:stylesheet>
