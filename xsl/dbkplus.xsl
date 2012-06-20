<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file converts dbk+ extension elements (like exercise and its children)
	 using the Docbook templates.
	* Customizes title generation
	* Numbers exercises
	* Labels exercises (and links to them)
 -->
<xsl:include href="param.xsl"/>

<xsl:key name="exercise" match="ext:exercise[@id or @xml:id]" use="@id|@xml:id"/>
<xsl:key name="solution" match="ext:solution" use="parent::ext:exercise/@xml:id"/>

<!-- EXERCISE templates -->

<!-- Generate custom HTML for an ext:problem, ext:solution, and ext:commentary.
	Taken from docbook-xsl/xhtml-1_1/formal.xsl: <xsl:template match="example">
 -->
<xsl:template match="ext:*">

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="param.placement" select="substring-after(normalize-space($formal.title.placement), concat(local-name(.), ' '))"/>

  <xsl:variable name="placement">
    <xsl:choose>
      <xsl:when test="contains($param.placement, ' ')">
        <xsl:value-of select="substring-before($param.placement, ' ')"/>
      </xsl:when>
      <xsl:when test="$param.placement = ''">before</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$param.placement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="labeled">
    <xsl:if test="ext:label">
      <xsl:text> labeled</xsl:text>
    </xsl:if>
  </xsl:variable>
  <div id="{$id}" class="{local-name()}{$labeled}">
<xsl:comment>calling formal.object</xsl:comment>
  <xsl:call-template name="formal.object">
    <xsl:with-param name="placement" select="$placement"/>
  </xsl:call-template>
  </div>
</xsl:template>

<xsl:template match="ext:problem[not(db:title[normalize-space(text()) !=''])]">
<xsl:comment>calling informal.object</xsl:comment>
  <xsl:call-template name="informal.object"/>
</xsl:template>

<!-- Can't use docbook-xsl/common/gentext.xsl because labels and titles can contain XML (makes things icky) -->
<xsl:template match="ext:*" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
</xsl:template>

