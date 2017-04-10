"""
Lisp in Python
"""

from __future__ import print_function

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

def main():
    """Main"""
    program = '(begin (define r 10) (* pi (* r r)))'
    parsed = parse(program)
    print('Parsed: {}'.format(parsed))

if __name__ == '__main__':
    main()
