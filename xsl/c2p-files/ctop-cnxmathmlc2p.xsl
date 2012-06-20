<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://cnx.rice.edu/technology/mathml/schema/dtd/2.0/moz-mathml.ent">
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://www.w3.org/1998/Math/MathML" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns="http://www.w3.org/1999/xhtml" version="1.0"> 
 
 
  <!-- Import mathmlc2p to minimize space required by new material --> 
  <xsl:import href="ctop.xsl"/> 
 
  <!--  This file contains changes to the content to presentation mathml --> 
  <!--  stylesheet. --> 
  
  <!--  Created 2001-02-01.  --> 
 
  <!-- paramaters --> 
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
 
  <!--This is the template for math.--> 
  <xsl:template mode="phil-unused" match="m:math"> 
    <m:math> 
      <xsl:choose> 
    <!-- Otherwise, explicitly set equations to mode 'display' --> 
    <xsl:when test="parent::*[local-name()='equation']"> 
      <xsl:attribute name="display">block</xsl:attribute> 
    </xsl:when> 
    <xsl:when test="@display"> 
      <xsl:attribute name="display"><xsl:value-of select="@display"/></xsl:attribute> 
    </xsl:when> 
    <xsl:otherwise> 
      <xsl:attribute name="display">inline</xsl:attribute> 
    </xsl:otherwise> 
      </xsl:choose> 
      <m:semantics> 
    <m:mrow> 
      <xsl:apply-templates/> 
    </m:mrow> 
    <m:annotation-xml encoding="MathML-Content"> 
      <xsl:copy-of select="child::*"/> 
    </m:annotation-xml> 
      </m:semantics> 
    </m:math> 
  </xsl:template> 
  
  <!-- New equal for equation --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='eq'] and parent::*[parent::*[local-name()='equation']]]"> 
    <xsl:choose> 
      <xsl:when test="count(child::*)&gt;3"> 
    <m:mtable align="center" columnalign="right center left"> 
      <m:mtr> 
        <m:mtd columnalign="right"> 
          <m:mrow><xsl:apply-templates select="child::*[position()=2]"/></m:mrow> 
        </m:mtd> 
        <m:mtd columnalign="center"><m:mo>=</m:mo></m:mtd> 
        <m:mtd columnalign="left"> 
          <m:mrow><xsl:apply-templates select="child::*[position()=3]"/></m:mrow> 
        </m:mtd> 
      </m:mtr> 
      <xsl:for-each select="child::*[position()&gt;3]"> 
        <m:mtr> 
          <m:mtd columnalign="right"/> 
          <m:mtd columnalign="center"><m:mo>=</m:mo></m:mtd> 
          <m:mtd columnalign="left"> 
        <m:mrow><xsl:apply-templates select="."/></m:mrow> 
          </m:mtd> 
        </m:mtr> 
      </xsl:for-each> 
    </m:mtable> 
      </xsl:when> 
      <xsl:otherwise> 
    <m:mrow><xsl:apply-templates select="child::*[position()=2]"/></m:mrow> 
        <m:mrow><m:mo>=</m:mo></m:mrow> 
        <m:mrow><xsl:apply-templates select="child::*[position()=last()]"/></m:mrow> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Places the power of a function or a trig function in the middle
  of it --> 
  
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='power']]"> 
    <xsl:choose> 
      <!-- checks to see if it is a function then formats --> 
      
      <xsl:when test="child::*[position()=2 and child::*[local-name()='ci' and @type='fn']]"> 
    <m:mrow> 
      <m:msup> 
        <xsl:apply-templates select="child::*/child::*[local-name()='ci' and @type='fn']"/> 
        <xsl:apply-templates select="child::*[position()=3]"/> 
      </m:msup> 
      <m:mfenced> 
        <xsl:if test="child::*[position()=2 and child::*[local-name()='ci' and @class='discrete']]"> 
          <xsl:attribute name="open">[</xsl:attribute> 
          <xsl:attribute name="close">]</xsl:attribute> 
        </xsl:if> 
        <xsl:apply-templates select="child::*/child::*[position()!=1]"/> 
      </m:mfenced> 
    </m:mrow> 
      </xsl:when> 
      <!-- puts the exponent of a sin function between the sin and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='sin']]"> 
    <m:msup> 
      <m:mi>sin</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a cos function between the cos and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='cos']]"> 
    <m:msup> 
      <m:mi>cos</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a tan function between the tan and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='tan']]"> 
    <m:msup> 
      <m:mi>tan</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a sec function between the sec and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='sec']]"> 
    <m:msup> 
      <m:mi>sec</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a sec function between the csc and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='csc']]"> 
    <m:msup> 
      <m:mi>csc</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a cot function between the cot and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='cot']]"> 
    <m:msup> 
      <m:mi>cot</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a sinh function between the sinh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='sinh']]"> 
    <m:msup> 
      <m:mi>sinh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a cosh function between the cosh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='cosh']]"> 
    <m:msup> 
      <m:mi>cosh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a tanh function between the tanh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='tanh']]"> 
    <m:msup> 
      <m:mi>tanh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a sech function between the sech and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='sech']]"> 
    <m:msup> 
      <m:mi>sech</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a csch function between the csch and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='csch']]"> 
    <m:msup> 
      <m:mi>csch</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of a coth function between the coth and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='coth']]"> 
    <m:msup> 
      <m:mi>coth</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arcsin function between the arcsin and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arcsin']]"> 
    <m:msup> 
      <m:mi>arcsin</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccos function between the arccos and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccos']]"> 
    <m:msup> 
      <m:mi>arccos</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arctan function between the arctan and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arctan']]"> 
    <m:msup> 
      <m:mi>arctan</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccosh function between the arccosh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccosh']]"> 
    <m:msup> 
      <m:mi>arccosh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccot function between the arccot and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccot']]"> 
    <m:msup> 
      <m:mi>arccot</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccoth function between the arccoth and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccoth']]"> 
    <m:msup> 
      <m:mi>arccoth</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccsc function between the arccsc and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccsc']]"> 
    <m:msup> 
      <m:mi>arccsc</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arccsch function between the arccsch and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arccsch']]"> 
    <m:msup> 
      <m:mi>arccsch</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arcsec function between the arcsec and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arcsec']]"> 
    <m:msup> 
      <m:mi>arcsec</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arcsech function between the arcsech and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arcsech']]"> 
    <m:msup> 
      <m:mi>arcsech</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arcsinh function between the arcsinh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arcsinh']]"> 
    <m:msup> 
      <m:mi>arcsinh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- puts the exponent of an arctanh function between the arctanh and the
      rest --> 
      <xsl:when test="m:apply[child::*[position()=1 and         local-name()='arctanh']]"> 
    <m:msup> 
      <m:mi>arctanh</m:mi> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
    <m:mfenced separators=" "> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
      <!-- for normal power applications --> 
      <xsl:when test="local-name(*[position()=2])='apply'"> 
    <m:msup> 
      <m:mfenced separators=" "> 
        <xsl:apply-templates select="child::*[position()=2]"/></m:mfenced> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
      </xsl:when> 
      <xsl:otherwise> 
    <m:msup> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:msup> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- places the -1 of a inverted function or trig function in the --> 
  <!-- middle of the function --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='inverse']]"> 
    <xsl:choose> 
      <xsl:when test="descendant::*[position()=3 and @type='fn']"> 
    <m:msup> 
      <xsl:apply-templates select="descendant::*[position()=3]"/> 
      <m:mo>-1</m:mo> 
    </m:msup> 
    <m:mfenced> 
      <xsl:apply-templates select="descendant::*[position()=4]"/> 
    </m:mfenced> 
      </xsl:when> 
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
 
  
  <!-- csymbol stuff: Connexions MathML extensions --> 
 
  <!-- Combination --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='csymbol' and @definitionURL='http://www.openmath.org/cd/combinat1.ocd']]"> 
    <m:mrow> 
      
      <m:mfenced> 
    <m:mtable> 
      <m:mtr> 
        <m:mtd> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
        </m:mtd> 
      </m:mtr> 
      <m:mtr> 
        <m:mtd> 
          <xsl:apply-templates select="child::*[position()=3]"/> 
        </m:mtd> 
      </m:mtr> 
    </m:mtable> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- Probability --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#probability']]"> 
    <xsl:choose> 
      <xsl:when test="m:condition"> 
    <m:mrow>  
      <m:mi><xsl:text disable-output-escaping="yes">Pr</xsl:text></m:mi> 
      <m:mfenced open="[" close="]" separators=" "> 
          <m:mfenced open=" " close=" "> 
         <xsl:apply-templates select="*[local-name()!='condition' and local-name()!='csymbol']"/> 
        </m:mfenced> 
        <m:mspace width=".3em"/> 
        <m:mo>|</m:mo> 
        <m:mspace width=".3em"/> 
        <xsl:apply-templates select="m:condition"/> 
      </m:mfenced> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <m:mrow> 
      <m:mi><xsl:text disable-output-escaping="yes">Pr</xsl:text></m:mi> 
      <m:mfenced open="[" close="]"> 
        <xsl:apply-templates select="*[local-name()!='csymbol']"/> 
      </m:mfenced> 
    </m:mrow> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Complement --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and     local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#complement']]"> 
    <xsl:choose> 
      <xsl:when test="$complementnotation='overbar'"> 
    <m:mover> 
       <xsl:choose> 
        <xsl:when test="local-name(*[position()=2])='apply'"> 
          <m:mfenced separators=" "> 
        <xsl:apply-templates select="child::*[position()=2]"/> 
          </m:mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
        </xsl:otherwise> 
      </xsl:choose> 
      <m:mo>&#xAF;</m:mo> 
    </m:mover> 
      </xsl:when> 
      <xsl:otherwise> 
    <m:msup> 
      <xsl:choose> 
        <xsl:when test="local-name(*[position()=2])='apply'"> 
          <m:mfenced separators=" "> 
        <xsl:apply-templates select="child::*[position()=2]"/> 
          </m:mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
        </xsl:otherwise> 
      </xsl:choose> 
      <m:mo>&#x2032;</m:mo> 
    </m:msup> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Expected value --> 
  
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and     local-name()='csymbol' and     @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#expectedvalue']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:bvar"> 
      <m:msub> 
        <m:mi><xsl:text disable-output-escaping="yes">E</xsl:text></m:mi> 
        <xsl:apply-templates select="child::*[local-name()='bvar']"/> 
      </m:msub> 
      <m:mfenced open="[" close="]" seperators=" "> 
        <m:mrow> 
          <xsl:apply-templates select="child::*[local-name()!='condition' and position()=last()]"/> 
          <xsl:if test="m:condition"> 
        <m:mrow> 
          <m:mspace width=".1em"/> 
          <m:mo>|</m:mo> 
          <m:mspace width=".1em"/> 
          <m:mfenced open=" " close=" "> 
          <xsl:apply-templates select="child::*[local-name()='condition']"/> 
          </m:mfenced> 
        </m:mrow> 
          </xsl:if> 
        </m:mrow> 
      </m:mfenced> 
    </xsl:when> 
    <xsl:otherwise>   
      <m:mi><xsl:text disable-output-escaping="yes">E</xsl:text></m:mi> 
      <m:mfenced open="[" close="]" seperators=" "> 
        <m:mrow> 
          <xsl:apply-templates select="child::*[local-name()!='condition' and position()=last()]"/> 
          <xsl:if test="m:condition"> 
        <m:mrow> 
          <m:mspace width=".1em"/> 
          <m:mo>|</m:mo> 
          <m:mspace width=".1em"/> 
          <m:mfenced open=" " close=" "> 
          <xsl:apply-templates select="child::*[local-name()='condition']"/> 
          </m:mfenced> 
        </m:mrow> 
          </xsl:if> 
        </m:mrow> 
      </m:mfenced> 
    </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- Estimate --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#estimate']]"> 
    <xsl:choose> 
      <xsl:when test="child::*[position()=2 and local-name()='ci' and child::*[local-name()='msub']]"> 
    <m:msub> 
      <m:mover> 
        <xsl:apply-templates select="m:ci/m:msub/*[1]"/> 
        <m:mo>&#x302;</m:mo> 
      </m:mover> 
      <m:mrow> 
        <xsl:apply-templates select="m:ci/m:msub/*[2]"/> 
      </m:mrow> 
    </m:msub> 
      </xsl:when> 
      <xsl:otherwise> 
    <m:mover> 
      <m:mrow><xsl:apply-templates/></m:mrow> 
      <m:mo>&#x302;</m:mo> 
    </m:mover> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
 <!--PDF (Probability Density Function)--> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and     @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#pdf']]"> 
    <m:mrow> 
      <m:mrow> 
    <xsl:choose> 
      <xsl:when test="m:bvar"> 
        <m:msub> 
          <m:mrow><xsl:apply-templates select="child::*[local-name()='csymbol']"/></m:mrow> 
          <m:mfenced open="" close=""> 
        <m:mrow> 
          <m:mfenced open=" " close=" "> 
            <xsl:apply-templates select="child::*[local-name()='bvar']"/> 
          </m:mfenced> 
          <xsl:if test="m:condition"> 
            <m:mrow> 
              <m:mspace width=".1em"/> 
              <m:mo>|</m:mo> 
              <m:mspace width=".1em"/> 
              <xsl:apply-templates select="child::*[local-name()='condition']"/> 
            </m:mrow> 
          </xsl:if> 
        </m:mrow> 
          </m:mfenced> 
        </m:msub> 
      </xsl:when> 
      <xsl:otherwise> 
        <m:mrow><xsl:apply-templates select="child::*[local-name()='csymbol']"/></m:mrow> 
      </xsl:otherwise> 
    </xsl:choose> 
      </m:mrow> 
      <m:mfenced> 
    <m:mrow> 
      <m:mfenced open=" " close=" "> 
        <xsl:apply-templates select="child::*[not(local-name()='condition' or local-name()='csymbol' or local-name()='bvar')]"/> 
      </m:mfenced> 
      <xsl:if test="m:condition and not(m:bvar)"> 
        <m:mrow> 
          <m:mspace width=".1em"/> 
          <m:mo>|</m:mo> 
          <m:mspace width=".1em"/> 
          <xsl:apply-templates select="child::*[local-name()='condition']"/> 
        </m:mrow> 
      </xsl:if> 
    </m:mrow> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