<!-- Link to the exercise and to the solution. HACK: We can do this because solutions are within a module (html file) -->
<xsl:template match="ext:exercise" mode="object.title.markup">
  <xsl:variable name="solutions" select="key('solution', @xml:id)"/>
  <xsl:choose>
    <xsl:when test="$solutions">
      <a class="solution-number" href="#{$solutions[1]/@xml:id}">
        <xsl:apply-templates select="." mode="cnx.template"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="cnx.template"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ext:solution" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
	<xsl:variable name="exerciseId" select="parent::ext:exercise/@xml:id"/>
	<xsl:if test="$exerciseId!='' and parent::db:section[@ext:element='solutions']">
		<xsl:text> </xsl:text>
                <!-- TODO: gentext for "(" -->
		<xsl:text>(</xsl:text>
		  <xsl:call-template name="simple.xlink">
		    <xsl:with-param name="linkend" select="$exerciseId"/>
		    <xsl:with-param name="content">
                        <!-- TODO: gentext for "Return to" -->
		    	<xsl:text>Return to</xsl:text>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="key('exercise', $exerciseId)[1]/ext:label">
                                <xsl:apply-templates select="key('exercise', $exerciseId)[1]/ext:label" mode="cnx.label" />
                            </xsl:when>
                            <xsl:when test="key('exercise', $exerciseId)[ancestor::db:example]">
                                <!-- TODO: gentext for "Problem" -->
                                <xsl:text>Problem</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- TODO: gentext for "Exercise" -->
                                <xsl:text>Exercise</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
		    </xsl:with-param>
		  </xsl:call-template>
                <!-- TODO: gentext for ")" -->
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="ext:*" mode="insert.label.markup">
	<xsl:param name="label" select="ext:label"/>
	<xsl:if test="$label!=''">
		<xsl:apply-templates select="$label" mode="cnx.label"/>
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="ext:*[not(db:title)]" mode="title.markup"/>
<xsl:template match="ext:*/db:title"/>
<xsl:template match="ext:exercise|ext:problem|ext:solution|ext:commentary" mode="label.markup"/>

<xsl:template match="ext:exercise" mode="cnx.template">
  <xsl:variable name="label">
    <xsl:call-template name="cnx.label">
      <xsl:with-param name="default">
        <xsl:choose>
          <xsl:when test="ancestor::db:example">
            <!-- TODO: gentext for "Problem" -->
            <xsl:text>Problem</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- TODO: gentext for "Exercise" -->
            <xsl:text>Exercise</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="title">
  	<xsl:apply-templates select="db:title/node()"/>
  </xsl:variable>
  <xsl:copy-of select="$label"/>
  <xsl:if test="$label != '' and $title != ''">
    <xsl:text>: </xsl:text>
  </xsl:if>
  <xsl:copy-of select="$title"/>
</xsl:template>

<xsl:template match="ext:rule" mode="cnx.template">
        <xsl:variable name="type">
                <xsl:choose>
                        <xsl:when test="@type">
                                <xsl:value-of select="translate(@type,$cnx.upper,$cnx.lower)"/>
                        </xsl:when>
                        <xsl:otherwise>rule</xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
	<xsl:variable name="defaultLabel">
		<xsl:choose>
			<!-- TODO: gentext for "Rule" and custom rules -->
			<xsl:when test="$type='theorem'"><xsl:text>Theorem</xsl:text></xsl:when>
			<xsl:when test="$type='lemma'"><xsl:text>Lemma</xsl:text></xsl:when>
			<xsl:when test="$type='corollary'"><xsl:text>Corollary</xsl:text></xsl:when>
			<xsl:when test="$type='law'"><xsl:text>Law</xsl:text></xsl:when>
			<xsl:when test="$type='proposition'"><xsl:text>Proposition</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Rule</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="cnx.label">
		<xsl:with-param name="default" select="$defaultLabel"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="cnx.label" match="ext:*[ext:label]" mode="cnx.template" priority="0">
	<xsl:param name="c" select="."/>
	<xsl:param name="default"></xsl:param>
	<xsl:choose>
		<xsl:when test="$c/ext:label">
      <span class="cnx-gentext-{local-name($c)} cnx-gentext-autogenerated">
		    <xsl:apply-templates select="$c/ext:label" mode="cnx.label"/>
      </span>
		</xsl:when>
		<xsl:when test="$default=''">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: No default set when calling template cnx.label</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
      <span class="cnx-gentext-{local-name($c)} cnx-gentext-autogenerated">
        <xsl:value-of select="$default"/>
        <xsl:text> </xsl:text>
      </span>
      <span class="cnx-gentext-{local-name($c)} cnx-gentext-n">
        <xsl:apply-templates select="$c/." mode="number"/>
      </span>
      <xsl:if test="$c/db:title">
        
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Not reprinting title, this might result in a bug</xsl:with-param></xsl:call-template>
<!--
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$c/." mode="title.markup"/>
-->
      </xsl:if>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="ext:problem" mode="cnx.template">
	<xsl:apply-templates select="ext:label" mode="cnx.label"/>
	<xsl:if test="ext:label and db:title">
		<xsl:text>: </xsl:text>
	</xsl:if>
        <xsl:apply-templates select="db:title" mode="title.markup"/>
</xsl:template>

<xsl:template match="ext:commentary" mode="cnx.template">
	<xsl:apply-templates select="ext:label" mode="cnx.label"/>
	<xsl:if test="ext:label and db:title">
		<xsl:text>: </xsl:text>
	</xsl:if>
        <xsl:apply-templates select="db:title" mode="title.markup"/>
</xsl:template>

<xsl:template match="ext:solution" mode="cnx.template">
  <xsl:variable name="exerciseId" select="parent::ext:exercise/@xml:id"/>
  <xsl:choose>
    <xsl:when test="ext:label">
      <xsl:apply-templates select="ext:label" mode="cnx.label"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- TODO: gentext for "Solution" -->
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="count(key('solution', $exerciseId)) > 1">
    <xsl:number count="ext:solution[parent::ext:exercise/@xml:id=$exerciseId]" level="any" format=" A"/>
  </xsl:if>
</xsl:template>

<xsl:template match="ext:label" mode="cnx.label">
	<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="ext:label"/>



<!-- NUMBERING templates -->

<!-- By default, nothing is numbered. -->
<xsl:template match="ext:*" mode="number"/>

<xsl:template name="cnx.chapter.number">
	<xsl:for-each select="ancestor::db:chapter">
                <xsl:apply-templates select="." mode="label.markup"/>
		<xsl:apply-templates select="." mode="intralabel.punctuation"/>
        </xsl:for-each>
</xsl:template>

<xsl:template match="ext:exercise" mode="number">
	<xsl:call-template name="cnx.chapter.number"/>
  <xsl:if test="ancestor::db:section[@ext:element='module']">
    <xsl:number format="1" level="any" from="db:chapter" count="*[@ext:element='module']"/>
    <xsl:apply-templates select="." mode="intralabel.punctuation"/>
    <xsl:call-template name="number-based-on-element-and-type"/>
	</xsl:if>
</xsl:template>

<!-- Some elements like exercises are numbered based on the @type.
     This means that there may exist 2 "Exercise 4.1" in a chapter
-->
<xsl:template name="number-based-on-element-and-type">
  <xsl:param name="name" select="local-name()"/>
  <xsl:param name="type" select="@type"/>
  <xsl:choose>
    <xsl:when test="$type and $type != ''">
      <xsl:number format="1." level="any" from="*[@ext:element='module']" count="*[local-name()=$name][not(ancestor::db:example) and @type=$type]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number format="1." level="any" from="*[@ext:element='module']" count="*[local-name()=$name][not(ancestor::db:example)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ext:exercise[ancestor::db:example]" mode="number">
        <xsl:if test="count(ancestor::db:example[1]//ext:exercise) > 1">
        	<xsl:number format="1." level="any" from="db:example" count="ext:exercise"/>
        </xsl:if>
</xsl:template>

<xsl:template match="ext:rule" mode="number">
	<xsl:variable name="type" select="translate(@type,$cnx.upper,$cnx.lower)"/>
	<xsl:call-template name="cnx.chapter.number"/>
        <xsl:choose>
                <xsl:when test="$type='rule' or not(@type)">
                        <xsl:number format="1." level="any" from="db:preface|db:chapter" count="ext:rule[translate(@type,$cnx.upper,$cnx.lower)='rule' or not(@type)]"/>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:number format="1." level="any" from="db:preface|db:chapter" count="ext:rule[translate(@type,$cnx.upper,$cnx.lower)=$type]"/>
                </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="ext:solution" mode="number">
	<xsl:variable name="exerciseId" select="parent::ext:exercise/@xml:id"/>
	<xsl:apply-templates select="key('exercise', $exerciseId)[1]" mode="number"/>
</xsl:template>


<!-- Don't number examples inside exercises. Original code taken from docbook-xsl/common/labels.xsl -->
<xsl:template match="db:example[ancestor::db:glossentry
            or ancestor::*[@ext:element='rule']
            ]" mode="label.markup">
</xsl:template>
<xsl:template match="db:example[ancestor::db:glossentry
            or ancestor::*[@ext:element='rule']
            ]" mode="intralabel.punctuation"/>
