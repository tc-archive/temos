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
        """Test 'eval_sexpr' circle circumference 1"""
        eval_sexpr(parse("(define r 10)"))
        actual = eval_sexpr(parse("(* pi (* r r))"))
        expected = 314.1592653589793
        self.assertEqual(actual, expected)

    def test_eval_expr_2(self):
        """Test 'eval_sexpr' circle circumference 2"""
        sexpr1 = "(define circle-area (lambda (r) (* pi (* r r))))"
        sexpr2 = "(circle-area 3)"
        _actual1 = eval_sexpr(parse(sexpr1))
        actual2 = eval_sexpr(parse(sexpr2))
        expected = 28.274333882308138
        self.assertEqual(actual2, expected)

    def test_eval_expr_3(self):
        """Test 'eval_sexpr' circle cricumference 3"""
        sexpr1 = "(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))"
        sexpr2 = "(circle-area (fact 10))"
        _actual1 = eval_sexpr(parse(sexpr1))
        actual2 = eval_sexpr(parse(sexpr2))
        expected = 41369087205782.695
        self.assertEqual(actual2, expected)

    def test_eval_expr_4(self):
        """Test 'eval_sexpr' account structure"""
        sexpr1 = "(define make-account (lambda (balance) (lambda (amt) (begin (set! balance (+ balance amt)) balance))))"
        sexpr2 = "(define account1 (make-account 100.00))"
        sexpr3 = "(account1 -20.00)"
        _actual1 = eval_sexpr(parse(sexpr1))
        _actual2 = eval_sexpr(parse(sexpr2))
        actual3 = eval_sexpr(parse(sexpr3))
        expected = 80.0
        self.assertEqual(actual3, expected)

    def test_eval_expr_5(self):
        """Test 'eval_sexpr' factorial"""
        sexpr1 = "(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))"
        sexpr2 = "(fact 10)"
        _actual1 = eval_sexpr(parse(sexpr1))
        actual2 = eval_sexpr(parse(sexpr2))
        expected = 3628800
        self.assertEqual(actual2, expected)

    def test_eval_expr_6(self):
        """Test 'eval_sexpr' count"""
        sexpr1 = "(define first car)"
        sexpr2 = "(define rest cdr)"
        sexpr3 = "(define count (lambda (item L) (if L (+ (equal? item (first L)) (count item (rest L))) 0)))"
        sexpr4 = "(count 0 (list 0 1 2 3 0 0))"
        sexpr5 = "(count (quote the) (quote (the more the merrier the bigger the better)))"
        _actual1 = eval_sexpr(parse(sexpr1))
        _actual2 = eval_sexpr(parse(sexpr2))
        _actual3 = eval_sexpr(parse(sexpr3))
        actual4 = eval_sexpr(parse(sexpr4))
        actual5 = eval_sexpr(parse(sexpr5))
        expected_1 = 3
        self.assertEqual(actual4, expected_1)
        expected_2 = 4
        self.assertEqual(actual5, expected_2)

    def test_eval_expr_7(self):
        """Test 'eval_sexpr' repeat"""
        sexpr1 = "(define twice (lambda (x) (* 2 x)))"
        sexpr2 = "(define repeat (lambda (f) (lambda (x) (f (f x)))))"
        sexpr3 = "(twice 5)"
        sexpr4 = "((repeat twice) 10)"
        sexpr5 = "((repeat (repeat twice)) 10)"
        sexpr6 = "((repeat (repeat (repeat twice))) 10)"
        sexpr7 = "((repeat (repeat (repeat (repeat twice)))) 10)"
        _actual1 = eval_sexpr(parse(sexpr1))
        _actual2 = eval_sexpr(parse(sexpr2))
        actual3 = eval_sexpr(parse(sexpr3))
        actual4 = eval_sexpr(parse(sexpr4))
        actual5 = eval_sexpr(parse(sexpr5))
        actual6 = eval_sexpr(parse(sexpr6))
        actual7 = eval_sexpr(parse(sexpr7))
        expected_3 = 10
        self.assertEqual(actual3, expected_3)
        expected_4 = 40
        self.assertEqual(actual4, expected_4)
        expected_5 = 160
        self.assertEqual(actual5, expected_5)
        expected_6 = 2560
        self.assertEqual(actual6, expected_6)
        expected_7 = 655360
        self.assertEqual(actual7, expected_7)

    def test_eval_expr_8(self):
        """Test 'eval_sexpr' range"""
        sexpr1 = "(define fib (lambda (n) (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2))))))"
        sexpr2 = "(define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b)))))"
        sexpr3 = "(range 0 10)"
        sexpr4 = "(map fib (range 0 10))"
        sexpr5 = "(map fib (range 0 20))"
        _actual1 = eval_sexpr(parse(sexpr1))
        _actual2 = eval_sexpr(parse(sexpr2))
        actual3 = eval_sexpr(parse(sexpr3))
        actual4 = eval_sexpr(parse(sexpr4))
        actual5 = eval_sexpr(parse(sexpr5))
        expected_3 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        self.assertEqual(actual3, expected_3)
        expected_4 = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
        self.assertEqual(actual4, expected_4)
        expected_5 = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765]
        self.assertEqual(actual5, expected_5)
