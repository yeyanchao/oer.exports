<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2000 Xerox Corporation.  All Rights Reserved.  

  Unlimited use, reproduction, and distribution of this software is
  permitted.  Any copy of this software must include both the above
  copyright notice of Xerox Corporation and this paragraph.  Any
  distribution of this software must comply with all applicable United
  States export control laws.  This software is made available AS IS,
  and XEROX CORPORATION DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED,
  INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS FOR A PARTICULAR PURPOSE, AND NOTWITHSTANDING ANY OTHER
  PROVISION CONTAINED HEREIN, ANY LIABILITY FOR DAMAGES RESULTING FROM
  THE SOFTWARE OR ITS USE IS EXPRESSLY DISCLAIMED, WHETHER ARISING IN
  CONTRACT, TORT (INCLUDING NEGLIGENCE) OR STRICT LIABILITY, EVEN IF
  XEROX CORPORATION IS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

  emmanuel.pietriga@xrce.xerox.com

  This work is done for the OPERA project (INRIA) during a thesis work under a 
  CIFRE contract.

  April 2000
-->
<!--
Author: E. Pietriga {emmanuel.pietriga@xrce.xerox.com}
Created: 02/10/2000
Last updated: 12/04/2000
-->
<!-- general rules: 
*based on the 13 November 2000 WD   http://www.w3.org/TR/2000/CR-MathML2-20001113
*comments about char refs which do not work are related to Amaya 3.0, since this stylesheet was tested using Amaya as the presentation renderer; perhaps some of the char refs said not to be working in Amaya will work with another renderer.
*the subtrees returned by a template decide for themselves if they have to be surrounded by an mrow element (sometimes it is an mfenced element)
*they never add brackets to themselves (or this will be an exception); it is the parent (template from which this one has been called) which decides this since the need for brackets depends on the context
-->
<!-- TO DO LIST
*handling of compose and inverse is probably not good enough
*as for divide, we could use the dotted notation for differentiation provided apply has the appropriate 'other' attribute (which is not defined yet ans will perhaps never be: it does not seem to be something that will be specified, rather application dependant)
*have to find a way to detect when a vector should be represented verticaly (we do that only in one case: when preceding sibling is a matrix and operation is a multiplication; there are other cases where a vertical vector is the correct representation, but they are not yet supported)
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:m="http://www.w3.org/1998/Math/MathML" 
  xmlns="http://www.w3.org/1998/Math/MathML"
  > <!--exclude-result-prefixes="m #default"-->

  <xsl:param name="imaginaryi" select="'&#x2148;'" />


<!-- #################### 4.4.1 #################### -->

<!-- number-->
<!-- support for bases and types-->
<xsl:template match="m:cn">
  <xsl:choose>
  <xsl:when test="@base and (@base != '10')">  <!-- base specified and different from 10 ; if base = 10 we do not display it -->
    <m:msub>
      <m:mrow> <!-- mrow to be sure that the base is actually the element put as sub in case the number is a composed one-->
      <xsl:choose>  
      <xsl:when test="./@type='complex-cartesian' or ./@type='complex'">
        <m:mn><xsl:value-of select="text()[position()=1]"/></m:mn>

  <xsl:choose>
  <xsl:when test="contains(text()[position()=2],'-')">
    <m:mo>-</m:mo><m:mn><xsl:value-of select="substring-after(text()[position()=2],'-')"/></m:mn> 
    <!--substring-after does not seem to work well in XT : if imaginary part is expressed with at least one space char before the minus sign, then it does not work (we end up with two minus sign since the one in the text is kept)-->
  </xsl:when>
  <xsl:otherwise>
    <m:mo>+</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn>
  </xsl:otherwise>

  </xsl:choose>
  <m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo><m:mi><xsl:value-of select="$imaginaryi"/></m:mi>
      </xsl:when>
      <xsl:when test="./@type='complex-polar'">
        <m:mrow><m:mn><xsl:value-of select="text()[position()=1]"/></m:mn><m:mo>&#x2220;</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn></m:mrow>
      </xsl:when>
      <xsl:when test="./@type='rational'">
        <m:mn><xsl:value-of select="text()[position()=1]"/></m:mn><m:mo>/</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn>

      </xsl:when>
      <xsl:otherwise>
        <m:mn><xsl:value-of select="."/></m:mn>
      </xsl:otherwise>
      </xsl:choose>
      </m:mrow>
      <m:mn><xsl:value-of select="@base"/></m:mn>
    </m:msub>
  </xsl:when>

  <xsl:otherwise>  <!-- no base specified -->
    <xsl:choose>  
    <xsl:when test="./@type='complex-cartesian' or ./@type='complex'">
      <m:mrow>
        <m:mn><xsl:value-of select="text()[position()=1]"/></m:mn>
        <xsl:choose>
        <xsl:when test="contains(text()[position()=2],'-')">
      <m:mo>-</m:mo><m:mn><xsl:value-of select="substring(text()[position()=2],2)"/></m:mn><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo><m:mi><xsl:value-of select="$imaginaryi"/></m:mi><!-- perhaps ii-->

        </xsl:when>
        <xsl:otherwise>
    <m:mo>+</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo><m:mi><xsl:value-of select="$imaginaryi"/></m:mi><!-- perhaps ii-->
        </xsl:otherwise>
        </xsl:choose>
      </m:mrow>
    </xsl:when>
    <xsl:when test="./@type='complex-polar'">

      <m:mrow><m:mn><xsl:value-of select="text()[position()=1]"/></m:mn><m:mo>&#x2220;</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn></m:mrow>
    </xsl:when> 
    <xsl:when test="./@type='e-notation'">
      <m:mrow>
        <m:mn><xsl:value-of select="text()[position()=1]"/></m:mn>
  <m:mo>&#x00D7;</m:mo>
  <m:msup><m:mn>10</m:mn><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn></m:msup>
      </m:mrow>
    </xsl:when>

    <xsl:when test="./@type='rational'">
      <m:mrow><m:mn><xsl:value-of select="text()[position()=1]"/></m:mn><m:mo>/</m:mo><m:mn><xsl:value-of select="text()[position()=2]"/></m:mn></m:mrow>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
      <xsl:when test="count(node()) != count(text())">
      <!--test if children are not all text nodes, meaning there is -->
<!--markup assumed to be presentation markup-->
      <m:mrow><xsl:copy-of select="child::*"/></m:mrow>

      </xsl:when>
      <xsl:otherwise>  <!-- common case -->
      <m:mn><xsl:value-of select="."/></m:mn>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<!-- identifier -->
<!--support for presentation markup-->
<xsl:template match="m:ci">
  <xsl:choose>  
  <xsl:when test="./@type='complex-cartesian' or ./@type='complex'">
    <xsl:choose>
    <xsl:when test="count(*)>0">  <!--if identifier is composed of real+imag parts-->
      <m:mrow>

  <m:mi><xsl:value-of select="text()[position()=1]"/></m:mi>
        <xsl:choose> <!-- im part is negative-->
        <xsl:when test="contains(text()[preceding-sibling::*[position()=1 and self::m:sep]],'-')">
          <m:mo>-</m:mo><m:mi>
    <xsl:value-of select="substring-after(text()[preceding-sibling::*[position()=1 and self::m:sep]],'-')"/>
          </m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo><m:mi><xsl:value-of select="$imaginaryi"/></m:mi><!-- perhaps ii-->
        </xsl:when>
        <xsl:otherwise> <!-- im part is not negative-->

          <m:mo>+</m:mo><m:mi>
          <xsl:value-of select="text()[preceding-sibling::*[position()=1 and self::m:sep]]"/>
          </m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo><m:mi><xsl:value-of select="$imaginaryi"/></m:mi><!-- perhaps ii-->
        </xsl:otherwise>
        </xsl:choose>
      </m:mrow>
    </xsl:when>
    <xsl:otherwise>  <!-- if identifier is composed only of one text child-->

      <m:mi><xsl:value-of select="."/></m:mi>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="./@type='complex-polar'">
    <xsl:choose>
    <xsl:when test="count(*)>0">   <!--if identifier is composed of real+imag parts-->
      <m:mrow>

        <m:mi>Polar</m:mi>
        <m:mfenced><m:mi>
        <xsl:value-of select="text()[following-sibling::*[self::m:sep]]"/>
        </m:mi>
        <m:mi>
        <xsl:value-of select="text()[preceding-sibling::*[self::m:sep]]"/>
        </m:mi></m:mfenced>
      </m:mrow>

    </xsl:when>
    <xsl:otherwise>   <!-- if identifier is composed only of one text child-->
      <m:mi><xsl:value-of select="."/></m:mi>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when> 
  <xsl:when test="./@type='rational'">
    <xsl:choose>
    <xsl:when test="count(*)>0"> <!--if identifier is composed of two parts-->

      <m:mrow><m:mi>
      <xsl:value-of select="text()[following-sibling::*[self::m:sep]]"/>
      </m:mi>
      <m:mo>/</m:mo>
      <m:mi>
      <xsl:value-of select="text()[preceding-sibling::*[self::m:sep]]"/>
      </m:mi></m:mrow>
    </xsl:when>

    <xsl:otherwise>   <!-- if identifier is composed only of one text child-->
      <m:mi><xsl:value-of select="."/></m:mi>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="./@type='vector'">
  <xsl:choose>
    <xsl:when test="count(node()) != count(text())">

      <!--test if children are not all text nodes, meaning there
      is markup assumed to be presentation markup-->
      <xsl:choose>
        <xsl:when test="child::m:msub[position()=1]"><!-- test to see if the first child
      is msub so that the subscript will not be bolded -->
    <m:msub>
          <m:mrow><m:mstyle
          fontweight="bold"><m:mrow><xsl:apply-templates
          select="./m:msub/child::*[position()=1]"/></m:mrow></m:mstyle></m:mrow>
          <m:mrow><xsl:apply-templates
          select="./m:msub/child::*[position()=2]"/></m:mrow>
          </m:msub>
        </xsl:when>
        <xsl:when test="m:msup[position()=1]"><!-- test to see if the first child
    is msup so that the superscript will not be bolded -->

    <m:msup>
      <m:mrow><m:mstyle
          fontweight="bold"><m:mrow><xsl:apply-templates
        select="./m:msup/child::*[position()=1]"/></m:mrow></m:mstyle></m:mrow>
      <m:mrow><xsl:apply-templates
          select="./m:msup/child::*[position()=2]"/></m:mrow>
          </m:msup>
        </xsl:when>
        <xsl:when test="m:msubsup[position()=1]"><!-- test to see if the first child
    is msubsup so that the subscript/superscript will not be bolded -->
    <m:msubsup>
      <m:mrow><m:mstyle
          fontweight="bold"><m:mrow><xsl:apply-templates
        select="./m:msubsup/child::*[position()=1]"/></m:mrow></m:mstyle></m:mrow>
      <m:mrow><xsl:apply-templates
          select="./m:msubsup/child::*[position()=2]"/></m:mrow>

      <m:mrow><xsl:apply-templates
          select="./m:msubsup/child::*[position()=3]"/></m:mrow>
          </m:msubsup>
        </xsl:when>
              <xsl:otherwise>
    <m:mrow><xsl:copy-of select="child::*"/></m:mrow>
              </xsl:otherwise>
            </xsl:choose>
    </xsl:when>
    <xsl:otherwise>  <!-- common case -->

      <m:mi fontweight="bold"><xsl:value-of select="text()"/></m:mi>
    </xsl:otherwise>
  </xsl:choose>   
  </xsl:when>
     

  <!-- type 'set' seems to be deprecated (use 4.4.12 instead); besides, there is no easy way to translate set identifiers to chars in ISOMOPF -->
  <xsl:otherwise>  <!-- no type attribute provided -->
    <xsl:choose>
    <xsl:when test="count(node()) != count(text())">
      <!--test if children are not all text nodes, meaning there is markup assumed to be presentation markup-->

  <m:mrow><xsl:copy-of select="child::*"/></m:mrow>
    </xsl:when>
    <xsl:otherwise>  <!-- common case -->
      <m:mi><xsl:value-of select="."/></m:mi>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- externally defined symbols-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='csymbol']]">
  <m:mrow>
  <xsl:apply-templates select="m:csymbol[position()=1]"/>
  <m:mfenced>
  <xsl:for-each select="child::*[position()!=1]">
    <xsl:apply-templates select="."/>
  </xsl:for-each>  
  </m:mfenced>

  </m:mrow>
</xsl:template>