<!-- Only number figures and tables if they are not in exercises.
    Largely taken from docbook-xsl/common/labels.xsl
 -->
<xsl:template match="db:figure|db:table|db:example" mode="label.markup">
  <xsl:variable name="pchap"
                select="(ancestor::db:chapter
                        |ancestor::db:appendix
                        |ancestor::db:article[ancestor::db:book])[last()]"/>
  <xsl:variable name="name" select="local-name()"/>
  
  <xsl:variable name="prefix">
    <xsl:if test="count($pchap) &gt; 0">
      <xsl:apply-templates select="$pchap" mode="label.markup"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$prefix != ''">
            <xsl:apply-templates select="$pchap" mode="label.markup"/>
            <xsl:apply-templates select="$pchap" mode="intralabel.punctuation"/>
          <xsl:number format="1" from="db:chapter|db:appendix" count="*[$name=local-name() and not(
               ancestor::db:glossentry
               or ancestor::*[@ext:element='rule']
               or ancestor::ext:exercise

          )]" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number format="1" from="db:book|db:article" level="any" count="*[$name=local-name() and not(
               ancestor::db:glossentry
               or ancestor::*[@ext:element='rule']
               or ancestor::ext:exercise
               
          )]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- XREF templates -->

<xsl:template match="ext:*" mode="xref-to">
	<xsl:apply-templates select="." mode="object.xref.markup"/>
