Startup web server
inets:start().
{ok, Pid} = inets:start(httpd, [{proplist_file,"httpd.conf"}]).
ok = inets:stop(httpd, Pid).

Browse
http://localhost:8080/scripts/scripts/test?a=123&b=22