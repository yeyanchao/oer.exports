<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ext="http://cnx.org/ns/docbook+"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  version="1.0">

<!-- This file converts dbk files to html (maybe chunked) which is used in EPUB and PDF generation.
    * Stores customizations and docbook settings specific to Connexions
    * Shifts images that were converted from MathML so they line up with text nicely
    * Puts equation numbers on the RHS of an equation
    * Disables equation and figure numbering inside things like examples and glossaries
    * Adds @class attributes to elements for custom styling (like c:rule, c:figure)
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="dbk2xhtml-overrides.xsl"/>
<xsl:import href="dbkplus.xsl"/>
<xsl:include href="table2epub.xsl"/>
<xsl:include href="bibtex2epub.xsl"/>


<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="xref.with.number.and.title">0</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>
<xsl:param name="admon.style" select="''"/><!-- notes get margins by default -->

<!-- Prevent a TOC from being generated for module books -->
<xsl:param name="generate.toc">
  <xsl:choose>
    <xsl:when test="db:book/@ext:element='module'">
      book nop
    </xsl:when>
    <xsl:otherwise>
      book toc,title
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="toc.list.type">ul</xsl:param>
<xsl:param name="toc.dd.type">li</xsl:param>
<xsl:param name="toc.listitem.type">li</xsl:param>

<xsl:output indent="no" method="xml" omit-xml-declaration="yes" encoding="ASCII"/>

<!-- Discard any c:media tags that haven't been converted into docbook images or links to the content -->
<xsl:template match="c:media"/>

<!-- Give links a class based on the target-id element (so CSS3 knows how to create a label for them) -->
<xsl:key name="id" match="*[@xml:id]" use="@xml:id"/>
<xsl:template match="db:xref[@linkend]" mode="class.value">
  <xsl:param name="class" select="local-name()"/>

  <xsl:variable name="target" select="key('id', @linkend)"/>
  <xsl:value-of select="$class"/>
  <xsl:if test="$target">
    <xsl:message>LOG: INFO: Adding target class to link "<xsl:value-of select="local-name($target)"/>"</xsl:message>
    <xsl:text> target-</xsl:text>
    <xsl:choose>
      <xsl:when test="$target[parent::db:figure]">
        <xsl:text>subfigure</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="local-name($target)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <!-- if a link contains text let CSS know to use the label instead of attempting to autogenerate it -->
  <xsl:if test="text()">
    <xsl:text> labeled</xsl:text>
  </xsl:if>
</xsl:template>


<!-- ============================================== -->
<!-- New Feature: @class='problems-exercises'  -->
<!-- ============================================== -->

<!-- Render problem sections at the bottom of a chapter -->

<xsl:template match="db:chapter">

	<div><xsl:call-template name="common.html.attributes"/>
    <xsl:attribute name="id">
		  <xsl:call-template name="object.id"/>
    </xsl:attribute>
		<xsl:call-template name="chapter.titlepage"/>
    <xsl:apply-templates mode="cnx.intro" select="d:section">
      <xsl:with-param name="toc">
        <xsl:variable name="toc.params">
          <xsl:call-template name="find.path.params">
            <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="contains($toc.params, 'toc')">
          <xsl:call-template name="component.toc">
            <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
          </xsl:call-template>
          <xsl:call-template name="component.toc.separator"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select="node()[not(contains(@class,'introduction'))]"/>
		<xsl:call-template name="cnx.eoc"/>
    <xsl:call-template name="cnx.solutions"/>
  </div>
</xsl:template>

<!-- Used for deciding which solutions should be moved to the back of the book -->
<xsl:key name="cnx.eoc-key" match="processing-instruction('cnx.eoc')" use="substring-before(substring-after(concat(' ', .),' class=&quot;'), '&quot;')"/>

<xsl:template name="cnx.eoc">
 	<!-- <?cnx.eoc class=review title=Review Notes?> -->
 	<xsl:variable name="context" select="."/>
	<xsl:for-each select=".//processing-instruction('cnx.eoc')">
		<xsl:variable name="val" select="concat(' ', .)"/>
		<xsl:variable name="class" select="substring-before(substring-after($val,' class=&quot;'), '&quot;')"/>
		<xsl:variable name="title" select="substring-before(substring-after(.,' title=&quot;'),'&quot;')"/>

			<xsl:message>LOG: INFO: Looking for some end-of-chapter matter: class=[<xsl:value-of select="$class"/>] title=[<xsl:value-of select="$title"/>] inside a [<xsl:value-of select="name()"/>]</xsl:message>
		
		<xsl:if test="string-length($class) &gt; 0 and $context//*[contains(@class,$class)]">
			<xsl:message>LOG: INFO: Found some end-of-chapter matter: class=[<xsl:value-of select="$class"/>] title=[<xsl:value-of select="$title"/>]</xsl:message>
			<xsl:call-template name="cnx.end-of-chapter-problems">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="title">
					<xsl:value-of select="$title"/>
				</xsl:with-param>
				<xsl:with-param name="attribute" select="$class"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

<xsl:template name="cnx.end-of-chapter-problems">
	<xsl:param name="context" select="."/>
	<xsl:param name="title"/>
	<xsl:param name="attribute"/>

	<!-- Create a 1-column Listing of "Conceptual Questions" or "end-of-chapter Problems" -->
	<xsl:if test="count($context//*[contains(@class,$attribute)]) &gt; 0">
		<xsl:comment>CNX: Start Area: "<xsl:value-of select="$title"/>"</xsl:comment>
		
		<div class="cnx-eoc {$attribute}">
		<div class="title">
			<span>
				<xsl:copy-of select="$title"/>
			</span>
		</div>

		<!-- This for-each is the main section (1.4 Newton) to print section title -->
		<xsl:for-each select="$context/db:section">
			<xsl:variable name="sectionId">
				<xsl:call-template name="object.id"/>
			</xsl:variable>
			<div class="section">
			  <xsl:attribute name="class">
			    <xsl:text>section</xsl:text>
          <xsl:if test="not(descendant::*[contains(@class,$attribute)])">
            <xsl:text> empty</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <!-- Print the section title and link back to it -->
        <div class="title">
          <a href="#{$sectionId}">
            <xsl:apply-templates select="." mode="object.title.markup">
              <xsl:with-param name="allow-anchors" select="0"/>
            </xsl:apply-templates>
          </a>
        </div>
        <!-- This for-each renders all the sections and exercises and numbers them -->
        <div class="body">
          <xsl:apply-templates select="descendant::*[contains(@class,$attribute)]/node()[not(self::db:title)]">
            <xsl:with-param name="render" select="true()"/>
          </xsl:apply-templates>
        </div>
      </div>
		</xsl:for-each>
    </div>
	</xsl:if>
</xsl:template>

<xsl:template mode="cnx.chapter.summary" match="db:section[not(contains(@class,'introduction')) and db:sectioninfo/db:abstract]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <tr>
    <td>
      <div class="cnx-summary-number">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div class="cnx-summary-title">
        <xsl:apply-templates select="db:sectioninfo/db:abstract">
          <xsl:with-param name="render" select="true()"/>
        </xsl:apply-templates>
      </div>
    </td>
  </tr>
