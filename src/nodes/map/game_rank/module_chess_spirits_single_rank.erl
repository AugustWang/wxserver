%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-28
%% Description: TODO: Add description to module_sprite_rank
-module(module_chess_spirits_single_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(CHESS_SPIRITS_SINGLE_RANK_LIST,chess_spirits_single_rank_list).
-define(CHESS_SPIRITS_SINGLE_TOP_LIST,chess_spirits_single_top_list).
-define(CHESS_SPIRITS_SINGLE_RANK_EDGE,chess_spirits_single_rank_edge).
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
			put(?CHESS_SPIRITS_SINGLE_RANK_LIST,[]),
			put(?CHESS_SPIRITS_SINGLE_TOP_LIST,[]),
			put(?CHESS_SPIRITS_SINGLE_RANK_EDGE,{0,0});
		_ ->
			RoleInfoList = case get(?CHESS_SPIRITS_SINGLE_RANK_LIST) of
								undefined ->
									put(?CHESS_SPIRITS_SINGLE_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									NewList = lists:keysort(1,fold_list(Data)),
									lists:ukeymerge(1,get(?CHESS_SPIRITS_SINGLE_RANK_LIST),NewList)
							end,
			case make_rank(RoleInfoList) of
				{RankList,0,0} ->
					put(?CHESS_SPIRITS_SINGLE_RANK_EDGE,{0,0});
				{RankList,RankEdge,Time} ->
					put(?CHESS_SPIRITS_SINGLE_RANK_EDGE,{RankEdge,Time})
			end,
			put(?CHESS_SPIRITS_SINGLE_RANK_LIST,RankList),
			case erlang:length(RankList) >= ?RANK_MAX_TOP_NUM of
				true ->
					{TopList,_} = lists:split(?RANK_MAX_TOP_NUM,RankList),
					put(?CHESS_SPIRITS_SINGLE_TOP_LIST,TopList);
				false ->
					put(?CHESS_SPIRITS_SINGLE_TOP_LIST,RankList)
			end
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,_},Acc)-> 
		   			case Type of
						?RANK_TYPE_CHESS_SPIRITS_SINGLE ->
							{Count,UseTime} = Info,
							[{RoleId,Count,UseTime}|Acc];
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
												game_rank_manager_op:lose_rank(RoleId,?RANK_TYPE_CHESS_SPIRITS_SINGLE)
											end,LoseRank),
							{_,RankEdge,Time} = lists:nth(?RANK_TOTLE_NUM,RankList),
							{RankList,RankEdge,Time};
			  		true ->
				    		{AllRankList,0,0}
			end;
		false->
			{RoleInfoList,0,0}
	end.

can_challenge_rank({Count,UseTime})->
	{RankEdge,TimeEdge} = get(?CHESS_SPIRITS_SINGLE_RANK_EDGE),
	if Count > RankEdge ->
		   true;
	   Count =:= RankEdge ->
		   if 
			   UseTime < TimeEdge ->
				   true;
			   true ->
				   false
		   end;
	   true ->
		   false
	end.

is_top(RoleId)->
	TopList = get(?CHESS_SPIRITS_SINGLE_TOP_LIST),
	case lists:keyfind(RoleId,1,TopList) of
		false ->
			false;
		_ ->
			true
	end.

challenge_rank(RoleId,{Count,Time})->
	case can_challenge_rank({Count,Time}) of										
		true ->
			case lists:keyfind(RoleId,1,get(?CHESS_SPIRITS_SINGLE_RANK_LIST)) of	
				false ->
					game_rank_manager_op:join_rank(RoleId,?RANK_TYPE_CHESS_SPIRITS_SINGLE,{Count,Time},[]),
					put(?CHESS_SPIRITS_SINGLE_RANK_LIST,[{RoleId,Count,Time}|get(?CHESS_SPIRITS_SINGLE_RANK_LIST)]);
				{_,OldCount,_} ->
					if 
						Count >= OldCount ->
							 game_rank_manager_op:update_rank(RoleId,?RANK_TYPE_CHESS_SPIRITS_SINGLE,{Count,Time},[]),
							 put(?CHESS_SPIRITS_SINGLE_RANK_LIST,lists:keyreplace(RoleId, 1, get(?CHESS_SPIRITS_SINGLE_RANK_LIST), {RoleId,Count,Time}));
						true ->
							 nothing
					end
			end,
			case make_rank(get(?CHESS_SPIRITS_SINGLE_RANK_LIST)) of
				{RankList,0,0} ->
					put(?CHESS_SPIRITS_SINGLE_RANK_EDGE,{0,0});
				{RankList,RankEdge,TimeEdge} ->
					put(?CHESS_SPIRITS_SINGLE_RANK_EDGE,{RankEdge,TimeEdge})
			end,
			put(?CHESS_SPIRITS_SINGLE_RANK_LIST,RankList),
			OldTopList = get(?CHESS_SPIRITS_SINGLE_TOP_LIST),
			case erlang:length(get(?CHESS_SPIRITS_SINGLE_RANK_LIST)) >= ?RANK_MAX_TOP_NUM of
				true ->
					{NewTopList,_} = lists:split(?RANK_MAX_TOP_NUM,get(?CHESS_SPIRITS_SINGLE_RANK_LIST));
				false ->
					NewTopList = get(?CHESS_SPIRITS_SINGLE_RANK_LIST)
			end,
			put(?CHESS_SPIRITS_SINGLE_TOP_LIST,NewTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  case lists:keyfind(RoleIdTemp,1,NewTopList) of
							  false ->
								  game_rank_manager_op:lose_top(RoleIdTemp,?RANK_TYPE_CHESS_SPIRITS_SINGLE);
							  _ ->
								  nothing
						  end
					end,OldTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  case lists:keyfind(RoleIdTemp,1,OldTopList) of
							  false ->
								  game_rank_manager_op:join_top(RoleIdTemp,?RANK_TYPE_CHESS_SPIRITS_SINGLE);
							  _ ->
								  nothing
						  end
					end,NewTopList),
			ok;
		false ->
			failed
	end.
							 

gather(_,_)->
	todo.

refresh_gather()->
	todo.

send_rank_list(RoleId) ->
	RankList = get(?CHESS_SPIRITS_SINGLE_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Count,Time})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,1,[]);
								  		{RoleName,RoleClass,_RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,_RoleGender,[Count,Time])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_chess_spirits_single_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).






