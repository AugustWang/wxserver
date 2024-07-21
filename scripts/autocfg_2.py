#!/usr/bin/env python
import os
import sys
import options
import string
import re


cwd = os.path.abspath(os.path.split(sys.argv[0])[0])
os.chdir(cwd)
opt =options.Options(sys.argv)
##process every node

host = opt.get_value('-host')[0]

gateip = '127.0.0.1'
if host != '':
    gateip = host
    
map1ip = '127.0.0.1'
if host != '':
    map1ip = host

map2ip = '127.0.0.1'
if host != '':
    map2ip = host

miscip = '127.0.0.1'
if host != '':
    miscip = host

PortMin = opt.get_value('-min_port')[0]
PortMax = opt.get_value('-max_port')[0]

gatelist = '1,2,3,4,5,6'

if opt.get_value('-gateip')[0] != '':
    gateip = opt.get_value('-gateip')[0]
    if opt.get_value('-gateip')[1] != '':
    		gatelist = opt.get_value('-gateip')[1]
 
map1list = '1,2,3,4'

if opt.get_value('-map1ip')[0] != '':
    map1ip = opt.get_value('-map1ip')[0]
    if opt.get_value('-map1ip')[1] != '':
    		map1list = opt.get_value('-map1ip')[1]

map2list = ''

if opt.get_value('-map2ip')[0] != '':
    map2ip = opt.get_value('-map2ip')[0]
    if opt.get_value('-map2ip')[1] != '':
    		map2list = opt.get_value('-map2ip')[1]
    		
if opt.get_value('-miscip')[0] != '':
    miscip = opt.get_value('-miscip')[0]

mapshare1server = ''
mapshare1ip = ''
if opt.get_value('-mapshare1ip')[0] != '':
		mapshare1ip  = opt.get_value('-mapshare1ip')[0]
		if opt.get_value('-mapshare1ip')[1] != '':
			mapshare1server = opt.get_value('-mapshare1ip')[1]
					
mapshare1name = ''	
		
if mapshare1server != '':
		mapshare1server = mapshare1server.split(',')
		for serverid in mapshare1server:
				mapshare1name	= mapshare1name + serverid + '_'
				
def replace_bench(input_string,old_string_array,new_string_array):
    temp_string = input_string
    i=0
    for old in old_string_array:
        temp_string = temp_string.replace(old,new_string_array[i])
        i=i+1
    return temp_string

if sys.platform=='linux2':
    cmd = './configure_2.py '
    cmd2 = './cfg_node.option.py '
else:
    cmd = 'configure_2.py '
    cmd2 = 'cfg_node.option.py '



Prefix = opt.get_value('-prefix')[0]

Platform = opt.get_value('-pf')[0]
if Platform == '':
	Platform = 'unknown'

Sid = opt.get_value('-sid')[0]
if Sid =='':
	Sid = '0'

if Prefix == '':
    Prefix = Platform +'_'+Sid+'_'

cmdoption =' --line $MISCIP$ --guild $MISCIP$ --timer $MISCIP$ --db $MISCIP$ --cross $GATEIP$ --gm $MISCIP$ --auth $MISCIP$ --chat1 $MISCIP$ '

map1list = map1list.split(',')
for num in map1list:
	cmdoption = cmdoption + ' --map' +num + ' $MAP1IP$ '
		
map2list = map2list.split(',')
for num in map2list:
	cmdoption = cmdoption + ' --map' +num + ' $MAP2IP$ '
	
gatelist = gatelist.split(',')
for num in gatelist:
	cmdoption = cmdoption + ' --gate' +num + ' $GATEIP$ '
	
cmdoption = cmdoption + ' --tool1 $MISCIP$ --tool2 $MISCIP$ --tool3 $MISCIP$ --tool4 $MISCIP$ --tool5 $MISCIP$ --tool6 $MISCIP$ '

if mapshare1ip != '':
	cmdoption = cmdoption + ' --mapshare1 $MAPSHARE1IP$ $MAPSHARE1NAME$ '

if Prefix !='':
    cmdoption = cmdoption + ' --prefix $PREFIX$ '

if PortMin !='':
    if PortMax!='':
        cmdoption  = cmdoption + ' --min_port $MIN_PORT$ --max_port $MAX_PORT$'
    else:
        cmdoption = cmdoption + ' --min_port $MIN_PORT$ --max_port $MIN_PORT$'
    
cmdoption = replace_bench(cmdoption,['$GATEIP$','$MAP1IP$','$MAP2IP$','$MISCIP$','$MIN_PORT$','$MAX_PORT$','$PREFIX$','$MAPSHARE1IP$','$MAPSHARE1NAME$'],
												[gateip,map1ip,map2ip,miscip,PortMin,PortMax,Prefix,mapshare1ip,mapshare1name])
cmd =  cmd + cmdoption + ' --pf ' + Platform + ' --sid ' + Sid
cmd2 = cmd2 + cmdoption
os.system(cmd)
os.system(cmd2)
