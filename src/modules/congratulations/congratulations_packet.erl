%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-4-14
%% Description: TODO: Add description to congratulations_packet
-module(congratulations_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([handle/2,process_congratulations/1]).
-export([encode_congratulations_levelup_remind_s2c/3,encode_congratulations_levelup_receive_s2c/6,
		 encode_congratulations_levelup_s2c/3,encode_congratulations_error_s2c/1]).

%%
%% API Functions
%%
handle(Message=#congratulations_levelup_c2s{}, RolePid)->
	RolePid!{congratulations,Message};
handle(Message=#congratulations_received_c2s{}, RolePid)->
	RolePid!{congratulations,Message}.

process_congratulations(#congratulations_levelup_c2s{level=Level,roleid=RoleId,type=Type})->
	congratulations_op:congratulations_levelup_c2s(Level,RoleId,Type);
process_congratulations(#congratulations_received_c2s{level=Level,rolename=RoleName})->
	congratulations_op:congratulations_received_c2s(Level,RoleName).
	
encode_congratulations_levelup_remind_s2c(RoleId,RoleName,Level)->
	login_pb:encode_congratulations_levelup_remind_s2c(#congratulations_levelup_remind_s2c{roleid=RoleId,rolename=RoleName,level=Level}).
encode_congratulations_levelup_s2c(Exp,SoulPower,Remain)->
	login_pb:encode_congratulations_levelup_s2c(#congratulations_levelup_s2c{exp=Exp,soulpower=SoulPower,remain=Remain}).
encode_congratulations_levelup_receive_s2c(Exp,SoulPower,Type,RoleName,Level,RoleId)->
	login_pb:encode_congratulations_receive_s2c(#congratulations_receive_s2c{exp=Exp,soulpower=SoulPower,type=Type,rolename=RoleName,level=Level,roleid=RoleId}).
encode_congratulations_error_s2c(Reason)->
	login_pb:encode_congratulations_error_s2c(#congratulations_error_s2c{reason=Reason}).
%%
%% Local Functions
%%

