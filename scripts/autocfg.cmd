@echo off
cd /d %0/..
call localipv4.cmd

autocfg_2.py --map1ip %IP% 1,2 --gateip %IP% 1