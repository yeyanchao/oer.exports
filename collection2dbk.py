import sys
import os
import Image
from StringIO import StringIO
from tempfile import mkstemp
#try:
#	import json
#except KeyError:
#	import simplejson as json

from lxml import etree
import urllib2

import module2dbk
import util

COLLXML_PARAMS = util.makeXsl('collxml-params-json.xsl')
COLLXML2DOCBOOK_XSL = util.makeXsl('collxml2dbk.xsl')

DOCBOOK_CLEANUP_XSL = util.makeXsl('dbk-clean-whole.xsl')
DOCBOOK_NORMALIZE_PATHS_XSL = util.makeXsl('dbk2epub-normalize-paths.xsl')
DOCBOOK_NORMALIZE_GLOSSARY_XSL = util.makeXsl('dbk-clean-whole-remove-duplicate-glossentry.xsl')


XINCLUDE_XPATH = etree.XPath('//xi:include', namespaces=util.NAMESPACES)
# etree.XSLT does not allow returning just a text node so the XSLT wraps it in a <root/>
PARAMS_XPATH = etree.XPath('/root[1]/text()[1]', namespaces=util.NAMESPACES)

def transform(xslDoc, xmlDoc):
  """ Performs an XSLT transform and parses the <xsl:message /> text """
  ret = xslDoc(xmlDoc)
  for entry in xslDoc.error_log:
    # TODO: Log the errors (and convert JSON to python) instead of just printing
    print >> sys.stderr, entry.message.encode('utf-8')
  return ret

# Main method. Doing all steps for the Google Docs to CNXML transformation
def convert(p, collxml, modulesDict, temp_dir, svg2png=True, math2svg=True, reduce_quality=False):
  """ Convert a collxml file (and dictionary of module info) to a Docbook file and dict of filename:bytes) """

  newFiles = {}

  p.start(len(modulesDict), 'collxml to dbk')

  paramsStr = PARAMS_XPATH(COLLXML_PARAMS(collxml))[0]
  collParamsUnicode = eval(paramsStr) #json.loads(paramsStr)
  collParams = {}
  for key, value in collParamsUnicode.items():
  	collParams[key.encode('utf-8')] = value
  dbk1 = transform(COLLXML2DOCBOOK_XSL, collxml)

  modDbkDict = {}
  # Each module can be converted in parallel
  for module, (cnxml, filesDict) in modulesDict.items():

    p.tick('Converting ' + module)
    module_temp_dir = os.path.join(temp_dir, module)
    if not os.path.exists(module_temp_dir):
      os.makedirs(module_temp_dir)
    modDbk, newFilesMod = module2dbk.convert(module, cnxml, filesDict, collParams, module_temp_dir, svg2png, math2svg, reduce_quality)
    modDbkDict[module] = etree.parse(StringIO(modDbk)).getroot()
    # Add newFiles with the module prefix
    for f, data in newFilesMod.items():
    	newFiles[os.path.join(module, f)] = data

  # Combine into a single large file
  # Replacing Xpath xinclude magic with explicit pyhton code
  for i, module in enumerate(XINCLUDE_XPATH(dbk1)):
    # m9003/index.included.dbk
    id = module.get('href').split('/')[0]
    if id in modDbkDict:
      module.getparent().replace(module, modDbkDict[id])
    else:
      print >> sys.stderr, "ERROR: Didn't find module source!!!!"
  
  # Clean up image paths
  dbk2 = transform(DOCBOOK_NORMALIZE_PATHS_XSL, dbk1)
  
  dbk3 = transform(DOCBOOK_CLEANUP_XSL, dbk2)
  dbk4 = transform(DOCBOOK_NORMALIZE_GLOSSARY_XSL, dbk3)

  # Create cover SVG and convert it to an image
  cover, newFiles2 = util.dbk2cover(dbk4, filesDict, svg2png)

  if svg2png:
    newFiles['cover.png'] = cover

  p.finish()
  return dbk4, newFiles
