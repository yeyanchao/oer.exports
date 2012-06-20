This directory is structured the same way DocbookXSL is
  except that it makes remote calls to sourceforge.net to get the actual stylesheets
  which is taxing on their servers unless you have installed the Docbook XSL stylesheets
  into your system XML catalog.

You can use it as is, but for a production environment either:
 * Install the XML catalog files for docbook ( "apt-get install docbook-xsl" )
 * Download the docbook-xsl zip from http://sourceforge.net/projects/docbook/files/ and overwrite this dir
