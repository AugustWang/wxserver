%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_manager_op).
-include("common_define.hrl").
-compile(export_all).


%%-define(BUFFER_TIME_S,130).	%%130s earlier startup and 2*130s delayed shutdown 

-define(CHECK_TIME,10000).	%%10s check




init()->
	tangle_battle_manager_op:init(),
	yhzq_manager_op:init(),
	jszd_battle_manager_op:init(),
	guild_instance_manager_op:init(),
	send_check_message().

on_check()->
	tangle_battle_manager_op:on_check(),
	yhzq_manager_op:on_check(),
	jszd_battle_manager_op:on_check(),
	guild_instance_manager_op:on_check(),
	send_check_message().


send_check_message()->
	erlang:send_after(?CHECK_TIME,self(),{battle_check}).


on_start_battle(?TANGLE_BATTLE)->
	tangle_battle_manager_op:on_start_battle();

on_start_battle(_)->
	nothing.

on_battle_end(?TANGLE_BATTLE)->
	tangle_battle_manager_op:on_battle_end();

on_battle_end(?JSZD_BATTLE)->
	jszd_battle_manager_op:on_battle_end();

on_battle_end(_)->
	nothing.

apply_for_battle({?TANGLE_BATTLE,Info})->
	tangle_battle_manager_op:apply_for_battle(Info);
apply_for_battle({?JSZD_BATTLE,Info})->
	jszd_battle_manager_op:apply_for_battle(Info);
apply_for_battle(_)->
	nothing.

cancel_apply_battle({?TANGLE_BATTLE,Info})->
	tangle_battle_manager_op:cancel_apply_battle(Info);

cancel_apply_battle(_)->
	nothing.

battle_start_notify({?TANGLE_BATTLE,Info})->
	tangle_battle_manager_op:battle_start_notify(Info);

battle_start_notify({?JSZD_BATTLE,Info})->
	jszd_battle_manager_op:battle_start_notify(Info);

battle_start_notify(_)->
	nothing.

notify_manager_battle_start({?TANGLE_BATTLE,Info})->
	tangle_battle_manager_op:notify_manager_battle_start(Info);

notify_manager_battle_start(_)->
	nothing.

%%check_init_battle(?TANGLE_BATTLE)->
%%	tangle_battle_manager:check_init_battle();

%%check_init_battle(_)->
%%	nothing.
	
get_role_battle_info({?TANGLE_BATTLE,RoleId})->
	tangle_battle_manager_op:get_role_battle_info(RoleId);

get_role_battle_info(_)->
	nothing.

get_role_battle_kill_info({?TANGLE_BATTLE,Info})->
	%%io:format("Info:~p~n",[Info]),
	tangle_battle_manager_op:get_role_battle_kill_info(Info);
get_role_battle_kill_info(_)->
	nothing.

notify_manager_role_leave({?TANGLE_BATTLE,Info})->
	tangle_battle_manager_op:role_leave_battle(Info);

notify_manager_role_leave(_)->
	nothing.

check_battle_time(?TANGLE_BATTLE)->
	tangle_battle_manager_op:check_battle_time();

check_battle_time(?YHZQ_BATTLE)->
	yhzq_manager_op:check_battle_time();

check_battle_time(?JSZD_BATTLE)->
	jszd_battle_manager_op:check_battle_time();

check_battle_time(_)->
	nothing.

get_reward_by_manager({?TANGLE_BATTLE,RoleId})->
	tangle_battle_manager_op:get_role_battle_reward(RoleId);

get_reward_by_manager(_)->
	nothing.

apply_yhzq(Info)->
	yhzq_manager_op:apply_yhzq(Info).

reject_to_join_yhzq(Info)->
	yhzq_manager_op:reject_to_join_yhzq(Info).

cancel_apply_yhzq(Info)->
	yhzq_manager_op:cancel_apply_yhzq(Info).

change_yhzq_state(Info)->
	yhzq_manager_op:change_yhzq_state(Info).
			
get_tangle_battle_curenum()->
	tangle_battle_manager_op:get_tangle_battle_curenum().
		




