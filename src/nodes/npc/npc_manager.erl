%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-6-5
%%% -------------------------------------------------------------------
-module(npc_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(NPC_SUP,npc_sup).
-include("common_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/4]).

-export([get_npcinfo/1,get_npcinfo/2, regist_npcinfo/3, unregist_npcinfo/2,gen_npc_id/1,
		make_npc_manager_proc/1,add_npc_by_option/6,remove_npc/2]).

-export([remove_all_npc/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {npc_pid_db,mapid,sup_ref,mapproc}).


%% ====================================================================
%% External functions
%% ====================================================================

add_npc_by_option(NpcManagerProc,NpcId,LineId,MapId,NpcInfo,CreateArg)->
	try
		gen_server:call(NpcManagerProc,{add_npc_by_option,{{LineId,MapId},NpcInfo},NpcId,CreateArg},50000)
	catch
		E:R -> slogger:msg("add_npc_by_option E:R ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),error
	end.

remove_npc(NpcManagerProc,NpcId)->
	try
		NpcManagerProc ! {remove_npc,NpcId}
	catch
		E:R -> slogger:msg("add_npc_by_option E:R ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end.

gen_npc_id(NpcManagerProc)->
	try
		gen_server:call(NpcManagerProc,{gen_npc_id},50000)
	catch
		E:R -> slogger:msg("gen_npc_id E:R ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		0
	end.

remove_all_npc(NpcManagerProc)->
	try
		gen_server:call(NpcManagerProc,remove_all)
	catch
		E:R -> slogger:msg("remove_all_npc E:R ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		nothing
	end.

start_link(MapId,EtsName,MapProcName,SupRef)->
	NpcManagerProc = make_npc_manager_proc(MapProcName),
	gen_server:start_link({local,NpcManagerProc}, ?MODULE , [MapId,EtsName,MapProcName,SupRef], []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 娉ㄥ唽淇℃伅
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 鑾峰彇鍜岃皟鐢ㄨ�呭浜庡悓涓�Node鐨凬pc淇℃伅
get_npcinfo(NpcId) ->
	get_npcinfo(get(npcinfo_db),NpcId).

get_npcinfo(NpcManagerProc,NpcId)->
	case ets:lookup(NpcManagerProc, NpcId) of
		[] ->
			undefined;
		[{_, NpcInfo}] ->
			NpcInfo
	end.

regist_npcinfo(NpcInfoDB, NpcId, NpcInfo) ->
	ets:insert(NpcInfoDB, {NpcId, NpcInfo}).

unregist_npcinfo(NpcInfoDB, NpcId) ->
	ets:delete(NpcInfoDB, NpcId).
	
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([MapId,EtsDB,MapProc,SupRef]) ->
	init_dynamic_npc_ids(),
	MapProc!{npc_manager_join,self(),EtsDB}, 						%%send message to mapproc include ets
	{ok, #state{npc_pid_db=EtsDB,mapid=MapId,sup_ref=SupRef,mapproc=MapProc}}.

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
%%Option = {{LineId,MapId},SpawnNpcInfo} return:error/_
handle_call({add_npc_by_option,Option,NpcId,CreateArg},From,#state{mapid=MapId,sup_ref=SupRef,mapproc=MapProc}=State)->
	Result = 
	try
		npc_sup:add_npc(SupRef,MapProc,NpcId,self(),Option,CreateArg)
	catch
		E:R->
			slogger:msg("add_npc_by_option error ~p R~p ~p~n",[NpcId,R,erlang:get_stacktrace()]),
			error
	end,	
	case Result of
		{error,Error}->
			slogger:msg("add_npc_by_option error ~p R~p~n",[NpcId,Error]),
			error;
		_->
			nothing
	end,	
	{reply,Result, State};

handle_call({gen_npc_id},_From,State)->
	Result = create_new_npc_id(),
	{reply,Result, State};	
	
handle_call(remove_all,_From,#state{npc_pid_db=EtsDB,mapid=MapId,sup_ref=SupRef,mapproc=MapProc}=State)->
	npc_sup:remove_all_npc(SupRef),
	{reply,ok, State};		
	
handle_call(Request, From, State) ->
    Reply = ok,
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
handle_info({remove_npc,NpcId},#state{npc_pid_db=EtsDB,mapid=MapId,sup_ref=SupRef,mapproc=MapProc}=State)->
	try
		npc_sup:delete_npc(SupRef,NpcId),
		recycle_npc_id(NpcId),
		unregist_npcinfo(EtsDB, NpcId)
	catch
		E:R->slogger:msg("remove_npc ~p E~p R~p ~p ~n",[NpcId,E,R,erlang:get_stacktrace()])
	end,
	{noreply, State};
	
handle_info(Info, State) ->
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

make_npc_manager_proc(MapProcName)->
	NpcManager = lists:append(["npc_manager_of_",atom_to_list(MapProcName)]),
	list_to_atom(NpcManager).
	
	
%%private:
init_dynamic_npc_ids()->
	put(dynamic_npc_ids,{?DYNAMIC_NPC_INDEX,[]}).

create_new_npc_id()->
	{Index,UsedIds} = get(dynamic_npc_ids),
	if
		Index < ?DYNAMIC_NPC_INDEX + ?DYNAMIC_NPC_NUM_MAX->
			NewIndex = Index+1,
			case lists:member(NewIndex,UsedIds) of
				false->
					put(dynamic_npc_ids,{NewIndex,[NewIndex|UsedIds]}),
					NewIndex;
				_->
					put(dynamic_npc_ids,{NewIndex,UsedIds}),
					case length(UsedIds) >= ?DYNAMIC_NPC_NUM_MAX of
						false->
							create_new_npc_id();
						_->	
							slogger:msg("create_new_npc_id maxnum error!!! ~n"),
							0
					end
			end;
		true->
			put(dynamic_npc_ids,{?DYNAMIC_NPC_INDEX,UsedIds}),
			create_new_npc_id()
	end.	
	
recycle_npc_id(Id)->
	if
		Id>=?DYNAMIC_NPC_INDEX->
			{Index,UsedIds} = get(dynamic_npc_ids),
			put(dynamic_npc_ids,{Index,lists:delete(Id,UsedIds)});
		true->
			nothing
	end.			

