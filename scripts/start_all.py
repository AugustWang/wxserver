#!/usr/bin/env python
import os
import sys

def replace_bench(input_string,old_string_array,new_string_array):
    temp_string = input_string
    i=0
    for old in old_string_array:
        temp_string = temp_string.replace(old,new_string_array[i])
        i=i+1
    return temp_string

cwd = os.path.abspath(os.path.split(sys.argv[0])[0])
os.chdir(cwd)

dbhost = '127.0.0.1'
linehost= '127.0.0.1'
maphost ='127.0.0.1'
gatehost ='127.0.0.1'
gmhost = '127.0.0.1'
chathost = '127.0.0.1'
guildhost = '127.0.0.1'
crosshost = '127.0.0.1'
authhost = '127.0.0.1'
timerhost = '127.0.0.1'

if len(sys.argv) > 1:
    dbhost = sys.argv[1]
    linehost= sys.argv[1]
    maphost =sys.argv[1]
    gatehost =sys.argv[1]
    gmhost = sys.argv[1]
    chathost = sys.argv[1]
    guildhost = sys.argv[1]
    crosshost = sys.argv[1]
    authhost = sys.argv[1]
    timerhost = sys.argv[1]

if sys.platform=='linux2':
    cmdlineheader = './start.py --linecenter %s' %(linehost)
else:
    cmdlineheader = 'start start.py --linecenter %s' %(linehost)
    

cmdline = cmdlineheader + ' --db ' + dbhost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --line ' + linehost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --map1 ' + maphost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --map2 ' + maphost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --map3 ' + maphost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --gate1 ' + gatehost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --gate2 ' + gatehost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --chat1 ' + chathost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --cross ' + crosshost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --guild ' + guildhost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --gm ' + gmhost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --auth ' + authhost
print cmdline
os.system(cmdline)

cmdline = cmdlineheader + ' --timer ' + timerhost
print cmdline
os.system(cmdline)
