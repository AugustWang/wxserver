cd /d %0/..
call localipv4.cmd
cd ../ebin
werl.exe -name 0001@%IP% -setcookie abc
pause