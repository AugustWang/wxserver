%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-29
%% Description: TODO: Add description to venation_advanced_db
-module(venation_advanced_db).

%%
%% Include files
%%
-include("venation_def.hrl").
-define(ETS_TABLE_NAME,venation_advanced_ets).
%%
%% Exported Functions
%%
-compile(export_all).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_venation_advanced,record_info(fields,role_venation_advanced),[],set),
	db_tools:create_table_disc(venation_advanced,record_info(fields,venation_advanced),[],bag).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_venation_advanced,RoleId).

tables_info()->
	[{venation_advanced,proto},{role_venation_advanced,disc}].

create()->
	ets:new(?ETS_TABLE_NAME, [set,named_table]).

init()->
	db_operater_mod:init_ets(venation_advanced, ?ETS_TABLE_NAME,#venation_advanced.venationinfo).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_venation_info(Venation,Level)->
	case ets:lookup(?ETS_TABLE_NAME, {Venation,Level}) of
		[]-> [];
		[{_,VenationInfo}]-> VenationInfo
	end.

get_venation_effect(VenationInfo)->
	element(#venation_advanced.effect,VenationInfo).

get_venation_success_rate(VenationInfo)->
	element(#venation_advanced.success_rate,VenationInfo).

get_venation_need_money(VenationInfo)->
	element(#venation_advanced.need_money,VenationInfo).

get_venation_useitem(VenationInfo)->
	element(#venation_advanced.useitem,VenationInfo).

get_venation_consumeitem(VenationInfo)->
	element(#venation_advanced.protect_item,VenationInfo).

get_venation_need_gold(VenationInfo)->
	element(#venation_advanced.need_gold,VenationInfo).

get_role_venation_info(RoleId)->
	case dal:read_rpc(role_venation_advanced,RoleId) of
		{ok,[{_,RoleId,VenationInfo}]}-> VenationInfo;
		_-> []
	end.

add_to_role_venation_advanced(RoleId,VenationInfo)->
	dal:write_rpc({role_venation_advanced,RoleId,VenationInfo}).