<xsl:template match="m:csymbol">
  <xsl:choose>
  <!--test if children are not all text nodes, meaning there is markup assumed to be presentation markup-->
  <!--perhaps it would be sufficient to test if there is more than one node or text node-->
  <xsl:when test="count(node()) != count(text())"> 
    <m:mrow><xsl:copy-of select="child::*"/></m:mrow>
  </xsl:when>
  <xsl:otherwise>

    <m:mo><xsl:value-of select="."/></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="m:mtext">
  <xsl:copy-of select="."/>
</xsl:template>

<!-- #################### 4.4.2 #################### -->

 

  <!-- apply/apply -->

  <xsl:template match="m:apply[child::*[position()=1 and local-name()='apply']]">  <!-- when the function itself is defined by other functions: (F+G)(x) -->
    <xsl:choose>
      <xsl:when test="count(child::*)>=2">
  <m:mrow>
    <m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=1]"/></m:mfenced>
    <m:mfenced><xsl:apply-templates select="child::*[position()!=1]"/></m:mfenced>
  </m:mrow>
      </xsl:when>

      <xsl:otherwise> <!-- apply only contains apply, no operand-->
  <m:mfenced separators=" "><xsl:apply-templates select="child::*"/></m:mfenced>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- apply/apply/csymbol/estimate -->
  <xsl:template match="m:apply[child::m:apply[child::m:csymbol[@definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#estimate']]]">
    <xsl:apply-templates select="child::*[position()=1]"/>

    <m:mfenced><xsl:apply-templates select="child::*[position()!=1]"/></m:mfenced>
  </xsl:template> 

<!-- force function or operator MathML 1.0 deprecated-->
<xsl:template match="m:apply[child::m:fn[position()=1]]">
<m:mrow>
  <xsl:choose>
    <xsl:when test="m:fn/m:apply[position()=1]"> <!-- fn definition is complex, surround with brackets, but only one child-->
      <m:mfenced separators=" "><m:mrow><xsl:apply-templates select="m:fn/*"/></m:mrow></m:mfenced>
    </xsl:when>
    <xsl:otherwise>

      <m:mi><xsl:apply-templates select="m:fn/*"/></m:mi>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="count(*)>1"> <!-- if no operands, don't put empty parentheses-->
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <m:mfenced>
      <xsl:apply-templates select="*[position()!=1]"/>
    </m:mfenced>

  </xsl:if>
</m:mrow>
</xsl:template>

  <!--first ci is supposed to be a function-->
  <xsl:template match="m:apply[child::*[position()=1 and
    local-name()='ci']]">
    <!-- special case if the function is to some power -->
    <xsl:choose>
      <xsl:when test='child::m:ci[child::m:mo and position()=1]'>
  <xsl:choose>

    <xsl:when test="count(*)>=3"><!-- use infix notation if more than one child -->
      <m:mrow> 
        <m:mfenced open='(' close=')' separators=" ">
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:apply-templates select="."/><xsl:copy-of select="../m:ci[position()=1]/m:mo"/>
    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>
        </m:mfenced>
      </m:mrow>

    </xsl:when>
    <xsl:otherwise><!-- use prefix notation -->
      <xsl:choose>
        <xsl:when test="contains(m:ci/m:mo/text(),
    '&#x2112;')">
    <m:mrow><xsl:copy-of select="m:ci[position()=1]/m:mo"/><m:mfenced open="{{" close="}}"><xsl:apply-templates select="child::*[position()!=1]"/></m:mfenced></m:mrow>
        </xsl:when>
        <xsl:when test="contains(m:ci/m:mo/text(),
    '&#x2131;')">
    <m:mrow><xsl:copy-of select="m:ci[position()=1]/m:mo"/><m:mfenced open='{{' close='}}'><xsl:apply-templates select="child::*[position()!=1]"/></m:mfenced></m:mrow>
        </xsl:when>

        <!-- Test to see if child has an apply -->
        <xsl:when test="child::*[local-name()='apply' and
    count(child::*)=3]">
    <m:mrow>
      <xsl:copy-of select="m:ci/m:mo[position()=1]"/>
      <m:mfenced>
        <xsl:apply-templates select="child::*[position()=2]"/>
      </m:mfenced>
    </m:mrow>    
        </xsl:when>

        <!--this was the original before tests  <xsl:when
        test="count(child::*)=2"> -->
        <xsl:otherwise>
    <m:mrow><xsl:copy-of select="m:ci[position()=1]/m:mo"/><xsl:apply-templates select="child::*[position()=2]"/></m:mrow>
        </xsl:otherwise>        
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
      </xsl:when>
      <xsl:otherwise>

  <m:mrow>
    <xsl:apply-templates select="m:ci[position()=1]"/>
    <xsl:if test="count(*)>1">  <!-- if no operands, don't put empty parentheses-->
      <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
      <xsl:choose>
        <xsl:when test="m:ci[@class='discrete']">
    <m:mfenced open='[' close=']'>

      <xsl:apply-templates select="*[position()!=1]"/>

    </m:mfenced>
        </xsl:when>
        <xsl:otherwise>
    <m:mfenced>
      <xsl:apply-templates select="*[position()!=1]"/>
    </m:mfenced>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

  </m:mrow>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="m:apply[child::*[position()=1 and local-name()='mo']]">
    <!--operator assumed to be infix-->
    <xsl:choose>
      <xsl:when test="count(child::*)>=3">

  <m:mrow>
    <m:mfenced open='(' close=')' separators=" ">
      <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
        <xsl:apply-templates select="."/><xsl:copy-of select="preceding-sibling::m:mo"/>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()!=1 and position()=last()]"/>
    </m:mfenced>
  </m:mrow>
      </xsl:when>

  <!-- Unary operation --><!-- tests added to check for Laplace
  and Fourier Transform Symbols-->
      <xsl:otherwise>
  <xsl:choose>
    <xsl:when test="contains(m:mo/text(),
        '&#x2112;')">
      <m:mrow><xsl:copy-of select="child::m:mo[position()=1]"/><m:mfenced open="{{" close="}}"><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced></m:mrow>
    </xsl:when>
    <xsl:when test="contains(m:mo/text(),
        '&#x2131;')">
      <m:mrow><xsl:copy-of select="child::m:mo[position()=1]"/><m:mfenced open='{{' close='}}'><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced></m:mrow>
    </xsl:when>

          <!-- Test to see if child has an apply -->
    <xsl:when test="child::*[local-name()='apply' and
      count(child::*)=3]">
      <m:mrow>
        <xsl:copy-of select="child::m:mo[position()=1]"/>
        <m:mfenced>
    <xsl:apply-templates select="child::*[position()=2]"/>
        </m:mfenced>
      </m:mrow>    
    </xsl:when>

  <!--this was the original before tests  <xsl:when
    test="count(child::*)=2"> -->
    <xsl:otherwise>
      <m:mrow><xsl:copy-of select="child::m:mo[position()=1]"/><xsl:apply-templates select="child::*[position()=2]"/></m:mrow>
    </xsl:otherwise>
  </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- intervals -->
<xsl:template match="m:interval">
  <xsl:choose>
    <xsl:when test="count(*)=2"> <!--we have an interval defined by two real numbers-->
      <xsl:choose>
        <xsl:when test="@closure and @closure='open-closed'">
    <m:mfenced open="(" close="]">
      <xsl:apply-templates select="child::*[position()=1]"/>
      <xsl:apply-templates select="child::*[position()=2]"/>

    </m:mfenced>
  </xsl:when>
        <xsl:when test="@closure and @closure='closed-open'">
    <m:mfenced open="[" close=")">
      <xsl:apply-templates select="child::*[position()=1]"/>
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
        <xsl:when test="@closure and @closure='closed'">

    <m:mfenced open="[" close="]">
      <xsl:apply-templates select="child::*[position()=1]"/>
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
        <xsl:when test="@closure and @closure='open'">
    <m:mfenced open="(" close=")">
      <xsl:apply-templates select="child::*[position()=1]"/>
      <xsl:apply-templates select="child::*[position()=2]"/>

    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>  <!--default is close-->
    <m:mfenced open="[" close="]">
      <xsl:apply-templates select="child::*[position()=1]"/>
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:otherwise>

      </xsl:choose>
    </xsl:when>
    <xsl:otherwise> <!--we have an interval defined by a condition-->
      <m:mrow><xsl:apply-templates select="m:condition"/></m:mrow>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- inverse -->
<xsl:template match="m:apply[child::*[position()=1 and
        local-name()='apply']/m:inverse]">

  <m:mrow>
      <m:msup><!-- elementary classical functions have two templates: apply[func] for standard case, func[position()!=1] for inverse and compose case-->
      <m:mrow><xsl:apply-templates select="m:apply[position()=1]/*[position()=2]"/></m:mrow><!-- function to be inversed-->
      <m:mn>-1</m:mn>
    </m:msup>
    <xsl:if test="count(*)>=2"> <!-- deal with operands, if any-->
      <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
      <m:mfenced>

        <xsl:apply-templates select="*[position()!=1]"/>
      </m:mfenced>
    </xsl:if>
  </m:mrow>
</xsl:template> 

<!-- checks to see if there is an apply after the inverse and adds parentheses if so -->
<xsl:template match="m:apply[child::*[position()=1 and
        local-name()='inverse']]">
    <xsl:choose>
      <xsl:when test="local-name(*[position()=2])='apply'">
  <m:msup>

    <m:mfenced separators=" ">
      <m:mrow>
        <xsl:apply-templates select="*[position()=2]"/>
      </m:mrow>
    </m:mfenced>
    <m:mn>-1</m:mn>
  </m:msup>
      </xsl:when>

      <xsl:otherwise>
  <m:msup> <!-- elementary classical functions have two templates: apply[func] for standard case, func[position()!=1] for inverse and compose case-->
    <m:mrow><xsl:apply-templates select="*[position()=2]"/></m:mrow><!-- function to be inversed-->
    <m:mn>-1</m:mn>
  </m:msup>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- conditions -->
<!-- no support for deprecated reln-->
<xsl:template match="m:condition">
  <m:mrow><xsl:apply-templates select="*"/></m:mrow>
</xsl:template>

<!-- domain of application -->
<xsl:template match="m:domainofapplication">
  <m:mrow><xsl:apply-templates select="*"/></m:mrow>
</xsl:template>

<!-- declare -->
<xsl:template match="m:declare">
<!-- no rendering for declarations-->

</xsl:template>

<!-- lambda -->
<xsl:template match="m:lambda">
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes">&#x03BB;</xsl:text></m:mo>
    <m:mrow><m:mo>(</m:mo>
      <xsl:for-each select="m:bvar">
        <xsl:apply-templates select="."/><m:mo>,</m:mo>
      </xsl:for-each>

      <xsl:apply-templates select="*[position()=last()]"/>
    <m:mo>)</m:mo></m:mrow>
  </m:mrow>
</xsl:template>

<!-- composition -->
<xsl:template match="m:apply[child::m:apply[position()=1]/m:compose]">
  <m:mrow> <!-- elementary classical functions have two templates: apply[func] for standard case, func[position()!=1] for inverse and compose case-->
    <xsl:for-each select="m:apply[position()=1]/*[position()!=1 and position()!=last()]">
      <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2218;</xsl:text></m:mo> <!-- compose functions --><!-- does not work, perhaps compfn, UNICODE 02218-->

    </xsl:for-each>
    <xsl:apply-templates select="m:apply[position()=1]/*[position()=last()]"/>
    <xsl:if test="count(*)>=2"> <!-- deal with operands, if any-->
      <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
      <m:mrow><m:mo>(</m:mo>
      <xsl:for-each select="*[position()!=1 and position()!=last()]">
        <xsl:apply-templates select="."/><m:mo>,</m:mo>

      </xsl:for-each>
      <xsl:apply-templates select="*[position()=last()]"/>
      <m:mo>)</m:mo></m:mrow>
    </xsl:if>
  </m:mrow>
</xsl:template>

<xsl:template match="m:apply[child::m:compose[position()=1]]">
   <!-- elementary classical functions have two templates: apply[func] for standard case, func[position()!=1] for inverse and compose case-->
  <xsl:for-each select="*[position()!=1 and position()!=last()]">

    <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2218;</xsl:text></m:mo> <!-- compose functions --><!-- does not work, perhaps compfn, UNICODE 02218-->
  </xsl:for-each>
  <xsl:apply-templates select="*[position()=last()]"/>
</xsl:template>

<!-- identity -->
<xsl:template match="m:ident">
  <m:mi>id</m:mi>
</xsl:template>

<!-- domain -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='domain']]">
  <m:mrow>
    <m:mi>domain</m:mi><m:mfenced open="(" close=")"><xsl:apply-templates select="*[position()!=1]"/></m:mfenced>
  </m:mrow>
</xsl:template>

<!-- codomain -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='codomain']]">
  <m:mrow>
    <m:mi>codomain</m:mi><m:mfenced open="(" close=")"><xsl:apply-templates select="*[position()!=1]"/></m:mfenced>

  </m:mrow>
