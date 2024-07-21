cd /d %0/..

call localipv4.cmd
set host=%IP%

python start.py  --dbcenter %host% --linecenter %host% --gmcenter %host% --timer %host%

pause
