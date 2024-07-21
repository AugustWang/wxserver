%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-26
%% Description: TODO: Add description to designation_op
-module(designation_op).

%%
%% Exported Functions
%%

-export([init/1,export_for_copy/0,load_by_copy/1,get_designation_attr/0,change_designation/1,process_message/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("designation_def.hrl").
-define(DESIGNATION_DATA,designation_data_ets).

%%
%% API Functions
%%
%%designation_info:has gain designation [designationid]
%%cur_designation:current designation [designationid]
%%designation_attr_addition:[{attribute,point}] 

init(RoleId)->
	case designation_db:load_role_designation_info(RoleId) of
		[]->
%% 			io:format("first init designation info~n"),
			put(designation_info,[]),
			put(cur_designation,[]),
			put(designation_attr_addition,[]),
			designation_db:write_designationinfo_to_db(RoleId,[],[]);
		{_,_,CurDesignation,DesignationInfo}->
%% 			io:format("not first init designation info curdesignation:~p,designationinfo:~p~n",[CurDesignation,DesignationInfo]),
			put(designation_info,DesignationInfo),
			put(cur_designation,CurDesignation),
			DesignationAttrAddition = lists:foldl(fun(DesignationId,TmpAttrAdditon)->
														  DesignationData = designation_db:get_designation_data(DesignationId),
														  Tmp1AttrAddition= designation_db:get_attr_addition(DesignationData),
														  TmpAttrAdditon++Tmp1AttrAddition
												  end,[],CurDesignation),
%% 			io:format("DesignationAttrAddition:~p~n",[DesignationAttrAddition]),
			put(designation_attr_addition,DesignationAttrAddition)
	end,
%% 	io:format(" init designation_info:~p~n",[get(designation_info)]),
	Message = designation_packet:encode_designation_init_s2c(get(designation_info)),
	role_op:send_data_to_gate(Message).
	
	

export_for_copy()->
	{get(designation_info),
	 get(cur_designation),
	 get(designation_attr_addition)
	 }.

load_by_copy(Info)->
	{DesignationInfo,CurDesignation,DesignationAttrAddition} = Info,
	put(designation_info,DesignationInfo),
	put(cur_designation,CurDesignation),
	put(designation_attr_addition,DesignationAttrAddition).
		
		
get_designation_attr()->
	get(designation_attr_addition).							   


%%get new designation,change current designation 
change_designation(ArriveDesignation)->
%% 	io:format("ArriveDesignation:~p~n",[ArriveDesignation]),
	OldCurDesignation = get(cur_designation),
%% 	io:format("OldCurDesignation:~p,OldDesignationinfo:~p~n",[OldCurDesignation,get(designation_info)]),
	RemoveOldDesignation = fun(CurDesignationId)->
								   if
									   ArriveDesignation =< CurDesignationId->
										   true;
									   true->
										   false
								   end
						   end,
	TmpCurDesignation = lists:filter(RemoveOldDesignation,OldCurDesignation),
%% 	io:format("TmpCurDesignationList:~p~n",[TmpCurDesignation]),
	NewCurDesignation = [ArriveDesignation|TmpCurDesignation],
	put(cur_designation,NewCurDesignation),
	NewDesignationInfo = [ArriveDesignation|get(designation_info)],
	put(designation_info,NewDesignationInfo),
	NewDesignationAttrAddition = lists:foldl(fun(DesignationId,TmpAttrAdditon)->
														  DesignationData = designation_db:get_designation_data(DesignationId),
														  Tmp1AttrAddition= designation_db:get_attr_addition(DesignationData),
														  TmpAttrAdditon++Tmp1AttrAddition
												  end,[],NewCurDesignation),
	put(designation_attr_addition,NewDesignationAttrAddition),
	put(creature_info,set_cur_designation_to_roleinfo(get(creature_info),NewCurDesignation)),
%% 	io:format("NewCurDesignationList:~p~n",[NewCurDesignation]),
	role_op:self_update_and_broad([{cur_designation,NewCurDesignation}]),
	role_op:recompute_designation_attr(),
	Message = designation_packet:encode_designation_update_s2c(NewDesignationInfo),
	role_op:send_data_to_gate(Message),
%% 	io:format("NewCurDesignationList:~p,NewDesignationInfo:~p",[NewCurDesignation,NewDesignationInfo]),
	role_fighting_force:hook_on_change_role_fight_force(),
	designation_db:write_designationinfo_to_db(get(roleid),NewCurDesignation,NewDesignationInfo).
	
%%other_inspect_you
process_message({other_inspect_you,ServerId,RoleId})->
%%	todo.
	MsgBin = designation_packet:encode_inspect_designation_s2c(get(roleid),get(designation_info)), 
	%io:format("other_inspect_you,ServerId:~p,RoleId:~p,designation_info:~p~n",[ServerId,RoleId,get(designation_info)]),
	role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoleId,MsgBin).
%%
%% Local Functions
%%