<!-- CDF (Cumulative Distribution Function) --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and     @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#cdf']]"> 
    <m:mrow> 
      <m:mrow> 
    <xsl:choose> 
      <xsl:when test="m:bvar"> 
        <m:msub> 
          <m:mrow><xsl:apply-templates select="child::*[local-name()='csymbol']"/></m:mrow> 
          <m:mfenced open="" close=""> 
        <m:mrow> 
          <m:mfenced open=" " close=" "> 
            <xsl:apply-templates select="child::*[local-name()='bvar']"/> 
          </m:mfenced> 
          <xsl:if test="m:condition"> 
            <m:mrow> 
              <m:mspace width=".1em"/> 
              <m:mo>|</m:mo> 
              <m:mspace width=".1em"/> 
              <xsl:apply-templates select="child::*[local-name()='condition']"/> 
            </m:mrow> 
          </xsl:if> 
        </m:mrow> 
          </m:mfenced> 
        </m:msub> 
      </xsl:when> 
      <xsl:otherwise> 
        <m:mrow><xsl:apply-templates select="child::*[local-name()='csymbol']"/></m:mrow> 
      </xsl:otherwise> 
    </xsl:choose> 
      </m:mrow> 
      <m:mfenced> 
    <m:mrow> 
      <m:mfenced open=" " close=" "> 
        <xsl:apply-templates select="child::*[not(local-name()='condition' or local-name()='csymbol' or local-name()='bvar')]"/> 
      </m:mfenced> 
       <xsl:if test="m:condition and not(m:bvar)"> 
        <m:mrow> 
          <m:mspace width=".1em"/> 
          <m:mo>|</m:mo> 
          <m:mspace width=".1em"/> 
          <xsl:apply-templates select="child::*[local-name()='condition']"/> 
        </m:mrow> 
      </xsl:if> 
    </m:mrow> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
  
