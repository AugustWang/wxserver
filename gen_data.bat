cd ebin
erl -name db@127.0.0.1 -noshell -s config_db run -s init stop
xcopy Mnesia.db@127.0.0.1 ..\dbfile\
rd /s /q Mnesia.db@127.0.0.1
cd ..
pause