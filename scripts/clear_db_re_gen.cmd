echo please input: data_gen:start().
pause

cd /d %0/..
call localipv4.cmd
set host=%IP%

start cmd.exe /k start.py  --linecenter %host% --db %host% 
start cmd.exe /k start.py  --linecenter %host% --line %host%
start cmd.exe /k start.py  --linecenter %host% --timer %host%

pause

