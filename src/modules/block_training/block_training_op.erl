%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(block_training_op).

-compile(export_all).

-include("common_define.hrl").
-include("error_msg.hrl").
-include("little_garden.hrl").
-include("map_info_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("game_map_define.hrl").

%%
%%trainning_info:{start_time,duration},not export,reinit in map change
%%

init()->
	put(training_info,{{0,0,0},0}),
	NewInfo = buffer_extra_effect:remove_ext_state(block_training,get(creature_info),[]),
	put(creature_info,NewInfo),
	role_op:update_role_info(get(roleid), NewInfo).

is_other_training(RoleInfo)->
	ExtAttrs = creature_op:get_extra_state_from_roleinfo(RoleInfo),
	lists:member(block_training,ExtAttrs).

load_from_db(TrainingInfo)->
	case TrainingInfo of
		{StartTime,Duration}->
		if
			(StartTime=/= {0,0,0}) and (Duration =/= 0)->					%%online in block_training 
				put(training_info,TrainingInfo);
			true->
				init()
		end;
		_->
			init()
	end.

load_by_copy(TrainingInfo)->
	put(training_info,TrainingInfo).

export_for_copy()->
	get(training_info).

is_in_training_map()->
	MapId = get_mapid_from_mapinfo(get(map_info)),
	mapop:get_map_tag(MapId) =:=?MAP_TAG_BLOCK_TRAINING.

on_map_complete()->
	case is_in_training_map() of
		true->
			{StartTime,Duration} = get(training_info),
			Mylevel = get_level_from_roleinfo(get(creature_info)),
			Training =  block_training_db:get_block_training(Mylevel),
			ExpBaseValue = block_training_db:get_growth(Training),
			SpBaseValue = block_training_db:get_spgrowth(Training),
			BaseValue = {ExpBaseValue,SpBaseValue},
			LeftTime = Duration - erlang:trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000),
			case  LeftTime =< ?TRAINING_TIME of
				true->						%%time out
					init();
				_->
					start_with_time_and_value(LeftTime,BaseValue)
			end;
		_->
			init()	
	end.

export_for_db()->
	get(training_info).

start_training()->
	{OriStartTime,OriDuration} = get(training_info),
	if
		(OriStartTime=/= {0,0,0}) or (OriDuration =/= 0)->			
			nothing;
		true->
			clear_timer(),
			case is_in_training_map() of
				true->						%%start 
					Mylevel = get_level_from_roleinfo(get(creature_info)),
					case block_training_db:get_block_training(Mylevel) of
						[]->
							nothing;
						TrainingInfo-> 
							Duration = block_training_db:get_duration(TrainingInfo),
							ExpBaseValue = block_training_db:get_growth(TrainingInfo),
							SpBaseValue = block_training_db:get_spgrowth(TrainingInfo),
							BaseValue = {ExpBaseValue,SpBaseValue},
							put(training_info,{timer_center:get_correct_now(),Duration}),
							start_with_time_and_value(Duration,BaseValue)
					end;
				_->
					slogger:msg("start_training error map maybe hack! ~n")
			end
	end.

start_with_time_and_value(Duration,BaseValue)->
	case  Duration =< ?TRAINING_TIME of
		true->						%%time out
			init();
		_->
			Timer = erlang:send_after(?TRAINING_TIME, self(),{block_training,BaseValue }),
			put(training_timer,Timer),
			Msg = role_packet:encode_start_block_training_s2c(get(roleid),Duration),
			role_op:send_data_to_gate(Msg),
			role_op:broadcast_message_to_aoi_client(Msg),
			NewInfo = buffer_extra_effect:add_ext_state(block_training,get(creature_info),[]),
			put(creature_info,NewInfo),
			role_op:update_role_info(get(roleid), NewInfo)
	end.


clear_timer()->
	case get(training_timer) of
		undefined->
			nothing;
		Timer->
			erlang:cancel_timer(Timer),
			put(training_timer,undefined)
	end.

