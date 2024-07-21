%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-4-17
%% Description: 建立两个表，一个用来存储炼制丹药信息，一个用来存储使用丹药信息【小五】: Add description to furnace_db
-module(furnace_db).

%%
%% Include files
%%
-include("furnace_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([]).

%%
%% API Functions
%%
-define(MNESIA_FURNACE_TABLE,furnace).
-define(MNESIA_FURNACE_ADD_ROLE_ATTRIBUTE_TABLE,furnace_add_role_attribute).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).


%%
%% Local Functions
%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(furnace,record_info(fields,furnace),[],set),
	db_tools:create_table_disc(furnace_add_role_attribute,record_info(fields,furnace_add_role_attribute),[],set).
create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{furnace,proto},{furnace_add_role_attribute,proto}].

delete_role_from_db(RoleId)->
	lists:foreach(fun(FurnaceInfo)->
					case furnace_db:get_id(FurnaceInfo) of
						RoleId->
							dal:delete_object_rpc(FurnaceInfo);
						_->
							nothing
					end
	end,get_furnace_info()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_furnace_info()->
	case dal:read_rpc(?MNESIA_FURNACE_TABLE) of
		{ok,FurnaceInfo}->FurnaceInfo;
		_->[]
	end.

%%{id,roleinfo,nickname,items,create_time,ext}
%%items:{ItemId,Money} Moneys:{Silver,Gold,Ticket}

save_furnace_info(RoleId,RefineInfo,Furnace_Level)->
	dal:write_rpc({?MNESIA_FURNACE_TABLE,RoleId,RefineInfo,Furnace_Level}).

del_furnace(RoleId)->	
	dal:delete_rpc(?MNESIA_FURNACE_TABLE,RoleId).

get_furnace_info_by_roleid(RoleId)->
	case dal:read_rpc(?MNESIA_FURNACE_TABLE,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_id(FurnaceInfo)->
	erlang:element(#furnace.roleid, FurnaceInfo).

get_refineinfo(FurnaceInfo)->
	erlang:element(#furnace.refineinfo, FurnaceInfo).

get_furnace_level(FurnaceInfo)->
	erlang:element(#furnace.furnace_level, FurnaceInfo).




save_furnace_add_role_attribute_info(RoleId,Pill_use_info)->
	dal:write_rpc({?MNESIA_FURNACE_ADD_ROLE_ATTRIBUTE_TABLE,RoleId,Pill_use_info}).

del_furnace_add_role_attribute(RoleId)->	
	dal:delete_rpc(?MNESIA_FURNACE_ADD_ROLE_ATTRIBUTE_TABLE,RoleId).

get_furnace_add_role_attribute_info_by_roleid(RoleId)->
	case dal:read_rpc(?MNESIA_FURNACE_ADD_ROLE_ATTRIBUTE_TABLE,RoleId) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_id_from_farainfo(FARAInfo)->
	erlang:element(#furnace_add_role_attribute.roleid, FARAInfo).

get_pill_use_info_from_farainfo(FARAInfo)->
	erlang:element(#furnace_add_role_attribute.pill_use_info, FARAInfo).

