import os
import sys
import codecs
from StringIO import StringIO
from lxml import etree

from custom import premailer
from custom import numbers
from custom.util import PropertyParser, ContentPropertyParser, parse_style, ContentEvaluator, State, UnsupportedError

__all__ = ['AddNumbering', 'UnsupportedError']

# By default use a special attribute and remove it at the end of parsing
# (do not apply alls the "simple' styles like color, font-face, etc
STYLE_ATTRIBUTE = '_custom_style' # 'style'

# Maps different features with which properties they support and which content they support
FEATURES = {
  'counter': (['counter-reset', 'counter-increment'], ['counter', 'counters']),
  'target' : ([], ['target-text', 'target-counter', 'target-counters']),
  'string' : (['string-set'], ['string']),
  'move'   : (['move-to'], ['pending'])
}

class AddNumbering(object):

  def __init__(self, args, pseudo_element_name='{http://www.w3.org/1999/xhtml}span'):
    self.node_at = {}
    self.evaluator = ContentEvaluator(self.node_at)
    self.reprocess = [] # nodes with content: target-counter(....) and the current counter values at that point for the node: (etree.Element, {'name', 4})
    self.args = args
    self.verbose = False
    if args is not None:
      self.verbose = args.verbose
    self.pseudo_element_name = pseudo_element_name


  def transform(self, html, explicit_styles = [], pretty_print = True):
    xpath = etree.XPath('//*')
    
    supported_properties = {}
    supported_content = {}

    for (props, contents) in FEATURES.values():
      for x in props:
        supported_properties[x] = True
      for x in contents:
        supported_content[x] = True
    
    def del_features(feature):
      (props, contents) = FEATURES[feature]
      for x in props:
        supported_properties[x] = False
      for x in contents:
        supported_content[x] = False

    if self.args is not None:
      if self.args.no_counter: del_features('counter')
      if self.args.no_target:  del_features('target')
      if self.args.no_string:  del_features('string')
      if self.args.no_move:    del_features('move')

    if self.verbose: print >> sys.stderr, 'LOG: Supported properties: %s' % str(supported_properties)
    if self.verbose: print >> sys.stderr, 'LOG: Supported content values: %s' % str(supported_content)
    
    p = premailer.Premailer(html, supported_properties=supported_properties, supported_content=supported_content, explicit_styles=explicit_styles, remove_classes=False, custom_style_attrib=STYLE_ATTRIBUTE, verbose=self.verbose)
    html = p.transform(pretty_print=pretty_print)
    html = etree.parse(StringIO(html))
    nodes = xpath(html)
    
    # Passes:
    # - expand all pseudo nodes and remove all hidden ones
    #   - find all the targets we'll need to look up
    # - calculate all the counters and save counters that will need to be looked up (target-counter)
    # - recalculate all the remaining content (that has target-counter) by looking up the nodes
    # - remove the styling attribute
    
    if self.verbose: print >> sys.stderr, "-------- Finding target nodes ( CSS target-counter() or target-text() ) : %d" % len(nodes)
    for node in nodes:
      style = node.attrib.get(STYLE_ATTRIBUTE, '')
      style = PropertyParser().parse(style)
      if 'content' in style:
        for (name, value) in style['content']:
          attr = None
          if 'target-text' == name: (attr, _) = value
          if 'target-counter' == name: (attr, _, _) = value
          if attr:
            id = node.attrib.get(attr, None)
            if id[0] == '#':
              id = id[1:]
            self.node_at[id] = None

    if self.verbose: print >> sys.stderr, "-------- Creating pseudo elements ( CSS :before and :after ) : %d" % len(nodes)
    for node in nodes:
      style = node.attrib.get(STYLE_ATTRIBUTE, '')
      self.expand_pseudo(node, style)
    
    if self.verbose: print >> sys.stderr, "-------- Running counters and generating simple content",
    nodes = xpath(html) # we may have added pseudo nodes so re-self.update
    if self.verbose: print >> sys.stderr, ": %d" % len(nodes)
    # This has to be done in a separate pass so we can look up target-counter
    for node in nodes:
      self.mutate_node(node)

    if self.verbose: print >> sys.stderr, "-------- Resolving link counters ( CSS3 target-counter ) : %d" % len(self.reprocess)
    for (node, self.evaluator.state.countersAt) in self.reprocess:
      self.evaluator.state.counters = self.evaluator.state.countersAt
      d = PropertyParser().parse(node.attrib.get(STYLE_ATTRIBUTE, ''))
      if 'content' in d:
        self._replace_content(node, d['content'])
        # also remove non-pseudo elements
        for child in node:
          if not self.is_pseudo(child):
            node.remove(child)
    
    if self.verbose: print >> sys.stderr, "-------- Moving nodes ( CSS3 http://www.w3.org/TR/css3-content/#moving ) : %d" % len(nodes)
    nodes = xpath(html) # we may have removed nodes re-self.update
    move_to_destinations = {} # name -> list of nodes waiting to be dumped
    for node in nodes:
      style = PropertyParser().parse(node.attrib.get(STYLE_ATTRIBUTE, ''))
      if 'move-to' in style:
        dest = style['move-to']
        if dest != 'here': # Ignore if it's 'here'
          if dest not in move_to_destinations: move_to_destinations[dest] = []
          move_to_destinations[dest].append(node)
          # Can't just remove the node. because of tails...
          if node.tail is not None:
            if node.getprevious() is not None:
              if node.getprevious().tail is not None:
                node.getprevious().tail += node.tail
              else:
                node.getprevious().tail = node.tail
            else:
              if node.getparent().text is not None:
                node.getparent().text += node.tail
              else:
                node.getparent().text = node.tail
            node.tail = None
          node.getparent().remove(node)
          
      if 'content' in style:
        for (name, pending_name) in style['content']:
          if 'pending' == name:
            #TODO remove all children and text
            pending_name = str(pending_name)
            if pending_name in move_to_destinations:
              for n in move_to_destinations[pending_name]:
                node.append(n)
              move_to_destinations[pending_name] = []
    
    # Clean up the HTML.
    if STYLE_ATTRIBUTE != 'style':
      for node in nodes:
        if STYLE_ATTRIBUTE in node.attrib:
          del node.attrib[STYLE_ATTRIBUTE]
    
    return html

  def is_pseudo(self, node):
    return node.attrib.get('class', '') in ('pseudo-before', 'pseudo-after')
  
  def _replace_content(self, node, content):
    # because of lxml's use of text tails, if we have:
    # <node><pseudo-before>...</pseudo-before>...</node>
    #
    # then if we just set node.text='foo' then we'd get:
    # <node>foo<pseudo-before>...</pseudo-before>...</node>
    #
    # instead of the expected:
    # <node><pseudo-before>...</pseudo-before>foo</node>
    #
    text = self.evaluator.eval_content(node, content)
    if len(node) > 0 and self.is_pseudo(node[0]):
      node[0].tail = text
    else:
      node.text = text

  def update_counters(self, node, d):
    if 'counter-reset' in d:
      for (name, v) in d['counter-reset']:
        if name == 'none': continue
        if self.verbose: print >> sys.stderr, "Resetting %s to %d" % (name, v)
        self.evaluator.state.counters[name] = v
    if 'counter-increment' in d:
      for (name, v) in d['counter-increment']:
        if self.verbose: print >> sys.stderr, "Incrementing %s by %s" % (name, str(v))
        if name not in self.evaluator.state.counters:
          self.evaluator.state.counters[name] = 0
        self.evaluator.state.counters[name] += v

  def mutate_node(self, node):
    d = PropertyParser().parse(node.attrib.get(STYLE_ATTRIBUTE, ''))
    if d:
      self.update_counters(node, d)
    # if there's a target-counter pointing to this node, squirrel the counter (TODO: Should this be done _before_ incrementing?)
    id = node.attrib.get('id', None)
    if id and id in self.node_at:
      self.node_at[id] = (node, State(self.evaluator.state))
    if d:
      # We'll have to look up the id later to find the counter
      if 'content' in d:
        has_target = False
        for (key, _) in d['content']:
          if key in [ 'target-counter', 'target-text' ]:
            has_target = True
        if has_target:
          self.reprocess.append((node, State(self.evaluator.state)))
        else:
          self._replace_content(node, d['content'])
      # http://www.w3.org/TR/css3-gcpm/#setting-named-strings-the-string-set-pro
      if 'string-set' in d:
        has_target = False
        for (_, string_value) in d['string-set']:
          for (operation, _) in string_value:
            if operation in [ 'target-counter', 'target-text' ]:
              has_target = True
        if has_target:
          self.reprocess.append((node, State(self.evaluator.state)))
        else:
          for (string_name, string_value) in d['string-set']:
            string_computed = self.evaluator.eval_content(node, string_value)
            # Note: The 1st "value" is actually the string name
            print "Setting string %s to [%s]" % (string_name, string_computed)
            self.evaluator.state.strings[string_name] = string_computed

  def expand_pseudo(self, node, style, class_ = ''):
    d = parse_style(style, class_)
    
    if 'display' in d and 'none' == d['display']:
      node.getparent().remove(node)
      return
      
    newStyle = _style_to_string(d)
    node.attrib[STYLE_ATTRIBUTE] = newStyle
    # Also, if there's a target-counter then add it to the list
    if 'content' in d:
      content = ContentPropertyParser().parse(d['content'])
      if content is not None:
        for (function, args) in content:
          attr = None
          if function == 'target-counter':
            (attr, _, _) = args
          if function == 'target-text':
            (attr, _) = args
          
          if attr:
            n = node
            # If it's a pseudo element use the parent's attribute
            if class_ != '': n = node.getparent()
            id = n.attrib.get(attr, '')
            if id and len(id) > 0:
              # omit the hash tag
              if id[0] == '#':
                id = id[1:]
              self.node_at[id] = None
            else:
              if self.verbose: print >> sys.stderr, "WARNING: Ignoring lookup to a non-internal id: '%s' on a %s" % (href, n.tag)
    
    if not class_ and ':before' in style:
      pseudo = etree.Element(self.pseudo_element_name)
      pseudo.attrib['class'] = 'pseudo-before'
      node.insert(0, pseudo)
      if node.text:
        pseudo.tail = node.text
        node.text = ''
      self.expand_pseudo(pseudo, style, ':before')
    
    if not class_ and ':after' in style:
      pseudo = etree.Element(self.pseudo_element_name)
      pseudo.attrib['class'] = 'pseudo-after'
      node.append(pseudo)
      self.expand_pseudo(pseudo, style, ':after')


