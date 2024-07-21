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
    
    def values(self):
        return self._config
