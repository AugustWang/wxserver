%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2011-1-7
%% Description: TODO: Add description to role_create_deploy
-module(role_create_deploy).

%%
%% Include files
%%
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([create/7]).

%%
%% API Functions
%%

%%
%% Local Functions
%%

create(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId)->
	case db_template:create_template_role({Gender,ClassId},RoleName, AccountName,ServerId) of
		{ok,RoleId}-> case RoleName of
						  {visitor,RName} ->
							  gm_logger_role:create_role(AccountName,AccountId,RName,RoleId,ClassId,Gender,CreateIp,true);
						  _->
							  gm_logger_role:create_role(AccountName,AccountId,RoleName,RoleId,ClassId,Gender,CreateIp,false)
					  end,
					  {ok,RoleId};
		_-> {failed,?ERR_CODE_CREATE_ROLE_INTERL}
	end.
