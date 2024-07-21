ECHO on

rem cd /d %~f0/..
rem call localipv4.cmd
rem echo generating the node.option
rem echo [{pre_connect_nodes,['line@%IP%','timer@%IP%','db@%IP%','guild@%IP%','auth@%IP%','gm@%IP%','chat1@%IP%','map1@%IP%','map2@%IP%','gate1@%IP%','gate2@%IP%']}].> ../option/node.option
rem 
rem cd /d %~f0/..
rem 
rem 
rem set PROTO_PATH=..\..\..\common\proto
rem 
rem call ../../../tools/ei_compiler/erlang.cmd
rem 
rem 
rem cd /d %~f0/..
rem 
rem cd ..\scripts

copy Emakefile.win Emakefile

escript.exe erl_make.erl

pause
