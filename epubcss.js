
/*
What does this file do?
-----------------------

This parses a lesscss (or plain CSS) file and emulates certain rules that aren't supported by some HTML browsers
There are several pieces:

1. Replace lesscss node evaluation for some nodes:

LessCSS offers a great AST for navigating through CSS.
It has a stack (using env.frames that keeps scoped information)
We add an additional variable, _context that stores a jQuery set of elements that are currently matched
So, for a ruleset (selector and rules) the Ruleset.eval maintains a list of elements that currently match the selector.
Rule.eval is modified to understand rules like counter-increment: and content:
Call.eval is modified to emulate functions like target-counter(), attr(), etc

2. Special LessCSS Nodes:

Some of these functions cannot be evaluated yet so their evaluation is deferred until later using DeferredEvaluationNode
(DeferredEvaluationNode.eval() will return itself when it cannot evaluate to something)

The tree.Anonymous node is used to return strings (like the result of counter(chapter) or target-text() )

3. Pseudo Elements ::before and ::after

Pseudo elements are "emulated" because their content: may not be supported by the browser (ie "content: target-text(attr(href))" )
Also, EPUB documents do not support ::before and ::after
Pseudo elements are converted to spans with a special class defined by config.pseudoCls.

4. Loops over the document:

The DOM is looped over 3 times:
- The 1st traversal is done using LessCSS selectors and is used to:
  a. Expand pseudo elements
  b. Remove elements with "display: none"
  c. Sprinkle the special CSS rules on elements (stored in jQuery data())
  d. Find which nodes will need to be looked up later using target-text or target-counter

- The 2nd traversal is over the entire DOM in order and calculates the state of all the counters
- The 3rd traversal is also over the entire DOM in order and replaces the content of elements that have a 'content: ...' rule.
*/

/*
*/

