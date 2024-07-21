#!/usr/bin/env python

import os
import re

Exp = re.compile('\w+[ ]+(\d+)')

Buf = os.popen("ps -ef|grep erlang").read()

Lines = Buf.split('\n')
for L in Lines:
    if L.find('ps -ef|grep erlang') == -1:
        Res = Exp.findall(L)
        if len(Res) > 0:
            os.system('kill -9 %d' % int(Res[0]))
