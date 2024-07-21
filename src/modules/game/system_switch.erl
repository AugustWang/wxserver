%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-25
%% Description: TODO: Add description to system_switch
-module(system_switch).
-include("common_define.hrl").
-include("login_pb.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2,send_system_switch_rpc/1,send_system_switch/1]).

%%
%% API Functions
%%

handle(#query_system_switch_c2s{sysid=SysIdKey},_RolePid)->
	{Cur,Flt} = env:get2(system_status, SysIdKey, {0,0}),
	Cur_Message = #system_status_s2c{sysid =SysIdKey,status= Cur},
	Cur_Binary = login_pb:encode_system_status_s2c(Cur_Message),
	
	Flt_Message = #system_status_s2c{sysid =SysIdKey,status= Flt},
	Flt_Binary = login_pb:encode_system_status_s2c(Flt_Message),
	tcp_client:send_data_filter(self(),Cur_Binary,Flt_Binary).
%%
%% Local Functions
%%
send_system_switch_rpc(SysIdKey)->
	case node_util:get_linenodes() of
		[]-> ignor;
		[LineNode|_]-> 
			rpc:call(LineNode, ?MODULE, send_system_switch, [SysIdKey])
	end.

send_system_switch(SysIdKey)->
	{Cur,Flt} = env:get2(system_status, SysIdKey, {0,0}),
	Cur_Message = #system_status_s2c{sysid =SysIdKey,status= Cur},
	Cur_Binary = login_pb:encode_system_status_s2c(Cur_Message),
	
	Flt_Message = #system_status_s2c{sysid =SysIdKey,status= Flt},
	Flt_Binary = login_pb:encode_system_status_s2c(Flt_Message),
	
	F = fun(RolePos)->
				GateProc = role_pos_db:get_role_gateproc(RolePos),
				tcp_client:send_data_filter( GateProc, Cur_Binary,Flt_Binary)
		end,
	role_pos_db:foreach(F).