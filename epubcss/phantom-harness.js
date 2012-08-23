(function() {
  var address, config, cssFile, fs, lessFile, lines, name, outputCSSFile, outputFile, page, param, startTime, system, val, value, _i, _len, _ref, _ref2;

  system = require('system');

  fs = require('fs');

  page = require("webpage").create();

  page.onConsoleMessage = function(msg, line, source) {
    return console.log("console> " + msg);
  };

  if (system.args.length < 5) {
    console.error("This program takes exactly 4 arguments:");
    console.error("CSS/LESS file (for example '/home/my-home/style.css)");
    console.error("Absolute path to html file (for example '/home/my-home/file.xhtml)");
    console.error("Output (X)HTML file");
    console.error("Output CSS file");
    console.error("Additional config params passed to the EpubCSS constructor:");
    console.error("  debug=true");
    console.error("  autogenerateClasses=false");
    phantom.exit(1);
  }

  cssFile = system.args[1];

  address = system.args[2];

  if (address[0] !== '/') {
    console.error("Path to HTML file does not seem to be an absolute path. For now it needs to start with a '/'");
    phantom.exit(1);
  }

  address = "file://" + address;

  outputFile = fs.open(system.args[3], 'w');

  outputFile.write('<html xmlns="http://www.w3.org/1999/xhtml">');

  outputCSSFile = fs.open(system.args[4], 'w');

  config = {};

  if (system.args.length > 5) {
    _ref = system.args.slice(5);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      param = _ref[_i];
      _ref2 = param.split('='), name = _ref2[0], value = _ref2[1];
      val = value === 'true';
      config[name] = val;
    }
  }

  lines = 0;

  page.onAlert = function(msg) {
    if (lines++ > 100000) {
      console.log('Still Serializing HTML...');
      lines = 0;
    }
    return outputFile.write(msg);
  };

  page.onConfirm = function(msg) {
    outputCSSFile.write(msg);
    outputCSSFile.close();
    return true;
  };

  console.log("Reading CSS file at: " + cssFile);

  lessFile = fs.read(cssFile, 'utf-8');

  console.log("Opening page at: " + address);

  startTime = new Date().getTime();

  page.open(encodeURI(address), function(status) {
    var loadScript, num;
    if (status !== 'success') {
      console.error("File not FOUND!!");
      phantom.exit(1);
    }
    console.log("Loaded? " + status + ". Took " + (((new Date().getTime()) - startTime) / 1000) + "s");
    loadScript = function(path) {
      if (page.injectJs(path)) {} else {
        console.error("Could not find " + path);
        return phantom.exit(1);
      }
    };
    loadScript(fs.workingDirectory + '/lib/jquery.js');
    loadScript(fs.workingDirectory + '/lib/less-1.3.0.js');
    loadScript(fs.workingDirectory + '/custom.js');
    loadScript(fs.workingDirectory + '/epubcss.js');
    loadScript(fs.workingDirectory + '/lib/dom-to-xhtml.js');
    num = page.evaluate(function(lessFile) {
      var aryHack, newCSS, parser;
      parser = new window.EpubCSS(config);
      newCSS = parser.emulate(lessFile);
      console.log('Serializing (X)HTML back out from WebKit...');
      aryHack = {
        push: function(str) {
          return alert(str);
        }
      };
      window.dom2xhtml.serialize($('body')[0], aryHack);
      return confirm(newCSS);
    }, lessFile);
    outputFile.flush();
    outputFile.write('</html>');
    outputFile.close();
    return phantom.exit();
  });

}).call(this);
