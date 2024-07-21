%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-18
%% Description: TODO: Add description to npc_mail
-module(npc_storage_action).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-export([npc_storage_action/4,npc_storage_action/5]).

-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).


%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(npc_storage_action,?NPC_FUNCTION_STORAGE, ?MODULE).

registe_func(_)->
	Mod= ?MODULE,
	Fun= npc_storage_action,
	Arg= [],
	Response= #kl{key=?NPC_FUNCTION_STORAGE, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,NpcId)->
	role_op:send_items_on_storage(NpcId),
	{ok}.

npc_storage_action(_RoleInfo,_Arg,enum,NpcId)->
	role_op:send_items_on_storage(NpcId).
	

npc_storage_action(_RoleInfo,_Arg,swap_item,SrcSlot,DesSlot)->
	SrcPos = package_op:where_slot(SrcSlot),
	DesPos = package_op:where_slot(DesSlot),
	IsIllegal = (SrcSlot =:= DesSlot) or (not package_op:is_has_item_in_slot(SrcSlot)) or role_op:is_dead(),
	if
		(DesPos =:= error) or (SrcPos =:= error) or IsIllegal ->
			nothing;
		((SrcPos =:= storage) and ((DesPos =:= storage) or (DesPos =:= package)))
		  or 
		((DesPos =:= storage) and ((SrcPos =:= storage) or (SrcPos =:= package)))->
			role_op:process_swap_item(SrcSlot,DesSlot);
		true->
			nothing
	end.
	
	
	
