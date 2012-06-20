import sys
import os
import Image
from StringIO import StringIO
import subprocess

from lxml import etree
import urllib2
import util

SAXON_PATH = util.resource_filename('lib', 'saxon9he.jar')
MATH2SVG_PATH = util.resource_filename('xslt2', 'math2svg-in-docbook.xsl')

DOCBOOK_BOOK_XSL = util.makeXsl('moduledbk2book.xsl')

MATH_XPATH = etree.XPath('//mml:math', namespaces=util.NAMESPACES)
DOCBOOK_SVG_IMAGE_XPATH = etree.XPath('//db:imagedata[svg:svg]', namespaces=util.NAMESPACES)
DOCBOOK_SVG_XPATH = etree.XPath('svg:svg', namespaces=util.NAMESPACES)
DOCBOOK_IMAGE_XPATH = etree.XPath('//db:imagedata[@fileref]', namespaces=util.NAMESPACES)

# -----------------------------
# Transform Structure:
#
# Every transform takes in 3 arguments:
# - xml doc
# - dictionary of files (string name, string bytes)
# - optional dictionary of parameters (string, string)
#
# Every transform returns:
# - xml doc
# - dictionary of new files
# - A list of log messages
#

def extractLog(entries):
  """ Takes in an etree.xsl.error_log and returns a list of dicts (JSON) """
  log = []
  for entry in entries:
    # Entries are of the form:
    # {'level':'ERROR','id':'id1234','msg':'Descriptive message'}
    text = entry.message
    if text:
      print >> sys.stderr, text.encode('utf-8')
    #try:
    #    dict = json.loads(text)
    #    errors.append(dict)
    #except ValueError:
    log.append({
      u'level':u'CRITICAL',
      u'id'   :u'(none)',
      u'msg'  :unicode(text) })

def makeTransform(file):
  xsl = util.makeXsl(file)
  def t(xml, files, **params):
    xml = xsl(xml, **params)
    errors = extractLog(xsl.error_log)
    return xml, {}, errors
  return t    

# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(moduleId, xml, filesDict, collParams, temp_dir, svg2png=True, math2svg=True, reduce_quality=False):
  """ Convert a cnxml file (and dictionary of filename:bytes) to a Docbook file and dict of filename:bytes) """

  #if 'index.included.dbk' in filesDict:
  #  print >> sys.stderr, "LOG: Using already converted dbk file!"
  #  return (filesDict['index.included.dbk'], {})
  #print >> sys.stderr, "LOG: Working on Module %s" % moduleId
  # params are XPaths so strings need to be quoted
  params = {'cnx.module.id': "'%s'" % moduleId, 'cnx.svg.chunk': 'false'}
  params.update(collParams)

  # Use pmml2svg to convert MathML to inline SVG
  def mathml2svg(xml, files, **params):
    if math2svg:
      formularList = MATH_XPATH(xml)
      strErr = ''
      if len(formularList) > 0:
        
        # Take XML from stdin and output to stdout
        # -s:$DOCBOOK1 -xsl:$MATH2SVG_PATH -o:$DOCBOOK2
        strCmd = ['java','-jar', SAXON_PATH, '-s:-', '-xsl:%s' % MATH2SVG_PATH]
    
        # run the program with subprocess and pipe the input and output to variables
        p = subprocess.Popen(strCmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=True)
        # set STDIN and STDOUT and wait untill the program finishes
        stdOut, strErr = p.communicate(etree.tostring(xml))
    
        #xml = etree.fromstring(stdOut, recover=True) # @xml:id is set to '' so we need a lax parser
        parser = etree.XMLParser(recover=True)
        xml = etree.parse(StringIO(stdOut), parser)
  
        if strErr:
          print >> sys.stderr, strErr.encode('utf-8')
    return xml, {}, [] # xml, newFiles, log messages

  def imageResize(xml, files, **params):
    # TODO: parse the XML and xpath/annotate it as we go.
    newFiles = {}
    for position, image in enumerate(DOCBOOK_IMAGE_XPATH(xml)):
      filename = image.get('fileref')
      mimeType = image.getparent().get('format', 'JPEG')
      # Exception thrown if image doesn't exist
      if filename in files:
        try:
          bytes = files[filename]
          img = Image.open(StringIO(bytes))
          
          width = img.size[0]
          height = img.size[1]
          if reduce_quality: # Only resize when in DEBUG mode (so content entry sees the High Resolution PDFs)
            print >> sys.stderr, 'LOG: DEBUG: Reducing quality of %s (%s)' % (filename, mimeType)
            # Always resave
            fname = "_autogen-png2jpeg-%04d.jpg" % (position + 1)

            bytesFile = StringIO()
            img.save(bytesFile, 'jpeg', optimize=True, quality=30)
            # Since we probably changed the type of file to JPEG change the format in the image tag
            # The image type is used in the epub manifest to map images to their mime-type
            image.set('fileref', fname)
            image.set('format', 'JPEG')
            image.getparent().set('format', 'JPEG')

            newFiles[fname] = bytesFile.getvalue()
          
        except IOError:
          print >> sys.stderr, 'LOG: WARNING: Malformed image %s' % filename
      else:
        print >> sys.stderr, 'LOG: WARNING: Image missing %s' % filename
        pass
    return xml, newFiles, [] # xml, newFiles, log messages

  # Convert SVG elements to PNG files
  # (this mutates the document)
  def svg2pngTransform(xml, files, **params):
    newFiles2 = {}
    if svg2png:
      for position, image in enumerate(DOCBOOK_SVG_IMAGE_XPATH(xml)):
        print >> sys.stderr, 'LOG: Converting SVG to PNG'
        # TODO add the generated file to the edited files dictionary
        strImageName = "_autogen-svg2png-%04d.png" % (position + 1)
        svg = DOCBOOK_SVG_XPATH(image)[0]
        svgStr = etree.tostring(svg)

        pngStr = util.svg2png(svgStr)
        newFiles2[strImageName] = pngStr
        image.set('fileref', strImageName)
        image.set('format', 'PNG')
        image.getparent().set('format', 'PNG')

    return xml, newFiles2, [] # xml, newFiles, log messages

  PIPELINE = [
    makeTransform('cnxml-clean.xsl'),
    makeTransform('cnxml-clean-math.xsl'),
    # Have to run the cleanup twice because we remove empty mml:mo,
    # then remove mml:munder with only 1 child.
    # See m21903
    makeTransform('cnxml-clean-math.xsl'),
    makeTransform('cnxml-clean-math-simplify.xsl'),   # Convert "simple" MathML to cnxml
    makeTransform('cnxml2dbk.xsl'),   # Convert to docbook
    mathml2svg,
    makeTransform('dbk-clean.xsl'),
    imageResize, # Resizing is done before svg2png because svg2png uses a reduced color depth
    svg2pngTransform,
    makeTransform('dbk-svg2png.xsl'), # Clean up the image attributes
#    dbk2xhtml,
  ]

  newFiles = {}
  origAndNewFiles = {}
  origAndNewFiles.update(filesDict)

  for transform in PIPELINE:
    xml, newFiles2, errors = transform(xml, origAndNewFiles, **params)
    newFiles.update(newFiles2)
    origAndNewFiles.update(newFiles2)

  # Create a standalone db:book file for the module
  dbkStandalone = DOCBOOK_BOOK_XSL(xml)
  newFiles['index.standalone.dbk'] = etree.tostring(dbkStandalone)
  origAndNewFiles.update(newFiles)
  
  # Write out all files to the temp dir so they don't stay in memory
  for (key, value) in origAndNewFiles.items():
    print >> sys.stderr, "Writing out " + os.path.join(temp_dir, key)
    f = open(os.path.join(temp_dir, key), 'w')
    f.write(value)
    f.close()
  newFiles = {}
  
  return etree.tostring(xml), newFiles
