%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-22
%% Description: TODO: Add description to buffer_op
-module(buffer_op).

%%
%% Include files
%%
-include("little_garden.hrl").
-include("skill_define.hrl").
%%
%% Exported Functions
%%
-export([init/0,do_interval/1,generate_interval/5,remove_buffer/1,load_from_db/1,export_for_copy/0,get_from_copy/1,has_buff/1]).

-export([do_hprecover/3,do_mprecover/3,generate_hprecover/2,
		 generate_mprecover/2,stop_mprecover/0,stop_hprecover/0,export_for_db/0,get_buff_casterinfo/1]).

-export([get_buffers_cast_by_pet/0]).
-compile(export_all).
%%
%% API Functions
%%
%% buffinfo: {BuffId,{Bufflevel,StartTime},CasterInfo}
%% CasterInfo : {CasterId,Name}/{0,Type} Type:ride/...
%%  
init()->
	put(buffinfo,[]).
	
has_buff(BuffId)->
	lists:keymember(BuffId,1,get(buffinfo)).
	
get_buff_info(BuffId)->
	case lists:keyfind(BuffId,1,get(buffinfo)) of
		false->
			[];
		{BuffId,{BuffLevel,_},_}->
			{BuffId,BuffLevel}
	end.

get_buff_start_ttime(BuffId)->
	case lists:keyfind(BuffId,1,get(buffinfo)) of
		false->
			[];
		{_,{_,StartTime},_}->
			StartTime
	end.

get_buff_casterinfo(BuffId)->
	case lists:keyfind(BuffId,1,get(buffinfo)) of
		false->
			{0,[]};	
		 {BuffId,{_,_},CasterInfo}->
			CasterInfo
	end.
	
%%[{BufferId,BufferLevel}]
get_buffers_by_class(Class)->
	lists:foldl(fun({BufferId,{BuffLevel,_},_},AccBuff)-> 
					BufferInfo = buffer_db:get_buffer_info(BufferId, BuffLevel),	
					case buffer_db:get_buffer_class(BufferInfo) of
						Class->
							[{BufferId,BuffLevel}|AccBuff];
						_->			
							AccBuff
					end
			end,[],get(buffinfo)).

get_buffers_cast_by_ride()->
	lists:foldl(fun({BuffId,{BuffLevel,_},{CasterId,Name}},AccBuffs)->
			case (Name=:=ride) and (CasterId=:=0) of
				true->
					[{BuffId,BuffLevel}|AccBuffs];	
				_->
					AccBuffs
			end
		end,[],get(buffinfo)).

get_buffers_cast_by_pet()->
	lists:foldl(fun({BuffId,{BuffLevel,_},{CasterId,_}},AccBuffs)->
			case creature_op:what_creature(CasterId) of
				pet->
					[{BuffId,BuffLevel}|AccBuffs];	
				_->
					AccBuffs
			end
		end,[],get(buffinfo)).

get_cancel_buffs_by_type(EventType)->
	lists:filter(fun({BufferId, BufferLevel})-> 
		BufferInfo2 = buffer_db:get_buffer_info(BufferId, BufferLevel), 
		lists:member(EventType,buffer_db:get_buffer_deadcancel(BufferInfo2)) 
	end,get(current_buffer)).

%%private	
insert(BuffId,Bufflevel,StartTime,CasterInfo)->
	case lists:keyfind(BuffId,1,get(buffinfo)) of
		false->
			put(buffinfo,get(buffinfo)++[{BuffId,{Bufflevel,StartTime},CasterInfo}]);	
		_ ->
			nothing
	end.	
	
remove(BuffId)->
	put(buffinfo,lists:keydelete(BuffId,1,get(buffinfo))).

