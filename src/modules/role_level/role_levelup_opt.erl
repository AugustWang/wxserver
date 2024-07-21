%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_levelup_opt).

-include("error_msg.hrl").
-include("login_pb.hrl").

-export([levelup_opt_c2s/1,init/1]).


init(RoleId)->
	AllLevels = role_level_db:load_role_levelup_opts_level(RoleId),
	Msg = role_level_packet:encode_add_levelup_opt_levels_s2c(AllLevels),
	role_op:send_data_to_gate(Msg).

levelup_opt_c2s(NewLevel)->
	MyId = get(roleid),
	case get(level) >= NewLevel of
		true->
			case role_level_db:is_have_done_levelup_opt(MyId,NewLevel) of
				true->
					slogger:msg("role_levelup_opt:hook_on_levelup error!has done MyId ~p NewLevel ~p ~n",[MyId,NewLevel]);
				error->
					slogger:msg("role_levelup_opt:hook_on_levelup error!is_have_done_levelup_opt error MyId ~p NewLevel ~p ~n",[MyId,NewLevel]);
				false->
					case role_level_db:get_levelup_opt_info(NewLevel) of
						[]->
							slogger:msg("role_levelup_opt:hook_on_levelup error Level ~p ~n",[NewLevel]);
						LevelInfo->	
							Items = role_level_db:get_levelup_opt_reward_items(LevelInfo),
							case package_op:can_added_to_package_template_list(Items) of
								false->							
									Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
									role_op:send_data_to_gate(Message);
								true->
									case role_level_db:get_levelup_opt_script(LevelInfo) of
										[]->
											ScriptRe = true;
										{Module,Fun,Args}->
											ScriptRe = exec_beam(Module,Fun,Args)
									end,
									if
										ScriptRe->
											lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_levelup) end,Items),
											role_level_db:write_level_up_done(MyId,NewLevel,[]),
											Msg = login_pb:encode_add_levelup_opt_levels_s2c(#add_levelup_opt_levels_s2c{levels = [NewLevel]}),
											role_op:send_data_to_gate(Msg);
										true->
											nothing
									end
							end
					end
			end;
		false->
			nothing
	end.
					
					
exec_beam(Mod,Fun,Args)->
	try 
		erlang:apply(Mod, Fun, Args)
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p Args: ~p ~p:~p ~n",[Mod,Fun,Args,Errno,Reason]),
			false
	end.						