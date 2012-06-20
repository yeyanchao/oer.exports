<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  xmlns:exsl="http://exslt.org/common"
  version="1.0">

<!-- This file: Converts a module's cnxml (and mdml) into Docbook elements
	Whatever it can't match is printed out as a "BUG: " for later implementation
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="debug.xsl"/>
<xsl:import href="cnxml2dbk-simple.xsl"/>
<xsl:import href="mdml2dbk.xsl"/>
<xsl:output indent="no" method="xml"/>

<xsl:template mode="copy" match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates mode="copy" select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="processing-instruction()|comment()">
	<xsl:copy/>
</xsl:template>

<!-- Boilerplate -->
<xsl:template match="/">
	<xsl:apply-templates select="*"/>
</xsl:template>

<!-- Prefix all id's with the module id (for inclusion in collection) -->
<xsl:template match="@id|c:note/@id">
	<xsl:attribute name="xml:id">
		<xsl:value-of select="$cnx.module.id"/>
		<xsl:value-of select="$cnx.module.separator"/>
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>
<!-- Bug. can't replace @id with xsl:attribute if other attributes have already converted using xsl:copy -->
<xsl:template match="@*">
	<xsl:attribute name="{local-name(.)}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@src|@format|@alt"/>
<!-- Pass @type through so exercises, examples, etc are re-numberred based on type -->
<xsl:template match="*/@type">
  <xsl:copy>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="c:note/@*">
    <xsl:attribute name="{local-name()}">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>

<!-- Match the roots and add boilerplate -->
<xsl:template match="c:document">
<!-- TODO: No longer discards solutions from the docbook. Fix epub generation
    <xsl:variable name="moving.solutions" select=".//c:solution[not(ancestor::c:example)][not(@print-placement='here')][not(../@print-placement='here') or @print-placement='end']|
                                                  .//c:solution[ancestor::c:example][@print-placement='end' or (../@print-placement='end' and not(@print-placement='here'))]"/>
