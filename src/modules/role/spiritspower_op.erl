%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-28
%% Description: TODO: Add description to spiritspower_op
-module(spiritspower_op).

-compile(export_all).

%%
%% Include files
%%
-include("spiritspower_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("creature_define.hrl").
%%
%% Exported Functions
%%


-record(spiritpower_struct,{curvalue,maxvalue,state,timestamp}).

%%
%% API Functions
%%
init()->
	put(spiritpowerinfo,init_spiritpower_struct()).

export_for_copy()->
	get(spiritpowerinfo).

load_by_copy(Info)->
	put(spiritpowerinfo,Info).


on_other_killed(OtherId)->
	case creature_op:what_creature(OtherId) of
		npc->
			case creature_op:get_creature_info(OtherId) of
				undefined->
					nothing;
				NpcInfo->
					case get_npcflags_from_npcinfo(NpcInfo) of
						?CREATURE_MONSTER->
							Level = get_level_from_npcinfo(NpcInfo),
							MyLevel = get_level_from_roleinfo(get(creature_info)),
							if
								abs(MyLevel - Level) =< ?MONSTER_LEVEL_LIMIT->
									add_value(?ADDPOWER_PER_MONSTER);									
								true->
									nothing
							end;
						_->
							nothing
					end
			end;
		_->
			nothing
	end.

reset()->
	case get_state() of
		?SPIRITSPOWER_STATE_BURNING->
			Now = now(),
			TimeStamp = get_timestamp(),
			CurValue = get_value(),
			DiffSeconds = erlang:max(trunc(timer:now_diff(Now, TimeStamp)/1000000),0),
			CosumeValue = DiffSeconds * ?CONSUME_POWER_PER_SECOND,
			if
				CosumeValue >=  CurValue->
					reset_and_notify_client();
				true->
					NewCurValue = CurValue - CosumeValue,
					set_value(NewCurValue),
					set_state(?SPIRITSPOWER_STATE_BURNING,Now),
					LeftTime = util:even_div(NewCurValue,?CONSUME_POWER_PER_SECOND),
					Message = role_packet:encode_spiritspower_state_update_s2c(?SPIRITSPOWER_STATE_BURNING,LeftTime,NewCurValue)
			end;
		_->
			nothing
	end.

cleanup()->
	case get_state() of
		?SPIRITSPOWER_STATE_BURNING->
			reset_and_notify_client();
		_->
			nothing
	end.
%%
%%check burning to normal
%%
check_timer(Now)->
	case get_state() of
		?SPIRITSPOWER_STATE_BURNING->
			TimeStamp = get_timestamp(),
			CurValue = get_value(),
			DiffSeconds = erlang:max(trunc(timer:now_diff(Now, TimeStamp)/1000000) - ?BURNING_DELAY_TIME_S,0),
%% 			io:format("DiffSeconds ~p ~n",[DiffSeconds]),
			CosumeValue = DiffSeconds * ?CONSUME_POWER_PER_SECOND,
			if
				CosumeValue >=  CurValue->
					reset_and_notify_client();
				true->
					nothing
			end;
		_->
			nothing
	end.

%%
%%return true | false
%%
check_state()->
	get_state() =:= ?SPIRITSPOWER_STATE_BURNING.
%%
%% Local Functions
%%

%%return record spiritpower_struct
init_spiritpower_struct()->
	#spiritpower_struct{
						curvalue = 0,
						maxvalue = ?MAX_SPIRITSPOWER,
						state = ?SPIRITSPOWER_STATE_NORMAL,
						timestamp = {0,0,0}
						}.

get_value()->
	SpiritPower = get(spiritpowerinfo),
	element(#spiritpower_struct.curvalue,SpiritPower).

get_maxvalue()->
	SpiritPower = get(spiritpowerinfo),
	element(#spiritpower_struct.maxvalue,SpiritPower).

get_state()->
	SpiritPower = get(spiritpowerinfo),
	element(#spiritpower_struct.state,SpiritPower).

get_timestamp()->
	SpiritPower = get(spiritpowerinfo),
	element(#spiritpower_struct.timestamp,SpiritPower).

set_value(Value)->
	NewSpiritPower = setelement(#spiritpower_struct.curvalue,
								get(spiritpowerinfo),
								Value),
	put(spiritpowerinfo,NewSpiritPower).

set_state(State,TimeStamp)->
	NewSpiritPower1 = setelement(#spiritpower_struct.state,
								get(spiritpowerinfo),
								State),
	NewSpiritPower = setelement(#spiritpower_struct.timestamp,
								NewSpiritPower1,
								TimeStamp),
	put(spiritpowerinfo,NewSpiritPower).

reset_and_notify_client()->
	set_value(0),
	set_state(?SPIRITSPOWER_STATE_NORMAL,{0,0,0}),
	Message = role_packet:encode_spiritspower_state_update_s2c(?SPIRITSPOWER_STATE_NORMAL,0,0),
	role_op:send_data_to_gate(Message),
	role_op:only_self_update([{spiritspower,0}]).

add_value(Value)->
	case get_state() of
		?SPIRITSPOWER_STATE_BURNING->
			nothing;
		_->
			CurValue = get_value(),
			MaxValue = get_maxvalue(),
			NewValue = min(CurValue + Value,MaxValue),
			if
				NewValue =:= MaxValue->
					Now = now(),
					set_state(?SPIRITSPOWER_STATE_BURNING,Now),
					LeftTime = util:even_div(NewValue,?CONSUME_POWER_PER_SECOND),
%% 					io:format("LeftTime ~p ~n",[LeftTime]),
					Message = role_packet:encode_spiritspower_state_update_s2c(?SPIRITSPOWER_STATE_BURNING,LeftTime,NewValue),
					role_op:send_data_to_gate(Message);				
				true->
					nothing
			end,
			role_op:only_self_update([{spiritspower,NewValue}]),
			set_value(NewValue)
	end.
	
