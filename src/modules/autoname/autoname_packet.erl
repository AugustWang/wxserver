%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-20
%% Description: TODO: Add description to autoname_packet
-module(autoname_packet).

%%
%% Include files
%%
-export([handle/2]).
-export([encode_init_random_rolename_s2c/2]).
-include("login_pb.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
handle(_Message,_RolePid)->
	ok.

encode_init_random_rolename_s2c(BoyName,GirlName)->
	login_pb:encode_init_random_rolename_s2c(#init_random_rolename_s2c{bn=BoyName,gn=GirlName}).

%%
%% Local Functions
%%