%%[{BuffId,Bufflevel,StartTime,CasterInfo}]		
load_from_db(AllBuffersInfo)->	
	lists:foldl(fun({BuffId,Bufflevel,StartTime,CasterInfo},AllBuff)->
		BufferInfo = buffer_db:get_buffer_info(BuffId, Bufflevel),						
		DurationTime = buffer_db:get_buffer_duration(BufferInfo),
		LeftTime = DurationTime - erlang:trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000),
		case LeftTime > 0  of %%or (DurationTime =:= -1) not use.
		 	true->		 	
		 		AllBuff ++ [{BuffId,Bufflevel,StartTime,CasterInfo}];
		  	false->		  					  		
		  		AllBuff 
	 end end,[],AllBuffersInfo).

export_for_db()->
	lists:map(fun({BuffId,{Bufflevel,StartTime},CasterInfo})->{BuffId,Bufflevel,StartTime,CasterInfo} end,get(buffinfo)).

get_from_copy(AllBuffersInfo)->
	lists:map(fun({BuffId,{Bufflevel,StartTime},CasterInfo})->{BuffId,Bufflevel,StartTime,CasterInfo} end,AllBuffersInfo).
	
export_for_copy()->
	get(buffinfo).		
	
do_hprecover(HpRecInt,CurHp,CurrAttributes)->
	HpMax = attribute:get_current(CurrAttributes, hpmax),
 	HpRec = attribute:get_current(CurrAttributes, hprecover),
	NewHp = erlang:min(CurHp + HpRec,HpMax),
	HpChange = NewHp - CurHp,
	SendMsg = {hprecover_interval,HpRecInt},
	case timer_util:send_after(HpRecInt, SendMsg) of
		{ok,TimerId}-> put(hprecover_timer,TimerId);
		{error,Reason}-> slogger:msg("do_hprecover error :~p\n",[Reason])
	end,
	{hp,HpChange}.

generate_hprecover(ClassId,Level)->
	case get(hprecover_timer) of
		undefined->		
			ClassBase = role_db:get_class_base(ClassId, Level),
			HpRecInt = role_db:get_class_hprecoverinterval(ClassBase),
			SendMsg = {hprecover_interval,HpRecInt},
			case timer_util:send_after(HpRecInt, SendMsg) of
				{ok,TimerId}-> put(hprecover_timer,TimerId);
				{error,Reason}-> slogger:msg("generate_hprecover error:~p\n",[Reason])
			end;
		_->
			io:format("generate_hprecover duplicate ~n"),
			nothing
	end.

do_mprecover(MpRecInt,CurMp,CurrAttributes)->	
	MpMax = attribute:get_current(CurrAttributes, mpmax),
 	MpRec = attribute:get_current(CurrAttributes, mprecover),		   	
	NewMp = erlang:min(CurMp + MpRec,MpMax),
	MpChange = NewMp - CurMp,
	SendMsg = {mprecover_interval,MpRecInt},
	case timer_util:send_after(MpRecInt, SendMsg) of
		{ok,TimerId}-> put(mprecover_timer,TimerId);
		{error,Reason}-> slogger:msg("do_mprecover error:~p\n",[Reason])
	end,
	{mp,MpChange}.

generate_mprecover(ClassId, Level)->
	case get(mprecover_timer) of
		undefined->
			ClassBase = role_db:get_class_base(ClassId, Level),
			MpRecInt = role_db:get_class_mprecoverinterval(ClassBase),
			SendMsg = {mprecover_interval,MpRecInt},
			case timer_util:send_after(MpRecInt, SendMsg) of
				{ok,TimerId}-> put(mprecover_timer,TimerId);
				{error,Reason}-> slogger:msg("generate_mprecover error:~p\n",[Reason])
			end;
		_->
			%%io:format("generate_mprecover duplicate ~n"),
			nothing
	end.

stop_mprecover()->
	try 
		case get(mprecover_timer) of
			undefined -> o;
			TimerId ->
				erlang:cancel_timer(TimerId)				
		end
	catch 
		_:_-> o 
	end,
	erase(mprecover_timer).

