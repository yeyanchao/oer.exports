<!--Currently I use a sed script to do the replacement
the following xsl doesn't match any xml elements, it's probably
because the namespace setting issue-->
<xsl:stylesheet version="1.0"

  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

>

<xsl:template match="@*|node()">

  <xsl:copy>

    <xsl:apply-templates select="@*|node()"/>

  </xsl:copy>

</xsl:template>

<!-- Unwrap the para tag if it is the only child 
<xsl:template match="li/@class='listitem'/p">

  <span class="yeyanchao">

    <xsl:apply-templates select="@*|node()"/>

  </span>

</xsl:template>


<xsl:template match="li[count(*) = 1]/p">-->
<xsl:template match="li[count(*) = 1]/p">

  <!--<span class="para">-->
  <span class="yeyanchao">

    <xsl:apply-templates select="@*|node()"/>

  </span>

</xsl:template>


</xsl:stylesheet>
