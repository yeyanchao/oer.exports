See the docbook.txt for setting things up (You can ignore anything with Apache FOP).

Then, there are a couple of files that need patching:
docbook-xsl/epub/bin/lib/docbook.rb will need epub-xmlbase-and-namespace-prefixes.diff


Additionally, the epub scripts that come with Docbook require Ruby. On a debian/ubuntu system, run:
  apt-get install ruby

Another set of tools may work as an alternative: http://code.google.com/p/epub-tools/

We're ready to do some converting!

Then, you can create an epub of a collection by running:
  ./scripts/module2epub.sh "rhaptos" $COLLECTION_DIR

Or, you can create an epub of a module by running:
  ./scripts/module2epub.sh "rhaptos" $MODULE_DIR $MODULE_ID

If you just downloaded a module and unzipped it, then $COLLECTION_DIR is just "."
For example, after downloading and unzipping m10349_2.42.zip, you should have a m10349_2.42 dir.
Run:
  ./scripts/module2epub.sh "rhaptos" ./m10349_2.42 m10349

And out should pop an epub (may have a .zip extension. If so, remove it) 