stop_hprecover()->
	try 
		case get(hprecover_timer) of
			undefined ->o;
			TimerId ->
				erlang:cancel_timer(TimerId)							
		end
	catch 
		_:_-> o 
	end,
	erase(hprecover_timer).

%%return: { attr_changed,{BufferId,Level},ChangedAttrs } / {remove,{BufferId,Level}}
%% ChangedAttrs : [{Attr,Value}]
do_interval({{BufferId,Level},StartTime,LeftTimes,IntervalTime,FunctionEffects,SkillInput})->
	case LeftTimes of
		0-> 
			case get_buff_start_ttime(BufferId) of
				StartTime->
					{remove,{BufferId,Level}};
				_->	%%last buff's timer,not current 
					{changattr,{BufferId,Level},[]}
			end;
		_-> generate_interval(BufferId,Level,StartTime,LeftTimes,IntervalTime,FunctionEffects,SkillInput),
			ScriptsResult = 
			lists:foldl(fun({Effect,EffectArg},ResultTmp)->
				case ResultTmp of
					remove->
						ResultTmp;
					_->
						{Eff_Mod,Eff_Fun} = effect:get_effect_module(Effect),
						case apply(Eff_Mod,Eff_Fun,[EffectArg,SkillInput]) of
							remove->
								remove;
							NewResult->
								ResultTmp++NewResult
						end
				end
			end,[], FunctionEffects),
			case ScriptsResult of
				remove ->
					{remove,{BufferId,Level}};
				ChangeAttrs ->
					{changattr,{BufferId,Level},ChangeAttrs}
			end
	end.

%%
%% SkillInput dependence the skill,maybe: skill destroy; skill heal;hpmax ;mpmax

generate_interval(BufferId,Level,SkillInput,StartTime,CasterInfo)->
	BufferInfo = buffer_db:get_buffer_info(BufferId, Level),
	OriDurationTime = buffer_db:get_buffer_duration(BufferInfo),		
	UsedTime = erlang:trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000),
	if 
		(UsedTime <1000) or (OriDurationTime =:= -1) ->DurationTime = OriDurationTime;
		true -> DurationTime = erlang:max(0,OriDurationTime - UsedTime)
	end,						
	IntervalTime = buffer_db:get_buffer_effect_interval(BufferInfo),
	
	{SendAfterTime,LeftTimes,FunctionEffects} =
		case  get_buffer_function_effect(BufferInfo) of
			[]->		%%无timer触发效果,DurationTime秒后删除
				{DurationTime,0,[]};				
			BuffFunctionEffects ->
				case IntervalTime of
					0-> 	%%触发一次
						{DurationTime,1,BuffFunctionEffects};
					_-> 
						if
							(DurationTime=:= -1)->
								SendTime = IntervalTime,
								DuTimes = infinity;
							true->
								SendTime = IntervalTime - erlang:trunc(DurationTime - erlang:trunc(DurationTime/IntervalTime)*IntervalTime),
								DuTimes = util:even_div(DurationTime,IntervalTime)
						end,
						{SendTime,DuTimes,BuffFunctionEffects}										
				end
		end,
	if
		SendAfterTime=:=-1->		%%无特殊效果的非时间,持续性buff
			nothing;
		true->
			SendMsg = {buffer_interval,{{BufferId,Level},StartTime,LeftTimes,IntervalTime,FunctionEffects,SkillInput}},
			case timer_util:send_after(SendAfterTime, SendMsg) of
				{ok,TimerId}-> put_timer(BufferId,TimerId);
				{error,Reason}-> slogger:msg("buffer_op +++++++~p+++ BufferId ~p,Level ~p\n",[Reason,BufferId,Level])
			end
	end,
	insert(BufferId,Level,StartTime,CasterInfo).

