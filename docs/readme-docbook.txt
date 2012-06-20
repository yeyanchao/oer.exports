Prerequisites:

 * Install Java
 * Download PrinceXML (7.0+) from http://princexml.com
 * Download the Docbook XSL-ns (1.75.2+) from http://sourceforge.net/projects/docbook/files/ (Remember to get the xsl-ns one!)
                            (http://sourceforge.net/projects/docbook/files/docbook-xsl-ns/1.75.2/docbook-xsl-ns-1.75.2.zip/download)


Download a collection zip from http://cnx.org . Examples:
 * Collaborative Statistics: http://cnx.org/content/col10522/1.36/complete
 * Elementary Algebra: http://cnx.org/content/col10614/1.3/complete
 * Music Theory : http://cnx.org/content/col10363/1.3/complete

We'll need to unzip these into the correct directories:
 * Unzip the Docbook XSL file into "docbook-xsl" (./docbook-xsl/fo/docbook.xsl should exist)
 * Unzip the collection zip into the project root (./col*/collection.xml should exist)


Now, we'll need to install/configure some fonts for Apache FOP (mostly the Math fonts).

Install the STIXGeneral and STIXSize1 fonts from the fonts directory into your OS
  (getting this right is a pain. see the tests dir to make sure FOP and Batik can find the fonts)
In Linux:
$ mkdir ~/.fonts
$ cp fonts/stix/*.ttf ~/.fonts

We're ready to do some converting!

See the 1st line of collectiondbk2pdf.py for what to run

For details on the output, check out the accompanying txt file.

Done! Now you should have a PDF!