</xsl:template>


<!-- Render the solutions to evercises at the end of the chapter -->
<xsl:template name="cnx.solutions">
  <xsl:variable name="solutions">
    <xsl:apply-templates select=".//ext:solution" mode="cnx.eoc.solutions"/>
  </xsl:variable>
  <xsl:if test="count($solutions) != 0">
    <div class="cnx-eoc solutions">
      <div class="title">Solutions</div>
      <xsl:copy-of select="$solutions" />
    </div>
  </xsl:if>
</xsl:template>

<!-- By default, solutions are rendered in-place. -->
<xsl:template mode="cnx.eoc.solutions" match="ext:solution" />
<!-- If it's a solution that goes at the end of a chapter then give it a number -->
<xsl:template mode="cnx.eoc.solutions" match="ext:solution
      [key('cnx.eoc-key', ancestor::*[@class]/@class)]
    |
      ext:solution[ancestor::db:example][@print-placement='end' or (../@print-placement='end' and not(@print-placement='here'))]">
  <xsl:variable name="exerciseId" select="parent::ext:exercise/@xml:id"/>
  <div class="solution" id="{@xml:id}">
    <a class="number" href="#{$exerciseId}">
      <xsl:choose>
        <xsl:when test="ext:label">
          <xsl:apply-templates select="ext:label" mode="cnx.label"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="parent::ext:exercise" mode="number"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="count(key('solution', $exerciseId)) > 1">
        <xsl:number count="ext:solution[parent::ext:exercise/@xml:id=$exerciseId]" level="any" format=" A"/>
      </xsl:if>
    </a>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="node()"/>
  </div>
</xsl:template>

<!-- If it's a solution that goes at the end of a chapter, AND it's just a para, unwrap the para -->
<xsl:template match="ext:solution[count(*)=1 and count(db:para)=1]/db:para">
  <xsl:apply-templates select="node()"/>
</xsl:template>


<!-- Renders an abstract onnly when "render" is set to true().
-->
<xsl:template match="d:abstract" mode="titlepage.mode">
  <xsl:param name="render" select="false()"/>
  <xsl:if test="$render">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>

<!-- Renders an exercise only when "render" is set to true().
     This allows us to move certain problem-sets to the end of a chapter.
     Also, wither it renders the problem or the solution.
     This way we can render the solutions at the end of a book
-->
<xsl:template match="ext:exercise[ancestor-or-self::*[@class]]">
<xsl:param name="render" select="false()"/>
<xsl:param name="renderSolution" select="false()"/>
<xsl:variable name="class" select="ancestor-or-self::*[@class][1]/@class"/>
<xsl:if test="$render">
    <xsl:apply-imports/>
</xsl:if>
</xsl:template>

