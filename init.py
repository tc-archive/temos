#!/usr/bin/env python

"""
execute command
"""

import os
import sys

def main():
    """
    execute command
    """
    print "shell PID: " + str(os.system("echo $$"))
    # print "argv: " + sys.argv[1]
    cmd = "unset -f " + sys.argv[1]
    print "cmd: " + cmd
    os.system(cmd)

if __name__ == "__main__":
    main()
