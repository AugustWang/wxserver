#!/usr/bin/env python
import os
import sys
import options
import string
import re
    
def gen_file(filename,content):
    if not os.path.exists(filename):
        open(filename, 'w').close()
        
    fd = open(filename, 'r+')
    fd.truncate()
    fd.write(content)
    fd.close()

def makenodename(OldStr,ServerPrefix,Node,Ip):
    if Ip != '' and Ip != '0':
        if OldStr != '':
            return OldStr + ',' + '\'' + ServerPrefix + Node + '@' + Ip + '\''
        else:
            return  '\'' + ServerPrefix + Node + '@' + Ip + '\''
    else:
        return OldStr
            

opt =options.Options(sys.argv)
##process every node
str_content = ''

server_prefix = opt.get_value('-prefix')[0]

lineip  = opt.get_value('-line')[0]
str_content = makenodename(str_content,server_prefix,'line',lineip)       
timerip = opt.get_value('-timer')[0]
str_content = makenodename(str_content,server_prefix,'timer',timerip)   
dbip = opt.get_value('-db')[0]
str_content = makenodename(str_content,server_prefix,'db',dbip)
guildip = opt.get_value('-guild')[0]
str_content = makenodename(str_content,server_prefix,'guild',guildip)
authip  = opt.get_value('-auth')[0]
str_content = makenodename(str_content,server_prefix,'auth',authip)
gmip = opt.get_value('-gm')[0]
str_content = makenodename(str_content,server_prefix,'gm',gmip)
chat1ip = opt.get_value('-chat1')[0]
str_content = makenodename(str_content,server_prefix,'chat1',chat1ip)
chat2ip = opt.get_value('-chat2')[0]
str_content = makenodename(str_content,server_prefix,'chat2',chat2ip)
chat3ip = opt.get_value('-chat3')[0]
str_content = makenodename(str_content,server_prefix,'chat3',chat3ip)
chat4ip = opt.get_value('-chat4')[0]
str_content = makenodename(str_content,server_prefix,'chat4',chat4ip)
chat5ip = opt.get_value('-chat5')[0]
str_content = makenodename(str_content,server_prefix,'chat5',chat5ip)
chat6ip = opt.get_value('-chat6')[0]
str_content = makenodename(str_content,server_prefix,'chat6',chat6ip)

map1ip = opt.get_value('-map1')[0]
str_content = makenodename(str_content,server_prefix,'map1',map1ip)
map2ip = opt.get_value('-map2')[0]
str_content = makenodename(str_content,server_prefix,'map2',map2ip)
map3ip = opt.get_value('-map3')[0]
str_content = makenodename(str_content,server_prefix,'map3',map3ip)
map4ip = opt.get_value('-map4')[0]
str_content = makenodename(str_content,server_prefix,'map4',map4ip)
map5ip = opt.get_value('-map5')[0]
str_content = makenodename(str_content,server_prefix,'map5',map5ip)
map6ip = opt.get_value('-map6')[0]
str_content = makenodename(str_content,server_prefix,'map6',map6ip)
map7ip = opt.get_value('-map7')[0]
str_content = makenodename(str_content,server_prefix,'map7',map7ip)
map8ip = opt.get_value('-map8')[0]
str_content = makenodename(str_content,server_prefix,'map8',map8ip)

map9ip = opt.get_value('-map9')[0]
str_content = makenodename(str_content,server_prefix,'map9',map9ip)
map10ip = opt.get_value('-map10')[0]
str_content = makenodename(str_content,server_prefix,'map10',map10ip)
map11ip = opt.get_value('-map11')[0]
str_content = makenodename(str_content,server_prefix,'map11',map11ip)
map12ip = opt.get_value('-map12')[0]
str_content = makenodename(str_content,server_prefix,'map12',map12ip)
map13ip = opt.get_value('-map13')[0]
str_content = makenodename(str_content,server_prefix,'map13',map13ip)
map14ip = opt.get_value('-map14')[0]
str_content = makenodename(str_content,server_prefix,'map14',map14ip)

gate1ip= opt.get_value('-gate1')[0]
str_content = makenodename(str_content,server_prefix,'gate1',gate1ip)
gate2ip= opt.get_value('-gate2')[0]
str_content = makenodename(str_content,server_prefix,'gate2',gate2ip)
gate3ip= opt.get_value('-gate3')[0]
str_content = makenodename(str_content,server_prefix,'gate3',gate3ip)
gate4ip= opt.get_value('-gate4')[0]
str_content = makenodename(str_content,server_prefix,'gate4',gate4ip)
gate5ip= opt.get_value('-gate5')[0]
str_content = makenodename(str_content,server_prefix,'gate5',gate5ip)
gate6ip= opt.get_value('-gate6')[0]
str_content = makenodename(str_content,server_prefix,'gate6',gate6ip)


mapshareserver1 = ''
mapshare1ip = opt.get_value('-mapshare1')[0]
if mapshare1ip != '':
    mapshareserver1 = opt.get_value('-mapshare1')[1]
    str_content = makenodename(str_content,mapshareserver1,'map_share',mapshare1ip)

mapshareserver2 = ''
mapshare2ip = opt.get_value('-mapshare2')[0]
if mapshare2ip != '':
    mapshareserver2 = opt.get_value('-mapshare2')[1]
    str_content = makenodename(str_content,mapshareserver2,'map_share',mapshare2ip)
	
mapshareserver3 = ''
mapshare3ip = opt.get_value('-mapshare3')[0]
if mapshare3ip != '':
    mapshareserver3 = opt.get_value('-mapshare3')[1]
    str_content = makenodename(str_content,mapshareserver3,'map_share',mapshare3ip)
	
mapshareserver4 = ''
mapshare4ip = opt.get_value('-mapshare4')[0]
if mapshare4ip != '':
    mapshareserver4 = opt.get_value('-mapshare4')[1]
    str_content = makenodename(str_content,mapshareserver4,'map_share',mapshare4ip)

str_content = '[{pre_connect_nodes,['+str_content +']}].'

gen_file('../option/node.option',str_content)

