cd /d %0/..
call localipv4.cmd
set host=%IP%

cd ../ebin

werl.exe  -name tool1@%host% --line line@%host%  -s server_tool run