#!/usr/bin/env python
import os
import sys

host = '127.0.0.1'
if len(sys.argv) > 1:
     host = sys.argv[1]
cmdline = './start.py  --dbcenter $host$ --linecenter $host$ --guild $host$ --gmcenter $host$'
cmdline = cmdline.replace('$host$',host)
print cmdline
os.system(cmdline)
