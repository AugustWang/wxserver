%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_chess_spirits).


-include("chess_spirit_define.hrl").
-include("map_info_struct.hrl").
-include("error_msg.hrl").
-include("login_pb.hrl").
-compile(export_all).


%%role_chess_spirits_info {Type,NpcId,NpcPid,MyRanSkills}
%%best_chess_spirits_info,[{Type,Section,UsedTime_S}]
%%last_chess_spirits_info[{Type,Section,UsedTime_S,Hasrewards}]
init()->
	put(role_chess_spirits_info,[]),
	put(last_chess_spirits_info,[]),
	put(best_chess_spirits_info,[]),
	load_from_db(get(roleid)).

load_from_db(RoleId)->
	case chess_spirit_db:get_role_chess_spirit_log(RoleId) of
		[]->
			put(best_chess_spirits_info,[]),
			put(last_chess_spirits_info,[]);
		{LastInfo,BestInfo}->
			put(last_chess_spirits_info,LastInfo),
			put(best_chess_spirits_info,BestInfo)
	end.
  
load_by_copy({LastInfo,ChessInfo,BestInfo})->
	put(last_chess_spirits_info,LastInfo),
	put(role_chess_spirits_info,ChessInfo),
	put(best_chess_spirits_info,BestInfo).

export_for_copy()->
	{get(last_chess_spirits_info),get(role_chess_spirits_info),get(best_chess_spirits_info)}.

handle_message({init,Type,NpcId,NpcPid,MyRanSkills})->
	put(role_chess_spirits_info,{Type,NpcId,NpcPid,MyRanSkills});

handle_message({result,Type,CurSection,UsedTime_S,Result})->
	add_result(Type,CurSection,UsedTime_S),
	proc_role_leave_from_spirits(CurSection,UsedTime_S,Result);
	
