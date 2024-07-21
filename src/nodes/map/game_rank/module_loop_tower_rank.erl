%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_loop_tower_rank
-module(module_loop_tower_rank).

%%
%% Exported Functions
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(LOOP_TOWER_RANK_LIST,loop_tower_rank_list).

-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,is_top/1,refresh_gather/0,gather/2]).

%%
%% API Functions
%%
load_from_data(Data) ->
	case Data of
		[] ->
			put(?LOOP_TOWER_RANK_LIST,[]);
		_ ->
			case get(?LOOP_TOWER_RANK_LIST) of
				undefined ->
					RoleInfoList = fold_list(Data),
					put(?LOOP_TOWER_RANK_LIST,lists:reverse(lists:keysort(2, RoleInfoList)));
				[] ->
					RoleInfoList = fold_list(Data),
					put(?LOOP_TOWER_RANK_LIST,lists:reverse(lists:keysort(2, RoleInfoList)));
				_ ->
					lists:foreach(fun({RoleId,Count,Time})->
											challenge_rank(RoleId,Count)
									end,fold_list(Data))
			end
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,_},Acc)-> 
		   			case Type of
						?RANK_TYPE_LOOP_TOWER_MASTER ->
							{Count,Time} = Info,
							[{RoleId,Count,Time}|Acc];
						 _ ->
							Acc
					end
				end,[],Data).

is_top(RoleId)->
	case lists:keyfind(RoleId,1,get(?LOOP_TOWER_RANK_LIST)) of
		false ->
			false;
		_ ->
			true
	end.

%%Return:
%%	true|false
%%Args:
%%	Count = int,Time = int
can_challenge_rank({Count,Time})->
	case lists:keyfind(Count, 2, get(?LOOP_TOWER_RANK_LIST)) of
		false ->
			true;
		{_,_,OldTime} ->
			if Time < OldTime ->
				   true;
			   true ->
				   false
			end
	end.

gather(_,_)->
	todo.

refresh_gather() ->
	todo.
%%Return:
%%	ok|failed
%%Args:
%%	RoleId
%%	Count = int   Time = Seconds
challenge_rank(RoleId,{Count,Time}) ->
	case lists:keyfind(RoleId, 1, get(?LOOP_TOWER_RANK_LIST)) of
		false ->
			case lists:keyfind(Count, 2, get(?LOOP_TOWER_RANK_LIST)) of
				false ->
					put(?LOOP_TOWER_RANK_LIST,[{RoleId,Count,Time}|get(?LOOP_TOWER_RANK_LIST)]);
				{RoleIdTemp,_,_} ->
					put(?LOOP_TOWER_RANK_LIST,lists:keyreplace(Count,2,get(?LOOP_TOWER_RANK_LIST),{RoleId,Count,Time})),
					game_rank_manager_op:lose_rank(RoleIdTemp,?RANK_TYPE_LOOP_TOWER_MASTER)
			end,
			game_rank_manager_op:join_rank(RoleId,?RANK_TYPE_LOOP_TOWER_MASTER,{Count,Time},[]);
		{RoleId,OldCount,_} ->
			if Count > OldCount ->
					case lists:keyfind(Count, 2, get(?LOOP_TOWER_RANK_LIST)) of
						false ->
						   		  put(?LOOP_TOWER_RANK_LIST,lists:keyreplace(RoleId,1,get(?LOOP_TOWER_RANK_LIST),{RoleId,Count,Time}));
						{OldId,_,_} ->
								  put(?LOOP_TOWER_RANK_LIST,lists:keydelete(RoleId,1,get(?LOOP_TOWER_RANK_LIST))),
								  put(?LOOP_TOWER_RANK_LIST,lists:keyreplace(Count,2,get(?LOOP_TOWER_RANK_LIST),{RoleId,Count,Time})),
								  game_rank_manager_op:lose_rank(OldId,?RANK_TYPE_LOOP_TOWER_MASTER)
					end;
			   Count =:= OldCount->
				    put(?LOOP_TOWER_RANK_LIST,lists:keyreplace(RoleId,1,get(?LOOP_TOWER_RANK_LIST),{RoleId,Count,Time}));
				true ->
					nothing
			end,
			game_rank_manager_op:update_rank(RoleId,?RANK_TYPE_LOOP_TOWER_MASTER,{Count,Time},[])
	end,
	RoleInfoList = get(?LOOP_TOWER_RANK_LIST),
	put(?LOOP_TOWER_RANK_LIST,lists:reverse(lists:keysort(2, RoleInfoList))).

send_rank_list(RoleId) ->
	RankList = get(?LOOP_TOWER_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Count,Time})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,[Count,Time])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_loop_tower_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).

