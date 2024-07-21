cd /d %0/..

call localipv4.cmd
set host=%IP%

start.py  --dbcenter %host% --linecenter %host% --gmcenter %host% --guild %host%

pause
