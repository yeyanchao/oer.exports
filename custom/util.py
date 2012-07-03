import cssselect # The customized one
from lxml.cssselect import TokenStream, String, Symbol, Token

import numbers

class UnsupportedError(Exception): pass

class State(object):
  def __init__(self, state = None):
    self.counters = {}
    self.strings = {}
    if state:
      self.counters = state.counters.copy()
      self.strings = state.strings.copy()

def parse_style(style, class_ = ''):
  news = {}
  if class_:
    test = class_ + '{'
    style = style[style.find(test) + len(test):].split('}')[0]
  elif not style or style[0] == ':':
    return news
  elif style[0] == '{':
    style = style[1:style.find('}')]
  for k, v in [x.strip().split(':', 1) for x in style.split(';') if x.strip()]:
    news[k.strip()] = v.strip()
  # TODO: validate whether properties should be discarded (using ContentPropertyParser)
  return news

class PropertyParser(object):
  """ Parses all the style properties we care about (display:none, counter-reset:, counter-increment:, and content:) """
  def parse(self, style, class_ = ''):
    style = parse_style(style, class_)
    ret = {}
    for (name, value) in style.iteritems():
      method = '_parse_' + name.replace('-', '_')
      if hasattr(self, method):
        method = getattr(self, method)
        val = method(value)
        #if name in ret:
          # Decide whether to overwrite it.
          # 2 cases:
          # - doesn't have an unknown
          # - ends-with "!important"
        if val is not None:
          ret[name] = val
    return ret
  def _counter(self, value, default):
    acc = []
    stream = TokenStream(cssselect.tokenize(value))
    while stream.peek() is not None:
      name = str(stream.next())
      by = default
      if _is_int(str(stream.peek())):
        by = int(str(stream.next()))
      acc.append((name, by))
    return acc
  def _parse_counter_reset(self, value):
    return self._counter(value, 0)
  def _parse_counter_increment(self, value):
    return self._counter(value, 1)
  def _parse_content(self, value):
    return ContentPropertyParser().parse(value)
  # http://www.w3.org/TR/css3-gcpm/#setting-named-strings-the-string-set-pro
  # Note: The 1st arg in the "value" is the string name
  def _parse_string_set(self, value):
    # string-set may set multiple strings (separated by commas)
    # For example:
    # { string-set: string1 "value1", string2 "value2", string3 counter(item, decimal); }
    # Also, we can't just split on commas because for example target-text() has commas in it
    # This first piece is just a glorified split(',')
    stream = TokenStream(cssselect.tokenize(value))
    values = []
    acc = ''
    parentheses = 0
    while stream.peek() is not None:
      token = stream.next()
      if str(token) == ',' and parentheses == 0:
        values.append(acc)
        acc = ''
      else:
        if str(token) == '(':
          parentheses += 1
        elif str(token) == ')':
          parentheses -= 1
        
        if type(token) == String:
          acc += '"%s" ' % str(token)
        else:
          acc += str(token) + ' '
    if acc != '':
      values.append(acc)
        
    acc = []
    for val in values:
      stream = TokenStream(cssselect.tokenize(val))
      string_name = str(stream.next())
      string_value = val[len(string_name) + 1:]
      acc.append((string_name, ContentPropertyParser().parse(string_value)))
    return acc
  def _parse_display(self, value):
    if 'none' in value:
      return 'none'
  # http://www.w3.org/TR/css3-content/#moving
  def _parse_move_to(self, value):
    move_dest = value
    return move_dest
      