<xsl:template match="ext:exercise[not(ancestor::db:example)]" mode="number">
  <xsl:param name="type" select="@type"/>
  <xsl:choose>
    <xsl:when test="$type and $type != ''">
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example) and @type=$type]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: Solutions at end of book          -->
<!-- ============================================== -->
<!-- TODO: end-of-book solutions code is bitrotting -->
<!-- when the placeholder element is encountered (since I didn't want to
      rewrite the match="d:book" template) run a nested for-loop on all
      chapters (and then sections) that contain a solution to be printed ( *[contains(@class,'problems-exercises') and .//ext:solution] ).
      Print the "exercise" solution with numbering.
-->
<xsl:template match="ext:cnx-solutions-placeholder[..//*[contains(@class,'problems-exercises') and .//ext:solution]]">
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">Injecting custom solution appendix</xsl:with-param></xsl:call-template>

  <div class="cnx-answers">
  <div class="title">
    <span>
      <xsl:text>Answers</xsl:text>
    </span>
  </div>
  
  <xsl:for-each select="../*[self::db:preface | self::db:chapter | self::db:appendix][.//*[contains(@class,'problems-exercises') and .//ext:solution]]">

    <xsl:variable name="chapterId">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <!-- Print the chapter number (not title) and link back to it -->
    <div class="problem">
      <a href="#{$chapterId}">
        <xsl:apply-templates select="." mode="object.xref.markup"/>
      </a>
    </div>

    <xsl:for-each select="db:section[.//*[contains(@class,'problems-exercises')]]">
      <xsl:variable name="sectionId">
        <xsl:call-template name="object.id"/>
      </xsl:variable>
      <!-- Print the section title and link back to it -->
      <div class="cnx-problems-subtitle">
        <a href="#{$sectionId}">
          <xsl:apply-templates select="." mode="object.title.markup">
            <xsl:with-param name="allow-anchors" select="0"/>
          </xsl:apply-templates>
        </a>
      </div>
      <xsl:apply-templates select=".//*[contains(@class,'problems-exercises')]">
        <xsl:with-param name="render" select="true()"/>
        <xsl:with-param name="renderSolution" select="true()"/>
      </xsl:apply-templates>
    </xsl:for-each>

  </xsl:for-each>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: @class='introduction'             -->
<!-- ============================================== -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="marker.title"/>

  <xsl:variable name="cnx.title">
      <xsl:choose>
        <xsl:when test="$marker.title != ''">
          <span class="section-title-number">
            <xsl:value-of select="substring-before($title, $marker.title)"/>
          </span>
          <xsl:copy-of select="$marker.title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$title"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>


  <xsl:variable name="head">
    <xsl:choose>
      <xsl:when test="number($level) &lt; 5">
        <xsl:value-of select="$level"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>5</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$level + 1}">
    <xsl:if test="ancestor::db:section[1]/@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="ancestor::db:section[1]/@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$cnx.title"/>
  </xsl:element>
</xsl:template>

<xsl:template mode="cnx.intro" match="node()"/>

<!-- Since intro sections are rendered specifically only in the title page, ignore them for normal rendering -->
<xsl:template mode="cnx.intro" match="d:section[contains(@class,'introduction')]">
  <xsl:param name="toc"/>

  <xsl:variable name="title">
    <xsl:apply-templates select=".." mode="title.markup"/>
  </xsl:variable>
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <div class="introduction" id="{$id}">

  <xsl:if test=".//db:figure[contains(@class,'splash')]">
    <xsl:apply-templates mode="cnx.splash" select=".//db:figure[contains(@class,'splash')]"/>
  </xsl:if>
  
  <xsl:copy-of select="$toc"/>
  
  <h3 class="title">
    <span>
      <xsl:choose>
        <xsl:when test="db:title">
          <xsl:apply-templates select="db:title/node()"/>
        </xsl:when>
        <xsl:when test="db:sectioninfo/db:title">
          <xsl:apply-templates select="db:sectioninfo/db:title/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Introduction</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </h3>
  <xsl:apply-templates select="node()"/>
  </div>

</xsl:template>



<xsl:template mode="introduction.toc" match="db:chapter/db:section[not(contains(@class,'introduction'))]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <tr>
    <td>
      <div class="cnx-introduction-toc-number">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div class="cnx-introduction-toc-title">
        <a href="#{$id}">
          <xsl:apply-templates mode="title.markup" select="."/>
        </a>
      </div>
    </td>
  </tr>
</xsl:template>

<!-- HACK: Fix section numbering. Search for "CNX" below to find the change -->
<!-- From ../docbook-xsl/common/labels.xsl -->
<xsl:template match="d:section" mode="label.markup">
  <!-- if this is a nested section, label the parent -->
  <xsl:if test="local-name(..) = 'section'">
    <xsl:variable name="parent.section.label">
      <xsl:call-template name="label.this.section">
        <xsl:with-param name="section" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$parent.section.label != '0'">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <!-- if the parent is a component, maybe label that too -->
  <xsl:variable name="parent.is.component">
    <xsl:call-template name="is.component">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <!-- does this section get labelled? -->
  <xsl:variable name="label">
    <xsl:call-template name="label.this.section">
      <xsl:with-param name="section" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$section.label.includes.component.label != 0                 and $parent.is.component != 0">
    <xsl:variable name="parent.label">
      <xsl:apply-templates select=".." mode="label.markup"/>
    </xsl:variable>
    <xsl:if test="$parent.label != ''">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$label != 0">
      <xsl:variable name="format">
        <xsl:call-template name="autolabel.format">
          <xsl:with-param name="format" select="$section.autolabel"/>
        </xsl:call-template>
      </xsl:variable>
<!-- CNX: Don't include the introduction Section
      <xsl:number format="{$format}" count="d:section"/>
-->
      <xsl:number format="{$format}" count="d:section[not(contains(@class,'introduction'))]"/>

    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: Custom splash image
  -->
<!-- ============================================== -->

<!-- Splash figures are moved up so they need to be rendered in a separate mode -->
<xsl:template match="d:figure[contains(@class,'splash')]"/>
<xsl:template mode="cnx.splash" match="d:figure[contains(@class,'splash')]">
  <xsl:call-template name="cnx.figure"/>
</xsl:template>


<!-- ============================================== -->
<!-- Customize block-text structure
     (notes, examples, exercises, nested elts)
  -->
<!-- ============================================== -->

<!-- Handle figures differently.
Combination of formal.object and formal.object.heading -->
<xsl:template match="d:figure" name="cnx.figure">
	<xsl:param name="c" select="."/>
	<xsl:param name="renderCaption" select="true()"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
    	<xsl:with-param name="object" select="$c"/>
    </xsl:call-template>
  </xsl:variable>

  <div id="{$id}"><xsl:call-template name="common.html.attributes"/>
    <xsl:choose>
      <xsl:when test="$c/@orient = 'vertical' or not($c/db:informalfigure)">
        <div class="body">
          <xsl:apply-templates select="$c/*[not(self::d:caption)]"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <table class="cnx-figure-horizontal">
          <tr>
            <xsl:for-each select="$c/db:informalfigure">
              <td>
                <xsl:apply-templates select="."/>
              </td>
            </xsl:for-each>
          </tr>
        </table>
        <xsl:apply-templates select="$c/*[not(self::db:informalfigure or self::db:caption)]"/>
      </xsl:otherwise>
    </xsl:choose>
		<xsl:if test="$renderCaption">
			<div class="title">
				<xsl:apply-templates select="$c" mode="object.title.markup">
					<xsl:with-param name="allow-anchors" select="1"/>
				</xsl:apply-templates>
			</div>
			<xsl:apply-templates select="$c/d:caption"/>
		</xsl:if>
  </div>
</xsl:template>


<!-- A block-level element inside another block-level element should use the inner formatting -->
<xsl:template mode="formal.object.heading" match="*" name="formal.object.heading">
  <xsl:param name="object" select="."/>

  <xsl:variable name="content">
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- CNX: added special case for examples and notes -->
  <div class="title">
    <span>
      <xsl:copy-of select="$content"/>
    </span>
  </div>
</xsl:template>

<xsl:template name="formal.object">
    <xsl:apply-templates mode="formal.object.heading" select=".">
    </xsl:apply-templates>
  
    <xsl:variable name="content">
      <xsl:apply-templates select="*[not(self::d:caption)]"/>
      <xsl:apply-templates select="d:caption"/>
    </xsl:variable>
  
    <div class="body">
      <xsl:copy-of select="$content"/>
    </div>
</xsl:template>

<xsl:template match="d:figure/d:caption">
  <div class="caption">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:note">
  <xsl:variable name="classes">
    <xsl:if test="@type">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@type"/>
    </xsl:if>
    <xsl:if test="@class">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@class"/>
    </xsl:if>
  </xsl:variable>
  <div id="{@xml:id}" class="note{$classes}">
    <div class="title">
      <span class="cnx-gentext-tip-t">
        <xsl:apply-templates select="db:title/node()|db:label/node()"/>
      </span>
    </div>
    <div class="body">
      <xsl:apply-templates select="*[not(self::db:title or self::db:label)]"/>
    </div>
  </div>
</xsl:template>

<!-- Lists inside an exercise (that isn't at the bottom of the chapter)
     (ie "Check for Understanding")
     have a larger number. overriding docbook-xsl/fo/lists.xsl
     see <xsl:template match="d:orderedlist/d:listitem">
 -->
<xsl:template match="ext:exercise/ext:problem/d:orderedlist/d:listitem" mode="item-number">
  <div class="cnx-gentext-listitem cnx-gentext-n">
    <xsl:apply-imports/>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize index page for modern-textbook       -->
<!-- ============================================== -->

<!-- If it's rendered in multiple columns the indexdiv gets a "h3" tag and, if the title div doesn't have one the title will show up alone in 1 column with the indexdivs in another -->
<xsl:template name="index.titlepage">
  <div class="title">
    <h2>
      <xsl:apply-templates select="." mode="title.markup"/>
    </h2>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize Table of Contents                    -->
<!-- ============================================== -->

<!-- Don't include the introduction section in the TOC -->
<xsl:template match="db:section[contains(@class,'introduction')]" mode="toc"/>

<!-- Don't render sections that contain a class that is collated at the end of the chapter (problems + Exercises, Conceptual Questions, etc -->
<xsl:template match="db:section[@class]">
  <xsl:variable name="class" select="@class"/>
  <xsl:choose>
    <xsl:when test="not(ancestor::db:chapter[.//processing-instruction('cnx.eoc')[contains(., $class)]])">
      <xsl:message>LOG: DEBUG: Rendering a section with class=<xsl:value-of select="@class"/></xsl:message>
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>LOG: DEBUG: NOT Rendering a section with class=<xsl:value-of select="@class"/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="NOTANODE"/>  
  <xsl:variable name="id">  
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">  
    <xsl:apply-templates select="." mode="label.markup"/>  
  </xsl:variable>

      <a href="#{$id}" class="target-{local-name()}">

<!-- CNX: Add the word "Chapter" or Appendix in front of the number. TODO: Dump this junk -->
        <xsl:if test="self::db:appendix or self::db:chapter">
<span class="cnx-gentext-{local-name()} cnx-gentext-autogenerated">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name()"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
</span>
        </xsl:if>

        <xsl:if test="$label != ''">
<span class="cnx-gentext-{local-name()} cnx-gentext-n">
          <xsl:copy-of select="$label"/>
</span>
<span class="cnx-gentext-{local-name()} cnx-gentext-autogenerated">
          <xsl:value-of select="$autotoc.label.separator"/>
</span>
        </xsl:if>
        <span class="cnx-gentext-{local-name()} cnx-gentext-t">
          <xsl:apply-templates select="." mode="title.markup"/>  
        </span>
      </a>
</xsl:template>

<!-- Output the PNG with the baseline info -->
<xsl:template name="cnx.baseline-shift">
    <xsl:attribute name="style">
        <!-- Set the height and width in the style so it scales? -->
        <xsl:text>width:</xsl:text>
        <xsl:value-of select="ancestor::db:imagedata/@width"/>
        <xsl:text>; height:</xsl:text>
        <xsl:value-of select="ancestor::db:imagedata/@depth"/>
        <xsl:text>; </xsl:text>
          <xsl:text>vertical-align:-</xsl:text>
          <xsl:value-of select="svg:svg/svg:metadata/pmml2svg:baseline-shift/text()" />
          <xsl:text>pt;</xsl:text>
      </xsl:attribute>
</xsl:template>

<xsl:template match="db:imagedata[svg:svg]" xmlns:svg="http://www.w3.org/2000/svg">
    <xsl:choose>
        <xsl:when test="$cnx.svg.compat = 'raw-svg'">
          <span class="cnx-svg">
            <xsl:call-template name="cnx.baseline-shift"/>
            <xsl:apply-templates select="svg:svg"/>
          </span>
        </xsl:when>
        <xsl:when test="@fileref and $cnx.svg.compat = 'object'">
          <object type="image/png" width="{@width}" height="{@height}">
            <xsl:attribute name="data">
              <xsl:value-of select="@fileref"/>
            </xsl:attribute>
            <xsl:call-template name="cnx.baseline-shift"/>
            <!-- Insert the SVG inline -->
            <xsl:apply-templates select="node()"/>
          </object>
        </xsl:when>
        <xsl:when test="@fileref">
          <img src="{@fileref}">
            <xsl:call-template name="cnx.baseline-shift"/>
          </img>
        </xsl:when>
        <xsl:when test="mml:math">
          <xsl:apply-templates select="mml:math"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>ERROR: Image does not contain SVG, MathML, or a path to the JPEG/PNG.</xsl:message>
          <span class="error">ERROR: Image does not contain SVG, MathML, or a path to the JPEG/PNG.</span>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="pmml2svg:baseline-shift"/>


<!-- Put the equation number on the RHS -->
<xsl:template match="db:equation|db:inlineequation">
  <div>
    <xsl:call-template name="common.html.attributes"/>

    <!-- Put the label before the equation so it can float: right; -->
    <span class="label">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="." mode="label.markup"/>
      <xsl:text>)</xsl:text>
    </span>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:inlineequation" mode="class.value">
  <xsl:text>equation</xsl:text>
</xsl:template>

<!-- Output equation titles instead of squishing them, as done in docbook (xsl/html/formal.xsl) -->
<xsl:template match="db:equation/db:title[normalize-space(text()) != '']">
    <div><xsl:call-template name="common.html.attributes"/>
        <b>
            <xsl:apply-templates/>
        </b>
    </div>
</xsl:template>


<!-- Output para titles as blocks instead of inline, as done in docbook -->
<xsl:template match="db:formalpara/db:title[normalize-space(text()) != '']">
    <div><xsl:call-template name="common.html.attributes"/>
        <b>
            <xsl:apply-templates/>
        </b>
    </div>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/html.xsl -->
<xsl:template match="*[@ext:element|@class]" mode="class.value">
  <xsl:param name="class" select="local-name(.)"/>
  <xsl:variable name="cls">
      <xsl:value-of select="$class"/>
      <xsl:if test="@ext:element">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@ext:element"/>
      </xsl:if>
      <xsl:if test="@class">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@class"/>
      </xsl:if>
  </xsl:variable>
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Adding to @class: "<xsl:value-of select="$cls"/>"</xsl:with-param></xsl:call-template>
  <!-- permit customization of class value only -->
  <!-- Use element name by default -->
  <xsl:value-of select="$cls"/>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/xref.xsl -->
<xsl:template match="*[@XrefLabel]" mode="xref-to">
    <xsl:value-of select="@XrefLabel"/>
</xsl:template>

<xsl:template match="db:inlineequation" mode="xref-to">
    <xsl:text>Equation</xsl:text>
</xsl:template>

<xsl:template match="db:caption" mode="xref-to">
    <xsl:apply-templates select="."/>
</xsl:template>

<!-- Subfigures are converted to images inside a figure with an anchor.
    With this code, any xref to a subfigure contains the text of the figure.
    I just added "ancestor::figure" when searching for the context.
 -->
<xsl:template match="db:anchor" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:variable name="context" select="(ancestor::db:figure| ancestor::db:simplesect                                        |ancestor::section                                        |ancestor::sect1                                        |ancestor::sect2                                        |ancestor::sect3                                        |ancestor::sect4                                        |ancestor::sect5                                        |ancestor::refsection                                        |ancestor::refsect1                                        |ancestor::refsect2                                        |ancestor::refsect3                                        |ancestor::chapter                                        |ancestor::appendix                                        |ancestor::preface                                        |ancestor::partintro                                        |ancestor::dedication                                        |ancestor::acknowledgements                                        |ancestor::colophon                                        |ancestor::bibliography                                        |ancestor::index                                        |ancestor::glossary                                        |ancestor::glossentry                                        |ancestor::listitem                                        |ancestor::varlistentry)[last()]"/>

  <xsl:choose>
    <xsl:when test="$xrefstyle != ''">
      <xsl:apply-templates select="." mode="object.xref.markup">
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$context" mode="xref-to">
        <xsl:with-param name="purpose" select="'xref'"/>
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Add a template for newlines.
     The cnxml2docbook adds a processing instruction named <?cnx.newline?>
     and is matched here
     see http://www.sagehill.net/docbookxsl/LineBreaks.html
-->
<xsl:template match="processing-instruction('cnx.newline')">
    <xsl:comment>cnx.newline</xsl:comment>
    <br/>
</xsl:template>
<xsl:template match="processing-instruction('cnx.newline.underline')">
    <xsl:comment>cnx.newline.underline</xsl:comment>
    <hr/>
</xsl:template>


<xsl:template name="cnx.authors.match">
    <xsl:param name="set1"/>
    <xsl:param name="set2"/>
    <xsl:param name="count" select="1"/>
    <xsl:choose>
        <!-- Base case (end of list) -->
        <xsl:when test="$count > count($set1)"/>
        <!-- Mismatch because set sizes don't match -->
        <xsl:when test="count($set1) != count($set2)">
            <xsl:text>set-size-diff=</xsl:text>
            <xsl:value-of select="count($set2) - count($set1)"/>
        </xsl:when>
        <!-- Check and recurse -->
        <xsl:otherwise>
	        <xsl:variable name="id" select="$set1[$count]/@ext:user-id"/>
	        <xsl:if test="not($set2[@ext:user-id=$id])">
	            <xsl:value-of select="$id"/>
	            <xsl:text>|</xsl:text>
	        </xsl:if>
	        <xsl:call-template name="cnx.authors.match">
	            <xsl:with-param name="set1" select="$set1"/>
	            <xsl:with-param name="set2" select="$set2"/>
	            <xsl:with-param name="count" select="$count+1"/>
	        </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<!-- Customize the title page.
    TODO: All of these can be made nicer using gentext and the %t replacements
 -->
<xsl:template name="book.titlepage">
    <!-- To handle the case where we're generating a module epub -->
    <xsl:variable name="collectionAuthorgroup" select="db:bookinfo/db:authorgroup[@role='collection' or not(../db:authorgroup[@role='collection'])]"/>
    <xsl:variable name="collectionAuthors" select="$collectionAuthorgroup/db:author"/>
    <xsl:variable name="moduleAuthors" select="db:bookinfo/db:authorgroup[@role='module' or not(../db:authorgroup[@role='module'])]/db:author"/>
    <!-- Only modules have editors -->
    <xsl:variable name="editors" select="db:bookinfo/db:authorgroup[not(@role)]/db:editor"/>
    <xsl:variable name="translators" select="$collectionAuthorgroup/db:othercredit[@class='translator']"/>
    <xsl:variable name="licensors" select="$collectionAuthorgroup/db:othercredit[@class='other' and db:contrib/text()='licensor']"/>
    <xsl:variable name="authorsMismatch">
        <xsl:call-template name="cnx.authors.match">
            <xsl:with-param name="set1" select="$collectionAuthors"/>
            <xsl:with-param name="set2" select="$moduleAuthors"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="showCollectionAuthors" select="$authorsMismatch != ''"/>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Displaying separate collections authors on title page? <xsl:value-of select="$showCollectionAuthors"/></xsl:with-param></xsl:call-template>
  <div class="cnx-title">
    <h1>
        <xsl:value-of select="db:bookinfo/db:title/text()"/>
    </h1>

    <xsl:if test="$showCollectionAuthors">
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Authors mismatch because of <xsl:value-of select="$authorsMismatch"/></xsl:with-param></xsl:call-template>
        <div id="title_page_collection_editors">
            <strong><xsl:text>Collection edited by: </xsl:text></strong>
            <span>
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$collectionAuthors"/>
                </xsl:call-template>
            </span>
        </div>
    </xsl:if>
    <div id="title_page_module_authors">
        <strong>
            <xsl:choose>
                <xsl:when test="not($showCollectionAuthors)">
                    <xsl:text>By: </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Content authors: </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </strong>
        <span>
            <xsl:call-template name="person.name.list">
                <xsl:with-param name="person.list" select="$moduleAuthors"/>
            </xsl:call-template>
        </span>
    </div>
    <!-- Only for modules -->
    <xsl:if test="$editors">
        <div>
            <strong><xsl:text>Edited by: </xsl:text></strong>
            <span>
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$editors"/>
                </xsl:call-template>
            </span>
        </div>
    </xsl:if>
    <xsl:if test="$translators">
        <div id="title_page_translators">
            <strong><xsl:text>Translated by: </xsl:text></strong>
            <span>
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$translators"/>
                </xsl:call-template>
            </span>
        </div>
    </xsl:if>
    <xsl:for-each select="db:bookinfo/ext:derived-from">
        <div id="title_page_derivation">
        <strong><xsl:text>Based on: </xsl:text></strong>
        <span>
            <xsl:apply-templates select="db:title/node()"/>
            <xsl:call-template name="cnx.cuteurl">
                <xsl:with-param name="url" select="@url"/>
            </xsl:call-template>
            <xsl:if test="ancestor::db:book[@ext:element='module']">
                <xsl:text> by </xsl:text>
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="db:authorgroup/db:author"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </span>
        </div>
    </xsl:for-each>
    <div id="title_page_url">
        <strong><xsl:text>Online: </xsl:text></strong>
        <span>
            <xsl:call-template name="cnx.cuteurl">
                <xsl:with-param name="url" select="@ext:url"/>
            </xsl:call-template>
        </span>
    </div>
    <xsl:if test="/db:book/@ext:site-type = 'cnx'">
        <div id="portal_statement">
            <div id="portal_title"><span><xsl:text>CONNEXIONS</xsl:text></span></div>
            <div id="portal_location"><span><xsl:text>Rice University, Houston, Texas</xsl:text></span></div>
        </div>
    </xsl:if>
    <div id="copyright_page">
        <xsl:if test="$licensors">
            <div id="copyright_statement">
                <xsl:choose>
                    <xsl:when test="@ext:element='module'">
                        <xsl:text>This module is copyrighted by </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>This selection and arrangement of content as a collection is copyrighted by </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$licensors"/>
                </xsl:call-template>
                <xsl:text>.</xsl:text>
            </div>
        </xsl:if>
        <xsl:if test="not($licensors)">
            <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: No copyright holders getting output under bookinfo for collection level.... weird.</xsl:with-param></xsl:call-template>
        </xsl:if>
        <!-- TODO: use the XSL param "generate.legalnotice.link" to chunk the notice into a separate file -->
        <xsl:apply-templates mode="titlepage.mode" select="db:bookinfo/db:legalnotice"/>
        <xsl:if test="@ext:derived-url">
            <div id="copyright_derivation">
                <xsl:text>The collection was based on </xsl:text>
                <xsl:call-template name="cnx.cuteurl">
                    <xsl:with-param name="url" select="@ext:derived-url"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        <div id="copyright_revised">
            <xsl:choose>
                <xsl:when test="@ext:element='module'">
                    <xsl:text>Module revised: </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Collection structure revised: </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- FIXME: Should read "August 10, 2009".  But for now, leaving as "2009/08/10" and chopping off the rest of the time/timezone stuff. -->
            <xsl:value-of select="substring-before(normalize-space(db:bookinfo/db:pubdate/text()),' ')"/>
        </div>
        <xsl:if test="not(@ext:element='module')">
	        <div id="copyright_attribution">
	            <xsl:text>For copyright and attribution information for the modules contained in this collection, see the "</xsl:text>
	            <xsl:call-template name="simple.xlink">
	                <xsl:with-param name="linkend" select="$attribution.section.id"/>
	                <xsl:with-param name="content">
	                    <xsl:text>Attributions</xsl:text>
	                </xsl:with-param>
	            </xsl:call-template>
	            <xsl:text>" section at the end of the collection.</xsl:text>
	        </div>
	    </xsl:if>
    </div>
  </div>
</xsl:template>

<xsl:template name="cnx.cuteurl">
    <xsl:param name="url"/>
    <xsl:param name="text">
        <xsl:value-of select="$url"/>
    </xsl:param>
    <xsl:text> &lt;</xsl:text>
    <a href="{$url}">
        <xsl:copy-of select="$text"/>
    </a>
    <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template name="section.titlepage.recto">
  <xsl:choose>
    <xsl:when test="d:sectioninfo/d:title">
      <xsl:apply-templates mode="section.titlepage.recto.auto.mode" select="d:sectioninfo/d:title"/>
    </xsl:when>
    <xsl:when test="d:info/d:title">
      <xsl:apply-templates mode="section.titlepage.recto.auto.mode" select="d:info/d:title"/>
    </xsl:when>
    <xsl:when test="d:title">
      <xsl:apply-templates mode="section.titlepage.recto.auto.mode" select="d:title"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Docbook generates "???" when it cannot generate text for a db:xref. Instead, we print the name of the closest enclosing element. -->
<xsl:template match="*" mode="xref-to">
    <xsl:variable name="orig">
        <xsl:apply-imports/>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="$orig='???'">
            <xsl:choose>
                <xsl:when test="@ext:element">
		            <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Using @ext:element for xref text: <xsl:value-of select="local-name()"/> is <xsl:value-of select="@ext:element"/></xsl:with-param></xsl:call-template>
                    <xsl:value-of select="@ext:element"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Using element name for xref text: <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
                    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Using element name for xref text: <xsl:value-of select="local-name()"/> id=<xsl:value-of select="(@id|@xml:id)[1]"/></xsl:with-param></xsl:call-template>
                    <xsl:value-of select="local-name()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$orig"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="db:xref" mode="xref-to">
    <xsl:text>link</xsl:text>
</xsl:template>
<!-- Support linking to c:media or c:media/c:image. See m12196 -->
<xsl:template match="db:mediaobject[not(db:objectinfo/db:title)]|db:inlinemediaobject[not(db:objectinfo/db:title)]" mode="xref-to">
    <xsl:choose>
        <xsl:when test="db:imageobject">
            <xsl:text>image</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>media</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- FIXME: This template an exact copy from the docbook copy.  The only change was for the namespace ("d:" to "db:") and white space.  
     This mysteriously makes @start-value work (and gets us closer to @number-style working).
     But it really shouldn't be necessary to copy the template verbatim.  Not sure why it doesn't work w/o this template here.  -->
<xsl:template match="db:orderedlist">
  <xsl:variable name="start">
    <xsl:call-template name="orderedlist-starting-number"/>
  </xsl:variable>
  <xsl:variable name="numeration">
    <xsl:call-template name="list.numeration"/>
  </xsl:variable>
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="$numeration='arabic'">1</xsl:when>
      <xsl:when test="$numeration='loweralpha'">a</xsl:when>
      <xsl:when test="$numeration='lowerroman'">i</xsl:when>
      <xsl:when test="$numeration='upperalpha'">A</xsl:when>
      <xsl:when test="$numeration='upperroman'">I</xsl:when>
      <!-- What!? This should never happen -->
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unexpected numeration: </xsl:text>
          <xsl:value-of select="$numeration"/>
        </xsl:message>
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <div>
    <xsl:call-template name="common.html.attributes"/>
    <xsl:call-template name="anchor"/>
    <xsl:if test="db:title">
      <xsl:call-template name="formal.object.heading"/>
    </xsl:if>
    <!-- Preserve order of PIs and comments -->
    <xsl:apply-templates 
        select="*[not(self::db:listitem
                  or self::db:title
                  or self::db:titleabbrev)]
                |comment()[not(preceding-sibling::db:listitem)]
                |processing-instruction()[not(preceding-sibling::db:listitem)]"/>
    <xsl:choose>
      <xsl:when test="@inheritnum='inherit' and ancestor::db:listitem[parent::db:orderedlist]">
        <table border="0">
          <xsl:call-template name="generate.class.attribute"/>
          <col align="{$direction.align.start}" valign="top"/>
          <tbody>
            <xsl:apply-templates 
                mode="orderedlist-table"
                select="db:listitem
                        |comment()[preceding-sibling::db:listitem]
                        |processing-instruction()[preceding-sibling::db:listitem]"/>
          </tbody>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <ol>
          <xsl:call-template name="generate.class.attribute"/>
          <xsl:if test="$start != '1'">
            <xsl:attribute name="start">
              <xsl:value-of select="$start"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$numeration != ''">
            <xsl:attribute name="type">
              <xsl:value-of select="$type"/>
            </xsl:attribute>
          </xsl:if>
