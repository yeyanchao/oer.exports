This package generates PDFs from complete zips of collections or zips of modules
by converting the collxml and cnxml to docbook and then using a XHTML+CSS3 to PDF script.

Technologies used:
 * Connexions  : http://cnx.org
 * Docbook XSL : http://docbook.org
 * Docbook RNG : http://docbook.org/rng
 * xsltproc    : http://xmlsoft.org/XSLT
 * Saxon 9     : http://saxon.sourceforge.net
 * pmml2svg    : http://pmml2svg.sourceforge.net
 * STIX Fonts  : http://stixfonts.org

The following files may be useful:
 * docbook.txt : Instructions on how to configure and run the docbook PDF generation
 * epub.txt    : Instructions on generating an epub from a collection or module
 * design.txt  : Notes on the entire PDF generation process
 * notes.txt   : My personal scratchpad


To install and get it running:

$ sudo apt-get install python-virtualenv        # for the following commands
$ sudo apt-get install libxslt1-dev libxml2-dev # For lxml to compile
$ sudo apt-get install librsvg2-bin             # To convert SVG and math to PNG
$ sudo apt-get install otf-stix

$ virtualenv .
$ source bin/activate
$ easy_install lxml argparse pil

# To generate an EPUB:
$ ./scripts/module2epub.sh "Connexions" test-ccap test-ccap.epub col12345 xsl/dbk2epub.xsl static/content.css

# To generate a PDF:
- Install PrinceXML or wkhtmltopdf
# python collectiondbk2pdf.py -p /usr/local/bin/prince -d test-ccap -s ccap-physics result.pdf   #for example
$ python collectiondbk2pdf.py -p ${path-to-wkhtml2pdf-or-princexml} -d test-ccap -s ccap-physics result.pdf


#To generate a MOBI:
- Install kindlegen
$ ./scripts/module2mobi.sh test-ccap mobi-name ccap-physics.css