<!-- Normal Distribution --> 
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#normaldistribution']]"> 
    <m:mrow> 
      <m:mi>&#xEF3B;</m:mi> 
      <m:mfenced> 
    <xsl:apply-templates select="child::*[position()=2 or position()=3]"/> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
<!-- Distributed In --> 
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#distributedin']]"> 
    <m:mrow> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <m:mo>&#x223C;</m:mo> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:mrow> 
  </xsl:template> 
 
<!-- Distance --> 
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#distance']]"> 
    <m:mrow> 
      <m:mi>&#xEF37;</m:mi> 
      <m:mfenced> 
    <m:mrow> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <m:mo>&#x2225;</m:mo> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:mrow> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
<!-- Mutual Information --> 
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and   local-name()='csymbol' and   @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#mutualinformation']]"> 
    <m:mrow> 
      <m:mi>&#x2110;</m:mi> 
      <m:mfenced> 
    <m:mrow> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <m:mo>;</m:mo> 
      <xsl:apply-templates select="child::*[position()=3]"/> 
    </m:mrow> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
 <!-- Peicewise Stochastic Process --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and     local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#stochastic']]"> 
   <m:mrow> 
      <xsl:element name="m:mfenced" namespace="http://www.w3.org/1998/Math/MathML"> 
    <xsl:attribute name="open">{</xsl:attribute> 
    <xsl:attribute name="close"/> 
    <m:mtable> 
      <xsl:for-each select="m:apply[child::*[position()=1 and         local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#stochasticpiece']]"> 
        <m:mtr><m:mtd> 
        <xsl:apply-templates select="*[position()=2]"/> 
        <m:mspace width="0.3em"/><m:mtext>Prob</m:mtext><m:mspace width="0.3em"/> 
        <xsl:apply-templates select="*[position()=3]"/> 
          </m:mtd></m:mtr> 
      </xsl:for-each> 
    </m:mtable> 
      </xsl:element> 
    </m:mrow> 
  </xsl:template>  
 
  <!-- Vector Derivative --> 
  
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='diff' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#vectorderivative']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:degree"> 
      <m:msubsup> 
        <m:mi>&#x2207;</m:mi> 
        <xsl:apply-templates select="m:bvar"/> 
        <xsl:apply-templates select="m:degree"/> 
      </m:msubsup> 
    </xsl:when> 
    <xsl:otherwise> 
      <m:msub> 
        <m:mi>&#x2207;</m:mi> 
        <xsl:apply-templates select="m:bvar"/> 
      </m:msub> 
    </xsl:otherwise> 
      </xsl:choose> 
      <m:mfenced> 
    <xsl:apply-templates select="*[position()=last()]"/> 
      </m:mfenced> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- infimum --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and     local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#infimum']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:bvar"> <!-- if there are bvars--> 
      <m:msub> 
        <m:mi>inf</m:mi> 
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
      <m:mo>inf</m:mo> 
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
 
  
 
  
    
  <!-- Horizontally Partitioned Matrix --> 
  <!-- FIXME: not in use till futher discussion--> 
 
  <!--
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and
  local-name()='csymbol' and
  @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#partitionedmatrix'
  and @type='horizontal']]">