<xsl:message>LOG: INFO: Discarding list numeration @type because it's not valid xhtml</xsl:message>

          <xsl:if test="@spacing='compact'">
            <xsl:attribute name="compact">
              <xsl:value-of select="@spacing"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates 
                select="db:listitem
                        |comment()[preceding-sibling::db:listitem]
                        |processing-instruction()[preceding-sibling::db:listitem]"/>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>


<!-- Originally taken from docbook-xsl/xhtml-1_1/html.xsl -->
<!-- In HTML mode, <a/> tags cannot be nested. For example
     <a href="http://x.org"><a id="1"/>...</a>
     will cause the @href to be dropped.
 -->
<xsl:template name="anchor">
  <xsl:param name="node" select="."/>
  <xsl:param name="conditional" select="1"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="not($node[parent::db:blockquote])">
    <xsl:if test="$conditional = 0 or $node/@id or $node/@xml:id">
<!-- Added the case where the current node is a db:link -->
<xsl:choose>
    <xsl:when test="self::db:link">
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Instead of generating an anchor, just set the @xml:id</xsl:with-param></xsl:call-template>
        <xsl:attribute name="xml:id">
            <xsl:value-of select="$id"/>
        </xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Inserting a span tag instead of an anchor tag for <xsl:value-of select="local-name($node)"/></xsl:with-param></xsl:call-template>
        <!-- Webkit parses the HTML incorrectly if a span is self-closed -->
        <span id="{$id}"><xsl:text> </xsl:text></span>
    </xsl:otherwise>
