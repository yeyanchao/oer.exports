
import sys
import os
import Image
from StringIO import StringIO
from tempfile import mkdtemp
import subprocess

from lxml import etree
import urllib2

import module2dbk
import collection2dbk
import util

DEBUG= 'DEBUG' in os.environ

BASE_PATH = os.getcwd()

# XSL files
DOCBOOK2XHTML_XSL=util.makeXsl('dbk2epub.xsl')
DOCBOOK_CLEANUP_XSL = util.makeXsl('dbk-clean-whole.xsl')


def convert(dbk1, files):
  """ Converts a Docbook Element and a dictionary of files into a PDF. """

  def transform(xslDoc, xmlDoc):
    """ Performs an XSLT transform and parses the <xsl:message /> text """
    ret = xslDoc(xmlDoc) # , **({'cnx.tempdir.path':"'%s'" % tempdir}))    Don't set the tempdir. We don't need it
    for entry in xslDoc.error_log:
      # TODO: Log the errors (and convert JSON to python) instead of just printing
      print >> sys.stderr, entry.message.encode('utf-8')
    return ret

  # Step 0 (Sprinkle in some index hints whenever terms are used)
  # termsprinkler.py $DOCBOOK > $DOCBOOK2
  if DEBUG:
    open('temp-collection1.dbk','w').write(etree.tostring(dbk1,pretty_print=True))

  # Step 1 (Cleaning up Docbook)
  dbk2 = transform(DOCBOOK_CLEANUP_XSL, dbk1)
  if DEBUG:
    open('temp-collection2.dbk','w').write(etree.tostring(dbk2,pretty_print=True))

  return dbk2, files


def main():
  try:
    import argparse
  except ImportError:
    print "argparse is needed for commandline"
    return 1

  parser = argparse.ArgumentParser(description='Converts a a collection directory to an xhtml file and additional images')
  parser.add_argument('directory')
  parser.add_argument('-r', dest='reduce_quality', help='Reduce image quality', action='store_true')
  # parser.add_argument('-t', dest='temp_dir', help='Path to store temporary files to (default is a temp dir that will be removed)', nargs='?')
  parser.add_argument('-o', dest='output', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
  args = parser.parse_args()
  
  temp_dir = args.directory

  p = util.Progress()

  collxml, modules, allFiles = util.loadCollection(args.directory)
  dbk, newFiles = collection2dbk.convert(p, collxml, modules, temp_dir, svg2png=True, math2svg=True, reduce_quality=args.reduce_quality)
  allFiles.update(newFiles)

  dbk, files = convert(dbk, allFiles)

  args.output.write(etree.tostring(dbk))
  
  # Write out all the added files
  for name in newFiles:
    f = open(os.path.join(args.directory, name), 'w')
    f.write(newFiles[name])
    f.close()

if __name__ == '__main__':
    sys.exit(main())
