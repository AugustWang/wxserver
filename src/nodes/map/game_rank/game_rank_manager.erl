%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : zhaoyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module(game_rank_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([challenge/3,gather/3,watch_rank/2,get_role_top_types/1,
		 mul_gather/1,watch_roleinfo/3,disdain_role/4,praised_role/4,sync_get_level_rank/1,sync_get_pet_talent_rank/1,pet_lose_rank/1,updata_pet_rank_info/2,
		 get_main_line_rank_top_role/3,on_role_change_name/2]).
  
-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% ====================================================================
%% Server functions
%% ====================================================================
challenge(RoleId,Type,Info)->
	global_util:send(?MODULE, {challenge,RoleId,Type,Info}).

gather(RoleId,Type,Info)->
	global_util:send(?MODULE, {gather,RoleId,Type,Info}).	

mul_gather(GatherList)->
	global_util:send(?MODULE, {mul_gather,GatherList}).

%%Info:Role/{RoleId,Type}
watch_rank(Info,Type)->
	global_util:send(?MODULE,{watch_rank,Info,Type}).

watch_roleinfo(RoleId,Watched_RoleId,Leftnum)->
	global_util:send(?MODULE,{watch_roleinfo,RoleId,Watched_RoleId,Leftnum}).

praised_role(RoleId,Praise_RoleId,LeftNum,MyName)->
	global_util:send(?MODULE,{praised_role,RoleId,Praise_RoleId,LeftNum,MyName}).

disdain_role(RoleId,Disdan_RoleId,LeftNum,MyName)->
	global_util:send(?MODULE,{disdain_role,RoleId,Disdan_RoleId,LeftNum,MyName}).

updata_pet_rank_info(PetId,Info)->
	global_util:send(?MODULE,{updata_pet_rank,PetId,Info}).

pet_lose_rank(PetId)->
	global_util:send(?MODULE,{lose_rank,PetId}).

on_role_change_name(RoleId,NewNameStr)->
	global_util:send(?MODULE,{role_change_name,RoleId,NewNameStr}).

get_main_line_rank_top_role(Chapter,Festival,Difficulty)->
	try
		global_util:call(?MODULE,{get_main_line_rank_top_role,Chapter,Festival,Difficulty})
	catch
		E:R->
			slogger:msg("get_main_line_rank_top_role RoleId ~p ~p ~n",[E,R]),
			[]
	end.

sync_get_pet_talent_rank(PetId)->
	try
		global_util:call(?MODULE,{sync_get_pet_talent_rank,PetId})
	catch
		E:R->
			slogger:msg("sync_get_pet_talent_rank PetId ~p ~p ~p ~n",[PetId,E,R]),
			[]
	end.

get_role_top_types(RoleId)->
	try
		global_util:call(?MODULE,{get_role_top_types,RoleId})
	catch
		E:R->
			slogger:msg("get_role_top_types RoleId ~p ~p ~p ~n",[RoleId,E,R]),
			[]
	end.

sync_get_level_rank(RoleId)->
	try
		global_util:call(?MODULE,{sync_get_level_rank,RoleId})
	catch
		E:R->
			slogger:msg("sync_get_level_rank RoleId ~p ~p ~p ~n",[RoleId,E,R]),
			[]
	end.
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	my_apply(init,[]),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({get_role_top_types,RoleId},_From, State) ->
	Reply = my_apply(get_role_top_types,[RoleId]),
    {reply, Reply, State};

handle_call({get_main_line_rank_top_role,Chapter,Festival,Difficulty},_From, State) ->
	Reply = module_main_line_rank:get_main_line_rank_top_role(Chapter,Festival,Difficulty),
    {reply, Reply, State};

handle_call({sync_get_level_rank,RoleId},_From, State) ->
	Reply = module_level_rank:search_rank(RoleId),
    {reply, Reply, State};

handle_call({sync_get_pet_talent_rank,PetId},_From, State) ->
	Reply = module_pet_talent_score_rank:search_rank(PetId),
    {reply, Reply, State}.
%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({watch_rank,Info,Type},State)->
	my_apply(get_rank_list,[Info,Type]),
	{noreply, State};

handle_info({watch_roleinfo,RoleId,Watched_RoleId,Leftnum},State)->
	my_apply(watch_roleinfo,[RoleId,Watched_RoleId,Leftnum]),
	{noreply, State};

handle_info({praised_role,RoleId,Praise_RoleId,LeftNum,MyName},State)->
	my_apply(praised_role,[RoleId,Praise_RoleId,LeftNum,MyName]),
	{noreply, State};

handle_info({disdain_role,RoleId,Disdan_RoleId,LeftNum,MyName},State)->
	my_apply(disdain_role,[RoleId,Disdan_RoleId,LeftNum,MyName]),
	{noreply, State};

handle_info({gather,RoleId,Type,Info},State)->
	my_apply(gather,[RoleId,Type,Info]),
	{noreply, State};

handle_info({mul_gather,GatherList},State)->
	my_apply(mul_gather,[GatherList]),
	{noreply, State};

handle_info(refresh_rank,State)->
	my_apply(refresh_rank,[]),
	{noreply, State};

handle_info({challenge,RoleId,Type,Info},State)->
	my_apply(challenge,[RoleId,Type,Info]),
	{noreply, State};

handle_info({role_change_name,RoleId,NewNameStr},State)->
	try
		game_rank_manager_op:hook_on_role_change_name(RoleId,NewNameStr)
	catch
		E:R->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({lose_rank,PetId},State)->
	try
		module_pet_talent_score_rank:lose_rank(PetId)
	catch
		E:R->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_info({updata_pet_rank,PetId,Info},State)->
	try
		module_pet_talent_score_rank:updata_rank(PetId,Info)
	catch
		E:R->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			error
	end,
	%åŠ ã€å°äº”ã€‘
	try
		module_pet_growth_rank:updata_rank(PetId,Info)
	catch
		E1:R1->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E1,R1,erlang:get_stacktrace()]),
			error
	end,
	try
		module_pet_fighting_force_rank:updata_rank(PetId,Info)
	catch
		E2:R2->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E2,R2,erlang:get_stacktrace()]),
			error
	end,
	try
		module_pet_quality_value_rank:updata_rank(PetId,Info)
	catch
		E3:R3->
			slogger:msg("game_rank_manager ~p ~p ~p ~n",[E3,R3,erlang:get_stacktrace()]),
			error
	end,
	%åŠ ã€å°äº”ã€‘
	{noreply, State};

handle_info(_, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

my_apply(Fun,Args)->
	try
		erlang:apply(game_rank_manager_op,Fun, Args)
	catch 
		E:R->
		slogger:msg("game_rank_manager ~p ~p ~p ~p ~p ~n",[Fun, Args,E,R,erlang:get_stacktrace()]),
		error
	end.
	

					