-->
    <xsl:variable name="lang" select="c:metadata/md:language/text()"/>
    <db:section ext:element="module" lang="{$lang}"
            ext:url="{c:metadata/md:content-url/text()}/"
            ext:version="{c:metadata/md:version/text()}">
    	<xsl:attribute name="xml:id"><xsl:value-of select="$cnx.module.id"/></xsl:attribute>
        <xsl:attribute name="xml:lang"><xsl:value-of select="$lang"/></xsl:attribute>
        <xsl:apply-templates select="@class"/>
        <db:sectioninfo ext:repository="{c:metadata/md:repository/text()}">
        	<xsl:apply-templates select="c:title"/>
        	<xsl:apply-templates select="c:metadata"/>
        </db:sectioninfo>
        
        <!-- Make sure any keywords (that aren't terms in the content) get
         			index entries pointing to this module -->
<!--
        <xsl:apply-templates select="c:metadata/md:keyword-list/md:keyword"/>
-->

        <xsl:apply-templates select="c:content/node()"/>
        <!-- Move some exercise solutions to the end of a module -->
<!-- TODO: No longer discards solutions from the docbook. Fix epub generation
        <xsl:if test="$moving.solutions">
        	<db:section ext:element="solutions">
        		<db:title>Solutions to Exercises</db:title>
                        <xsl:apply-templates select="$moving.solutions" />
        	</db:section>
        </xsl:if>
-->
        <xsl:apply-templates select="c:glossary"/>
        <xsl:for-each select="bib:file">
            <db:section>
                <xsl:apply-templates select="@*"/>
                <db:title>
                    <!-- TODO: gentext for 'References' -->
                    <xsl:text>References</xsl:text>
                </db:title>
                <xsl:apply-templates select="self::bib:file"/>
            </db:section>
        </xsl:for-each>
    </db:section>
</xsl:template>

<xsl:template match="bib:*">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="bib:file">
    <db:orderedlist>
        <xsl:apply-templates select="node()"/>
    </db:orderedlist>
</xsl:template>
<!-- Every bib:entry must have @id, not @xml:id -->
<xsl:template match="bib:entry">
    <db:listitem>
        <xsl:attribute name="id">
            <xsl:call-template name="cnx.id"/>
        </xsl:attribute>
        <db:para>
          <xsl:apply-templates select="@*|node()"/>
        </db:para>
    </db:listitem>
</xsl:template>


<xsl:template match="c:para[c:title]">
    <db:formalpara>
		<xsl:apply-templates select="@*|c:title"/>
		<db:para>
			<xsl:apply-templates select="*[local-name()!='title']|text()|processing-instruction()|comment()"/>
		</db:para>
	</db:formalpara>
</xsl:template>


<xsl:template match="c:list[@number-style or @list-type='enumerated']">
	<xsl:variable name="numeration">
		<xsl:choose>
    		<xsl:when test="not(@number-style) or @number-style='arabic'">arabic</xsl:when>
			<xsl:when test="@number-style='upper-alpha'">upperalpha</xsl:when>
			<xsl:when test="@number-style='lower-alpha'">loweralpha</xsl:when>
			<xsl:when test="@number-style='upper-roman'">upperroman</xsl:when>
			<xsl:when test="@number-style='lower-roman'">lowerroman</xsl:when>
    		<xsl:otherwise>
    			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Unsupported @number-style="<xsl:value-of select="@number-style"/>"</xsl:with-param></xsl:call-template>
    			<xsl:text>arabic</xsl:text>
    		</xsl:otherwise>
    	</xsl:choose>
	</xsl:variable>		
    <db:orderedlist numeration="{$numeration}"><xsl:apply-templates select="@*|node()"/></db:orderedlist>
</xsl:template>


<xsl:template match="c:list[@display='inline']">
	<xsl:for-each select="c:item">
		<xsl:if test="position()!=1">; </xsl:if>
    	<xsl:apply-templates select="*|text()|node()|comment()"/>
    </xsl:for-each>
</xsl:template>


<xsl:template match="c:item">
    <db:listitem>
    	<xsl:call-template name="cnx.list.item"/>
    </db:listitem>
</xsl:template>

<xsl:template match="c:list[@list-type='labeled-item']/c:item">
	<db:member>
    	<xsl:call-template name="cnx.list.item">
    		<xsl:with-param name="inline-only" select="1"/>
    	</xsl:call-template>
	</db:member>
</xsl:template>

<xsl:template name="cnx.list.item">
	<xsl:param name="inline-only" select="0"/>
	<xsl:apply-templates select="@*"/>
   	<xsl:choose>
   		<xsl:when test="c:title">
   			<db:formalpara>
   				<xsl:apply-templates select="*[local-name(.)!='para']|node()"/>
   			</db:formalpara>
   			<xsl:apply-templates select="c:para"/>
   		</xsl:when>
   		<xsl:when test="c:para and $inline-only = 0">
			<xsl:apply-templates select="node()"/>
   		</xsl:when>
   		<xsl:when test="$inline-only != 0">
			<xsl:apply-templates select="node()"/>
   		</xsl:when>
   		<xsl:when test="db:title">
            <db:formalpara>
                <xsl:apply-templates select="node()"/>
            </db:formalpara>
   		</xsl:when>
   		<xsl:otherwise>
	    	<db:para>
				<xsl:apply-templates select="node()"/>
			</db:para>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@start-value">
    <xsl:attribute name="startingnumber">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>



<!-- ****************************************
        A simple c:figure = img
        By simple, I mean:
        * only a c:media (no c:subfigure, c:table, c:code)
        * only a c:image in the c:media (no c:audio, c:flash, c:video, c:text, c:java-applet, c:labview, c:download)
        * no c:caption
        * c:title cannot have xml elements in it, just text
     **************************************** -->
<xsl:template match="c:media[not(ancestor::c:para) and c:image[not(starts-with(@src, 'http'))]]">
	<db:mediaobject><xsl:call-template name="media.image"/></db:mediaobject>
</xsl:template>
<!-- See m21854 //c:equation/@id="eip-id14423064" -->
<xsl:template match="c:media[(ancestor::c:para) and c:image[not(starts-with(@src, 'http'))]]|c:figure[not(@orient) or @orient='horizontal']/c:subfigure/c:media">
	<db:inlinemediaobject><xsl:call-template name="media.image"/></db:inlinemediaobject>
</xsl:template>
<!-- see m0003 -->
<xsl:template name="media.image">
	<xsl:apply-templates select="@*"/>
	<!-- Pick the correct image. To get Music Theory to use the included SVG file, 
	     we try to xinclude it here and then remove the xinclude in the cleanup phase.
	 -->
	 <!-- Including alt text as per http://docbook.org/tdg/en/html/textobject.html -->
        <db:textobject>
          <db:phrase>
            <xsl:choose>
                <!-- If the image has an alt value, use it. -->
                <xsl:when test="@alt != ''">
                    <xsl:value-of select="@alt"/>
                </xsl:when>
                <!-- If not, generate one based on ancestor features plus the file name -->
                <xsl:otherwise>
                    <xsl:choose>
                        <!-- If in a subfigure, use the subfigure's title or label, then output the filename. -->
                        <xsl:when test="parent::c:subfigure">
                            <xsl:choose>
                                <xsl:when test="parent::c:subfigure/c:title">
                                    <xsl:value-of select="parent::c:subfigure/c:title"/>
                                </xsl:when>
                                <xsl:when test="parent::c:subfigure/c:label[node()]">
                                    <xsl:value-of select="parent::c:subfigure/c:label"/>
                                    <xsl:if test="parent::c:subfigure/@type">
                                        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Ignoring c:subfigure/@type (for numbering)</xsl:with-param></xsl:call-template>
                                    </xsl:if>
                                    <xsl:text> </xsl:text>
                                    <xsl:number count="c:subfigure" format="(a)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Not labeling/numbering figure+subfigure for now (using "Subfigure" instead)</xsl:with-param></xsl:call-template>
                                    <xsl:text>Subfigure </xsl:text>
                                    <xsl:number count="c:subfigure" format="(a)" />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="c:image/@src"/>
                            <xsl:text>)</xsl:text>
                        </xsl:when>
                        <!-- If in a figure, use the figure's title or label, then output the filename. -->
                        <xsl:when test="parent::c:figure">
                            <xsl:choose>
                                <xsl:when test="parent::c:figure/c:title">
                                    <xsl:value-of select="parent::c:figure/c:title"/>
                                </xsl:when>
                                <xsl:when test="parent::c:figure/c:label[node()]">
                                    <xsl:value-of select="parent::c:figure/c:label"/>
                                    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Not numbering figure for now</xsl:with-param></xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Figure</xsl:text>
                                    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Not numbering figure for now</xsl:with-param></xsl:call-template>
                                </xsl:otherwise>
                             </xsl:choose>
                             <xsl:text> (</xsl:text>
                             <xsl:value-of select="c:image/@src"/>
                             <xsl:text>)</xsl:text>
                         </xsl:when>
                         <!-- Else, just output the filename. -->
                         <xsl:otherwise>
                             <xsl:value-of select="c:image/@src"/>
                         </xsl:otherwise>
                     </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
          </db:phrase>
        </db:textobject>
	<xsl:apply-templates select="c:image[contains(@src, '.eps')]"/>
	<xsl:choose>
	 	<xsl:when test="c:image[(not(@mime-type) or @mime-type != 'application/postscript') and not(contains(@src, '.eps')) and @for = 'pdf']">
	 		<xsl:apply-templates select="c:image[(not(@mime-type) or @mime-type != 'application/postscript') and not(contains(@src, '.eps')) and @for = 'pdf']"/>
	 	</xsl:when>
	 	<xsl:when test="c:image[(not(@mime-type) or @mime-type != 'application/postscript') and not(contains(@src, '.eps'))]">
	 		<xsl:apply-templates select="c:image[(not(@mime-type) or @mime-type != 'application/postscript') and not(contains(@src, '.eps'))]"/>
	 	</xsl:when>
		<xsl:when test="c:image[contains(@src, '.eps')]">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: No suitable image found. Hoping that a SVG file with the same name as the EPS file exists</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: No suitable image found.</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!-- Catch-all for any unsupported media -->
