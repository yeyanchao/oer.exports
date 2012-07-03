# Taken from https://github.com/lxml/lxml/blob/master/src/lxml/cssselect.py
from lxml.cssselect import String, Symbol, Token, TokenStream
import re

############################################################
## Tokenizing
############################################################

_match_whitespace = re.compile(r'\s+', re.UNICODE).match

_replace_comments = re.compile(r'/\*.*?\*/', re.DOTALL).sub

_match_count_number = re.compile(r'[+-]?\d*n(?:[+-]\d+)?').match

def tokenize(s):
    pos = 0
    s = _replace_comments('', s)
    while 1:
        match = _match_whitespace(s, pos=pos)
        if match:
            preceding_whitespace_pos = pos
            pos = match.end()
        else:
            preceding_whitespace_pos = 0
        if pos >= len(s):
            return
        match = _match_count_number(s, pos=pos)
        if match and match.group() != 'n':
            sym = s[pos:match.end()]
            yield Symbol(sym, pos)
            pos = match.end()
            continue
        c = s[pos]
        c2 = s[pos:pos+2]
        if c2 in ('~=', '|=', '^=', '$=', '*=', '::', '!='):
            if c2 == '::' and preceding_whitespace_pos > 0:
                yield Token(' ', preceding_whitespace_pos)
            yield Token(c2, pos)
            pos += 2
            continue
        if c in '>+~,.*=[]()|:#':
            if c in ':.#[' and preceding_whitespace_pos > 0:
                yield Token(' ', preceding_whitespace_pos)
            yield Token(c, pos)
            pos += 1
            continue
        if c == '"' or c == "'":
            # Quoted string
            old_pos = pos
            sym, pos = tokenize_escaped_string(s, pos)
            yield String(sym, old_pos)
            continue
        old_pos = pos
        sym, pos = tokenize_symbol(s, pos)
        yield Symbol(sym, old_pos)
        continue

split_at_string_escapes = re.compile(r'(\\(?:%s))'
                                     % '|'.join(['[A-Fa-f0-9]{1,6}(?:\r\n|\s)?',
                                                 '[^A-Fa-f0-9]'])).split

def unescape_string_literal(literal):
    substrings = []
    for substring in split_at_string_escapes(literal):
        if not substring:
            continue
        elif '\\' in substring:
            if substring[0] == '\\' and len(substring) > 1:
                substring = substring[1:]
                if substring[0] in '0123456789ABCDEFabcdef':
                    # int() correctly ignores the potentially trailing whitespace
                    substring = _unichr(int(substring, 16))
            else:
                raise SelectorSyntaxError(
                    "Invalid escape sequence %r in string %r"
                    % (substring.split('\\')[1], literal))
        substrings.append(substring)
    return ''.join(substrings)

def tokenize_escaped_string(s, pos):
    quote = s[pos]
    assert quote in ('"', "'")
    pos = pos+1
    start = pos
    while 1:
        next = s.find(quote, pos)
        if next == -1:
            raise SelectorSyntaxError(
                "Expected closing %s for string in: %r"
                % (quote, s[start:]))
        result = s[start:next]
        if result.endswith('\\'):
            # next quote character is escaped
            pos = next+1
            continue
        if '\\' in result:
            result = unescape_string_literal(result)
        return result, next+1
    
_illegal_symbol = re.compile(r'[^\w\\-]', re.UNICODE)

def tokenize_symbol(s, pos):
    start = pos
    match = _illegal_symbol.search(s, pos=pos)
    if not match:
        # Goes to end of s
        return s[start:], len(s)
    if match.start() == pos:
        assert 0, (
            "Unexpected symbol: %r at %s" % (s[pos], pos))
    if not match:
        result = s[start:]
        pos = len(s)
    else:
        result = s[start:match.start()]
        pos = match.start()
    try:
        result = result.encode('ASCII', 'backslashreplace').decode('unicode_escape')
    except UnicodeDecodeError:
        import sys
        e = sys.exc_info()[1]
        raise SelectorSyntaxError(
            "Bad symbol %r: %s" % (result, e))
    return result, pos