</xsl:choose>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- Label module abstracts as more user-friendly "Summary" instead of "Abstract" (conforms to rest of our site). -->
<!-- Copied from docbook/xsl/common/titles.xsl and edited.  -->
<xsl:template match="db:abstract" mode="title.markup">
  <xsl:param name="allow-anchors" select="0"/>
  <xsl:choose>
    <xsl:when test="db:title|db:info/db:title">
      <xsl:apply-templates select="(db:title|db:info/db:title)[1]" mode="title.markup">
        <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <!-- TODO: generate 'Summary' with gentext -->
      <xsl:text>Summary</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Taken from docbook-xsl/epub/graphics.xsl . Added default for "alt" param. -->
  <!-- we can't deal with no img/@alt, because it's required. Try grabbing a title before it instead (hopefully meaningful) --> 
  <xsl:template name="process.image.attributes"> 
    <!-- BEGIN customization -->
    <xsl:param name="alt" select="ancestor::d:mediaobject/d:textobject[d:phrase]|ancestor::d:inlinemediaobject/d:textobject[d:phrase]"/>
    <!-- END customization -->
    <xsl:param name="html.width"/> 
    <xsl:param name="html.depth"/> 
    <xsl:param name="longdesc"/> 
    <xsl:param name="scale"/> 
    <xsl:param name="scalefit"/> 
    <xsl:param name="scaled.contentdepth"/> 
    <xsl:param name="scaled.contentwidth"/> 
    <xsl:param name="viewport"/> 
 
    <xsl:choose>
      <!-- Use @print-width by default (@contentwidth will have units at the end, and thus not be a number -->
      <xsl:when test="@width and string(number(@width)) = 'NaN'">
        <xsl:attribute name="style">
          <xsl:text>width: </xsl:text>
          <xsl:value-of select="@width"/>
          <xsl:text>;</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="@contentwidth or @contentdepth"> 
        <!-- ignore @width/@depth, @scale, and @scalefit if specified --> 
        <xsl:if test="@contentwidth and $scaled.contentwidth != ''"> 
          <xsl:attribute name="width"> 
            <xsl:value-of select="$scaled.contentwidth"/> 
          </xsl:attribute> 
        </xsl:if> 
        <xsl:if test="@contentdepth and $scaled.contentdepth != ''"> 
          <xsl:attribute name="height"> 
            <xsl:value-of select="$scaled.contentdepth"/> 
          </xsl:attribute> 
        </xsl:if> 
      </xsl:when> 
 
      <xsl:when test="number($scale) != 1.0"> 
        <!-- scaling is always uniform, so we only have to specify one dimension --> 
        <!-- ignore @scalefit if specified --> 
        <xsl:attribute name="width"> 
          <xsl:value-of select="$scaled.contentwidth"/> 
        </xsl:attribute> 
      </xsl:when> 
 
      <xsl:when test="$scalefit != 0"> 
        <xsl:choose> 
          <xsl:when test="contains($html.width, '%')"> 
            <xsl:choose> 
              <xsl:when test="$viewport != 0"> 
                <!-- The *viewport* will be scaled, so use 100% here! --> 
                <xsl:attribute name="width"> 
                  <xsl:value-of select="'100%'"/> 
                </xsl:attribute> 
              </xsl:when> 
              <xsl:otherwise> 
                <xsl:attribute name="width"> 
                  <xsl:value-of select="$html.width"/> 
                </xsl:attribute> 
              </xsl:otherwise> 
            </xsl:choose> 
          </xsl:when> 
 
          <xsl:when test="contains($html.depth, '%')"> 
            <!-- HTML doesn't deal with this case very well...do nothing --> 
          </xsl:when> 
 
          <xsl:when test="$scaled.contentwidth != '' and $html.width != ''                         and $scaled.contentdepth != '' and $html.depth != ''"> 
            <!-- scalefit should not be anamorphic; figure out which direction --> 
            <!-- has the limiting scale factor and scale in that direction --> 
            <xsl:choose> 
              <xsl:when test="$html.width div $scaled.contentwidth &gt;                             $html.depth div $scaled.contentdepth"> 
                <xsl:attribute name="height"> 
                  <xsl:value-of select="$html.depth"/> 
                </xsl:attribute> 
              </xsl:when> 
              <xsl:otherwise> 
                <xsl:attribute name="width"> 
                  <xsl:value-of select="$html.width"/> 
                </xsl:attribute> 
              </xsl:otherwise> 
            </xsl:choose> 
          </xsl:when> 
 
          <xsl:when test="$scaled.contentwidth != '' and $html.width != ''"> 
            <xsl:attribute name="width"> 
              <xsl:value-of select="$html.width"/> 
            </xsl:attribute> 
          </xsl:when> 
 
          <xsl:when test="$scaled.contentdepth != '' and $html.depth != ''"> 
            <xsl:attribute name="height"> 
              <xsl:value-of select="$html.depth"/> 
            </xsl:attribute> 
          </xsl:when> 
        </xsl:choose> 
      </xsl:when> 
    </xsl:choose> 
 
    <!-- AN OVERRIDE --> 
    <xsl:if test="not(@format ='SVG')"> 
      <xsl:attribute name="alt"> 
        <xsl:choose> 
          <xsl:when test="$alt != ''"> 
            <xsl:value-of select="normalize-space($alt)"/> 
          </xsl:when> 
          <xsl:when test="preceding::d:title[1]"> 
            <xsl:value-of select="normalize-space(preceding::d:title[1])"/> 
          </xsl:when> 
          <xsl:otherwise> 
            <xsl:text>(missing alt)</xsl:text> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:attribute> 
    </xsl:if> 
    <!-- END OF OVERRIDE --> 
 
    <xsl:if test="$longdesc != ''"> 
      <xsl:attribute name="longdesc"> 
        <xsl:value-of select="$longdesc"/> 
      </xsl:attribute> 
    </xsl:if> 
 
    <xsl:if test="@align and $viewport = 0"> 
      <xsl:attribute name="style"><xsl:text>text-align: </xsl:text> 
        <xsl:choose> 
          <xsl:when test="@align = 'center'">middle</xsl:when> 
          <xsl:otherwise> 
            <xsl:value-of select="@align"/> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:attribute> 
    </xsl:if> 
  </xsl:template> 

  <xsl:template match="db:example">
    <div id="{@xml:id}"><xsl:call-template name="common.html.attributes"/>
      <xsl:apply-imports/>
    </div>
  </xsl:template>

  <!-- xrefs to a subfigure just render "informalfigure" but should render as "Figure 1.12 c" -->
  <xsl:template match="db:figure/db:informalfigure" mode="xref-to">
    <xsl:param name="referrer"/>
    <xsl:param name="xrefstyle"/>

    <xsl:apply-templates mode="xref-to" select=".."/>
    <xsl:number from="db:figure" count="db:informalfigure" format="a"/>
  </xsl:template>

<!-- Don't include glossaries in the TOC -->
<xsl:template match="d:bibliography|d:glossary" mode="toc"/>


<!-- For gentext templates that generate things like "1.2 Acceleration" or "Figure 3.1: How the west was won" make sure parts like the number or title are stylable by adding in spans with certain classes around the templated tet -->
<xsl:template name="substitute-markup">
  <xsl:param name="template" select="''"/>
  <xsl:param name="allow-anchors" select="'0'"/>
  <xsl:param name="title" select="''"/>
  <xsl:param name="subtitle" select="''"/>
  <xsl:param name="docname" select="''"/>
  <xsl:param name="label" select="''"/>
  <xsl:param name="pagenumber" select="''"/>
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="referrer"/>
  <xsl:param name="verbose"/>
  <xsl:choose>
    <xsl:when test="contains($template, '%')">
<!-- CNX: START Customization -->
<span class="cnx-gentext-{local-name()} cnx-gentext-autogenerated">
<!-- CNX: END Customization -->
      <xsl:value-of select="substring-before($template, '%')"/>
<!-- CNX: START Customization -->
</span>
<!-- CNX: END Customization -->
      <xsl:variable name="candidate"
             select="substring(substring-after($template, '%'), 1, 1)"/>
<!-- CNX: START Customization -->
<span class="cnx-gentext-{local-name()} cnx-gentext-{$candidate}">
<!-- CNX: END Customization -->
      <xsl:choose>
        <xsl:when test="$candidate = 't'">
          <xsl:apply-templates select="." mode="insert.title.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="title">
              <xsl:choose>
                <xsl:when test="$title != ''">
                  <xsl:copy-of select="$title"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="title.markup">
                    <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
                    <xsl:with-param name="verbose" select="$verbose"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = 's'">
          <xsl:apply-templates select="." mode="insert.subtitle.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="subtitle">
              <xsl:choose>
                <xsl:when test="$subtitle != ''">
                  <xsl:copy-of select="$subtitle"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="subtitle.markup">
                    <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = 'n'">
          <xsl:apply-templates select="." mode="insert.label.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="label">
              <xsl:choose>
                <xsl:when test="$label != ''">
                  <xsl:copy-of select="$label"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="label.markup"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = 'p'">
          <xsl:apply-templates select="." mode="insert.pagenumber.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="pagenumber">
              <xsl:choose>
                <xsl:when test="$pagenumber != ''">
                  <xsl:copy-of select="$pagenumber"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="pagenumber.markup"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = 'o'">
          <!-- olink target document title -->
          <xsl:apply-templates select="." mode="insert.olink.docname.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="docname">
              <xsl:choose>
                <xsl:when test="$docname != ''">
                  <xsl:copy-of select="$docname"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="olink.docname.markup"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = 'd'">
          <xsl:apply-templates select="." mode="insert.direction.markup">
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="direction">
              <xsl:choose>
                <xsl:when test="$referrer">
                  <xsl:variable name="referent-is-below">
                    <xsl:for-each select="preceding::d:xref">
                      <xsl:if test="generate-id(.) = generate-id($referrer)">1</xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$referent-is-below = ''">
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key" select="'above'"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key" select="'below'"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:message>Attempt to use %d in gentext with no referrer!</xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$candidate = '%' ">
          <xsl:text>%</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>%</xsl:text><xsl:value-of select="$candidate"/>
        </xsl:otherwise>
      </xsl:choose>
<!-- CNX: START Customization -->
</span>
<!-- CNX: END Customization -->
      <!-- recurse with the rest of the template string -->
      <xsl:variable name="rest"
            select="substring($template,
            string-length(substring-before($template, '%'))+3)"/>
      <xsl:call-template name="substitute-markup">
        <xsl:with-param name="template" select="$rest"/>
        <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="subtitle" select="$subtitle"/>
        <xsl:with-param name="docname" select="$docname"/>
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="pagenumber" select="$pagenumber"/>
        <xsl:with-param name="purpose" select="$purpose"/>
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:call-template>
    </xsl:when>
