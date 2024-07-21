#!/usr/bin/env python
import os
import sys
import options
import re
import time


def gen_file(filename,content):
    if not os.path.exists(filename):
        open(filename, 'w').close()
        
    fd = open(filename, 'r+')
    fd.truncate()
    fd.write(content)
    fd.close()

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
        
class run_hidden(run_base):
     def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +K true  $OPTIONS$ -detached -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$ -hidden > /dev/null 2>&1&'
        elif sys.platform=='darwin':
            cmdline = 'erl  $OPTIONS$ -detached  -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$  -hidden > /dev/null 2>&1&'
        else:
            cmdline = 'start erl.exe  $OPTIONS$  -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$  -hidden '
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])
        print cmdline    
        os.system(cmdline)

class run_gs(run_base):
    def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +K true  $OPTIONS$ -detached -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        elif sys.platform=='darwin':
            cmdline = 'erl  $OPTIONS$ -detached  -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        else:
            cmdline = 'start erl.exe  $OPTIONS$  -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$'
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])

        print cmdline
        
        os.system(cmdline)
        

class run_shell(run_base):
    def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +K true  $OPTIONS$ -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$'
        elif sys.platform=='darwin':
            cmdline = 'erl $OPTIONS$  -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$'
        else:
            cmdline = 'start erl.exe  $OPTIONS$ -name $CURNODE$ -s reloader -s server_tool run --line $LINENODE$'
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])

        print cmdline
        
        os.system(cmdline)
        
class run_callfunc_base(object):
     def execute(self,curnode,linenode,options,callfunc):
        print 'call callfunc base class!'
        
class run_callfunc(run_callfunc_base):
     def execute(self,curnode,linenode,options,callfunc):
	cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +K true  $OPTIONS$ -noshell -name $CURNODE$ -s reloader -s server_tool run $CALLFUNC$ --line $LINENODE$'
        elif sys.platform=='darwin':
            cmdline = 'erl $OPTIONS$ -noshell -name $CURNODE$ -s reloader -s server_tool run $CALLFUNC$ --line $LINENODE$'
        else:
            cmdline = 'start erl.exe  $OPTIONS$ -noshell -name $CURNODE$ -s reloader -s server_tool run $CALLFUNC$ --line $LINENODE$'
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$','$CALLFUNC$'],[curnode,linenode,options,callfunc])

        print cmdline
        
        os.system(cmdline)

def string_include(str_list,substr):
    for i in str_list:
        if i==substr:
            return True
    return False

def get_iplist():
    if sys.platform=='linux2':
        child = os.popen("/sbin/ifconfig | grep 'inet addr' | awk '{print $2}'")
        current_ip = child.read()
        current_ip = current_ip.split('\n')
        current_ips = []
        for i in current_ip:
            if i !='':
                current_ips.append(i.replace('addr:',''))
    else:
        child = os.popen("ipconfig")
        current_ip = child.read()
        current_ip = current_ip.split('\n')
        current_ips = []
        for i in current_ip:
            if i !='':
                if (i.find('IP')!=-1) and (i.find(' : ')!=-1):
                    indx = i.find(' : ')
                    current_ips.append(i[(indx + 3):])
    return current_ips
        
def run_hidden_app(App,LineNode,CurNode,PortMin,PortMax):
	 AppOptions = ''
	 if App == 'map_share':
		AppOptions = ' -smp disable '
		 			
	 if PortMin !='':
        	AppOptions = AppOptions + '-kernel inet_dist_listen_min ' + PortMin
        	if PortMax !='':
            		AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMax
        	else:
            		AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMin    
   	 robj = run_hidden()
    	 robj.execute(CurNode,LineNode,AppOptions)
		 
def run_at_shell(App,LineNode,CurNode,PortMin,PortMax):
    AppOptions = ''
    if App == 'db':
        AppOptions=' -mnesia dir \'"../dbfile/"\' '
    if PortMin !='':
        AppOptions = AppOptions + '-kernel inet_dist_listen_min ' + PortMin
        if PortMax !='':
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMax
        else:
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMin
    robj = run_shell()
    robj.execute(CurNode,LineNode,AppOptions)
    
