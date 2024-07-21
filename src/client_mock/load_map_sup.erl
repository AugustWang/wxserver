%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-6
%% Description: TODO: Add description to load_map_sup
-module(load_map_sup).
-behaviour(supervisor).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start_link/0]).
-export([init/1]).

%%
%% API Functions
%%
start_link()->
	supervisor:start_link({local,?MODULE},?MODULE,[]).

init([])->
	AChild = {load_map_process,{load_map_process,start_link,[]},
			  permanent,2000,worker,[load_map_process]},
	{ok,{{one_for_one,10,10},[AChild]}}.
%%
%% Local Functions
%%

