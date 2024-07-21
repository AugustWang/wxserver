%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: PC17
%% Created: 2010-10-6
%% Description: TODO: Add description to feedback_op
-module(feedback_op).
%%
%% Exported Functions
%%
-export([submit_feedback/6,info_back/3]).

%%
%% Include files
%%

%%
%% API Functions
%%
submit_feedback(RoleName, RoleId, Type, Title , Content, ContactWay) ->
	LineKeyValue = [{"cmd","feedback"},
					{"roleid", RoleId},
					{"rolename", RoleName},
					{"type", Type},
					{"title", Title},
					{"content", Content},
					{"contactway", ContactWay}
		 ],
	gm_msgwrite:write(feedback,LineKeyValue).

info_back(Type,Info,Version)->
	LineKeyValue = [{"cmd","infoback"},
					{"type", Type},
					{"info", Info},
					{"version", Version}
		 ],
	gm_msgwrite:write(infoback,LineKeyValue).
	
%%
%% Local Functions
%%
 

