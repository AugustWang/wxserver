%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%author zhaoyan
%%date 7.14
-module(game_rank_manager_op).

-include("game_rank_define.hrl").
-include("mnesia_table_def.hrl").
-include("item_define.hrl").
-include("system_chat_define.hrl").

%%{RoleId,Types}
-define(ROLE_INFO_BACK_ETS,rank_role_info_ets).
-define(ROLE_INFO_BACK_TYPES_POS,2).		

-compile(export_all).

-define(REFRESH_GATHER_TIME,600000).		%%10min


init()->
	DbData = game_rank_db:load_from_db(),
	%%not db in travel
	ets:new(?ROLE_INFO_BACK_ETS,[set,named_table]),
	AllRoleRankInfo = lists:foldl(fun({{Type,RoleId},_,_},RankInfoTmp)->
						if
							%(Type =:= ?RANK_TYPE_CHESS_SPIRITS_TEAM) or (Type =:= ?RANK_TYPE_PET_TALENT_SCORE) or is_tuple(Type)->%ç”¨ä¸‹é¢æ›¿æ¢ã€å°äº”ã€‘
							(Type =:= ?RANK_TYPE_CHESS_SPIRITS_TEAM) or (Type =:= ?RANK_TYPE_PET_TALENT_SCORE) or (Type =:= ?RANK_TYPE_PET_FIGHTING_FORCE) or (Type =:= ?RANK_TYPE_PET_GROWTH) or (Type =:= ?RANK_TYPE_PET_QUALITY_VALUE) or is_tuple(Type)->%jia[xiaowu]
								RankInfoTmp;
							true ->
								case lists:keyfind(RoleId, 1, RankInfoTmp) of
									false->
										[{RoleId,[Type]}|RankInfoTmp];
									{RoleId,TypesTmp}->
										lists:keyreplace(RoleId, 1, RankInfoTmp,{RoleId,[Type|TypesTmp]})
								end
						end
					end,[], DbData),
	lists:foreach(fun({RoleId,TopTypes})->
			try
				add_role_info_to_rank(RoleId,TopTypes)
			catch
				E:R-> slogger:msg("add_role_info_to_rank role ~p type ~p E ~p R ~p S ~p ~n",[RoleId,TopTypes,E,R,erlang:get_stacktrace()])
			end
			end, AllRoleRankInfo),
	lists:foreach(fun(Type)->erlang:apply(get_module_by_type(Type), load_from_data, [DbData]) end, lists:seq(1, ?RANK_TYPE_ENDEX)),
	erlang:send_after(?REFRESH_GATHER_TIME,self(),refresh_rank).

disdain_role(RoleId,Disdan_RoleId,LeftNum,MyName)->
	case get_role_judge_info(Disdan_RoleId) of
		[]->
			nothing;
		{DisDainNum,PraisedNum}-> 
			game_rank_db:update_role_disdain_num_to_mnesia(Disdan_RoleId,DisDainNum+1),
			rank_judge_db:add_to_judge_num(Disdan_RoleId,DisDainNum+1,PraisedNum),
			OtherMessage = game_rank_packet:encode_rank_judge_to_other_s2c(?DISDAIN,MyName),
			role_pos_util:send_to_role_clinet(Disdan_RoleId,OtherMessage),
			Message = game_rank_packet:encode_rank_judge_opt_result_s2c(Disdan_RoleId,DisDainNum+1,PraisedNum,LeftNum),
			role_pos_util:send_to_role_clinet(RoleId,Message),
			case get_broadcast_type(?DISDAIN,DisDainNum+1) of
				false ->
					nothing;
				{SysId,Num} ->
					case game_rank_db:get_rank_role_info(Disdan_RoleId) of
						[]->
							[];
						RoleRankInfo->
							RoleName = game_rank_db:get_name_from_rank_role_info(RoleRankInfo),
							RoleServerId = game_rank_db:get_serverid_from_rank_role_info(RoleRankInfo),
							system_broadcast(SysId,{RoleName,Disdan_RoleId,RoleServerId},Num)
					end
			end
	end.

