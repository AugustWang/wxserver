#!/usr/bin/env python
#coding:utf-8
#生成配置文件
#参数 make_option.py --pf [platform] --sid [serverid] --type [new|other] --gp [gateport] 
#platform 平台参数 4399|96pk|rising|pptv|tw|360|51play|57k|xjwa|kuwo|baidu|renren|8090|qizai|pps|kaikai
#serverid 服务器id
#type 服务器类型 new 新服 other 老服
#步骤
#1.检测参数
#2.根据平台和服务器类型 选择合适的模板文件
#3.替换模板文件中的可变字段
#4.生成gm.option 和 xxx--xx.option

import os
import sys
import options
import string
import re

def replace_bench(input_string,old_string_array,new_string_array):
    temp_string = input_string
    i=0
    for old in old_string_array:
        temp_string = temp_string.replace(old,new_string_array[i])
        i=i+1
    return temp_string

def gen_file(filename,content):
    if not os.path.exists(filename):
        open(filename, 'w').close()      
    fd = open(filename, 'r+')
    fd.truncate()
    fd.write(content)
    fd.close()


    
opt = options.Options(sys.argv)
platform = opt.get_value('-pf')[0]
serverid = opt.get_value('-sid')[0]
typeargv = opt.get_value('-type')
option_type = ''
if typeargv != '':
    option_type = opt.get_value('-type')[0]
else:
    option_type = 'old' 

gateport = 8080
gateportargv = opt.get_value('-gp')
if gateportargv != '':
	gateport = opt.get_value('-gp')[0]



#check platform

if platform == '4399':
    baseid = 0
    if option_type == 'new':
        server_option_template = '4399_new.option.template'
    else:
        server_option_template = '4399.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == '96pk':
    baseid = 2000
    if option_type == 'new':
        server_option_template = '96pk_new.option.template'
    else:
        server_option_template = '96pk.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'rising':
    baseid = 3000
    if option_type == 'new':
        server_option_template = 'rising_new.option.template'
    else:
        server_option_template = 'rising.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'tw':
    baseid = 1000
    if option_type == 'new':
        server_option_template = 'tw_new.option.template'
    else:
        server_option_template = 'tw.option.template'
    gm_option_template = 'gm_tw.option.tempate'
elif platform == 'pptv':
    baseid = 4000
    if option_type == 'new':
        server_option_template = 'pptv_new.option.template'
    else:
        server_option_template = 'pptv.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == '51play':
    baseid = 5000
    if option_type == 'new':
        server_option_template = '51play_new.option.template'
    else:
        server_option_template = '51play.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'xjwa':
    baseid = 6000
    if option_type == 'new':
        server_option_template = 'xjwa_new.option.template'
    else:
        server_option_template = 'xjwa.option.template'
    gm_option_template = 'gm.option.tempate'  
elif platform == '57k':
    baseid = 7000
    if option_type == 'new':
        server_option_template = '57k_new.option.template'
    else:
        server_option_template = '57k.option.template'
    gm_option_template = 'gm.option.tempate'  
elif platform == '360':
    baseid = 8000
    if option_type == 'new':
        server_option_template = '360_new.option.template'
    else:
        server_option_template = '360.option.template'
    gm_option_template = 'gm.option.tempate'  
elif platform == 'kuwo':
    baseid = 9000
    if option_type == 'new':
        server_option_template = 'kuwo_new.option.template'
    else:
        server_option_template = 'kuwo.option.template'
    gm_option_template = 'gm.option.tempate'   
elif platform == '5pk':
    baseid = 10000
    if option_type == 'new':
        server_option_template = '5pk_new.option.template'
    else:
        server_option_template = '5pk.option.template'
    gm_option_template = 'gm.option.tempate'       
elif platform == 'iyouqu':
    baseid = 11000
    if option_type == 'new':
        server_option_template = 'iyouqu_new.option.template'
    else:
        server_option_template = 'iyouqu.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'baidu':
    baseid = 12000
    if option_type == 'new':
        server_option_template = 'baidu_new.option.template'
    else:
        server_option_template = 'baidu.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'renren':
    baseid = 13000
    if option_type == 'new':
        server_option_template = 'renren_new.option.template'
    else:
        server_option_template = 'renren.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == '8090':
    baseid = 14000
    if option_type == 'new':
        server_option_template = '8090_new.option.template'
    else:
        server_option_template = '8090.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'qizai':
    baseid = 15000
    if option_type == 'new':
        server_option_template = 'qizai_new.option.template'
    else:
        server_option_template = 'qizai.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'pps':
    baseid = 16000
    if option_type == 'new':
        server_option_template = 'pps_new.option.template'
    else:
        server_option_template = 'pps.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'kaikai':
    baseid = 17000
    if option_type == 'new':
        server_option_template = 'kaikai_new.option.template'
    else:
        server_option_template = 'kaikai.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'aoyou':
    baseid = 18000
    if option_type == 'new':
        server_option_template = 'aoyou_new.option.template'
    else:
        server_option_template = 'aoyou.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == '51':
    baseid = 19000
    if option_type == 'new':
        server_option_template = '51_new.option.template'
    else:
        server_option_template = '51.option.template'
    gm_option_template = 'gm.option.tempate'
elif platform == 'moka':
    baseid = 20000
    if option_type == 'new':
        server_option_template = 'moka_new.option.template'
    else:
        server_option_template = 'moka.option.template'
    gm_option_template = 'gm_tw.option.tempate'
elif platform == 'jifeng':
    baseid = 21000
    if option_type == 'new':
        server_option_template = 'jifeng_new.option.template'
    else:
        server_option_template = 'jifeng.option.template'
    gm_option_template = 'gm.option.tempate'
else:
    print 'unknown platform %s\n'%(platform)
    exit()

basegmport = 1080

#make server option
option_name = '%s-%s.option'%(platform,serverid)
realsid = int(serverid) + baseid
gmport = basegmport + int(serverid)
sop_temp_path = '../option/%s'%(server_option_template)
gmop_temp_path = '../option/%s'%(gm_option_template)

soptemp_fd = open(sop_temp_path,'r')
sopcontent = soptemp_fd.read()
soptemp_fd.close()

ppsgiftcardsid = int(serverid) + 3950

sopcontent = replace_bench(sopcontent,['$$SERVERID$$','$$GMPORT$$','$$LOGINDEX$$','$$GATEPORT$$','$$PPSGIFTCARDSID$$'],[str(realsid),str(gmport),serverid,gateport,str(ppsgiftcardsid)])
sop_path = '../option/%s'%(option_name)
gen_file(sop_path,sopcontent)

gmoptemp_fd = open(gmop_temp_path,'r')
gmopcontent = gmoptemp_fd.read()
gmoptemp_fd.close()
gmopcontent = replace_bench(gmopcontent,['$$OPTION$$'],[option_name])

gmop_path = '../option/gm.option'
gen_file(gmop_path,gmopcontent)





    