<xsl:template match="c:media[ancestor::c:para]" name="cnx.media.catchall" priority="0">
	<!-- All @id's are prefixed with the module id, so remove it before using it. -->
	<xsl:variable name="fullId">
		<xsl:call-template name="cnx.id"/>
	</xsl:variable>
	<xsl:variable name="modulePrefix">
		<xsl:value-of select="$cnx.module.id"/>
		<xsl:value-of select="$cnx.module.separator"/>
	</xsl:variable>
	<xsl:variable name="version" select="/c:document/c:metadata/md:version"/>
	<xsl:variable name="url">
		<xsl:call-template name="cnx.repository.url"/>
		<xsl:value-of select="$cnx.module.id"/>
        <xsl:text>/</xsl:text>
		<xsl:if test="not($version)">
		  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: This module does not have a md:version tag</xsl:with-param></xsl:call-template>
		  <xsl:text>latest</xsl:text>
		</xsl:if>
		<xsl:value-of select="$version"/>
		<xsl:text>/#</xsl:text>
		<xsl:value-of select="substring-after($fullId, $modulePrefix)"/>
	</xsl:variable>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Found c:media that is not converted. Adding a link to the online version and retaining the original media tag.</xsl:with-param></xsl:call-template>
	<db:link xlink:href="{$url}">
		<xsl:text>(This media type is not supported in this reader. Click to open media in browser.)</xsl:text>
	    <xsl:comment>Adding the original media tag for use by the offline HTML generation XSLT</xsl:comment>
	    <c:media>
		    <xsl:apply-templates select="@*|node()"/>
		  </c:media>
	</db:link>