praised_role(RoleId,Parised_RoleId,LeftNum,MyName)->
	case get_role_judge_info(Parised_RoleId) of
		[]->
			nothing;
		{DisdainNum,PraisedNum}-> 
			game_rank_db:update_role_praised_num_to_mnesia(Parised_RoleId,PraisedNum+1),
			rank_judge_db:add_to_judge_num(Parised_RoleId,DisdainNum,PraisedNum+1),
			OtherMessage = game_rank_packet:encode_rank_judge_to_other_s2c(?PARISED,MyName),
			role_pos_util:send_to_role_clinet(Parised_RoleId,OtherMessage),
			Message = game_rank_packet:encode_rank_judge_opt_result_s2c(Parised_RoleId,DisdainNum,PraisedNum+1,LeftNum),
			role_pos_util:send_to_role_clinet(RoleId,Message),
			case get_broadcast_type(?PARISED,PraisedNum+1) of
				false ->
					nothing;
				{SysId,Num} ->
					case game_rank_db:get_rank_role_info(Parised_RoleId) of
						[]->
							[];
						RoleRankInfo->
							RoleName = game_rank_db:get_name_from_rank_role_info(RoleRankInfo),
							RoleServerId = game_rank_db:get_serverid_from_rank_role_info(RoleRankInfo),
							system_broadcast(SysId,{RoleName,Parised_RoleId,RoleServerId},Num)
					end
			end
	end.

watch_roleinfo(RoleId,Watched_RoleId,Leftnum)->
	case game_rank_db:get_rank_role_info(Watched_RoleId) of
		[]->
			[];
		RoleRankInfo->
			RoleName = game_rank_db:get_name_from_rank_role_info(RoleRankInfo),
			RoleClass = game_rank_db:get_class_from_rank_role_info(RoleRankInfo), 
			RoleGender = game_rank_db:get_gender_from_rank_role_info(RoleRankInfo),
%%			RoleServerId = game_rank_db:get_serverid_from_rank_role_info(RoleRankInfo),
			GuildName = game_rank_db:get_guild_name_from_rank_role_info(RoleRankInfo),
			RoleEquipMents = game_rank_db:get_equipments_from_rank_role_info(RoleRankInfo),
			RoleLevel = game_rank_db:get_level_from_rank_role_info(RoleRankInfo),
			VipTag = game_rank_db:get_viptag_from_rank_role_info(RoleRankInfo),
			Disdain_num = game_rank_db:get_disdain_num_from_rank_role_info(RoleRankInfo),
			Praised_num = game_rank_db:get_praised_num_from_rank_role_info(RoleRankInfo),
			SendItems = lists:map(fun(PlayerItemTmp)->pb_util:to_item_info_by_playeritem(PlayerItemTmp) end, RoleEquipMents),
			{Cloth,Arm} = item_util:get_cloth_and_arm_by_playeritems(RoleEquipMents),
			Message = game_rank_packet:encode_rank_get_rank_role_s2c(Watched_RoleId,RoleName,RoleClass,RoleGender,GuildName,RoleLevel,Cloth,Arm,VipTag,SendItems,Disdain_num,Praised_num,Leftnum),
			role_pos_util:send_to_role_clinet(RoleId,Message)
	end.

