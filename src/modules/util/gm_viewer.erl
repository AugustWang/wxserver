%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-26
%% Description: TODO: Add description to gm_viewer
-module(gm_viewer).

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

get_roledictionary(RoleId)->
	case node_util:get_mapnodes() of
		[]-> io:format("can not find map node ~n");
		[MapNode|_]->
			Term = rpc:call(MapNode, role_pos_util, where_is_role, [RoleId]),
			RoleNode = erlang:element(4,Term),
			io:format("~p~n",[rpc:call(RoleNode,role_manager,get_role_info,[RoleId])])
	end.

%%
%% Local Functions
%%

