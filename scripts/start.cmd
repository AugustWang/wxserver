cd /d %0/..

echo off
call localipv4.cmd

echo generating the node.option
rem echo [{pre_connect_nodes,['line@%IP%','timer@%IP%','db@%IP%','guild@%IP%','auth@%IP%','gm@%IP%','chat1@%IP%','map1@%IP%','map2@%IP%','gate1@%IP%','gate2@%IP%']}].> ../option/node.option
echo [{pre_connect_nodes,['line@%IP%','timer@%IP%','db@%IP%','guild@%IP%','auth@%IP%','gm@%IP%','chat1@%IP%','map1@%IP%','map2@%IP%','gate1@%IP%']}].> ../option/node.option

set linehost=%IP%
set dbhost=%IP%
set gmhost=%IP%
set maphost=%IP%
set gatehost=%IP%
set timerhost=%IP%
set authhost=%IP%
set guildhost=%IP%
set crosshost=%IP%
set chathost=%IP%

set sleep_dur=1

start cmd.exe /k python start.py  --linecenter %linehost%  --timer %timerhost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --db %dbhost% 

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --line %linehost% 

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --map1 %maphost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --map2 %maphost% 

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --gate1  %gatehost% 

rem call wait_time %sleep_dur%
rem start cmd.exe /k python start.py  --linecenter %linehost%  --gate2  %gatehost% 

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --chat1 %chathost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --cross %crosshost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --guild %guildhost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --gm %gmhost%

call wait_time %sleep_dur%
start cmd.exe /k python start.py  --linecenter %linehost%  --auth %authhost%