(function() {
  var EpubCSS, SUPPORTED_PSEUDO_SELECTORS, numberingStyle, toRoman,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  toRoman = function(num) {
    var integer, numeral, result, romanNumeralMap, _i, _len, _ref;
    romanNumeralMap = [['M', 1000], ['CM', 900], ['D', 500], ['CD', 400], ['C', 100], ['XC', 90], ['L', 50], ['XL', 40], ['X', 10], ['IX', 9], ['V', 5], ['IV', 4], ['I', 1]];
    if (!((0 < num && num < 5000))) {
      console.error('number out of range (must be 1..4999)');
      return num;
    }
    result = '';
    for (_i = 0, _len = romanNumeralMap.length; _i < _len; _i++) {
      _ref = romanNumeralMap[_i], numeral = _ref[0], integer = _ref[1];
      while (num >= integer) {
        result += numeral;
        num -= integer;
      }
    }
    return result;
  };

  numberingStyle = function(num, style) {
    if (style == null) style = 'decimal';
    switch (style) {
      case 'decimal-leading-zero':
        if (num < 10) {
          return "0" + num;
        } else {
          return num;
        }
        break;
      case 'lower-roman':
        return toRoman(num).toLowerCase();
      case 'upper-roman':
        return toRoman(num);
      case 'lower-latin':
        if (!((1 <= num && num <= 26))) {
          console.error('number out of range (must be 1...26)');
        }
        return String.fromCharCode(num + 96);
      case 'upper-latin':
        if (!((1 <= num && num <= 26))) {
          console.error('number out of range (must be 1...26)');
        }
        return String.fromCharCode(num + 64);
      case 'decimal':
        return num;
      default:
        console.warn("Counter numbering not supported for list type " + style + ". Using decimal.");
        return num;
    }
  };

  SUPPORTED_PSEUDO_SELECTORS = ['before', 'after', 'footnote-call', 'footnote-marker'];

  EpubCSS = (function() {

    function EpubCSS(config) {
      var defaultConfig;
      if (config == null) config = {};
      defaultConfig = {
        debugCls: 'debug-epubcss',
        pseudoCls: "pseudo-element",
        pseudoElement: "<span></span>",
        autogenerateClasses: true,
        bakeInAllStyles: true
      };
      this.config = $.extend(defaultConfig, config);
    }

    /* Returns a string of the new CSS
    */

    EpubCSS.prototype.emulate = function(cssStr, rootNode) {
      var DeferredEvaluationNode, complexRules, config, evaluators, expressionsToString, interestingNodes, newCSSFile, p, pendingNodes, preorderTraverse, storeIt, tree, _oldCallPrototype;
      if (rootNode == null) rootNode = $('html');
      config = this.config;
      /*
      */
      tree = less.tree;
      less.tree.Ruleset.prototype.eval = function(env) {
        var $context, $found, $newContext, css, css2, endTime, frame, i, parentCSS, pseudoMatch, pseudos, rule, ruleset, selector, selectors, skips, startTime, took, _i, _j, _len, _len2, _ref, _ref2, _ref3;
        skips = 0;
        _ref = env.frames;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          frame = _ref[_i];
          if (skips > 0) {
            skips -= 1;
            continue;
          }
          if (less.tree.mixin.Definition.prototype.isPrototypeOf(frame)) {
            skips = frame.frames.length + 1;
          } else if (frame._context && !$context) {
            $context = frame._context;
            parentCSS = frame._parentCSS;
          }
        }
        if (!$context) {
          $context = rootNode;
          parentCSS = '';
        }
        $newContext = $('NOT-VALID-TAG');
        if (this.selectors && this.selectors.length) {
          css = '';
          _ref2 = this.selectors;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            selector = _ref2[_j];
            css = selector.toCSS();
            pseudoMatch = css.match(/::?([\w\-]+) *$/) || [];
            css2 = css.replace(/::?[\w\-]+ *$/, '');
            startTime = new Date().getTime();
            if (css2[0] === ' ') {
              $found = $context.find(css2.trim());
            } else {
              $found = $context.filter(css2.trim());
            }
            $found = $found.filter(":not(." + config.pseudoCls + ")");
            if (pseudoMatch.length >= 0 && (_ref3 = pseudoMatch[1], __indexOf.call(SUPPORTED_PSEUDO_SELECTORS, _ref3) >= 0)) {
              pseudos = [];
              $found.each(function() {
                var $el, pseudo;
                $el = $(this);
                pseudo = $el.children("." + config.pseudoCls + "." + pseudoMatch[1]);
                if (pseudo.length === 0) {
                  pseudo = $(config.pseudoElement).addClass(config.pseudoCls).addClass(pseudoMatch[1]);
                  if (pseudoMatch[1] === 'before') {
                    pseudo.prependTo($el);
                  } else {
                    pseudo.appendTo($el);
                  }
                }
                return pseudos.push(pseudo);
              });
              $found = pseudos;
            }
            $newContext = $newContext.add($found);
            endTime = new Date().getTime();
            took = endTime - startTime;
            if ($found.length || took > 10000) {
              console.log("Selector [" + parentCSS + "] / [" + css + "] (" + (took / 1000) + "s)  Matches: " + $found.length);
            }
          }
          this._context = $newContext;
          this._parentCSS = "" + parentCSS + " | " + css + " (" + $newContext.length + ")";
        } else {
          this._context = $context;
          this._parentCSS = parentCSS;
        }
        /* Run the original eval
        */
        selectors = this.selectors && this.selectors.map(function(s) {
          return s.eval(env);
        });
        ruleset = new tree.Ruleset(selectors, this.rules.slice(0), this.strictImports);
        /* Start: New Code
        */
        ruleset._context = this._context;
        ruleset._parentCSS = this._parentCSS;
        /* End: New Code
        */
        ruleset.root = rootNode;
        ruleset.allowImports = this.allowImports;
        env.frames.unshift(ruleset);
        if (ruleset.root || ruleset.allowImports || !ruleset.strictImports) {
          i = 0;
          while (i < ruleset.rules.length) {
            if (ruleset.rules[i] instanceof tree.Import) {
              Array.prototype.splice.apply(ruleset.rules, [i, 1].concat(ruleset.rules[i].eval(env)));
            }
            i++;
          }
        }
        i = 0;
        while (i < ruleset.rules.length) {
          if (ruleset.rules[i] instanceof tree.mixin.Definition) {
            ruleset.rules[i].frames = env.frames.slice(0);
          }
          i++;
        }
        i = 0;
        while (i < ruleset.rules.length) {
          if (ruleset.rules[i] instanceof tree.mixin.Call) {
            Array.prototype.splice.apply(ruleset.rules, [i, 1].concat(ruleset.rules[i].eval(env)));
          }
          i++;
        }
        i = 0;
        rule = void 0;
        while (i < ruleset.rules.length) {
          rule = ruleset.rules[i];
          if (!(rule instanceof tree.mixin.Definition)) {
            ruleset.rules[i] = (rule.eval ? rule.eval(env) : rule);
          }
          i++;
        }
        env.frames.shift();
        return ruleset;
      };
      interestingNodes = {};
      pendingNodes = {};
      expressionsToString = function(env, args) {
        var i, ret, _i, _len;
        if (less.tree.Expression.prototype.isPrototypeOf(args)) args = args.value;
        if (args instanceof Array) {
          ret = '';
          for (_i = 0, _len = args.length; _i < _len; _i++) {
            i = args[_i];
            if (!i) console.error("BUG: i is not defined!");
            ret = ret + expressionsToString(env, i);
          }
          return ret;
        } else {
          return args.eval(env).value;
        }
      };
      DeferredEvaluationNode = (function() {

        function DeferredEvaluationNode(name, f) {
          this.name = name;
          this.f = f;
        }

        DeferredEvaluationNode.prototype.eval = function(env) {
          if (env.doNotDefer) {
            return this.f(env);
          } else {
            return this;
          }
        };

        return DeferredEvaluationNode;

      })();
      evaluators = {
        'attr': function(env, args) {
          return new DeferredEvaluationNode('attr', function(env) {
            var $context, href, id;
            $context = env.doNotDefer;
            if ($context.hasClass(config.pseudoCls)) $context = $context.parent();
            href = args[0].eval(env).value;
            id = $context.attr(href);
            if (!id) {
              console.warn("CSS Bug: Could not find attribute '" + href + "' on ", $context);
            }
            return new tree.Anonymous(id || "NO_ID_FOUND_WOOT");
          }).eval(env);
        },
        'target-counter': function(env, args) {
          var $node, id, newEnv, node, _i, _len, _ref;
          if (args.length < 2) {
            console.error('target-counter requires at least 2 arguments');
          }
          _ref = env.frames[0]._context;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            $node = $(node);
            newEnv = {
              doNotDefer: $node
            };
            id = expressionsToString(newEnv, args[0]);
            interestingNodes[id] = false;
          }
          return new DeferredEvaluationNode('target-counter', function(env) {
            var counterName, counters, style, val;
            id = expressionsToString(env, args[0]);
            counterName = args[1].eval(env).value;
            style = 'decimal';
            if (args.length > 2) style = args[2].eval(env).value;
            if (id in interestingNodes && interestingNodes[id]) {
              counters = interestingNodes[id].data('counters') || {};
              val = counters[counterName] || 0;
              return new tree.Anonymous(numberingStyle(val, style));
            }
          }).eval(env);
        },
        'target-text': function(env, args) {
          var $node, id, newEnv, node, _i, _len, _ref;
          _ref = env.frames[0]._context;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            $node = $(node);
            newEnv = {
              doNotDefer: $node,
              frames: [
                {
                  _context: $node
                }
              ]
            };
            id = expressionsToString(newEnv, args[0]);
            interestingNodes[id] = false;
          }
          return new DeferredEvaluationNode('target-text', function(env) {
            var newContent;
            id = expressionsToString(env, args[0]);
            if (interestingNodes[id]) {
              $node = interestingNodes[id];
              newEnv = {
                doNotDefer: $node
              };
              newContent = args[1].eval(newEnv);
              return new tree.Anonymous(newContent);
            }
          }).eval(env);
        },
        'counter': function(env, args) {
          return new DeferredEvaluationNode('counter', function(env) {
            var $context, name, style, val;
            $context = env.doNotDefer;
            name = args[0].eval(env).value;
            style = 'decimal';
            if (args.length > 1) style = args[1].eval(env).value;
            val = $context.data('counters')[name];
            return new tree.Anonymous(numberingStyle(val || 0, style));
          }).eval(env);
        },
        'string': function(env, args) {
          return new DeferredEvaluationNode('string', function(env) {
            var $context, name, val;
            $context = env.doNotDefer;
            name = args[0].eval(env).value;
            val = $context.data('strings')[name];
            return new tree.Anonymous(val || '');
          }).eval(env);
        },
        'content': function(env, args) {
          return new DeferredEvaluationNode('content', function(env) {
            var $node, contentType, ret;
            $node = env.doNotDefer;
            contentType = (args[0] || {
              eval: function() {
                return {
                  value: 'NO_ARGUMENT'
                };
              }
            }).eval(env).value;
            ret = null;
            switch (contentType) {
              case 'NO_ARGUMENT':
                ret = $node.contents().filter(function() {
                  return this.nodeType !== 1 || !$(this).hasClass(config.pseudoCls);
                }).text();
                break;
              case 'before':
                ret = $node.children("." + config.pseudoCls + ".before").text();
                break;
              case 'after':
                ret = $node.children("." + config.pseudoCls + ".after").text();
                break;
              case 'first-letter':
                ret = $node.children(":not(." + config.pseudoCls + ")").text().substring(0, 1);
                break;
              default:
                console.warn("content() was called with an invalid argument: '" + contentType + "'. Assuming no argument was passed in.");
                ret = $node.children(":not(." + config.pseudoCls + ")").text();
            }
            return new tree.Anonymous(ret);
          }).eval(env);
        },
        'leader': function(env, args) {
          return new tree.Anonymous(args[0]);
        },
        'pending': function(env, args) {
          return new DeferredEvaluationNode('pending', function(env) {
            var $context, $node, id, _i, _len, _ref;
            $context = env.doNotDefer;
            id = expressionsToString(env, args[0]);
            if (pendingNodes[id]) {
              _ref = pendingNodes[id];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                $node = _ref[_i];
                $context.append($node);
              }
              pendingNodes[id] = [];
              return new tree.Anonymous('THIS_SHOULD_NEVER_DISPLAY');
            }
          }).eval(env);
        }
      };
      storeIt = function(cmd) {
        return function($el, value) {
          return $el.data(cmd, value);
        };
      };
      complexRules = {
        'counter-reset': storeIt('counter-reset'),
        'counter-increment': storeIt('counter-increment'),
        'content': storeIt('content'),
        'move-to': storeIt('move-to'),
        'display': function($el, value) {
          if ('none' === value.eval().value) {
            return $el.remove();
          } else {

          }
        },
        'string-set': storeIt('string-set')
      };
      _oldCallPrototype = less.tree.Call.prototype.eval;
      less.tree.Call.prototype.eval = function(env) {
        var args;
        if (this.name in evaluators) {
          args = this.args.map(function(a) {
            return a.eval(env);
          });
          return evaluators[this.name](env, args);
        } else {
          return _oldCallPrototype.apply(this, [env]);
        }
      };
      less.tree.Rule.prototype.eval = function(env) {
        var $el, el, style, value, _i, _len, _ref;
        _ref = env.frames[0]._context;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          el = _ref[_i];
          $el = $(el);
          value = this.value.eval(env);
          if (this.name in complexRules) {
            complexRules[this.name]($el, this.value.eval(env));
          } else {
            if (!$el.data('style')) $el.data('style', {});
            style = $el.data('style');
            style[this.name] = value.toCSS(env);
          }
        }
        return new tree.Rule(this.name, this.value.eval(env), this.important, this.index, this.inline);
      };
      preorderTraverse = function($nodes, func) {
        return $nodes.each(function() {
          var $node;
          $node = $(this);
          func($node);
          return preorderTraverse($node.children(), func);
        });
      };
      newCSSFile = null;
      p = less.Parser();
      p.parse(cssStr, function(err, lessNode) {
        var ary, counterState, cssClassNum, cssClassPrefix, cssClasses, cssHashes, env, id, name, parseCounters, propName, propVal, props, recHasProperty, setContent, stringState, vals;
        env = {
          frames: []
        };
        lessNode.eval(env);
        for (id in interestingNodes) {
          interestingNodes[id] = $(id);
        }
        parseCounters = function(expr, defaultNum) {
          var counters, exp, i, name, tokens, val, _i, _len, _ref;
          counters = {};
          if (less.tree.Anonymous.prototype.isPrototypeOf(expr)) {
            tokens = expr.value.split(' ');
          } else if (less.tree.Expression.prototype.isPrototypeOf(expr)) {
            tokens = [];
            _ref = expr.value;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              exp = _ref[_i];
              tokens.push(exp.value);
            }
          } else {
            tokens = [expr.value];
          }
          i = 0;
          while (i < tokens.length) {
            name = tokens[i];
            if (i === tokens.length - 1) {
              val = defaultNum;
            } else if (isNaN(parseInt(tokens[i + 1]))) {
              val = defaultNum;
            } else {
              val = parseInt(tokens[i + 1]);
              i++;
            }
            counters[name] = val;
            i++;
          }
          return counters;
        };
        console.log("----- Looping over all nodes to squirrel away counters to be looked up later");
        counterState = {};
        stringState = {};
        cssHashes = {};
        cssClasses = {};
        cssClassPrefix = 'autogen-';
        cssClassNum = 0;
        preorderTraverse(rootNode, function($node) {
          var counter, counters, exp, hash, isInteresting, name, propName, propVal, stringsExp, style, val, vals, _i, _len, _ref;
          if ($node.data('counter-reset')) {
            counters = parseCounters($node.data('counter-reset'), 0);
            for (counter in counters) {
              val = counters[counter];
              counterState[counter] = val;
            }
          }
          if ($node.data('counter-increment')) {
            counters = parseCounters($node.data('counter-increment'), 1);
            for (counter in counters) {
              val = counters[counter];
              counterState[counter] = (counterState[counter] || 0) + val;
            }
          }
          isInteresting = '#' + $node.attr('id') in interestingNodes;
          if (isInteresting || $node.data('content') || $node.data('string-set')) {
            $node.data('counters', $.extend({}, counterState));
            $node.data('strings', $.extend({}, stringState));
          }
          if (isInteresting) interestingNodes['#' + $node.attr('id')] = $node;
          if ($node.data('string-set')) {
            stringsExp = $node.data('string-set');
            env = {
              doNotDefer: $node,
              frames: [
                {
                  _context: $node
                }
              ]
            };
            if (stringsExp instanceof tree.Value) {
              _ref = stringsExp.value;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                exp = _ref[_i];
                name = expressionsToString(env, exp.value[0]);
                val = expressionsToString(env, new tree.Expression(exp.value.slice(1)));
                stringState[name] = val;
              }
            } else {
              name = expressionsToString(env, stringsExp.value[0]);
              val = expressionsToString(env, new tree.Expression(stringsExp.value.slice(1)));
              stringState[name] = val;
            }
          }
          if (config.bakeInAllStyles && $node.data('style')) {
            style = $node.data('style');
            $node.data('style', null);
            if (config.autogenerateClasses) {
              hash = JSON.stringify(style);
              if (!(hash in cssHashes)) {
                name = cssClassPrefix + (cssClassNum++);
                cssHashes[hash] = name;
                cssClasses[name] = style;
              } else {
                name = cssHashes[hash];
              }
              return $node.addClass(name);
            } else {
              vals = [];
              for (propName in style) {
                propVal = style[propName];
                vals.push("" + propName + ": " + propVal + ";");
              }
              return $node.attr('style', vals.join(' '));
            }
          }
        });
        console.log("----- Looping over all nodes and updating 'content:' without a target-*");
        recHasProperty = function(expr, propName) {
          var hasProperty, val, _i, _len, _ref;
          hasProperty = false;
          if (DeferredEvaluationNode.prototype.isPrototypeOf(expr)) {
            hasProperty = expr.name === propName;
          } else if (less.tree.Expression.prototype.isPrototypeOf(expr)) {
            _ref = expr.value;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              val = _ref[_i];
              hasProperty = hasProperty || recHasProperty(val, propName);
            }
          } else if (expr.value != null) {
            hasProperty = recHasProperty(expr.value, propName);
          }
          return hasProperty;
        };
        setContent = function(boolTarget) {
          return function($node) {
            var expr, hasPending, hasTarget, newContent, pseudoBefore;
            if ($node.data('content')) {
              $node.addClass(config.debugCls);
              env = {
                doNotDefer: $node,
                frames: [
                  {
                    _context: $node
                  }
                ]
              };
              expr = $node.data('content');
              hasTarget = recHasProperty(expr, 'target-text');
              if (boolTarget ^ hasTarget) return;
              hasPending = recHasProperty(expr, 'pending');
              if (hasPending) {
                expressionsToString(env, expr);
              } else {
                newContent = expressionsToString(env, expr);
                pseudoBefore = $node.children("." + config.pseudoCls + ".before");
                $node.contents().filter(function() {
                  return this.nodeType !== 1 || !$(this).hasClass(config.pseudoCls);
                }).remove();
                if (pseudoBefore.length) {
                  pseudoBefore.after(newContent);
                } else {
                  $node.prepend(newContent);
                }
              }
            }
            if ($node.data('move-to')) {
              id = expressionsToString(env, $node.data('move-to'));
              pendingNodes[id] = pendingNodes[id] || [];
              return pendingNodes[id].push($node);
            }
          };
        };
        preorderTraverse(rootNode, setContent(false));
        console.log("----- Looping over all nodes and updating 'content:' with a target-*");
        preorderTraverse(rootNode, setContent(true));
        console.log('Done processing!');
        ary = [];
        for (name in cssClasses) {
          props = cssClasses[name];
          vals = [];
          for (propName in props) {
            propVal = props[propName];
            vals.push("" + propName + ": " + propVal + ";");
          }
          ary.push("." + name + " { " + (vals.join('')) + " }");
        }
        return newCSSFile = ary.join('\n');
      });
      return newCSSFile;
    };

    return EpubCSS;

  })();

  if (typeof module !== "undefined" && module !== null) {
    module.exports = EpubCSS;
  } else if (typeof window !== "undefined" && window !== null) {
    window.EpubCSS = EpubCSS;
  }

}).call(this);
