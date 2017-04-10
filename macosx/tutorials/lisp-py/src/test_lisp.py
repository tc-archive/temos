"""
lisp.py Units Tests
"""

import unittest

from lisp import parse

class TestLisp(unittest.TestCase):
    """Tests"""
    def test_parse(self):
        """Test parse function happy path"""
        actual = parse('(begin (define r 10) (* pi (* r r)))')
        expected = ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]]
        self.assertEqual(actual, expected)
