#!/usr/bin/env python
import os
import sys
import string

def makeversion(param):
    
    if sys.platform=='linux2':
        os.system('./makeversion.py '+ param)
    else:
        os.system('makeversion.py '+ param)

cwd = os.path.abspath(os.path.split(sys.argv[0])[0])

os.chdir(cwd)

PROTO_PATH='%s/../../../common/proto' % (cwd)

os.system('%s/../../../tools/ei_compiler/mkmsg.py  --erh_out %s/../include --erl_out %s/../src/modules/protocol --proto_dir %s ' % (cwd,cwd,cwd,PROTO_PATH))

#debug =''
#makeversion('-RELEASE')

debug = False
if len(sys.argv)==2:
    dbg = sys.argv[1]
    if dbg == 'debug':
       debug=True

if sys.platform=='linux2':
	if	debug:
		cpcmd = 'cp Emakefile.linux.debug Emakefile'
	else:
    		cpcmd = 'cp Emakefile.linux Emakefile'
    	mkcmd = 'escript erl_make.erl'
else:
    cpcmd = 'copy Emakefile.win Emakefile'
    mkcmd = 'escript.exe erl_make.erl'

os.chdir(cwd)

print cpcmd
os.system(cpcmd)

print mkcmd
os.system(mkcmd)

