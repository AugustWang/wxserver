%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-13
%% Description: TODO: Add description to npc_mainline_defend
-module(npc_mainline_defend).

%%
%% Include files
%%
%%
%% Exported Functions
%%
-export([proc_special_msg/1,init/0,on_dead/0]).

-include("npc_struct.hrl").

-define(CHECK_TIME_INTERVAL,2000).

%%
%% API Functions
%%
init()->
	%%send_update_message(),
	send_check().

send_check()->		
	erlang:send_after(?CHECK_TIME_INTERVAL,self(),npc_mainline_defend_check).

on_dead()->
	send_update_message(),
	CreatureInfo = get(creature_info),
	MyProto = get_templateid_from_npcinfo(CreatureInfo),
	broad_msg_to_whole_map({mainline_internal_msg,{npc_bekilled,MyProto}}).


proc_special_msg(npc_mainline_defend_check)->
	update();

proc_special_msg(_)->
  	nothing.
	

%%
%% Local Functions
%%

update()->
	send_update_message(),
	CreatureInfo = get(creature_info),
	case creature_op:is_creature_dead(CreatureInfo) of
		true->
			nothing;
		_->
			send_check()	
	end.
	

broad_msg_to_whole_map(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_creature(RoleId,Msg) end,mapop:get_map_roles_id()). 

broad_msg_to_whole_map_clinet(Msg)->
	lists:foreach(fun(RoleId)->npc_op:send_to_other_client(RoleId, Msg) end,mapop:get_map_roles_id()). 

send_update_message()->
	CreatureInfo = get(creature_info),
	MyProto = get_templateid_from_npcinfo(CreatureInfo),
	MaxHp = get_hpmax_from_npcinfo(CreatureInfo),
	CurHp = get_life_from_npcinfo(CreatureInfo),
	UpdateMsg = mainline_packet:encode_mainline_protect_npc_info_s2c(MyProto,MaxHp,CurHp),
	broad_msg_to_whole_map_clinet(UpdateMsg).
	