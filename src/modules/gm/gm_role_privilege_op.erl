%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-5-12
%% Description: TODO: Add description to gm_role_privilege_op
-module(gm_role_privilege_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([export_for_copy/0,load_by_copy/1,write_to_db/0,load_from_db/1,
		 get_role_privilege/0
		]).
-include("common_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%
init()->
	put(role_privilege,0).

load_from_db(RoleId)->
	case gm_role_privilege_db:get_role_privilege(RoleId) of
		{ok,[]}->
			init();
		{ok,RolePrivilege}->
			{_,_RoleId,Privilege} = RolePrivilege,
			put(role_privilege,Privilege);
		_->
			init()
	end.

export_for_copy()->
	get(role_privilege).
	
write_to_db()->
	nothing.

load_by_copy(RolePrivilege)->
	put(role_privilege,RolePrivilege).

get_role_privilege()->
	get(role_privilege).
%%
%% Local Functions
%%