<mrow>
<mfenced separators=" ">
<mtable>
<xsl:apply-templates select="child::*[position()=2]"/>
</mtable>
<mo>|</mo>
<mtable>
<xsl:apply-templates select="child::*[position()=3]"/>
</mtable>
</mfenced>
</mrow>
</xsl:template>
  --> 
 
  <!-- Vertically Partitioned Matrix --> 
  <!-- FIXME: not in use till futher discussion--> 
  <!-- FIXME: Doesn't work --> 
 
  <!--
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and
  local-name()='csymbol' and
  @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#partitionedmatrix'
  and @type='vertical']]">
<mrow>
<mfenced>
<mtable>
<mtr>
<mtd>
<mtable>
<xsl:apply-templates select="child::*[position()=2]"/>
</mtable>
</mtd>
</mtr>
<mtr>
<mtd>
  &HorizontalLine;
</mtd>
</mtr>
<mtr>
<mtd>
<mtable>
<xsl:apply-templates select="child::*[position()=3]"/>
</mtable>
</mtd>
</mtr>
</mtable>
</mfenced>
</mrow>
</xsl:template> 
  --> 
 
  <!-- Quad Partitioned Matrix --> 
  <!-- FIXME: not in use till futher discussion--> 
  <!-- FIXME: Doesn't work --> 
 
  <!--
<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#partitionedmatrix' and @type='quad']]">
  
<mrow>
<mfenced separators=" ">
<mfrac>
<mtable>
<xsl:apply-templates select="child::*[position()=2]"/>
</mtable>
<mtable>
<xsl:apply-templates select="child::*[position()=3]"/>
</mtable>
</mfrac>
<mo>|</mo>
<mfrac>
<mtable>
<xsl:apply-templates select="child::*[position()=4]"/>
</mtable>
<mtable>
<xsl:apply-templates select="child::*[position()=5]"/>
</mtable>
</mfrac>
</mfenced>
</mrow>
</xsl:template>
  --> 
 
  <!--<xsl:template mode="c2p" match="m:apply[child::*[position()=1 and
  local-name()='csymbol' and
  @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#partition']]">
