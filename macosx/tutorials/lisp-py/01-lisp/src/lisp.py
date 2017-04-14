"""
Lisp in Python
"""

from __future__ import print_function
import math
import operator as op

SYMBOL = str
LIST = list
NUMBER = (int, float)
ENV = dict

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

def atom(token):
    """Numbers become numbers; every other token is a symbol."""
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            return SYMBOL(token)

def parse(program):
    """Read a lisp expression from a string."""
    return read_tokens(tokenize(program))

def standard_env():
    """An environment with some Scheme standard procedures."""
    env = ENV()
    env.update(vars(math)) # sin, cos, sqrt, etc.
    env.update({
        '+' : op.add,
        '-' : op.sub,
        '*' : op.mul,
        '/' : op.div,
        '>' : op.gt,
        '<' : op.lt,
        '<=': op.ge,
        '=>': op.le,
        '=' : op.eq,
        'abs'      : abs,
        'append'   : op.add,
        'apply'    : apply,
        'begin'    : lambda *x: x[-1],
        'car'      : lambda x: x[0],
        'cdr'      : lambda x: x[1],
        'cons'     : lambda x, y: [x] + y,
        'eq?'      : op.is_,
        'equal?'   : op.eq,
        'length'   : len,
        'list'     : lambda *x: list(x),
        'list?'    : lambda x: isinstance(x.list),
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

GLOBAL_ENV = standard_env()

def eval_sexpr(sexpr, env=GLOBAL_ENV):
    """Evalaute an expression in the environment."""
    # variable references
    if isinstance(sexpr, SYMBOL):
        return env[sexpr]
    # constant literal
    elif not isinstance(sexpr, LIST):
        return sexpr
    # conditional
    elif sexpr[0] == 'if':
        (_, test, conseq, alt) = sexpr
        exp = (conseq if eval_sexpr(test, env) else alt)
        return eval_sexpr(exp, env)
    # definition
    elif sexpr[0] == 'define':
        (_, var, exp) = sexpr
        env[var] = eval_sexpr(exp, env)
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

def repl(prompt='awly> '):
    """A REPL loop"""
    while True:
        val = eval_sexpr(parse(raw_input(prompt)))
        if val is not None:
            print(schemestr(val))

def main():
    """Main"""
    repl()

if __name__ == '__main__':
    main()
