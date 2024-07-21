%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(map_script).

-include("pvp_define.hrl").
%%
%% Include files
%%
%%
%% Exported Functions
%%
-compile(export_all).
-include("data_struct.hrl").
-include("map_info_struct.hrl").
-include("role_struct.hrl").
-include("activity_define.hrl").
%%Key : on_leave/on_join

run_script(Key)->
	MapId = get_mapid_from_mapinfo(get(map_info)), 
	case map_info_db:get_map_info(MapId) of
		[]->
			nothing;
		MapProtoInfo->
			map_script:run_script(Key,MapProtoInfo)
	end.
  
run_script(Key,MapProtoInfo)->
	Scripts = map_info_db:get_script(MapProtoInfo),
	case lists:keyfind(Key,1,Scripts) of
		false->
			nothing;
		{_,MapFun,MapArgs}->
			apply_script(MapFun,MapArgs)
	end.

apply_script(Fun,Args)->
	try
		erlang:apply(?MODULE,Fun, Args)
	catch
		Errno:Reason -> 	
			slogger:msg("apply_script error fun:~p  ~p:~p ~n",[Fun,Errno,Reason])			
	end.

change_pkmodel(PkModel)->
	CurModel = pvp_op:get_pkmodel(),
	if
		(CurModel=:=?PVP_MODEL_PEACE)or (CurModel=:=?PVP_MODEL_PUNISHER)->
			pvp_op:proc_set_pkmodel(PkModel,timer_center:get_correct_now());
		true->
			nothing
	end.

%%组队进入副本后，进行判断，如果队员是和平或惩戒模式则切为和平模式，若非和平和惩戒模式则自动切换为组队模式；%%
%%该规则的具体要求问策划%%
group_change_pkmodel(PkModel)->
	CurModel = pvp_op:get_pkmodel(),
	if
		(CurModel=:=?PVP_MODEL_PEACE)or (CurModel=:=?PVP_MODEL_PUNISHER)->
			pvp_op:proc_set_pkmodel(?PVP_MODEL_PEACE,timer_center:get_correct_now());
		true->
			pvp_op:proc_set_pkmodel(?PVP_MODEL_TEAM,timer_center:get_correct_now())
	end.


delete_buffs(BuffIds)->
	BuffWithLevels = lists:foldl(fun(BuffId,BuffsTmp)-> 
		case buffer_op:get_buff_info(BuffId) of
			[]->
				BuffsTmp;
			BuffInfo->
				[BuffInfo|BuffsTmp]
		end
	end,[],BuffIds),
	role_op:remove_buffers(BuffWithLevels).

%%[{Gender,[Id]}]
delete_buffs_by_gender(GenderBuffIds)->
	CurInfo = get(creature_info),
	Gender = get_gender_from_roleinfo(CurInfo),
	case lists:keyfind(Gender, 1, GenderBuffIds) of
		false->
			nothing;
		{_,BuffIds}->
			delete_buffs(BuffIds)
	end.

%%[{Gender,[{Id,Level}]}]
add_buffs_by_gender(GenderBuffs)->
	CurInfo = get(creature_info),
	Gender = get_gender_from_roleinfo(CurInfo),
	case lists:keyfind(Gender, 1, GenderBuffs) of
		false->
			nothing;
		{_,Buffs}->
			role_op:add_buffers_by_self(Buffs)
	end.
	
add_buffs_by_timepoint(Buffs)->
	IsTimePoint = guild_instance:check_is_timepoint(),
	if
		IsTimePoint->
			activity_value_op:update({join_activity,?GUILD_INSTANCE_ACTIVITY}),
			role_op:add_buffers_by_self(Buffs);
		true->
			ignor
	end.

