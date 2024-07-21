%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-4-14
%% Description: TODO: Add description to congratulations_op
-module(congratulations_op).

%%
%% Include files
%%
-include("error_msg.hrl").
-define(RANDOM_COUNT,5).
%%
%% Exported Functions
%%
-export([load_from_db/1,export_for_copy/0,write_to_db/0,load_by_copy/1,hook_on_offline/0]).
-export([congratulations_levelup_c2s/3,hook_on_role_levelup/1,hook_on_other_role_levelup/1,
		 other_role_congratulations_you/1,congratulations_received_c2s/2]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
%%
%% API Functions
%%
init()->
	random:seed(timer_center:get_correct_now()),
	put(role_congratu_log,[]).

load_from_db(RoleId)->
	case congratulations_db:get_role_congratu_log(RoleId) of
		{ok,[]}->
			init();
		{ok,[Result]}->
			{_,_,{{CurLevel,CurCount},{ConCount,ConTime}}}=Result,
			put(role_congratu_log,{RoleId,{{CurLevel,CurCount},{ConCount,ConTime}},0})
	end.

hook_on_offline()->
	case get(role_congratu_log) of
		[]->
			nothing;
		{RoleId,{{CurLevel,CurCount},{ConCount,ConTime}},_}->
			congratulations_db:sync_update_role_congratu_log_to_mnesia(RoleId, {RoleId,{{CurLevel,CurCount},{ConCount,ConTime}}})
	end.

export_for_copy()->
	get(role_congratu_log).
	
write_to_db()->
	nothing.

load_by_copy(RoleCongratuLog)->
	put(role_congratu_log,RoleCongratuLog).

hook_on_role_levelup(Level)->
	case congratulations_db:get_congratulations_info(Level) of
		[]->
			nothing;
		Info->
			RoleId = get(roleid),
			case get(role_congratu_log) of
				[]->
					put(role_congratu_log,{RoleId,{{Level,0},{0,timer_center:get_correct_now()}},0});
				{_,{{_,_},{ConCount,ConTime}},_}->
					put(role_congratu_log,{RoleId,{{Level,0},{ConCount,ConTime}},0})
			end,
			InfoBeCount=congratulations_db:get_coninfo_becount(Info),
			if
				InfoBeCount>0->
					case get(myfriends) of
						[]->
							ignor;
						FriendInfos->
							send_to_online_friend(FriendInfos,Level)
					end;
					
				true->
					nothing
			end
	end.

check_reming_limited()->
	Flag = case get(role_congratu_log) of
		[]->
			true;
		{_,{_,{ConCount,ConTime}},_}->
			Now = timer_center:get_correct_now(),
			{{_,_,NowD},{_,_,_}} = calendar:now_to_local_time(Now),
			{{_,_,ConD},{_,_,_}} = calendar:now_to_local_time(ConTime),
			if
				NowD=/=ConD->
					true;
				true->
					if
						ConCount<20->
							true;
						true->
							false
					end
			end
	end,
	Flag.

hook_on_other_role_levelup(Msg)->
	case check_reming_limited() of
		true->
			{BeRoleId,BeLevel,BeRoleName}=Msg,
			Message = congratulations_packet:encode_congratulations_levelup_remind_s2c(BeRoleId,BeRoleName,BeLevel),
			role_op:send_data_to_gate(Message);
		_->
			nothing
	end.
	
send_to_online_friend(FriendInfos,BeLevel)->
	BeRoleId = get(roleid),
	BeRoleName = get_name_from_roleinfo(get(creature_info)), 
	LFun = fun({Fid,_Fname,_Fclass,_Fgender,LineId,_Sign,_Intimacy,_Level})->%%@@wb20130311
				   if
					   LineId>0->
						   role_pos_util:send_to_role(Fid,{other_role_levelup,{congratulations,{BeRoleId,BeLevel,BeRoleName}}});
					   true->
						   nothing
				   end
		   end,
	lists:foreach(LFun, FriendInfos).
				
send_to_online_without_friend(FriendInfos,NoticeRange,_NoticeCount,BeLevel)->
	{Line,{LevelS,LevelE}}=NoticeRange,
	BeRoleId=get(roleid),
	BeRoleName = get_name_from_roleinfo(get(creature_info)), 
	if
		Line =:= 0->
			S = fun(RolePos)->
				RoleNode = role_pos_db:get_role_mapnode(RolePos),
				RoleProc = role_pos_db:get_role_pid(RolePos),
				RoleId = role_pos_db:get_role_id(RolePos),
				if 
					BeRoleId=/=RoleId->
						gs_rpc:cast(RoleNode,RoleProc,{other_role_levelup,{congratulations,{BeRoleId,BeLevel,BeRoleName,LevelS,LevelE}}});
					true->
						nothing
				end
			end,
			RolePosList = role_pos_db:get_all_rolepos(),
			ExceptFriendList = lists:filter(fun(RolePos)->
								 RoleId = role_pos_db:get_role_id(RolePos),
								 case lists:keymember(RoleId, 1, FriendInfos) of
									 true->
										 false;
									 false->
										 true
								 end
						 end, RolePosList),
			RandomRolePos = random_rolepos_by_count(ExceptFriendList,?RANDOM_COUNT),
			lists:foreach(S, RandomRolePos);
		Line =:= 1->
			SelfLineId = get_lineid_from_mapinfo(get(map_info)),
			S = fun(RolePos)->
				RoleNode = role_pos_db:get_role_mapnode(RolePos),
				RoleProc = role_pos_db:get_role_pid(RolePos),
				RoleId = role_pos_db:get_role_id(RolePos),
				if 
					BeRoleId=/=RoleId->
						case lists:keymember(RoleId, 1, FriendInfos) of
							true->
								nothing;
							false->
								gs_rpc:cast(RoleNode,RoleProc,{other_role_levelup,{congratulations,{BeRoleId,BeLevel,BeRoleName,LevelS,LevelE}}})
						end;
					true->
						nothing
				end
			end,
			RolePosList = role_pos_db:get_role_info_by_line(SelfLineId),
			ExceptFriendList = lists:filter(fun(RolePos)->
								 RoleId = role_pos_db:get_role_id(RolePos),
								 case lists:keymember(RoleId, 1, FriendInfos) of
									 true->
										 false;
									 false->
										 true
								 end
						 end, RolePosList),
			RandomRolePos = random_rolepos_by_count(ExceptFriendList,?RANDOM_COUNT),
			lists:foreach(S, RandomRolePos);
		true->
			nothing
	end.

random_rolepos_by_count(RolePosList,Count)->
	Len = erlang:length(RolePosList),
	if
		Len=<Count->
			RolePosList;
		true->
			util:get_random_list_from_list(RolePosList,Count)
	end.

obt_role_info(BeLevel,BeRoleId,Type,Exp,SoulPower)->
	RoleName = get_name_from_roleinfo(get(creature_info)),
	RoleId = get(roleid),
	case role_pos_util:where_is_role(BeRoleId) of
		[] -> 
			send_error_msg(?ERROR_CONGRATULATIONS_IS_ERROR),
			error;
		RolePos->			
			RoleNode = role_pos_db:get_role_mapnode(RolePos),
			RolePid = role_pos_db:get_role_pid(RolePos),
			%%BeRoleName = role_pos_db:get_role_rolename(RolePos),
			case role_processor:other_role_congratulations_you(RoleNode,RolePid,{BeLevel,RoleId,RoleName,Type}) of
				ok->
					role_op:obtain_exp(Exp),
					role_op:obtain_soulpower(SoulPower),
					%%friend_op:add_friend_for_inner(get(creature_info), BeRoleName),
					ok;
				{error,limited}->
					send_error_msg(?ERROR_BE_CONGRATULATIONS_IS_LIMITED),
					limited;
				error->
					send_error_msg(?ERROR_CONGRATULATIONS_IS_ERROR),
					error;
				_->
					send_error_msg(?ERROR_CONGRATULATIONS_IS_ERROR),
					error
			end
	end.
	
send_error_msg(Reason)->
	ErrorMessage = congratulations_packet:encode_congratulations_error_s2c(Reason),
	role_op:send_data_to_gate(ErrorMessage).

send_congratulation_levelup_s2c(Exp,SoulPower,Remain)->
	Message = congratulations_packet:encode_congratulations_levelup_s2c(Exp, SoulPower,Remain),
	role_op:send_data_to_gate(Message).

congratulations_levelup_c2s(BeLevel,BeRoleId,Type)->
	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	RoleId = get(roleid),
	case congratulations_db:get_congratulations_info(RoleLevel) of
		[]->
			send_error_msg(?ERRNO_NPC_EXCEPTION);
		Info->
			{Exp,SoulPower} = congratulations_db:get_coninfo_reward(Info),
			Now = timer_center:get_correct_now(),
			{{_,_,NowD},{_,_,_}} = calendar:now_to_local_time(Now),
			case get(role_congratu_log) of
				[]->
					case obt_role_info(BeLevel,BeRoleId,Type,Exp,SoulPower) of
						ok->
							send_congratulation_levelup_s2c(Exp,SoulPower,19),
							put(role_congratu_log,{RoleId,{{RoleLevel,0},{1,Now}},0});
						_->
							nothing
					end;
				{PlayerId,{{CurLevel,CurCount},{ConCount,ConTime}},ReceiveCon}->
					{{_,_ConM,ConD},_}=calendar:now_to_local_time(ConTime),
					if
						ConD=/=NowD->
							case obt_role_info(BeLevel,BeRoleId,Type,Exp,SoulPower) of
								ok->
									send_congratulation_levelup_s2c(Exp,SoulPower,19),
									put(role_congratu_log,{PlayerId,{{CurLevel,CurCount},{1,Now}},ReceiveCon});
								_->
									nothing
							end;
						true->
							if 
								ConCount<20->
									case obt_role_info(BeLevel,BeRoleId,Type,Exp,SoulPower) of
										ok->
											send_congratulation_levelup_s2c(Exp,SoulPower,19-ConCount),
											put(role_congratu_log,{PlayerId,{{CurLevel,CurCount},{ConCount+1,ConTime}},ReceiveCon});
										_->
											nothing
									end;
								true->
									send_error_msg(?ERROR_CONGRATULATIONS_IS_LIMITED)
							end
					end
			end
	end.
			
other_role_congratulations_you({BeLevel,RoleId,RoleName,Type})->
	case get(role_congratu_log) of
		{PlayerId,{{CurLevel,CurCount},{ConCount,ConTime}},ReceiveCon}->
			case congratulations_db:get_congratulations_info(BeLevel) of
				[]->
					send_error_msg(?ERRNO_NPC_EXCEPTION);
				Info->
					Becount = congratulations_db:get_coninfo_becount(Info),
					Bereward = congratulations_db:get_coninfo_bereward(Info),
					if
						CurCount<Becount->
							{Exp,SoulPower} = Bereward,
							Message = congratulations_packet:encode_congratulations_levelup_receive_s2c(Exp, SoulPower,Type, RoleName, BeLevel, RoleId),
							role_op:send_data_to_gate(Message),
							if
								CurLevel=:=BeLevel->
									put(role_congratu_log,{PlayerId,{{CurLevel,CurCount+1},{ConCount,ConTime}},ReceiveCon});
								true->
									nothing
							end,
							ok;
						true->
							{error,limited}
					end
			end;
		_->
			error
	end.
				
congratulations_received_c2s(Level,_RoleName)->
	case get(role_congratu_log) of
		[]->
			send_error_msg(?ERRNO_NPC_EXCEPTION);
		{RoleId,{{_CurLevel,_CurCount},{_ConCount,_ConTime}},ReceiveCon}->
			case congratulations_db:get_congratulations_info(_CurLevel) of
				[]->
					send_error_msg(?ERRNO_NPC_EXCEPTION);
				Info->
					Becount = congratulations_db:get_coninfo_becount(Info),
					if
						ReceiveCon > Becount->
							slogger:msg("congratulations_received more than 20 [~p]",[get(roleid)]),
							role_op:kick_out(get(roleid));
						true->
							case congratulations_db:get_congratulations_info(Level) of
								[]->
									send_error_msg(?ERRNO_NPC_EXCEPTION);
								NewInfo->
									Bereward = congratulations_db:get_coninfo_bereward(NewInfo),
									{Exp,SoulPower} = Bereward,
									role_op:obtain_exp(Exp),
									role_op:obtain_soulpower(SoulPower),
									NewReceiveCon = ReceiveCon + 1,
									put(role_congratu_log,{RoleId,{{_CurLevel,_CurCount},{_ConCount,_ConTime}},NewReceiveCon})
							end
					end
					%%friend_op:add_friend_for_inner(get(creature_info), RoleName)
			end
	end.
	
%%
%% Local Functions
%%