</xsl:template>

<!-- image -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='image']]">
  <m:mrow>
    <m:mi>image</m:mi><m:mfenced open="(" close=")"><xsl:apply-templates select="*[position()!=1]"/></m:mfenced>
  </m:mrow>
</xsl:template>

<!-- piecewise -->
<xsl:template match="m:piecewise">

  <m:mrow>
      <xsl:element name="m:mfenced" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:attribute name="open">{</xsl:attribute>
      <xsl:attribute name="close"></xsl:attribute>
      <m:mtable>
  <xsl:for-each select="m:piece">
  <m:mtr><m:mtd>
    <xsl:apply-templates select="*[position()=1]"/><m:mspace
    width="0.3em"/><m:mtext>if</m:mtext><m:mspace width="0.3em"/><xsl:apply-templates select="*[position()=2]"/>

  </m:mtd></m:mtr>
  </xsl:for-each>
        <xsl:if test="m:otherwise">
    <m:mtr><m:mtd><xsl:apply-templates
    select="m:otherwise/*"/><m:mspace width="0.3em"/><m:mtext>otherwise</m:mtext></m:mtd></m:mtr>
        </xsl:if>
  </m:mtable>
      </xsl:element>
  </m:mrow>

</xsl:template>

<!-- #################### 4.4.3 #################### -->

<!-- quotient -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='quotient']]">
  <m:mrow>  <!-- the third notation uses UNICODE chars x0230A and x0230B -->
    <m:mo>integer part of</m:mo>
    <m:mrow>
      <xsl:choose> <!-- surround with brackets if operands are composed-->

      <xsl:when test="child::*[position()=2] and local-name()='apply'">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[position()=2]"/>
      </xsl:otherwise>
      </xsl:choose>
      <m:mo>/</m:mo>

      <xsl:choose>
      <xsl:when test="child::*[position()=3] and local-name()='apply'">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=3]"/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[position()=3]"/>
      </xsl:otherwise>
      </xsl:choose>
    </m:mrow>

  </m:mrow>
</xsl:template>

<!-- factorial -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='factorial']]">
  <m:mrow>
    <xsl:choose> <!-- surround with brackets if operand is composed-->
    <xsl:when test="local-name(*[position()=2])='apply'">
      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
    </xsl:when>

    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
    <m:mo>!</m:mo>
  </m:mrow>
</xsl:template>

<!-- divide -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='divide']]">

  <m:mrow>
    <xsl:choose>
    <xsl:when test="contains(@other,'scriptstyle')">
      <m:mfrac bevelled="true">
  <m:mrow>    
        <xsl:apply-templates select="child::*[position()=2]"/>
  </m:mrow>
  <m:mrow>    
        <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>      
      </m:mfrac>

    </xsl:when>
    <xsl:otherwise>
      <m:mfrac>
  <m:mrow>    
        <xsl:apply-templates select="child::*[position()=2]"/>
        </m:mrow>
  <m:mrow>    
        <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
      </m:mfrac>

    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- min -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='min']]">
  <m:mrow>
    <xsl:choose>
    <xsl:when test="m:domainofapplication"> <!-- if there is a domain of application -->

    <m:mrow>
      <xsl:choose>
            <xsl:when test="m:bvar"><!-- bvar and domain of application -->
             <m:msub>
              <m:munder>
           <m:mo><xsl:text disable-output-escaping="yes">min</xsl:text></m:mo>
           <xsl:apply-templates select="m:domainofapplication"/>
          </m:munder>

              <m:mrow>
              <xsl:for-each select="m:bvar[position()!=last()]">  <!--select every bvar except the last one (position() only counts bvars, not the other siblings)-->
               <xsl:apply-templates select="."/><m:mo>,</m:mo>
              </xsl:for-each>
           <xsl:apply-templates select="m:bvar[position()=last()]"/>
             </m:mrow>
            </m:msub>
           </xsl:when>

      <xsl:otherwise>
            <m:munder>
          <m:mo><xsl:text disable-output-escaping="yes">min</xsl:text></m:mo>
          <xsl:apply-templates select="m:domainofapplication"/>
        </m:munder>
      </xsl:otherwise>
     </xsl:choose>
    </m:mrow>

    <m:mrow><m:mo>{</m:mo>
      <xsl:apply-templates select="*[local-name()!='condition' and local-name()!='domainofapplication' and local-name()!='bvar']"/>
      <xsl:if test="m:condition">
        <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>
      </xsl:if>
      <m:mo>}</m:mo></m:mrow>
    </xsl:when>

    <xsl:when test="m:bvar"> <!-- if there are bvars-->
      <m:msub>
        <m:mi>min</m:mi>
        <m:mrow>
          <xsl:for-each select="m:bvar[position()!=last()]">  <!--select every bvar except the last one (position() only counts bvars, not the other siblings)-->
              <xsl:apply-templates select="."/><m:mo>,</m:mo>
          </xsl:for-each>

    <xsl:apply-templates select="m:bvar[position()=last()]"/>
        </m:mrow>
      </m:msub>
      <m:mrow><m:mo>{</m:mo>
        <xsl:apply-templates select="*[local-name()!='condition' and local-name()!='bvar']"/>
        <xsl:if test="m:condition">
          <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>
        </xsl:if>

      <m:mo>}</m:mo></m:mrow>
    </xsl:when>
    <xsl:otherwise> <!-- if there are no bvars-->
      <m:mo>min</m:mo>
      <m:mrow><m:mo>{</m:mo>
      <m:mfenced open="" close=""><xsl:apply-templates select="*[local-name()!='condition' and local-name()!='min']"/></m:mfenced>
      <xsl:if test="m:condition">

        <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>
      </xsl:if>
      <m:mo>}</m:mo></m:mrow>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- max -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='max']]">
  <m:mrow>
    <xsl:choose>
    <xsl:when test="m:domainofapplication"> <!-- if there is a domain of application -->
    <m:mrow>
      <xsl:choose>
            <xsl:when test="m:bvar"><!-- bvar and domain of application -->
             <m:msub>
              <m:munder>

           <m:mo><xsl:text disable-output-escaping="yes">max</xsl:text></m:mo>
           <xsl:apply-templates select="m:domainofapplication"/>
          </m:munder>
              <m:mrow>
              <xsl:for-each select="m:bvar[position()!=last()]">  <!--select every bvar except the last one (position() only counts bvars, not the other siblings)-->
               <xsl:apply-templates select="."/><m:mo>,</m:mo>
              </xsl:for-each>

           <xsl:apply-templates select="m:bvar[position()=last()]"/>
             </m:mrow>
            </m:msub>
           </xsl:when>
      <xsl:otherwise>
            <m:munder>
          <m:mo><xsl:text disable-output-escaping="yes">max</xsl:text></m:mo>
          <xsl:apply-templates select="m:domainofapplication"/>

        </m:munder>
      </xsl:otherwise>
     </xsl:choose>
    </m:mrow>
    <m:mrow><m:mo>{</m:mo>
      <xsl:apply-templates select="*[local-name()!='condition' and local-name()!='domainofapplication' and local-name()!='bvar']"/>
      <xsl:if test="m:condition">
        <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>

      </xsl:if>
      <m:mo>}</m:mo></m:mrow>
    </xsl:when>
    <xsl:when test="m:bvar"><!-- if there are bvars-->
      <m:msub>
        <m:mi>max</m:mi>
        <m:mrow>
          <xsl:for-each select="m:bvar[position()!=last()]">  <!--select every bvar except the last one (position() only counts bvars, not the other siblings)-->

            <xsl:apply-templates select="."/><m:mo>,</m:mo>
          </xsl:for-each>  
      <xsl:apply-templates select="m:bvar[position()=last()]"/>
        </m:mrow>
      </m:msub>
      <m:mrow><m:mo>{</m:mo>
      <xsl:apply-templates select="*[local-name()!='condition' and local-name()!='bvar']"/>
      <xsl:if test="m:condition">

        <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>
      </xsl:if>
      <m:mo>}</m:mo></m:mrow>
    </xsl:when>
    <xsl:otherwise> <!-- if there are no bvars-->
      <m:mo>max</m:mo>
      <m:mrow><m:mo>{</m:mo>

        <m:mfenced open="" close=""><xsl:apply-templates select="*[local-name()!='condition' and local-name()!='max']"/></m:mfenced>
        <xsl:if test="m:condition">
          <m:mo>|</m:mo><xsl:apply-templates select="m:condition"/>
        </xsl:if>
      <m:mo>}</m:mo></m:mrow>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>

</xsl:template>

<!-- substraction(minus); unary or binary operator-->
  <xsl:template match="m:apply[child::*[position()=1 and local-name()='minus']]">
    <m:mrow>
      <xsl:choose> <!-- binary -->
  <xsl:when test="count(child::*)=3">
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo>-</m:mo>

    <xsl:choose>
      <xsl:when test="((local-name(*[position()=3])='ci' or local-name(*[position()=3])='cn') and contains(*[position()=3]/text(),'-')) or ((local-name(*[position()=3])='apply') and (local-name(*[position()=3]/*[position()=1])='minus' or local-name(*[position()=3]/*[position()=1])='plus'))">
        <m:mfenced separators=" ">
        <xsl:apply-templates select="*[position()=3]"/>
        </m:mfenced>
        
        <!-- surround negative or complex things with brackets -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[position()=3]"/>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise> <!-- unary -->
    <m:mo>-</m:mo>
    <xsl:choose>
      <xsl:when test="((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-')) or (local-name(*[position()=2])='apply')">
        <m:mfenced separators=" ">

<!-- surround negative or complex things with brackets -->
      <xsl:apply-templates select="child::*[position()=last()]"/>
        </m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="child::*[position()=last()]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>

      </xsl:choose>
    </m:mrow>
  </xsl:template>

<!-- addition -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='plus']]">
  <xsl:choose>
  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:choose>

        <xsl:when test="((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
          <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced> <!-- surround negative things with brackets -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[position()=2]"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="child::*[position()!=1 and position()!=2]">

        <xsl:choose>
        <xsl:when test="((local-name(.)='ci' or local-name(.)='cn') and contains(./text(),'-')) or (self::m:apply and child::m:minus and child::*[last()=2]) or (self::m:apply and child::m:times[1] and child::*[position()=2 and (local-name(.)='ci' or local-name(.)='cn') and contains(./text(),'-')])"> <!-- surround negative things with brackets -->
          <m:mo>+</m:mo><m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when>
        <xsl:otherwise>
          <m:mo>+</m:mo><xsl:apply-templates select="."/>
        </xsl:otherwise>

        </xsl:choose>
      </xsl:for-each>
    </m:mrow>
  </xsl:when>
  <xsl:when test="count(child::*)=2">
    <m:mrow>
      <m:mo>+</m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>

  </xsl:when>
  <xsl:otherwise>
    <m:mo>+</m:mo>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- power -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='power']]">
    <m:msup>

      <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply'">
    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]" /> 
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]" /> 
  </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="child::*[position()=3]" /> 
    </m:msup>
  </xsl:template>

