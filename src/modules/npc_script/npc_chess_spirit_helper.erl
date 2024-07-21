%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_chess_spirit_helper).

-export([proc_special_msg/1,init/0]).

-define(CAST_TIME_INTERVAL,5000).			%%5s


init()->
	put(chess_spirit_helper_last_cast,{0,0,0}),
	put(chess_spirit_helper_cur_buff,[]),
	put(chess_spirit_helper_interval,?CAST_TIME_INTERVAL).

proc_special_msg({chess_helper_give_buff,{BuffId,BuffLevel}})->
	put(chess_spirit_helper_cur_buff,{BuffId,BuffLevel}),
	give_map_roles_buff();

proc_special_msg(chess_spirit_helper_check)->
	give_map_roles_buff();

proc_special_msg(_)->
	nothing.

cast_checker()->
	case get(chess_spirit_helper_check_timer) of
		undefined->
			nothing;
		Timer->
			erlang:cancel_timer(Timer)
	end,
	NewTimer = erlang:send_after(get(chess_spirit_helper_interval), self(),chess_spirit_helper_check),
	put(chess_spirit_helper_check_timer,NewTimer).

give_map_roles_buff()->
	case get(is_in_world) of
		true->
			case get(chess_spirit_helper_cur_buff) of
				[]->
					nothing;
				{BuffId,BuffLevel}->
					RoleList = mapop:get_map_roles_id(),
					BufferInfo = buffer_db:get_buffer_info(BuffId,BuffLevel),
					Duration = buffer_db:get_buffer_duration(BufferInfo),
					put(chess_spirit_helper_interval,Duration),
					lists:foreach(fun(Id)-> normal_ai:give_target_buff(Id,[{BuffId,BuffLevel}]) end, RoleList)
			end;
		_->
			nothing
	end,
	cast_checker().