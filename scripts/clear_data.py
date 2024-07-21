#!/usr/bin/env python
import os
import sys
import re

os.system("rm -r -f ../dbfile")
os.system("rm -r -f ../dbfile1")

os.system("rm -r -f ../ebin/Mnesia.*@*")

os.system("mkdir ../dbfile")

os.system("mkdir ../dbfile1")

host = '127.0.0.1'
if len(sys.argv) > 1:
	host = sys.argv[1]
	
def start_db():
    os.chdir('../scripts')
    cmdline = './start.py --linecenter $host$ --db $host$ --nohide true'
    cmdline = cmdline.replace('$host$',host)
    os.system(cmdline)
    
def start_line():
    cmdline = './start.py --linecenter $host$ --line $host$ '
    cmdline = cmdline.replace('$host$',host)
    os.system(cmdline)

def start_timer():
    cmdline = './start.py --linecenter $host$ --timer $host$ '
    cmdline = cmdline.replace('$host$',host)
    os.system(cmdline)

if __name__ == '__main__':
    start_line()
    start_timer()
    start_db()
