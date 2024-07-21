#!/usr/bin/env python
import os
import sys

import time

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

temp_fd = open('version.erl.template','r')
content = temp_fd.read()
temp_fd.close()

param = sys.argv[1]

versionstr = time.strftime('%y.%m.%d.%H%M',time.localtime(time.time())) + param

newcontent = replace_bench(content,['$$VERSION_STRING$$'],[versionstr])
newpath = '../src/modules/game/version.erl'
gen_file(newpath,newcontent)
