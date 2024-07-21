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

if opt.get_value('-gateip')[0] != '':
    gateip = opt.get_value('-gateip')[0]

if opt.get_value('-map1ip')[0] != '':
    map1ip = opt.get_value('-map1ip')[0]

if opt.get_value('-map2ip')[0] !='':
    map2ip = opt.get_value('-map2ip')[0]

if opt.get_value('-miscip')[0] != '':
    miscip = opt.get_value('-miscip')[0]

def replace_bench(input_string,old_string_array,new_string_array):
    temp_string = input_string
    i=0
    for old in old_string_array:
        temp_string = temp_string.replace(old,new_string_array[i])
        i=i+1
    return temp_string

if sys.platform=='linux2':
    cmd = './configure.py '
else:
    cmd = 'configure.py '


Prefix = opt.get_value('-prefix')[0]

cmd =cmd + ' --line $MISCIP$ --guild $MISCIP$ --timer $MISCIP$ --db $MISCIP$ --cross $GATEIP$ --gm $MISCIP$ --auth $MISCIP$ --chat1 $MISCIP$ '
cmd =cmd + ' --map1 $MAP1IP$ --map2 $MAP1IP$ --map3 $MAP1IP$ --map4 $MAP1IP$ --map5 $MAP2IP$ --map6 $MAP2IP$ --map7 $MAP2IP$ --map8 $MAP2IP$ '
cmd =cmd + ' --map9 $MAP1IP$ --map10 $MAP2IP$ --map11 $MAP1IP$ --map12 $MAP2IP$ --map13 $MAP1IP$ --map14 $MAP2IP$  '
cmd =cmd + ' --gate1 $GATEIP$ --gate2 $GATEIP$ --gate3 $GATEIP$ --gate4 $GATEIP$ --gate5 $GATEIP$ --gate6 $GATEIP$ '
cmd =cmd + ' --tool1 $MISCIP$ --tool2 $MISCIP$ --tool3 $MISCIP$ --tool4 $MISCIP$ --tool5 $MISCIP$ --tool6 $MISCIP$ '

if Prefix !='':
    cmd =cmd + ' --prefix $PREFIX$ '

if PortMin !='':
    if PortMax!='':
        cmd =cmd + ' --min_port $MIN_PORT$ --max_port $MAX_PORT$'
    else:
        cmd =cmd + ' --min_port $MIN_PORT$ --max_port $MIN_PORT$'
    
cmd = replace_bench(cmd,['$GATEIP$','$MAP1IP$','$MAP2IP$','$MISCIP$','$MIN_PORT$','$MAX_PORT$','$PREFIX$'],[gateip,map1ip,map2ip,miscip,PortMin,PortMax,Prefix])

os.system(cmd)