<!-- remainder -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='rem']]">
  <m:mrow>
    <xsl:choose> <!-- surround with brackets if operands are composed-->
    <xsl:when test="local-name(*[position()=2])='apply'">
      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>

    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
    <m:mo>mod</m:mo>
    <xsl:choose>
    <xsl:when test="local-name(*[position()=3])='apply'">

      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=3]"/></m:mfenced>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=3]"/>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

  <!-- multiplication -->

  <xsl:template match="m:apply[child::*[position()=1 and local-name()='times']]">
    <xsl:choose>
      <xsl:when test="count(child::*)>=3">
  <m:mrow>  
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:choose>
        <xsl:when test="m:product">
    <m:mfenced seperators=" "><xsl:apply-templates
        select="."/></m:mfenced><m:mo><xsl:text
        disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
        </xsl:when>

        <xsl:when test="m:sum">
    <m:mfenced seperators=" "><xsl:apply-templates
        select="."/></m:mfenced><m:mo><xsl:text
        disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
        </xsl:when>
        <xsl:when test="m:plus"> <!--add brackets around + children for priority purpose-->
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
        </xsl:when>
        <xsl:when test="m:minus"> <!--add brackets around - children for priority purpose-->
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>

        </xsl:when>
        <!-- if someone goes through the trouble of nesting
        times then add brackets -->
        <xsl:when test="m:times"> <!--add brackets around - children for priority purpose-->
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
        </xsl:when>
        <!-- putting a times symbol between two cn's added by allison -->
        <xsl:when test="(local-name()='cn') and
    following-sibling::*[position()=1 and local-name()='cn']">
    <xsl:choose>

      <!--case when the entity pi is a cn-->
      <!--and when the pi tag is used-->
      <xsl:when test="(local-name()='cn') and
        contains(text(),'&#x03C0;')">
        <xsl:apply-templates
          select="."/><m:mo> <!--&InvisibleTimes;--></m:mo>
      </xsl:when>
      <xsl:when
        test="following-sibling::*[contains(text(),'&#x03C0;')
        or local-name()='pi']">
        <xsl:apply-templates
          select="."/><m:mo> <!--&InvisibleTimes;--></m:mo>
      </xsl:when>
      <!-- when complex-cartesians are multiplied, add parentheses -->

      <xsl:when test="@type='complex-cartesian'">
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
      </xsl:when>
      <!--default case with two cn's there is a times sign-->
      <xsl:otherwise>
        <xsl:apply-templates select="."/><m:mo>&#x00D7;</m:mo>
      </xsl:otherwise>
    </xsl:choose>
        </xsl:when>

        <!-- case for powers (scientific notation by using times) -->
        <xsl:when test="(local-name()='cn') and
    following-sibling::*[position()=1 and local-name()='apply' and
    child::*[position()=2 and local-name()='cn'] and
    child::*[position()=1 and local-name()='power']]">
    <xsl:apply-templates select="."/><m:mo>&#x00D7;</m:mo>
        </xsl:when>
        <!-- end of allison's addition -->
        <xsl:otherwise>
    <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
    <xsl:for-each select="child::*[position()=last()]">
      <xsl:choose>
        <xsl:when test="m:plus">
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when>
        <xsl:when test="m:minus">
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when>

        <!-- when complex-cartesians are multiplied, add parentheses -->
        <xsl:when test="(local-name(.)='cn' and @type='complex-cartesian')">
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when>
        <!-- if someone goes through the trouble of nesting
        times, then add parentheses -->
        <xsl:when test="m:times">
    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when> 
        
        <xsl:when test="(local-name(.)='ci' or local-name(.)='cn') and contains(text(),'-')"> <!-- have to do it using contains because starts-with doesn't seem to work well in  XT-->

    <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
        </xsl:when>
        
        <xsl:otherwise>
    <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </m:mrow>
      </xsl:when>

      <xsl:when test="count(child::*)=2">  <!-- unary -->
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
    <xsl:choose>
      <xsl:when test="m:plus">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:minus">

        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      <xsl:when test="(*[position()=2 and self::m:ci] or *[position()=2 and self::m:cn]) and contains(*[position()=2]/text(),'-')">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:apply-templates select="*[position()=2]"/>
      </xsl:otherwise>
    </xsl:choose>

  </m:mrow>
      </xsl:when>
      <xsl:otherwise>  <!-- no operand -->
  <m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- root -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='root']]">
  <xsl:choose>
  <xsl:when test="m:degree">
    <xsl:choose>
    <xsl:when test="m:degree/m:cn/text()='2'"> <!--if degree=2 display
    a standard square root-->
      <m:msqrt>
        <xsl:apply-templates select="child::*[position()=3]"/>
        </m:msqrt>
    </xsl:when>

    <xsl:otherwise>
      <m:mroot>
        <xsl:apply-templates select="child::*[position()=3]"/>
        <m:mrow><xsl:apply-templates select="m:degree/*"/></m:mrow>
      </m:mroot>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise> <!-- no degree specified-->

    <m:msqrt>
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:msqrt>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- greatest common divisor -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='gcd']]">
  <m:mrow>
    <m:mi>gcd</m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>

    <m:mfenced>
      <xsl:apply-templates select="child::*[position()!=1]"/>
    </m:mfenced>
  </m:mrow>
</xsl:template>

<!-- AND -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='and']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3"> <!-- at least two operands (common case)-->

    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:choose>
      <xsl:when test="m:or"> <!--add brackets around OR children for priority purpose-->
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mspace width='.3em'/><m:mo><xsl:text  disable-output-escaping="yes">&#x2227;</xsl:text></m:mo><m:mspace width='.3em'/>
      </xsl:when>
      <xsl:when test="m:xor"> <!--add brackets around XOR children for priority purpose-->
       <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2227;</xsl:text></m:mo><m:mspace width='.3em'/> 
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="."/><m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2227;</xsl:text></m:mo><m:mspace width='.3em'/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="child::*[position()=last()]">
      <xsl:choose>
      <xsl:when test="m:or">
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>

      </xsl:when>
      <xsl:when test="m:xor">
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

  </xsl:when>
  <xsl:when test="count(*)=2">
    <m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2227;</xsl:text></m:mo><m:mspace width='.3em'/><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>
    <m:mspace width='.5em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2227;</xsl:text></m:mo><m:mspace width='.5em'/>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>

</xsl:template>

<!-- OR -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='or']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3">
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:apply-templates select="."/><m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2228;</xsl:text></m:mo><m:mspace width='.3em'/>
    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>

    </xsl:when>
    <xsl:when test="count(*)=2">
      <m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2228;</xsl:text></m:mo><m:mspace width='.3em'/><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>
    <m:mspace width='.3em'/><m:mo><xsl:text disable-output-escaping="yes">&#x2228;</xsl:text></m:mo><m:mspace width='.3em'/>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>

</xsl:template>

<!-- XOR -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='xor']]">
<m:mrow>
  <xsl:choose>
   <xsl:when test="count(*)>=3">
    <xsl:choose>
      <xsl:when test="parent::m:apply">   
        <m:mfenced>
         <m:mrow>   
         <xsl:for-each select="child::*[position()!=last() and  position()!=1]">

          <xsl:apply-templates select="."/><m:mo>&#x2295;</m:mo>
         </xsl:for-each>
         <xsl:apply-templates select="child::*[position()=last()]"/>
         </m:mrow>
        </m:mfenced> 
      </xsl:when>
      <xsl:otherwise>
       <m:mrow>   
       <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
         <xsl:apply-templates select="."/><m:mo>&#x2295;</m:mo>

       </xsl:for-each>
       <xsl:apply-templates select="child::*[position()=last()]"/>
       </m:mrow>
  </xsl:otherwise>
     </xsl:choose>
    </xsl:when>
    <xsl:when test="count(*)=2">
      <xsl:choose>
        <xsl:when test="parent::m:apply">

          <m:mfenced>
           <m:mrow>
           <m:mo>&#x2295;</m:mo><xsl:apply-templates select="*[position()=last()]"/>
           </m:mrow>
          </m:mfenced>
        </xsl:when>
        <xsl:otherwise>
          <m:mrow>
           <m:mo>&#x2295;</m:mo><xsl:apply-templates select="*[position()=last()]"/>

          </m:mrow>
    </xsl:otherwise>
  </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
    <m:mo>&#x2295;</m:mo>
    </xsl:otherwise>
  </xsl:choose>
</m:mrow>

</xsl:template>

<!-- NOT -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='not']]">
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes">&#x00AC;</xsl:text></m:mo>
    <xsl:choose>
    <xsl:when test="child::m:apply"><!--add brackets around OR,AND,XOR children for priority purpose-->
      <m:mfenced separators=" ">
        <xsl:apply-templates select="child::*[position()=2]"/>
      </m:mfenced>

    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="child::*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- implies -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='implies']]">
  <m:mrow>

    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x21D2;</xsl:text></m:mo>
    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='implies']]">
  <m:mrow>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x21D2;</xsl:text></m:mo>

    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<!-- for all-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='forall']]">
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2200;</xsl:text></m:mo>
    <m:mrow>
      <xsl:for-each select="m:bvar[position()!=last()]">
        <xsl:apply-templates select="."/><m:mo>,</m:mo>

      </xsl:for-each>
      <xsl:apply-templates select="m:bvar[position()=last()]"/>
    </m:mrow>
    <xsl:if test="m:condition">
      <m:mrow><m:mo>,</m:mo><xsl:apply-templates select="m:condition"/></m:mrow>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="m:apply">

        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:apply"/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:reln">
        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:reln"/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:ci">
        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:ci"/></m:mfenced>

      </xsl:when>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- exist-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='exists']]">
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2203;</xsl:text></m:mo>
    <m:mrow>
      <xsl:for-each select="m:bvar[position()!=last()]">

        <xsl:apply-templates select="."/><m:mo>,</m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="m:bvar[position()=last()]"/>
    </m:mrow>
    <xsl:if test="m:condition">
      <m:mrow><m:mo>,</m:mo><xsl:apply-templates select="m:condition"/></m:mrow>
    </xsl:if>
    <xsl:choose>

      <xsl:when test="m:apply">
        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:apply"/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:reln">
        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:reln"/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:ci">
        <m:mo>:</m:mo><m:mfenced><xsl:apply-templates select="m:ci"/></m:mfenced>

      </xsl:when>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- absolute value -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='abs']]">
  <m:mrow><m:mo>|</m:mo><xsl:apply-templates select="child::*[position()=last()]"/><m:mo>|</m:mo></m:mrow>
</xsl:template>

<!-- conjugate -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='conjugate']]">
  <m:mover>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x00AF;</xsl:text></m:mo>  <!-- does not work, UNICODE x0233D  or perhaps OverBar-->
  </m:mover>
</xsl:template>

<!-- argument of complex number -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arg']]">
  <m:mrow>
    <m:mi>&#x2220;</m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo><m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced>

  </m:mrow>
</xsl:template>

<!-- real part of complex number -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='real']]">
  <m:mrow>
    <m:mi><xsl:text disable-output-escaping="yes">&amp;#x0211C;</xsl:text><!-- &#x211C; or &#x211C; should work--></m:mi>
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced>
  </m:mrow>

</xsl:template>

<!-- imaginary part of complex number -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='imaginary']]">
  <m:mrow>
    <m:mi><xsl:text disable-output-escaping="yes">&amp;#x02111;</xsl:text><!-- &#x2111; or &impartl should work--></m:mi>
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced>
  </m:mrow>
</xsl:template>

<!-- lowest common multiple -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='lcm']]">
  <m:mrow>
    <m:mi>lcm</m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <m:mfenced>
      <xsl:apply-templates select="child::*[position()!=1]"/>
    </m:mfenced>
  </m:mrow>
</xsl:template>

<!-- floor -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='floor']]">
  <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x230A;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=last()]"/><m:mo><xsl:text disable-output-escaping="yes">&#x230B;</xsl:text></m:mo></m:mrow>
</xsl:template>

<!-- ceiling -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='ceiling']]">
  <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2308;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=last()]"/><m:mo><xsl:text disable-output-escaping="yes">&#x2309;</xsl:text></m:mo></m:mrow>
</xsl:template>

<!-- #################### 4.4.4 #################### -->

<!-- equal to -->
<xsl:template name="eqRel">
  <xsl:choose>

  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo>=</m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>
    </m:mrow>
  </xsl:when>

  <xsl:when test="count(child::*)=2">
    <m:mrow>
      <m:mo>=</m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>
  <xsl:otherwise>
    <m:mo>=</m:mo>
  </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='eq']]">
  <xsl:call-template name="eqRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='eq']]">
  <xsl:call-template name="eqRel"/>
</xsl:template>

<!-- not equal to -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='neq']]">
  <m:mrow>

    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2260;</xsl:text></m:mo>
    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='neq']]">
  <m:mrow>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2260;</xsl:text></m:mo>

    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<!-- greater than -->
<xsl:template name="gtRel">
  <xsl:choose>
  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&gt;</xsl:text></m:mo>

      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>
    </m:mrow>
  </xsl:when>
  <xsl:when test="count(child::*)=2">
    <m:mrow>
      <m:mo><xsl:text disable-output-escaping="yes">&gt;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>

  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&gt;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='gt']]">
  <xsl:call-template name="gtRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='gt']]">
  <xsl:call-template name="gtRel"/>

</xsl:template>

<!-- less than -->
<xsl:template name="ltRel">
  <xsl:choose>
  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes"><![CDATA[&lt;]]></xsl:text></m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>

    </m:mrow>
  </xsl:when>
  <xsl:when test="count(child::*)=2">
    <m:mrow>
      <m:mo><xsl:text disable-output-escaping="yes"><![CDATA[&lt;]]></xsl:text></m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes"><![CDATA[&lt;]]></xsl:text></m:mo>

  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='lt']]">
  <xsl:call-template name="ltRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='lt']]">
  <xsl:call-template name="ltRel"/>
</xsl:template>

<!-- greater than or equal to -->

<xsl:template name="geqRel">
  <xsl:choose>
  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2265;</xsl:text></m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>
    </m:mrow>

  </xsl:when>
  <xsl:when test="count(child::*)=2">
    <m:mrow>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2265;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2265;</xsl:text></m:mo>
  </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='geq']]">
  <xsl:call-template name="geqRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='geq']]">
  <xsl:call-template name="geqRel"/>
