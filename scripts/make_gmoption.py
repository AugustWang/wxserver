#!/usr/bin/env python
#coding:utf-8
#生成配置文件
#参数 make_gmoption.py --pf [platform] --file [filename] 
#platform 平台参数 4399|96pk|rising|pptv|tw|360|51play|57k|xjwa|kuwo|baidu|renren|8090|qizai|pps|kaikai
#filename 
#步骤
#1.检测参数
#2.根据平台和服务器类型 选择合适的模板文件
#3.替换模板文件中的可变字段
#4.生成gm.option

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
filename = opt.get_value('-file')[0]


#check platform

if platform == '4399':
    gm_option_template = 'gm.option.tempate'
elif platform == '96pk':
    gm_option_template = 'gm.option.tempate'
elif platform == 'rising':
    gm_option_template = 'gm.option.tempate'
elif platform == 'tw':
    gm_option_template = 'gm_tw.option.tempate'
elif platform == 'pptv':
    gm_option_template = 'gm.option.tempate'
elif platform == '51play':
    gm_option_template = 'gm.option.tempate'
elif platform == 'xjwa':
    gm_option_template = 'gm.option.tempate'  
elif platform == '57k':
    gm_option_template = 'gm.option.tempate'  
elif platform == '360':
    gm_option_template = 'gm.option.tempate'  
elif platform == 'kuwo':
    gm_option_template = 'gm.option.tempate'   
elif platform == '5pk':
    gm_option_template = 'gm.option.tempate'       
elif platform == 'iyouqu':
    gm_option_template = 'gm.option.tempate'
elif platform == 'baidu':
    gm_option_template = 'gm.option.tempate'
elif platform == 'renren':
    gm_option_template = 'gm.option.tempate'
elif platform == '8090':
    gm_option_template = 'gm.option.tempate'
elif platform == 'qizai':
    gm_option_template = 'gm.option.tempate'
elif platform == 'pps':
    gm_option_template = 'gm.option.tempate'
elif platform == 'kaikai':
    gm_option_template = 'gm.option.tempate'
elif platform == 'aoyou':
    gm_option_template = 'gm.option.tempate'
elif platform == '51':
    gm_option_template = 'gm.option.tempate'
elif platform == 'moka':
    gm_option_template = 'gm_tw.option.tempate'
elif platform == 'jifeng':
    gm_option_template = 'gm.option.tempate'
else:
    print 'unknown platform %s\n'%(platform)
    exit()


gmop_temp_path = '../option/%s'%(gm_option_template)



gmoptemp_fd = open(gmop_temp_path,'r')
gmopcontent = gmoptemp_fd.read()
gmoptemp_fd.close()
gmopcontent = replace_bench(gmopcontent,['$$OPTION$$'],[filename])

gmop_path = '../option/gm.option'
gen_file(gmop_path,gmopcontent)





    
