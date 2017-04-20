"""
Lisp in Python
"""

from __future__ import print_function
from __future__ import division
import math
import operator as op
import re
import sys
import StringIO

SYMBOL = str
LIST = list
NUMBER = (int, float)

def tokenize(chars):
    """Convert lisp expression into a set of tokens."""
    return chars.replace('(', ' ( ').replace(')', ' ) ').split()

def read_tokens(tokens):
    """Read an expression from a sequence of tokens."""
    if len(tokens) == 0:
        raise SyntaxError('Unexpected EOF while reading.')
    token = tokens.pop(0)
    if token == '(':
        s_expr = []
        while tokens[0] != ')':
            s_expr.append(read_tokens(tokens))
        tokens.pop(0)
        return s_expr
    if token == ')':
        raise SyntaxError("Enexpected ')'")
    else:
        return atom(token)

def parse(inport):
    "Parse a program: read and expand/error-check it."
    # Backwards compatibility: given a str, convert it to an InPort
    if isinstance(inport, str):
        inport = InPort(StringIO.StringIO(inport))
    # return expand(read(inport), toplevel=True)
    return read(inport)

def standard_env():
    """An environment with some Scheme standard procedures."""
    env = Env()
    env.update(vars(math)) # sin, cos, sqrt, etc.
    env.update({
        '+' : op.add,
        '-' : op.sub,
        '*' : op.mul,
        '/' : op.div,
        '>' : op.gt,
        '<' : op.lt,
        '>=': op.ge,
        '<=': op.le,
        '=' : op.eq,
        'abs'      : abs,
        'append'   : op.add,
        'apply'    : apply,
        'begin'    : lambda *x: x[-1],
        'car'      : lambda x: x[0],
        'cdr'      : lambda x: x[1:],
        'cons'     : lambda x, y: [x] + y,
        'eq?'      : op.is_,
        'equal?'   : op.eq,
        'length'   : len,
        'list'     : lambda *x: list(x),
        'list?'    : lambda x: isinstance(x, LIST),
        'map'      : map,
        'max'      : max,
        'min'      : min,
        'not'      : op.not_,
        'null?'    : lambda x: x == [],
        'number?'  : lambda x: isinstance(x, NUMBER),
        'procedure': callable,
        'round'    : round,
        'symbol?'  : lambda x: isinstance(x, SYMBOL)
    })
    return env

class Symbol(str):
    """Represent a symbol"""
    pass

EOF = Symbol('#<eof-object>') # Note: uninterned; can't be read

SYMBOL_TABLE = {}

def _add_symbol(symbol, symbol_table):
    "Find or create unique Symbol entry for a str symbol in symbol table."
    if symbol not in symbol_table:
        symbol_table[symbol] = Symbol(symbol)
    return symbol_table[symbol]

# _QUOTE = Symbol("quote")
# _IF = Symbol("if")
# _SET = Symbol("set!")
# _DEFINE = Symbol("define")
# _LAMBDA = Symbol("lambda")
# _BEGIN = Symbol("begin")
# _DEFINEMACRO = Symbol("define-macro")
# _QUASIQUOTE = Symbol("quasiquote")
# _UNQUOTE = Symbol("unquote")
# _UNQUOTESPLICING = Symbol("unquote-splicing")

_add_symbol("quote", SYMBOL_TABLE)
_add_symbol("if", SYMBOL_TABLE)
_add_symbol("set!", SYMBOL_TABLE)
_add_symbol("define", SYMBOL_TABLE)
_add_symbol("lambda", SYMBOL_TABLE)
_add_symbol("begin", SYMBOL_TABLE)
_add_symbol("define-macro", SYMBOL_TABLE)
_add_symbol("quasiquote", SYMBOL_TABLE)
_add_symbol("unquote", SYMBOL_TABLE)
_add_symbol("unquote-splicing", SYMBOL_TABLE)

QUOTES = {"'" :SYMBOL_TABLE["quote"],
          "`" :SYMBOL_TABLE["quasiquote"],
          "," :SYMBOL_TABLE["unquote"],
          ",@":SYMBOL_TABLE["unquote-splicing"]}

class InPort(object):
    "An input port. Retains a line of chars."
    tokenizer = r'''\s*(,@|[('`,)]|"(?:[\\].|[^\\"])*"|;.*|[^\s('"`,;)]*)(.*)'''
    def __init__(self, infile):
        self.file = infile
        self.line = ''
    def next_token(self):
        "Return the next token, reading new text into line buffer if needed."
        while True:
            if self.line == '':
                self.line = self.file.readline()
            if self.line == '':
                return EOF
            token, self.line = re.match(InPort.tokenizer, self.line).groups()
            if token != '' and not token.startswith(';'):
                return token

