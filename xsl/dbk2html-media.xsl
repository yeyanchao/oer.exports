<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:cnx="http://cnx.rice.edu/cnxml" version="1.0"> 
<!-- Portions are taken from http://cnx.org/aboutus/technology/cnxml/stylesheet/media.xsl -->
 
  <!-- Squash PARAMs--> 
  <xsl:template match="cnx:param"/> 
 
  <!-- MEDIA (catch-all/fall-back case) --> 
  <xsl:template match="cnx:media"> 
    <!-- None of the cnxml is 0.5. It is always auto-upgraded.
    <xsl:choose> 
      <xsl:when test="$version='0.5'"> 
        <xsl:call-template name="default-media"/> 
      </xsl:when> 
      <xsl:otherwise> 
    -->
        <xsl:choose> 
          <xsl:when test="child::*[@for='online']"> 
            <xsl:apply-templates select="child::*[@for='online'][1]"/> 
          </xsl:when> 
          <xsl:when test="child::*[not(self::cnx:longdesc) and not(@for='pdf')]"> 
            <xsl:apply-templates select="child::*[not(self::cnx:longdesc) and not(@for='pdf')][1]"/> 
          </xsl:when> 
        </xsl:choose>
    <!--  
      </xsl:otherwise> 
    </xsl:choose>
     --> 
  </xsl:template> 
 
  <!-- OBJECT and MEDIA --> 
  <xsl:template match="cnx:object|cnx:download"> 
    <xsl:call-template name="default-media"/> 
  </xsl:template> 
 
  <xsl:template name="default-media"> 
    <div class="media"> 
      <xsl:call-template name="IdCheck"/> 
      <object> 
        <xsl:for-each select="@width|@height"> 
          <xsl:attribute name="{name()}"> 
            <xsl:value-of select="."/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <xsl:for-each select="cnx:param"> 
          <xsl:attribute name="{@name}"> 
            <xsl:value-of select="@value"/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <span class="cnx_label"> 
          <!--Media File:--> 
          <xsl:call-template name="cnx.gentext"> 
            <xsl:with-param name="key">MediaFile</xsl:with-param> 
            <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
          </xsl:call-template> 
          <xsl:text>: </xsl:text> 
        </span> 
        <a class="link" href="{@src}"> 
          <xsl:choose> 
            <xsl:when test="cnx:title"> 
              <xsl:apply-templates select="cnx:title"/> 
            </xsl:when> 
            <xsl:when test="cnx:param[@name='title' and normalize-space(@value) != '']"> 
              <xsl:value-of select="cnx:param[@name='title']/@value"/> 
            </xsl:when> 
            <xsl:otherwise> 
              <xsl:value-of select="@src"/> 
            </xsl:otherwise> 
          </xsl:choose> 
        </a> 
        <xsl:apply-templates/> 
      </object> 
    </div> 
  </xsl:template> 
 
  <!-- TEXT --> 
  <xsl:template match="cnx:text"> 
    <div class="media"> 
      <xsl:call-template name="IdCheck"/> 
      <xsl:apply-templates/> 
    </div> 
  </xsl:template> 
  
  <!-- IMAGE (cnxml version 0.6) --> 
  <xsl:template match="cnx:image"> 
    <span class="media" id="{parent::cnx:media/@id}"> 
      <xsl:choose> 
        <xsl:when test="@thumbnail!=''"> 
          <a href="{@src}"> 
            <img src="{@thumbnail}"> 
              <xsl:call-template name="image-attributes"/> 
            </img> 
          </a> 
        </xsl:when> 
        <xsl:otherwise> 
          <img src="{@src}"> 
            <xsl:call-template name="image-attributes"/> 
          </img> 
        </xsl:otherwise> 
      </xsl:choose> 
    </span> 
  </xsl:template> 
 
  <xsl:template name="image-attributes"> 
    <xsl:for-each select="@width|@height|@id"> 
      <xsl:attribute name="{name()}"> 
        <xsl:value-of select="."/> 
      </xsl:attribute> 
    </xsl:for-each> 
    <xsl:choose> 
      <xsl:when test="@longdesc"> 
        <xsl:attribute name="longdesc"> 
          <xsl:value-of select="@longdesc"/> 
        </xsl:attribute> 
      </xsl:when> 
      <xsl:when test="cnx:longdesc"> 
        <xsl:attribute name="longdesc"> 
          <xsl:value-of select="cnx:longdesc"/> 
        </xsl:attribute> 
      </xsl:when> 
      <xsl:when test="parent::cnx:media/@longdesc"> 
        <xsl:attribute name="longdesc"> 
          <xsl:value-of select="parent::cnx:media/@longdesc"/> 
        </xsl:attribute> 
      </xsl:when> 
      <xsl:when test="parent::cnx:media/cnx:longdesc"> 
        <xsl:attribute name="longdesc"> 
          <xsl:value-of select="parent::cnx:media/cnx:longdesc"/> 
        </xsl:attribute> 
      </xsl:when> 
    </xsl:choose> 
    <xsl:choose> 
      <xsl:when test="parent::cnx:media[@alt!='']"> 
        <xsl:attribute name="alt"> 
          <xsl:value-of select="parent::cnx:media/@alt"/> 
        </xsl:attribute> 
      </xsl:when> 
      <xsl:otherwise> 
        <xsl:call-template name="alt-generator"/> 
      </xsl:otherwise> 
    </xsl:choose> 
    <xsl:for-each select="cnx:param"> 
      <xsl:attribute name="{@name}"> 
        <xsl:value-of select="@value"/> 
      </xsl:attribute> 
    </xsl:for-each> 
  </xsl:template> 
 
  <!-- Alt generator (if that param is absent) --> 
  <xsl:template name="alt-generator"> 
      <xsl:attribute name="alt"> 
        <xsl:choose> 
          <xsl:when test="parent::cnx:subfigure or ancestor::*[2][self::cnx:subfigure]"> 
            <xsl:choose> 
              <xsl:when test="ancestor::cnx:subfigure[1]/*[self::cnx:name or self::cnx:title]"> 
                <xsl:value-of select="ancestor::cnx:subfigure[1]/*[self::cnx:name or self::cnx:title]"/> 
              </xsl:when> 
              <xsl:when test="not(ancestor::cnx:subfigure[1][cnx:label[not(node())]])"> 
                <xsl:variable name="subfiguretype" select="translate(ancestor::cnx:subfigure[1]/@type,$upper,$lower)"/> 
                <xsl:choose> 
                  <xsl:when test="ancestor::cnx:subfigure[1][@type and $subfiguretype!='subfigure']"> 
                    <xsl:if test="ancestor::cnx:subfigure[1][cnx:label]"> 
                      <xsl:value-of select="ancestor::cnx:subfigure[1]/cnx:label"/> 
                      <xsl:text> </xsl:text> 
                    </xsl:if> 
                    <xsl:number level="any" count="cnx:subfigure[translate(@type,$upper,$lower)=$subfiguretype]"/> 
                  </xsl:when> 
                  <xsl:when test="ancestor::cnx:subfigure[1]/cnx:label"> 
                    <xsl:value-of select="ancestor::cnx:subfigure[1]/cnx:label"/> 
                    <xsl:text> </xsl:text> 
                    <xsl:number count="cnx:subfigure[not(@type) or translate(@type,$upper,$lower)='subfigure']" format="(a)"/> 
                  </xsl:when> 
                  <xsl:otherwise> 
                    <!--Figure--> 
                    <xsl:call-template name="cnx.gentext"> 
                      <xsl:with-param name="key">Figure</xsl:with-param> 
                      <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
                    </xsl:call-template> 
                    <xsl:text> </xsl:text> 
                    <xsl:variable name="figuretype" select="translate(ancestor::cnx:figure[1]/@type,$upper,$lower)"/> 
                    <xsl:choose> 
                      <xsl:when test="ancestor::cnx:figure[1][@type and $figuretype!='figure']"> 
                        <xsl:number level="any" count="cnx:figure[translate(@type,$upper,$lower)=$figuretype]"/> 
                      </xsl:when> 
                      <xsl:otherwise> 
                        <xsl:number level="any" count="cnx:figure[not(@type) or translate(@type,$upper,$lower)='figure']"/> 
                      </xsl:otherwise> 
                    </xsl:choose> 
                    <xsl:number count="cnx:subfigure[not(@type) or translate(@type,$upper,$lower)='subfigure']" format="(a)"/> 
                  </xsl:otherwise> 
                </xsl:choose> 
              </xsl:when> 
            </xsl:choose> 
            <xsl:text> (</xsl:text> 
            <xsl:value-of select="@src"/> 
            <xsl:text>)</xsl:text> 
          </xsl:when> 
          <xsl:when test="parent::cnx:figure or ancestor::*[2][self::cnx:figure]"> 
            <xsl:choose> 
              <xsl:when test="ancestor::cnx:figure[1]/*[self::cnx:name or self::cnx:title]"> 
                <xsl:value-of select="ancestor::cnx:figure[1]/*[self::cnx:name or self::cnx:title]"/> 
              </xsl:when> 
              <xsl:otherwise> 
                <xsl:choose> 
                  <xsl:when test="ancestor::cnx:figure[1]/cnx:label[node()]"> 
                    <xsl:value-of select="ancestor::cnx:figure[1]/cnx:label"/> 
                  </xsl:when> 
                  <xsl:otherwise> 
                    <!--Figure--> 
                    <xsl:call-template name="cnx.gentext"> 
                      <xsl:with-param name="key">Figure</xsl:with-param> 
                      <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
                    </xsl:call-template> 
                  </xsl:otherwise> 
                </xsl:choose> 
                <xsl:text> </xsl:text> 
                <xsl:variable name="figuretype" select="translate(ancestor::cnx:figure[1]/@type,$upper,$lower)"/> 
                <xsl:choose> 
                  <xsl:when test="ancestor::cnx:figure[1][@type and translate(@type,$upper,$lower)!='figure']"> 
                    <xsl:number level="any" count="cnx:figure[translate(@type,$upper,$lower)=$figuretype]"/> 
                  </xsl:when> 
                  <xsl:otherwise> 
                    <xsl:number level="any" count="cnx:figure[not(@type) or translate(@type,$upper,$lower)='figure']"/> 
                  </xsl:otherwise> 
                </xsl:choose> 
              </xsl:otherwise> 
            </xsl:choose> 
            <xsl:text> (</xsl:text> 
            <xsl:value-of select="@src"/> 
            <xsl:text>)</xsl:text> 
          </xsl:when> 
          <xsl:otherwise> 
            <xsl:value-of select="@src"/> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:attribute> 
  </xsl:template> 
 
  <!-- JAVA-APPLET (cnxml version 0.6) --> 
  <xsl:template match="cnx:java-applet"> 
    <span class="media" id="{parent::cnx:media/@id}"> 
      <applet code="{@code}"> 
        <xsl:for-each select="@width|@height|@id|@codebase|@archive|@name"> 
          <xsl:attribute name="{name()}"> 
            <xsl:value-of select="."/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <xsl:for-each select="cnx:param"> 
          <xsl:attribute name="{@name}"> 
            <xsl:value-of select="@value"/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <xsl:choose> 
          <xsl:when test="parent::cnx:media[@alt!='']"> 
            <xsl:attribute name="alt"> 
              <xsl:value-of select="parent::cnx:media/@alt"/> 
            </xsl:attribute> 
          </xsl:when> 
          <xsl:otherwise> 
            <xsl:call-template name="alt-generator"/> 
          </xsl:otherwise> 
        </xsl:choose> 
        <xsl:apply-templates/> 
      </applet> 
    </span> 
  </xsl:template> 
 
  <!-- VIDEO (cnxml version 0.6) --> 
  <xsl:template match="cnx:video"> 
    <span class="media" id="{parent::cnx:media/@id}"> 
      <object> 
        <xsl:for-each select="@classid|@codebase|@width|@height|@id"> 
          <xsl:attribute name="{name()}"> 
            <xsl:value-of select="."/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <xsl:for-each select="@src|@standby|@autoplay|@loop|@controller|@volume"> 
          <param name="{name()}" value="{.}"/> 
        </xsl:for-each> 
        <xsl:for-each select="cnx:param"> 
          <param name="{@name}" value="{@value}"/> 
        </xsl:for-each> 
        <embed> 
          <xsl:for-each select="@width|@height|@src|@standby|@autoplay|@loop|@controller|@volume"> 
            <xsl:attribute name="{name()}"> 
              <xsl:value-of select="."/> 
            </xsl:attribute> 
          </xsl:for-each> 
          <xsl:for-each select="cnx:param"> 
            <xsl:attribute name="{@name}"> 
              <xsl:value-of select="."/> 
            </xsl:attribute> 
          </xsl:for-each> 
          <xsl:apply-templates/> 
        </embed> 
      </object> 
    </span> 
  </xsl:template> 
 
  <!-- LABVIEW 7.0 (cnxml version 0.6) --> 
  <xsl:template match="cnx:labview[@version='7.0']"> 
    <div class="media labview example"> 
      <xsl:call-template name="IdCheck"/> 
      <span class="cnx_label"> 
        <xsl:call-template name="cnx.gentext"> 
          <xsl:with-param name="key">LabVIEWExample</xsl:with-param> 
          <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
        </xsl:call-template>:
        <xsl:text> </xsl:text> 
        <!--LabVIEW Example:--> 
      </span> 
      <xsl:for-each select="."> 
        (<a class="cnxn" href="{@viname}">run</a>) (<a class="cnxn" href="{@src}">source</a>)
      </xsl:for-each> 
    </div> 
  </xsl:template> 
  
  <!-- LABVIEW 8.X (cnxml version 0.6) --> 
  <xsl:template match="cnx:labview[@version!='7.0']"> 
    <xsl:param name="classid"> 
      <xsl:choose> 
        <xsl:when test="@version = '8.0'">CLSID:A40B0AD4-B50E-4E58-8A1D-8544233807AD</xsl:when> 
        <xsl:when test="@version = '8.2'">CLSID:A40B0AD4-B50E-4E58-8A1D-8544233807AE</xsl:when> 
      </xsl:choose> 
    </xsl:param> 
    <xsl:param name="codebase"> 
      <xsl:choose> 
        <xsl:when test="@version = '8.0'">ftp://ftp.ni.com/pub/devzone/tut/cnx_lv8_runtime.exe</xsl:when> 
        <xsl:when test="@version = '8.2'">ftp://ftp.ni.com/support/labview/runtime/windows/8.2/LVRunTimeEng.exe</xsl:when> 
      </xsl:choose> 
    </xsl:param> 
    <div class="media labview example"> 
      <xsl:call-template name="IdCheck"/> 
      <object classid="{$classid}" codebase="{$codebase}"> 
    <xsl:if test="@width"> 
      <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute> 
    </xsl:if> 
    <xsl:if test="@height"> 
      <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute> 
    </xsl:if> 
    <param name="SRC" value="{@src}"/> 
        <param name="LVFPPVINAME" value="{@viname}"/> 
    <param name="REQCTRL" value="false"/> 
    <param name="RUNLOCALLY" value="true"/> 
    <embed src="{@src}" reqctrl="true" runlocally="true" type="{@mime-type}" lvfppviname="{@viname}" pluginspage="http://digital.ni.com/express.nsf/bycode/exwgjq"> 
      <xsl:if test="@width"> 
        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute> 
      </xsl:if> 
      <xsl:if test="@height"> 
        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute> 
      </xsl:if> 
    </embed> 
      </object> 
      <p> 
        <!--Download--> 
        <xsl:call-template name="cnx.gentext"> 
          <xsl:with-param name="key">Download</xsl:with-param> 
          <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
        </xsl:call-template> 
        <xsl:text> </xsl:text> 
        <a class="cnxn" href="{@src}"> 
          <!--LabVIEW source--> 
          <xsl:call-template name="cnx.gentext"> 
            <xsl:with-param name="key">LabVIEWSource</xsl:with-param> 
            <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
          </xsl:call-template> 
        </a> 
      </p> 
    </div> 
  </xsl:template> 
 
  <!-- FLASH (cnxml version 0.6) --> 
  <xsl:template match="cnx:flash"> 
    <span class="media"> 
      <object type="application/x-shockwave-flash" data="{@src}"> 
        <xsl:call-template name="IdCheck"/> 
        <xsl:for-each select="@width|@height"> 
          <xsl:attribute name="{name()}"> 
            <xsl:value-of select="."/> 
          </xsl:attribute> 
        </xsl:for-each> 
        <xsl:for-each select="@wmode|@loop|@quality|@scale|@bgcolors"> 
          <param name="{name()}" value="{.}"/> 
        </xsl:for-each> 
        <xsl:if test="@flash-vars"> 
          <param name="FlashVars" value="{@flash-vars}"/> 
        </xsl:if> 
        <xsl:for-each select="cnx:param"> 
          <param name="{@name}" value="{@value}"/> 
        </xsl:for-each> 
        <param name="movie" value="{@src}"/> 
        <embed src="{@src}" type="application/x-shockwave-flash" pluginspace="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"> 
          <xsl:for-each select="@width|@height|@wmode|@loop|@quality|@scale|@bgcolor"> 
            <xsl:attribute name="{name()}"> 
              <xsl:value-of select="."/> 
            </xsl:attribute> 
          </xsl:for-each> 
          <xsl:if test="@flash-vars"> 
            <xsl:attribute name="FlashVars"> 
              <xsl:value-of select="@flash-vars"/> 
            </xsl:attribute> 
          </xsl:if> 
          <xsl:for-each select="cnx:param"> 
            <xsl:attribute name="{@name}"> 
              <xsl:value-of select="@value"/> 
            </xsl:attribute> 
          </xsl:for-each> 
        </embed> 
      </object> 
    </span> 
  </xsl:template> 
 
  <!-- Non-MP3 AUDIO (cnxml version 0.6) --> 
  <xsl:template match="cnx:audio"> 
    <div class="media musical example"> 
      <xsl:call-template name="IdCheck"/> 
      <span class="cnx_label"> 
        <!--Audio File:--> 
        <xsl:call-template name="cnx.gentext"> 
          <xsl:with-param name="key">AudioFile</xsl:with-param> 
          <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
        </xsl:call-template>:
      </span> 
      <a class="link" href="{@src}"> 
    <xsl:choose> 
      <xsl:when test="cnx:param[@name='title' and normalize-space(@value) != '']"> 
        <i><xsl:value-of select="cnx:param[@name='title']/@value"/></i> 
      </xsl:when> 
      <xsl:otherwise> 
        <xsl:value-of select="@src"/> 
      </xsl:otherwise> 
    </xsl:choose> 
      </a> 
    </div>       
  </xsl:template> 
 
  <!-- MP3 AUDIO and MEDIA of type: MP3 AUDIO (Tony Brandt) --> 
  <xsl:template match="cnx:media[@type='audio/mpeg']|cnx:audio[@mime-type='audio/mpeg']"> 
    <div class="media musical example"> 
      <xsl:call-template name="IdCheck"/> 
      <span class="cnx_label"> 
        <!--Musical Example:--> 
        <xsl:call-template name="cnx.gentext"> 
          <xsl:with-param name="key">MusicalExample</xsl:with-param> 
          <xsl:with-param name="lang" select="ancestor-or-self::*[@xml:lang]/@xml:lang"/> 
        </xsl:call-template>:
      </span> 
      <a class="cnxn" href="{@src}"> 
        <xsl:call-template name="composer-title-comments"/> 
      </a> 
    </div>       
  </xsl:template> 
 
  <!-- COMPOSER, TITLE and COMMENTS template --> 
  <xsl:template name="composer-title-comments"> 
    <xsl:if test="cnx:param[@name='composer' and normalize-space(@value) != '']"> 
      <xsl:value-of select="cnx:param[@name='composer']/@value"/> 
      <xsl:text>, </xsl:text> 
    </xsl:if> 
    <xsl:choose> 
      <xsl:when test="cnx:param[@name='title' and normalize-space(@value) != '']"> 
    <i><xsl:value-of select="cnx:param[@name='title']/@value"/></i> 
      </xsl:when> 
      <xsl:when test="cnx:title"> 
        <i><xsl:apply-templates select="cnx:title"/></i> 
      </xsl:when> 
      <xsl:otherwise> 
    <xsl:value-of select="@src"/> 
      </xsl:otherwise> 
    </xsl:choose> 
    <xsl:if test="cnx:param[@name='comments' and normalize-space(@value)!='']"> 
      <xsl:text>, </xsl:text> 
      <xsl:value-of select="cnx:param[@name='comments']/@value"/> 
    </xsl:if> 
  </xsl:template> 
 
</xsl:stylesheet> 