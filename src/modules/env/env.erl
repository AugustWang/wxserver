%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-16
%% Description: TODO: Add description to env
-module(env).

%%
%% Include files
%%
-define(OPTION_FILE,"../option/game_server.option").
-define(GM_OPTION,"../option/gm.option").
-define(SERVER_START_TIME,"../option/server_start_time.option").

-define(OPTION_ETS,option_value_ets).
-define(SERVER_NAME_ETS,option_servers_name).
-define(SERVER_NAME_FILE,"../option/server_name.option").
-define(NODE_OPTION_FILE,"../option/node.option").


%%
%% Exported Functions
%%

-export([get_env/2,get/2,get2/3,put/2,put2/3,get_tuple2/3,get_server_name/1]).
-export([init/0,fresh/0]).
%%
%% API Functions
%%

%%
%% Local Functions
%%

get_env(Opt, Default) ->
	case application:get_env(Opt) of
		{ok, Val} ->  Val;
		_ -> Default
	end.

init()->
	try
		ets:new(?OPTION_ETS, [named_table,public ,set])
	catch
		_:_-> ignor
	end,
	try
		ets:new(?SERVER_NAME_ETS, [named_table,public ,set])
	catch
		_:_-> ignor
	end,
	fresh().

read_from_file(File,Ets)->
	case file:consult(File) of
		{ok, [Terms]} ->
			lists:foreach(fun(Term)->
								  ets:insert(Ets, Term)
						  end, Terms);
		{error, Reason} -> 
			slogger:msg("load option file [~p] Error ~p",[File,Reason]) ,	
			{error, Reason}
	end.

get_server_name(ServerId)->
	try
		case ets:lookup(?SERVER_NAME_ETS, ServerId) of
			[]-> [];
			[{ServerId,ServerName}]-> ServerName
		end
	catch
		E:R->
			slogger:msg("get_server_name error !!!!!!!!! ServerId ~p R ~p  ~p ~n",[ServerId,R,erlang:get_stacktrace()]),
			[]
	end.

	

get(Key,Default)->
	try
		case ets:lookup(?OPTION_ETS, Key) of
			[]-> Default;
			[{_,Value}]->Value
		end
	catch
		E:R->
			slogger:msg("env get error !!!!!!!!! Key ~p R ~p  ~p ~n",[Key,R,erlang:get_stacktrace()]),
			Default
	end.

get2(Key,Key2,Default)->
	case get(Key,[]) of
		[]->Default;
		Value-> case lists:keyfind(Key2, 1, Value) of
					false-> Default;
					{_Key2,Value2}-> Value2
				end
	end.

get_tuple2(Key,Key2,Default)->
	case get(Key,[]) of
		[]->Default;
		Value-> case lists:keyfind(Key2, 1, Value) of
					false-> Default;
					Tuple-> Tuple
				end
	end.

put(Key,Value)->
	ets:insert(?OPTION_ETS, {Key,Value}).

put2(Key,Key2,Value)->
	OldValue = get(Key,[{Key2,Value}]),
	NewValue = lists:keyreplace(Key2, 1, OldValue, {Key2,Value}),
	ets:insert(?OPTION_ETS, {Key,NewValue}).

fresh()->
	ets:delete_all_objects(?OPTION_ETS),
	ets:delete_all_objects(?SERVER_NAME_ETS),
	read_from_file(?NODE_OPTION_FILE,?OPTION_ETS),
	read_from_file(?OPTION_FILE,?OPTION_ETS),
	read_from_file(?GM_OPTION,?OPTION_ETS),
	read_from_file(?SERVER_NAME_FILE,?SERVER_NAME_ETS),
	read_from_file(?SERVER_START_TIME,?OPTION_ETS),
	case get(platformfile,"") of
		[]-> ignor;
		FileName->
			read_from_file(FileName,?OPTION_ETS)
	end.
	