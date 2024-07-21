cd /d %0/..
cd ..\ebin
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v Recompile /t REG_SZ /d "erl.exe -pa \"%CD%\"  -noinput -detached -s  recompile start" /f
pause