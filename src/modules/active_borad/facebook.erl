%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-7-26
%% Description: TODO: Add description to facebook
-module(facebook).

%%
%% Include files
%%

-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-define(FB_NOT_BIND,-1).
-define(SWITCH_CLOSE,0).
-define(SWITCH_OPEN,1).
-define(UNFINISHED,0).
-define(FINISHED,1).
%%
%% API Functions
%%
handle(_Msg,RolePid)->
	RolePid ! {facebook_bind_check}.

%%facebook bind state check
facebook_bind_check()->
	Switch = env:get(facebook_bind_switch,?SWITCH_CLOSE),
	if	Switch =:= ?SWITCH_OPEN ->	
%% 			io:format("facebook switch open~n"),
			FBID = get_facebook_bind_state(get(roleid)),
%% 			io:format("facebook_bind_check,FBID:~p~n",[FBID]),
			BinMsg = login_pb:encode_facebook_bind_check_result_s2c(#facebook_bind_check_result_s2c{fbid = FBID}),
			role_op:send_data_to_gate(BinMsg);
		true->
%% 			io:format("facebook switch not open~n"),
			nothing
	end.



facebook_quest_finished(RoleId,FaceBookId,MsgId)->
%% 	io:format("facebook_quest_finished,RoleId:~p,FaceBookId:~p,MsgId:~p~n",[RoleId,FaceBookId,MsgId]),
	Switch = env:get(facebook_bind_switch,?SWITCH_CLOSE),
	if	Switch =:= ?SWITCH_OPEN ->	
%% 			io:format("facebook switch open~n"),
			case get_facebook_quest_state(RoleId,MsgId) of 
				?UNFINISHED->
%% 					io:format("get_facebook_quest_state not finished~n"),
					case put_facebook_quest_state(RoleId,FaceBookId,MsgId) of
						{ok}->
							case role_pos_util:where_is_role(RoleId) of
								[]->
%% 									io:format("role:~p not online~n",[RoleId]),
									nothing;
								RolePos->
									Node = role_pos_db:get_role_mapnode(RolePos),
									Proc = role_pos_db:get_role_pid(RolePos),
								try
									gen_fsm:sync_send_all_state_event({Proc,Node}, {facebook_quest_update,MsgId},10000)
								catch
									E:R -> slogger:msg("~p ~pfacebook_bind_quest_update E ~p Reason:~p ~n",[Proc,?MODULE,E,R]),error
								end
							end,
							gm_logger_role:facebook_bind(RoleId,FaceBookId,MsgId,ok),
							{ok};
						{error,Reason}->
							slogger:msg("facebook database operate error ~n"),
							gm_logger_role:facebook_bind(RoleId,FaceBookId,MsgId,Reason),
							{error,database_failed}
					end;
				?FINISHED->
					gm_logger_role:facebook_bind(RoleId,FaceBookId,MsgId,hasfinished),
%% 					io:format(" get_facebook_quest_state has finished~n"),
					{error,hasfinished}
			end;
		true->
%% 			io:format("facebook switch not open~n"),
			{error,switch_close}
	end.

%%facebook update quest state online
init()->
%% 	io:format("facebook_update_quest_state~n"),
	Switch = env:get(facebook_bind_switch,?SWITCH_CLOSE),
	if
		Switch =:= ?SWITCH_OPEN ->
%% 			io:format("facebook switch open~n"),
			FBQuest = get_facebook_finished_quest(get(roleid)),
%% 			io:format("facebook_update_quest_state~p~n",[FBQuest]),
			lists:map(fun({_FBID,MsgId})->
							  quest_special_msg:proc_specail_msg({facebook_quest_state,MsgId})
					  end,FBQuest);
		true->
%% 			io:format("facebook switch not open~n"),
			nothing
	end.
			
%% 
%%db opterate 
%% 

%%return:has finished quest about facebook 
get_facebook_finished_quest(RoleId)->
	facebook_db:get_facebook_finished_quest(RoleId).

%%return:FBID or -1 
get_facebook_bind_state(RoleId)->
	case facebook_db:get_facebook_bind_state(RoleId) of
		[]->
			integer_to_list(?FB_NOT_BIND);
		FBID->
			FBID
	end.

%%return 1:finished,0:unfinished
get_facebook_quest_state(RoleId,MsgId)->
	FBQuest = facebook_db:get_facebook_finished_quest(RoleId),
	case lists:keyfind(MsgId,2,FBQuest) of
		false->
			?UNFINISHED;
		_->
			?FINISHED
	end.

%%put quest state to db 
put_facebook_quest_state(RoleId,FaceBookId,MsgId)->
	facebook_db:put_facebook_quest_state(RoleId,FaceBookId,MsgId).


gm_command(FBID,MsgId)->
	RoleId = get(roleid),
	Switch = env:get(facebook_bind_switch,?SWITCH_CLOSE),
	if Switch =:= ?SWITCH_OPEN ->
		   case get_facebook_quest_state(RoleId,MsgId) of
			   ?UNFINISHED->
%% 					io:format("get_facebook_quest_state not finished~n"),
				   case put_facebook_quest_state(RoleId,FBID,MsgId) of
					   {ok}->
%% 						   io:format("facebook_quest_state update:MsgId ~p~n",[MsgId]),
						   quest_special_msg:proc_specail_msg({facebook_quest_state,MsgId});
						{error,Reason}->
							gm_logger_role:facebook_bind(RoleId,FBID,MsgId,Reason),
							slogger:msg("facebook database error ~n")
					end;
				?FINISHED->
%% 					io:format(" get_facebook_quest_state has finished~n"),
					nothing
		   end;
	   true->
%% 		   io:format("facebook switch not open~n"),
		   nothing
	end.
	

	
%%
%% Local Functions
%%

