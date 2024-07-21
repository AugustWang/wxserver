echo please input: data_gen:start().

cd /d %0/..
call localipv4.cmd
set host=%IP%

del  /s /q /f ..\dbfile
del  /s /q /f ..\dbfile1

set host=%IP%

del  /s /q /f ..\ebin\Mnesia.map1@%host%
del  /s /q /f ..\ebin\Mnesia.map2@%host%
del  /s /q /f ..\ebin\Mnesia.gate1@%host%
del  /s /q /f ..\ebin\Mnesia.gate2@%host%
del  /s /q /f ..\ebin\Mnesia.auth@%host%
del  /s /q /f ..\ebin\Mnesia.chat1@%host%
del  /s /q /f ..\ebin\Mnesia.line@%host%
del  /s /q /f ..\ebin\Mnesia.guild@%host%
del  /s /q /f ..\ebin\Mnesia.gm@%host%
pause

cd ../scripts
set sleep_dur=1
start cmd.exe /k start.py  --linecenter %host% --db %host% 
ping 127.0.0.1 -n %sleep_dur% > nul
start cmd.exe /k start.py  --linecenter %host% --timer %host%
ping 127.0.0.1 -n %sleep_dur% > nul
pause

