%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-28
%% Description: TODO: Add description to module_chess_spirits_team_rank
-module(module_chess_spirits_team_rank).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1]).

-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(CHESS_SPIRITS_TEAM_RANK_LIST,chess_spirits_team_rank_list).
-define(CHESS_SPIRITS_TEAM_TOP_LIST,chess_spirits_team_top_list).
-define(CHESS_SPIRITS_TEAM_RANK_EDGE,chess_spirits_team_rank_edge).

%%
%% Local Functions
%%
load_from_data(Data) ->
	case Data of
		[] ->
			put(?CHESS_SPIRITS_TEAM_RANK_LIST,[]),
			put(?CHESS_SPIRITS_TEAM_RANK_EDGE,{0,0});
		_ ->
			RoleInfoList = case get(?CHESS_SPIRITS_TEAM_RANK_LIST) of
								undefined ->
									put(?CHESS_SPIRITS_TEAM_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									get(?CHESS_SPIRITS_TEAM_RANK_LIST) ++ fold_list(Data)
							end,
			case make_rank(RoleInfoList) of
				{RankList,0,0} ->
					put(?CHESS_SPIRITS_TEAM_RANK_EDGE,{0,0});
				{RankList,RankEdge,Time} ->
					put(?CHESS_SPIRITS_TEAM_RANK_EDGE,{RankEdge,Time})
			end,
			put(?CHESS_SPIRITS_TEAM_RANK_LIST,RankList)
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RankKey},Info,_},Acc)-> 
		   			case Type of
						?RANK_TYPE_CHESS_SPIRITS_TEAM ->
							{RoleList,Time} = RankKey,
							{Count,UseTime} = Info,
							[{{RoleList,Time},Count,UseTime}|Acc];
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
							lists:foreach(fun({{RoleList,Time},_,_})->
												  game_rank_manager_op:lose_rank_not_role({RoleList,Time},?RANK_TYPE_CHESS_SPIRITS_TEAM)
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
	{RankEdge,TimeEdge} = get(?CHESS_SPIRITS_TEAM_RANK_EDGE),
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

challenge_rank({RoleList,Time},{Count,UseTime})->
	case can_challenge_rank({Count,UseTime}) of
		true ->
			game_rank_manager_op:join_rank_not_role({RoleList,Time},?RANK_TYPE_CHESS_SPIRITS_TEAM,{Count,UseTime},[]),
			put(?CHESS_SPIRITS_TEAM_RANK_LIST,[{{RoleList,Time},Count,UseTime}|get(?CHESS_SPIRITS_TEAM_RANK_LIST)]);
		false ->
			nothing
	end,
	case make_rank(get(?CHESS_SPIRITS_TEAM_RANK_LIST)) of
		 {RankList,0,0} ->
			 put(?CHESS_SPIRITS_TEAM_RANK_EDGE,{0,0});
		 {RankList,RankEdge,TimeEdge} ->
			 put(?CHESS_SPIRITS_TEAM_RANK_EDGE,{RankEdge,TimeEdge})
	end,
	put(?CHESS_SPIRITS_TEAM_RANK_LIST,RankList).

is_top(_)->
	todo.

gather(_,_)->
	todo.

refresh_gather()->
	todo.

send_rank_list(RoleId) ->
	RankList = get(?CHESS_SPIRITS_TEAM_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({{RoleNames,_},Count,Time})->
							 RoleNameList = lists:map(fun(RoleName)->
												binary_to_list(RoleName)
										end,RoleNames),
							 game_rank_packet:make_chess_spirits_param(RoleNameList,[Count,Time])
						end,RankList)
	end,
	Message = game_rank_packet:encode_rank_chess_spirits_team_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).












