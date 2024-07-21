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
            cmdline = 'ulimit -SHn 65535 && erl +P 100000 +K true  $OPTIONS$ -detached -name $CURNODE$ -s server_tool run --line $LINENODE$ -hidden > /dev/null 2>&1&'
        elif sys.platform=='darwin':
            cmdline = 'erl  $OPTIONS$ -detached  -name $CURNODE$ -s server_tool run --line $LINENODE$  -hidden > /dev/null 2>&1&'
        else:
            cmdline = 'start erl.exe  $OPTIONS$  -name $CURNODE$ -s server_tool run --line $LINENODE$  -hidden '
            
        cmdline = replace_bench(cmdline,['$CURNODE$','$LINENODE$','$OPTIONS$'],[curnode,linenode,options])
        print cmdline    
        os.system(cmdline)

class run_gs(run_base):
    def execute(self,curnode,linenode,options):
        cmdline = ''
        if sys.platform=='linux2':
            cmdline = 'ulimit -SHn 65535 && erl +P 100000 +K true  $OPTIONS$ -detached -name $CURNODE$ -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        elif sys.platform=='darwin':
            cmdline = 'erl  $OPTIONS$ -detached  -name $CURNODE$ -s server_tool run --line $LINENODE$ > /dev/null 2>&1&'
        else:
            cmdline = 'start erl.exe  $OPTIONS$  -name $CURNODE$ -s server_tool run --line $LINENODE$'
            
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
            cmdline = 'start erl.exe  $OPTIONS$ -name $CURNODE$ -s server_tool run --line $LINENODE$'
            
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
            cmdline = 'ulimit -SHn 65535 && erl +P 100000 +K true  $OPTIONS$ -noshell -name $CURNODE$ -s server_tool run $CALLFUNC$ --line $LINENODE$'
        elif sys.platform=='darwin':
            cmdline = 'erl $OPTIONS$ -noshell -name $CURNODE$ -s server_tool run $CALLFUNC$ --line $LINENODE$'
        else:
            cmdline = 'start erl.exe  $OPTIONS$ -noshell -name $CURNODE$ -s server_tool run $CALLFUNC$ --line $LINENODE$'
            
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
    
    robj = run_gs()
    robj.execute(CurNode,LineNode,AppOptions)
    
