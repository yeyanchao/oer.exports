This ZIP file contains the complete contents of a collection.

TO VIEW THE COLLECTION IN YOUR BROWSER: 
=======================================
Open the start.html file for viewing the collection's contents.  A navigation panel will be located on the left hand side.

INCLUDED FILES:
===============
HTML files of the collection's contents:
- start.html - A shortcut for viewing the collection's contents in a set of frames.
- content/cover.html and cover.png - Collection cover page and image.
- content/index.html - Collection title page.
- content/bk01-toc.html - Collection table of contents.
- content/*.html - HTML pages that make up the collection's contents.  Navigate to these pages by opening start.html in your browser.

Other support and advanced files:
- content/content.css - Primary CSS file for styling the HTML files.
- content/offline-zip-overrides.css - An additional CSS file for styling the HTML files.
- content/collection.xml - XML file that defines the structure of the collection, written in CollXML.  It cannot be reimported in the editing interface.
- content/collection.dbk - The collection converted into Docbook format.  Each module directory contains a Docbook file as well.

INCLUDED SUB-DIRECTORIES:
=========================
- content/mXXXXX/ (e.g. content/m10000/) - These directories contain files associated with each of the modules in the collection.
  - index.cnxml - The original XML source code representing the contents and metadata of the module, written in CNXML.
  - index_auto_generated.cnxml - A read-only version of the module XML file that has been upgraded to the latest version of CNXML and that includes extended metadata.
  - index.dbk - The index.cnxml file converted into a standalone Docbook file format.
  - index.included.dbk - The index.cnxml file converted into a Docbook format that is included in the collection.
  - mXXXXX.idXXXXXX.svg and mXXXXX.idXXXXXX.png - Math is automatically converted to these image formats for browsers that do not support MathML. 
  - Various media files - Images, videos, applets, audio recordings, etc., used in the module.  These will only appear if they are part of the module.
