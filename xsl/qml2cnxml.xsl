<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:md="http://cnx.rice.edu/mdml" 
                xmlns="http://cnx.rice.edu/cnxml"
                xmlns:c="http://cnx.rice.edu/cnxml"
                xmlns:q="http://cnx.rice.edu/qml/1.0">

  <!-- Import our local translation keys -->
  <xsl:import href="l10n/cnxmll10n.xsl"/>

  <!-- FIXME: The following need to be added to cnxml10n.xsl: 
      <l:gentext key="singleresopnsehelp" text="Select one"/>
      <l:gentext key="multipleresponsehelp" text="Select all that apply"/>
      <l:gentext key="orderedreponsehelp" text="Select all that apply, in order"/>
      <l:gentext key="seeresource" text="See resource:"/>
      <l:gentext key="hintinnoteplural" text="See hints in notes"/>
      <l:gentext key="hintinnote" text="See hint in note"/>
  -->

  <!-- FIXME: This param isn't very robust (not sure if there is a document ancestor from where this is called, doesn't account 
       for pre-0.6 modules, nor modules where metadata isn't correct). -->
  <xsl:param name="modlang">
    <xsl:choose>
      <xsl:when test="ancestor::document/metadata/md:language">
        <xsl:value-of select="ancestor::document/metadata/md:language"/>
      </xsl:when>
      <xsl:otherwise>en</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- If there is a q:problemset, convert it into a c:section. -->
  <xsl:template match="q:problemset">
    <section>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@id">
            <xsl:value-of select="@id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>q2c-problemset-</xsl:text>
            <xsl:value-of select="generate-id()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <title>
        <xsl:call-template name="cnx.gentext">
          <xsl:with-param name="key">ProblemSet</xsl:with-param>
          <xsl:with-param name="lang" select="$modlang"/>
        </xsl:call-template>
      </title>
      <xsl:apply-templates />
    </section>
  </xsl:template>

  <!-- If there is a c:exercise around the q:item, remake the exercise to use a "Problem" label and number it (via @type) only with the other qml "Problems" (unless it's 
       in an example).  This should match online behavior.  -->
  <xsl:template match="c:exercise[q:item]">
    <exercise id="{@id}">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:attribute name="type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="not(ancestor::c:example)">
          <xsl:attribute name="type">q2c-qml-item</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@print-placement">
          <xsl:copy-of select="@print-placement" />
        </xsl:when>
        <xsl:when test="processing-instruction('solution_in_back') and ancestor::c:example">
          <xsl:attribute name="print-placement">end</xsl:attribute>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="c:label">
          <xsl:copy-of select="c:label"/> 
        </xsl:when>
        <xsl:otherwise>
          <label>
            <xsl:call-template name="cnx.gentext">
              <xsl:with-param name="key">Problem</xsl:with-param>
              <xsl:with-param name="lang" select="$modlang"/>
            </xsl:call-template>
          </label>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*[not(self::c:label)]"/>
    </exercise>
  </xsl:template>

  <!-- This is basically for the case of a q:item in a c:exercise. -->
  <xsl:template match="q:item">
    <xsl:call-template name="item"/>
  </xsl:template>

  <!-- If the q:item is in a q:problemset, generate a c:exercise. Don't worry about special numbering via @type since problemset precludes mixing with other CNXML elements. -->
  <xsl:template match="q:item[parent::q:problemset]">
    <exercise>
      <xsl:attribute name="id">
        <xsl:text>q2c-exercise-</xsl:text>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <label>
        <xsl:call-template name="cnx.gentext">
          <xsl:with-param name="key">Problem</xsl:with-param>
          <xsl:with-param name="lang" select="$modlang"/>
        </xsl:call-template>
      </label>
      <xsl:call-template name="item"/>
    </exercise>
  </xsl:template>

  <!-- Make a c:problem and maybe c:solution for the q:item -->
  <xsl:template name="item">
    <problem id="{@id}">
      <div id="q2c-{@id}-question">
        <xsl:apply-templates select="q:question"/>
        <xsl:if test="@type!='text-response' and q:answer">
          <span effect="italics">
            <xsl:text> (</xsl:text>
            <xsl:choose>
              <xsl:when test="@type='single-response'">
<!--
                <xsl:call-template name="cnx.gentext">
                  <xsl:with-param name="key">singleresponsehelp</xsl:with-param>
                  <xsl:with-param name="lang" select="$modlang"/>
                </xsl:call-template>
-->
                <xsl:text>Select one</xsl:text>
              </xsl:when>
              <xsl:when test="@type='multiple-response'">
<!--
                <xsl:call-template name="cnx.gentext">
                  <xsl:with-param name="key">multipleresponsehelp</xsl:with-param>
                  <xsl:with-param name="lang" select="$modlang"/>
                </xsl:call-template>
-->
                <xsl:text>Select all that apply</xsl:text>
              </xsl:when>
              <xsl:when test="@type='ordered-response'">
<!--
                <xsl:call-template name="cnx.gentext">
                  <xsl:with-param name="key">orderedresponsehelp</xsl:with-param>
                  <xsl:with-param name="lang" select="$modlang"/>
                </xsl:call-template>
-->
                <xsl:text>Select all that apply, in order</xsl:text>
              </xsl:when>
            </xsl:choose>
            <xsl:text>)</xsl:text>
          </span>
        </xsl:if>
        <!-- I don't think we're even processing the resource for online view. -->
        <xsl:apply-templates select="q:resource" />
      </div>
      <xsl:if test="@type!='text-response' and q:answer">
        <list id="q2c-{@id}-answers" list-type="enumerated" number-style="lower-alpha" mark-suffix=")">
          <xsl:apply-templates select="q:answer" />
        </list>
      </xsl:if>
      <!-- If there are hints, note that these available in footnotes. -->
      <xsl:if test="q:hint">
        <para id="q2c-{@id}-hints">
          <span effect="italics">
            <!-- FIXME: These may need to be parameterized for PDF vs. EPUB to read "See hint(s) in footnote(s)" vs. "See hint(s) in note(s)", respectively. -->