</xsl:template>

<!-- less than or equal to -->
<xsl:template name="leqRel">
  <xsl:choose>

  <xsl:when test="count(child::*)>=3">
    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2264;</xsl:text></m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>
    </m:mrow>
  </xsl:when>
  <xsl:when test="count(child::*)=2">

    <m:mrow>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2264;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2264;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='leq']]">
  <xsl:call-template name="leqRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='leq']]">
  <xsl:call-template name="leqRel"/>
</xsl:template>

<!-- equivalent -->
<xsl:template name="equivRel">
  <xsl:choose>
  <xsl:when test="count(child::*)>=3">

    <m:mrow>
      <xsl:for-each select="child::*[position()!=1 and position()!=last()]">
  <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2261;</xsl:text></m:mo>
      </xsl:for-each>
      <xsl:apply-templates select="child::*[position()=last()]"/>
    </m:mrow>
  </xsl:when>
  <xsl:when test="count(child::*)=2">
    <m:mrow>

      <m:mo><xsl:text disable-output-escaping="yes">&#x2261;</xsl:text></m:mo><xsl:apply-templates select="child::*[position()=2]"/>
    </m:mrow>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2261;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='equivalent']]">

  <xsl:call-template name="equivRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='equivalent']]">
  <xsl:call-template name="equivRel"/>
</xsl:template>

<!-- approximately equal -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='approx']]">
  <m:mrow>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping='yes'>&amp;#x02248;</xsl:text><!-- &#x2248; or &#x2248; should work--></m:mo>

    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='approx']]">
  <m:mrow>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo><xsl:text disable-output-escaping='yes'>&amp;#x02248;</xsl:text><!-- &#x2248; or &#x2248; should work--></m:mo>
    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>

</xsl:template>

<!-- factor of -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='factorof']]">
  <m:mrow>
    <xsl:apply-templates select="child::*[position()=2]"/>
    <m:mo>|</m:mo>
    <xsl:apply-templates select="child::*[position()=3]"/>
  </m:mrow>
</xsl:template>

<!-- #################### 4.4.5 #################### -->

<!-- integral -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='int']]">
  <m:mrow>
    <xsl:choose>
    <xsl:when test="m:condition"> <!-- integration domain expressed by a condition-->
      <m:munder>
        <m:mo><xsl:text disable-output-escaping="yes">&#x222B;</xsl:text></m:mo>
        <xsl:apply-templates select="m:condition"/>

      </m:munder>
      <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow>
      <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow>
    </xsl:when>
    <xsl:when test="m:domainofapplication"> <!-- integration domain expressed by a domain of application-->
      <m:munder>
        <m:mo><xsl:text disable-output-escaping="yes">&#x222B;</xsl:text></m:mo>
        <xsl:apply-templates select="m:domainofapplication"/>

      </m:munder>
      <m:mrow><xsl:apply-templates select="*[position()=last() and local-name()!='domainofapplication']"/></m:mrow>
      <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow>  <!--not sure about this line: can get rid of it if there is never a bvar elem when integ domain specified by domainofapplication-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
      <xsl:when test="m:interval"> <!-- integration domain expressed by an interval-->

        <m:msubsup>
          <m:mo><xsl:text disable-output-escaping="yes">&#x222B;</xsl:text></m:mo>
          <xsl:apply-templates select="m:interval/*[position()=1]"/>
          <xsl:apply-templates select="m:interval/*[position()=2]"/>
        </m:msubsup>
        <xsl:apply-templates select="*[position()=last()]"/>
        <m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/>
      </xsl:when>

      <xsl:when test="m:lowlimit"> <!-- integration domain expressed by lower and upper limits-->
        <m:msubsup>
          <m:mo><xsl:text disable-output-escaping="yes">&#x222B;</xsl:text></m:mo>
          <m:mrow><xsl:apply-templates select="m:lowlimit"/></m:mrow>
          <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow>
        </m:msubsup>
        <xsl:apply-templates select="*[position()=last()]"/>
        <m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/>

      </xsl:when>
      <xsl:otherwise>
        <m:mo><xsl:text disable-output-escaping="yes">&#x222B;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=last()]"/>
  <m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>

    </xsl:choose>
  </m:mrow>
</xsl:template>

  <!-- differentiation -->
  <xsl:template match="m:apply[child::*[position()=1 and local-name()='diff']]">
    <m:mrow>
      <xsl:choose>
  <!-- If there's a bound-variable, use Leibniz notation-->
  <xsl:when test="m:bvar">

    <xsl:choose>
      <xsl:when test="m:bvar/m:degree"> 
        <!-- if the order of the derivative is specified-->
        <xsl:choose>
    <xsl:when test="contains(m:bvar/m:degree/m:cn/text(),'1') and string-length(normalize-space(m:bvar/m:degree/m:cn/text()))=1">
      <m:mfrac>
        <m:mo>d<!--DifferentialD does not work--></m:mo>
        <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo>

          <xsl:apply-templates select="m:bvar/*[local-name(.)!='degree']"/></m:mrow>
      </m:mfrac>
      <m:mrow>
        <xsl:choose>
          <xsl:when test="(m:apply[position()=last()]/m:fn[position()=1] or m:apply[position()=last()]/m:ci[@type='fn'] or m:matrix)"> 
      <xsl:apply-templates select="*[position()=last()]"/>
          </xsl:when> <!--add brackets around expression if not a function-->
          <xsl:otherwise>
      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>

          </xsl:otherwise>
        </xsl:choose>
      </m:mrow>
    </xsl:when>
    <xsl:otherwise> <!-- if the order of the derivative is not 1-->
      <m:mfrac>
        <m:mrow><m:msup><m:mo>d<!--DifferentialD does not work--></m:mo><m:mrow><xsl:apply-templates select="m:bvar/m:degree"/></m:mrow></m:msup></m:mrow>
        <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><m:msup><m:mrow><xsl:apply-templates select="m:bvar/*[local-name(.)!='degree']"/></m:mrow><m:mrow><xsl:apply-templates select="m:bvar/m:degree"/></m:mrow></m:msup></m:mrow>

      </m:mfrac>
      <m:mrow>
        <xsl:choose>
          <xsl:when test="(m:apply[position()=last()]/m:fn[position()=1] or m:apply[position()=last()]/m:ci[@type='fn'] or m:matrix)">
      <xsl:apply-templates select="*[position()=last()]"/>
          </xsl:when>
          <xsl:otherwise>
      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
          </xsl:otherwise>

        </xsl:choose>
      </m:mrow>
    </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- if no order is specified, default to 1-->
        <m:mfrac>
    <m:mo>d<!--DifferentialD does not work--></m:mo>

    <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow>
        </m:mfrac>
        <m:mrow>
    <xsl:choose>
      <xsl:when test="(m:apply[position()=last()]/m:fn[position()=1] or m:apply[position()=last()]/m:ci[@type='fn'] or m:matrix)">
        <xsl:apply-templates select="*[position()=last()]"/>
      </xsl:when>
      <xsl:otherwise>

        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
      </xsl:otherwise>
    </xsl:choose>
        </m:mrow>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <!-- Otherwise use prime notation -->
  <xsl:otherwise>

    <xsl:choose>
      <xsl:when test="m:degree">
        <m:msup>
    <m:mrow><xsl:apply-templates
    select="child::*[local-name()!='degree']"/></m:mrow>
    <m:mrow>    
      <xsl:choose>
        <xsl:when test='m:degree/m:ci'>
          <xsl:apply-templates select="m:degree/m:ci"/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:choose>
      <xsl:when test="m:degree/m:cn/text() &gt;= '4'">
        <xsl:value-of select="m:degree/m:cn/text()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="differentiation-degree">
          <xsl:with-param name="degreemax">
            <xsl:value-of select="m:degree/m:cn/text()"/>

          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </m:mrow>
        </m:msup>
      </xsl:when>

      <xsl:otherwise>
        <xsl:choose>
    <xsl:when test="m:apply/m:ci[@type='fn']">
      <m:mrow>
      <m:msup>
        <xsl:apply-templates select="m:apply/m:ci[1]"/>
        <m:mo accent="true"><xsl:text disable-output-escaping="yes">&#x2032;</xsl:text></m:mo>
      </m:msup>
        </m:mrow>

      <m:mfenced>
        <xsl:apply-templates select="child::m:apply/*[position()!='1']"/>
      </m:mfenced>
    </xsl:when>
    <xsl:otherwise>
      <m:msup>
        <m:mrow><xsl:apply-templates/></m:mrow>
        <m:mo accent="true"><xsl:text disable-output-escaping="yes">&#x2032;</xsl:text></m:mo>
      </m:msup>

    </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
      </xsl:choose>
    </m:mrow>
  </xsl:template>

  <xsl:template name="differentiation-degree">
    <xsl:param name="degreemax"/>
      <m:mo accent="true"><xsl:text disable-output-escaping="yes">&#x2032;</xsl:text></m:mo>
      <xsl:if test="not($degreemax = 1)">
  <xsl:call-template name="differentiation-degree"> 
    <xsl:with-param name="degreemax"> 
      <xsl:value-of select="$degreemax - 1"/> 
    </xsl:with-param> 
  </xsl:call-template> 
      </xsl:if> 
  </xsl:template>
      
      
  
  <!-- partial differentiation -->

  <!-- the latest working draft sets the default rendering of the numerator
  to only one mfrac with one PartialD for the numerator, exponent being the sum
  of every partial diff's orders; not supported yet (I am not sure it is even possible with XSLT)-->
  <xsl:template match="m:apply[child::*[position()=1 and local-name()='partialdiff']]">
    <m:mrow>
      <xsl:choose>
  <xsl:when test="m:list">
    <m:msub>
      <m:mo>D</m:mo>
      <m:mfenced separators="," open="" close=""><xsl:apply-templates select="m:list/*"/></m:mfenced>

    </m:msub>
    <m:mfenced open="(" close=")"><xsl:apply-templates select="*[local-name()!='list']"/></m:mfenced>
  </xsl:when>
  
  <xsl:otherwise>
    <xsl:choose>
      <xsl:when test="child::*[local-name()='degree' and position()>0]">
        <m:mfrac>           
    <m:mrow><m:msup><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo><xsl:apply-templates select="m:degree"/></m:msup></m:mrow>
    <m:mrow>

      <xsl:for-each select="m:bvar">
        <xsl:choose>
          <xsl:when test="m:degree"> <!-- if order is specified" -->    
      <xsl:choose>         
        <xsl:when test="contains(m:degree/m:cn/text(),'1') and string-length(normalize-space(m:degree/m:cn/text()))=1">
          <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo><xsl:apply-templates select="*[local-name(.)!='degree']"/></m:mrow>
        </xsl:when>
        <xsl:otherwise> <!-- if order of the derivative is not 1 -->
          <m:mrow><m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo></m:mrow><m:msup><m:mrow><xsl:apply-templates select="*[local-name(.)!='degree']"/></m:mrow><m:mrow><xsl:apply-templates select="m:degree"/></m:mrow></m:msup></m:mrow>

        </xsl:otherwise>
      </xsl:choose>
          </xsl:when>
          <xsl:otherwise> <!-- no order specifiied, default to 1 -->         
      <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo><xsl:apply-templates select="."/></m:mrow>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </m:mrow>

        </m:mfrac>
        <m:mrow>
    <xsl:choose>
      <xsl:when test="m:apply[position()=last()]/m:fn[position()=1]"> 
        <xsl:apply-templates select="*[position()=last()]"/>
      </xsl:when> <!--add brackets around expression if not a function (MathML 1.0 )-->
      <xsl:when test="m:apply[position()=last()]/m:ci[position()=1 and @type='fn']">
        <xsl:apply-templates select="*[position()=last()]"/>
      </xsl:when> <!-- add brackets around expression if not a function -->

      <xsl:when test="*[position()=last() and local-name()!='bvar' and local-name()!='degree']">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <!-- do nothing in this case -->
      </xsl:otherwise>
    </xsl:choose>
        </m:mrow>
      </xsl:when>

      
      <xsl:otherwise>
        <m:mfrac>
    <m:mrow><m:msup><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo>
        <m:mrow> 
          <xsl:if test="count(m:bvar/m:degree[child::*[local-name()='cn']])>=1 or count(m:bvar[count(child::*)=1])>1">
      <xsl:variable name="sumdeg" select="sum(m:bvar/m:degree/m:cn/text())"/>
      <xsl:variable name="degsum" select="count(m:bvar[count(child::*)=1])"/>
      <xsl:variable name="totalsum" select="$sumdeg+$degsum"/>
      <m:mn><xsl:value-of select="$totalsum"/></m:mn>

          </xsl:if>
          <xsl:for-each select="child::*[position()=2 and local-name()='bvar']">
      <xsl:if test="m:degree[child::*[local-name()!='cn']]">
        <xsl:apply-templates select="child::*[position()!=1]"/>
      </xsl:if>
          </xsl:for-each>
          <xsl:for-each select="child::*[position()>2 and local-name()='bvar']">
      <xsl:if test="m:degree[child::*[local-name()!='cn']]">
        <m:mo>+</m:mo>

        <xsl:apply-templates select="child::*[position()!=1]"/>
      </xsl:if>
          </xsl:for-each>
        </m:mrow>
      </m:msup></m:mrow>
    <m:mrow>
      <xsl:for-each select="m:bvar">
        <xsl:choose>
          <xsl:when test="m:degree"> <!-- if the order of the derivative is specified-->

      <xsl:choose>
        <xsl:when test="contains(m:degree/m:cn/text(),'1') and string-length(normalize-space(m:degree/m:cn/text()))=1">
          <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo><xsl:apply-templates select="*[local-name(.)!='degree']"/></m:mrow>
        </xsl:when>
        <xsl:otherwise> <!-- if the order of the derivative is not 1-->
          <m:mrow><m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo></m:mrow><m:msup><m:mrow><xsl:apply-templates select="*[local-name(.)!='degree']"/></m:mrow><m:mrow><xsl:apply-templates select="m:degree"/></m:mrow></m:msup></m:mrow>
        </xsl:otherwise>
      </xsl:choose>

          </xsl:when>
          <xsl:otherwise> <!-- if no order is specified, default to 1-->
      <m:mrow><m:mo><xsl:text disable-output-escaping="yes">&#x2202;</xsl:text></m:mo><xsl:apply-templates select="."/></m:mrow>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </m:mrow>
        </m:mfrac>

        <m:mrow>
    <xsl:choose>
      <xsl:when test="m:apply[position()=last()]/m:fn[position()=1]"> 
        <xsl:apply-templates select="*[position()=last()]"/>
      </xsl:when> <!--add brackets around expression if not a function (MathML 1.0) -->
      <xsl:when test="m:apply[position()=last()]/m:ci[position()=1 and @type='fn']"> 
        <xsl:apply-templates select="*[position()=last()]"/>
      </xsl:when> <!-- add brackets around expression if not a function -->
      <xsl:when test="*[position()=last() and local-name()!='bvar' and local-name()!='degree']">

        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <!-- do nothing -->
      </xsl:otherwise>
    </xsl:choose>
        </m:mrow>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:otherwise>
      </xsl:choose>
    </m:mrow>
  </xsl:template>

