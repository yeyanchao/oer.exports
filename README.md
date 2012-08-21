oer.exports
===========

To install and get it running:

    sudo apt-get install python-virtualenv        # for the following commands
    sudo apt-get install libxslt1-dev libxml2-dev # For lxml to compile
    sudo apt-get install librsvg2-bin             # To convert SVG and math to PNG
    sudo apt-get install otf-stix

    cd oer.exports
    virtualenv .
    source bin/activate
    easy_install lxml argparse pil

To generate a PDF:

    # Install PrinceXML or wkhtmltopdf
    # Then do the following:
    python collectiondbk2pdf.py -p ${path-to-wkhtml2pdf-or-princexml} -d test-ccap -s ccap-physics result.pdf

To generate an EPUB:

    ./scripts/module2epub.sh "Connexions" test-ccap test-ccap.epub col12345 xsl/dbk2epub.xsl static/content.css

To generate a MOBI:

    - Install kindlegen
    - Install ImageMagick
    - Install phantomjs
    - Install xsltproc
    $ ./scripts/mobibuilder.sh test-ccap mobi-name ccap-physics.css
