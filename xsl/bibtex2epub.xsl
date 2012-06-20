<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://www.w3.org/1999/xhtml" >

  <!-- BOOK and BOOKLET and INBOOK -->
  <xsl:template match="bib:book|bib:booklet|bib:inbook">
    <xsl:apply-templates select="bib:author|bib:editor"/>
    <xsl:if test="bib:editor[string-length(normalize-space(text()))>0]">
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:chapter"/>
    <xsl:apply-templates select="bib:series"/>
    <xsl:if test="bib:series[string-length(normalize-space(text()))>0]">
      <xsl:apply-templates select="bib:volume"/>
    </xsl:if>
    <xsl:apply-templates select="bib:title"/>
    <xsl:call-template name="edition-volume-number-pages"/>
    <xsl:apply-templates select="bib:howpublished"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:type"/>
    <xsl:apply-templates select="bib:address"/>
    <xsl:apply-templates select="bib:publisher"/>
  </xsl:template>

  <!-- ARTICLE -->
  <xsl:template match="bib:article">
    <xsl:apply-templates select="bib:author"/>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:title"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:journal"/>
    <xsl:apply-templates select="bib:volume"/>
    <xsl:apply-templates select="bib:number"/>
    <xsl:apply-templates select="bib:pages"/>
  </xsl:template>

  <!-- THESES and TECHREPORT -->
  <xsl:template match="bib:mastersthesis|bib:phdthesis|bib:techreport">
    <xsl:apply-templates select="bib:author"/>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:title"/>
    <xsl:apply-templates select="bib:number"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:type"/>
    <xsl:apply-templates select="bib:school"/>
    <xsl:apply-templates select="bib:address"/>
    <xsl:apply-templates select="bib:institution"/>
  </xsl:template>

  <!-- PROCEEDINGS -->
  <xsl:template match="bib:proceedings">
    <xsl:apply-templates select="bib:editor"/>
    <xsl:if test="bib:editor[string-length(normalize-space(text()))>0]">
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:series"/>
    <xsl:apply-templates select="bib:title"/>
    <xsl:apply-templates select="bib:volume"/>
    <xsl:apply-templates select="bib:number"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:organization"/>
    <xsl:apply-templates select="bib:address"/>
    <xsl:apply-templates select="bib:publisher"/>
  </xsl:template>

  <!-- CONFERENCE and INCOLLECTION and INPROCEEDINGS -->
  <xsl:template match="bib:conference|bib:incollection|bib:inproceedings">
    <xsl:apply-templates select="bib:author"/>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:title"/>
    <xsl:text>In </xsl:text>
    <xsl:apply-templates select="bib:editor"/>
    <xsl:if test="bib:editor[string-length(normalize-space(text()))>0]">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="bib:series"/>
    <xsl:if test="bib:series[string-length(normalize-space(text()))>0]">
      <xsl:apply-templates select="bib:volume"/>
    </xsl:if>
    <xsl:apply-templates select="bib:booktitle"/>
    <xsl:call-template name="edition-volume-number-pages"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:type"/>
    <xsl:apply-templates select="bib:organization"/>
    <xsl:apply-templates select="bib:address"/>
    <xsl:apply-templates select="bib:publisher"/>
  </xsl:template>

  <!-- MANUAL and MISC and UNPUBLISHED -->
  <xsl:template match="bib:manual|bib:misc|bib:unpublished">
    <xsl:apply-templates select="bib:author"/>
    <xsl:call-template name="year-month"/>
    <xsl:apply-templates select="bib:title"/>
    <xsl:call-template name="edition-volume-number-pages"/>
    <xsl:apply-templates select="bib:note"/>
    <xsl:apply-templates select="bib:organization"/>
    <xsl:apply-templates select="bib:howpublished"/>
  </xsl:template>

  <!-- Variables for handy use later on -->
  <xsl:variable name="period">.</xsl:variable>
  <xsl:variable name="exclamation">!</xsl:variable>
  <xsl:variable name="question">?</xsl:variable>
  <xsl:variable name="comma">,</xsl:variable>
  <xsl:variable name="ampersand">&amp;</xsl:variable>
  <xsl:variable name="semicolon">;</xsl:variable>

  <!-- Don't output empty elements. Docbook will output these as code and make them red. -->
  <xsl:template match="bib:*[string-length(normalize-space(text()))=0]" priority="-1"/>

  <!-- AUTHOR, BOOKTITLE, CHAPTER, INSTITUTION, ORGANIZATION, PUBLISHER, TYPE, HOWPUBLISHED (adds period, unless element already ends in punctuation) -->
  <xsl:template match="bib:author[string-length(normalize-space(text()))>0]       |
                       bib:booktitle[string-length(normalize-space(text()))>0]    |
                       bib:chapter[string-length(normalize-space(text()))>0]      |
                       bib:institution[string-length(normalize-space(text()))>0]  |
                       bib:organization[string-length(normalize-space(text()))>0] |
                       bib:publisher[string-length(normalize-space(text()))>0]    |
                       bib:type[string-length(normalize-space(text()))>0]         |
                       bib:howpublished[string-length(normalize-space(text()))>0]">
    <xsl:for-each select=".">
      <xsl:variable name="last-character" select="substring(string(normalize-space()),string-length(normalize-space()),1)"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="not($last-character=$period or $last-character=$exclamation or $last-character=$question)">
	<xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- EDITION-VOLUME-NUMBER-PAGES templates (for Book, Conference, Inbook, Incollection, Inproceedings, Proceedings, ???) -->
  <xsl:template name="edition-volume-number-pages">
    <xsl:if test="bib:edition[string-length(normalize-space(text()))>0] or
                  bib:volume[string-length(normalize-space(text()))>0] or
                  bib:number[string-length(normalize-space(text()))>0] or
                  bib:pages[string-length(normalize-space(text()))>0]">
      <xsl:text>(</xsl:text>
	<xsl:apply-templates select="bib:edition"/>
	<xsl:if test="not(bib:series[string-length(normalize-space(text()))>0])">
	  <xsl:apply-templates select="bib:volume"/>
	</xsl:if>
	<xsl:apply-templates select="bib:number"/>
	<xsl:apply-templates select="bib:pages"/>
      <xsl:text>). </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- EDITION -->
  <xsl:template match="bib:edition[string-length(normalize-space(text()))>0]">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="(../bib:volume[string-length(normalize-space(text()))>0] and
                   not(../bib:series[string-length(normalize-space(text()))>0])) or
                   ../bib:number[string-length(normalize-space(text()))>0] or
                   ../bib:pages[string-length(normalize-space(text()))>0]">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- VOLUME (explicitly states that it's a Volume, unless it's in an Article) -->
  <xsl:template match="bib:volume[string-length(normalize-space(text()))>0]">
    <xsl:choose>
      <xsl:when test="parent::bib:article or
                      ../bib:series[string-length(normalize-space(text()))>0]">
	<i>
	  <xsl:if test="../bib:series[string-length(normalize-space(text()))>0]">
	    <xsl:text>Vol. </xsl:text>
	  </xsl:if>
	  <xsl:value-of select="normalize-space(.)"/>
	</i>
	<xsl:if test="parent::bib:article and
                      not(../bib:number[string-length(normalize-space(text()))>0])">
	  <xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:if test="../bib:series[string-length(normalize-space(text()))>0]">
	  <xsl:text>. </xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>Vol. </xsl:text>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:if test="../bib:number[string-length(normalize-space(text()))>0] or
                      ../bib:pages[string-length(normalize-space(text()))>0]">
	  <xsl:text>, </xsl:text>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- NUMBER -->
  <xsl:template match="bib:number[string-length(normalize-space(text()))>0]">
    <xsl:choose>
      <xsl:when test="parent::bib:article or parent::bib:techreport">
	<xsl:text>(</xsl:text>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:text>)</xsl:text>
	<xsl:if test="parent::bib:article">
	  <xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:if test="parent::bib:techreport">
	  <xsl:text>. </xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:if test="../bib:pages[string-length(normalize-space(text()))>0]">
	  <xsl:text>, </xsl:text>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- PAGES (in non-articles, precedes by "p. ", or "pp. " if more than one page (only knows to do this if hyphen is used)) -->
  <xsl:template match="bib:pages[string-length(normalize-space(text()))>0]">
    <xsl:choose>
      <xsl:when test="parent::bib:article">
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>p</xsl:text>
	<xsl:if test="contains(string(),'-')">
	  <xsl:text>p</xsl:text>
	</xsl:if>
	<xsl:text>. </xsl:text>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- EDITOR (adds "(Ed.)" if singular or "(Eds.)" if plural - this might not always work, however) -->
  <xsl:template match="bib:editor[string-length(normalize-space(text()))>0]">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text> (Ed</xsl:text>
    <xsl:if test="contains(string(),' and ') or contains(string(),' with ') or contains(string(),$ampersand) or contains(string(),$semicolon)">
      <xsl:text>s</xsl:text>
    </xsl:if>
    <xsl:text>.)</xsl:text>
  </xsl:template>

  <!-- YEAR-MONTH template (surrounds with parentheses and adds period) -->
  <xsl:template name="year-month">
    <xsl:if test="bib:year[string-length(normalize-space(text()))>0]">
      <xsl:text>(</xsl:text>
      <xsl:value-of select="normalize-space(bib:year)"/>
      <xsl:if test="bib:month[string-length(normalize-space(text()))>0]">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="normalize-space(bib:month)"/>
      </xsl:if>
      <xsl:text>). </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- NOTE (surrounds with bracket and adds period) -->
  <xsl:template match="bib:note[string-length(normalize-space(text()))>0]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>]. </xsl:text>
  </xsl:template>

  <!-- ADDRESS (adds semicolon if followed by publisher, otherwise adds period unless address already ends in punctutation) -->
  <xsl:template match="bib:address[string-length(normalize-space(text()))>0]">
    <xsl:for-each select=".">
      <xsl:variable name="last-character" select="substring(string(normalize-space()),string-length(normalize-space()),1)"/>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="../bib:publisher[string-length(normalize-space(text()))>0] or
                    ../bib:institution[string-length(normalize-space(text()))>0]">
	<xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:if test="../bib:school[string-length(normalize-space(text()))>0] and
                    not($last-character=$period or $last-character=$exclamation or $last-character=$question)">
	<xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- TITLE (italicizes if appropriate, adds period unless title already ends in punctuation) -->
  <xsl:template match="bib:title|bib:booktitle[string-length(normalize-space(text()))>0]">
    <xsl:for-each select=".">
      <xsl:variable name="last-character" select="substring(string(normalize-space()),string-length(normalize-space()),1)"/>
      <xsl:variable name="italicized" select="not(parent::bib:article or parent::bib:proceedings or ../bib:booktitle)"/>
      <xsl:choose>
	<xsl:when test="$italicized or self::bib:booktitle">
	  <i>
	    <xsl:value-of select="normalize-space(.)"/>
	  </i>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not($last-character=$period or $last-character=$exclamation or $last-character=$question)">
	<xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- JOURNAL (italicizes and adds appropriate punctuation) -->
  <xsl:template match="bib:journal[string-length(normalize-space(text()))>0]">
    <i>
      <xsl:value-of select="normalize-space(.)"/>
    </i>
    <xsl:choose>
      <xsl:when test="../bib:volume[string-length(normalize-space(text()))>0] or
                      ../bib:number[string-length(normalize-space(text()))>0] or
                      ../bib:pages[string-length(normalize-space(text()))>0]">
	<xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- SCHOOL (adds comma if followed by Address, otherwise adds period) -->
  <xsl:template match="bib:school[string-length(normalize-space(text()))>0]">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="../bib:address[string-length(normalize-space(text()))>0]">
	<xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- SERIES (italicizes and adds colon) -->
  <xsl:template match="bib:series[string-length(normalize-space(text()))>0]">
    <i>
     <xsl:value-of select="normalize-space(.)"/>
     <xsl:text>: </xsl:text>
    </i>
  </xsl:template>

</xsl:stylesheet>