class ContentPropertyParser(object):
  
  def parse(self, value):
    """ Given a string like "'Exercise ' target-counter(attr(href, url), chapter, decimal) counters(section)"
        return a list of the form:
        (function-name or None, values) """
    vals = []
    stream = TokenStream(cssselect.tokenize(value))
    while stream.peek() is not None:
      t = stream.next()
      if isinstance(t, String):
        vals.append((None, str(t)))
      else:
        name = str(t)
        val = None
        method = '_parse_' + name.replace('-', '_')
        if hasattr(self, method):
          method = getattr(self, method)
          val = method(stream)
        #else:
        #  name = ContentPropertyParser.UNKNOWN
        #  val = [t].concat(self._unknown(stream))
        # If anything fails parsing (ie it's None) then the whole line is unusable
        if val is None:
          return None
        vals.append((name, val))
    return vals

  def _unknown(self, stream):
    # parse up to the matching close paren
    acc = []
    assert str(stream.read()) == '('
    while stream.peek() is not None and str(stream.peek()) != ')':
      if str(stream.peek()) == '(':
        acc.concat(_unknown(stream))
      else:
        acc.append(stream.read())
    return acc
      
  def _optional(self, stream, default=None):
    """ Parses an optional argument (not the 1st argument to a function) by consuming the comma """
    if str(stream.peek()) == ',':
      assert str(stream.next()) == ','
      return str(stream.next())
    return default

  def _parse_target_text(self, stream):
    # These look like: "target-counter(attr(href), counter-name)"
    #               or "target-counter(attr(href, url), counter-name)"
    #               or "target-counter(attr(href, url), counter-name, upper-roman)"
    #
    assert str(stream.next()) == '('             # ignore the outer "("
    assert str(stream.next()) == 'attr'
    (attr, _, _) = self._parse_attr(stream)
    which = 'before'                             # If there's no content(...) then before is default
    content = self._optional(stream, None)
    if content == 'content':                     # If there's a content() then all text is used
      which = 'at'
      assert str(stream.next()) == '('
      if str(stream.peek()) != ')':
        which = str(stream.next())
      assert str(stream.next()) == ')'
    assert str(stream.next()) == ')'             # ignore the outer ")"
    return (attr, which)

  def _parse_target_counter(self, stream):
    # These look like: "target-counter(attr(href), counter-name)"
    #               or "target-counter(attr(href, url), counter-name)"
    #               or "target-counter(attr(href, url), counter-name, upper-roman)"
    #
    assert str(stream.next()) == '('             # ignore the outer "("
    assert str(stream.next()) == 'attr'
    (attr, _, _) = self._parse_attr(stream)
    assert str(stream.next()) == ','             # ignore the comma
    name = str(stream.next())
    numbering = self._optional(stream, 'decimal')
    assert str(stream.next()) == ')'             # ignore the outer ")"
    if name == 'page':
      return None
    return (attr, name, numbering)

  def _parse_counter(self, stream):
    # These look like: "counter(chapter)" or "counter(chapter, upper-roman)"
    assert str(stream.next()) == '('      # ignore the "("
    name = str(stream.next())
    numbering = self._optional(stream, 'decimal')
    assert str(stream.next()) == ')'
    return (name, numbering)

  def _parse_attr(self, stream):
    assert str(stream.next()) == '('
    attr = str(stream.next())
    type_ = self._optional(stream)
    value = self._optional(stream)
    assert str(stream.next()) == ')'
    return (attr, type_, value)

  def _parse_content(self, stream):
    assert str(stream.next()) == '('
    assert str(stream.next()) == ')'
    return ''

  #def _parse_leader(self, stream):
  #  assert str(stream.next()) == '('
  #  token = stream.next()
  #  leader = ' '
  #  if isinstance(token, Token):
  #    if 'dotted' == token:
  #      leader = '. '
  #    elif 'solid' == token:
  #      leader = '_'
  #    elif 'space' == token:
  #      leader = ' '
  #  elif isinstance(token, String):
  #    leader = str(token)
  #  assert str(stream.next()) == ')'
  #  return leader

  def _parse_string(self, stream):
    assert str(stream.next()) == '('
    string_name = stream.next()
    assert str(stream.next()) == ')'
    return string_name

  # http://www.w3.org/TR/css3-content/#moving
  def _parse_pending(self, stream):
    assert str(stream.next()) == '('
    pending_name = stream.next()
    assert str(stream.next()) == ')'
    return pending_name