</xsl:template>
<xsl:template match="c:media[not(ancestor::c:para)]" priority="0">
	<db:para>
		<xsl:call-template name="cnx.media.catchall"/>
	</db:para>
</xsl:template>

<xsl:template match="c:image[@src]">
	<xsl:variable name="ext" select="substring-after(substring(@src, string-length(@src) - 5), '.')"/>
	<xsl:variable name="format">
		<xsl:choose>
			<xsl:when test="$ext='jpg' or $ext='jpeg' or @mime-type = 'image/jpeg'">JPEG</xsl:when>
			<xsl:when test="$ext='gif' or @mime-type = 'image/gif'">GIF</xsl:when>
			<xsl:when test="$ext='png' or @mime-type = 'image/png'">PNG</xsl:when>
			<xsl:when test="$ext='svg' or @mime-type = 'image/svg+xml'">SVG</xsl:when>
			<!-- Hack for Music Theory. Kitty stores the .epc and .svg files -->
			<xsl:when test="@mime-type = 'application/postscript'">SVG</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Could not match mime-type. Assuming JPEG.</xsl:with-param></xsl:call-template>
				<xsl:text>JPEG</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<db:imageobject format="{$format}">
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
		    <xsl:call-template name="cnx.id"/>
		</xsl:attribute>
		<db:imagedata fileref="{@src}">
      <xsl:copy-of select="@_actual-width"/>
      <xsl:copy-of select="@_actual-height"/>
			<xsl:choose>
				<xsl:when test="@print-width and @print-width != ''">
					<xsl:attribute name="width"><xsl:value-of select="@print-width"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="@width and @width != ''">
					<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="@height and @height != ''">
				<xsl:attribute name="depth"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
		</db:imagedata>
	</db:imageobject>
