#!/usr/bin/env python
import os
import sys

class Options(object):
    def proc_argv(self,argv):
        i = 1;
        argc = len(argv)
        opt = ''
        opt_params= []
        config = self._config
        while(i<argc):
            if str.find(argv[i],'--')!=-1:
                newopt = str.replace(argv[i],'-','',1)
                if opt !='':
                    config[opt] = opt_params
                opt = newopt
                opt_params = []
            else:
                opt_params.append(argv[i])
            i=i+1
        if opt !='':
            config[opt] = opt_params
            
    def __init__(self,argv):
        self._argv = argv
        self._config = {}
        Options.proc_argv(self,argv)

    def get_value(self,optname):
        try:
            value = self._config[optname]
        except:
            value = ['']
        return value

opt =Options(sys.argv)

host = opt.get_value('-host')[0]
if host == '':
    host = '192.168.0.99'

mischost=opt.get_value('-mischost')[0]
if mischost=='':
    mischost='192.168.0.102'

cmdline = './start_node.py --node gate1 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node gate2 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node gate3 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node gate4 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node gate5 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node gate6 --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
cmdline = './start_node.py --node cross --linehost %s  --host %s'%(mischost,host)
os.system(cmdline)
