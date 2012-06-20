<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file is run once all modules are converted and once all module dbk files are XIncluded.
    See the docs/link-checker.txt for info on how to use this alpha-level script
	It:
	* Annotates every cnxml element with a __xpath attribute which will be used later
	    to show the approximate line number that caused the problem since the error 
	    won't be detected until after the cnxml has already been processed
	    and converted to Docbook.
 -->

<xsl:import href="../debug.xsl"/>
<xsl:import href="../ident.xsl"/>

<!-- Inject an Xpath attribute logging where the element originally came from -->
<xsl:template match="*">
    <xsl:copy>
        <xsl:attribute name="xpath" namespace="http://cnx.org/ns/docbook+">
            <xsl:call-template name="debugPathPrinter"/>
        </xsl:attribute>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