def run_with_func(App,LineNode,CurNode,PortMin,PortMax,Func):
    AppOptions = ''
    if App == 'db':
        AppOptions=' -mnesia dir \'"../dbfile/"\' '
    if PortMin !='':
        AppOptions = AppOptions + '-kernel inet_dist_listen_min ' + PortMin
        if PortMax !='':
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMax
        else:
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMin
    robj = run_callfunc()
    robj.execute(CurNode,LineNode,AppOptions,Func)

def run_app(App,LineNode,CurNode,PortMin,PortMax):
    run_app1(App,LineNode,CurNode,PortMin,PortMax,False)
    
def run_app1(App,LineNode,CurNode,PortMin,PortMax,ShowShell):
    AppOptions = ''
    if App == 'db':
        AppOptions=' -mnesia dir \'"../dbfile/"\' '
    elif App =='map1':
        AppOptions=' -smp disable '
    elif App =='map2':
        AppOptions=' -smp disable '
    elif App =='map3':
        AppOptions=' -smp disable '
    elif App =='map4':
        AppOptions=' -smp disable '
    elif App =='map5':
        AppOptions=' -smp disable '
    elif App =='map6':
        AppOptions=' -smp disable '
    elif App =='map7':
        AppOptions=' -smp disable '
    elif App =='map8':
        AppOptions=' -smp disable '
    elif App =='map9':
        AppOptions=' -smp disable '
    elif App =='map10':
        AppOptions=' -smp disable '
    elif App =='map11':
        AppOptions=' -smp disable '
    elif App =='map12':
        AppOptions=' -smp disable '
    elif App =='map13':
        AppOptions=' -smp disable '
    elif App =='map14':
        AppOptions=' -smp disable '
    elif App =='gate1':
        AppOptions=' -smp disable '
    elif App =='gate2':
        AppOptions=' -smp disable '
    elif App =='gate3':
        AppOptions=' -smp disable '
    elif App =='gate4':
        AppOptions=' -smp disable '
    elif App =='gate5':
        AppOptions=' -smp disable '
    elif App =='gate6':
        AppOptions=' -smp disable '

    if PortMin !='':
        AppOptions = AppOptions + '-kernel inet_dist_listen_min ' + PortMin
        if PortMax !='':
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMax
        else:
            AppOptions = AppOptions + ' inet_dist_listen_max ' + PortMin
    if ShowShell:
  	robj = run_shell()
    	robj.execute(CurNode,LineNode,AppOptions)
    else:
    	robj = run_gs()
    	robj.execute(CurNode,LineNode,AppOptions)
    