<xsl:apply-templates select="*"/>
</xsl:template>
  --> 
 
 
  <!-- Convolution --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#convolve']]"> 
    <xsl:choose> 
      <xsl:when test="count(child::*)&gt;=3"> 
    <m:mrow> 
      <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
        <xsl:choose> 
          <xsl:when test="m:plus"> <!--add brackets around + children for priority purpose--> 
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
          </xsl:when> 
          <xsl:when test="m:minus"> <!--add brackets around - children for priority purpose--> 
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
          </xsl:when> 
          <!-- if some csymbol is used put parentheses around it --> 
          <xsl:when test="m:csymbol"> <!--add brackets around - children for priority purpose--> 
        <m:mfenced separators=" "><xsl:apply-templates select="."/></m:mfenced><m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
          </xsl:when> 
          <xsl:otherwise> 
        <xsl:apply-templates select="."/><m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
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
          <!-- if some csymbol is used put parentheses around it --> 
          <xsl:when test="m:csymbol"> 
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
      <m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
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
    <m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Adjoint --> 
  <!-- FIXME: the notation here really needs to be customizable --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='csymbol' and         @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#adjoint']]"> 
    <m:msup accent="true"> 
      <xsl:choose> 
    <xsl:when test="child::m:apply"> 
      <m:mfenced><m:mrow><xsl:apply-templates select="*[position()=2]"/></m:mrow></m:mfenced> 
    </xsl:when> 
    <xsl:otherwise> 
      <m:mrow><xsl:apply-templates select="*[position()=2]"/></m:mrow> 
    </xsl:otherwise> 
      </xsl:choose> 
      <m:mo>H</m:mo> 
    </m:msup> 
  </xsl:template> 
  
 <!-- norm --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='csymbol' and         @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#norm']]"> 
    <xsl:choose> 
      <xsl:when test="m:domainofapplication"> 
    <m:mrow> 
      <m:msub> 
        <m:mrow> 
          <m:mo>&#x2225;</m:mo> 
          <xsl:apply-templates select="child::*[position()=3]"/> 
          <m:mo>&#x2225;</m:mo> 
        </m:mrow> 
        <m:mrow> 
          <xsl:apply-templates select="*[position()=2 and           local-name()='domainofapplication']"/> 
        </m:mrow> 
      </m:msub> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise>       
    <m:mrow> 
      <m:mo>&#x2225;</m:mo> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <m:mo>&#x2225;</m:mo> 
    </m:mrow> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Evaluated At --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#evaluateat']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:condition"> <!-- evaluation expressed by a condition--> 
      <xsl:apply-templates select="*[position()=last()]"/> 
      <xsl:choose> 
        <xsl:when test="m:bvar"> 
          <m:msub> 
        <m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo> 
        <m:mrow> 
          <xsl:apply-templates select="m:bvar"/> 
          <m:mo><xsl:text disable-output-escaping="yes">,</xsl:text></m:mo> 
          <xsl:apply-templates select="m:bvar"/> 
          <m:mo><xsl:text disable-output-escaping="yes">=</xsl:text></m:mo> 
          <xsl:apply-templates select="m:condition"/> 
        </m:mrow> 
          </m:msub> 
        </xsl:when> 
        <xsl:otherwise> 
          <m:msub> 
        <m:mrow><m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo></m:mrow> 
        <m:mrow> 
              <xsl:for-each select="m:condition[position()!=last()]"><xsl:apply-templates/><m:mo>,</m:mo></xsl:for-each> 
              <xsl:for-each select="m:condition[position()=last()]"><xsl:apply-templates/></xsl:for-each> 
            </m:mrow> 
          </m:msub> 
        </xsl:otherwise> 
      </xsl:choose> 
    </xsl:when> 
    <xsl:otherwise> 
      <xsl:choose> 
        <xsl:when test="m:interval"> <!-- evaluation expressed by an interval--> 
          <xsl:apply-templates select="*[position()=last()]"/> 
          <xsl:choose> 
        <xsl:when test="m:bvar"> 
          <m:msubsup> 
            <m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo> 
            <m:mrow> 
              <xsl:apply-templates select="m:bvar"/> 
              <m:mo><xsl:text disable-output-escaping="yes">=</xsl:text></m:mo> 
              <xsl:apply-templates select="m:interval/*[position()=1]"/> 
            </m:mrow> 
            <xsl:apply-templates select="m:interval/*[position()=2]"/> 
          </m:msubsup> 
        </xsl:when> 
        <xsl:otherwise> 
          <m:msubsup> 
            <m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo> 
            <xsl:apply-templates select="m:interval/*[position()=1]"/> 
            <xsl:apply-templates select="m:interval/*[position()=2]"/> 
          </m:msubsup> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:when> 
        <xsl:when test="m:lowlimit"> <!-- evaluation domain expressed by lower and upper limits--> 
          <xsl:apply-templates select="*[position()=last()]"/> 
          <xsl:choose> 
        <xsl:when test="m:bvar"> 
          <m:msubsup>       
            <m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo> 
            <m:mrow> 
              <xsl:apply-templates select="m:bvar"/> 
              <m:mo><xsl:text disable-output-escaping="yes">=</xsl:text></m:mo> 
              <xsl:apply-templates select="m:lowlimit"/> 
            </m:mrow> 
            <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow> 
          </m:msubsup> 
        </xsl:when> 
        <xsl:otherwise> 
          <m:msubsup> 
            <m:mo><xsl:text disable-output-escaping="yes">|</xsl:text></m:mo> 
            <xsl:apply-templates select="m:lowlimit"/> 
            <xsl:apply-templates select="m:uplimit"/> 
          </m:msubsup> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:when> 
      </xsl:choose>     
    </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- Surface Integral --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#surfaceintegral']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:condition"> <!-- surface integration domain expressed by a condition--> 
      <m:munder> 
        <m:mo><xsl:text disable-output-escaping="yes">&#x222E;</xsl:text></m:mo> 
        <xsl:apply-templates select="m:condition"/> 
      </m:munder> 
      <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      <m:mrow><mo>d<!--DifferentialD does not work--></mo><xsl:apply-templates select="m:bvar"/></m:mrow> 
    </xsl:when> 
    <xsl:when test="m:domainofapplication"> <!-- surface integration domain expressed by a domain of application--> 
      <m:munder> 
        <m:mo><xsl:text disable-output-escaping="yes">&#x222E;</xsl:text></m:mo> 
        <xsl:apply-templates select="m:domainofapplication"/> 
      </m:munder> 
      <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow>  <!--not sure about this line: can get rid of it if there is never a bvar elem when integ domain specified by domainofapplication--> 
    </xsl:when> 
    <xsl:when test="m:lowlimit"><!-- surface integration expressed
      by lowlimit and uplimit --> 
      <m:munderover>       
        <m:mo><xsl:text disable-output-escaping="yes">&#x222E;</xsl:text></m:mo> 
        <m:mrow><xsl:apply-templates select="m:lowlimit"/></m:mrow> 
        <m:mrow><xsl:apply-templates select="m:uplimit"/></m:mrow> 
      </m:munderover> 
      <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      <m:mrow><m:mo>d<!--DifferentialD does not work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow> 
    </xsl:when> 
    <xsl:otherwise><!-- surface integral with no condition --> 
      <m:mo><xsl:text disable-output-escaping="yes">&#x222E;</xsl:text></m:mo> 
      <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      <m:mrow><m:mo>d<!--DifferentialD does not
          work--></m:mo><xsl:apply-templates select="m:bvar"/></m:mrow> 
    </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
  </xsl:template> 
  
  <!-- arg min --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#argmin']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:condition"> <!-- arg min domain expressed by
      a condition--> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:munder> 
          <m:mo><xsl:text disable-output-escaping="yes">min</xsl:text></m:mo> 
          <xsl:apply-templates select="m:condition"/> 
        </m:munder> 
      </m:mrow> 
      <m:mrow><xsl:apply-templates select="*[position()=3]"/></m:mrow> 
    </xsl:when> 
    <xsl:when test="m:domainofapplication"> <!-- arg min domain
      expressed with domain of application--> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:munder> 
          <m:mo><xsl:text disable-output-escaping="yes">min</xsl:text></m:mo> 
          <xsl:apply-templates select="m:domainofapplication"/> 
        </m:munder> 
      </m:mrow> 
      <m:mrow><xsl:apply-templates select="*[position()=3]"/></m:mrow> 
    </xsl:when> 
    <xsl:otherwise><!--condition with no condition --> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:mo><xsl:text disable-output-escaping="yes">min</xsl:text></m:mo> 
        <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      </m:mrow> 
    </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- arg max --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='csymbol' and @definitionURL='http://cnx.rice.edu/cd/cnxmath.ocd#argmax']]"> 
    <m:mrow> 
      <xsl:choose> 
    <xsl:when test="m:condition"> <!-- arg max domain expressed by
      a condition--> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:munder> 
          <m:mo><xsl:text disable-output-escaping="yes">max</xsl:text></m:mo> 
          <xsl:apply-templates select="m:condition"/> 
        </m:munder> 
      </m:mrow> 
      <m:mrow><xsl:apply-templates select="*[position()=3]"/></m:mrow> 
    </xsl:when> 
    <xsl:when test="m:domainofapplication"> <!-- arg max domain
      expressed with domain of application--> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:munder> 
          <m:mo><xsl:text disable-output-escaping="yes">max</xsl:text></m:mo> 
          <xsl:apply-templates select="m:domainofapplication"/> 
        </m:munder> 
      </m:mrow> 
      <m:mrow><xsl:apply-templates select="*[position()=3]"/></m:mrow> 
    </xsl:when> 
    <xsl:otherwise><!-- arg max with no condition --> 
      <m:mrow> 
        <xsl:text disable-output-escaping="yes">arg</xsl:text> 
        <m:mo><xsl:text disable-output-escaping="yes">max</xsl:text></m:mo> 
        <m:mrow><xsl:apply-templates select="*[position()=last()]"/></m:mrow> 
      </m:mrow> 
    </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
  </xsl:template> 
 
  <!-- Presentation Changes --> 
 
  <!-- apply/apply/diff formatting change-->    
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='apply' and child::*[position()=1 and         local-name()='diff'] ]]"> 
    <xsl:choose> 
      <xsl:when test="count(child::*)&gt;=2"> 
    <m:mrow> 
      <xsl:apply-templates select="child::*[position()=1]"/> 
      <m:mfenced><xsl:apply-templates select="child::*[position()!=1]"/></m:mfenced> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise><!-- apply only contains apply, no operand
    --> 
    <m:mfenced separators=" "><xsl:apply-templates select="child::*"/></m:mfenced> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
 
  <!--apply/forall formatting change with parameter --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='forall']]"> 
    <xsl:choose> 
      <xsl:when test="$forallequation"> 
    <m:mrow> 
      <xsl:apply-templates select="child::*[local-name()='ci' or local-name()='apply'or local-name()='cn' or local-name()='mo']"/> 
      <m:mo><xsl:text disable-output-escaping="yes">&#xA0;&#xA0;</xsl:text></m:mo> 
      <xsl:if test="child::*[local-name()='condition']"> 
        <m:mo><xsl:text disable-output-escaping="yes">,</xsl:text></m:mo> 
        <m:mo><xsl:text disable-output-escaping="yes">&#xA0;&#xA0;</xsl:text></m:mo> 
        <xsl:for-each select="child::*[local-name()='condition']">  
          <xsl:apply-templates/> 
          <m:mo><xsl:text disable-output-escaping="yes">&#xA0;&#xA0;</xsl:text></m:mo> 
        </xsl:for-each> 
      </xsl:if> 
    </m:mrow> 
      </xsl:when>  
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
      
            
  <!-- Parameters --> 
 
  <!-- Mean Notation choice --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and local-name()='mean']]"> 
    <xsl:choose> 
      <xsl:when test="$meannotation='anglebracket'"><!--use angle
    notation --> 
    <xsl:choose> 
      <xsl:when test="count(*)&gt;2"> 
        <mo><xsl:text disable-output-escaping="yes">&#x2329;</xsl:text></mo> 
        <xsl:for-each select="*[position()!=1 and position()!=last()]"> 
          <xsl:apply-templates select="."/><mo>,</mo> 
        </xsl:for-each> 
        <xsl:apply-templates select="*[position()=last()]"/> 
        <mo><xsl:text disable-output-escaping="yes">&#x232A;</xsl:text></mo> 
      </xsl:when> 
      <xsl:otherwise> 
        <mo><xsl:text disable-output-escaping="yes">&#x2329;</xsl:text></mo> 
          <xsl:apply-templates select="*[position()=last()]"/> 
        <mo><xsl:text disable-output-escaping="yes">&#x232A;</xsl:text></mo> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
        
  <!-- Vector notation choice --> 
 
  <xsl:template mode="c2p" match="m:ci[@type='vector']"> 
    <xsl:choose> 
 
      <xsl:when test="$vectornotation='overbar'"> 
    <!--vector with overbar --> 
    <xsl:choose> 
      <xsl:when test="count(node()) != count(text())"> 
        <!--test if children are not all text nodes, meaning there
        is markup assumed to be presentation markup--> 
        <xsl:choose> 
          <xsl:when test="child::*[position()=1 and             local-name()='msub']"><!-- test to see if the first
        child is msub so that the subscript will not be bolded --> 
        <m:msub> 
          <m:mover><m:mi><xsl:apply-templates select="./m:msub/child::*[position()=1]"/></m:mi><m:mo>&#x2212;</m:mo></m:mover> 
          <m:mrow><xsl:apply-templates select="./m:msub/child::*[position()=2]"/></m:mrow> 
        </m:msub> 
          </xsl:when> 
          <xsl:otherwise> 
        <m:mrow><xsl:copy-of select="child::*"/></m:mrow> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:when> 
      <xsl:otherwise>  <!-- common case --> 
        <m:mover><m:mi><xsl:value-of select="text()"/></m:mi><m:mo>&#x2212;</m:mo></m:mover> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
 
      <xsl:when test="$vectornotation='rightarrow'"> 
    <!--vector with rightarrow over --> 
    <xsl:choose> 
      <xsl:when test="count(node()) != count(text())"> 
        <!--test if children are not all text nodes, meaning there
        is markup assumed to be presentation markup--> 
        <xsl:choose> 
          <xsl:when test="child::*[position()=1 and             local-name()='msub']"><!-- test to see if the first child
        is msub so that the subscript will not be bolded --> 
        <m:msub> 
          <m:mover><m:mi><xsl:apply-templates select="./m:msub/child::*[position()=1]"/></m:mi><m:mo>&#x21C0;</m:mo></m:mover> 
          <m:mrow><xsl:apply-templates select="./m:msub/child::*[position()=2]"/></m:mrow> 
        </m:msub> 
          </xsl:when> 
          <xsl:otherwise> 
        <m:mrow><xsl:copy-of select="child::*"/></m:mrow> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:when> 
      <xsl:otherwise>  <!-- common case --> 
        <m:mover><m:mi><xsl:value-of select="text()"/></m:mi><m:mo>&#x21C0;</m:mo></m:mover> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
      
      <xsl:otherwise> 
    <!-- vector bolded --> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- And/Or notation choice --> 
 
  <!-- AND --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='and']]"> 
    <xsl:choose> 
      <xsl:when test="$andornotation='text'"><!-- text notation --> 
    <xsl:choose> 
      <xsl:when test="count(*)&gt;=3"> <!-- at least two operands (common case)--> 
        <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> <!--add brackets around OR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text disable-output-escaping="yes">&#xA0;and&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:when test="m:xor"> <!--add brackets around XOR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text disable-output-escaping="yes">&#xA0;and&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/><mo><xsl:text disable-output-escaping="yes">&#xA0;and&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
        <xsl:for-each select="child::*[position()=last()]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:when test="m:xor"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
      </xsl:when> 
      <xsl:when test="count(*)=2"> 
        <mo><xsl:text disable-output-escaping="yes">&#xA0;and&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
      </xsl:when> 
      <xsl:otherwise> 
        <mo><xsl:text disable-output-escaping="yes">&#xA0;and&#xA0;</xsl:text></mo> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
      <!-- statistical logic notation --> 
      <xsl:when test="$andornotation='statlogicnotation'"> 
    <xsl:choose> 
      <xsl:when test="count(*)&gt;=3"> <!-- at least two operands (common case)--> 
        <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> <!--add brackets around OR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text>&#xA0;&amp;&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:when test="m:xor"> <!--add brackets around XOR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text>&#xA0;&amp;&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/><mo><xsl:text>&#xA0;&amp;&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
        <xsl:for-each select="child::*[position()=last()]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:when test="m:xor"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
      </xsl:when> 
      <xsl:when test="count(*)=2"> 
        <mo><xsl:text>&#xA0;&amp;&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
      </xsl:when> 
      <xsl:otherwise> 
        <mo><xsl:text>&#xA0;&amp;&#xA0;</xsl:text></mo> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
 
      <!-- dsp logic notation --> 
      <xsl:when test="$andornotation='dsplogicnotation'"> 
    <xsl:choose> 
      <xsl:when test="count(*)&gt;=3"> <!-- at least two operands (common case)--> 
        <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> <!--add brackets around OR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text disable-output-escaping="yes">&#xA0;&#xB7;&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:when test="m:xor"> <!--add brackets around XOR children for priority purpose--> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced><mo><xsl:text disable-output-escaping="yes">&#xA0;&#xB7;&#xA0;</xsl:text></mo> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/><mo><xsl:text disable-output-escaping="yes">&#xA0;&#xB7;&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
        <xsl:for-each select="child::*[position()=last()]"> 
          <xsl:choose> 
        <xsl:when test="m:or"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:when test="m:xor"> 
          <mfenced separators=" "><xsl:apply-templates select="."/></mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="."/> 
        </xsl:otherwise> 
          </xsl:choose> 
        </xsl:for-each> 
      </xsl:when> 
      <xsl:when test="count(*)=2"> 
        <mo><xsl:text disable-output-escaping="yes">&#xA0;&#xB7;&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
      </xsl:when> 
      <xsl:otherwise> 
        <mo><xsl:text disable-output-escaping="yes">&#xA0;&#xB7;&#xA0;</xsl:text></mo> 
      </xsl:otherwise> 
    </xsl:choose> 
      </xsl:when> 
      
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='or']]"> 
    <xsl:choose> 
      <xsl:when test="$andornotation='text'"><!-- text
      notation --> 
    <mrow> 
      <xsl:choose> 
        <xsl:when test="count(*)&gt;=3"> 
          <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
        <xsl:apply-templates select="."/><mo><xsl:text disable-output-escaping="yes">&#xA0;or&#xA0;</xsl:text></mo> 
          </xsl:for-each> 
          <xsl:apply-templates select="child::*[position()=last()]"/> 
        </xsl:when> 
        <xsl:when test="count(*)=2"> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;or&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
        </xsl:when> 
        <xsl:otherwise> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;or&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
      </xsl:choose> 
    </mrow> 
      </xsl:when> 
      <!--statistical logic notation --> 
      <xsl:when test="$andornotation='statlogicnotation'"> 
    <mrow> 
      <xsl:choose> 
        <xsl:when test="count(*)&gt;=3"> 
          <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
        <xsl:apply-templates select="."/><mo><xsl:text disable-output-escaping="yes">|</xsl:text></mo> 
          </xsl:for-each> 
          <xsl:apply-templates select="child::*[position()=last()]"/> 
        </xsl:when> 
        <xsl:when test="count(*)=2"> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;|&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
        </xsl:when> 
        <xsl:otherwise> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;|&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
      </xsl:choose> 
    </mrow> 
      </xsl:when> 
      <!-- dsp logic notation --> 
      <xsl:when test="$andornotation='dsplogicnotation'"> 
    <mrow> 
      <xsl:choose> 
        <xsl:when test="count(*)&gt;=3"> 
          <xsl:for-each select="child::*[position()!=last() and  position()!=1]"> 
        <xsl:apply-templates select="."/><mo><xsl:text disable-output-escaping="yes">&#xA0;+&#xA0;</xsl:text></mo> 
          </xsl:for-each> 
          <xsl:apply-templates select="child::*[position()=last()]"/> 
        </xsl:when> 
        <xsl:when test="count(*)=2"> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;+&#xA0;</xsl:text></mo><xsl:apply-templates select="*[position()=last()]"/> 
        </xsl:when> 
        <xsl:otherwise> 
          <mo><xsl:text disable-output-escaping="yes">&#xA0;+&#xA0;</xsl:text></mo> 
        </xsl:otherwise> 
      </xsl:choose> 
    </mrow> 
      </xsl:when> 
      
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Real/Imaginary notation choice --> 
 
  <!-- real part of complex number --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='real']]"> 
    <xsl:choose> 
      <xsl:when test="$realimaginarynotation='text'"> 
    <m:mrow> 
      <m:mi><xsl:text disable-output-escaping="yes">Re</xsl:text></m:mi> 
      <m:mo><xsl:text disable-output-escaping="yes"/></m:mo> 
      <m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose>    
  </xsl:template> 
 
  <!-- imaginary part of complex number --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='imaginary']]"> 
    <xsl:choose> 
      <xsl:when test="$realimaginarynotation='text'"> 
    <m:mrow> 
      <m:mi><xsl:text disable-output-escaping="yes">Im</xsl:text></m:mi> 
      <m:mo><xsl:text disable-output-escaping="yes"/></m:mo> 
      <m:mfenced separators=" "><xsl:apply-templates select="child::*[position()=2]"/></m:mfenced> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Scalar Product Notation --> 
 
 <!-- scalar product = A x B x cos(teta) --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='scalarproduct']]"> 
    <xsl:choose> 
      <xsl:when test="$scalarproductnotation='dotnotation'"><!--dot
      notation --> 
    <m:mrow> 
      <xsl:apply-templates select="*[position()=2]"/> 
      <m:mo>&#xA0;&#xB7;&#xA0;</m:mo> 
      <xsl:apply-templates select="*[position()=3]"/> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
 
  <!-- Conjugate Notation --> 
  
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='conjugate']]"> 
    <xsl:choose> 
      <xsl:when test="$conjugatenotation='engineeringnotation'"><!-- asterik notation -->    
    <m:msup> 
      <xsl:apply-templates select="child::*[position()=2]"/> 
      <m:mo><xsl:text disable-output-escaping="yes">*</xsl:text></m:mo> 
    </m:msup> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Gradient and Curl Notation --> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='grad']]"> 
    <xsl:choose> 
      <xsl:when test="$gradnotation='symbolicnotation'"> 
    <m:mrow> 
      <m:mo>&#x2207;</m:mo> 
      <xsl:choose> 
        <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))"> 
          <mfenced separators=" "> 
        <xsl:apply-templates select="child::*[position()=2]"/> 
          </mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
        </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='curl']]"> 
    <xsl:choose> 
      <xsl:when test="$curlnotation='symbolicnotation'"> 
    <m:mrow> 
      <m:mo>&#x2207;</m:mo> 
      <m:mo>&#xD7;</m:mo> 
      <xsl:choose> 
        <xsl:when test="local-name(*[position()=2])='apply' or ((local-name(*[position()=2])='ci' or local-name(*[position()=2])='cn') and contains(*[position()=2]/text(),'-'))"> 
          <mfenced separators=" "> 
        <xsl:apply-templates select="child::*[position()=2]"/> 
          </mfenced> 
        </xsl:when> 
        <xsl:otherwise> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
        </xsl:otherwise> 
      </xsl:choose> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
  <!-- Remainder Notation --> 
  <xsl:template mode="c2p" match="m:apply[child::*[position()=1 and         local-name()='rem']]"> 
    <xsl:choose> 
      <xsl:when test="$remaindernotation='remainder_anglebracket'"> 
    <m:mrow> 
      <m:msub> 
        <m:mrow> 
          <m:mo>&#x2329;</m:mo> 
          <xsl:apply-templates select="child::*[position()=2]"/> 
          <m:mo>&#x232A;</m:mo> 
        </m:mrow> 
        <xsl:apply-templates select="child::*[position()=3]"/> 
      </m:msub> 
    </m:mrow> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:apply-imports/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
 
