<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
> 
 
  <!-- Begin section of translations for english text that appear in this file--> 
  <xsl:param name="output-l10n-keys" select="'0'"/> 
  <xsl:param name="cnx.l10n.xml" select="document('l10n.xml')"/> 
  <xsl:param name="cnx.local.l10n.xml" select="document('')"/> 
  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"> 
    <l:l10n language="en" english-language-name="English"> 
      <!-- for cnxml_render.xsl --> 
      <l:gentext key="subfigure" text="Subfigure"/> 
      <l:gentext key="Subfigure" text="Subfigure"/> 
      <l:gentext key="problem" text="Problem"/> 
      <l:gentext key="Problem" text="Problem"/> 
      <l:gentext key="exercise" text="Exercise"/> 
      <l:gentext key="Exercise" text="Exercise"/> 
      <l:gentext key="solution" text="Solution"/> 
      <l:gentext key="para" text="Paragraph"/> 
      <l:gentext key="statement" text="Statement"/> 
      <l:gentext key="rule" text="Rule"/> 
      <l:gentext key="definition" text="Definition"/> 
      <l:gentext key="meaning" text="Meaning"/> 
      <l:gentext key="list" text="List"/> 
      <l:gentext key="item" text="Item"/> 
      <l:gentext key="caption" text="Caption"/> 
      <l:gentext key="media" text="Media"/> 
      <l:gentext key="param" text="Param"/> 
      <l:gentext key="emphasis" text="Emphasis"/> 
      <l:gentext key="quote" text="Quote"/> 
      <l:gentext key="foreign" text="Foreign"/> 
      <l:gentext key="code" text="Code"/> 
      <l:gentext key="cnxn" text="Cnxn"/> 
      <l:gentext key="link" text="Link"/> 
      <l:gentext key="cite" text="Cite"/> 
      <l:gentext key="term" text="Term"/> 
      <l:gentext key="name" text="Name"/> 
      <l:gentext key="tgroup" text="Tgroup"/> 
      <l:gentext key="colspec" text="Colspec"/> 
      <l:gentext key="spanspec" text="Spanspec"/> 
      <l:gentext key="thead" text="Thead"/> 
      <l:gentext key="tfoot" text="Tfoot"/> 
      <l:gentext key="tbody" text="Tbody"/> 
      <l:gentext key="row" text="Row"/> 
      <l:gentext key="entrytbl" text="Entrytbl"/> 
      <l:gentext key="entry" text="Entry"/> 
      <l:gentext key="Strength" text="Strength"/> 
      <l:gentext key="Definition" text="Definition"/> 
      <l:gentext key="Proof" text="Proof"/> 
      <l:gentext key="MediaFile" text="Media File"/> 
      <l:gentext key="LabVIEWExample" text="LabVIEW Example"/> 
      <l:gentext key="Download" text="Download"/> 
      <l:gentext key="LabVIEWSource" text="LabVIEW Source"/> 
      <l:gentext key="AudioFile" text="Audio File"/> 
      <l:gentext key="MusicalExample" text="Musical Example"/> 
      <l:gentext key="Show" text="Show"/> 
      <l:gentext key="Hide" text="Hide"/> 
      <l:gentext key="Solution" text="Solution"/> 
      <l:gentext key="Diagnosis" text="Diagnosis"/> 
      <l:gentext key="Footnotes" text="Footnotes"/> 
      <l:gentext key="warning" text="Warning"/> 
      <l:gentext key="important" text="Important"/> 
      <l:gentext key="aside" text="Aside"/> 
      <l:gentext key="tip" text="Tip"/> 
      <l:gentext key="Note" text="Note"/> 
      <l:gentext key="theorem" text="Theorem"/> 
      <l:gentext key="lemma" text="Lemma"/> 
      <l:gentext key="corollary" text="Corollary"/> 
      <l:gentext key="law" text="Law"/> 
      <l:gentext key="proposition" text="Proposition"/> 
      <l:gentext key="Rule" text="Rule"/> 
      <l:gentext key="Step" text="Step"/> 
      <l:gentext key="Listing" text="Listing"/> 
      <l:gentext key="citelink" text="link"/> 
 
      <!-- for content_render.xsl --> 
      <l:gentext key="Example links" text="Example links"/> 
      <l:gentext key="Prerequisite links" text="Prerequisite links"/> 
      <l:gentext key="Supplemental links" text="Supplemental links"/> 
      <l:gentext key="Stronglink" text="Strongly related link"/> 
      <l:gentext key="Relatedlink" text="Related link"/> 
      <l:gentext key="Weaklink" text="Weakly related link"/> 
 
      <!-- for editInPlace.xsl --> 
      <l:gentext key="Instructions" text="Instructions: "/> 
      <l:gentext key="Instructionstext" text="To edit text, click on an area with a white background. Warning: Reloading or leaving the page will discard any unpublished changes."/> 
      <l:gentext key="Brieflydescribeyourchanges" text="Briefly describe your changes:"/> 
      <l:gentext key="Publish" text="Publish"/> 
      <l:gentext key="Discard" text="Discard"/> 
 
      <!-- for qml.xsl --> 
      <l:gentext key="ProblemSet" text="Problem Set"/> 
      <l:gentext key="CheckAnswer" text="Check Answer"/> 
      <l:gentext key="ShowAnswer" text="Show Answer"/> 
      <l:gentext key="Hint" text="Hint"/> 
      <l:gentext key="Correct" text="Correct!"/> 
      <l:gentext key="Incorrect" text="Incorrect."/> 
 
      <!-- Old pairs resurrected for use by old content_render template --> 
      <l:gentext key="Aboutus" text="About us"/> 
      <l:gentext key="Browseallcontent" text="Browse all content"/> 
      <l:gentext key="PrintPDF" text="Print (PDF)"/> 
