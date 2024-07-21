%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_tower_count_rank
-module(module_loop_tower_num_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(TOWER_NUM_RANK_LIST,tower_num_rank_list).       
-define(TOWER_NUM_RANK_EDGE,tower_num_rank_edge).  
-define(TOWER_NUM_TOP_LIST,tower_num_top_list).
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
			put(?TOWER_NUM_RANK_LIST,[]),
			put(?TOWER_NUM_TOP_LIST,[]),
			put(?TOWER_NUM_RANK_EDGE,0);
		_ ->
			RoleInfoList = case get(?TOWER_NUM_RANK_LIST) of
								undefined ->
									put(?TOWER_NUM_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									NewList = lists:keysort(1,fold_list(Data)),
									lists:ukeymerge(1,get(?TOWER_NUM_RANK_LIST),NewList)
							end,
			case make_rank(RoleInfoList) of
				{RankList,0} ->
					put(?TOWER_NUM_RANK_EDGE,0);
				{RankList,RankEdge} ->
					put(?TOWER_NUM_RANK_EDGE,RankEdge)
			end,
			put(?TOWER_NUM_RANK_LIST,RankList),
			case erlang:length(RankList) >= ?RANK_MAX_TOP_NUM of
				true ->
					{TopList,_} = lists:split(?RANK_MAX_TOP_NUM,RankList),
					put(?TOWER_NUM_TOP_LIST,TopList);
				false ->
					put(?TOWER_NUM_TOP_LIST,RankList)
			end
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						?RANK_TYPE_LOOP_TOWER_NUM ->
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
							{RankList,LoseRank} = lists:split(?RANK_TOTLE_NUM,AllRankList),
							lists:foreach(fun({RoleId,_,_})->
												game_rank_manager_op:lose_rank(RoleId,?RANK_TYPE_LOOP_TOWER_NUM)
											end,LoseRank),
							{_,RankEdge,_} = lists:nth(?RANK_TOTLE_NUM,RankList),
							{RankList,RankEdge};
			  		true ->
				   		{AllRankList,0}
			end;
		false->
			{RoleInfoList,0}
	end.

%%Return:
%%	true|false
%%Args:
%%	Num = int
can_challenge_rank(Num)->
	RankEdge = get(?TOWER_NUM_RANK_EDGE),
	if Num > RankEdge ->
		   true;
	   true ->
		   false
	end.

is_top(RoleId)->
	TopList = get(?TOWER_NUM_TOP_LIST),
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
%%	Num = int
challenge_rank(RoleId,Num) ->
	Time = now(),
	case can_challenge_rank(Num) of												
		true ->																	
			case lists:keyfind(RoleId,1,get(?TOWER_NUM_RANK_LIST)) of			
				false ->
					game_rank_manager_op:join_rank(RoleId,?RANK_TYPE_LOOP_TOWER_NUM,Num,Time),
					put(?TOWER_NUM_RANK_LIST,[{RoleId,Num,Time}|get(?TOWER_NUM_RANK_LIST)]);
				{_,OldNum,_} ->
					if Num > OldNum ->
						   game_rank_manager_op:update_rank(RoleId,?RANK_TYPE_LOOP_TOWER_NUM,Num,Time),
						   put(?TOWER_NUM_RANK_LIST,lists:keyreplace(RoleId, 1, get(?TOWER_NUM_RANK_LIST), {RoleId,Num,Time}));
					   true ->
						   nothing
					end
			end,
			case make_rank(get(?TOWER_NUM_RANK_LIST)) of
				{RankList,0} ->
					put(?TOWER_NUM_RANK_EDGE,0);
				{RankList,RankEdge} ->
					put(?TOWER_NUM_RANK_EDGE,RankEdge)
			end,
			put(?TOWER_NUM_RANK_LIST,RankList),
			OldTopList = get(?TOWER_NUM_TOP_LIST),
			case erlang:length(get(?TOWER_NUM_RANK_LIST)) >= ?RANK_MAX_TOP_NUM of
				true ->
					{NewTopList,_} = lists:split(?RANK_MAX_TOP_NUM,get(?TOWER_NUM_RANK_LIST));
				false ->
					NewTopList = get(?TOWER_NUM_RANK_LIST)
			end,
			put(?TOWER_NUM_TOP_LIST,NewTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  case lists:keyfind(RoleIdTemp,1,NewTopList) of
							  false ->
								  game_rank_manager_op:lose_top(RoleIdTemp,?RANK_TYPE_LOOP_TOWER_NUM);
							  _ ->
								  nothing
						  end
					end,OldTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  case lists:keyfind(RoleIdTemp,1,OldTopList) of
							  false ->
								  game_rank_manager_op:join_top(RoleIdTemp,?RANK_TYPE_LOOP_TOWER_NUM);
							  _ ->
								  nothing
						  end
					end,NewTopList),
			ok;
		false ->
			failed
	end.

gather(RoleId,Num)->
	todo.
				
refresh_gather()->
	todo.


send_rank_list(RoleId) ->
	RankList = get(?TOWER_NUM_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Infos,_})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,[Infos])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_loop_tower_num_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).
