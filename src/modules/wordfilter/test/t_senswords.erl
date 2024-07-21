%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-9
%% Description: TODO: Add description to t_senswords
-module(t_senswords).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([test/0]).

%%
%% API Functions
%%

test()->
	env:init(),
	senswords:init(),
	BinString = <<"娓稿001">>,
	senswords:word_is_sensitive(BinString).
