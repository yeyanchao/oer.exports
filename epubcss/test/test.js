(function() {
  var runTest;

  runTest = function(expect, html, css) {
    var p, root;
    root = $('#qunit-fixture');
    root[0].innerHTML = html;
    p = new module.exports();
    p.emulate(css, root);
    root.find('.debug-epubcss').removeClass('debug-epubcss');
    root.find('*[class=""]').removeAttr('class');
    return equal(root[0].innerHTML, expect);
  };

  test('content simple', function() {
    var css, expect, html;
    css = "article { content: \"pass\"; }";
    html = "<article>fail</article>";
    expect = "<article>pass</article>";
    return runTest(expect, html, css);
  });

  test('pseudo simple', function() {
    var css, expect, html;
    css = "article::before { content: \"before\"; }\narticle::after { content: \"after\"; }";
    html = "<article>text1<span>text2</span>text3</article>";
    expect = "<article><span class=\"pseudo-element before\">before</span>text1<span>text2</span>text3<span class=\"pseudo-element after\">after</span></article>";
    return runTest(expect, html, css);
  });

  test('counter simple', function() {
    var css, expect, html;
    css = "*::before { content: \" before:\" counter(c1) \" \"; }\n*::after  { content: \" after:\"  counter(c1) \" \"; }\n*         { counter-increment: c1; }";
    html = "<article>text1<span>text2<span><span>text3</span>text4</span></span><span>text5</span>text6</article>";
    expect = "<article><span class=\"pseudo-element before\"> before:1 </span>text1<span><span class=\"pseudo-element before\"> before:2 </span>text2<span><span class=\"pseudo-element before\"> before:3 </span><span><span class=\"pseudo-element before\"> before:4 </span>text3<span class=\"pseudo-element after\"> after:4 </span></span>text4<span class=\"pseudo-element after\"> after:4 </span></span><span class=\"pseudo-element after\"> after:4 </span></span><span><span class=\"pseudo-element before\"> before:5 </span>text5<span class=\"pseudo-element after\"> after:5 </span></span>text6<span class=\"pseudo-element after\"> after:5 </span></article>";
    return runTest(expect, html, css);
  });

  test('counter', function() {
    var css, expect, html;
    css = "article { counter-reset: a -10 b c 20; }\narticle { counter-increment: a b -2 c; }\narticle { content: \"a=\" counter(a) \",b=\" counter(b) \",c=\" counter(c); }";
    html = "<article>fail</article>";
    expect = "<article>a=-9,b=-2,c=21</article>";
    return runTest(expect, html, css);
  });

  test('attr', function() {
    var css, expect, html;
    css = "article::before { content: attr(href); }";
    html = "<article href=\"pass\">fail</article>";
    expect = "<article href=\"pass\"><span class=\"pseudo-element before\">pass</span>fail</article>";
    return runTest(expect, html, css);
  });

  test('target-counter simple', function() {
    var css, expect, html;
    css = "article       { counter-reset: counter 20; }\nem            { counter-increment: counter; }\ntest          { content: target-counter(attr(href), counter); }\ntest::before  { content: target-counter(attr(href), counter, lower-roman); }\ntest::after   { content: target-counter(attr(href), counter, upper-latin); }";
    html = "<article><test href=\"#correct\">text0</test><em id=\"some-other-test\">text1</em><em id=\"correct\">text2</em></article>";
    expect = "<article><test href=\"#correct\"><span class=\"pseudo-element before\">xxii</span>22<span class=\"pseudo-element after\">V</span></test><em id=\"some-other-test\">text1</em><em id=\"correct\">text2</em></article>";
    return runTest(expect, html, css);
  });

  test('target-counter', function() {
    " This test replaces the content of an element (deleting the child) and increments the child";
    var css, expect, html;
    css = "test            { counter-increment: counter; }\narticle         { content: target-counter(attr(href), counter); }\narticle::before { content: target-counter(attr(href), counter); }";
    html = "<article href=\"#correct\"><test id=\"some-other-test\"/><test id=\"correct\"/></article>";
    expect = "<article href=\"#correct\"><span class=\"pseudo-element before\">0</span>2</article>";
    return runTest(expect, html, css);
  });

  test('counter with display:none', function() {
    var css, expect, html;
    css = ".hide       { display: none; }\ntest        { counter-increment: counter; }\ntest        { content: counter(counter); }";
    html = "<article><test class=\"hide\">fail</test><test class=\"hide\">fail</test><test>fail</test></article>";
    expect = "<article><test>1</test></article>";
    return runTest(expect, html, css);
  });

  test('target-text', function() {
    var css, expect, html;
    css = "test          { content: target-text(attr(href), content()); }\ntest::before  { content: target-text(attr(href), content(before)); }\ntest::after   { content: target-text(attr(href), content(after)); }\ntest2::before { content: \"BEFORE\"; }\ntest2::after  { content: \"AFTER\"; }\ninner::before { content: \"B\"; }\ninner::after  { content: \"D\"; }\nhide          { display: none; }";
    html = "<article><test href=\"#itsme\">text1</test><test2 id=\"itsme\">A<inner>C<hide>XXX</hide></inner>E</test2>X</article>";
    expect = "<article><test href=\"#itsme\"><span class=\"pseudo-element before\">BEFORE</span>ABCDE<span class=\"pseudo-element after\">AFTER</span></test><test2 id=\"itsme\"><span class=\"pseudo-element before\">BEFORE</span>A<inner><span class=\"pseudo-element before\">B</span>C<span class=\"pseudo-element after\">D</span></inner>E<span class=\"pseudo-element after\">AFTER</span></test2>X</article>";
    return runTest(expect, html, css);
  });

  test('target-text and counters', function() {
    var css, expect, html;
    css = "test          { content: target-text(attr(href), content()); }\ntest::before  { content: target-text(attr(href), content(before)); }\ntest::after   { content: target-text(attr(href), content(after)); }\ntest2::before { content: \"BEFORE\"; }\ntest2::after  { content: \"AFTER\"; }\ninner::before { content: \"B\"; }\ninner::after  { content: \"D\"; }\nhide          { display: none; }";
    html = "<article><test href=\"#itsme\"></test><test2 id=\"itsme\">A<inner>C<hide>XXX</hide></inner>E</test2>X</article>";
    expect = "<article><test href=\"#itsme\"><span class=\"pseudo-element before\">BEFORE</span>ABCDE<span class=\"pseudo-element after\">AFTER</span></test><test2 id=\"itsme\"><span class=\"pseudo-element before\">BEFORE</span>A<inner><span class=\"pseudo-element before\">B</span>C<span class=\"pseudo-element after\">D</span></inner>E<span class=\"pseudo-element after\">AFTER</span></test2>X</article>";
    return runTest(expect, html, css);
  });

  test('string-set simple', function() {
    var css, expect, html;
    css = "html          { string-set: test-string \"SHOULD NEVER SEE THIS\"; }\narticle       { string-set: test-string \"SIMPLE\"; }\narticle::before  { content: string(test-string); }\ntest::before  { content: string(test-string); }\ntest          { string-set: test-string target-text(attr(href), content()) \"-text\"; }\ntest2         { content: string(test-string); }";
    html = "<article><test href=\"#itsme\"></test><test2 id=\"itsme\">A<inner>B</inner>C</test2>X</article>";
    expect = "<article><span class=\"pseudo-element before\">SIMPLE</span><test href=\"#itsme\"><span class=\"pseudo-element before\">ABC-text</span></test><test2 id=\"itsme\">ABC-text</test2>X</article>";
    return runTest(expect, html, css);
  });

  test('string-set counter', function() {
    var css, expect, html;
    css = "article { counter-reset: c1 1234; }\ntest    { string-set: s1 counter(c1); }\ntest2   { content: string(s1); }";
    html = "<article><test></test><test2></test2></article>";
    expect = "<article><test></test><test2>1234</test2></article>";
    return runTest(expect, html, css);
  });

  test('string-set multiple', function() {
    var css, expect, html;
    css = "article { string-set: test-string1 \"success\", test-string2 \"SUCCESS\"; }\ntest    { content: string(test-string1) \" \" string(test-string2); }";
    html = "<article><test>FAILED</test></article>";
    expect = "<article><test>success SUCCESS</test></article>";
    return runTest(expect, html, css);
  });

  test('string-set complex', function() {
    var css, expect, html;
    css = "test  { string-set: test-string target-text(attr(href), content()) \"-text\"; }\ntest2 { content: string(test-string); }\nhide  { display: none; }";
    html = "<article><test href=\"#itsme\"></test><test2 id=\"itsme\">A<inner>B<hide>XXX</hide></inner>C</test2>X</article>";
    expect = "<article><test href=\"#itsme\"></test><test2 id=\"itsme\">ABC-text</test2>X</article>";
    return runTest(expect, html, css);
  });

  test('move-to simple', function() {
    var css, expect, html;
    css = "test  { move-to: BUCKET1; }\ntest2 { content: pending(BUCKET1); }";
    html = "<article><test>ABC</test><test2></test2></article>";
    expect = "<article><test2><test>ABC</test></test2></article>";
    return runTest(expect, html, css);
  });

  test('move-to', function() {
    var css, expect, html;
    css = "test::before  { move-to: BUCKET1; content: \"123\"; }\ntest          { move-to: BUCKET2; }\ntest::after   { move-to: BUCKET1; content: \"456\";}\ntest2::before { content: pending(BUCKET1); }\ntest2::after  { content: pending(BUCKET2); }";
    html = "<article><test>ABC</test>tail1<test2>DEF</test2>tail2</article>";
    expect = "<article>tail1<test2><span class=\"pseudo-element before\"><span class=\"pseudo-element before\">123</span><span class=\"pseudo-element after\">456</span></span>DEF<span class=\"pseudo-element after\"><test>ABC</test></span></test2>tail2</article>";
    return runTest(expect, html, css);
  });

}).call(this);
