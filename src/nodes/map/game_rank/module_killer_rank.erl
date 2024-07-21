%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_kill_rank
-module(module_killer_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(KILLER_RANK_LIST,killer_rank_list).
-define(COLLECT_KILLER_LIST,collect_killer_list).
-define(KILLER_TOP_LIST,killer_top_list).
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1]).
%%
%% API Functions
%%
load_from_data(Data) ->
	case Data of
		[] ->
			put(?KILLER_RANK_LIST,[]),
			put(?KILLER_TOP_LIST,[]),
			put(?COLLECT_KILLER_LIST,[]);
		_ ->
			RoleInfoList = case get(?KILLER_RANK_LIST) of
								undefined ->
									put(?KILLER_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									NewList = lists:keysort(1,fold_list(Data)),
									lists:ukeymerge(1,get(?KILLER_RANK_LIST),NewList)
							end,
			RankList = make_rank(RoleInfoList),
			put(?KILLER_RANK_LIST,RankList),
			put(?COLLECT_KILLER_LIST,[]),
			case erlang:length(RankList) >= ?RANK_MAX_TOP_NUM of
				true ->
					{TopList,_} = lists:split(?RANK_MAX_TOP_NUM,RankList),
					put(?KILLER_TOP_LIST,TopList);
				false ->
					put(?KILLER_TOP_LIST,RankList)
			end
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						?RANK_TYPE_ROLE_TANGLE_KILL ->
							Num = Info,
							[{RoleId,Num,Time}|Acc];
						 _ ->
							Acc
					end
				end,[],Data).

make_rank(RoleInfoList)->
	case erlang:length(RoleInfoList) > 1 of
		true->
			AllRankList = lists:sort(fun({_,A1,A2},{_,B1,B2})->
											 if A1 > B1 ->
													true;
												A1 =:= B1 ->
													case A2 < B2 of
														true -> true;
														false -> false
													end;
												true->
													false
									 		end
										end, RoleInfoList),
			if erlang:length(AllRankList) >= ?RANK_TOTLE_NUM ->
							{RankList,_} = lists:split(?RANK_TOTLE_NUM,AllRankList),
							RankList;
			  		true ->
						    AllRankList
			end;
		false->
			RoleInfoList
	end.
	

%%Return:
%%	true|false
%%Args:
%%	Killer = int
can_challenge_rank(Killer)->
	todo.

is_top(RoleId)->
	TopList = get(?KILLER_TOP_LIST),
	case lists:keyfind(RoleId,1,TopList) of
		false ->
			false;
		_ ->
			true
	end.

%%Return:
%%	ok|failed
%%Args:
%%	RoleId
%%	Killer = int
challenge_rank(RoleId,Killer) ->
	todo.

gather(RoleId,Killer)->
	Time = now(),
	case get(?KILLER_RANK_LIST) of
		[] ->
			nothing;
		RankList ->
			lists:foreach(fun({RoleIdTemp,_,_})->
						game_rank_manager_op:lose_rank(RoleIdTemp,?RANK_TYPE_ROLE_TANGLE_KILL)
					end,RankList),
			put(?KILLER_RANK_LIST,[])
	end,
	case lists:keyfind(RoleId,1,get(?COLLECT_KILLER_LIST)) of		
		false ->
			put(?COLLECT_KILLER_LIST,[{RoleId,Killer,Time}|get(?COLLECT_KILLER_LIST)]);
		_ ->
			put(?COLLECT_KILLER_LIST,lists:keyreplace(RoleId, 1, get(?COLLECT_KILLER_LIST), {RoleId,Killer,Time}))
	end.

refresh_gather()->
	case get(?KILLER_RANK_LIST) of
		[]->
			NewList = get(?COLLECT_KILLER_LIST),
			NewRankList =  make_rank(NewList),
			lists:foreach(fun({RoleIdTemp,Num,Time})->
						game_rank_manager_op:join_rank(RoleIdTemp,?RANK_TYPE_ROLE_TANGLE_KILL,Num,Time)
					end,NewRankList),
			put(?KILLER_RANK_LIST,NewRankList),
			OldTopList = get(?KILLER_TOP_LIST),
			case erlang:length(NewRankList) >= ?RANK_MAX_TOP_NUM of
				true ->
					{NewTopList,_} = lists:split(?RANK_MAX_TOP_NUM,NewRankList);
				false ->
					NewTopList = get(?KILLER_RANK_LIST)
			end,
			put(?KILLER_TOP_LIST,NewTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						 		 case lists:keyfind(RoleIdTemp,1,NewTopList) of
							 		 false ->
								  		game_rank_manager_op:lose_top(RoleIdTemp,?RANK_TYPE_ROLE_TANGLE_KILL);
							 		 _ ->
								  		nothing
						 		 end
							end,OldTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  		case lists:keyfind(RoleIdTemp,1,OldTopList) of
							  		false ->
								  		game_rank_manager_op:join_top(RoleIdTemp,?RANK_TYPE_ROLE_TANGLE_KILL);
							  		_ ->
								  		nothing
						  		end
							end,NewTopList);
		_ ->
			put(?COLLECT_KILLER_LIST,[])
	end.
	
 
send_rank_list(RoleId) ->
	RankList = get(?KILLER_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Infos,_})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,RoleGender,[Infos])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_killer_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).