<!-- CNX: START Customization -->
    <xsl:when test="normalize-space($template) = ''"/>
<!-- CNX: END Customization -->
    <xsl:otherwise>
<!-- CNX: START Customization -->
<span class="cnx-gentext-{local-name()} cnx-gentext-autogenerated">
<!-- CNX: END Customization -->
      <xsl:value-of select="$template"/>
<!-- CNX: START Customization -->
</span>
<!-- CNX: END Customization -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>





<!-- Chapters titles should be H1, not H2. This is from docbook-xsl/xhtml-1_1/component.xsl -->
<xsl:template name="component.title">
  <xsl:param name="node" select="."/>

  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="ancestor::d:section">
        <xsl:value-of select="count(ancestor::d:section)+1"/>
      </xsl:when>
      <xsl:when test="ancestor::d:sect5">6</xsl:when>
      <xsl:when test="ancestor::d:sect4">5</xsl:when>
      <xsl:when test="ancestor::d:sect3">4</xsl:when>
      <xsl:when test="ancestor::d:sect2">3</xsl:when>
      <xsl:when test="ancestor::d:sect1">2</xsl:when>
<!-- CNX: START Customization -->
      <xsl:otherwise>
        <!-- for-each is just to change the context for ancestor:: to not be the d:title element -->
        <xsl:for-each select="$node">
          <xsl:value-of select="count(ancestor::*[self::d:chapter or self::d:appendix])"/>
        </xsl:for-each>
      </xsl:otherwise>