if __name__ == '__main__':
    os.chdir('../ebin')
    opt =options.Options(sys.argv)
    
    LineNode = '$PROC_PREFIX$line@$LINE_IP$'
    GuildNode= '$PROC_PREFIX$guild@$GUILD_IP$'
    TimerNode= '$PROC_PREFIX$timer@$TIMER_IP$'
    CrossNode= '$PROC_PREFIX$cross@$CROSS_IP$'
    AuthNode = '$PROC_PREFIX$auth@$AUTH_IP$'
    GmNode   = '$PROC_PREFIX$gm@$GM_IP$'
    DbNode   = '$PROC_PREFIX$db@$DB_IP$'
    Chat1Node= '$PROC_PREFIX$chat1@$CHAT1_IP$'
    Chat2Node= '$PROC_PREFIX$chat2@$CHAT2_IP$'
    Chat3Node= '$PROC_PREFIX$chat3@$CHAT3_IP$'
    Chat4Node= '$PROC_PREFIX$chat4@$CHAT4_IP$'
    Chat5Node= '$PROC_PREFIX$chat5@$CHAT5_IP$'
    Chat6Node= '$PROC_PREFIX$chat6@$CHAT6_IP$'
    Map1Node = '$PROC_PREFIX$map1@$MAP1_IP$'
    Map2Node = '$PROC_PREFIX$map2@$MAP2_IP$'
    Map3Node = '$PROC_PREFIX$map3@$MAP3_IP$'
    Map4Node = '$PROC_PREFIX$map4@$MAP4_IP$'
    Map5Node = '$PROC_PREFIX$map5@$MAP5_IP$'
    Map6Node = '$PROC_PREFIX$map6@$MAP6_IP$'
    Map7Node = '$PROC_PREFIX$map7@$MAP7_IP$'
    Map8Node = '$PROC_PREFIX$map8@$MAP8_IP$'
    Map9Node = '$PROC_PREFIX$map9@$MAP9_IP$'
    Map10Node = '$PROC_PREFIX$map10@$MAP10_IP$'
    Map11Node = '$PROC_PREFIX$map11@$MAP11_IP$'
    Map12Node = '$PROC_PREFIX$map12@$MAP12_IP$'
    Map13Node = '$PROC_PREFIX$map13@$MAP13_IP$'
    Map14Node = '$PROC_PREFIX$map14@$MAP14_IP$'
    Gate1Node= '$PROC_PREFIX$gate1@$GATE1_IP$'
    Gate2Node= '$PROC_PREFIX$gate2@$GATE2_IP$'
    Gate3Node= '$PROC_PREFIX$gate3@$GATE3_IP$'
    Gate4Node= '$PROC_PREFIX$gate4@$GATE4_IP$'
    Gate5Node= '$PROC_PREFIX$gate5@$GATE5_IP$'
    Gate6Node= '$PROC_PREFIX$gate6@$GATE6_IP$'
    Tool1Node = '$PROC_PREFIX$tool1@$LINE_IP$'
    Tool2Node = '$PROC_PREFIX$tool2@$LINE_IP$'
    Tool3Node = '$PROC_PREFIX$tool3@$LINE_IP$'
    Tool4Node = '$PROC_PREFIX$tool4@$LINE_IP$'
    Tool5Node = '$PROC_PREFIX$tool5@$LINE_IP$'
    Tool6Node = '$PROC_PREFIX$tool6@$LINE_IP$'
    ShareMap1Node = '$SHARE_SERVERS1$map_share@$SHAREMAP1_IP$'
    ShareMap2Node = '$SHARE_SERVERS2$map_share@$SHAREMAP2_IP$'
    ShareMap3Node = '$SHARE_SERVERS3$map_share@$SHAREMAP3_IP$'
    ShareMap4Node = '$SHARE_SERVERS4$map_share@$SHAREMAP4_IP$'
    ServerToolNode = '$PROC_PREFIX$servercontrol@$LINE_IP$'
    
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
		
    PortMin = '$MIN_PORT$'
    PortMax = '$MAX_PORT$'
    Curpwd = os.getcwd()
    LogPath = Curpwd.replace('ebin','log/*.log')
    BackupPath = Curpwd.replace('ebin','backup/')
    MonitorString = 'platform:$PLATFORM$\r\nsid:$SERVERID$\r\nlog:'+LogPath+'\r\nbackup:'+BackupPath+'\r\n'
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
        if string_include(current_ips,'$LINE_IP$'):
            run_app('line',LineNode,LineNode,PortMin,PortMax)
            MonitorString += 'node:'+LineNode +'\r\n'
#timer 
        if string_include(current_ips,'$TIMER_IP$'):
            run_app('timer',LineNode,TimerNode,PortMin,PortMax)
            MonitorString += 'node:'+TimerNode +'\r\n'
