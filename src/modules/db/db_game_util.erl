%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(db_game_util).


-export([delete_all_unuesd_role/0]).
-export([rename_guild_in_db/2,rename_role_in_db/2]).

-include("guild_define.hrl").

-define(OFFLINE_TIME_DURATION,2592000000000).		%%30day

delete_all_unuesd_role()->
	AllDeleteRoles = get_all_unused_role(),
	lists:foreach(fun(RoleId)->delete_roleid_from_db(RoleId) end, AllDeleteRoles),
	AllDeleteRoles.	

rename_role_in_db(RoleId,NewName)->
	%%1.roleattr
	RoleInfoDB = role_db:get_role_info(RoleId),
	RoleInfoInDB1 = role_db:put_name(RoleInfoDB,NewName),
	role_db:flush_role(RoleInfoInDB1),
	%%2.friend,black
	friend_db:change_role_name_in_db(RoleId,NewName).
	
rename_guild_in_db(GuildId,NewName)->
	guild_spawn_db:set_guild_name(GuildId,NewName).

delete_roleid_from_db(RoleId)->
	mod_util:behaviour_apply(db_operater_mod,delete_role_from_db,[RoleId]).

get_all_unused_role()->
	lists:foldl(fun(Table,Acc)->Acc++get_unused_roles_in_table(Table) end, [], db_split:get_splitted_tables(roleattr)).

get_unused_roles_in_table(RoleDbTab)->
	F = fun()->
			mnesia:foldl(fun(RoleInfo,AccRoles)-> 
					case is_unused_role(RoleInfo) of
						true->
					  		[role_db:get_roleid(RoleInfo)|AccRoles];
						_->
							AccRoles
					end end,[],RoleDbTab)
		end,
	case mnesia:transaction(F) of
		{atomic,Result}->
			Result;
		Error->
			slogger:msg("get_unused_role_in_table RoleDbTab ~p Error ~p ~n",[RoleDbTab,Error]),
			[]
	end.

is_unused_role(RoleInfo)->
	RoleId = role_db:get_roleid(RoleInfo),
	LeveCheck = role_db:get_level(RoleInfo)=<35,
	TimeCheck = (timer:now_diff(now(),role_db:get_offline(RoleInfo)) >= ?OFFLINE_TIME_DURATION),
	GoldCheck = role_db:get_currencygold(RoleInfo) =:=0,
	GoldSumCheck = 	
		case vip_db:get_role_sum_gold(RoleId) of
			{ok,[]}->
				true;
			{ok,RoleSumInfo}->
				vip_db:get_sumgold_from_suminfo(RoleSumInfo)=:=0;
			_->
				true
		end,
	VipCheck = 
			case vip_db:get_vip_role(RoleId) of
				{ok,[]}->
					true;
				{ok,VipInfo}->
					vip_db:get_vip_level(VipInfo)=:=0;
				_->
					true
			end,
	GuildLeaderCheck = 
		case guild_spawn_db:get_guildinfo_of_member(RoleId) of
			[]->
				true;
			GuildMemberInfo->
				guild_spawn_db:get_authgroup_by_memberinfo(GuildMemberInfo) >= ?GUILD_POSE_MEMBER
		end,
	
	LeveCheck and TimeCheck and GoldCheck and GoldSumCheck and VipCheck and GuildLeaderCheck.
	
	
	
	