<!--
            <xsl:call-template name="cnx.gentext">
              <xsl:with-param name="key">
                <xsl:choose>
                  <xsl:when test="count(q:hint) &gt; 1">hintinnoteplural</xsl:when>
                  <xsl:otherwise>hintinnote</xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="lang" select="$modlang" />
            </xsl:call-template>
-->
            <xsl:choose>
              <xsl:when test="count(q:hint) &gt; 1">See hints in notes</xsl:when>
              <xsl:otherwise>See hint in note</xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
          </span>
          <xsl:apply-templates select="q:hint" />
        </para>
      </xsl:if>
    </problem>
    <!-- Since q:answer and q:feedback are optional (probably to accommodate text-response items?), only output a solution if they exist. -->
    <xsl:if test="q:answer or q:feedback">
      <solution id="q2c-{@id}-solution">
        <!-- Output each of the matching answers from the key. -->
        <xsl:call-template name="process.answers"/>
        <!-- Then output the feedback for the entire item. -->
        <xsl:apply-templates select="q:feedback" mode="item.feedback" />
      </solution>
    </xsl:if>
  </xsl:template>

  <!-- Output each of the matching answers from the key. -->
  <!-- FIXME: This process elements not in q:answer order, but in q:key/@answer order, which could look off for @type='multiple-response' (though is necessary for 
       @type='ordered-response'). -->
  <xsl:template name="process.answers">
    <!-- Get the answer key -->
    <xsl:param name="key.answers" select="q:key/@answer"/>
    <!-- Get the first correct answer from the key (before the first comma if there are multiple, otherwise just the whole string) -->
    <xsl:param name="key.current.answer">
      <xsl:choose>
        <xsl:when test="contains($key.answers,',')">
          <xsl:value-of select="normalize-space(substring-before($key.answers,','))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($key.answers)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- If there are more correct answers in the key, make a string of that to process through on the next loop. -->
    <xsl:param name="key.answers.remainder">
      <xsl:choose>
        <xsl:when test="substring(substring-after($key.answers,$key.current.answer),1,1) = ','">
          <xsl:value-of select="substring-after($key.answers,concat($key.current.answer,','))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($key.answers,$key.current.answer)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Make a list with "a)" number styling for each correct answer.  -->
    <xsl:for-each select="q:answer[@id=$key.current.answer]">
      <list list-type="enumerated" number-style="lower-alpha" mark-suffix=")">
        <xsl:attribute name="start-value">
          <xsl:number count="q:answer" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:text>q2c-</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>-answer-</xsl:text>
          <xsl:number count="q:answer" />
        </xsl:attribute>
        <item>
          <xsl:apply-templates select="q:response"/>
          <xsl:apply-templates select="q:feedback" mode="answer.feedback"/>
        </item>
      </list>
    </xsl:for-each>
    <xsl:if test="$key.answers.remainder!=''">
      <xsl:call-template name="process.answers">
        <xsl:with-param name="key.answers" select="$key.answers.remainder"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- I don't think we're even processing the resource for online view. -->
  <xsl:template match="q:resource">
    <span effect="italics">
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:text> (</xsl:text>
<!--
      <xsl:call-template name="cnx.gentext">
        <xsl:with-param name="key">seeresource</xsl:with-param>
        <xsl:with-param name="lang" select="$modlang"/>
      </xsl:call-template>
-->
      <xsl:text>See resource:</xsl:text>
      <xsl:text> </xsl:text>
      <link url="{@uri}">
        <xsl:value-of select="@uri"/>
      </link>
      <xsl:text>)</xsl:text>
    </span>
  </xsl:template>

  <!-- Each of the possible answers in the question. -->
  <xsl:template match="q:answer">
    <item>
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="not(q:response)">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="q:response"/>
    </item>
  </xsl:template>

  <xsl:template match="q:question|q:response">
    <xsl:apply-templates />
  </xsl:template>

  <!-- Feedback for the whole item. -->
  <xsl:template match="q:feedback" mode="item.feedback">
    <div id="q2c-{parent::q:item/@id}-feedback">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Feedback fro each of the individual answers. -->
  <xsl:template match="q:feedback" mode="answer.feedback">
    <xsl:choose>
      <xsl:when test="child::*">
        <div>
          <xsl:attribute name="id">
            <xsl:value-of select="parent::q:item/@id"/>
            <xsl:text>-answer</xsl:text>
            <xsl:number count="q:answer"/>
            <xsl:text>-feedback</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <newline/>
        <span effect="italics">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="normalize-space(.)" />
          <xsl:text>)</xsl:text>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Turn each hint into a footnote. -->
  <xsl:template match="q:hint">
    <footnote>
      <xsl:apply-templates />
    </footnote>
  </xsl:template>

</xsl:stylesheet>