</xsl:template>

<xsl:template match="ext:*" mode="object.xref.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="referrer"/>
  <xsl:param name="verbose" select="1"/>
	<!-- TODO: Reimplement using gentext defaults -->
	<xsl:apply-templates select="." mode="cnx.template"/>
</xsl:template>



    <!-- Add an asterisk linking to a module's attribution. The XPath ugliness below is like preface/prefaceinfo/title/text(), but also for chapter and section -->
    <!-- FIXME: not working for some reason in modules that front matter (i.e. in db:preface).   Haven't tested module EPUBs or EPUBs of collections with no subcollections. -->
    <xsl:template match="*[@ext:element='module']/db:*[contains(local-name(),'info')]/db:title/text()">
    	<xsl:variable name="moduleId">
    		<xsl:call-template name="cnx.id">
    			<xsl:with-param name="object" select="../../.."/>
    		</xsl:call-template>
    	</xsl:variable>
    	<xsl:variable name="id">
    		<xsl:value-of select="$attribution.section.id"/>
    		<xsl:value-of select="$cnx.module.separator"/>
    		<xsl:value-of select="$moduleId"/>
    	</xsl:variable>
        <xsl:value-of select="."/>
        <!-- FIXME: Remove the reference to the <sup/> element by using docbook templates and move this into dbkplus.xsl -->
        <xsl:call-template name="inline.superscriptseq">
        	<xsl:with-param name="content">
                <xsl:call-template name="simple.xlink">
                        <xsl:with-param name="linkend" select="$id"/>
                        <xsl:with-param name="content">
							<xsl:text>*</xsl:text>
                        </xsl:with-param>
                </xsl:call-template>
        	</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
<!-- Otherwise the call to "simple.xlink" above would fail. -->
<xsl:template match="db:title/text()" mode="common.html.attributes"/>
<xsl:template match="db:title/text()" mode="html.title.attribute"/>

<xsl:template match="ext:persons">
	<xsl:call-template name="person.name.list">
		<xsl:with-param name="person.list" select="db:*"/>
	</xsl:call-template>
</xsl:template>


<!-- cnxml supports sections without titles while Docbook does not.
  If a section has no title then an empty div @class="titlepage" is rendered causing CSS problems
  (the following text becomes blue). This code disables that from happening.
  Taken from docbook-xsl/xhtml-1_1/titlepage.templates.xsl -->
<xsl:template name="section.titlepage" xmlns:exsl="http://exslt.org/common">
<!-- START: edit -->
<xsl:if test="db:title or db:*[contains(local-name(), 'info')]/db:title">
<!-- END: edit -->
  <div class="titlepage">
    <xsl:variable name="recto.content">
      <xsl:call-template name="section.titlepage.before.recto"/>
      <xsl:call-template name="section.titlepage.recto"/>
    </xsl:variable>
    <xsl:variable name="recto.elements.count">
      <xsl:choose>
        <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
        <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
          <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
      <div><xsl:copy-of select="$recto.content"/></div>
    </xsl:if>
  </div>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
