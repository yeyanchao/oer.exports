<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns="http://www.w3.org/1999/xhtml" 
                xmlns:db="http://docbook.org/ns/docbook" 
                version="1.0">
  
  <!-- FIXME: This file essentially copied from cnxml/trunk/style/table.xsl with some edits.  Eventually we should try to use just one file to reduce code duplication. -->

  <!--ID CHECK -->
  <xsl:template name="IdCheck">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="class-test">           
    <xsl:param name="provided-class"/>
    <xsl:param name="wanted-class"/>
    <xsl:if test="$provided-class = $wanted-class or                   
                  starts-with($provided-class, concat($wanted-class, ' ')) or                   
                  contains($provided-class, concat(' ', $wanted-class, ' ')) or                    
                  substring($provided-class, string-length($provided-class) - string-length($wanted-class)) = concat(' ', $wanted-class)                               
                 ">1</xsl:if> 
  </xsl:template> 

  <xsl:template match="db:table/@class">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="db:table">
    <div class="table">
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates select="@class"/>
      <xsl:choose>
	<!-- OLD TABLES -->
	<xsl:when test="db:categories">
          <xsl:apply-templates select="db:name"/>
	  <table class="old-table" cellspacing="0" cellpadding="0" style="border: 1px solid !important; border-collapse: collapse;">
	    <!--Outputs CATEGORY as headers.-->
	    <tr>
	      <xsl:for-each select="//db:category">
		<th style="border: 1px solid !important;">
		  <xsl:apply-templates/>
		</th>
	      </xsl:for-each>
	    </tr>
	    <!--Outputs the content of ELEMs in the order they are listed within each GROUP.-->
	    <xsl:for-each select="db:group">
	      <tr>
		<xsl:for-each select="db:elem">
		  <td style="border: 1px solid !important;">
		    <xsl:apply-templates/>
		  </td>
		</xsl:for-each>
	      </tr>
	    </xsl:for-each>
	  </table>
	</xsl:when>
	<!-- NEW TABLE -->
	<xsl:otherwise>
	  <table cellspacing="0" cellpadding="0">
            <xsl:if test="@summary!='' or processing-instruction('table-summary')">
              <xsl:attribute name="summary">
                <xsl:choose>
                  <xsl:when test="@summary">
                    <xsl:value-of select="@summary"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="processing-instruction('table-summary')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:if>
	    <xsl:attribute name="style">
	      <!-- The "solid" style is used because browsers need this to render any border at all (can be overridden in a CSS file 
	      with !important marker).  Where the border is turned off with a "border-width: 0 !important;", the !important marker is 
	      used to prevent a CSS file from overriding that zero width when a general width is given to table elements in a CSS file 
	      (which must also use the !important marker to override the non-!important elements encoded inline).  -->
	      <xsl:text>border: 1px solid; </xsl:text>
	      <xsl:if test="@pgwide!='0' or @orient='land'">
		width: 100%; 
	      </xsl:if>
      	      <xsl:if test="@frame">
		<xsl:choose>
		  <xsl:when test="@frame='none'">
		    border-width: 0 !important;
		  </xsl:when>
		  <xsl:when test="@frame='sides'">
		    border-top-width: 0 !important; border-bottom-width: 0 !important;
		  </xsl:when>
		  <xsl:when test="@frame='top'">
		    border-left-width: 0 !important; border-right-width: 0 !important; border-bottom-width: 0 !important;
		  </xsl:when>
		  <xsl:when test="@frame='bottom'">
		    border-left-width: 0 !important; border-right-width: 0 !important; border-top-width: 0 !important;
		  </xsl:when>
		  <xsl:when test="@frame='topbot'">
		    border-left-width: 0 !important; border-right-width: 0 !important;
		  </xsl:when>
	        </xsl:choose>
	      </xsl:if>
	    </xsl:attribute>
            <xsl:if test="db:name[node()] or                            db:title[node()] or                            db:caption[node()] or                            db:label[node()] or                            (not(db:label[not(node())]) and                             not(ancestor::*[1][self::db:figure or self::db:subfigure]))">
              <caption>
                <xsl:if test="db:label[node()] or                                (not(db:label[not(node())]) and                                 not(ancestor::*[1][self::db:figure or self::db:subfigure]))">
                  <span class="cnx-gentext-caption cnx-gentext-t">
                    <xsl:choose>
                      <xsl:when test="db:label">
                        <xsl:apply-templates select="db:label"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>Table</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                  </span>
                  <span class="cnx-gentext-caption cnx-gentext-n">
                    <xsl:if test="not(ancestor::*[1][self::db:figure or self::db:subfigure])">
                      <xsl:for-each select="ancestor::db:chapter">   
                        <xsl:apply-templates select="." mode="label.markup"/>
                        <xsl:apply-templates select="." mode="intralabel.punctuation"/>
                      </xsl:for-each>
                      <xsl:variable name="type" select="translate(@type,$cnx.upper,$cnx.lower)"/>
                      <xsl:choose>
                        <xsl:when test="@type and $type!='table'">
                          <xsl:number level="any" from="db:preface|db:chapter" count="db:table[not(ancestor::*[1][self::db:figure or self::db:subfigure])][translate(@type,$cnx.upper,$cnx.lower)=$type]" format="1. "/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:number level="any" from="db:preface|db:chapter" count="db:table[not(ancestor::*[1][self::db:figure or self::db:subfigure])][not(@type) or translate(@type,$cnx.upper,$cnx.lower)='table']" format="1. "/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                  </span>
                  <xsl:apply-templates select="db:title/node()" />
                </xsl:if>
                <xsl:if test="db:caption[node()]">
                  <xsl:variable name="caption-element">
                    <xsl:choose>
                      <xsl:when test="db:name[node()] or db:title[node()]">div</xsl:when>
                      <xsl:otherwise>span</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:element name="{$caption-element}">
                    <xsl:attribute name="class">table-caption caption</xsl:attribute>
                    <xsl:if test="db:caption/@id">
                      <xsl:attribute name="id">
                        <xsl:value-of select="db:caption/@id"/>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="db:caption/node()"/>
                  </xsl:element>
                </xsl:if>
              </caption>
            </xsl:if>
	    <xsl:choose>
	      <xsl:when test="count(db:tgroup) &gt; 1">
		<tbody>
		  <xsl:for-each select="db:tgroup">
		    <tr>
		      <td style="padding: 0 !important; border: 0 !important">
			<table cellspacing="0" cellpadding="0" width="100%" style="border: 0 !important; margin: 0 !important;">
	    		  <xsl:apply-templates select="self::db:tgroup"/>
			</table>
		      </td>
		    </tr>
		  </xsl:for-each>
		</tbody>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates select="db:tgroup"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </table>
	</xsl:otherwise>
      </xsl:choose>
    </div>  
  </xsl:template>

  <xsl:template match="db:colspec|db:spanspec"/>

  <xsl:template match="db:tgroup">    
    <!-- Only bother to do this if there are colwidth attributes specified. -->
    <xsl:call-template name="IdCheck"/>
    <xsl:if test="db:colspec/@colwidth or child::*/db:colspec/@colwidth">
      <colgroup>
	<xsl:call-template name="col.maker"/>
      </colgroup>
    </xsl:if>
    <xsl:apply-templates select="db:thead"/>
    <xsl:apply-templates select="db:tbody"/>
    <xsl:apply-templates select="db:tfoot"/>
  </xsl:template>

  <xsl:template match="db:entrytbl">
    <td class="entrytbl">
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="style">
	<xsl:text>height: 100%; padding: 0 !important; border-left: 0 !important; border-top: 0 !important; </xsl:text>
	<xsl:call-template name="style.param.determiner">
	  <xsl:with-param name="style.name">colsep</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="style.param.determiner">
	  <xsl:with-param name="style.name">rowsep</xsl:with-param>
	</xsl:call-template>
      </xsl:attribute>
      <xsl:if test="(@namest and @nameend) or @spanname">
	<xsl:attribute name="colspan">
	  <xsl:call-template name="calculate.colspan"/>
	</xsl:attribute>
      </xsl:if>
      <table cellspacing="0" cellpadding="0" width="100%" style="height: 100%; border: 0 !important; margin: 0 !important;">
	<!-- Only bother to do this if there are colwidth attributes specified. -->
	<xsl:if test="db:colspec/@colwidth or child::*/db:colspec/@colwidth">
	  <colgroup>
	    <xsl:call-template name="col.maker"/>
	  </colgroup>
	</xsl:if>
	<xsl:apply-templates/>
      </table>
    </td>
  </xsl:template>

  <xsl:template match="db:thead|db:tfoot|db:tbody">
    <xsl:element name="{local-name(.)}">
      <xsl:call-template name="IdCheck"/>
      <xsl:attribute name="valign">
	<xsl:choose>
	  <xsl:when test="@valign">
	    <xsl:value-of select="@valign"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="self::db:tbody or self::db:tfoot">
		<xsl:text>top</xsl:text>
	      </xsl:when>
	      <xsl:when test="self::db:thead">
		<xsl:text>bottom</xsl:text>
	      </xsl:when>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="db:row">
    <tr>
      <xsl:if test="@valign">
	<xsl:attribute name="valign">
	  <xsl:value-of select="@valign"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="IdCheck"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="db:thead/db:row/db:entry|db:tfoot/db:row/db:entry">
    <xsl:call-template name="process.cell">
      <xsl:with-param name="cellgi">th</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Doesn't yet support non-sequential entry(tbl)s (presumably ordered by colnames that refer to colspecs that actually put the 
       elements in their correct order). -->  
  <xsl:template match="db:tbody/db:row/db:entry">
    <xsl:variable name="row.header.or.not">
      <xsl:call-template name="row.header.or.not">
        <xsl:with-param name="entry" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="process.cell">
      <xsl:with-param name="cellgi">
        <xsl:value-of select="$row.header.or.not"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="row.header.or.not">
    <xsl:param name="entry" select="."/>
    <xsl:variable name="entry.colnum">
      <xsl:call-template name="entry.colnum"/>
    </xsl:variable>
    <xsl:variable name="row.header.class.or.not">
      <xsl:call-template name="row.header.class.or.not">
        <xsl:with-param name="entry.colnum" select="$entry.colnum"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$row.header.class.or.not = '1'">th</xsl:when>
      <!-- nearest matching spanspec -->
      <xsl:when test="substring(ancestor::*[3]/db:spanspec[@spanname=current()/@spanname]/@namest,1,7) = 'header_'">th</xsl:when>
      <!-- nearest entrytbl/colspec or tgroup/colspec (where @colnum attributes are specified) -->
      <xsl:when test="substring(ancestor::*[3]/db:colspec[@colnum=$entry.colnum]/@colname,1,7) = 'header_'">th</xsl:when>
      <!-- nearest entrytbl/colspec or tgroup/colspec (where no @colnum attributes are specified and colspecs are instead ordered sequentially) -->
      <xsl:when test="substring(ancestor::*[3]/db:colspec[position()=$entry.colnum and not(@colnum)]/@colname,1,7) = 'header_'">th</xsl:when>
      <xsl:otherwise>td</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="row.header.class.or.not">
    <xsl:param name="step" select="'entry'"/>
    <xsl:param name="entry.colnum">1</xsl:param>
    <xsl:variable name="provided-class">
      <xsl:choose>
        <xsl:when test="$step='entry'">
          <xsl:value-of select="normalize-space(@class)"/>
        </xsl:when>
        <xsl:when test="$step='colspecstep1'">
          <xsl:value-of select="normalize-space(ancestor::*[3]/db:colspec[@colnum=$entry.colnum]/@class)"/>
        </xsl:when>
        <xsl:when test="$step='colspecstep2'">
          <xsl:value-of select="normalize-space(ancestor::*[3]/db:colspec[position()=$entry.colnum and not(@colnum)]/@class)"/>
        </xsl:when>
        <xsl:when test="$step='spanspec'">
          <xsl:value-of select="normalize-space(ancestor::*[3]/db:spanspec[@spanname=current()/@spanname]/@class)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="row.header.class.or.not">
      <xsl:call-template name="class-test">
        <xsl:with-param name="provided-class" select="$provided-class"/>
        <xsl:with-param name="wanted-class" select="'rowheader'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$row.header.class.or.not='1'">1</xsl:when>
      <xsl:when test="$step='entry'">
        <xsl:call-template name="row.header.class.or.not">
          <xsl:with-param name="entry.colnum" select="$entry.colnum"/>
          <xsl:with-param name="step" select="'colspecstep1'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$step='colspecstep1'">
        <xsl:call-template name="row.header.class.or.not">
          <xsl:with-param name="entry.colnum" select="$entry.colnum"/>
          <xsl:with-param name="step" select="'colspecstep2'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$step='colspecstep2'">
        <xsl:call-template name="row.header.class.or.not">
          <xsl:with-param name="entry.colnum" select="$entry.colnum"/>
          <xsl:with-param name="step" select="'spanspec'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process.cell">
    <xsl:param name="cellgi"/>

    <xsl:element name="{$cellgi}">
      <xsl:if test="@morerows">
	<xsl:attribute name="rowspan">
	  <xsl:value-of select="@morerows+1"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="(@namest and @nameend) or @spanname">
	<xsl:attribute name="colspan">
	  <xsl:call-template name="calculate.colspan"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:if test="@valign">
	<xsl:attribute name="valign">
	  <xsl:value-of select="@valign"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="IdCheck"/>
      <!-- Set colsep and rowsep attributes with CSS using the style attribute.  Turn off the borders on the left and top of any 
	   entry(tbl) because they are always ignored. -->
      <xsl:attribute name="style">
	<!-- Don't let .css files override these (hence the "!important") -->
	<xsl:text>border-left: 0 !important; border-top: 0 !important; </xsl:text>
	<!-- Give an entry a border on the right if its not in the last column of the tgroup or entrytbl, or according to any colsep 
	     attributes either in current entry or inherited from above. -->
	<xsl:choose>
	  <xsl:when test="not(following-sibling::*) or ancestor-or-self::*/@colsep='0' or ancestor::*/db:colspec/@colsep='0' or ancestor::*[3]/db:spanspec/@colsep='0'">
	    <xsl:call-template name="style.param.determiner">
	      <xsl:with-param name="style.name" select="'colsep'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="style.maker">
	      <xsl:with-param name="style.name" select="'colsep'"/>
	      <xsl:with-param name="style.param" select="'1'"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
	<!-- Give an entry a border on the bottom if its not in the very last row, or according to any rowsep attributes in current 
	     entry or inherited from above. -->
	<xsl:choose>
	  <xsl:when test="not(parent::db:row/following-sibling::db:row) or ancestor-or-self::*/@rowsep='0' or ancestor::*/db:colspec/@rowsep='0' or ancestor::*[3]/db:spanspec/@rowsep='0' or @morerows">
	    <xsl:call-template name="style.param.determiner">
	      <xsl:with-param name="style.name" select="'rowsep'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="style.maker">
	      <xsl:with-param name="style.name" select="'rowsep'"/>
	      <xsl:with-param name="style.param" select="'1'"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
	<!-- Give the cell alignment to the left unless otherwise declared or unless the cell is affected by a spanspec (whose default 
	     alignment is to the center). -->
	<xsl:choose>
	  <xsl:when test="ancestor-or-self::*/@align!='left' or ancestor::*/db:colspec/@align!='left' or @spanname">
	    <xsl:call-template name="style.param.determiner">
	      <xsl:with-param name="style.name" select="'align'"/>
            </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="style.maker">
	     <xsl:with-param name="style.name" select="'align'"/>
	      <xsl:with-param name="style.param" select="'left'"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <!-- Add any possible char and charoff attributes -->
      <xsl:if test="ancestor-or-self::*/@char or ancestor::*/db:colspec/@char or ancestor::*[3]/db:spanspec/@char">
	<xsl:call-template name="style.param.determiner">
	  <xsl:with-param name="style.name" select="'char'"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="ancestor-or-self::*/@charoff or ancestor::*/db:colspec/@charoff or ancestor::*[3]/db:spanspec/@charoff">
	<xsl:call-template name="style.param.determiner">
	  <xsl:with-param name="style.name" select="'charoff'"/>
	</xsl:call-template>
      </xsl:if>

      <xsl:choose>
	<xsl:when test="count(node()) = 0">
	  <xsl:text> </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!-- This template checks for instances of certain attributes (colsep, rowsep, align, char, and charoff) in certain places in the 
       table, going up in the following inheritance order: entry attributes > row attributes (rowsep) > colspecs in nearest thead 
       or nearest tfoot > nearest spanspec references > nearest colspec references not in thead or tfoot > entrytbl or tgroup 
       attributes > table attributes (if no intermediary entrybl), with pit stops first to turn borders off at the bottom and left of 
       the table's very last rows and columns, respectively.  If no attributes are found, the default values are provided. -->
  <xsl:template name="style.param.determiner">
    <xsl:param name="style.name"/>
    <xsl:variable name="entry.colnum">
      <xsl:call-template name="entry.colnum"/>
    </xsl:variable>
    <xsl:choose>
      <!-- If there is not a subsequent row of columns in the table (or entrytbl, if currently located there), don't give entry(tbl) a 
	   bottom border.  Watch out for the case where the current entry is not in the last row but stretches all the way down there 
	   anyway via @morerows.  Additionally, watch out for cases where the current entry(tbl) is at the bottom of a tgroup, but 
	   there are other tgroups that follow.  -->
      <xsl:when test="$style.name='rowsep' and          (parent::db:row[not(following-sibling::db:row)]           and not(ancestor::*[2][preceding-sibling::db:tfoot or self::db:thead]      or (ancestor::db:tgroup[following-sibling::db:tgroup] and not(ancestor::db:entrytbl))) or          @morerows=count(parent::db:row/following-sibling::db:row)           and not(ancestor::*[2][preceding-sibling::db:tfoot or self::db:thead]      or (ancestor::db:tgroup[following-sibling::db:tgroup] and not(ancestor::db:entrytbl))))">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="'0'"/>
	  <xsl:with-param name="style.name" select="'rowsep'"/>
	</xsl:call-template>
      </xsl:when>
      <!-- If the right edge (essentially the entry.ending.colnum) of the current entry(tbl) is at the end of the row (and not just 
	   bordering an entry from a previous row whose @morerows attribute makes it extend to the current entry(tbl)'s edge), don't 
	   give it a border on the right. -->
      <xsl:when test="$style.name='colsep' and          not(following-sibling::*) and          not(parent::db:row/preceding-sibling::db:row/db:entry[position()=last()][(@morerows + count(parent::db:row/preceding-sibling::db:row)) &gt;= count(current()/parent::db:row/preceding-sibling::db:row)])">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="'0'"/>
	  <xsl:with-param name="style.name" select="'colsep'"/>
	</xsl:call-template>
      </xsl:when>
      <!-- if entry has a colsep/rowsep/align/char/charoff attribute, use it -->
      <xsl:when test="attribute::*[local-name()=$style.name]">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- if nearest row has such an attribute, use it -->
      <xsl:when test="$style.name='rowsep' and parent::db:row/@rowsep">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="parent::db:row/@rowsep"/>
	  <xsl:with-param name="style.name" select="'rowsep'"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest thead/colspec or tfoot/colspec (notice these are not colspecs as children of tgroup or entrytbl)
	   (where @colnum attributes are specified) -->
      <xsl:when test="ancestor::*[2]/db:colspec[@colnum=$entry.colnum]/attribute::*[local-name()=$style.name]">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[2]/db:colspec[@colnum=$entry.colnum]/attribute::*[local-name()=$style.name]"/> 
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest thead/colspec or tfoot/colspec (notice these are not tgroups as children of tgroup or entrytbl) 
	   (where no @colnum attributes are specified and colspecs are instead ordered sequentially) -->
      <xsl:when test="ancestor::*[2]/db:colspec[position()=$entry.colnum and not(@colnum)]/attribute::*[local-name()=$style.name]">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[2]/db:colspec[position()=$entry.colnum and not(@colnum)]/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest matching spanspec (if a thead or tfoot have colspecs, however, the tgroup or entrytbl's colspecs are ignored) -->
      <xsl:when test="ancestor::*[3]/db:spanspec[@spanname=current()/@spanname]/attribute::*[local-name()=$style.name] and not(ancestor::*[2]/db:colspec)">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[3]/db:spanspec[@spanname=current()/@spanname]/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest entrytbl/colspec or tgroup/colspec (where @colnum attributes are specified) -->
      <xsl:when test="ancestor::*[3]/db:colspec[@colnum=$entry.colnum]/attribute::*[local-name()=$style.name] and not(ancestor::*[2]/db:colspec)">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[3]/db:colspec[@colnum=$entry.colnum]/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest entrytbl/colspec or tgroup/colspec (where no @colnum attributes are specified and colspecs are instead ordered sequentially) -->
      <xsl:when test="ancestor::*[3]/db:colspec[position()=$entry.colnum and not(@colnum)]/attribute::*[local-name()=$style.name] and not(ancestor::*[2]/db:colspec)">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[3]/db:colspec[position()=$entry.colnum]/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- nearest entrytbl or tgroup -->
      <xsl:when test="ancestor::*[3]/attribute::*[local-name()=$style.name]">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::*[3]/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- if table has a colsep/rowsep/align/char/charoff declaration, use it, unless current entry is in an entrytbl, in which case 
	   table's attributes cannot be inherited -->
      <xsl:when test="ancestor::db:table/attribute::*[local-name()=$style.name] and not(ancestor::db:entrytbl)">
	<xsl:call-template name="style.maker">
	  <xsl:with-param name="style.param" select="ancestor::db:table/attribute::*[local-name()=$style.name]"/>
	  <xsl:with-param name="style.name" select="$style.name"/>
	</xsl:call-template>
      </xsl:when>
      <!-- for everything else, default to having a border if testing borders and left alignment if testing alignment (with the 
	   special exception of aligning elements defined by a spanspec (via @spanname) to the center) -->
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="$style.name='rowsep' or $style.name='colsep'">
	    <xsl:call-template name="style.maker">
	      <xsl:with-param name="style.param" select="'1'"/>
	      <xsl:with-param name="style.name" select="$style.name"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="$style.name='align'">
	    <xsl:choose>
	      <!-- The spec says that the default alignment for spanspec-defined elements is center if not specified elsewhere -->
	      <xsl:when test="@spanname and not(ancestor::*[2]/db:colspec)">
		<xsl:call-template name="style.maker">
		  <xsl:with-param name="style.param" select="'center'"/>
		  <xsl:with-param name="style.name" select="'align'"/>
		</xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="style.maker">
		  <xsl:with-param name="style.param" select="'left'"/>
		  <xsl:with-param name="style.name" select="'align'"/>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- If there were no @char or @charoff attributes explicitly defined earlier, don't add any as a "default" value, because 
	       the default would be to just leave these things out. -->
	  <xsl:when test="$style.name='char' or $style.name='charoff'">
	    <xsl:call-template name="style.maker">
	      <xsl:with-param name="style.param" select="'null'"/>
	      <xsl:with-param name="style.name" select="$style.name"/>
	    </xsl:call-template>
	  </xsl:when>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template adds border styles, alignments, and char-related attributes to the HTML for the current entry(tbl), depending on 
       how those attributes were determined in style.param.determiner (or in the process.cell/db:entrytbl templates if the current 
       entry(tbl) didn't pass through style.param.determiner). -->
  <xsl:template name="style.maker">
    <xsl:param name="style.name"/>
    <xsl:param name="style.param"/>
    <xsl:choose>
      <xsl:when test="$style.name='colsep'">
	<xsl:choose>
	  <xsl:when test="$style.param='0'">
	    <xsl:text>border-right: 0 !important; </xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>border-right: 1px solid; </xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$style.name='rowsep'">
	<xsl:choose>
	  <xsl:when test="$style.param='0'">
	    <xsl:text>border-bottom: 0 !important; </xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>border-bottom: 1px solid; </xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$style.name='align'">
	<xsl:text>text-align: </xsl:text>
	<xsl:value-of select="$style.param"/>
	<xsl:text> !important; </xsl:text>
      </xsl:when>
      <xsl:when test="$style.name='char' or $style.name='charoff'">
	<xsl:choose>
	  <xsl:when test="$style.param='null'"/>
	  <xsl:otherwise>
	    <xsl:attribute name="{$style.name}">
	      <xsl:value-of select="$style.param"/>
	    </xsl:attribute>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- When looking for an entry(tbl)'s colnum, start with a @spanname, then @namest, then @colname, then figure it out manually if 
       none of those attributes are present.  If the entry(tbl) is inside a thead or tfoot with its own set of colspecs, however, 
       those colspecs take precedence and any @spanname is ignored (since thead and tfoot can't take spanspec). -->
  <xsl:template name="entry.colnum">
    <xsl:param name="entry" select="."/>
    <xsl:choose>
      <xsl:when test="$entry/ancestor::*[3]/db:spanspec[@spanname=$entry/@spanname] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:variable name="namest" select="$entry/ancestor::*[3]/db:spanspec[@spanname=$entry/@spanname]/@namest"/>
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$namest]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@namest]">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@namest]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@colname]">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@colname]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@namest] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@namest]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@colname] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@colname]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="count($entry/../*) = $entry/ancestor::*[3]/@cols">
	<xsl:value-of select="count($entry/preceding-sibling::*) + 1"/>
      </xsl:when>
      <xsl:when test="$entry/parent::db:row/preceding-sibling::db:row/db:entry[(@morerows + count(parent::db:row/preceding-sibling::db:row)) &gt;= count($entry/parent::db:row/preceding-sibling::db:row)]">
        <xsl:call-template name="morerows.check">
          <xsl:with-param name="mc.entry" select="$entry"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pcol">
          <xsl:call-template name="entry.ending.colnum">
            <xsl:with-param name="entry" select="$entry/preceding-sibling::*[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$pcol + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="entry.ending.colnum">
    <xsl:param name="entry" select="."/>
    <xsl:choose>
      <xsl:when test="$entry/ancestor::*[3]/db:spanspec[@spanname=$entry/@spanname] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:variable name="nameend" select="$entry/ancestor::*[3]/db:spanspec[@spanname=$entry/@spanname]/@nameend"/>
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$nameend]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@nameend]">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@nameend]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@colname]">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$entry/@colname]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@nameend] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@nameend]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@colname] and not($entry/ancestor::*[2]/db:colspec)">
	<xsl:call-template name="colspec.colnum">
	  <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$entry/@colname]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="count($entry/preceding-sibling::*) = 0">1</xsl:when>
      <xsl:otherwise>
	<xsl:variable name="pcol">
	  <xsl:call-template name="entry.ending.colnum">
	    <xsl:with-param name="entry" select="$entry/preceding-sibling::*[1]"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$pcol + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- The following 5 templates are used to determine the colnum of an entry(tbl) where there is a @morerows attribute in the entry 
       of a previous row which straddles the space to the left of a particular column.  For example, they would determine the colnum 
       of the "d" entry in this table (whose colnum is otherwise obscured by the "a" entry if "d" doesn't have a @colname, @namest or 
       @spanname attribute) in the following way: 
	 ___________
	| a | b | c |
	|   |___|___|
	|   | d | e |
	|___|___|___|

     - mc.cols.initialization builds a string that looks like this: ;0;0;0; (basically it serves like an array, filled with 
       values of rowspans for each column in the table)
     - The 1st iteration of mc.cols.assignment (entry "a") changes the string to: ;2;0;0; (since entry "a" spans two rows)
     - The 2nd iteration of mc.cols.assignment (entry "b") changes the string to: ;2;1;0; (since entry "b" spans one row, its own)
     - The 3rd iteration of mc.cols.assignment (entry "c") changes the string to: ;2;1;1; (since entry "c" spans one row, its own)
     - mc.cols.reset subtracts 1 from each of the values in the string, changing ;2;1;1; to ;1;0;0;
     - Since the fourth entry ("d") is matched in morerows.check, we look in mc.determine.colnum to see which column it is in, 
       based on the string we've made up to that point: 1;0;0;
     - We iterate through the string to determine where the entry can "fit" (i.e., where there isn't already a rowspan, represented by 
       any positive number).  We find this in the 2nd value of the string and therefore determine that the "d" entry is in column 2.
  -->

  <xsl:template name="morerows.check">
    <xsl:param name="mc.entry"/> <!-- all passed params must be declared, even if they don't need a default -->
    <xsl:param name="mc.first.part" select="';'"/> <!-- Used primarily for mc.cols.assignment below -->
    <xsl:param name="mc.row.number.being.checked" select="'1'"/> <!-- Number of row we're in during testing (start at top) -->
    <xsl:param name="mc.entry.number.being.checked" select="'1'"/> <!-- Number of column we're in during testing (start at left) -->
    <xsl:param name="mc.cols.quantity" select="$mc.entry/ancestor::*[3]/@cols"/>
    <xsl:param name="mc.cols"> <!-- A semi-colon separated string that shows us how many rows are being occupied by a particular 
				     row's entries.  Start of by making it look something like this: ;0;0;0;0;...;0; -->
      <xsl:call-template name="mc.cols.initialization">
	<xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	<xsl:with-param name="mc.cols" select="';'"/>
      </xsl:call-template>
    </xsl:param>
    <!-- Start at the top left (because we have to start accounting for @morerows beginning there) until we make it down to the row 
	 with the entry(tbl) whose colnum we're trying to determine. -->
    <xsl:choose>
      <xsl:when test="generate-id($mc.entry/ancestor::*[2]/db:row[position()=$mc.row.number.being.checked]/child::*[position()=$mc.entry.number.being.checked])                 = generate-id($mc.entry)">
	<xsl:call-template name="mc.determine.colnum">
	  <xsl:with-param name="mc.cols" select="$mc.cols"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="mc.cols.assignment">
	  <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
	  <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
	  <xsl:with-param name="mc.entry" select="$mc.entry"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	  <xsl:with-param name="mc.cols" select="$mc.cols"/>
	  <xsl:with-param name="mc.first.part" select="$mc.first.part"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mc.cols.initialization">
    <!-- Say, for example, the tgroup has @cols equal to 4.  $mc.cols will look like this: ;0;0;0;0; -->
    <xsl:param name="mci.iteration" select="'1'"/>
    <xsl:param name="mc.cols"/>
    <xsl:param name="mc.cols.quantity"/>
    <xsl:choose>
      <xsl:when test="$mci.iteration &gt; $mc.cols.quantity">
        <xsl:value-of select="$mc.cols"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mc.cols.initialization">
          <xsl:with-param name="mci.iteration" select="$mci.iteration + 1"/>
          <xsl:with-param name="mc.cols" select="concat($mc.cols,'0;')"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
       </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mc.cols.assignment">
    <xsl:param name="mc.cols"/>
    <xsl:param name="mc.first.part"/>
    <xsl:param name="mca.number.in.question">
      <xsl:choose>
	<!-- If nobody has added an entry(tbl) who's colnum is greater than the @cols attribute, determine the number by removing the 
	     "first part" from the mc.cols string, then taking the string before the first separator (';') -->
 	<xsl:when test="$mc.cols != $mc.first.part">
          <xsl:value-of select="substring-before(substring-after($mc.cols,$mc.first.part),';')"/>
	</xsl:when>
	<!-- Else, tack on another number to the string -->
	<xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="mca.last.part">
      <xsl:choose>
	<!-- If nobody has added an entry(tbl) who's colnum is greater than the @cols attribute, determine the "last part" by removing 
	     the "first part" and "number in question" from the cols string -->
	<xsl:when test="$mc.cols != $mc.first.part">
	  <xsl:value-of select="substring-after($mc.cols,concat($mc.first.part,$mca.number.in.question))"/>
	</xsl:when>
	<!-- Else, tack on another separator -->
	<xsl:otherwise>;</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="mc.cols.quantity"/>
    <xsl:param name="mc.entry"/>
    <xsl:param name="mc.entry.number.being.checked"/>
    <xsl:param name="mc.row.number.being.checked"/>
    <xsl:param name="mca.entry.being.checked" select="$mc.entry/ancestor::*[2]/db:row[position()=$mc.row.number.being.checked]/child::*[position()=$mc.entry.number.being.checked]"/>
    <xsl:param name="mca.rowspan">
      <xsl:choose>
      <!-- If there's a morerows attribute, the entry(tbl) spans the number of that attribute plus 1. -->
	<xsl:when test="$mca.entry.being.checked/@morerows">
	  <xsl:value-of select="$mca.entry.being.checked/@morerows + 1"/>
	</xsl:when>
	<!-- If there's not a morerows attribute, the entry(tbl) only spans one row -->
	<xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="mca.colspan">
      <xsl:choose>
 	<!-- If there entry(tbl) has a span, calculate how long it is -->
	<xsl:when test="($mca.entry.being.checked/@namest and $mca.entry.being.checked/@nameend) or $mca.entry.being.checked/@spanname">
	  <xsl:call-template name="calculate.colspan">
	    <xsl:with-param name="entry" select="$mca.entry.being.checked"/>
	  </xsl:call-template>
	</xsl:when>
	<!-- Otherwise, the entry(tbl) only spans one column -->
	<xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- If somebody has added an entry(tbl) who's colnum is greater than the @cols attribute, bump the cols.quantity up -->
    <xsl:param name="mc.cols.quantity.test">
      <xsl:choose>
	<xsl:when test="$mc.first.part = $mc.cols">
	  <xsl:value-of select="$mc.cols.quantity + 1"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$mc.cols.quantity"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Assign the colnum if it can be found -->
    <xsl:choose>
      <!-- If the column has a marker that's higher than 0, something is already sitting there (either a previous entry in the same 
	   row or a morerows in the entry of a previous row. -->
      <xsl:when test="$mca.number.in.question != 0">
	<xsl:call-template name="mc.cols.assignment">
	  <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
	  <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
	  <xsl:with-param name="mc.entry" select="$mc.entry"/>
	  <xsl:with-param name="mc.cols" select="$mc.cols"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	  <xsl:with-param name="mc.first.part" select="concat($mc.first.part,$mca.number.in.question,';')"/>
	</xsl:call-template>
      </xsl:when>
      <!-- Otherwise, the entry being checked can fit there. -->
      <xsl:otherwise>
	<xsl:choose>
	<!-- If the entry we're on in morerows.check has a colspan, also assign the other corresponding colnums. -->
	  <xsl:when test="$mca.colspan &gt; 1">
	    <xsl:call-template name="mc.cols.assignment">
	      <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
	      <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
	      <xsl:with-param name="mc.entry" select="$mc.entry"/>
	      <xsl:with-param name="mca.colspan" select="$mca.colspan - 1"/>
	      <xsl:with-param name="mca.rowspan" select="$mca.rowspan"/>
	      <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity.test"/>
	      <xsl:with-param name="mc.cols" select="concat($mc.first.part,$mca.rowspan,$mca.last.part)"/>
	      <xsl:with-param name="mc.first.part" select="concat($mc.first.part,$mca.rowspan,';')"/>
	    </xsl:call-template>
	  </xsl:when>
	  <!-- If the entry doesn't span cols, just assign the one colnum. -->
	  <xsl:otherwise>
	    <xsl:choose>
	      <!-- If not at new row (there's a following-sibling entry(tbl)) -->
	      <xsl:when test="boolean($mc.entry/ancestor::*[2]/db:row[position()=$mc.row.number.being.checked]/child::*[position()=$mc.entry.number.being.checked][following-sibling::*])">
		<xsl:call-template name="morerows.check">
		  <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
		  <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked + 1"/>
		  <xsl:with-param name="mc.entry" select="$mc.entry"/>
		  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity.test"/>
		  <xsl:with-param name="mc.cols" select="concat($mc.first.part,$mca.rowspan,$mca.last.part)"/>
		  <xsl:with-param name="mc.first.part" select="concat($mc.first.part,$mca.rowspan,';')"/>
		</xsl:call-template>
	      </xsl:when>
	      <!-- If at new row -->
	      <xsl:otherwise>
		<xsl:call-template name="mc.cols.reset">
		  <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
		  <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
		  <xsl:with-param name="mc.entry" select="$mc.entry"/>
		  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity.test"/>
		  <xsl:with-param name="mc.cols" select="concat($mc.first.part,$mca.rowspan,$mca.last.part)"/>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mc.cols.reset">
    <xsl:param name="mc.cols"/>
    <xsl:param name="mcr.iteration" select="'1'"/>
    <xsl:param name="mcr.first.part" select="';'"/>
    <xsl:param name="mcr.number.in.question" select="substring-before(substring-after($mc.cols,$mcr.first.part),';')"/>
    <xsl:param name="mcr.last.part" select="substring-after($mc.cols,concat($mcr.first.part,$mcr.number.in.question))"/>
    <xsl:param name="mc.row.number.being.checked"/>
    <xsl:param name="mc.entry.number.being.checked"/>
    <xsl:param name="mc.entry"/>
    <xsl:param name="mc.cols.quantity"/>
    <!-- Go through each number and subtract 1 from it (unless it's somehow less than 1, in which case return 0). -->
    <xsl:choose>
      <xsl:when test="$mcr.iteration &gt; $mc.cols.quantity">
	<xsl:call-template name="morerows.check">
	  <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked + 1"/>
	  <xsl:with-param name="mc.entry.number.being.checked" select="'1'"/>
	  <xsl:with-param name="mc.entry" select="$mc.entry"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	  <xsl:with-param name="mc.cols" select="$mc.cols"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<!-- If somebody failed to put in an entry(tbl) somewhere (i.e. all the entries in a row don't add up to the number in the 
	     @cols attribute), just set it to 0 instead of a negative number.  -->
	<xsl:choose>
	  <xsl:when test="$mcr.number.in.question &lt; 1">
	    <xsl:call-template name="mc.cols.reset">
	      <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
	      <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
	      <xsl:with-param name="mc.entry" select="$mc.entry"/>
	      <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	      <xsl:with-param name="mc.cols" select="concat($mcr.first.part,0,$mcr.last.part)"/>
	      <xsl:with-param name="mcr.first.part" select="concat($mcr.first.part,'0;')"/>
	      <xsl:with-param name="mcr.iteration" select="$mcr.iteration + 1"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="mc.cols.reset">
	      <xsl:with-param name="mc.row.number.being.checked" select="$mc.row.number.being.checked"/>
	      <xsl:with-param name="mc.entry.number.being.checked" select="$mc.entry.number.being.checked"/>
	      <xsl:with-param name="mc.entry" select="$mc.entry"/>
	      <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	      <xsl:with-param name="mc.cols" select="concat($mcr.first.part,$mcr.number.in.question - 1,$mcr.last.part)"/>
	      <xsl:with-param name="mcr.first.part" select="concat($mcr.first.part,$mcr.number.in.question - 1,';')"/>
	      <xsl:with-param name="mcr.iteration" select="$mcr.iteration + 1"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mc.determine.colnum">
    <xsl:param name="mc.cols"/>
    <xsl:param name="mc.first.part" select="';'"/>
    <xsl:param name="mdc.iteration" select="'1'"/>
    <xsl:param name="mdc.number.in.question" select="substring-before(substring-after($mc.cols,$mc.first.part),';')"/>
    <xsl:param name="mc.cols.quantity"/>
    <xsl:choose>
      <xsl:when test="($mdc.number.in.question = 0) or ($mdc.iteration &gt; $mc.cols.quantity)">
	<xsl:value-of select="$mdc.iteration"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="mc.determine.colnum">
	  <xsl:with-param name="mc.first.part" select="concat($mc.first.part,$mdc.number.in.question,';')"/>
	  <xsl:with-param name="mc.cols" select="$mc.cols"/>
	  <xsl:with-param name="mc.cols.quantity" select="$mc.cols.quantity"/>
	  <xsl:with-param name="mdc.iteration" select="$mdc.iteration + 1"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="colspec.colnum">
    <xsl:param name="colspec" select="."/>
    <xsl:choose>
      <xsl:when test="$colspec/@colnum">
	<xsl:value-of select="$colspec/@colnum"/>
      </xsl:when>
      <xsl:when test="$colspec/preceding-sibling::db:colspec">
	<xsl:variable name="prec.colspec.colnum">
	  <xsl:call-template name="colspec.colnum">
	    <xsl:with-param name="colspec" select="$colspec/preceding-sibling::db:colspec[1]"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:value-of select="$prec.colspec.colnum + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="col.maker">
    <xsl:param name="cm.iteration" select="'1'"/>
      <!-- If thead or tfoot has a colspec with a colwidth attribute, it takes precedence ??? over a colwidth directly under a 
	   tgroup or entrytbl.  Set this colwidth attribute as a param. -->
      <xsl:param name="colwidth">
      <xsl:choose>
	<xsl:when test="child::*/db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))]/@colwidth">
	  <xsl:value-of select="child::*/db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))]/@colwidth"/>
	</xsl:when>
	<xsl:when test="db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))]/@colwidth">
	  <xsl:value-of select="db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))]/@colwidth"/>
	</xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$cm.iteration &gt; @cols"/>
      <xsl:otherwise>
	<col>
	  <!-- Do something if this particular column (matched by the colspec's colnum attribute) has an actual colwidth. -->
	  <xsl:choose>
	    <xsl:when test="db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))][@colwidth!=''] or         child::*/db:colspec[(@colnum=$cm.iteration) or (position()=$cm.iteration and not(@colnum))][@colwidth!='']">
	      <!-- If the colwidth is expressed in 'in', 'em', 'cm', 'pc', 'pi', 'mm', or 'ex', express this width with a style 
		   attribute instead of a width attribute, since browsers can actually handle this. -->
	      <xsl:choose>
		<xsl:when test="contains($colwidth,'in') or      contains($colwidth,'em') or      contains($colwidth,'cm') or      contains($colwidth,'pc') or      contains($colwidth,'pi') or      contains($colwidth,'mm') or      contains($colwidth,'ex')">
		  <xsl:attribute name="style">
		    <xsl:text>width: </xsl:text>
		    <!-- If 'pi' is used for 'picas' (as given in an example in the CALS spec) instead of 'pc' (as can be rendered by 
			 browsers), change it to 'pc'. -->
		    <xsl:choose>
		      <xsl:when test="contains($colwidth,'pi')">
			<xsl:value-of select="substring-before($colwidth,'pi')"/>
			<xsl:text>pc</xsl:text>
		      </xsl:when>
		      <xsl:otherwise>
			<xsl:value-of select="$colwidth"/>
		      </xsl:otherwise>
		    </xsl:choose>
		  </xsl:attribute>
		</xsl:when>
		<!-- Otherwise, such as when the width is expressed in '%' (percentages), 'pt', 'px', '*' (relative widths) or just a 
		     number, use the width attribute, which browsers can render just as well in those cases (if not better, as in the 
		     case of relative widths). -->
		<xsl:otherwise>
		  <xsl:attribute name="width">
		    <xsl:value-of select="$colwidth"/>
		  </xsl:attribute>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:when>
	    <!-- If no colwidth was declared for a certain column, just give it a width of a '1*' (default as specified by CALS 
		 spec), and which also makes other relative values (e.g. '3*') actually work in the browsers.. -->
	    <xsl:otherwise>
	      <xsl:attribute name="width">
		<xsl:text>1*</xsl:text>
	      </xsl:attribute>
	    </xsl:otherwise>
	  </xsl:choose>
	</col>
	<!-- Go to the next column and make a col element for it, if it exists. -->
	<xsl:call-template name="col.maker">
	  <xsl:with-param name="cm.iteration" select="$cm.iteration + 1"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="calculate.colspan">
    <xsl:param name="entry" select="."/>
    <xsl:variable name="spanname" select="$entry/@spanname"/>
    <xsl:variable name="namest">
      <xsl:choose>
	<xsl:when test="$entry/@spanname and not($entry/ancestor::*[2]/db:colspec)">
	  <xsl:value-of select="$entry/ancestor::*[3]/db:spanspec[@spanname=$spanname]/@namest"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$entry/@namest"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nameend">
      <xsl:choose>
	<xsl:when test="$entry/@spanname and not($entry/ancestor::*[2]/db:colspec)">
	  <xsl:value-of select="$entry/ancestor::*[3]/db:spanspec[@spanname=$spanname]/@nameend"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$entry/@nameend"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="scol">
      <xsl:choose>
	<xsl:when test="$entry/ancestor::*[2]/db:colspec">
	  <xsl:call-template name="colspec.colnum">
	    <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$namest]"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="colspec.colnum">
	    <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$namest]"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ecol">
      <xsl:choose>
	<xsl:when test="$entry/ancestor::*[2]/db:colspec">
	  <xsl:call-template name="colspec.colnum">
	    <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/db:colspec[@colname=$nameend]"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="colspec.colnum">
	    <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/db:colspec[@colname=$nameend]"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$ecol - $scol + 1"/>
  </xsl:template>


</xsl:stylesheet>