<!-- lowlimit was not in original stylesheet -->
  <xsl:template match="m:lowlimit">
    <xsl:apply-templates select="*"/>
  </xsl:template>

<!-- uplimit was not in original stylesheet-->
  <xsl:template match="m:uplimit">
    <xsl:apply-templates select="*"/>
  </xsl:template>

<!-- bvar was not in original stylesheet -->
  <xsl:template match="m:bvar">
      <xsl:apply-templates select="*"/>
  </xsl:template>
  
<!-- degree was not in original stylesheet -->

  <xsl:template match="m:degree">
    <xsl:apply-templates select="*"/>
  </xsl:template>

<!-- divergence -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='divergence']]">
<m:mrow>
  <m:mi>div</m:mi>
  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">

    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]"/>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>

</xsl:template>

<!-- gradient -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='grad']]">
<m:mrow>
  <m:mi>grad</m:mi>
  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>

  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]"/>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- vector calculus curl -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='curl']]">
<m:mrow>
  <m:mi>curl</m:mi>

  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]"/>
  </xsl:otherwise>

  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- laplacian -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='laplacian']]">
<m:mrow>
  <m:msup>
    <m:mo><xsl:text disable-output-escaping='yes'>&amp;#x02207;</xsl:text></m:mo>  <!-- Del or nabla should work-->
    <m:mn>2</m:mn>

  </m:msup>
  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]"/>

  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>


<!-- #################### 4.4.6 #################### -->

<!-- set -->
<xsl:template match="m:set">
  <m:mrow>
    <xsl:choose>
    <xsl:when test="m:condition"> <!-- set defined by a condition-->

      <m:mo>{</m:mo><m:mrow><m:mfenced open="" close=""><xsl:apply-templates select="m:bvar"/></m:mfenced><m:mo>|</m:mo><xsl:apply-templates select="m:condition"/></m:mrow><m:mo>}</m:mo>
    </xsl:when>
    <xsl:otherwise> <!-- set defined by an enumeration -->
    <xsl:element name="m:mfenced" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:attribute name="open">{</xsl:attribute>
  <xsl:attribute name="close">}</xsl:attribute>

  <xsl:attribute name="separators">,</xsl:attribute>
  <xsl:apply-templates select="*"/>
      </xsl:element>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template> 

<!-- list -->
<!-- sorting is not supported yet; not sure we should do it; anyway, can be  done using xsl:sort-->
<xsl:template match="m:list">

  <m:mrow>
    <xsl:choose>
    <xsl:when test="m:condition"> <!-- set defined by a condition-->
      <m:mo>[</m:mo><m:mrow><m:mfenced open="" close=""><xsl:apply-templates select="m:bvar"/></m:mfenced><m:mo>|</m:mo><xsl:apply-templates select="m:condition"/></m:mrow><m:mo>]</m:mo>
    </xsl:when>
    <xsl:otherwise> <!-- set defined by an enumeration -->

      <m:mfenced open="[" close="]"><xsl:apply-templates select="*"/></m:mfenced>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- union -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='union']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3">

    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x22C3;</xsl:text></m:mo>
    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>
  </xsl:when>
  <xsl:when test="count(*)=2">
      <m:mo><xsl:text disable-output-escaping="yes">&#x22C3;</xsl:text></m:mo><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>

    <m:mo><xsl:text disable-output-escaping="yes">&#x22C3;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- intersection -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='intersect']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3">
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">

      <xsl:choose>
      <xsl:when test="m:union">  <!-- add brackets around UNION children for priority purpose: intersection has higher precedence than union -->
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">&#x22C2;</xsl:text></m:mo>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x22C2;</xsl:text></m:mo>
      </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>
  </xsl:when>
  <xsl:when test="count(*)=2">
      <m:mo><xsl:text disable-output-escaping="yes">&#x22C2;</xsl:text></m:mo><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x22C2;</xsl:text></m:mo>
  </xsl:otherwise>

  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- inclusion -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='in']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2208;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='in']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2208;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- exclusion -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='notin']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2209;</xsl:text></m:mo>

  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='notin']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2209;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- containment (subset of)-->

<xsl:template name="subsetRel">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3">
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2286;</xsl:text></m:mo>
    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>
    </xsl:when>
    <xsl:when test="count(*)=2">

      <m:mo><xsl:text disable-output-escaping="yes">&#x2286;</xsl:text></m:mo><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2286;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='subset']]">
  <xsl:call-template name="subsetRel"/>

</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='subset']]">
  <xsl:call-template name="subsetRel"/>
</xsl:template>

<!-- containment (proper subset of) -->
<xsl:template name="prsubsetRel">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>=3">
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x2282;</xsl:text></m:mo>

    </xsl:for-each>
    <xsl:apply-templates select="child::*[position()=last()]"/>
    </xsl:when>
    <xsl:when test="count(*)=2">
      <m:mo><xsl:text disable-output-escaping="yes">&#x2282;</xsl:text></m:mo><xsl:apply-templates select="*[position()=last()]"/>
  </xsl:when>
  <xsl:otherwise>
    <m:mo><xsl:text disable-output-escaping="yes">&#x2282;</xsl:text></m:mo>
  </xsl:otherwise>

  </xsl:choose>
</m:mrow>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='prsubset']]">
  <xsl:call-template name="prsubsetRel"/>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='prsubset']]">
  <xsl:call-template name="prsubsetRel"/>
</xsl:template>

<!-- perhaps Subset and SubsetEqual signs are used in place of one another ; not according to the spec -->

<!-- containment (not subset of)-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='notsubset']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2284;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='notsubset']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2284;</xsl:text></m:mo>

  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- containment (not proper subset of) -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='notprsubset']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2288;</xsl:text></m:mo>  <!-- does not work, perhaps nsube, or nsubE, or nsubseteqq or nsubseteq, UNICODE x02288-->
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='notprsubset']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2288;</xsl:text></m:mo>  <!-- does not work, perhaps nsube, or nsubE, or nsubseteqq or nsubseteq, UNICODE x02288-->
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- difference of two sets -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='setdiff']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>

  <m:mo><xsl:text disable-output-escaping="yes">&#x2216;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- cardinality -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='card']]">
  <m:mrow><m:mo>|</m:mo><xsl:apply-templates select="*[position()=last()]"/><m:mo>|</m:mo></m:mrow>
</xsl:template>

<!-- cartesian product -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='cartesianproduct']]">

<xsl:choose>
<xsl:when test="count(child::*)>=3">
  <m:mrow>
    <xsl:for-each select="child::*[position()!=last() and  position()!=1]">
      <xsl:choose>
      <xsl:when test="m:plus"> <!--add brackets around + children for priority purpose-->
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
      </xsl:when>
      <xsl:when test="m:minus"> <!--add brackets around - children for priority purpose-->

        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
      </xsl:when>
      <xsl:when test="(local-name(.)='ci' or local-name(.)='cn') and contains(text(),'-')"> <!-- have to do it using contains because starts-with doesn't seem to work well in XT-->
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
      </xsl:otherwise>

      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="child::*[position()=last()]">
      <xsl:choose>
      <xsl:when test="m:plus">
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
      </xsl:when>
      <xsl:when test="m:minus">
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>

      </xsl:when>
      <xsl:when test="(local-name(.)='ci' or local-name(.)='cn') and contains(text(),'-')"> <!-- have to do it using contains because starts-with doesn't seem to work well in  XT-->
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
  </m:mrow>
</xsl:when>
<xsl:when test="count(child::*)=2">  <!-- unary -->
  <m:mrow>
    <m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
    <xsl:choose>
      <xsl:when test="m:plus">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>

      </xsl:when>
      <xsl:when test="m:minus">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      <xsl:when test="(*[position()=2 and self::m:ci] or *[position()=2 and self::m:cn]) and contains(*[position()=2]/text(),'-')">
        <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[position()=2]"/>

      </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:when>
<xsl:otherwise>  <!-- no operand -->
  <m:mo><xsl:text disable-output-escaping="yes"> <!--&InvisibleTimes;--></xsl:text></m:mo>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- #################### 4.4.7 #################### -->

<!-- sum -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sum']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="m:condition and m:domainofapplication"><!-- domainofapplication as well as condition -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>
      <m:mrow><m:munder>
              <m:mrow><xsl:apply-templates select="m:domainofapplication"/></m:mrow>
              <m:mrow><xsl:apply-templates select='m:condition'/></m:mrow>

            </m:munder>
      </m:mrow>
    </m:munder>
  </xsl:when> 
  <xsl:when test="m:condition and m:lowlimit and m:uplimit"><!-- uplimit and lowlimit as well as condition -->
    <m:munderover>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>
      <m:mrow><m:munder>
              <m:mrow><xsl:apply-templates select="m:bvar"/><m:mo>=</m:mo><xsl:apply-templates
      select="m:lowlimit"/></m:mrow>

              <m:mrow><xsl:apply-templates select='m:condition'/></m:mrow>
            </m:munder>
      </m:mrow>
      <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow>
    </m:munderover>
  </xsl:when>    
  <xsl:when test="m:condition">  <!-- domain specified by a condition -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>

      <xsl:apply-templates select="m:condition"/>
    </m:munder>
  </xsl:when>
  <xsl:when test="m:domainofapplication">  <!-- domain specified by domain of application -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>
      <xsl:apply-templates select="m:domainofapplication"/>
    </m:munder>

  </xsl:when>
  <xsl:when test="m:lowlimit and m:uplimit">  <!-- domain specified by low and up limits -->
    <m:munderover>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>
      <m:mrow><xsl:apply-templates select="m:bvar"/><m:mo>=</m:mo><xsl:apply-templates select="m:lowlimit"/></m:mrow>
      <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow>
    </m:munderover>
  </xsl:when>

  <xsl:otherwise>
      <m:mo><xsl:text disable-output-escaping="yes">&#x2211;</xsl:text></m:mo>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
  <xsl:when test="*[position()=last() and self::m:apply]">  <!-- if expression is complex, wrap it in brackets -->
    <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
  </xsl:when>

  <xsl:otherwise>  <!-- if not put it in an mrow -->
    <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- product -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='product']]">
