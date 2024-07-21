#!/usr/bin/env python

import os
import re

MonitorFilePath = '/var/monitor/node_monitor_0.option'
if os.path.exists(MonitorFilePath):
	os.remove(MonitorFilePath)
Exp = re.compile('root[ ]+(\d+)')

PsStr = "ps -ef|grep erlang |grep %sline@"%('lszm_')

Buf = os.popen(PsStr).read()
Lines = Buf.split('\n')
for L in Lines:
    if L.find('ps -ef|grep erlang') == -1:
        Res = Exp.findall(L)
        if len(Res) > 0:
            os.system('kill %d' % int(Res[0]))