<!--      <l:gentext key="loginrequired" text="(login required)"/>  --> 
      <l:gentext key="Moreaboutthiscontent" text="More about this content"/> 
      <l:gentext key="Citethiscontent" text="Cite this content"/> 
      <l:gentext key="Versionhistory" text="Version history"/> 
      <l:gentext key="SaveToDelicious" text="Save to del.icio.us"/> 
      <l:gentext key="Coursesusingcontent" text="Collections using this content"/> 
      <l:gentext key="Morecoursesusingcontent" text="More collections using this content"/> 
      <l:gentext key="TableofContents" text="Table of Contents"/> 
 
<!--
      <l:gentext key="Summer Sky" text="Summer Sky"/>
      <l:gentext key="Desert Scape" text="Desert Scape"/>
      <l:gentext key="Charcoal" text="Charcoal"/>
      <l:gentext key="Playland" text="Playland"/>
--> 
<!--      <l:gentext key="Plone" text="Plone"/>  --> 
 
 
    </l:l10n> 
  </l:i18n> 
 
  <!-- Our hacked version of the gentext template --> 
  <xsl:template name="cnx.gentext"> 
    <xsl:param name="key" select="local-name(.)"/> 
    <xsl:param name="lang"/> 
  
    <xsl:variable name="local.l10n.gentext"
                  select="($cnx.local.l10n.xml/xsl:stylesheet/l:i18n/l:l10n[@language=$lang]/l:gentext[@key=$key])[1]"/> 
  
    <xsl:variable name="l10n.gentext"
                  select="($cnx.l10n.xml/l:i18n/l:l10n[@language=$lang]/l:gentext[@key=$key])[1]"/> 
    <xsl:if test="$output-l10n-keys = '1'"> 
      <xsl:message>l10n key: <xsl:value-of select="$key"/></xsl:message> 
    </xsl:if> 
    <xsl:choose> 
      <xsl:when test="$local.l10n.gentext"> 
        <xsl:value-of select="$local.l10n.gentext/@text"/> 
      </xsl:when> 
      <xsl:when test="$l10n.gentext"> 
        <xsl:value-of select="$l10n.gentext/@text"/> 
      </xsl:when> 
      <xsl:otherwise> 
        <xsl:message> 
          <xsl:text>No "</xsl:text> 
          <xsl:value-of select="$lang"/> 
          <xsl:text>" localization of "</xsl:text> 
          <xsl:value-of select="$key"/> 
          <xsl:text>" exists</xsl:text> 
          <xsl:choose> 
            <xsl:when test="$lang = 'en'"> 
               <xsl:text>.</xsl:text> 
            </xsl:when> 
            <xsl:otherwise> 
               <xsl:text>; using "en".</xsl:text> 
            </xsl:otherwise> 
          </xsl:choose> 
        </xsl:message> 
          
          <xsl:variable name="local.en.l10n.gentext"
            select="($cnx.local.l10n.xml//l:i18n/l:l10n[@language='en']/l:gentext[@key=$key])[1]"/> 
          
          <xsl:choose> 
            <xsl:when test="$local.en.l10n.gentext"> 
              <xsl:value-of select="$local.en.l10n.gentext/@text"/> 
            </xsl:when> 
            <xsl:otherwise> 
              <xsl:value-of select="($cnx.l10n.xml/l:i18n/l:l10n[@language='en']/l:gentext[@key=$key])[1]/@text"/> 
            </xsl:otherwise> 
          </xsl:choose> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template> 
  
</xsl:stylesheet> 