<m:mrow>
  <xsl:choose>

  <xsl:when test="m:condition and m:domainofapplication"><!-- domainofapplication as well as condition -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x220F;</xsl:text></m:mo>
      <m:mrow><m:munder>
              <m:mrow><xsl:apply-templates select="m:domainofapplication"/></m:mrow>
              <m:mrow><xsl:apply-templates select='m:condition'/></m:mrow>
            </m:munder>
      </m:mrow>
    </m:munder>

  </xsl:when> 
  <xsl:when test="m:condition and m:lowlimit and m:uplimit"><!-- uplimit and lowlimit as well as condition -->
    <m:munderover>
      <m:mo><xsl:text disable-output-escaping="yes">&#x220F;</xsl:text></m:mo>
      <m:mrow><m:munder>
              <m:mrow><xsl:apply-templates select="m:bvar"/><m:mo>=</m:mo><xsl:apply-templates
      select="m:lowlimit"/></m:mrow>
              <m:mrow><xsl:apply-templates select='m:condition'/></m:mrow>
            </m:munder>
      </m:mrow>

      <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow>
    </m:munderover>
  </xsl:when>  
  <xsl:when test="m:condition">   <!-- domain specified by a condition -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x220F;</xsl:text></m:mo>
      <xsl:apply-templates select="m:condition"/>
    </m:munder>
  </xsl:when>

  <xsl:when test="m:domainofapplication"> <!--domain specified by a domain -->
    <m:munder>
      <m:mo><xsl:text disable-output-escaping="yes">&#x220F;</xsl:text></m:mo>
      <xsl:apply-templates select="m:domainofapplication"/>
    </m:munder>
  </xsl:when>
  <xsl:otherwise>  <!-- domain specified by low and up limits -->
    <m:munderover>

      <m:mo><xsl:text disable-output-escaping="yes">&#x220F;</xsl:text></m:mo>
      <m:mrow><xsl:apply-templates select="m:bvar"/><m:mo>=</m:mo><xsl:apply-templates select="m:lowlimit"/></m:mrow>
      <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow>
    </m:munderover>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:choose>
  <xsl:when test="*[position()=last() and self::m:apply]">  <!-- if expression is complex, wrap it in brackets -->

    <m:mfenced separators=" "><xsl:apply-templates select="*[position()=last()]"/></m:mfenced>
  </xsl:when>
  <xsl:otherwise>  <!-- if not put it in an mrow -->
    <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- limit -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='limit']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="m:condition">
    <m:munder>
      <m:mo>lim</m:mo>
      <xsl:apply-templates select="m:condition"/>
    </m:munder>
  </xsl:when>

  <xsl:otherwise>
    <m:munder>
      <m:mo>lim</m:mo>
      <m:mrow><xsl:apply-templates select="m:bvar"/><m:mo><xsl:text disable-output-escaping="yes">&#x2192;</xsl:text></m:mo><xsl:apply-templates select="m:lowlimit"/></m:mrow>
    </m:munder>
  </xsl:otherwise>
  </xsl:choose>
  <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow>

</m:mrow>
</xsl:template>

<!-- tends to -->
<xsl:template name="tendstoRel">
<m:mrow>
  <xsl:choose>
  <xsl:when test="m:tendsto/@type">
    <xsl:choose>
    <xsl:when test="m:tendsto/@type='above'"> <!-- from above -->
      <xsl:apply-templates select="*[position()=2]"/><m:mo><xsl:text disable-output-escaping="yes">&#x2193;</xsl:text></m:mo><xsl:apply-templates select="*[position()=3]"/>

    </xsl:when>
    <xsl:when test="m:tendsto/@type='below'"> <!-- from below -->
      <xsl:apply-templates select="*[position()=2]"/><m:mo><xsl:text disable-output-escaping="yes">&#x2191;</xsl:text></m:mo><xsl:apply-templates select="*[position()=3]"/>
    </xsl:when>
    <xsl:when test="m:tendsto/@type='two-sided'"> <!-- from above or below -->
      <xsl:apply-templates select="*[position()=2]"/><m:mo><xsl:text disable-output-escaping="yes">&#x2192;</xsl:text></m:mo><xsl:apply-templates select="*[position()=3]"/>
    </xsl:when>
    </xsl:choose>

  </xsl:when>
  <xsl:otherwise>  <!-- no type attribute -->
    <xsl:apply-templates select="*[position()=2]"/><m:mo><xsl:text disable-output-escaping="yes">&#x2192;</xsl:text></m:mo><xsl:apply-templates select="*[position()=3]"/>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<xsl:template match="m:apply[child::*[position()=1 and local-name()='tendsto']]">
  <xsl:call-template name="tendstoRel"/>

</xsl:template>

<xsl:template match="m:reln[child::*[position()=1 and local-name()='tendsto']]">
  <xsl:call-template name="tendstoRel"/>
</xsl:template>

<!-- #################### 4.4.8 #################### -->

<!-- main template for all trigonometric functions -->
<xsl:template name="trigo">
  <xsl:param name="func">sin</xsl:param> <!-- provide sin as default function in case none is provided (this should never occur)-->
<m:mrow>
  <m:mi><xsl:value-of select="$func"/></m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>

  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
    <m:mfenced separators=" ">
    <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
      <m:mfenced separators=" ">
        <xsl:apply-templates select="child::*[position()=2]"/>

      </m:mfenced>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- trigonometric function: sine -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sin']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">sin</xsl:with-param>
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:sin[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>sin</m:mi>  <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: cosine -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='cos']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">cos</xsl:with-param>
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:cos[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>cos</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: tan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='tan']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">tan</xsl:with-param>   
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:tan[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>tan</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: sec -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sec']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">sec</xsl:with-param>  
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:sec[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>sec</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: csc -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='csc']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">csc</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:csc[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>csc</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: cotan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='cot']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">cot</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:cot[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>cot</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic sin -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sinh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">sinh</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:sinh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>sinh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic cos -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='cosh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">cosh</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:cosh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>cosh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic tan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='tanh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">tanh</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:tanh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>tanh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic sec -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sech']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">sech</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:sech[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>sech</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic csc -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='csch']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">csch</xsl:with-param>   
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:csch[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>csch</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: hyperbolic cotan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='coth']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">coth</xsl:with-param>   
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:coth[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>coth</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc sine -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arcsin']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arcsin</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arcsin[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arcsin</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc cosine -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccos']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccos</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccos[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccos</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc tan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arctan']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arctan</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arctan[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arctan</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc sec -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arcsec']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arcsec</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arcsec[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arcsec</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc csc -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccsc']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccsc</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccsc[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccsc</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc cotan -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccot']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccot</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccot[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccot</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc sinh -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arcsinh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arcsinh</xsl:with-param>
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arcsinh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arcsinh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc cosh -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccosh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccosh</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccosh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccosh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc tanh -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arctanh']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arctanh</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arctanh[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arctanh</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc sech -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arcsech']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arcsech</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arcsech[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arcsech</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc csch -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccsch']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccsch</xsl:with-param>    
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccsch[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccsch</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- trigonometric function: arc coth -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='arccoth']]">
  <xsl:call-template name="trigo">
    <xsl:with-param name="func">arccoth</xsl:with-param>   
  </xsl:call-template>

</xsl:template>

<xsl:template match="m:arccoth[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>arccoth</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- exponential -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='exp']]">
  <m:msup>
    <m:mi><xsl:text disable-output-escaping="yes">&#x2147;</xsl:text></m:mi>   <!-- ExponentialE does not work yet -->
    <xsl:apply-templates select="child::*[position()=2]"/>

  </m:msup>
</xsl:template>

<xsl:template match="m:exp[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi><xsl:text disable-output-escaping="yes">&#x2147;</xsl:text></m:mi>   <!-- used with inverse or composition; not sure it is appropriate for exponential-->
</xsl:template>

<!-- natural logarithm -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='ln']]">
<m:mrow>
  <m:mi>ln</m:mi><m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
  <xsl:choose>

  <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
    <m:mfenced separators=" ">
      <xsl:apply-templates select="child::*[position()=2]"/>
    </m:mfenced>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="child::*[position()=2]"/>
  </xsl:otherwise>
  </xsl:choose>

</m:mrow>
</xsl:template>

<xsl:template match="m:ln[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
  <m:mi>ln</m:mi>   <!-- used with inverse or composition-->
</xsl:template>

<!-- logarithm to a given base (default 10)-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='log']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="m:logbase">

    <m:msub>
      <m:mi>log</m:mi>
      <xsl:apply-templates select="m:logbase"/>
    </m:msub>
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <xsl:choose>
    <xsl:when test="local-name(*[position()=3])='apply' or ((local-name(*[position()=3])='ci' or local-name(*[position()=3])='cn') and contains(*[position()=3]/text(),'-'))">
      <m:mfenced separators=" ">

        <xsl:apply-templates select="child::*[position()=3]"/>
      </m:mfenced>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="child::*[position()=3]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise> <!--if no base is provided, default to 10-->

      <m:mi>log</m:mi> 
    <m:mo><xsl:text disable-output-escaping="yes"> <!--&ApplyFunction;--></xsl:text></m:mo>
    <xsl:choose>
    <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))">
      <m:mfenced separators=" ">
        <xsl:apply-templates select="child::*[position()=2]"/>
      </m:mfenced>
    </xsl:when>
    <xsl:otherwise>

      <xsl:apply-templates select="child::*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- logbase -->
<xsl:template match="m:logbase">
    <xsl:apply-templates select="*"/>

  </xsl:template>

<xsl:template match="m:log[local-name(preceding-sibling::*[position()=last()])='compose' or local-name(preceding-sibling::*[position()=last()])='inverse']">
<m:mrow>  <!-- used with inverse or composition-->
  <xsl:choose>
  <xsl:when test="m:logbase">
    <m:msub>
      <m:mi>log</m:mi>
      <xsl:apply-templates select="m:logbase"/>

    </m:msub>
  </xsl:when>
  <xsl:otherwise> <!--if no base is provided, default to 10-->
    <m:msub>
      <m:mi>log</m:mi>
      <m:mn>10</m:mn>
    </m:msub>

  </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- #################### 4.4.9 #################### -->

<!-- mean -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='mean']]">
<m:mrow>
  <xsl:choose>
  <xsl:when test="count(*)>2">  <!-- if more than one element use angle bracket notation-->

    <m:mo><xsl:text disable-output-escaping="yes">&#x2329;</xsl:text></m:mo>
    <xsl:for-each select="*[position()!=1 and position()!=last()]">
      <xsl:apply-templates select="."/><m:mo>,</m:mo>
    </xsl:for-each>
    <xsl:apply-templates select="*[position()=last()]"/>
    <m:mo><xsl:text disable-output-escaping="yes">&#x232A;</xsl:text></m:mo>  <!-- does not work, UNICODE x03009 or perhaps rangle or RightAngleBracket -->
  </xsl:when>
  <xsl:otherwise> <!-- if only one element use overbar notation-->

    <m:mover>
      <m:mrow>
  <xsl:apply-templates select="*[position()=last()]"/>
        </m:mrow>
      <m:mo><xsl:text
      disable-output-escaping="yes">&#x00AF;</xsl:text></m:mo>  <!-- does not work, UNICODE x0233D  or perhaps OverBar-->
    </m:mover>
  </xsl:otherwise>
  </xsl:choose>

</m:mrow>
</xsl:template>

<!-- standard deviation -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='sdev']]">
<m:mrow>
  <m:mi><xsl:text disable-output-escaping="yes">&#x03C3;</xsl:text></m:mi>
  <m:mfenced>
    <xsl:apply-templates select="*[position()!=1]"/>
  </m:mfenced>
</m:mrow>
</xsl:template>

<!-- statistical variance -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='variance']]">
<m:mrow>
  <m:mi><xsl:text disable-output-escaping="yes">&#x03C3;</xsl:text></m:mi>
  <m:msup> 
    <m:mfenced>
      <xsl:apply-templates select="*[position()!=1]"/>
    </m:mfenced>
    <m:mn>2</m:mn>

  </m:msup>
</m:mrow>
</xsl:template>

<!-- median -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='median']]">
<m:mrow>
  <m:mi>median</m:mi>
  <m:mfenced>
    <xsl:apply-templates select="*[position()!=1]"/>
  </m:mfenced>

</m:mrow>
</xsl:template>

<!-- statistical mode -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='mode']]">
<m:mrow>
  <m:mi>mode</m:mi>
  <m:mfenced>
    <xsl:apply-templates select="*[position()!=1]"/>
  </m:mfenced>
</m:mrow>

</xsl:template>

