echo off
IPCONFIG |FIND "IP" |FIND /v "Windows" |FIND /v "v6"> %temp%\TEMPIP.txt
FOR /F "tokens=2 delims=:" %%a in (%temp%\TEMPIP.txt) do set IP=%%a
del %temp%\TEMPIP.txt
rem set IP=%IP:~1%
set IP=127.0.0.1