def readchar(inport):
    "Read the next character from an input port."
    if inport.line != '':
        character = inport.line[0]
        inport.line = inport.line[1:]
        return character
    else:
        return inport.file.read(1) or EOF

def read(inport):
    "Read a symbolic expression from an input port."
    def read_ahead(token):
        """ read ahead """
        if token == '(':
            sexprs = []
            while True:
                token = inport.next_token()
                if token == ')':
                    return sexprs
                else:
                    sexprs.append(read_ahead(token))
        elif token == ')':
            raise SyntaxError('unexpected )')
        elif token in QUOTES:
            return [QUOTES[token], read(inport)]
        elif token is EOF:
            raise SyntaxError('unexpected EOF in list')
        else:
            return atom(token)
    # body of read:
    next_token = inport.next_token()
    return EOF if next_token is EOF else read_ahead(next_token)

def atom(token):
    """Numbers become numbers; #t and #f are booleans; "..." string; otherwise Symbol."""
    if token == '#t':
        return True
    elif token == '#f':
        return False
    elif token[0] == '"':
        return token[1:-1].decode('string_escape')
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            try:
                return complex(token.replace('i', 'j', 1))
            except ValueError:
                return Symbol(token)

# isa = isinstance

def to_string(obj):
    "Convert a Python object back into a Lisp-readable string."
    if obj is True:
        return "#t"
    elif obj is False:
        return "#f"
    elif isinstance(obj, Symbol):
        return obj
    elif isinstance(obj, str):
        return '"%s"' % obj.encode('string_escape').replace('"', r'\"')
    elif isinstance(obj, list):
        return '('+' '.join(map(to_string, obj)) +')'
    elif isinstance(obj, complex):
        return str(obj).replace('j', 'i')
    else:
        return str(obj)

def load(filename):
    "Eval every expression from a file."
    repl(None, InPort(open(filename)), None)

def repl(prompt='awly> ', inport=InPort(sys.stdin), out=sys.stdout):
    "A prompt-read-eval-print loop."
    sys.stderr.write("Awly version 2.0\n")
    while True:
        try:
            if prompt:
                sys.stderr.write(prompt)
            sexpr = parse(inport)
            # print("{}".format(sexpr))
            if sexpr is EOF:
                return
            elif sexpr == "quit" or sexpr == "exit":
                break
            val = eval_sexpr(sexpr)
            if val is not None and out:
                print(to_string(val))
        except Exception as exception:
            print('%s: %s' % (type(exception).__name__, exception))

class Procedure(object):
    """A user defined Scheme procedure."""
    def __init__(self, params, body, env):
        object.__init__(self)
        self.params, self.body, self.env = params, body, env
    def __call__(self, *args):
        return eval_sexpr(self.body, Env(self.params, args, self.env))

class Env(dict):
    """An enviromemt: a dict of {'var': val} pairs, with an outer Env."""
    def __init__(self, params=(), args=(), outer=None):
        dict.__init__(self)
        self.update(zip(params, args))
        self.outer = outer
    def find(self, var):
        """Find the innermost Env where var appears."""
        return self if (var in self) else self.outer.find(var)

GLOBAL_ENV = standard_env()

def eval_sexpr(sexpr, env=GLOBAL_ENV):
    """Evalaute an expression in the environment."""
    # variable references
    if isinstance(sexpr, SYMBOL):
        return env.find(sexpr)[sexpr]
    # constant literal
    elif not isinstance(sexpr, LIST):
        return sexpr
    # quotation
    elif sexpr[0] == 'quote':
        (_, exp) = sexpr
        return exp
    # conditional
    elif sexpr[0] == 'if':
        (_, test, conseq, alt) = sexpr
        exp = (conseq if eval_sexpr(test, env) else alt)
        return eval_sexpr(exp, env)
    # definition
    elif sexpr[0] == 'define':
        (_, var, exp) = sexpr
        env[var] = eval_sexpr(exp, env)
    # assignment
    elif sexpr[0] == 'set!':
        (_, var, exp) = sexpr
        env.find(var)[var] = eval_sexpr(exp, env)
    # procedure
    elif sexpr[0] == 'lambda':
        (_, params, body) = sexpr
        return Procedure(params, body, env)
    # procedure call
    else:
        proc = eval_sexpr(sexpr[0], env)
        args = [eval_sexpr(arg, env) for arg in sexpr[1:]]
        return proc(*args)

def schemestr(exp):
    """Convert a python object into a scheme readable object."""
    if isinstance(exp, LIST):
        return '(' + ' '.join(map(schemestr, exp)) + ')'
    else:
        return str(exp)

def main():
    """Main"""
    repl()

if __name__ == '__main__':
    main()
