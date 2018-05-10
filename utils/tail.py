#!/usr/bin/python

import os


def tail(f, n):
    """
    Function is a wrapper for UNIX tail function. 
    If you're on Windows, install UnxUtils from https://sourceforge.net/projects/unxutils/
    Extract archive and add usr\local\wbin to environment PATH variable.
    """
    try:
        stdout = os.popen("tail -n {} {}".format(n, f))
        lines = [x.replace('\n', '') for x in stdout.readlines()]
        stdout.close()
    except:
        print("You have to install 'tail' utility. For Windows check UnxUtils from \n" +
              "https://sourceforge.net/projects/unxutils")
    return lines