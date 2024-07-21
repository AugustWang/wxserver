%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_quest_action).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("ai_define.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-export([quest_action/4,quest_action/5,quest_action/6]).
%%
%% API Functions
%%
-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

init_func()->
	npc_function_frame:add_function(quest_action,?NPC_FUNCTION_QUEST, ?MODULE).

registe_func(NpcId)->
	{QuestIdAccs,QuestIdSubs} = read_com_and_acc_for_npc(NpcId),
	Mod= ?MODULE,
	Fun= quest_action,
	Arg=  {QuestIdAccs,QuestIdSubs},
	Response= #kl{key=?NPC_FUNCTION_QUEST, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg =  {QuestIdAccs,QuestIdSubs},
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,{QuestIdAccs,QuestIdSubs},NpcId)->
	QuestStatuList = quest_op:calculate_questgiver_details(QuestIdAccs,QuestIdSubs),
	QuestIds = lists:map(fun({ID,_Statu})->ID end,QuestStatuList),
	QuestStatus = lists:map(fun({_ID,Statu})->Statu end,QuestStatuList),
	Message = quest_packet:encode_questgiver_quest_details_s2c(NpcId,QuestIds,QuestStatus),
	role_op:send_data_to_gate(Message),
	{ok}.


quest_action(_,{QuestIdAccs,QuestIdSubs},hello,NpcId)->
	QuestStatuList = quest_op:calculate_questgiver_details(QuestIdAccs,QuestIdSubs),
	QuestIds = lists:map(fun({ID,_Statu})->ID end,QuestStatuList),
	QuestStatus = lists:map(fun({_ID,Statu})->Statu end,QuestStatuList),
	Message = quest_packet:encode_questgiver_quest_details_s2c(NpcId,QuestIds,QuestStatus),
	role_op:send_data_to_gate(Message);

quest_action(_,{QuestIdAccs,QuestIdSubs},auto_give,NpcId)->
	if
		NpcId=:=0->
			nothing;
		true->
			QuestStatuList = quest_op:calculate_questgiver_details(QuestIdAccs,QuestIdSubs),
			case lists:keyfind(?QUEST_STATUS_COMPLETE,2,QuestStatuList) of
				false->
					case lists:keyfind(?QUEST_STATUS_AVAILABLE, 2, QuestStatuList) of
						false->	%% no available quest,find everquest
							
							case npc_function_frame:list_everquest_response(NpcId) of
								[]->
									nothing;
								[EverQuestId|_T]->
									everquest_handle:handle_npc_start_everquest(EverQuestId,NpcId)
							end;
						{QuestId,_}->
							quest_op:start_quest(QuestId,NpcId)
					end;
				{QuestId,_}->		%% has compelete 
					quest_op:start_quest(QuestId,NpcId)
			end
	end.

quest_action(_,{QuestIdAccs,_},accept,NpcId,Questid)->
	case lists:member(Questid,QuestIdAccs) of
		true->
			case quest_op:accept_quest(Questid) of
				{State,Values}->
						npc_ai:call_npc_function({?EVENT_QUEST_ACCEPT,Questid},creature_op:get_creature_info(NpcId),get(roleid)),
						Message = quest_packet:encode_quest_list_add_s2c(Questid,State,Values),
						role_op:send_data_to_gate(Message),
						everquest_op:hookon_after_accpet_quest(Questid),
						npc_function_frame:do_action_without_check(0,get(creature_info),NpcId,quest_action,[auto_give,NpcId]);
				[]->
						nothing
			end;
		false->
			slogger:msg("hack find! quest_action accept hasnot this Quest: ~p ~n",[Questid])
	end.
			 
quest_action(_,{_,QuestIdSubs},compelet,Questid,ChoiceItem,NpcId)->
	case lists:member(Questid,QuestIdSubs) of
		true->
			case quest_op:complete_quest(Questid,ChoiceItem,NpcId) of
				quest_finished->
					npc_ai:call_npc_function({?EVENT_QUEST_FINISHED,Questid},creature_op:get_creature_info(NpcId),get(roleid));
				_->
					nothing
			end;
		false->
			slogger:msg("hack find! quest_action compelet hasnot this Quest:~p~n",[Questid])
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%local
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read_com_and_acc_for_npc(NpcId)->
	case quest_npc_db:get_questinfo_by_npcid(NpcId) of
		[]->
			Acc_quest_list= [],Com_quest_list=[];
		NpcQuestInfo->
			{Acc_quest_list,Com_quest_list } = quest_npc_db:get_quest_action(NpcQuestInfo)		
	end,
	{Acc_quest_list,Com_quest_list}.
				