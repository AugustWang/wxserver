%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-10
%% Description: TODO: Add description to dialyzer_util
-module(dialyzer_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([usage/0,run/0]).

%%
%% API Functions
%%

usage()->
	io:format("~n~n~nPlease input: dialyzer_util:run().~n~n~n").


run()->
	dialyzer:gui().
