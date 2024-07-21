%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-14
%% Description: TODO: Add description to gm_logger_hacking
-module(gm_logger_hacking).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%
role_hack(RoleId,RoleName,MapId,HackingIp,Type,Description)->
	LineKeyValue = [{"cmd","role_hack"},
					{"roleid",RoleId},
					{"rolename",RoleName},
					{"mapid",MapId},
					{"hackingip",HackingIp},
					{"type",Type},
					{"desc",Description}
		 ],
	gm_msgwrite:write(role_hack,LineKeyValue).

%%
%% Local Functions
%%