generate_interval(BufferId,Level,StartTime,LeftTimes,IntervalTime,FunctionEffects,SkillInput)->
	case LeftTimes of
		0-> nothing;
		_ ->
			if
				LeftTimes =:= infinity->
					NextLeftTimes = infinity;
				true->
					NextLeftTimes  = LeftTimes -1
			end,
			SendMsg = {buffer_interval,{{BufferId,Level},StartTime,NextLeftTimes,IntervalTime,FunctionEffects,SkillInput}},
			case timer_util:send_after(IntervalTime, SendMsg) of
				{ok,TimerId}-> put_timer(BufferId,TimerId);
				{error,Reason}-> slogger:msg("buffer_op +++++++~p+++ BufferId ~p ,Level ~p\n",[Reason,BufferId,Level])
			end,
			{effect,BufferId}
	end.
	
remove_buffer(BufferId)->
	try 
		TimerId = get_timer(BufferId),
		erlang:cancel_timer(TimerId)
	catch 
		_:_-> o 
	end,
	erase({buffer_timer,BufferId}),
	remove(BufferId).

%%
%% Local Functions
%%

get_timer(BufferId)->
	get({buffer_timer,BufferId}).

put_timer(BufferId,TimerId)->
	case get_timer(BufferId) of
		undefined-> o;
		OldTimerId -> timer:cancel(OldTimerId)
	end,
	put({buffer_timer,BufferId},TimerId).

%%
%%	Hook
%%
%%return:new ChangedAttr
hook_on_beattack(OriDamage,OriChangeAttr)->
	case get_buff_info(?MAGIC_SHIELD_BUFF) of
		[]->
			OriChangeAttr;
		{BuffId,BuffLevel}->
			if
				OriDamage<0->
					magic_shield:hook_on_beattack(OriDamage,OriChangeAttr,{BuffId,BuffLevel});
				true->
					OriChangeAttr
			end
	end.

cancel_buff_c2s(BufferId)->
	case get_buff_info(BufferId) of
		[]->
			nothing;	
		{BufferId,BuffLevel}->
			BufferInfo = buffer_db:get_buffer_info(BufferId, BuffLevel),
			case buffer_db:get_can_active_cancel(BufferInfo) of
				0->
					nothing;
				_->
					case buffer_db:get_buffer_class(BufferInfo) of
						?BUFF_CLASS_RIDE->
							role_ride_op:proc_dismount_ride();
						?BUFF_CLASS_HPPACKAGE->
							hp_package_gift:stop_hp_package();
						?BUFF_CLASS_MPPACKAGE->
							mp_package_gift:stop_mp_package();
						?BUFF_CLASS_SITDOWN->
							role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),cancel);
						_->
							role_op:remove_buffer({BufferId,BuffLevel})
					end	
			end
	end.
	
get_buffer_attr_effect(BufferId,BufferLevel)->
	BufferInfo = buffer_db:get_buffer_info(BufferId, BufferLevel),
	Effects = buffer_db:get_buffer_effect_list(BufferInfo),
	EffectArguments = buffer_db:get_buffer_effect_arguments(BufferInfo),
	{_,EffectTules} = 
		lists:foldl(fun(Effect,{N,LastEffects})-> 
			case effect:is_attr_effect(Effect) of
				true->
					EffectTuple = {Effect,lists:nth(N, EffectArguments)},
					{N+1,LastEffects++[EffectTuple]};
				_->
					{N+1,LastEffects}
			end end,{1,[]}, Effects),
	EffectTules.	

get_buffer_function_effect(BufferInfo)->
	Effects = buffer_db:get_buffer_effect_list(BufferInfo),
	EffectArguments = buffer_db:get_buffer_effect_arguments(BufferInfo),
	{_,EffectTules} = 
		lists:foldl(fun(Effect,{N,LastEffects})-> 
			case effect:is_function_effect(Effect) of
				true->
					EffectTuple = {Effect,lists:nth(N, EffectArguments)},
					{N+1,LastEffects++[EffectTuple]};
				_->
					{N+1,LastEffects}
			end end,{1,[]}, Effects),
	EffectTules.	
	
	