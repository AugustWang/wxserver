cd /d %0/..
call localipv4.cmd
cd ../ebin
erl.exe -name dialyzer@%IP% -s dialyzer_util usage
pause