end_training()->
	{StartTime,_} = get(training_info),
	DurationTime = trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000000),
	put(training_info,{{0,0,0},0}),
	case get(training_timer) of
		undefined ->
			nothing;
		Timer->
			put(training_timer,undefined),
			Msg = role_packet:encode_end_block_training_s2c(get(roleid)),
			role_op:send_data_to_gate(Msg),
			role_op:broadcast_message_to_aoi_client(Msg),
			NewInfo = buffer_extra_effect:remove_ext_state(block_training,get(creature_info),[]),
			put(creature_info,NewInfo),
			role_op:update_role_info(get(roleid), NewInfo),
			erlang:cancel_timer(Timer)
	end.
%% 	achieve_op:achieve_update({training}, [0], DurationTime).

training_heartbeat(BaseValue)->
	case is_in_training_map() of
		true->
			{BaseExp,BaseSp} = BaseValue,
			%%ExpRate = get_expratio_from_roleinfo(get(creature_info)),
			VipAdd = vip_op:get_addition_with_vip(block_training)/100,
			GlobalRate = global_exp_addition:get_role_exp_addition(block_training),
			Factor = get_addation_rate()+1+VipAdd+GlobalRate,
			RealExp = erlang:trunc(BaseExp*Factor),
			RealSp =  erlang:trunc(BaseSp*Factor),
			role_op:obtain_soulpower(RealSp),	
			case role_op:obtain_exp(RealExp) of
				level_up->
					Mylevel = get_level_from_roleinfo(get(creature_info)),
					TrainingInfo =  block_training_db:get_block_training(Mylevel),
					NewValue = {block_training_db:get_growth(TrainingInfo),block_training_db:get_spgrowth(TrainingInfo)};
				_->	
					NewValue = BaseValue
			end,
			{StartTime,Duration} = get(training_info),
			case timer:now_diff(timer_center:get_correct_now(),StartTime) > Duration*1000 of
				true->						%%time out
					end_training();
				_->
					Timer = erlang:send_after(?TRAINING_TIME, self(),{block_training,NewValue}),
					put(training_timer,Timer)
			end;
		_->			%%leave block_training map
			end_training()
	end.

get_addation_rate()->
	Members = group_op:get_members_in_aoi(),
	AllMembersInfo = lists:map(fun(Id)->creature_op:get_creature_info(Id) end, Members),
	MembersInfo = lists:filter(fun(Info)->is_other_training(Info) end, AllMembersInfo),
	if
		MembersInfo =:= []->
			0;
		true->
			get_membernum_addation(MembersInfo) + 	get_guild_addation(MembersInfo) + get_friend_addation(MembersInfo)
			+ get_gender_class_addation([get(creature_info)|MembersInfo])
	end.

get_membernum_addation(MembersInfo)->	
	case erlang:length(MembersInfo) + 1 of
		1->
			0;
		2->
			0.1;
		3->
			0.15;
		4->
			0.20;
		5->
			0.25
	end.

get_guild_addation(MembersInfo)->
	case (erlang:length(lists:filter(fun(Info)->guild_util:is_same_guild(get_id_from_roleinfo(Info)) end, MembersInfo))>=2) of
		true->
			0.05;
		_->
			0
	end.

get_friend_addation(MembersInfo)->
	case lists:filter(fun(Info)->not friend_op:is_friend_id(get_id_from_roleinfo(Info)) end, MembersInfo) of
		[]->
			0.05;
		_->
			0
	end.
	
		
get_gender_class_addation(MembersInfo)->
	{Genders,Classes} =
		lists:foldl(fun(RoleInfo,{Genders,Classes})->
					Class = get_class_from_roleinfo(RoleInfo),
					Gender = get_gender_from_roleinfo(RoleInfo),
					{case lists:member(Gender,Genders) of
						true->
							Genders;
						_->
							[Gender|Genders]
					end,
					case lists:member(Class,Classes) of
						true->
							Classes;
						_->
							[Class|Classes]
					end} end,{[],[]},MembersInfo),
	ClassAddation = 
	case erlang:length(Classes) of
		3->
			0.05;
		_->
			0
	end,
	GenderAddation = 
	case erlang:length(Genders) of
		2->
			0.05;
		_->
			0
	end,
	GenderAddation + ClassAddation.



