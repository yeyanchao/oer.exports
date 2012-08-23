==============
 What is this?
==============

The EPUB spec supports a subset of the CSS2 spec.
This package takes an HTML file and CSS3 and changes it so CSS features that aren't in the EPUB spec get "baked into" the HTML.

Some useful "features" in CSS that are "baked in" using this tool:

- pseudo-elements like ``::before`` and ``::after``
- counters for numbering sections, figures, tables, etc
- the content property (used to replace the contents of a tag)
- looking up text elsewhere (target-text)
- moving content later in the document (move-to)

Specifically, this supports:

- https://developer.mozilla.org/en/CSS/%3abefore
- https://developer.mozilla.org/en/CSS/content
- https://developer.mozilla.org/en/CSS/counter
- https://developer.mozilla.org/en/CSS/counter-reset
- https://developer.mozilla.org/en/CSS/counter-increment
- http://www.w3.org/TR/css3-gcpm/#the-target-counter-and-target-counters-v
- http://www.w3.org/TR/css3-gcpm/#the-target-text-value
- http://www.w3.org/TR/css3-content/#moving

The resulting HTML file has all of these pseudo elements and replaced content "baked in".

Since the same CSS *can* be used for other output formats you should list multiple properties and this will use the last property that's parseable.

==========
 Examples
==========

------------------------------
 Pseudo and Counters (CSS 2)
------------------------------

Let's say you want to add numbering for figures::

  figure { counter-increment: figure; }
  figure caption::before { content: "Figure " counter(figure) ": "; }

  <figure><img src=".."/><caption>Such a cute cat</caption></figure>

There are 2 features of CSS 2 that we used but EPUB does not support.
This tool takes both the CSS and HTML and transforms it into the following::

  <figure><img src=".."/><caption><span>Figure 12: </span>Such a cute cat</caption></figure>


------------------------------
 Linked Lookup (CSS 3)
------------------------------

For example, let's say you have the following CSS and HTML::

  a[href] { content: target-text(attr(href), content()); }

  Be sure to check out <a href="#factoring">Factoring Polynomials</a>.

``target-text`` and ``target-counter`` are new in CSS 3 and are not supported by browsers and definitely not EPUB readers.
This tool spits out the following::

  Be sure to check out <a href="#factoring"><span>4.7 Factoring Polynomials</span></a>.


------------------------------
 Moving Content Later (CSS 3)
------------------------------

Occasionally you may want to move content to have it display somewhere other than where it is; that's where ``move-to`` comes to the rescue!

For example, let's say you have the following HTML::

  <div class="chapter">
    <div class="exercise">What is 1+1?</div>
    <p>Some content</p>
    <p>Some more content</p>
  </div>

And you'd like to move all the exercises to the end of a chapter.
You can accomplish that by using the following CSS::

  .exercise { move-to: chapter-exercises; }
  .chapter::after { content: pending(chapter-exercises); }


------------------------------
 Graceful Fallback
------------------------------

Often it's useful in printed content to refer to page numbers (since users can't click) and some PDF generation tools will understand the CSS but there's no need to keep 2 CSS files around for EPUB and PDF.
This package gracefully ignores CSS properties it can't parse (like looking up a page number in the ``{ content: counter(page); }``). 
Adding a rule to the previous example will yield the same HTML as before but still render page numbers for PDFs::

  a[href] { content: content() " (Page " counter(page) ")"; }



====================
 Installing
====================

To run the QUnit tests just point your browser to ./test/index.html

To process a HTML and CSS file you will need to download http://phantomjs.org (Headless webkit).

Then, to process a HTML file::

  /path/to/phantomjs phantom-harness.coffee /path/to/less/file /absolute/path/to/htmlfile.html ./output.xhtml ./output.css

To see an example:
- point your browser to ./test/example.html
- open up the debugging console
- copy the contents of ./test/example.less and paste it into the textarea
- Press Tab to start the processing
When it's done, text in yellow is content that was added/changed by the script.