<!--      <xsl:otherwise>1</xsl:otherwise> -->
<!-- CNX: END Customization -->
    </xsl:choose>
  </xsl:variable>

  <!-- Let's handle the case where a component (bibliography, for example)
       occurs inside a section; will we need parameters for this? -->

  <xsl:element name="h{$level+1}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:if test="$generate.id.attributes = 0">
      <xsl:call-template name="anchor">
	<xsl:with-param name="node" select="$node"/>
	<xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
    </xsl:if>
      <xsl:apply-templates select="$node" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>



<!-- Due to limitations of CSS3 page hints (page-break-inside:avoid)
     this code was copy-pasted from docbook-xsl/xhtml-1_1/autoidx.xsl and the div wrapper was removed.
This is because the following generated HTML results in the Index title appearing on one page with the rest of the index appearing on the next page.
Example:
<div style="page-break-inside: avoid;">
  <div>Index</div>
  <div>A aardvark . . . Z zebra</div>
</div>
-->

<!--
<xsl:template name="generate-basic-index">
</xsl:template>
-->


<!-- If the dbk element contains a custom @class, append it -->
<!-- From docbook-xsl/xhtml/html.xsl -->
<xsl:template match="*" mode="class.value">
  <xsl:param name="class" select="local-name(.)"/>
  <!-- permit customization of class value only -->
  <!-- Use element name by default -->
  <xsl:value-of select="$class"/>