def _style_to_string(style):
  s = []
  for k, v in style.items():
    s += k + ':' + v + ';'
  return ''.join(s)



def main():
    try:
      import argparse
      parser = argparse.ArgumentParser(description='Apply CSS pseudo elements :before/:after and counters to HTML since epub does not support them')
      parser.add_argument('-v', dest='verbose', help='Verbose printing to stderr', action='store_true')
      parser.add_argument('-c', dest='css', help='CSS File', type=argparse.FileType('r'), nargs='*')
      parser.add_argument('-o', dest='output', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
      # parser.add_argument('--no-pseudo', dest='no_pseudo', help='Do not Emulate pseudo elements', action='store_true')
      parser.add_argument('--no-counter', dest='no_counter', help='Do not Emulate counters', action='store_true')
      parser.add_argument('--no-target', dest='no_target', help='Do not Emulate target-text', action='store_true')
      parser.add_argument('--no-string', dest='no_string', help='Do not Emulate string-set', action='store_true')
      parser.add_argument('--no-move', dest='no_move', help='Do not Emulate move-to', action='store_true')
      parser.add_argument('--no-default', dest='no_default', help='Emulate default styles', action='store_true')
      parser.add_argument('html',              nargs='?', type=argparse.FileType('r'), default=sys.stdin)
      args = parser.parse_args()
  
      # if self.verbose: if self.verbose: print >> sys.stderr, "Transforming..."
      if args.html:
        css = []
        if args.css:
          for style in args.css:
            css.append(style.read())
        result = AddNumbering(args).transform(args.html.read(), css)
        html = etree.tostring(result, encoding='ascii')
        args.output.write(html)
      
    except ImportError:
      print "argparse is needed for commandline"

if __name__ == '__main__':
    sys.exit(main())
