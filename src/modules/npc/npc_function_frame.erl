%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-28
%% Description: TODO: Add description to npc_function_frame
-module(npc_function_frame).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("npc_define.hrl").
-include("mnesia_table_def.hrl").
-include("dragon_fight_def.hrl").
-include("ai_define.hrl").
-include("error_msg.hrl").
-define(NPC_FUNCTIONS_ETS,npc_functions_ets).
-define(FUNCTION_MOD_MAPS,npc_function_module_map_ets).

%%
%% Exported Functions
%%
-export([do_action/5,do_enum/4,add_function/3,list_npc_function/3,list_everquest_response/1,do_action_without_check/5]).


-export([init_all_functions_after_ets_finish/0]).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?NPC_FUNCTIONS_ETS, [set,named_table,public]),
	ets:new(?FUNCTION_MOD_MAPS, [set,named_table,public]).

init()->
	nothing.

create_mnesia_table(disc)->
	db_tools:create_table_disc(npc_functions,record_info(fields,npc_functions),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{npc_functions,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% mnesia : {NpcId,[FunctionId]}
%%
init_all_functions_after_ets_finish()->
	mod_util:behaviour_apply(npc_function_mod,init_func,[]),
	case dal:read_rpc(npc_functions) of
		{ok,NpcFunctions}->
			nothing;						
			_T->NpcFunctions = []
	end,
	lists:foreach(fun(NpcFunction)->
					NpcId = element(#npc_functions.npcid,NpcFunction),
					lists:foreach(fun(FunctionId)-> 
						case get_function_module_info(FunctionId,NpcId) of
							undefined-> nothing;
							{Response,ActionMFA,EnumMFA}->
					  			insert_function_to_ets(NpcId,FunctionId,Response,ActionMFA,EnumMFA)
						end
					end,element(#npc_functions.function,NpcFunction))
				  end, NpcFunctions).

get_function_module_info(FunctionId,NpcId)->
	case  get_function_module(FunctionId) of
		undefined-> undefined;
		M-> M:registe_func(NpcId) %% call function's module and obtain the information
	end.
	

add_function(FunctionId,FunctionKey,Module)->
	ets:insert(?FUNCTION_MOD_MAPS, {FunctionId,FunctionKey,Module}).
	
check_state(_RoleMapId,_RoleCoord,NpcInfo)->
	case NpcInfo of
		undefined->
			false;
		_->		
			%%not check!
			%%Pos = get_pos_from_npcinfo(NpcInfo),
			%%util:is_in_range(Pos,RoleCoord,?NPC_FUNCTION_DISTANCE) 
			%%and 
			creature_op:is_in_aoi_list(creature_op:get_id_from_creature_info(NpcInfo)),
			(creature_op:get_state_from_creature_info(NpcInfo)=:=gaming)
	end.
	
list_npc_function(RoleMapId,RoleInfo,NpcId)->
	trade_role:interrupt(),
	RolePos = get_pos_from_roleinfo(RoleInfo),
	NpcInfo = creature_op:get_creature_info(NpcId),
	Code = case check_state(RoleMapId,RolePos,NpcInfo) of
					false-> 	{error,position};
			   		true->
			   			npc_ai:call_npc_function(?EVENT_DIALOG,NpcInfo,get_id_from_roleinfo(RoleInfo)),
						OriResponse = get_npc_function_response_list(NpcId),
						case lists:keymember(?NPC_FUNCTION_QUEST,#kl.key,OriResponse) of
							true->
								{Quests,QuestStatus} = list_quest_response(NpcId);%%得到可接的任务
							_->
								Quests = [],
								QuestStatus = []
						end,
						case list_everquest_response(NpcId) of
							[] ->
								EverQuests =[];
							EverQuests-> 
								nothing
						end,	
						Response1 = lists:keydelete(?NPC_FUNCTION_QUEST,#kl.key,OriResponse),
						Response2 = lists:keydelete(?NPC_FUNCTION_EVERQUEST,#kl.key,Response1),
						case (erlang:length(Response2) =:= 1) and (Quests =:= []) of
							true->
								[{_,FunctionKey,_}] = Response2,
								FunctionId = get_functionid(FunctionKey),
								case FunctionId of
									[]-> Response = Response2;
									_-> case get_npc_function_info(NpcId,FunctionId) of
											 []->
												 Response = Response2;
											 {_,_,{EnumM,EnumF,EnumA}}->
												 Response = try
																case apply(EnumM, EnumF, [RoleInfo,EnumA,NpcId]) of
																	{ok}->no_send
																end
															catch
																_E:_R -> Response2
															end
										 end
								end;
							_-> Response = Response2
						end,
						case Response of
							no_send ->
								nothing;
							_->
								Message =  role_packet:encode_npc_function_s2c(NpcId,Response,Quests,QuestStatus,EverQuests),
								role_op:send_data_to_gate(Message)
						end,
						{ok}
		   end,
   %slogger:msg("npc_function_frame:list_npc_function zhangting 20120716 Code:~p ~n",[Code]),

	process_npc_error(Code).	

list_quest_response(NpcId)->
	case creature_op:get_creature_info(NpcId) of
	undefined->
		{[],[]};
	CreatureInfo->
		AccList = get_acc_quest_list_from_npcinfo(CreatureInfo),%%npc身上所绑定的任务id
		ComList = get_com_quest_list_from_npcinfo(CreatureInfo),%%npc身上要完成的任务id
		case quest_op:calculate_questgiver_state(AccList,ComList) =/= ?QUEST_STATUS_UNAVAILABLE of
			true->
				QuestStatuList = quest_op:calculate_questgiver_details(AccList,ComList),%%得到可接受的任务id和状态
				Quests = lists:map(fun({ID,_Statu})->ID end,QuestStatuList),
				QuestStatus = lists:map(fun({_ID,Statu})->Statu end,QuestStatuList),
				{Quests,QuestStatus};
			_->
				{[],[]}
		end
	end.

list_everquest_response(NpcId)->
	case quest_npc_db:get_everquestlist_by_npcid(NpcId) of
		[]->
			[];
		EverQuestList ->
			lists:filter(fun(EverId)->everquest_op:hookon_adapt_can_accpet(EverId) end , EverQuestList)
	end.

do_enum(RoleMapId,RoleInfo,NpcId,FunctionId)->
	NpcInfo = creature_op:get_creature_info(NpcId),
	Code = case check_state(RoleMapId,get_pos_from_roleinfo(RoleInfo),NpcInfo) of
			   false-> {error,position};
			   true->
					npc_ai:call_npc_function(?EVENT_DIALOG,NpcInfo,get_id_from_roleinfo(RoleInfo)),
				   case get_npc_function_info(NpcId,FunctionId) of
					   []->{error,nofunction};
					   {_,_,{EnumM,EnumF,EnumA}}->
						   try
								apply(EnumM, EnumF, [RoleInfo,EnumA,NpcId]),
						   	    {ok}
						   catch
							   E:R -> slogger:msg("call npc funtion enum exception [~p:~p]\n",[E,R]),
										{error,excetpion}
						   end;
						 _->
						 	{error,excetpion}  
				   end
		   end,
	process_npc_error(Code).	

do_action(RoleMapId,RoleInfo,NpcId,FunctionId,FunctionInput)->
	trade_role:interrupt(),
	NpcInfo = creature_op:get_creature_info(NpcId),
	Code = case check_state(RoleMapId,get_pos_from_roleinfo(RoleInfo),NpcInfo) of
			   false->
			   		{error,position};
			   true->
				 proc_do_action(RoleMapId,RoleInfo,NpcId,FunctionId,FunctionInput)
		   end,
	process_npc_error(Code).
	
do_action_without_check(RoleMapId,RoleInfo,NpcId,FunctionId,FunctionInput)->	
	Code = 	proc_do_action(RoleMapId,RoleInfo,NpcId,FunctionId,FunctionInput),	
	process_npc_error(Code).			
	
proc_do_action(RoleMapId,RoleInfo,NpcId,FunctionId,FunctionInput)->
	case get_npc_function_info(NpcId,FunctionId) of
	   []->{error,nofunction};
	   {_,{ActionM,ActionF,ActionA},_}->
		   try
			   if erlang:is_list(FunctionInput)->
				 apply(ActionM, ActionF, [RoleInfo]++[ActionA]++FunctionInput);
				  true->
					  apply(ActionM, ActionF, [RoleInfo]++[ActionA]++[FunctionInput])
			   end,
			   {ok}
		   catch
			   E:R -> slogger:msg("call npc funtion exception [~p:~p] ~p\n",[E,R,erlang:get_stacktrace()]),
						{error,excetpion}
		   end;
		 _->
		 	{error,excetpion}  
	 end.	   
	
	
%%
%% Local Functions
%%

process_npc_error(Code)->
	case Code of
		{ok}-> ignor;
		{error,AtomCode}->
						ErrorCode = case AtomCode of
							position   -> ?ERRNO_NPC_POSITION;
							nofunction -> ?ERRNO_NPC_NOFUNCTION;
							excetpion  -> ?ERRNO_NPC_EXCEPTION
						end,
			Message = login_pb:encode_npc_fucnction_common_error_s2c(
						#npc_fucnction_common_error_s2c{reasonid=ErrorCode}),
			role_op:send_data_to_gate(Message)
	end.		
  
%%clear_npc_function(NpcId)->
%%	case ets:match(?NPC_FUNCTIONS_ETS,{{NpcId,'$1'},'_','_','_'}) of
%%		[]-> ignor;
%%		FunctionIds-> lists:foreach(fun([FunctionId])-> 
%%											delete_function_from_ets(NpcId,FunctionId) end ,
%%									 FunctionIds)
%%	end.
			

insert_function_to_ets(NpcId,FunctionId,Response,ActionMFA,EnumMFA)->
	ets:insert(?NPC_FUNCTIONS_ETS, {{NpcId,FunctionId},Response,ActionMFA,EnumMFA}).

%%delete_function_from_ets(NpcId,FunctionId)->
%%	ets:delete(?NPC_FUNCTIONS_ETS, {NpcId,FunctionId}).

get_npc_function_info(NpcId,FunctionId)->
	case ets:lookup(?NPC_FUNCTIONS_ETS, {NpcId,FunctionId}) of
		[]-> [];
		[{_,Response,ActionMFA,EnumMFA}]->
			{Response,ActionMFA,EnumMFA}
	end.
		
	

get_npc_function_response_list(NpcId)->
	case ets:match(?NPC_FUNCTIONS_ETS, {{NpcId,'_'},'$1','_','_'}) of
		[]-> [];
		FunctionInfos->
			lists:append(FunctionInfos)
	end.



get_function_module(FunctionId)->
	case ets:lookup(?FUNCTION_MOD_MAPS, FunctionId) of
		[]-> undefined;
		[{FunctionId,_FunctionKey,Module}]-> Module
	end.

get_functionid(FunctionKey)->
	case ets:match(?FUNCTION_MOD_MAPS, {'$1',FunctionKey,'_'}) of
		[[FunctionId]]-> FunctionId;
		_-> undefined
	end.
	
