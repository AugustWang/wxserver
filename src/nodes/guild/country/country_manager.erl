%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-4
%% Description: TODO: Add description to country_manager
-module(country_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("country_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-compile(export_all).
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================

%%
%%send 
%%
change_country_notice(RoleId,Notice)->
	global_util:send(?MODULE, {change_country_notice,{RoleId,Notice}}).
	
country_leader_promotion(Post,PostIndex,OtherRoelInfo,RoleId)->
	global_util:send(?MODULE, {country_leader_promotion,{Post,PostIndex,OtherRoelInfo,RoleId}}).
	
country_leader_demotion(Post,PostIndex,RoleId)->
	global_util:send(?MODULE, {country_leader_demotion,{Post,PostIndex,RoleId}}).

change_king_and_bestguild(RoleId,GuildId,GuildName)->
	global_util:send(?MODULE, {change_king_and_bestguild,{RoleId,GuildId,GuildName}}).

init_client_country(RoleId)->
	global_util:send(?MODULE, {init_client_country,RoleId}).

change_leader_name(RoleId,NewName)->
	global_util:send(?MODULE, {change_leader_name,{RoleId,NewName}}).

change_guild_name(GuildId,NewNameStr)->
	global_util:send(?MODULE, {change_guild_name,{GuildId,NewNameStr}}).

%%
%%call 
%%
check_country_leader_right(Type,RoleId)->
	global_util:call(?MODULE, {check_country_leader_right,{Type,RoleId}}).

member_online(RoleInfo)->
	global_util:call(?MODULE, {member_online,RoleInfo}).

get_bestguild()->
	global_util:call(?MODULE, {get_bestguild}).

reg_king_statue(Pid,Node)->
	global_util:call(?MODULE, {reg_king_statue,{Pid,Node}}).

%%
%% return [] | {x,y,z} = now()
%%
get_leader_items(RoleId,Level)->
	global_util:call(?MODULE, {get_leader_items,{RoleId,Level}}).

%%
%% return ok | alreay_get | less_time | error
%%
get_leader_ever_reward(RoleId)->
	global_util:call(?MODULE, {get_leader_ever_reward,RoleId}).	

get_king_roleid()->
	global_util:call(?MODULE, {get_king_roleid}).
	
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: start_link/1
%% Description: start server
%% --------------------------------------------------------------------
start_link(Args) ->
	slogger:msg("countrymgr start~n"),
	gen_server:start_link({local,?MODULE}, ?MODULE, Args, []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init(_Args) ->	
    slogger:msg("countrymgr init~n"),
	try    
    	country_manager_op:init()
	catch
		E:R->
			slogger:msg("init E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()])
	end,
	{ok, #state{}}.
		
handle_call({check_country_leader_right,{Type,RoleId}},_From,State)->
	Reply =
		try
			country_manager_op:check_leader_right(Type,RoleId)
		catch
			E:R->
				slogger:msg("check_country_leader_right E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				?ERRNO_NO_RIGHT
		end,
	{reply, Reply, State};

handle_call({member_online,RoleInfo},_From,State)->
	Reply =
		try
			country_manager_op:member_online(RoleInfo)
		catch
			E:R->
				slogger:msg("member_online E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				{?POST_COMMON,{0,0}}
		end,
	{reply, Reply, State};

handle_call({get_bestguild},_From,State)->
	Reply = 
		try
			country_manager_op:get_bestguild()
		catch
			E:R->
				slogger:msg("get_bestguild E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				{0,0}
		end,
	{reply, Reply, State};

handle_call({reg_king_statue,{Pid,Node}},_From,State)->
	Reply =
		try
			country_manager_op:reg_king_statue(Pid,Node)
		catch
			E:R->
				slogger:msg("reg_king_statue E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				[]
		end,
	{reply, Reply, State};

handle_call({get_leader_items,{RoleId,Level}},_From,State)->
	Reply =
		try
			country_manager_op:get_leader_items(RoleId,Level)
		catch
			E:R->
				slogger:msg("get_leader_items E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				[]
		end,
	{reply, Reply, State};

handle_call({get_leader_ever_reward,RoleId},_From,State)->
	Reply =
		try
		 	country_manager_op:get_leader_ever_reward(RoleId)
		catch
			E:R->
				slogger:msg("get_leader_ever_reward E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				error
		end,
	{reply, Reply, State};

handle_call({get_king_roleid},_From,State)->
	Reply =
		try
		 	country_manager_op:get_king_roleid()
		catch
			E:R->
				slogger:msg("get_king_roleid E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()]),
				error
		end,
	{reply, Reply, State};
			     
handle_call(_Request,_From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------		
handle_info({change_country_notice,{RoleId,Notice}},State)->
	catch country_manager_op:change_notice(RoleId,Notice) ,
	{noreply, State};	
		
handle_info({country_leader_promotion,{Post,PostIndex,OtherInfo,RoleId}},State)->
	catch country_manager_op:leader_promotion(Post,PostIndex,OtherInfo,RoleId),
	{noreply, State};
	
handle_info({country_leader_demotion,{Post,PostIndex,RoleId}},State)->
	catch country_manager_op:leader_demotion(Post,PostIndex,RoleId),
	{noreply, State};

handle_info({change_king_and_bestguild,{RoleId,GuildId,GuildName}},State)->
	catch country_manager_op:change_king_and_bestguild(RoleId,GuildId,GuildName),
	{noreply, State};

handle_info({init_client_country,RoleId},State)->
	catch country_manager_op:init_client_country(RoleId),
	{noreply, State};

handle_info({change_leader_name,{RoleId,NewName}},State)->
	catch country_manager_op:change_leader_name(RoleId,NewName),
	{noreply, State};

handle_info({change_guild_name,{GuildId,NewName}},State)->
	catch country_manager_op:change_guild_name(GuildId,NewName),
	{noreply, State};
				     			     			     	
handle_info(Info, State) ->
	slogger:msg("country_manager handle_info error:~p~n", [Info]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("~p~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State,_Extra) ->
    {ok, State}.


