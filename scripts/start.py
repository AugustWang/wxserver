#!/usr/bin/env python
import os
import sys
def getmapnodes(config):
    nodes = []
    for item in config:
        if item.find('--map') != -1:
            name = item.replace('--','') + '@' + config[item]
            nodes.append(name)
    return nodes

def getgatenodes(config):
    nodes = []
    for item in config:
        if item.find('--gate') != -1:
            name = item.replace('--','') + '@' + config[item]
            nodes.append(name)
    return nodes

def getchatnodes(config):
    nodes = []
    for item in config:
        if item.find('--chat') != -1:
            name = item.replace('--','') + '@' + config[item]
            nodes.append(name)
    return nodes


def replace_bench(input_string,old_string_array,new_string_array):
    temp_string = input_string
    i=0
    for old in old_string_array:
        temp_string = temp_string.replace(old,new_string_array[i])
        i=i+1
    return temp_string

class run_base(object):
    def execute(self,curnode,linenode,options):
        print 'call base class!'

class run_gs(run_base):
    def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +P 100000 +K true  $OPTIONS$ -noshell -name $CURNODE$ -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        elif sys.platform=='darwin':
            cmdline = 'erl  $OPTIONS$ -noshell  -name $CURNODE$ -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        else:
            cmdline = 'erl.exe  $OPTIONS$  -name $CURNODE$ -s server_tool run --line $LINENODE$'
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])

        print cmdline
        
        os.system(cmdline)
        
       

class run_shell(run_base):
    def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +P 100000 +K true  $OPTIONS$ -name $CURNODE$ -s server_tool run --line $LINENODE$'
        elif sys.platform=='darwin':
            cmdline = 'erl $OPTIONS$  -name $CURNODE$ -s server_tool run --line $LINENODE$'
        else:
            cmdline = 'erl.exe  $OPTIONS$ -name $CURNODE$ -s server_tool run --line $LINENODE$'
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])

        print cmdline
        
        #os.system(cmdline)


def get_cmd(config,cmd,opt):
    config[cmd] = opt
    
if __name__ == '__main__':
    os.chdir('../ebin')
    
    argc =  len(sys.argv)
    config = {'--db':'',
              '--line':'',
              '--cross':'', 
              '--timer':'',
              '--auth':'',
              '--guild':'',
              '--gm':'',
              '--nohide':'',
              '--linecenter':''}

    while(argc>=3):
        get_cmd(config,sys.argv[argc-2],sys.argv[argc-1])
        argc=argc-2
        
    if config['--linecenter'] == '':
        print 'error input ,missing --linecenter option'
        
    linecenter = 'line@'+config['--linecenter']

    mapnodes = getmapnodes(config)
    gatenodes = getgatenodes(config)
    chatnodes = getchatnodes(config)

    robj = run_gs()
    if config['--nohide']!='':
        robj = run_shell()

    if config['--db']!='':
        dbnode = 'db@'+config['--db']
    else:
        dbnode = ''
    
    if config['--line']!='':
        linenode = 'line@'+config['--line']
    else:
        linenode = ''
        
    if config['--auth']!='':
        authnode = 'auth@'+config['--auth']
    else:
        authnode = ''
        
    if config['--timer']!='':
        timernode ='timer@'+config['--timer']
    else:
        timernode = ''
        
    if config['--guild']!='':
        guildnode='guild@'+config['--guild']
    else:
        guildnode = ''
        
    if config['--gm']!='':
        gmnode = 'gm@' +config['--gm']
    else:
        gmnode = ''

    if config['--cross']!='':
        crossnode = 'cross@'+config['--cross']
    else:
        crossnode = ''

    if dbnode!='':
        option = ' -mnesia dir \'"../dbfile/"\' '
        robj.execute(dbnode,linecenter,option)
        
    for mapnode in mapnodes:
        robj.execute(mapnode,linecenter,'-smp disable')

    for gatenode in gatenodes:
        robj.execute(gatenode,linecenter,'-smp disable')
        
    for chatnode in chatnodes:
        robj.execute(chatnode,linecenter,'')
        
    if crossnode != '':
        robj.execute(crossnode,linecenter,'')

    if gmnode!='':
        robj.execute(gmnode,linecenter,'')
        
    if linenode!='':
        robj.execute(linenode,linecenter,'')
        
    if authnode!='':
        robj.execute(authnode,linecenter,'')
        
    if timernode!='':
        robj.execute(timernode,linecenter,'')
                
    if guildnode!='':
        robj.execute(guildnode,linecenter,'')

