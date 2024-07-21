#!/usr/bin/env python
import os
import sys


cwd = os.path.abspath(os.path.split(sys.argv[0])[0])
os.chdir(cwd)

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
            
def erl_compile(debug,srcfile,inc_dir,hipe,out_dir,nowarning_opt,defines):
    if sys.platform=='linux2':
        cmdline_header = 'erlc -W '
    elif sys.platform=='darwin':
        cmdline_header = 'erlc -W '
    else:
        cmdline_header = 'erlc.exe -W '
    if inc_dir !='':
        Inc = ' -I ' + inc_dir +' '
    else:
        Inc = ''

    if debug =='true':
        Dbg = ' +debug_info '
    else:
        Dbg = ''

    if hipe =='true':
        Hipe = ' +native +"{hipe, [o3]}" '
    else:
        Hipe = ''

    if srcfile !='':
        Src = srcfile
        
    if out_dir !='':
        Out = ' -o '+ out_dir

    if nowarning_opt == 'true':
        NoWarning = ' +nowarn_unused_vars +nowarn_unused_function '
    else:
        NoWarning = ''

    Defines = ''
    if len(defines) !=0:
        for DM in defines:
            if DM !='':
                Defines+= ' -D'+DM
    else:
        Defines = ''
        
    cmdline = cmdline_header + Out +Inc + Dbg  +Defines + Hipe + NoWarning + Src
    print cmdline
    os.system(cmdline)

opt = Options(sys.argv)

I = opt.get_value('-I')[0]
dbg = opt.get_value('-debug')[0]
hipe = opt.get_value('-hipe')[0]
out_dir = opt.get_value('-output')[0]
src_dir = opt.get_value('-src')[0]
nowarning = opt.get_value('-nowarning')[0]
defines=opt.get_value('-define')

print defines

files = []

class erl_object(object):
    def __init__(self,src):
        self._src = src
        self._inc = []
        erl_object.proc_erl(self,src)

    def proc_erl(self,src):
        fd = open(src,'r')
        lines = fd.readlines()
        fd.close()
        incstr = '-include("'
        incstr2= '").'
        for line in lines:
            if line.find(incstr) != -1:
                line = line.replace(incstr,'')
                line = line.replace('\n','')
                line = line.replace('\r','')
                line = line.replace('\t','')
                line = line.replace(' ','')
                incfile = line.replace(incstr2,'')
                
                self._inc.append(incfile)
                
    def check_modified(self,out,inc_dir):
        print 'now checking '+self._src
        path = os.path.split(self._src)
        path1 = os.path.splitext(path[1])
        dstfile = out +'/' + path1[0] + '.beam'
        srcfile = self._src
        
        if not os.path.exists(os.path.abspath(dstfile)) :
            print 'not exists:' + dstfile
            return True
        if os.stat(os.path.abspath(dstfile)).st_mtime < os.stat(os.path.abspath(srcfile)).st_mtime:
            print 'timeout:' + dstfile
            return True
        for incfile in self._inc:
            incfile = inc_dir + '/'+ incfile
            curincfile = path[0] + '/'+ incfile
            if os.path.exists(os.path.abspath(incfile)) :
                if os.stat(os.path.abspath(dstfile)).st_mtime < os.stat(os.path.abspath(incfile)).st_mtime:
                    print 'include timeout:'+dstfile
                    return True
                else:
                    return False
            elif os.path.exists(os.path.abspath(curincfile)):
                if os.stat(os.path.abspath(dstfile)).st_mtime < os.stat(os.path.abspath(curincfile)).st_mtime:
                    print 'include timeout:'+ dstfile
                    return True
                else:
                    return False
            else:
                print 'not exists include:'+ incfile +'  outfile:'+ dstfile
                return True
        return False
    
        
    def erlc(self,debug,hipe,inc_dir,out_dir,nowarning_opt,defines):
        
        if erl_object.check_modified(self,out_dir,inc_dir):
            erl_compile(dbg,self._src,inc_dir,hipe,out_dir,nowarning_opt,defines)
        

def scan_dir(files,input_dir):
    
    for file in os.listdir(input_dir):
        if file =='.svn':
            continue
        absfile = input_dir + file
        if os.path.isdir(absfile):
            scan_dir(files,absfile + '/')
        else:
            path = os.path.splitext(absfile)
            if len(path) == 2 and path[1] == '.erl':
                files.append(absfile)

        

scan_dir(files,src_dir)    
for item in files:
    obj = erl_object(item)
    obj.erlc(dbg,hipe,I,out_dir,nowarning,defines)



        
    
        




