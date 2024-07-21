%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(map_travel_deamon_op).

-compile(export_all).


-define(CHECK_INTERVAL,5000).
-define(CHECK_TIMES,20).

init()->
	do_check(?CHECK_TIMES).	
	
	
do_check_interval(Index)->	
	erlang:send_after(?CHECK_INTERVAL,self(), {check_interval,Index}).

do_check(Index)->
	if
		Index =< 0->
			true;
		true->
			[LineNode|_] = node_util:get_linenodes(),
			AllNodes = rpc:call(LineNode, erlang, nodes,[]),
			lists:map(fun(Node)-> ping_center:ping(Node) end, AllNodes),
			do_check_interval(Index - 1 ),
			false
	end.
