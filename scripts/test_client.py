#!/usr/bin/env python
import os
import sys

os.chdir('../ebin')

if len(sys.argv) == 3:
    Count = int(sys.argv[1])
    Group = int(sys.argv[2])
else:
    Count = 2
    Group = 10
os.system("ulimit -SHn 65535 && erl -smp disable +K true -eval 'start_robot:test(%d,%d).'" % (Count,Group))
