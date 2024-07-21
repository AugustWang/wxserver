%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author:xiaowu
%% Created: 2013-5-2
%% Description: TODO: Add description to astrology_db
-module(astrology_db).

%%
%% Include files
%%
-include("astrology_def.hrl").

-define(MNESIA_ASTROLOGY_TABLE,astrology).
-define(MNESIA_ASTROLOGY_PACKAGE_TABLE,astrology_package).
-define(MNESIA_ASTROLOGY_ADD_ROLE_ATTRIBUTE_TABLE,astrology_add_role_attribute).
-define(MNESIA_ASTROLOGY_ADD_MONEY_TIME_TABLE,astrology_add_money_time).
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).


%%
%% API Functions
%%



%%
%% Local Functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(astrology,record_info(fields,astrology),[],set),
	db_tools:create_table_disc(astrology_package, record_info(fields,astrology_package), [], set),
	db_tools:create_table_disc(astrology_add_role_attribute,record_info(fields,astrology_add_role_attribute),[],set),
	db_tools:create_table_disc(astrology_add_money_time,record_info(fields,astrology_add_money_time),[],set).
create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{astrology,proto},{astrology_package,proto},{astrology_add_role_attribute,proto},{astrology_add_money_time,disc}].

delete_role_from_db(RoleId)->
	lists:foreach(fun(AstrologyInfo)->
					case astrology_db:get_id(AstrologyInfo) of
						RoleId->
							dal:delete_object_rpc(AstrologyInfo);
						_->
							nothing
					end
	end,get_astrology_info()).

delete_astrology_package_role_from_db(RoleId)->
	lists:foreach(fun(AstrologyPackageInfo)->
					case astrology_db:get_id(AstrologyPackageInfo) of
						RoleId->
							dal:delete_object_rpc(AstrologyPackageInfo);
						_->
							nothing
					end
	end,get_astrology_info()).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_astrology_info()->
	case dal:read_rpc(?MNESIA_ASTROLOGY_TABLE) of
		{ok,AstrologyInfo}->AstrologyInfo;
		_->[]
	end.


save_astrology_info(RoleId,StarInfo,Money,Pos,Start_time)->
	dal:write_rpc({?MNESIA_ASTROLOGY_TABLE,RoleId,StarInfo,Money,Pos,Start_time}).

del_astrology(RoleId)->	
	dal:delete_rpc(?MNESIA_ASTROLOGY_TABLE,RoleId).

get_astrology_info_by_roleid(RoleId)->
	case dal:read_rpc(?MNESIA_ASTROLOGY_TABLE,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_id_from_astrology(AstrologyInfo)->
	erlang:element(#astrology.roleid, AstrologyInfo).

get_starinfo_from_astrology(AstrologyInfo)->
	erlang:element(#astrology.starinfo, AstrologyInfo).

get_money_from_astrology(AstrologyInfo)->
	erlang:element(#astrology.money, AstrologyInfo).

get_pos_from_astrology(AstrologyInfo)->
	erlang:element(#astrology.pos, AstrologyInfo).

get_start_time_from_astrology(AstrologyInfo)->
	erlang:element(#astrology.start_time, AstrologyInfo).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_astrology_package_info()->
	case dal:read_rpc(?MNESIA_ASTROLOGY_PACKAGE_TABLE) of
		{ok,AstrologyPackageInfo}->AstrologyPackageInfo;
		_->[]
	end.


save_astrology_package_info(RoleId,PackageInfo,UnlockNum)->
	dal:write_rpc({?MNESIA_ASTROLOGY_PACKAGE_TABLE,RoleId,PackageInfo,UnlockNum}).

del_astrology_package(RoleId)->	
	dal:delete_rpc(?MNESIA_ASTROLOGY_PACKAGE_TABLE,RoleId).

get_astrology_package_info_by_roleid(RoleId)->
	case dal:read_rpc(?MNESIA_ASTROLOGY_PACKAGE_TABLE,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.
get_packageinfo_from_astrology_package_info(AstrologyPackageInfo)->
	erlang:element(#astrology_package.packageinfo, AstrologyPackageInfo).

get_unlocknum_from_astrology_package_info(AstrologyPackageInfo)->
	erlang:element(#astrology_package.unlocknum, AstrologyPackageInfo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_astrology_add_role_attribute_info(RoleId,Star_use_info)->
	dal:write_rpc({?MNESIA_ASTROLOGY_ADD_ROLE_ATTRIBUTE_TABLE,RoleId,Star_use_info}).

save_astrology_add_money_time_info(RoleId,Starttime)->%%å°†å¼€å¯é¢æ¿æ—¶é—´å­˜å…¥
	dal:write_rpc({?MNESIA_ASTROLOGY_ADD_MONEY_TIME_TABLE,RoleId,Starttime}).

get_starttime_from_astrology(RoleId)->%%èŽ·å¾—ä¸Šæ¬¡å¼€å¯é¢æ¿æ—¶é—´
	case dal:read_rpc(?MNESIA_ASTROLOGY_ADD_MONEY_TIME_TABLE,RoleId) of
		{ok,[Info]}->
			{_,_,Starttime}=Info,
			Starttime;
		_->
			[]
	end.

del_astrology_add_role_attribute(RoleId)->	
	dal:delete_rpc(?MNESIA_ASTROLOGY_ADD_ROLE_ATTRIBUTE_TABLE,RoleId).

get_astrology_add_role_attribute_info_by_roleid(RoleId)->
	case dal:read_rpc(?MNESIA_ASTROLOGY_ADD_ROLE_ATTRIBUTE_TABLE,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_id_from_aarainfo(AARAInfo)->
	erlang:element(#astrology_add_role_attribute.roleid, AARAInfo).

get_star_use_info_from_aarainfo(AARAInfo)->
	erlang:element(#astrology_add_role_attribute.star_use_info, AARAInfo).