<!-- CNX: Start -->
  <xsl:if test="@class">
    <xsl:text> </xsl:text>
    <xsl:value-of select="@class"/>
  </xsl:if>
<!-- CNX: end -->
</xsl:template>



<!-- Generate a custom TOC (both for the book and chapters) -->
<!-- From docbook-xsl/xhtml/autotoc.xsl -->
<xsl:template name="make.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>
  <xsl:param name="nodes" select="/NOT-AN-ELEMENT"/>

  <xsl:variable name="nodes.plus" select="$nodes | d:qandaset"/>

  <xsl:variable name="toc.title">
    <xsl:if test="$toc.title.p">
      <div class="title">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">TableofContents</xsl:with-param>
        </xsl:call-template>
      </div>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="$nodes">
    <div class="toc">
      <xsl:copy-of select="$toc.title"/>
      <ul>
        <xsl:apply-templates select="$nodes" mode="toc">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </ul>
    </div>
  </xsl:if>

</xsl:template>

<xsl:template match="db:preface | db:chapter | db:appendix | db:section | db:index" mode="toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:variable name="nodes" select="db:section"/>
  <li>
    <xsl:attribute name="class">
      <xsl:text>toc-</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:if test="@class">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@class"/>
      </xsl:if>
    </xsl:attribute>
    <xsl:apply-templates select="." mode="toc.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:apply-templates>
    <xsl:if test="$nodes">
      <ul>
        <xsl:apply-templates select="$nodes" mode="toc">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="db:section[key('cnx.eoc-key', @class)]" mode="toc" />

<xsl:template match="*" mode="toc.line">
  <xsl:call-template name="toc.line"/>
</xsl:template>

<!-- To get module abstracts (Mearning Objectives) in the chapter TOC, add abstracts to the subtoc -->
<xsl:template match="d:section" mode="toc.line">
  <xsl:param name="toc-context" select="."/>

  <xsl:call-template name="toc.line"/>
  
  <xsl:if test="$toc-context[self::d:chapter] and d:sectioninfo/d:abstract">
    <li class="abstract">
      <xsl:apply-templates select="d:sectioninfo/d:abstract/node()"/>
    </li>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>

