%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-26
%% Description: TODO: Add description to designation_packet
-module(designation_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([encode_designation_init_s2c/1,encode_designation_update_s2c/1,encode_inspect_designation_s2c/2]).

%%
%% API Functions
%%

encode_designation_init_s2c(DesignationInfo)->
	login_pb:encode_designation_init_s2c(#designation_init_s2c{designationid = DesignationInfo}).

encode_designation_update_s2c(DesignationInfo)->
%% 	io:format("DesignationInfo:~p~n",[DesignationInfo]),
	login_pb:encode_designation_update_s2c(#designation_update_s2c{designationid = DesignationInfo}).

encode_inspect_designation_s2c(RoleId,DesignationInfo)->
	login_pb:encode_inspect_designation_s2c(#inspect_designation_s2c{roleid = RoleId,designationid = DesignationInfo}).
%%
%% Local Functions
%%