</xsl:template>

<xsl:template match="c:image[contains(@src, '.eps')]">
	<db:imageobject format="SVG">
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:value-of select="$cnx.module.separator"/>
			<xsl:value-of select="generate-id(.)"/>
		</xsl:attribute>
		<db:imagedata>
			<xsl:choose>
				<xsl:when test="@print-width">
					<xsl:attribute name="width"><xsl:value-of select="@print-width"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="@width and @width != ''">
					<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="@height and @height != ''">
				<xsl:attribute name="depth"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
			
			<xsl:variable name="href">
				<xsl:value-of select="substring-before(@src, '.eps')"/>
				<xsl:text>.svg</xsl:text>
			</xsl:variable>
			<xi:include href="{$href}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
		</db:imagedata>
	</db:imageobject>
</xsl:template>

<!-- Create a custom ext:exercise element that will be converted and labeled later on -->
<!-- TODO: No longer discards solutions from the docbook. Fix epub generation
<xsl:template match="c:exercise">
	<ext:exercise>
		<xsl:apply-templates select="@*|node()[not(self::c:solution[not(@print-placement='here')][not(../@print-placement='here') or @print-placement='end'])]"/>
	</ext:exercise>
</xsl:template>

<xsl:template match="c:exercise[ancestor::c:example]">
	<ext:exercise>
		<xsl:apply-templates select="@*|node()[not(self::c:solution[@print-placement='end' or (../@print-placement='end' and not(@print-placement='here'))])]"/>
	</ext:exercise>
</xsl:template>
-->
<xsl:template match="c:exercise">
	<ext:exercise>
		<xsl:apply-templates select="@*|node()"/>
	</ext:exercise>
</xsl:template>


<!-- Create a custom ext:problem element that will be converted and labeled later on -->
<xsl:template match="c:problem">
	<ext:problem>
		<xsl:apply-templates select="@*|node()"/>
	</ext:problem>
</xsl:template>

<!-- Create a custom ext:solution element that will be converted and labeled later on -->
<xsl:template match="c:solution">
	<xsl:variable name="exerciseId">
		<xsl:call-template name="cnx.id">
			<xsl:with-param name="object" select=".."/>
		</xsl:call-template>
	</xsl:variable>
	<ext:solution exercise-id="{$exerciseId}">
		<xsl:apply-templates select="@*|node()"/>
	</ext:solution>
</xsl:template>

<!-- Create a custom ext:commentary element that will be converted and labeled later on -->
<xsl:template match="c:commentary">
	<ext:commentary>
		<xsl:apply-templates select="@*|node()"/>
	</ext:commentary>
</xsl:template>

<xsl:template match="c:exercise/c:label|c:problem/c:label|c:solution/c:label|c:commentary/c:label|c:rule/c:label">
	<ext:label>
		<xsl:apply-templates select="@*|node()"/>
	</ext:label>
</xsl:template>

<xsl:template match="c:foreign">
        <db:foreignphrase>
        	<xsl:apply-templates select="node()"/>
        </db:foreignphrase>
</xsl:template>

<!-- MathML -->
<xsl:template match="c:equation[not(ancestor::c:para)]/mml:math">
	<db:mediaobject><xsl:call-template name="insert-mathml"/></db:mediaobject>
</xsl:template>
<xsl:template match="mml:math">
	<db:inlinemediaobject><xsl:call-template name="insert-mathml"/></db:inlinemediaobject>
</xsl:template>

<xsl:template name="insert-mathml">
	<db:imageobject>
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:value-of select="$cnx.module.separator"/>
			<xsl:value-of select="generate-id(.)"/>
		</xsl:attribute>
		<db:imagedata format="SVG"> 
			<xsl:apply-templates mode="copy" select="."/>
		</db:imagedata>
	</db:imageobject>
