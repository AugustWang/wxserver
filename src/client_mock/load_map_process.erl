%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-6
%% Description: TODO: Add description to load_map
-module(load_map_process).
-behaviour(gen_server).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start_link/0]).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).
-record(state,{}).
-define(MAPLIST,[100,200,300,500,600,700,1000,1300,1400,333]).
%% -define(MAPLIST,[100,600,300]).

%%
%% API Functions
%%

start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

init([])->
	MapIDs =?MAPLIST,
	lists:foreach(fun(MapId)->
						  MapDb = load_map_op:make_db_name(MapId),
						  case ets:info(MapDb) of
							  undefined->
								  ets:new(MapDb,[set,named_table]),
								  load_map_op:load_map_file(MapId, MapDb);
							  _->
								  nothing
						  end
				  end,MapIDs),	
	{ok,#state{}}.

handle_call(_Request,_From,State)->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State)->
	{call_robot,Index}=_Msg,
	robot:test_i("192.168.1.251",Index,1,8001,100,40,10,1),
	{noreply,State}.

handle_info(_Info,State)->
	{noreply,State}.
terminate(_Reason,_State)->
	ok.

code_change(_OldVsn,State,_Extra)->
	{ok,State}.


%%
%% Local Functions
%%

