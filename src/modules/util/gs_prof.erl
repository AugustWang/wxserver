%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-9-16
%% Description: TODO: Add description to gs_prof
-module(gs_prof).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([support/0,start/0,stop/0]).
-export([pids/0,procs/0]).
%%
%% API Functions
%%

-ifdef(DEBUG).
-define(START_PROF,eprof:start()).
-define(START_PROFILING,profiling_all()).
-define(STOP_PROFILING,eprof:stop_profiling(),eprof:log("../log/eprof.log"),eprof:analyze(total)).
-else.
-define(START_PROF,ok).
-define(START_PROFILING,ok).
-define(STOP_PROFILING,ok).
-endif.

start()->
	?START_PROFILING.

stop()->
	?STOP_PROFILING.
profiling_all()->
	Pro = fun(P)->
				  try
					  eprof:start_profiling([P]) 
				  catch
					  _:_->  io:format("~p can not start_profiling ~n",[P])
				  end
	end,
	lists:foreach(Pro,pids()).
	

support()->
	?START_PROF.

%%
%% Local Functions
%%
procs()->
    lists:zf(
      fun(Pid) ->
			  case process_info(Pid) of
				  ProcessInfo when is_list(ProcessInfo) ->
					  CurrentFunction = current_function(ProcessInfo),
					  InitialCall = initial_call(ProcessInfo),
					  RegisteredName = registered_name(ProcessInfo),
					  Ancestor = ancestor(ProcessInfo),
					  case filter_pid(Pid, CurrentFunction, InitialCall, RegisteredName, Ancestor) of
						  {true,_Pid}-> {true,RegisteredName};
						  false-> false
					  end;
				  _ ->
					  false
			  end
	        end,
	  processes()).
	


pids() ->
    lists:zf(
      fun(Pid) ->
			  case process_info(Pid) of
				  ProcessInfo when is_list(ProcessInfo) ->
					  CurrentFunction = current_function(ProcessInfo),
					  InitialCall = initial_call(ProcessInfo),
					  RegisteredName = registered_name(ProcessInfo),
					  Ancestor = ancestor(ProcessInfo),
					  filter_pid(Pid, CurrentFunction, InitialCall, RegisteredName, Ancestor);
				  _ ->
					  false
			  end
	        end,
	  processes()).

current_function(ProcessInfo) ->
    {value, {_, {CurrentFunction, _,_}}} =
	lists:keysearch(current_function, 1, ProcessInfo),
    atom_to_list(CurrentFunction).

initial_call(ProcessInfo) ->
    {value, {_, {InitialCall, _,_}}} =
	lists:keysearch(initial_call, 1, ProcessInfo),
    atom_to_list(InitialCall).

registered_name(ProcessInfo) ->
    case lists:keysearch(registered_name, 1, ProcessInfo) of
	{value, {_, Name}} when is_atom(Name) -> atom_to_list(Name);
	_ -> ""
    end.

ancestor(ProcessInfo) ->
    {value, {_, Dictionary}} = lists:keysearch(dictionary, 1, ProcessInfo),
    case lists:keysearch('$ancestors', 1, Dictionary) of
	{value, {_, [Ancestor|_T]}} when is_atom(Ancestor) ->
	    atom_to_list(Ancestor);
	_ ->
	    ""
    end.

filter_pid(Pid, _CurrentFunction, _InitialCall, "chat_"++_, _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "gm_"++_, _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "zygmagent_"++_, _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "dbslave", _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "dbmaster", _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "dbchecker", _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "map_" ++ _, _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "npc_" ++ _, _Ancestor) ->
    {true, Pid};
filter_pid(Pid, _CurrentFunction, _InitialCall, "zyagent_" ++ _, _Ancestor) ->
    {true, Pid};
filter_pid(_Pid, _CurrentFunction, _InitialCall, _RegisteredName, _Ancestor) ->
    false.
