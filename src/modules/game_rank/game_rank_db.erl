%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(game_rank_db).

%%
%% Include files
%%
-include("game_rank_def.hrl").
%%
%% Exported Functions
%%

-compile(export_all).

%%baseinfo:{RoleName,RoleClass,RoleGender,RoleServerId}
%%-record(rank_role_db,{roleid,baseinfo,equipments,guild_name,level,viptag,disdain_num,praised_num}).
-behaviour(db_operater_mod).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(game_rank_db, record_info(fields,game_rank_db), [], set);

create_mnesia_table(ram)->
	db_tools:create_table_ram(rank_role_db, record_info(fields,rank_role_db),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	lists:foreach(fun(Object)->
					case Object of
						{{Type,RoleId},Info,Time}->
							NewObject={game_rank_db,{Type,RoleId},Info,Time},
							dal:delete_object_rpc(NewObject);
			
						_->
							nothing
					end end, load_from_db()).
	
tables_info()->
	[{game_rank_db,disc},{rank_role_db,ram}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_from_db()->
	case dal:read_rpc(game_rank_db) of
		{ok,Result}->lists:map(fun({_,TypeRoleId,Info,Time})->{TypeRoleId,Info,Time}end, Result);
		_->[]
	end.

delete_from_game_rank_db(Type,RoleId)->
	dal:delete_rpc(game_rank_db, {Type,RoleId}).

add_to_game_rank_db(Type,RoleId,Info,Time)->
	dal:write_rpc({game_rank_db,{Type,RoleId},Info,Time}).

get_rank_role_info(Roleid)->
	case dal:read(rank_role_db,Roleid) of
		{ok,[R]}->R;
		_->[]
	end.

get_name_from_rank_role_info(RankRoleInfo)->
	{RoleName,_,_,_} = erlang:element(#rank_role_db.baseinfo,RankRoleInfo),
	RoleName.

get_class_from_rank_role_info(RankRoleInfo)->
	{_,RoleClass,_,_} = erlang:element(#rank_role_db.baseinfo,RankRoleInfo),
	RoleClass.

get_gender_from_rank_role_info(RankRoleInfo)->
	{_,_,RoleGender,_} = erlang:element(#rank_role_db.baseinfo,RankRoleInfo),
	RoleGender.

get_serverid_from_rank_role_info(RankRoleInfo)->
	{_,_,_,RoleServerId} = erlang:element(#rank_role_db.baseinfo,RankRoleInfo),
	RoleServerId.

get_equipments_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.equipments,RankRoleInfo).

get_guild_name_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.guild_name,RankRoleInfo).

get_level_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.level,RankRoleInfo).

get_viptag_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.viptag,RankRoleInfo).

get_disdain_num_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.disdain_num,RankRoleInfo).

get_praised_num_from_rank_role_info(RankRoleInfo)->
	erlang:element(#rank_role_db.praised_num,RankRoleInfo).

reg_rank_role_to_mnesia(Roleid,Baseinfo,Equipments,Guild_name,Level,Viptag,Disdain_num,Praised_num)->
	role_server_travel:safe_do_in_travels(?MODULE,reg_rank_role_to_db,[Roleid,Baseinfo,Equipments,Guild_name,Level,Viptag,Disdain_num,Praised_num]).

unreg_rank_role_from_mnesia(RoleId)->
	role_server_travel:safe_do_in_travels(?MODULE,unreg_rank_role_from_db,[RoleId]).

update_role_equipments_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.equipments,Value]).

update_role_guild_name_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.guild_name,Value]).

update_role_level_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.level,Value]).

update_role_viptag_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.viptag,Value]).

update_role_disdain_num_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.disdain_num,Value]).

update_role_praised_num_to_mnesia(RoleId,Value)->
	role_server_travel:safe_do_in_travels(?MODULE,update_role_rank_value_to_db,[RoleId,#rank_role_db.praised_num,Value]).

%%base opt 
update_role_rank_value_to_db(RoleId,Index, Value)->
	dal:write(rank_role_db, RoleId,Index, Value).			

reg_rank_role_to_db(Roleid,Baseinfo,Equipments,Guild_name,Level,Viptag,Disdain_num,Praised_num)->
	dal:write({rank_role_db,Roleid,Baseinfo,Equipments,Guild_name,Level,Viptag,Disdain_num,Praised_num}).

unreg_rank_role_from_db(RoleId)->
	dal:delete(rank_role_db,RoleId).