<!--
  This is added to fix the "a & b => c" bug which should add parentheses around "b => c".
  Note: I swapped the order of precedence from the original c2p XSLT.
  https://trac.rhaptos.org/trac/rhaptos/ticket/8045
  
  Also, mml:implies and mml:minus did not add parentheses around nested implies
  which should also be fixed.
  
  - Phil Schatz
--> 
 
  <!-- 4.4.3.5  minus--> 
  <!-- mml:minus is NOT associative, so pass an extra param to "binary"
--> 
  <xsl:template mode="c2p" match="mml:apply[*[1][self::mml:minus] and count(*)&gt;2]"> 
    <xsl:param name="p" select="0"/> 
    <xsl:call-template name="binary"> 
      <xsl:with-param name="mo"><mml:mo>&#x2212;<!--minus--></mml:mo></xsl:with-param> 
      <xsl:with-param name="p" select="$p"/> 
      <xsl:with-param name="this-p" select="2.1"/> 
      <xsl:with-param name="associative" select="'left'"/> 
    </xsl:call-template> 
  </xsl:template> 
 
  <!-- Custom "implies" --> 
  <xsl:template mode="c2p" match="mml:apply[*[1][self::mml:implies]]"> 
    <xsl:param name="p" select="0"/> 
    <xsl:call-template name="binary"> 
      <xsl:with-param name="mo"> 
        <mml:mo>&#x21D2;<!-- Rightarrow --></mml:mo> 
      </xsl:with-param> 
      <xsl:with-param name="p" select="$p"/> 
      <xsl:with-param name="this-p" select="1.5"/> 
      <xsl:with-param name="associative" select="'left'"/> 
    </xsl:call-template> 
  </xsl:template> 
 
  <!-- Custom "and" --> 
  <xsl:template mode="c2p" match="m:apply[*[1][self::m:and]]"> 
    <xsl:param name="p" select="0"/> 
    <xsl:variable name="separator"> 
    <xsl:choose> 
        <xsl:when test="$andornotation = 'text'"> and </xsl:when> 
        <xsl:when test="$andornotation = 'statlogicnotation'">&amp;</xsl:when> 
        <xsl:when test="$andornotation = 'dsplogicnotation'">&#xB7;<!-- TODO Middle dot entity --></xsl:when> 
        <xsl:otherwise>&#x2227;<!-- and --></xsl:otherwise> 
      </xsl:choose> 
    </xsl:variable>              
    <xsl:call-template name="infix"> 
      <xsl:with-param name="this-p" select="3"/> 
      <xsl:with-param name="p" select="$p"/> 
      <xsl:with-param name="mo"> 
        <mml:mspace width=".3em"/><m:mo><xsl:value-of select="$separator"/></m:mo><mml:mspace width=".3em"/> 
      </xsl:with-param> 
    </xsl:call-template> 
  </xsl:template> 
 
  <!-- Custom "or" --> 
  <xsl:template mode="c2p" match="m:apply[*[1][self::m:or]]"> 
    <xsl:param name="p" select="0"/> 
    <xsl:variable name="separator"> 
    <xsl:choose> 
        <xsl:when test="$andornotation = 'text'"> or </xsl:when> 
        <xsl:when test="$andornotation = 'statlogicnotation'">|</xsl:when> 
        <xsl:when test="$andornotation = 'dsplogicnotation'">+</xsl:when> 
        <xsl:otherwise>&#x2228;<!-- or --></xsl:otherwise> 
    </xsl:choose> 
    </xsl:variable>              
    <xsl:call-template name="infix"> 
      <xsl:with-param name="this-p" select="2"/> 
      <xsl:with-param name="p" select="$p"/> 
      <xsl:with-param name="mo"> 
        <mml:mspace width=".3em"/><m:mo><xsl:value-of select="$separator"/></m:mo><mml:mspace width=".3em"/> 
      </xsl:with-param> 
    </xsl:call-template> 
  </xsl:template> 
 