</xsl:template>



<!-- Partially supported -->
<xsl:template match="c:subfigure">
	<xsl:if test="@type">
		<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Ignoring c:subfigure/@type (for numbering)</xsl:with-param></xsl:call-template>
	</xsl:if>
  <db:informalfigure>
		<xsl:apply-templates select="@*|node()"/>
      <xsl:if test="not(c:caption)">
        <db:caption>
          <db:emphasis role="bold">
            <xsl:number count="c:subfigure" format="(a)"/>
          </db:emphasis>
        </db:caption>
      </xsl:if>
  </db:informalfigure>
</xsl:template>

<xsl:template match="c:figure">
	<db:figure>
		<xsl:apply-templates select="@*|node()"/>
	</db:figure>
</xsl:template>




<xsl:template match="c:document/c:title">
	<db:title>
		<xsl:apply-templates select="@*|node()"/>
		<!-- Add the module id to titles for debugging. -->
		<xsl:if test="$cnx.debug!=0">
			<xsl:text> [</xsl:text>
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:text>]</xsl:text>
	    </xsl:if>
	</db:title>
</xsl:template>


<!-- Match glossary stuff.
     TODO: A glossary definition should be in a top-level glossary and then later
     turned into a single db:glossary at the end of a book.
 -->
<xsl:template match="c:glossary">
	<db:glossary>
		<xsl:apply-templates select="@*|node()"/>
	</db:glossary>
</xsl:template>

<xsl:template match="c:glossary/c:definition">
        <xsl:call-template name="definition"/>
</xsl:template>

<!-- According to eip-help/definition, can be in with the rest of the content, outside of a c:glossary -->
<xsl:template match="c:definition">
	<db:glosslist>
                <xsl:call-template name="definition"/>
	</db:glosslist>
</xsl:template>

<xsl:template name="definition">
	<db:glossentry>
		<xsl:apply-templates select="@*|c:term"/>
      <xsl:for-each select="c:meaning">
        <!-- Put each c:meaning in a db:glossdef, along with any of its associated c:examples -->
        <db:glossdef>
          <xsl:apply-templates select=".|following-sibling::c:example[generate-id(preceding-sibling::c:meaning[1]) = generate-id(current())]"/>
        </db:glossdef>
      </xsl:for-each>
      <xsl:apply-templates select="c:seealso"/>
	</db:glossentry>
</xsl:template>

<xsl:template match="c:seealso">
  <db:glossdef>
    <db:glossseealso>
      <xsl:apply-templates select="node()"/>
    </db:glossseealso>
  </db:glossdef>
</xsl:template>

<xsl:template match="c:meaning">
	<db:para>
                <xsl:apply-templates select="@*"/>
                <xsl:if test="count(parent::c:definition/c:meaning) > 1">
                        <xsl:number count="c:meaning" format="1. "/>
                </xsl:if>
                <xsl:if test="c:title">
                    <db:emphasis>
                        <xsl:apply-templates select="c:title/node()"/>
                    </db:emphasis>
                </xsl:if>
                <xsl:apply-templates select="node()[not(self::c:title)]"/>
        </db:para>
</xsl:template>

