%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(sitdown_packet).

-include("error_msg.hrl").
-include("login_pb.hrl").

-export([handle/2,handle_companion_sitdown/2]).

-export([encode_companion_sitdown_apply_s2c/1,encode_companion_sitdown_result_s2c/1,encode_companion_reject_s2c/1]).

handle(#sitdown_c2s{},RolePid)->
	util:send_state_event(RolePid, {sitdown_c2s,[]});

handle(#stop_sitdown_c2s{},RolePid)->
	util:send_state_event(RolePid, stop_sitdown_c2s);

handle(#companion_sitdown_start_c2s{roleid = RoleId},RolePid)->
	util:send_state_event(RolePid, {sitdown_c2s,RoleId}).

handle_companion_sitdown(Msg,RolePid)->
	RolePid ! {companion_sitdown,Msg}.

encode_companion_sitdown_apply_s2c(RoleId)->
	login_pb:encode_companion_sitdown_apply_s2c(#companion_sitdown_apply_s2c{roleid = RoleId}).

encode_companion_sitdown_result_s2c(RoleId)->
	login_pb:encode_companion_sitdown_result_s2c(#companion_sitdown_result_s2c{result = RoleId}).

encode_companion_reject_s2c(RoleName)->
	login_pb:encode_companion_reject_s2c(#companion_reject_s2c{rolename = RoleName}).