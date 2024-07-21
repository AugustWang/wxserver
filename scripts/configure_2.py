#!/usr/bin/env python
import os
import sys
import options
import string
import re

def gen_file(filename,content):
    print 'filename:', filename
    print 'content:', content
    sys.exit()
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

cwd = os.path.abspath(os.path.split(sys.argv[0])[0])
os.chdir(cwd)
fd = open('start_template_2.py','r')
str_content = fd.read()
fd.close()

opt =options.Options(sys.argv)
##process every node

lineip  = opt.get_value('-line')[0]
timerip = opt.get_value('-timer')[0]
dbip = opt.get_value('-db')[0]
guildip = opt.get_value('-guild')[0]
crossip = opt.get_value('-cross')[0]
authip  = opt.get_value('-auth')[0]
gmip = opt.get_value('-gm')[0]
chat1ip = opt.get_value('-chat1')[0]
chat2ip = opt.get_value('-chat2')[0]
chat3ip = opt.get_value('-chat3')[0]
chat4ip = opt.get_value('-chat4')[0]
chat5ip = opt.get_value('-chat5')[0]
chat6ip = opt.get_value('-chat6')[0]
map1ip = opt.get_value('-map1')[0]
map2ip = opt.get_value('-map2')[0]
map3ip = opt.get_value('-map3')[0]
map4ip = opt.get_value('-map4')[0]
map5ip = opt.get_value('-map5')[0]
map6ip = opt.get_value('-map6')[0]
map7ip = opt.get_value('-map7')[0]
map8ip = opt.get_value('-map8')[0]

map9ip = opt.get_value('-map9')[0]
map10ip = opt.get_value('-map10')[0]
map11ip = opt.get_value('-map11')[0]
map12ip = opt.get_value('-map12')[0]
map13ip = opt.get_value('-map13')[0]
map14ip = opt.get_value('-map14')[0]

gate1ip= opt.get_value('-gate1')[0]
gate2ip= opt.get_value('-gate2')[0]
gate3ip= opt.get_value('-gate3')[0]
gate4ip= opt.get_value('-gate4')[0]
gate5ip= opt.get_value('-gate5')[0]
gate6ip= opt.get_value('-gate6')[0]

minport = opt.get_value('-min_port')[0]
maxport = opt.get_value('-max_port')[0]
server_prefix = opt.get_value('-prefix')[0]

mapshareserver1 = ''
mapshare1ip = opt.get_value('-mapshare1')[0]
if mapshare1ip != '':
		mapshareserver1 = opt.get_value('-mapshare1')[1]

mapshareserver2 = ''
mapshare2ip = opt.get_value('-mapshare2')[0]
if mapshare2ip != '':
	mapshareserver2 = opt.get_value('-mapshare2')[1]
	
mapshareserver3 = ''
mapshare3ip = opt.get_value('-mapshare3')[0]
if mapshare3ip != '':
	mapshareserver3 = opt.get_value('-mapshare3')[1]
	
mapshareserver4 = ''
mapshare4ip = opt.get_value('-mapshare4')[0]
if mapshare4ip != '':
	mapshareserver4 = opt.get_value('-mapshare4')[1]

paltform = opt.get_value('-pf')[0]
serverid = opt.get_value('-sid')[0]


old_str = ['$PROC_PREFIX$','$LINE_IP$','$GUILD_IP$','$TIMER_IP$',
           '$CROSS_IP$','$AUTH_IP$','$GM_IP$','$DB_IP$',
           '$CHAT1_IP$','$CHAT2_IP$','$CHAT3_IP$','$CHAT4_IP$','$CHAT5_IP$','$CHAT6_IP$',
           '$MAP1_IP$','$MAP2_IP$','$MAP3_IP$','$MAP4_IP$','$MAP5_IP$','$MAP6_IP$','$MAP7_IP$','$MAP8_IP$',
           '$MAP9_IP$','$MAP10_IP$','$MAP11_IP$','$MAP12_IP$','$MAP13_IP$','$MAP14_IP$',
           '$GATE1_IP$','$GATE2_IP$','$GATE3_IP$','$GATE4_IP$','$GATE5_IP$','$GATE6_IP$','$MIN_PORT$','$MAX_PORT$',
           '$SHARE_SERVERS1$','$SHAREMAP1_IP$','$SHARE_SERVERS2$','$SHAREMAP2_IP$','$SHARE_SERVERS3$','$SHAREMAP3_IP$','$SHARE_SERVERS4$','$SHAREMAP4_IP$','$PLATFORM$','$SERVERID$']

new_str = [server_prefix,lineip  ,guildip ,timerip ,
           crossip ,authip  ,gmip ,dbip ,
           chat1ip ,chat2ip ,chat3ip ,chat4ip ,chat5ip ,chat6ip ,
           map1ip ,map2ip ,map3ip ,map4ip ,map5ip ,map6ip ,map7ip ,map8ip ,
           map9ip ,map10ip ,map11ip ,map12ip ,map13ip ,map14ip,
           gate1ip,gate2ip,gate3ip,gate4ip,gate5ip,gate6ip,minport,maxport,
           mapshareserver1,mapshare1ip,mapshareserver2,mapshare2ip,
           mapshareserver3,mapshare3ip,mapshareserver4,mapshare4ip,paltform,serverid]

str_content = replace_bench(str_content,old_str,new_str)

gen_file('run.py',str_content)

if sys.platform=='linux3':
    os.system('chmod +x *.py')



#gen stop.py
if server_prefix!='':
    cwd = os.path.abspath(os.path.split(sys.argv[0])[0])
    os.chdir(cwd)
    fd = open('stop_template.py','r')
    str_content = fd.read()
    fd.close()

    old_str = ['$PROC_PREFIX$','$SERVERID$']
    new_str = [server_prefix,serverid]

    str_content = replace_bench(str_content,old_str,new_str)

    gen_file('stop.py',str_content)

    if sys.platform=='linux3':
        os.system('chmod +x *.py')