if __name__ == '__main__':
    os.chdir('../ebin')
    opt =options.Options(sys.argv)

    LineNode = 'lszm_line@127.0.0.1'
    GuildNode= 'lszm_guild@127.0.0.1'
    TimerNode= 'lszm_timer@127.0.0.1'
    CrossNode= 'lszm_cross@127.0.0.1'
    AuthNode = 'lszm_auth@127.0.0.1'
    GmNode   = 'lszm_gm@127.0.0.1'
    DbNode   = 'lszm_db@127.0.0.1'
    Chat1Node= 'lszm_chat1@127.0.0.1'
    Chat2Node= 'lszm_chat2@'
    Chat3Node= 'lszm_chat3@'
    Chat4Node= 'lszm_chat4@'
    Chat5Node= 'lszm_chat5@'
    Chat6Node= 'lszm_chat6@'
    Map1Node = 'lszm_map1@127.0.0.1'
    Map2Node = 'lszm_map2@127.0.0.1'
    Map3Node = 'lszm_map3@'
    Map4Node = 'lszm_map4@'
    Map5Node = 'lszm_map5@'
    Map6Node = 'lszm_map6@'
    Map7Node = 'lszm_map7@'
    Map8Node = 'lszm_map8@'
    Map9Node = 'lszm_map9@'
    Map10Node = 'lszm_map10@'
    Map11Node = 'lszm_map11@'
    Map12Node = 'lszm_map12@'
    Map13Node = 'lszm_map13@'
    Map14Node = 'lszm_map14@'
    Gate1Node= 'lszm_gate1@127.0.0.1'
    Gate2Node= 'lszm_gate2@'
    Gate3Node= 'lszm_gate3@'
    Gate4Node= 'lszm_gate4@'
    Gate5Node= 'lszm_gate5@'
    Gate6Node= 'lszm_gate6@'
    Tool1Node = 'lszm_tool1@127.0.0.1'
    Tool2Node = 'lszm_tool2@127.0.0.1'
    Tool3Node = 'lszm_tool3@127.0.0.1'
    Tool4Node = 'lszm_tool4@127.0.0.1'
    Tool5Node = 'lszm_tool5@127.0.0.1'
    Tool6Node = 'lszm_tool6@127.0.0.1'
    ShareMap1Node = 'map_share@'
    ShareMap2Node = 'map_share@'
    ShareMap3Node = 'map_share@'
    ShareMap4Node = 'map_share@'
    ServerToolNode = 'lszm_servercontrol@127.0.0.1'
    
    Clear = opt.get_value('-clear')[0]
    if Clear != '':
        os.system("rm -r -f ../dbfile")
        os.system("rm -r -f ../dbfile1")
        os.system("rm -r -f ../ebin/Mnesia.*@*")
        os.system("mkdir ../dbfile")

    NoCross = opt.get_value('-nocross')[0]
    Cross = opt.get_value('-cross')[0]
    
    Exp = re.compile('root[ ]+(\d+)')
    PsStr = "ps -ef|grep erlang |grep cross"
    Buf = os.popen(PsStr).read()
    if len(Buf.split('\n')) > 1:
    	    NoCross = 'true'
   
    Regen = opt.get_value('-gen')[0]
    Tool1 = opt.get_value('-tool1')[0]
    Tool2 = opt.get_value('-tool2')[0]
    Tool3 = opt.get_value('-tool3')[0]
    Tool4 = opt.get_value('-tool4')[0]
    Tool5 = opt.get_value('-tool5')[0]
    Tool6 = opt.get_value('-tool6')[0]
    
    ServerMod = opt.get_value('-servercontrol')[0]
    
    ShareIp = opt.get_value('-share')[0]
    ShareName = 'share_'
    ShareNode = '127.0.0.1'
    if ShareIp != '':
    	ShareName = opt.get_value('-share')[1]
    	ShareNode = ShareName+'map_share@'+ShareIp
		
    PortMin = ''
    PortMax = ''
    Curpwd = os.getcwd()
    LogPath = Curpwd.replace('ebin','log/*.log')
    BackupPath = Curpwd.replace('ebin','backup/')
    MonitorString = 'platform:unknown\r\nsid:0\r\nlog:'+LogPath+'\r\nbackup:'+BackupPath+'\r\n'
    current_ips = get_iplist()
    ServerToolFlag = ''
    CallFunc = ''
    ServerToolParam = ''
    if ServerMod != '':
	ServerToolFlag = opt.get_value('-servercontrol')[1]
	ServerToolParam = opt.get_value('-servercontrolparam')[0]
	if ServerToolParam != '':
            CallFunc = '--function '+ServerMod + ' --funcparam '+ServerToolParam
        else:
            CallFunc = '--function '+ServerMod 
    if ServerToolFlag == 'old':
	run_with_func('servercontrol',LineNode,ServerToolNode,PortMin,PortMax,CallFunc)
    elif Tool1 !='':
        run_at_shell('tool1',LineNode,Tool1Node,PortMin,PortMax)
    elif Tool2 !='':
        run_at_shell('tool2',LineNode,Tool2Node,PortMin,PortMax)
    elif Tool3 !='':
        run_at_shell('tool3',LineNode,Tool3Node,PortMin,PortMax)
    elif Tool4 !='':
        run_at_shell('tool4',LineNode,Tool4Node,PortMin,PortMax)
    elif Tool5 !='':
        run_at_shell('tool5',LineNode,Tool5Node,PortMin,PortMax)
    elif Tool6 !='':
        run_at_shell('tool6',LineNode,Tool6Node,PortMin,PortMax)
    elif Cross !='':
        run_app('cross',LineNode,CrossNode,PortMin,PortMax)
        print 'Now starting crossdomain node...'
    else:
        if string_include(current_ips,'127.0.0.1'):
            run_app('line',LineNode,LineNode,PortMin,PortMax)
            MonitorString += 'node:'+LineNode +'\r\n'
