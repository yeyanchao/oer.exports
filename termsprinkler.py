import os
import sys
import zipfile
import urllib
import pkg_resources
from cStringIO import StringIO
from lxml import etree, html
from sys import stdin

dirname = os.path.dirname(__file__)

NAMESPACES = {
  'db':'http://docbook.org/ns/docbook',
  }

TERM_XPATH = etree.XPath('//db:primary/text()', namespaces=NAMESPACES)

# Modified from http://stackoverflow.com/questions/1973026/insert-tags-in-elementtree-text
stylesheet = etree.XSLT(etree.XML("""
  <xsl:stylesheet version="1.0"
     xmlns:fn="uri:custom-func"
     xmlns:db="http://docbook.org/ns/docbook"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="@*|node()">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::db:primary)]">
      <xsl:copy-of select="fn:term-finder(.)" />
    </xsl:template>         
  </xsl:stylesheet>
"""))

def sprinkle_terms(xml):
  """ Takes in a etree.Element and sprinkles in hints for the index wherever a term is used """
  terms = set()
  for i, obj in enumerate(TERM_XPATH(xml)):
    s = obj.strip()
    if s != '':
      terms.add(s)
      
  def term_finder(context, s):
    results = []
    r = s[0] # Remaining parts of the string
    
    # TODO: keep looping
    found = True
    while found:
      found = False
      for t in terms:
        if t in r:
          found = True
          #found the term in the string!
          index = r.find(t)
          if index > 0:
            results.append(r[:index])
          r = r[index+len(t):]
          results.append(t)
          glossterm = etree.Element('{%s}indexterm' % NAMESPACES['db'])
          index = etree.SubElement(glossterm, '{%s}primary' % NAMESPACES['db'])
          index.text = t
          results.append(glossterm)
    results.append(r)
    return results
  
  ns = etree.FunctionNamespace('uri:custom-func') # register global namespace
  ns['term-finder'] = term_finder # define function in new global namespace
  return stylesheet(xml)

def main():
    try:
      import argparse
      parser = argparse.ArgumentParser(description='Add index hints next to terms used in text')
      parser.add_argument('file', help='/path/to/collection.dbk', type=file)
      args = parser.parse_args()
  
      xml = sprinkle_terms(etree.parse(args.file))
      print etree.tostring(xml)
    except ImportError:
      print "argparse is needed for commandline"

if __name__ == '__main__':
    sys.exit(main())
