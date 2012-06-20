Download DITA-OT1.5_full_easy_install_M21_bin.zip from http://sourceforge.net/projects/dita-ot/files/
  and rename DITA-OT1.5 to "dita"


To get FOP to handle MathML add the following line to dita/demo/fo/cfg/fo/xsl/custom.xsl :
	<xsl:include href="../../../../../../xsl/fo-include-svg.xsl"/>


Install the STIXGeneral and STIXSize1 fonts from the fonts directory
  (getting this right is a pain. see the tests dir to make sure FOP and Batik can find the fonts)


Make sure FOP knows about the fonts by adding the following lines to dita/demo/fo/fop/conf/fop.xconf 
  under the following XPath: fop/renderers/renderer[@mime="application/pdf"]/fonts :
	<font embed-url="../fonts/stix/STIXGeneral.ttf">
		<font-triplet name="STIXGeneral" style="normal" weight="normal"/>
	</font>
	<font embed-url="../fonts/stix/STIXGeneralItalic.ttf">
		<font-triplet name="STIXGeneral" style="italic" weight="normal"/>
	</font>
	<font embed-url="../fonts/stix/STIXGeneralBol.ttf">
		<font-triplet name="STIXGeneral" style="normal" weight="bold"/>
	</font>
	<font embed-url="../fonts/stix/STIXGeneralBolIta.ttf">
		<font-triplet name="STIXGeneral" style="italic" weight="bold"/>
	</font>
	<font embed-url="../fonts/stix/STIXSiz1Sym.ttf">
		<font-triplet name="STIXSize1" style="normal" weight="normal"/>
	</font>


So DITA doesn't replace the math-specific characters them with Helvetica 
  (and make "#" instead of the correct characters in the PDF)
  add the following into dita/demo/fo/cfg/fo/font-mappings.xml under font-mappings/font-table:

	<logical-font name="STIXGeneral"><physical-font char-set="default"><font-face>STIXGeneral</font-face></physical-font></logical-font>
	<logical-font name="STIXSize1"><physical-font char-set="default"><font-face>STIXSize1</font-face></physical-font></logical-font>

  (Otherwise demo/fo/xsl/fo/i18n-postprocess.xsl will silently replace them with Helvetica )


To get FOP to compile large PDF's add the following line:
	<jvmarg line="-Xmx2000M"/>

  to the line: <java classname="${fo.saxon.classname}" classpathref="project.class.path" fork="true">
    in dita/demo/fo/build.xml


Run Cnxml2Dita to generate a DITA .map file and .dita files for each module.


Start up a DITA-configured shell:
  $ declare -x DITA_HOME=./dita
  $ sh dita/startcmd.sh


Run:
  $ ant -f build.xml -Dtranstype=pdf -Dargs.input=../tests/00-all.ditamap
