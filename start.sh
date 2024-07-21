#!/bin/bash
cd ./ebin
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name timer@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -mnesia dir '"../dbfile/"'  -detached -name db@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name line@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true  -smp disable -detached -name map1@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true  -smp disable -detached -name map2@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true  -smp disable -detached -name gate1@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name chat1@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name cross@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name guild@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name gm@127.0.0.1 -s server_tool run --line line@127.0.0.1
ulimit -SHn 65535 && erl +P 100000 +K true   -detached -name auth@127.0.0.1 -s server_tool run --line line@127.0.0.1
