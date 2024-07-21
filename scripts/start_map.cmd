cd /d %0/..

call localipv4.cmd
set host=%IP%

start.py  --linecenter %host% --map1 %host%

pause