class ContentEvaluator(object):
  def __init__(self, node_at = {}, state = None, verbose = False):
    self.verbose = verbose
    self.node_at = node_at
    self.state = State()
    if state:
      self.state = state

  def eval_content(self, node, content):
    vals = [] # Accumulator
    for (function, args) in content:
      if function is None:
        vals.append(args)
      else:
        name = function
        method = '_eval_' + name.replace('-', '_')
        if not hasattr(self, method):
          raise UnsupportedError("The CSS content function %r is unsupported" % name)
        method = getattr(self, method)
        val = method(node, args)
        if val is not None: vals.append(val)

    if self.verbose: print >> sys.stderr, "DEBUG: Generated: [%s] from content:[%s]" % (''.join(vals), content)
    ret = ''.join(vals)
    return ret

  def lookup_state(self, node, attr):
    id = node.attrib.get(attr, None)
    if id:
      if id[0] == '#':
        id = id[1:]
      if id in self.node_at:
        return self.node_at[id]
  
  def lookup_text(self, node, attr, which):
    """ Used by target-text(attr(href), content(first-letter)) """
    target_node, state = self.lookup_state(node, attr)
    if state:
      if which == 'before':
        if len(target_node) > 0 and self.is_pseudo(target_node[0]):
          return target_node[0].text # guaranteed it doesn;t have child elements
      elif which == 'after':
        if len(target_node) > 0 and self.is_pseudo(target_node[-1]):
          return target_node[-1].text # guaranteed it doesn;t have child elements
      else:
        text = ''
        if target_node.text: text += target_node.text
        def rec_add(n):
          text = ''
          if n.text: text += n.text
          for s in n: text += rec_add(s)
          if n.tail: text += n.tail
          return text
        for child in target_node:
          if not self.is_pseudo(child):
            text += rec_add(child)
          elif child.tail: text += child.tail
        text = ''.join(text)
        if which == 'first-letter':
          text = text.strip()
          if text: return text[0]
          else: return ''
        else: return text
    
  def lookup_counter(self, node, attr, name):
    # Look up the node (strip of the leading "#" in the href)
    v = 0
    _, state = self.lookup_state(node, attr)
    if state:
      if not state.counters:
        if self.verbose: print >> sys.stderr, "WARNING: Trying to get target-counter of a non-existent id '%s'" % id
      elif name in state.counters:
        v = state.counters[name]
    else:
      if self.verbose: print >> sys.stderr, "WARNING: Element %s does not have attribute '%s' to look up" % (node.tag, attr)
    return v

  def _eval_target_text(self, node, args):
    (attr, which) = args
    n = node
    if self.is_pseudo(node):
      n = node.getparent()
    v = self.lookup_text(n, attr, which)
    return v

  def _eval_target_counter(self, node, args):
    (attr, name, numbering) = args
    n = node
    if self.is_pseudo(node):
      n = node.getparent()
    v = self.lookup_counter(n, attr, name)
    if v and name != 'page':
      # TODO: use numbering to customize how it's rendered (decimal, upper-roman, etc)
      return numbers.toString(v, numbering)

  def _eval_counter(self, node, args):
    # These look like: "counter(chapter)" or "counter(chapter, upper-roman)"
    (name, numbering) = args
    v = 0
    if name in self.state.counters:
      v = self.state.counters[name]
    if v and name != 'page':
      return numbers.toString(v, numbering)

  def _eval_attr(self, node, args):
    (name, type_, value) = args
    n = node
    if self.is_pseudo(node):
      n = node.getparent()
    v = n.attrib.get(name, '')
    return v

  def _eval_content(self, node, args):
    # TODO: Just the text may not be enough to match the spec
    assert args == ''
    return node.text

  def _eval_leader(self, node, args):
    # Ignore the leader function
    pass
  
  def _eval_pending(self, node, args):
    # Ignore for now. there's another pass on all the nodes (once the counters and text are calculated) that will look at this
    pass

  # http://www.w3.org/TR/css3-gcpm/#using-named-strings
  def _eval_string(self, node, args):
    print "Evaluating string and it's: %s" % str(self.state.strings)
    if args in self.state.strings:
      return self.state.strings[args]

  def is_pseudo(self, node):
    return node.attrib.get('class', '') in ('pseudo-before', 'pseudo-after')


def _is_int(s):
  try: 
    int(s)
    return True
  except ValueError:
    return False
