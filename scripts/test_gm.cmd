cd /d %0/..
call localipv4.cmd
start start_line.cmd
start start_db.cmd 
start start_gm.cmd
start start_auth.cmd

cd ../ebin
%erlexe% -name gm_client@%IP% -s test_gm_client start_link

pause