<!-- statistical moment -->
<!-- not sure we handle the n-ary thing correctly as far as display is concerned-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='moment']]">
<m:mrow>
  <m:mo><xsl:text disable-output-escaping="yes">&#x2329;</xsl:text></m:mo>
  <xsl:for-each select="*[position()!=1 and position()!=2 and position()!=last() and local-name()!='momentabout']">
    <m:msup>
      <xsl:apply-templates select="."/>
      <xsl:apply-templates select="../m:degree"/>
    </m:msup><m:mo>,</m:mo>

  </xsl:for-each>
  <m:msup>
    <xsl:apply-templates select="*[position()=last()]"/>
    <xsl:apply-templates select="m:degree"/>
  </m:msup>
  <m:mo><xsl:text disable-output-escaping="yes">&#x232A;</xsl:text></m:mo>
</m:mrow> 
</xsl:template>

<!-- point of moment (according to the spec it is not rendered)-->
<xsl:template match="m:momentabout">

</xsl:template>

<!-- #################### 4.4.10 #################### -->

<!-- vector -->
  <xsl:template match="m:vector">
    <!-- the default display for a vector is vertically -->
    <m:mrow>
      <m:mfenced open="(" close=")">
      <m:mtable>
  <xsl:for-each select="*">

    <m:mtr>
      <m:mtd>
        <xsl:apply-templates select="."/>
      </m:mtd>
    </m:mtr>
  </xsl:for-each>
      </m:mtable>
      </m:mfenced>
    </m:mrow>

    </xsl:template>
<!-- when vectors are displayed as block they are displayed vertically -->
  
  <xsl:template match="m:math[@display='block']//m:vector">
    <m:mrow>
      <m:mfenced open="(" close=")">
      <m:mtable>
  <xsl:for-each select="*">
    <m:mtr>
      <m:mtd>

        <xsl:apply-templates select="."/>
      </m:mtd>
    </m:mtr>
  </xsl:for-each>
      </m:mtable>
      </m:mfenced>
    </m:mrow>
  </xsl:template>
 <!-- when vectors are to be displayed inline they are displayed
  horizontally with a superscript T for transpose -->

  <xsl:template match="m:math[@display='inline']//m:vector">
    <m:msup>
      <m:mfenced>
  <xsl:apply-templates select="*"/>
      </m:mfenced>
      <m:mi>T</m:mi>
    </m:msup>
  </xsl:template>

<!-- matrix -->
<xsl:template match="m:matrix">
    <m:mrow>
      <m:mfenced>
  <m:mtable>
    <xsl:apply-templates select="child::*"/>
  </m:mtable>
      </m:mfenced>
    </m:mrow>

</xsl:template>

<xsl:template match="m:matrixrow">
  <m:mtr>
    <xsl:for-each select="child::*">
      <m:mtd>
    <m:mpadded width="+0.3em" lspace="+0.3em">
    <xsl:apply-templates select="."/>
    </m:mpadded>
  </m:mtd>

    </xsl:for-each>
  </m:mtr>
</xsl:template>

<!-- determinant -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='determinant']]">
  <m:mrow>
    <m:mo>det</m:mo>
    <xsl:choose>
    <xsl:when test="m:apply">

      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </m:mrow>
</xsl:template>

<!-- transpose -->

<xsl:template match="m:apply[child::*[position()=1 and local-name()='transpose']]">
  <m:msup>
    <xsl:choose>
    <xsl:when test="m:apply">
      <m:mfenced separators=" "><xsl:apply-templates select="*[position()=2]"/></m:mfenced>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>

    </xsl:choose>
    <m:mo>T</m:mo>
  </m:msup>
</xsl:template>

<!-- selector-->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='selector']]">
  <m:mrow>
  <xsl:choose>
  <xsl:when test="local-name(*[position()=2])='matrix'"> <!-- select in a matrix defined inside the selector -->

    <xsl:choose>
    <xsl:when test="count(*)=4"> <!-- matrix element-->
      <xsl:variable name="i"><xsl:value-of select="*[position()=3]"/></xsl:variable>  <!--extract row-->
      <xsl:variable name="j"><xsl:value-of select="*[position()=4]"/></xsl:variable>  <!--extract column-->
      <xsl:apply-templates select="*[position()=2]/*[position()=number($i)]/*[position()=number($j)]"/>
    </xsl:when>
    <xsl:when test="count(*)=3">  <!-- matrix row -->

      <xsl:variable name="i"><xsl:value-of select="*[position()=3]"/></xsl:variable>  <!--extract row, put it in a matrix container of its own-->
      <m:mtable><xsl:apply-templates select="*[position()=2]/*[position()=number($i)]"/></m:mtable>
    </xsl:when>
    <xsl:otherwise> <!-- no index select the entire thing-->
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>

  <xsl:when test="local-name(*[position()=2])='vector' or local-name(*[position()=2])='list'"> <!-- select in a vector or list defined inside the selector -->
    <xsl:choose>
    <xsl:when test="count(*)=3">  <!-- list/vector element -->
      <xsl:variable name="i"><xsl:value-of select="*[position()=3]"/></xsl:variable>  <!--extract index-->
      <xsl:apply-templates select="*[position()=2]/*[position()=number($i)]"/>
    </xsl:when>
    <xsl:otherwise> <!-- no index select the entire thing-->

      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="local-name(*[position()=2])='apply'"><!--Something more complex than vector or matrix -->
    <xsl:choose>
    <xsl:when test="count(*)=4"> <!-- two indices (matrix element)-->
      <m:msub>

        <m:mfenced open="[" close="]">
          <xsl:apply-templates select="*[position()=2]"/>
        </m:mfenced>
  <m:mrow>
    <xsl:apply-templates select="*[position()=3]"/>
    <!--<m:mo><xsl:text disable-output-escaping="yes">&InvisibleComma;</xsl:text></m:mo>-->  <!-- InvisibleComma does not work -->
    <xsl:apply-templates select="*[position()=4]"/>
  </m:mrow>

      </m:msub>
    </xsl:when>
    <xsl:when test="count(*)=3">  <!-- one index probably list or vector element, or matrix row -->
      <m:msub>
        <m:mfenced open="[" close="]">
         <xsl:apply-templates select="*[position()=2]"/>
        </m:mfenced>
  <xsl:apply-templates select="*[position()=3]"/>

      </m:msub>
    </xsl:when>
    <xsl:otherwise> <!-- no index select the entire thing-->
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>   
  <xsl:otherwise> <!-- select in something defined elsewhere : an identifier is provided-->

    <xsl:choose>
    <xsl:when test="count(*)=4"> <!-- two indices (matrix element)-->
      <m:msub>
        <xsl:apply-templates select="*[position()=2]"/>
  <m:mrow>
    <xsl:apply-templates select="*[position()=3]"/>
    <!--<m:mo><xsl:text disable-output-escaping="yes">&InvisibleComma;</xsl:text></m:mo>-->  <!-- InvisibleComma does not work -->
    <xsl:apply-templates select="*[position()=4]"/>

  </m:mrow>
      </m:msub>
    </xsl:when>
    <xsl:when test="count(*)=3">  <!-- one index probably list or vector element, or matrix row -->
      <m:msub>
        <xsl:apply-templates select="*[position()=2]"/>
  <xsl:apply-templates select="*[position()=3]"/>
      </m:msub>

    </xsl:when>
    <xsl:otherwise> <!-- no index select the entire thing-->
      <xsl:apply-templates select="*[position()=2]"/>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
  </xsl:choose>
  </m:mrow>

</xsl:template>

<!-- vector product = A x B x sin(teta) -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='vectorproduct']]">
<m:mrow>
  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo><xsl:text disable-output-escaping="yes">&#x00D7;</xsl:text></m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- scalar product = A x B x cos(teta) -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='scalarproduct']]">
<m:mrow>

      <m:mo>&lt;</m:mo>
  <xsl:apply-templates select="*[position()=2]"/>
      <m:mo>,</m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
      <m:mo>&gt;</m:mo>
</m:mrow>
</xsl:template>

<!-- outer product = A x B x cos(teta) -->
<xsl:template match="m:apply[child::*[position()=1 and local-name()='outerproduct']]">
<m:mrow>

  <xsl:apply-templates select="*[position()=2]"/>
  <m:mo>.</m:mo>
  <xsl:apply-templates select="*[position()=3]"/>
</m:mrow>
</xsl:template>

<!-- #################### 4.4.11 #################### -->

<!-- annotation-->
<xsl:template match="m:annotation">
<!-- no rendering for annotations-->
</xsl:template>

<!-- semantics-->
<xsl:template match="m:semantics">
<m:mrow>
  <xsl:choose>
    <xsl:when test="contains(m:annotation-xml/@encoding,'MathML-Presentation')"> <!-- if specific representation is provided use it-->
      <xsl:apply-templates select="annotation-xml[contains(@encoding,'MathML-Presentation')]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[position()=1]"/>  <!--if no specific representation is provided use the default one-->

    </xsl:otherwise>
  </xsl:choose>
</m:mrow>
</xsl:template>

<!-- MathML presentation in annotation-xml-->
<xsl:template match="m:annotation-xml[contains(@encoding,'MathML-Presentation')]">
<m:mrow>
  <xsl:copy-of select="*"/>
</m:mrow>
</xsl:template>

<!-- #################### 4.4.12 #################### -->
<!-- integer numbers -->

<xsl:template match="m:integers">
  <m:mi mathvariant="double-struck"><xsl:text disable-output-escaping='yes'>&amp;#x2124;</xsl:text></m:mi>  <!-- open face Z --> <!-- UNICODE char works -->
</xsl:template>

<!-- real numbers -->
<xsl:template match="m:reals">
  <m:mi mathvariant="double-struck"><xsl:text
  disable-output-escaping='yes'>&amp;#x211D;</xsl:text></m:mi>  <!-- open face R --> <!-- UNICODE char works -->
</xsl:template>

<!-- rational numbers -->
<xsl:template match="m:rationals">
  <m:mi mathvariant="double-struck"><xsl:text disable-output-escaping='yes'>&amp;#x211A;</xsl:text></m:mi>  <!-- open face Q --> <!-- UNICODE char works -->
</xsl:template>

<!-- natural numbers -->
<xsl:template match="m:naturalnumbers">
  <m:mi mathvariant="double-struck"><xsl:text disable-output-escaping='yes'>&amp;#x2115;</xsl:text></m:mi>  <!-- open face N --> <!-- UNICODE char works -->
</xsl:template>

<!-- complex numbers -->
<xsl:template match="m:complexes">
  <m:mi mathvariant="double-struck"><xsl:text disable-output-escaping='yes'>&amp;#x2102;</xsl:text></m:mi>  <!-- open face C --> <!-- UNICODE char works -->
</xsl:template>

<!-- prime numbers -->
<xsl:template match="m:primes">
  <m:mi mathvariant="double-struck"><xsl:text disable-output-escaping='yes'>&amp;#x2119;</xsl:text></m:mi>  <!-- open face P --> <!-- UNICODE char works -->

</xsl:template>

<!-- exponential base -->
<xsl:template match="m:exponentiale">
  <m:mi><xsl:text disable-output-escaping="yes">&#x2147;</xsl:text></m:mi>  <!-- ExponentialE does not work yet -->
</xsl:template>

<!-- square root of -1 -->
<xsl:template match="m:imaginaryi">
    <m:mi><xsl:value-of select="$imaginaryi"/></m:mi>  <!-- or perhaps ii -->
</xsl:template>

<!-- result of an ill-defined floating point operation -->

<xsl:template match="m:notanumber">
  <m:mi>NaN</m:mi>  
</xsl:template>

<!-- logical constant for truth -->
<xsl:template match="m:true">
  <m:mi>true</m:mi>  
</xsl:template>

<!-- logical constant for falsehood -->
<xsl:template match="m:false">
  <m:mi>false</m:mi>   

</xsl:template>

<!-- empty set -->
<xsl:template match="m:emptyset">
  <m:mi><xsl:text disable-output-escaping="yes">&#xEEFB;</xsl:text></m:mi>
</xsl:template>

<!-- ratio of a circle's circumference to its diameter -->
<xsl:template match="m:pi">
  <m:mi><xsl:text disable-output-escaping="yes">&#x03C0;</xsl:text></m:mi>
</xsl:template>

<!-- Euler's constant -->
<xsl:template match="m:eulergamma">
  <m:mi><xsl:text disable-output-escaping="yes">&#x03B3;</xsl:text></m:mi>

</xsl:template>

<!-- Infinity -->
<xsl:template match="m:infinity">
  <m:mi><xsl:text disable-output-escaping="yes">&#x221E;</xsl:text></m:mi>
</xsl:template>
</xsl:stylesheet>