#timer 
        if string_include(current_ips,'127.0.0.1'):
            run_app('timer',LineNode,TimerNode,PortMin,PortMax)
            MonitorString += 'node:'+TimerNode +'\r\n'
#db
        if Clear!='' or Regen!='':
            if string_include(current_ips,'127.0.0.1'):
                run_at_shell('db',LineNode,DbNode,PortMin,PortMax)
        else:
            if string_include(current_ips,'127.0.0.1'):
                run_app('db',LineNode,DbNode,PortMin,PortMax)
        
        if ShareIp!='':
        #share
      	     run_hidden_app(ShareName+'share_map',LineNode,ShareNode,PortMin,PortMax)
	     print 'Now starting share map node ...'	
	if ServerMod !='':
	#server tool
	    time.sleep(1)
	    run_with_func('servercontrol',LineNode,ServerToolNode,PortMin,PortMax,CallFunc)	
        elif (Clear == '' and Regen =='' and ServerMod == ''):
            #guild
            if string_include(current_ips,'127.0.0.1'):
                run_app('guild',LineNode,GuildNode,PortMin,PortMax)
                MonitorString += 'node:'+GuildNode +'\r\n'
                print 'Now starting guild node ...'
                #os.system('read -n 1')
                time.sleep(1)                
            #cross
            if NoCross!='':
                print 'ignor cross node ...'
            else:
                if string_include(current_ips,'127.0.0.1'):
                    run_app('cross',LineNode,CrossNode,PortMin,PortMax)
                    
            #auth        
            if string_include(current_ips,'127.0.0.1'):
                run_app('auth',LineNode,AuthNode,PortMin,PortMax)
                MonitorString += 'node:'+AuthNode +'\r\n'
            #gm
            if string_include(current_ips,'127.0.0.1'):
                run_app('gm',LineNode,GmNode,PortMin,PortMax)
                MonitorString += 'node:'+GmNode +'\r\n'
            #chat1
            if string_include(current_ips,'127.0.0.1'):
                run_app('chat1',LineNode,Chat1Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat1Node +'\r\n'
                print 'Now starting chat1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #chat2
            if string_include(current_ips,''):
                run_app('chat2',LineNode,Chat2Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat2Node +'\r\n'
                print 'Now starting chat2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat3
            if string_include(current_ips,''):
                run_app('chat3',LineNode,Chat3Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat3Node +'\r\n'
                print 'Now starting chat3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat4
            if string_include(current_ips,''):
                run_app('chat4',LineNode,Chat4Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat4Node +'\r\n'
                print 'Now starting chat4 node ...'
                #os.system('read -n 1')
                time.sleep(1)

            #chat5
            if string_include(current_ips,''):
                run_app('chat5',LineNode,Chat5Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat5Node +'\r\n'
                print 'Now starting chat5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat6
            if string_include(current_ips,''):
                run_app('chat6',LineNode,Chat6Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat6Node +'\r\n'
                print 'Now starting chat6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #map1
            if string_include(current_ips,'127.0.0.1'):
                run_app('map1',LineNode,Map1Node,PortMin,PortMax)
                MonitorString += 'node:'+Map1Node +'\r\n'
                print 'Now starting map1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map2
            if string_include(current_ips,'127.0.0.1'):
                run_app('map2',LineNode,Map2Node,PortMin,PortMax)
                MonitorString += 'node:'+Map2Node +'\r\n'
                print 'Now starting map2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map3
            if string_include(current_ips,''):
                run_app('map3',LineNode,Map3Node,PortMin,PortMax)
                MonitorString += 'node:'+Map3Node +'\r\n'
                print 'Now starting map3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map4
            if string_include(current_ips,''):
                run_app('map4',LineNode,Map4Node,PortMin,PortMax)
                MonitorString += 'node:'+Map4Node +'\r\n'
                print 'Now starting map4 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map5
            if string_include(current_ips,''):
                run_app('map5',LineNode,Map5Node,PortMin,PortMax)
                MonitorString += 'node:'+Map5Node +'\r\n'
                print 'Now starting map5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map6
            if string_include(current_ips,''):
                run_app('map6',LineNode,Map6Node,PortMin,PortMax)
                MonitorString += 'node:'+Map6Node +'\r\n'
                print 'Now starting map6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map7
            if string_include(current_ips,''):
                run_app('map7',LineNode,Map7Node,PortMin,PortMax)
                MonitorString += 'node:'+Map7Node +'\r\n'
                print 'Now starting map7 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map8
            if string_include(current_ips,''):
                run_app('map8',LineNode,Map8Node,PortMin,PortMax)
                MonitorString += 'node:'+Map8Node +'\r\n'
                print 'Now starting map8 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map9
            if string_include(current_ips,''):
                run_app('map9',LineNode,Map9Node,PortMin,PortMax)
                MonitorString += 'node:'+Map9Node +'\r\n'
                print 'Now starting map9 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map10
            if string_include(current_ips,''):
                run_app('map10',LineNode,Map10Node,PortMin,PortMax)
                MonitorString += 'node:'+Map10Node +'\r\n'
                print 'Now starting map10 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map11
            if string_include(current_ips,''):
                run_app('map11',LineNode,Map11Node,PortMin,PortMax)
                MonitorString += 'node:'+Map11Node +'\r\n'
                print 'Now starting map11 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map12
            if string_include(current_ips,''):
                run_app('map12',LineNode,Map12Node,PortMin,PortMax)
                MonitorString += 'node:'+Map12Node +'\r\n'
                print 'Now starting map12 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map13
            if string_include(current_ips,''):
                run_app('map13',LineNode,Map13Node,PortMin,PortMax)
                MonitorString += 'node:'+Map13Node +'\r\n'
                print 'Now starting map13 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map14
            if string_include(current_ips,''):
                run_app('map14',LineNode,Map14Node,PortMin,PortMax)
                MonitorString += 'node:'+Map14Node +'\r\n'
                print 'Now starting map14 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share1
            if string_include(current_ips,''):
                run_hidden_app('map_share',LineNode,ShareMap1Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap1Node +'\r\n'
                print 'Now starting map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share2
            if string_include(current_ips,''):
                run_hidden_app('map_share',LineNode,ShareMap2Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap2Node +'\r\n'
                print 'Now starting map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share3
            if string_include(current_ips,''):
                run_hidden_app('map_share',LineNode,ShareMap3Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap3Node +'\r\n'
                print 'Now starting map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share4
            if string_include(current_ips,''):
                run_hidden_app('map_share',LineNode,ShareMap4Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap4Node +'\r\n'
                print 'Now starting map_share node ...'
                #os.system('read -n 1')
            #gate1
            if string_include(current_ips,'127.0.0.1'):
                run_app1('gate1',LineNode,Gate1Node,PortMin,PortMax,True)
                MonitorString += 'node:'+Gate1Node +'\r\n'
                print 'Now starting gate1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate2
            if string_include(current_ips,''):
                run_app('gate2',LineNode,Gate2Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate2Node +'\r\n'
                print 'Now starting gate2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate3
            if string_include(current_ips,''):
                run_app('gate3',LineNode,Gate3Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate3Node +'\r\n'
                print 'Now starting gate3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate4
            if string_include(current_ips,''):
                run_app('gate4',LineNode,Gate4Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate4Node +'\r\n'
                print 'Now starting gate4 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate5
            if string_include(current_ips,''):
                run_app('gate5',LineNode,Gate5Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate5Node +'\r\n'
                print 'Now starting gate5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate6
            if string_include(current_ips,''):
                run_app('gate6',LineNode,Gate6Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate6Node +'\r\n'
                print 'Now starting gate6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
 

            MonitorFilePath = '/var/monitor/node_monitor_0.option'
	    if not os.path.exists('/var/monitor'):
                os.makedirs('/var/monitor')
            gen_file(MonitorFilePath,MonitorString)