<xsl:template match="c:term[not(@url)]">
  <xsl:variable name="id">
    <xsl:value-of select="$cnx.module.id"/>
    <xsl:value-of select="$cnx.module.separator"/>
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>autoid-cnx2dbk-</xsl:text>
        <xsl:value-of select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
	<db:glossterm>
    <xsl:attribute name="xml:id"><xsl:value-of select="$id"/></xsl:attribute>
    <xsl:apply-templates select="@*"/>
    <xsl:if test="parent::c:definition[not(parent::c:glossary)]">
      <xsl:choose>
        <xsl:when test="c:label">
          <xsl:apply-templates select="c:label" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Definition: </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()"/>
  </db:glossterm>
  <xsl:call-template name="cnx.indexterm">
    <xsl:with-param name="id" select="$id"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="c:term[@document|@target-id]">
	<xsl:variable name="linkend">
		<xsl:if test="not(@document)"><xsl:value-of select="$cnx.module.id"/></xsl:if>
		<xsl:value-of select="@document"/>
		<xsl:if test="@target-id"><xsl:value-of select="$cnx.module.separator"/></xsl:if>
		<xsl:value-of select="@target-id"/>
	</xsl:variable>
  <xsl:variable name="id">
    <xsl:value-of select="$cnx.module.id"/>
    <xsl:value-of select="$cnx.module.separator"/>
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>autoid-cnx2dbk-</xsl:text>
        <xsl:value-of select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <db:glossterm linkend="{$linkend}">
    <xsl:attribute name="xml:id"><xsl:value-of select="$id"/></xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </db:glossterm>
  <xsl:call-template name="cnx.indexterm">
    <xsl:with-param name="id" select="$id"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="cnx.indexterm">
  <xsl:param name="id"/>
  <xsl:variable name="node">
    <xsl:apply-templates mode="cnx.strip-id" select="."/>
  </xsl:variable>
    <db:indexterm zone="{$id}">
      <db:primary>
        <xsl:apply-templates mode="cnx.strip-id" select="exsl:node-set($node)"/>
      </db:primary>
    </db:indexterm>
</xsl:template>
<!-- We need to strip out id's since the elements occur in 2 places in the document now -->
<xsl:template mode="cnx.strip-id" match="@xml:id"/>
<xsl:template mode="cnx.strip-id" match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates mode="cnx.strip-id" select="@*|node()"/>
  </xsl:copy>
</xsl:template>
<!-- To combine terms in the index that have different capitalizations, convert them to lowercase -->
<xsl:template mode="cnx.strip-id" match="c:*/text()">
  <xsl:value-of select="translate(., $cnx.uppercase, $cnx.smallcase)"/>
</xsl:template>

<!-- Add a processing instruction that will be matched in the custom docbook2fo.xsl -->
<xsl:template match="c:newline">
	<xsl:variable name="count">
		<xsl:if test="not(@count)">
			<xsl:text>1</xsl:text>
		</xsl:if>
		<xsl:value-of select="@count"/>
	</xsl:variable>
	<xsl:call-template name="cnx.newline.loop">
		<xsl:with-param name="count" select="$count"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="cnx.newline.loop">
	<xsl:param name="count">0</xsl:param>
	<xsl:if test="$count != 0">
		<xsl:choose>
			<xsl:when test="@effect='underline'">
				<xsl:processing-instruction name="cnx.newline.underline"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:processing-instruction name="cnx.newline"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="cnx.newline.loop">
			<xsl:with-param name="count" select="$count - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="c:space[@effect='underline']">
	<xsl:call-template name="cnx.space.loop">
		<xsl:with-param name="char">_</xsl:with-param>
		<xsl:with-param name="count" select="@count"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="cnx.space.loop">
	<xsl:param name="char"/>
	<xsl:param name="count">0</xsl:param>
	<xsl:if test="$count != 0">
		<xsl:value-of select="$char"/>
		<xsl:call-template name="cnx.space.loop">
			<xsl:with-param name="char" select="$char"/>
			<xsl:with-param name="count" select="$count - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Add metadata like authors, an abstract, etc -->
<xsl:template match="c:metadata">
	<xsl:apply-templates select="node()"/>
</xsl:template>

<!-- Make sure module keywords (that don't exist elsewhere in the module)
		are added to the index -->
<!--
<xsl:template match="md:keyword">
	<xsl:variable name="term" select="text()"/>
	<xsl:if test="not(//c:term[text()=$term])">
		<db:indexterm>
			<db:primary><xsl:value-of select="$term"/></db:primary>
		</db:indexterm>
	</xsl:if>
</xsl:template>
-->

</xsl:stylesheet>