#db
        if Clear!='' or Regen!='':
            if string_include(current_ips,'$DB_IP$'):
                run_at_shell('db',LineNode,DbNode,PortMin,PortMax)
        else:
            if string_include(current_ips,'$DB_IP$'):
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
             #gate1
            if string_include(current_ips,'$GATE1_IP$'):
                run_app('gate1',LineNode,Gate1Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate1Node +'\r\n'
                print 'Now starting gate1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate2
            if string_include(current_ips,'$GATE2_IP$'):
                run_app('gate2',LineNode,Gate2Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate2Node +'\r\n'
                print 'Now starting gate2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate3
            if string_include(current_ips,'$GATE3_IP$'):
                run_app('gate3',LineNode,Gate3Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate3Node +'\r\n'
                print 'Now starting gate3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate4
            if string_include(current_ips,'$GATE4_IP$'):
                run_app('gate4',LineNode,Gate4Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate4Node +'\r\n'
                print 'Now starting gate4 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate5
            if string_include(current_ips,'$GATE5_IP$'):
                run_app('gate5',LineNode,Gate5Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate5Node +'\r\n'
                print 'Now starting gate5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #gate6
            if string_include(current_ips,'$GATE6_IP$'):
                run_app('gate6',LineNode,Gate6Node,PortMin,PortMax)
                MonitorString += 'node:'+Gate6Node +'\r\n'
                print 'Now starting gate6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #guild
            if string_include(current_ips,'$GUILD_IP$'):
                run_app('guild',LineNode,GuildNode,PortMin,PortMax)
                MonitorString += 'node:'+GuildNode +'\r\n'
                print 'Now starting guild node ...'
                #os.system('read -n 1')
                time.sleep(1)                
            #cross
            if NoCross!='':
                print 'ignor cross node ...'
            else:
                if string_include(current_ips,'$CROSS_IP$'):
                    run_app('cross',LineNode,CrossNode,PortMin,PortMax)
                    
            #auth        
            if string_include(current_ips,'$AUTH_IP$'):
                run_app('auth',LineNode,AuthNode,PortMin,PortMax)
                MonitorString += 'node:'+AuthNode +'\r\n'
            #gm
            if string_include(current_ips,'$GM_IP$'):
                run_app('gm',LineNode,GmNode,PortMin,PortMax)
                MonitorString += 'node:'+GmNode +'\r\n'
            #chat1
            if string_include(current_ips,'$CHAT1_IP$'):
                run_app('chat1',LineNode,Chat1Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat1Node +'\r\n'
                print 'Now starting chat1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #chat2
            if string_include(current_ips,'$CHAT2_IP$'):
                run_app('chat2',LineNode,Chat2Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat2Node +'\r\n'
                print 'Now starting chat2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat3
            if string_include(current_ips,'$CHAT3_IP$'):
                run_app('chat3',LineNode,Chat3Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat3Node +'\r\n'
                print 'Now starting chat3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat4
            if string_include(current_ips,'$CHAT4_IP$'):
                run_app('chat4',LineNode,Chat4Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat4Node +'\r\n'
                print 'Now starting chat4 node ...'
                #os.system('read -n 1')
                time.sleep(1)

            #chat5
            if string_include(current_ips,'$CHAT5_IP$'):
                run_app('chat5',LineNode,Chat5Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat5Node +'\r\n'
                print 'Now starting chat5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #chat6
            if string_include(current_ips,'$CHAT6_IP$'):
                run_app('chat6',LineNode,Chat6Node,PortMin,PortMax)
                MonitorString += 'node:'+Chat6Node +'\r\n'
                print 'Now starting chat6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
                
            #map1
            if string_include(current_ips,'$MAP1_IP$'):
                run_app('map1',LineNode,Map1Node,PortMin,PortMax)
                MonitorString += 'node:'+Map1Node +'\r\n'
                print 'Now starting map1 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map2
            if string_include(current_ips,'$MAP2_IP$'):
                run_app('map2',LineNode,Map2Node,PortMin,PortMax)
                MonitorString += 'node:'+Map2Node +'\r\n'
                print 'Now starting map2 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map3
            if string_include(current_ips,'$MAP3_IP$'):
                run_app('map3',LineNode,Map3Node,PortMin,PortMax)
                MonitorString += 'node:'+Map3Node +'\r\n'
                print 'Now starting map3 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map4
            if string_include(current_ips,'$MAP4_IP$'):
                run_app('map4',LineNode,Map4Node,PortMin,PortMax)
                MonitorString += 'node:'+Map4Node +'\r\n'
                print 'Now starting map4 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map5
            if string_include(current_ips,'$MAP5_IP$'):
                run_app('map5',LineNode,Map5Node,PortMin,PortMax)
                MonitorString += 'node:'+Map5Node +'\r\n'
                print 'Now starting map5 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map6
            if string_include(current_ips,'$MAP6_IP$'):
                run_app('map6',LineNode,Map6Node,PortMin,PortMax)
                MonitorString += 'node:'+Map6Node +'\r\n'
                print 'Now starting map6 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map7
            if string_include(current_ips,'$MAP7_IP$'):
                run_app('map7',LineNode,Map7Node,PortMin,PortMax)
                MonitorString += 'node:'+Map7Node +'\r\n'
                print 'Now starting map7 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map8
            if string_include(current_ips,'$MAP8_IP$'):
                run_app('map8',LineNode,Map8Node,PortMin,PortMax)
                MonitorString += 'node:'+Map8Node +'\r\n'
                print 'Now starting map8 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map9
            if string_include(current_ips,'$MAP9_IP$'):
                run_app('map9',LineNode,Map9Node,PortMin,PortMax)
                MonitorString += 'node:'+Map9Node +'\r\n'
                print 'Now starting map9 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map10
            if string_include(current_ips,'$MAP10_IP$'):
                run_app('map10',LineNode,Map10Node,PortMin,PortMax)
                MonitorString += 'node:'+Map10Node +'\r\n'
                print 'Now starting map10 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map11
            if string_include(current_ips,'$MAP11_IP$'):
                run_app('map11',LineNode,Map11Node,PortMin,PortMax)
                MonitorString += 'node:'+Map11Node +'\r\n'
                print 'Now starting map11 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map12
            if string_include(current_ips,'$MAP12_IP$'):
                run_app('map12',LineNode,Map12Node,PortMin,PortMax)
                MonitorString += 'node:'+Map12Node +'\r\n'
                print 'Now starting map12 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map13
            if string_include(current_ips,'$MAP13_IP$'):
                run_app('map13',LineNode,Map13Node,PortMin,PortMax)
                MonitorString += 'node:'+Map13Node +'\r\n'
                print 'Now starting map13 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map14
            if string_include(current_ips,'$MAP14_IP$'):
                run_app('map14',LineNode,Map14Node,PortMin,PortMax)
                MonitorString += 'node:'+Map14Node +'\r\n'
                print 'Now starting map14 node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share1
            if string_include(current_ips,'$SHAREMAP1_IP$'):
                run_hidden_app('$SHARE_SERVERS1$map_share',LineNode,ShareMap1Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap1Node +'\r\n'
                print 'Now starting $SHARE_SERVERS1$map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share2
            if string_include(current_ips,'$SHAREMAP2_IP$'):
                run_hidden_app('$SHARE_SERVERS2$map_share',LineNode,ShareMap2Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap2Node +'\r\n'
                print 'Now starting $SHARE_SERVERS2$map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share3
            if string_include(current_ips,'$SHAREMAP3_IP$'):
                run_hidden_app('$SHARE_SERVERS3$map_share',LineNode,ShareMap3Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap3Node +'\r\n'
                print 'Now starting $SHARE_SERVERS3$map_share node ...'
                #os.system('read -n 1')
                time.sleep(1)
            #map_share4
            if string_include(current_ips,'$SHAREMAP4_IP$'):
                run_hidden_app('$SHARE_SERVERS4$map_share',LineNode,ShareMap4Node,PortMin,PortMax)
                MonitorString += 'node:'+ShareMap4Node +'\r\n'
                print 'Now starting $SHARE_SERVERS4$map_share node ...'
                #os.system('read -n 1')

            MonitorFilePath = '/var/monitor/node_monitor_$SERVERID$.option'
	    if not os.path.exists('/var/monitor'):
                os.makedirs('/var/monitor')
            gen_file(MonitorFilePath,MonitorString)
