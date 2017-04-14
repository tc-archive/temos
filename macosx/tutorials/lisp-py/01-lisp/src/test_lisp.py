"""
lisp.py Units Tests
"""

import unittest

from lisp import parse, eval_sexpr

class TestLisp(unittest.TestCase):
    """Tests"""
    def test_parse(self):
        """Test 'parse' function happy path"""
        actual = parse('(begin (define r 10) (* pi (* r r)))')
        expected = ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]]
        self.assertEqual(actual, expected)

    def test_eval_expr(self):
        """Test 'eval_sexpr' function happy path"""
        eval_sexpr(parse("(define r 10)"))
        actual = eval_sexpr(parse("(* pi (* r r))"))
        expected = 314.1592653589793
        self.assertEqual(actual, expected)
