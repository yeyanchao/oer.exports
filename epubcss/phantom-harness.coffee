system = require('system')
fs = require('fs')
page = require("webpage").create()

page.onConsoleMessage = (msg, line, source) ->
  console.log "console> " + msg # + " @ line: " + line

if system.args.length < 5
  console.error "This program takes exactly 4 arguments:"
  console.error "CSS/LESS file (for example '/home/my-home/style.css)"
  console.error "Absolute path to html file (for example '/home/my-home/file.xhtml)"
  console.error "Output (X)HTML file"
  console.error "Output CSS file"
  console.error "Additional config params passed to the EpubCSS constructor:"
  console.error "  debug=true"
  console.error "  autogenerateClasses=false"
  # console.error "  bakeInAllStyles=true"
  phantom.exit 1

cssFile = system.args[1]
address = system.args[2]

# Verify address is an absolute path
# TODO: convert relative paths to absolute ones
if address[0] != '/'
  console.error "Path to HTML file does not seem to be an absolute path. For now it needs to start with a '/'"
  phantom.exit 1
address = "file://#{address}"

outputFile = fs.open(system.args[3], 'w')
outputFile.write '<html xmlns="http://www.w3.org/1999/xhtml">'

outputCSSFile = fs.open(system.args[4], 'w')

config = {}
if system.args.length > 5
  for param in system.args.slice(5)
    [name, value] = param.split('=')
    val = value == 'true'
    config[name] = val

lines = 0
page.onAlert = (msg) ->
  if lines++ > 100000
    console.log 'Still Serializing HTML...'
    lines = 0
  outputFile.write msg

page.onConfirm = (msg) ->
  outputCSSFile.write msg
  outputCSSFile.close()
  true

console.log "Reading CSS file at: #{cssFile}"
lessFile = fs.read(cssFile, 'utf-8')

console.log "Opening page at: #{address}"
startTime = new Date().getTime()




page.open encodeURI(address), (status) ->
  if status != 'success'
    console.error "File not FOUND!!"
    phantom.exit(1)

  console.log "Loaded? #{status}. Took #{((new Date().getTime()) - startTime) / 1000}s"
  
  loadScript = (path) ->
    if page.injectJs(path)
    else
      console.error "Could not find #{path}"
      phantom.exit(1)
  
  loadScript(fs.workingDirectory + '/lib/jquery.js')
  loadScript(fs.workingDirectory + '/lib/less-1.3.0.js')
  loadScript(fs.workingDirectory + '/custom.js')
  loadScript(fs.workingDirectory + '/epubcss.js')
  loadScript(fs.workingDirectory + '/lib/dom-to-xhtml.js')

  num = page.evaluate((lessFile, config) ->
  
    parser = new (window.EpubCSS)(config)
    newCSS = parser.emulate(lessFile)

    # Hack to serialize out the HTML (sent to the console)
    console.log 'Serializing (X)HTML back out from WebKit...'
    aryHack =
      push: (str) -> alert str
    
    window.dom2xhtml.serialize($('body')[0], aryHack)
    
    confirm(newCSS)

  , lessFile, config)
  outputFile.flush()
  outputFile.write '</html>'
  outputFile.close()
  phantom.exit()