<!-- ****************************** --> 
<xsl:template name="infix"> 
  <xsl:param name="mo"/> 
  <xsl:param name="p" select="0"/> 
  <xsl:param name="this-p" select="0"/> 
  <mml:mrow> 
  <xsl:if test="$this-p &lt; $p"><mml:mo>(</mml:mo></xsl:if> 
  <xsl:for-each select="*[position()&gt;1]"> 
   <xsl:if test="position() &gt; 1"> 
    <xsl:copy-of select="$mo"/> 
   </xsl:if>   
   <xsl:apply-templates select="."> 
     <xsl:with-param name="p" select="$this-p"/> 
   </xsl:apply-templates> 
  </xsl:for-each> 
  <xsl:if test="$this-p &lt; $p"><mml:mo>)</mml:mo></xsl:if> 
  </mml:mrow> 
</xsl:template> 
 
  <!-- mml:implies and mml:minus are NOT associative, so we need to add parentheses
--> 
  <xsl:template name="binary"> 
    <xsl:param name="mo"/> 
    <xsl:param name="p" select="0"/> 
    <xsl:param name="this-p" select="0"/> 
    <xsl:param name="associative" select="''"/><!-- can be: '' (both), 'none', or TODO 'left', 'right'
--> 
    <xsl:variable name="parent-op" select="local-name(../mml:*[1])"/> 
    <mml:mrow> 
    <xsl:if test="$this-p &lt; $p or ($associative='none' and $parent-op = local-name(mml:*[1])) or ($associative='left' and $parent-op = local-name(mml:*[1]) and not(following-sibling::*[position()=1]))"><mml:mo>(</mml:mo></xsl:if> 
     <xsl:apply-templates select="*[2]"> 
       <xsl:with-param name="p" select="$this-p"/> 
     </xsl:apply-templates> 
     <xsl:copy-of select="$mo"/> 
     <xsl:apply-templates select="*[3]"> 
       <xsl:with-param name="p" select="$this-p"/> 
     </xsl:apply-templates> 
    <xsl:if test="$this-p &lt; $p or ($associative='none' and $parent-op = local-name(mml:*[1])) or ($associative='left' and $parent-op = local-name(mml:*[1]) and not(following-sibling::*[position()=1]))"><mml:mo>)</mml:mo></xsl:if> 
    </mml:mrow> 
  </xsl:template> 
 
</xsl:stylesheet>
