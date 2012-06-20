import os
import sys
import re
from StringIO import StringIO
from lxml import etree
from oer.epubcss import AddNumbering

VERBOSE = False # Overridden in the command line
COMPARE_XSL = etree.XSLT(etree.parse('compare.xsl'))

def transform(xsl, xml, **kwargs):
  to_text = etree.XSLT(etree.fromstring(xsl))
  result = to_text(xml)
  return etree.tostring(result, **kwargs)


TRIM_WHITESPACE = re.compile(r'\s+')


# Get just the text content
def find_text(xml, verbose=False):
  lines = []
  def app(text):
    if text is not None:
      lines.append(TRIM_WHITESPACE.sub(' ', text).strip())
  
  def rec(node):
    app(node.text if hasattr(node, 'text') else None)
    for child in node:
      rec(child)
    app(node.tail)
  
  rec(xml)
  return unicode('\n'.join(lines)).encode('utf-8')

# Get the HTML with styles applied
def find_styled_text(html, css, verbose=False):
  styled = AddNumbering(verbose=verbose).transform(etree.tostring(html), css, pretty_print = False)
  return find_text(styled.getroot())

# Get the HTML with styles applied
def find_styled_tags(html, css, verbose=False):
  styled = AddNumbering(verbose=verbose).transform(etree.tostring(html), css, pretty_print = False)
  return etree.tostring(styled)

def main():
  try:
    import argparse
    parser = argparse.ArgumentParser(description='This file runs a Diff on a HTML+CSS pair to understand what effect code changes have.\n Also, generates a HTML diff that is viewable in a browser.')
    parser.add_argument('-v', dest='verbose', help='Verbose printing to stderr', action='store_true')
    parser.add_argument('-r', dest='rebase', help='Make the just-generated HTML be the "Control" HTML (automatically done the 1st time you create a new test dir)', action='store_true')
    parser.add_argument('-f', dest='force', help='Force a rebase', action='store_true')
    parser.add_argument('-c', dest='css', help='CSS File', type=argparse.FileType('r'), nargs='?')
    parser.add_argument('test_dir')
    parser.add_argument('html', type=argparse.FileType('r'))
    args = parser.parse_args()

    html = etree.fromstring(args.html.read())
    # if args.verbose: print >> sys.stderr, "Transforming..."

    OLD_HTML = 'old.xhtml'
    NEW_HTML = 'new.xhtml'
    DIFF_HTML = 'report.xhtml'
    OLD_CSS = 'squirreled-away.css'
    NEW_CSS = 'style.css'
    
    old_css = os.path.join(args.test_dir, OLD_CSS)
    old_html = os.path.join(args.test_dir, OLD_HTML)
    new_css = os.path.join(args.test_dir, NEW_CSS)
    new_html = os.path.join(args.test_dir, NEW_HTML)
    diff_html = os.path.join(args.test_dir, DIFF_HTML)

    if not os.path.isdir(args.test_dir):
      os.mkdir(args.test_dir)
      args.rebase = True
      args.force = True
    if not os.path.isfile(old_html):
      args.rebase = True
      args.force = True

    css = []
    if args.css:
      css = [ args.css.read() ]
      open(new_css, 'w').write(css[0])
    
    new_html_data = find_styled_tags(html, css, verbose=args.verbose)
    open(new_html, 'w').write(new_html_data)
    
    if args.rebase:
      # Move the new files to the old
      if args.force:
        response = 'yes'
      else:
        response = raw_input("Are you sure you want to rebase? [no]: ")
      if response == 'yes':
        if os.path.isfile(new_css):
          os.rename(new_css, old_css)
        os.rename(new_html, old_html)
        print "Rebased!"
      else:
        print "Rebase Cancelled"

    # Generate the report
    if not args.rebase:
      diff_html_data = COMPARE_XSL(etree.parse(StringIO(new_html_data)), cssPath="'%s'" % NEW_CSS, oldPath="'%s'" % old_html)
      for log in COMPARE_XSL.error_log:
        print >> sys.stderr, log.message
      diff_str = etree.tostring(diff_html_data)
      diff_file = open(diff_html, 'w')
      diff_file.write(diff_str)
      print "Generated HTML diff at %s. Check it out!" % diff_html

  except ImportError:
    print "argparse is needed for commandline"

if __name__ == '__main__':
    sys.exit(main())
