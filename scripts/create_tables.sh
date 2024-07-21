#!/bin/bash

NODE=lszm_db@127.0.0.1
DBDIR=../dbfile
EBINDIR=../ebin

erl  -mnesia dump_log_write_threshold 50000 -mnesia dc_dump_limit 40 -mnesia dir "\"$DBDIR\"" -name $NODE -pa $EBINDIR -noshell -s config_db run -s init stop
echo "如果需要查询数据，请手动复制下面的命令并执行之"
echo "erl -mnesia dir '\"$DBDIR\"' -name $NODE -pa $EBINDIR"
