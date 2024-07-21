cd /d %0/..

call localipv4.cmd
set host=%IP%

start.py  --dbcenter %host% --linecenter %host% --gmcenter %host% --map2 %host%

pause