handle_message(#chess_spirit_quit_c2s{})->
	proc_role_quit();

handle_message(#chess_spirit_log_c2s{type=Type})->
	proc_get_log(Type);

handle_message(#chess_spirit_get_reward_c2s{type=Type})->
	proc_get_rewards(Type);

handle_message(#chess_spirit_cast_skill_c2s{skillid = SkillId})->
	case get(role_chess_spirits_info) of
		[]->
			nothing;
		{_,_,_,MyRanSkills}->
			case lists:member(SkillId, MyRanSkills) of
				true->
					send_to_chess_spirit({role_cast_skill_self,get(roleid),SkillId});
				false->
					nothing
			end
	end;

handle_message(#chess_spirit_cast_chess_skill_c2s{})->
	case get(role_chess_spirits_info) of
		[]->
			nothing;
		{?CHESS_SPIRIT_TYPE_TEAM,_,_,_}->
			case group_op:is_leader() of
				true->
					send_to_chess_spirit({role_cast_skill_chess,get(roleid)});
				false->
					nothing
			end;
		_->
			send_to_chess_spirit({role_cast_skill_chess,get(roleid)})
	end;

handle_message(#chess_spirit_skill_levelup_c2s{skillid = SkillId})->
	send_to_chess_spirit({role_up_share_skill,get(roleid),SkillId});

handle_message(Info)->
	slogger:msg("role_chess_spirits handle_message error Info ~p ~n",[Info]).

hook_on_kick_from_instance()->
	case get(role_chess_spirits_info) of
		[]->
			nothing;
		_->
			%%leave before result will got nothing!
			proc_role_leave_from_spirits(0,0,?CHESS_SPIRIT_RESULT_LEAVE),
			%%clear me
			send_to_chess_spirit({chess_spirit_role_leave,get(roleid)})
	end.		

proc_role_quit()->
	instance_op:kick_from_cur_instance().

proc_role_leave_from_spirits(Section,Time,Reason)->
	case get(role_chess_spirits_info) of
		{Type,_,_,_}-> 
			put(role_chess_spirits_info,[]),
			Msg = chess_spirit_packet:encode_chess_spirit_game_over_s2c(Type,Section,Time,Reason),
			role_op:send_data_to_gate(Msg),
			proc_get_rewards(Type);
		_->
			slogger:msg("proc_role_leave_from_spirits ERROR ~p ~n",[get(role_chess_spirits_info)])
	end.

proc_get_log(Type)->
	case lists:keyfind(Type, 1, get(last_chess_spirits_info)) of
		false->
			LastSec = 0,
			LastTime = 0,
			CanReward = false,
			Rewardexp = 0,
			RewardItems = [];
		{Type,LastSec,LastTime,Hasreward}->
			CanReward = not Hasreward,
			{Rewardexp,RewardItems} = get_my_reaward_exp_and_item(Type,LastSec)
	end,
	case lists:keyfind(Type, 1, get(best_chess_spirits_info)) of
		false->
			BestSec = 0,
			BestTime = 0;
		{Type,BestSec,BestTime}->
			nothing
	end,
	if
		CanReward->
			CanRewardInt = 1;
		true->
			CanRewardInt = 0
	end,
	Msg = chess_spirit_packet:encode_chess_spirit_log_s2c(Type,LastSec,LastTime,BestSec,BestTime,CanRewardInt,Rewardexp,RewardItems),
	role_op:send_data_to_gate(Msg).

proc_get_rewards(Type)->
	case lists:keyfind(Type, 1, get(last_chess_spirits_info)) of
		false->
			nothing;
		{Type,LastSec,LastTime,Hasreward}->
			if
				not Hasreward->
					{Rewardexp,RewardItems} = get_my_reaward_exp_and_item(Type,LastSec),
					case package_op:can_added_to_package_template_list(RewardItems) of
						false->	
							Message = chess_spirit_packet:encode_chess_spirit_opt_result_s2s(?ERROR_PACKEGE_FULL),
							role_op:send_data_to_gate(Message);
						_->
							lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_chess_spirit) end,RewardItems),
							role_op:obtain_exp(Rewardexp),
							Message = chess_spirit_packet:encode_chess_spirit_opt_result_s2s(?ERRNO_CHESS_SPIRIT_REWARD_SUCCESS),
							role_op:send_data_to_gate(Message),
							put(last_chess_spirits_info,lists:keyreplace(Type,1, get(last_chess_spirits_info),{Type,LastSec,LastTime,true})),
							sync_to_db()
					end;
				true->
					nothing
			end
	end.

add_result(Type,CurSection,UsedTime_S)->
	case lists:keymember(Type, 1, get(last_chess_spirits_info)) of
		false->
			put(last_chess_spirits_info,[{Type,CurSection,UsedTime_S,false}|get(last_chess_spirits_info)]);
		_->
			put(last_chess_spirits_info,lists:keyreplace(Type,1,get(last_chess_spirits_info), {Type,CurSection,UsedTime_S,false}))
	end,
	RoleIds = group_op:get_member_id_list(),
	gm_logger_role:chess_spirit_log(Type,get(roleid),get(level),UsedTime_S,CurSection,RoleIds),
	update_record(Type,CurSection,UsedTime_S).

update_record(Type,CurSection,UsedTime_S)->
	case lists:keyfind(Type, 1, get(best_chess_spirits_info)) of
		false->
			put(best_chess_spirits_info,[{Type,CurSection,UsedTime_S}|get(best_chess_spirits_info)]);
		{Type,SectionRecord,RecordTime}->
			if
				CurSection>SectionRecord->
					put(best_chess_spirits_info,[{Type,CurSection,UsedTime_S}|get(best_chess_spirits_info)]);
				(CurSection=:=SectionRecord) and (UsedTime_S<RecordTime)->
					put(best_chess_spirits_info,[{Type,CurSection,UsedTime_S}|get(best_chess_spirits_info)]);
				true->
					nothing
			end
	end,
	sync_to_db().
	
	
sync_to_db()->	
	chess_spirit_db:sync_update_role_chess_spirit_log(get(roleid),get(last_chess_spirits_info),get(best_chess_spirits_info)).

get_my_reaward_exp_and_item(Type,RewardSec)->
	Rewardexp = 
	case chess_spirit_db:get_chess_spirit_rewards_info(Type,get(level)) of
		[]->
			0;
		RewardInfo->
			ExceptSec = chess_spirit_db:get_reward_expect_sec(RewardInfo),
			ExpArg = chess_spirit_db:get_reward_exp_args(RewardInfo),
			if
				RewardSec>ExceptSec->
					trunc(ExceptSec*ExpArg + ExpArg*(1 - math:pow(0.85, (RewardSec - ExceptSec)))/0.15);
				true->
					trunc(RewardSec*ExpArg)
			end
	end,
	RewardItems = 
	case chess_spirit_db:get_chess_spirit_section_info(Type,RewardSec) of
		[]->
			[];
		SectionInfo->
			chess_spirit_db:get_section_item_rewards(SectionInfo)
	end,
	{Rewardexp,RewardItems}.		

send_to_chess_spirit(Msg)->
	case get(role_chess_spirits_info) of
		[]->
			nothing;
		{_,_,NpcPid,_}->
			gs_rpc:cast(NpcPid,Msg)
	end.