%%RankKey:RoleId/{Teamaters'Name,now()}
challenge(RankKey,Type,Info)->
	erlang:apply(get_module_by_type(Type), challenge_rank, [RankKey,Info]).

gather(RoleId,Type,Info)->
	erlang:apply(get_module_by_type(Type), gather, [RoleId,Info]).

mul_gather(GatherList)->
	lists:foreach(fun({RoleId,Type,Info})->
			erlang:apply(get_module_by_type(Type), gather, [RoleId,Info])			  
		end, GatherList).
  
refresh_rank()->
	lists:foreach(fun(Type)->erlang:apply(get_module_by_type(Type), refresh_gather, []) end, lists:seq(1, ?RANK_TYPE_ENDEX)),
	update_all_role_info_from_db(),			%%todo
	erlang:send_after(?REFRESH_GATHER_TIME,self(),refresh_rank).
  
get_rank_list(Info,Type)->
	erlang:apply(get_module_by_type(Type),send_rank_list, [Info]).

get_role_top_types(RoleId)->
	AllTopType = [?RANK_TYPE_ROLE_LEVEL,?RANK_TYPE_ROLE_SILVER,?RANK_TYPE_ANSWER,?RANK_TYPE_ROLE_TANGLE_KILL,
				  ?RANK_TYPE_FIGHTING_FORCE],
	lists:filter(fun(Type)->erlang:apply(get_module_by_type(Type),is_top, [RoleId]) end, AllTopType).

lose_rank(RoleId,Type)->
	case get_role_rank_type(RoleId) of
		[]->
			nothing;
		OriTopTypes->
			case lists:delete(Type, OriTopTypes) of
				[]->
					%%lose all rank
					delete_role_info_from_rank(RoleId);
				LeftTypes->
					ets:update_element(?ROLE_INFO_BACK_ETS,RoleId,{?ROLE_INFO_BACK_TYPES_POS,LeftTypes})
			end
	end,
	game_rank_db:delete_from_game_rank_db(Type,RoleId).

lose_rank_not_role(RankKey,Type)->
	game_rank_db:delete_from_game_rank_db(Type,RankKey).

join_rank(RoleId,Type,Info,Time)->
	case get_role_rank_type(RoleId) of
		[]->			%%new role in all rank
			add_role_info_to_rank(RoleId,[Type]);
		OriTopTypes->			%% has in rank
			case lists:member(Type, OriTopTypes) of
				false->					%% new rank
					ets:update_element(?ROLE_INFO_BACK_ETS,RoleId,{?ROLE_INFO_BACK_TYPES_POS,[Type|OriTopTypes]});
				_->						%%pos in rank changed.
					nothing
			end
	end,
	game_rank_db:add_to_game_rank_db(Type,RoleId,Info,Time).

join_rank_not_role(RankKey,Type,Info,Time)->
	game_rank_db:add_to_game_rank_db(Type,RankKey,Info,Time).

update_rank(RoleId,Type,Info,Time)->
	game_rank_db:add_to_game_rank_db(Type,RoleId,Info,Time).

lose_top(RoleId,Type)->
	Info = {lost_top_type,Type},
	role_pos_util:send_to_role(RoleId, {role_game_rank,Info}).
  
lose_top_not_role(RoleId,RankInfo)->
	Info = {lost_top_type_not_role,RankInfo},
	role_pos_util:send_to_role(RoleId, {role_game_rank,Info}).

join_top(RoleId,Type)->
	Info = {join_top_type,Type},
	role_pos_util:send_to_role(RoleId, {role_game_rank,Info}).

join_top_not_role(RoleId,RankInfo)->
	Info = {join_top_type_not_role,RankInfo},
	role_pos_util:send_to_role(RoleId, {role_game_rank,Info}).

%%get_role_back_info(RoleId)->
%%	case get_role_info(RoleId) of
%%		[]->
%%			nothing;
%%		{RoleId,{RoleName,RoleClass,RoleGender,_RoleServerId,GuildName,VipTag,Level},EquipMents,_}->
%%			Cloth = get_display_by_item_slot(?ITEM_TYPE_CHEST,EquipMents),
%%			Arm =  get_display_by_item_slot(?ITEM_TYPE_MAINHAND,EquipMents),
%%			Items = lists:map(fun(PlayerItemTmp)->pb_util:to_item_info_by_playeritem(PlayerItemTmp) end,EquipMents),
%%			Msg = game_rank_packet:encode_rank_get_rank_role_s2c(RoleId,RoleName,RoleClass,RoleGender,GuildName,
%%								Level,Cloth,Arm,VipTag,Items,Be_disdain,Be_praised,Left_judge),
%%			role_pos_util:send_to_role_clinet(RoleId, Msg)
%%	end.

get_display_by_item_slot(Slot,EquipMents)->
	case lists:keyfind(Slot,#playeritems.slot, EquipMents) of
		false->
			0;
		PlayerItem->
			 #playeritems{entry = Entry} = PlayerItem,
			 Entry
	end.

get_role_base_info_from_db(RoleId)->
	case role_db:get_role_info(RoleId) of
		[]->
			{[],1,1,0,[],0,0};
		RoleInfo ->
			RoleName = role_db:get_name(RoleInfo),
			RoleClass = role_db:get_class(RoleInfo),
			RoleGender = role_db:get_sex(RoleInfo),
			RoleLevel = role_db:get_level(RoleInfo),
			RoleServerId = server_travels_util:get_serverid_by_roleid(RoleId), 
			GuildName = 
				case role_db:get_guildid(RoleInfo) of
					0->
						[];
					GuildId-> 
						case guild_spawn_db:get_guildinfo(GuildId) of
							[]->
								[];
							GuildInfo->
								guild_spawn_db:get_guild_name(GuildInfo)
						end
				end,
			VipTag = 
				case vip_db:get_vip_role(RoleId) of
					{ok,[]}->
						0;
					{ok,VipInfo}->
						vip_db:get_vip_level(VipInfo)
				end,
			{RoleName,RoleClass,RoleGender,RoleServerId,GuildName,VipTag,RoleLevel}
	end.

get_role_equipments_from_db(RoleId)->
	AllDbEquipments = playeritems_db:load_role_equipments(RoleId),
	lists:map(fun(ItemTmp)-> items_op:make_playeritem_by_db(ItemTmp) end,AllDbEquipments).

update_all_role_info_from_db()->
	ets:foldl(fun({RoleId,_},_)-> load_role_from_db_to_rank_role(RoleId),[] end,[], ?ROLE_INFO_BACK_ETS).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									Ets opt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_role_judge_info(RoleId)->
	case game_rank_db:get_rank_role_info(RoleId) of
		[]->
			[];
		RoleRankInfo->
			DisDainNum = game_rank_db:get_disdain_num_from_rank_role_info(RoleRankInfo),
			PraisedNum = game_rank_db:get_praised_num_from_rank_role_info(RoleRankInfo),
			{DisDainNum,PraisedNum}
end.

%%return []/{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}
get_role_baseinfo(RoleId)->
	case game_rank_db:get_rank_role_info(RoleId) of
		[]->
			[];
		RoleRankInfo->
			RoleName = game_rank_db:get_name_from_rank_role_info(RoleRankInfo),
			RoleClass = game_rank_db:get_class_from_rank_role_info(RoleRankInfo), 
			RoleGender = game_rank_db:get_gender_from_rank_role_info(RoleRankInfo),
			RoleServerId = game_rank_db:get_serverid_from_rank_role_info(RoleRankInfo),
			GuildName = game_rank_db:get_guild_name_from_rank_role_info(RoleRankInfo),
			{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}
	end.

%%return []/{RoleId,TopTypes}
get_role_rank_type(RoleId)->
	case ets:lookup(?ROLE_INFO_BACK_ETS, RoleId) of
		[]->
			[];
		[{RoleId,TopTypes}]->
			TopTypes
	end.

add_role_info_to_rank(RoleId,TopTypes)->
	ets:insert(?ROLE_INFO_BACK_ETS, {RoleId,TopTypes}),
	load_role_from_db_to_rank_role(RoleId).

load_role_from_db_to_rank_role(RoleId)->
	{Role_name,RoleClass,RoleGender,RoleServerId,GuildName,VipTag,RoleLevel} = get_role_base_info_from_db(RoleId),
	RoleEquipMents = get_role_equipments_from_db(RoleId),
	RoleName = util:safe_binary_to_list(Role_name),
	Baseinfo = {RoleName,RoleClass,RoleGender,RoleServerId},
	case rank_judge_db:get_role_judge_num(RoleId) of
		[]->
			rank_judge_db:add_to_judge_num(RoleId,0,0),
			game_rank_db:reg_rank_role_to_mnesia(RoleId,Baseinfo,RoleEquipMents,GuildName,RoleLevel,VipTag,0,0);
		{RoleId,Disdain_num,Praised_num} ->
			game_rank_db:reg_rank_role_to_mnesia(RoleId,Baseinfo,RoleEquipMents,GuildName,RoleLevel,VipTag,Disdain_num,Praised_num)
	end.
				
delete_role_info_from_rank(RoleId)->
	game_rank_db:unreg_rank_role_from_mnesia(RoleId),
	ets:delete(?ROLE_INFO_BACK_ETS, RoleId).

get_module_by_type(Type)->
	case Type of
		?RANK_TYPE_ROLE_LEVEL->
			module_level_rank;
		?RANK_TYPE_ROLE_SILVER->
			module_money_rank;
		?RANK_TYPE_PET_FIGHTING_FORCE->%åŠ [xiaowu]
			module_pet_fighting_force_rank;
		?RANK_TYPE_PET_QUALITY_VALUE->%åŠ [xiaowu]
			module_pet_quality_value_rank;
		?RANK_TYPE_PET_GROWTH->
			module_pet_growth_rank;
		?RANK_TYPE_LOOP_TOWER_MASTER->
			module_loop_tower_rank;
%%		?RANK_TYPE_MAGIC_POWER->
%%			module_magic_rank;
%%		?RANK_TYPE_RANGE_POWER->
%%			module_range_rank;
%%		?RANK_TYPE_MELLE_POWER->
%%			module_melee_rank;
		?RANK_TYPE_ROLE_TANGLE_KILL->
			module_killer_rank;
		?RANK_TYPE_LOOP_TOWER_NUM->			%%?RANK_TYPE_LOOP_TOWER_NUM
			module_loop_tower_num_rank;
		?RANK_TYPE_CHESS_SPIRITS_SINGLE->
			module_chess_spirits_single_rank;
		?RANK_TYPE_CHESS_SPIRITS_TEAM->
			module_chess_spirits_team_rank;
		?RANK_TYPE_PET_TALENT_SCORE->
			module_pet_talent_score_rank;
		?RANK_TYPE_FIGHTING_FORCE->
			module_fighting_force_rank;
		?RANK_TYPE_MAIN_LINE->
			module_main_line_rank;
%% 		?RANK_TYPE_ACHIEVE_VALUE->%%add by wb 20130530
%% 			module_achieve_rank;
		{?RANK_TYPE_MAIN_LINE,_}->
			module_main_line_rank;
		_->
			module_answer_rank
	end.

%%Args:
%%	Type = ?PARISED/?DISDAIN,JudgeNum = Num
%%return: 
%%	{SysId,Num}/false
get_broadcast_type(Type,JudgeNum)->
	case Type of
		?DISDAIN ->
			if JudgeNum =:= ?JUDGE_RANK_NUM_1 ->
		   			{?SYSTEM_CHAT_RANK_TYPE_1,JudgeNum};
	   			JudgeNum =:= ?JUDGE_RANK_NUM_2 ->
			   		{?SYSTEM_CHAT_RANK_TYPE_2,JudgeNum};
		   		JudgeNum =:= ?JUDGE_RANK_NUM_3 ->
			   		{?SYSTEM_CHAT_RANK_TYPE_3,JudgeNum};
	   			JudgeNum =:= ?JUDGE_RANK_NUM_4 ->
		   			{?SYSTEM_CHAT_RANK_TYPE_4,JudgeNum};
	   			(JudgeNum > ?JUDGE_RANK_NUM_4) and ((JudgeNum rem ?JUDGE_RANK_NUM_1) =:= 0)->
		   			{?SYSTEM_CHAT_RANK_TYPE_4,JudgeNum};
	   			true ->
		   			false
			end;
		?PARISED ->
			if JudgeNum =:= ?JUDGE_RANK_NUM_1 ->
		   			{?SYSTEM_CHAT_RANK_TYPE_5,JudgeNum};
	   			JudgeNum =:= ?JUDGE_RANK_NUM_2 ->
			   		{?SYSTEM_CHAT_RANK_TYPE_6,JudgeNum};
		   		JudgeNum =:= ?JUDGE_RANK_NUM_3 ->
			   		{?SYSTEM_CHAT_RANK_TYPE_7,JudgeNum};
	   			JudgeNum =:= ?JUDGE_RANK_NUM_4 ->
		   			{?SYSTEM_CHAT_RANK_TYPE_8,JudgeNum};
	   			(JudgeNum > ?JUDGE_RANK_NUM_4) and ((JudgeNum rem ?JUDGE_RANK_NUM_1) =:= 0)->
		   			{?SYSTEM_CHAT_RANK_TYPE_8,JudgeNum};
	   			true ->
		   			false
			end
	end.

system_broadcast(SysId,{Name,RoleId,ServerId},Num)->
	RoleName = util:safe_binary_to_list(Name),
	ParamRole = chat_packet:makeparam(role,{RoleName,RoleId,ServerId}),
	ParamNum = chat_packet:makeparam(int,Num),
	MsgInfo = [ParamRole,ParamNum],
	system_chat_op:system_broadcast(SysId,MsgInfo).

hook_on_role_change_name(RoleId,NewNameStr)->
	{Role_name,RoleClass,RoleGender,RoleServerId,GuildName,VipTag,RoleLevel} = get_role_base_info_from_db(RoleId),
	RoleEquipMents = get_role_equipments_from_db(RoleId),
	Baseinfo = {NewNameStr,RoleClass,RoleGender,RoleServerId},
	case rank_judge_db:get_role_judge_num(RoleId) of
		[]->
			rank_judge_db:add_to_judge_num(RoleId,0,0),
			game_rank_db:reg_rank_role_to_mnesia(RoleId,Baseinfo,RoleEquipMents,GuildName,RoleLevel,VipTag,0,0);
		{RoleId,Disdain_num,Praised_num} ->
			game_rank_db:reg_rank_role_to_mnesia(RoleId,Baseinfo,RoleEquipMents,GuildName,RoleLevel,VipTag,Disdain_num,Praised_num)
	end.
	




