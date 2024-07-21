%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
%% copy following code to module db_ini
%%
	

%%
%% add table timelimit_gift config to ebin/game_server.option
%%

%%
%% this file create by template
%% Author :
%% Created : 2011-03-23
%% Description : TODO

-module(timelimit_gift_db).

-define(ETS_TABLE_NAME,timelimit_gift_ets).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("mnesia_table_def.hrl").

-export([get_role_info/1,save_role_info/6]).

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
	db_tools:create_table_disc(timelimit_gift,record_info(fields,timelimit_gift),[],set),
	db_tools:create_table_disc(role_timelimit_gift,record_info(fields,role_timelimit_gift),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{timelimit_gift,proto},{role_timelimit_gift,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_timelimit_gift, RoleId).

create()->
	ets:new(?ETS_TABLE_NAME,[set,named_table]).

init()->
	db_operater_mod:init_ets(timelimit_gift, ?ETS_TABLE_NAME,#timelimit_gift.id).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%%format [{Index,Time,DropList}]
%%
%%
%% return : Value | []
%%
get_droplist(TableInfo)->
	element(#timelimit_gift.droplist,TableInfo).	

get_role_info(RoleId)->
	case dal:read_rpc(role_timelimit_gift, RoleId) of
		{ok,[RoleTLGiftInfo]}-> RoleTLGiftInfo;
		_-> []
	end.

save_role_info(RoleId,LastIndex,LastTime,NewDurationTime,GiftTime,ItemList)->
	WriteObj = #role_timelimit_gift{roleid=RoleId,last_gift_index = LastIndex,last_gift_time = {LastTime,NewDurationTime,GiftTime},last_gift = ItemList,ext = []},
	dal:write_rpc(WriteObj).