%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-18
%% Description: TODO: Add description to module_answer_rank
-module(module_answer_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

-define(ANSWER_RANK_LIST,answer_rank_list).
-define(COLLECT_ANSWER_LIST,collect_answer_list).
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
			put(?ANSWER_RANK_LIST,[]),
			put(?COLLECT_ANSWER_LIST,[]);
		_ ->
			RoleInfoList = case get(?ANSWER_RANK_LIST) of
								undefined ->
									put(?ANSWER_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									get(?ANSWER_RANK_LIST) ++ fold_list(Data)
							end,
			RankList = make_rank(RoleInfoList),
			put(?ANSWER_RANK_LIST,RankList),
			put(?COLLECT_ANSWER_LIST,[])
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						?RANK_TYPE_ANSWER ->
							Score = Info,
							[{RoleId,Score,Time}|Acc];
						 _ ->
							Acc
					end
				end,[],Data).

make_rank(RoleInfoList)->
	AllRankList = lists:keysort(2, RoleInfoList),
	if erlang:length(AllRankList) >= ?RANK_ANSWER_TOTLE_NUM ->
					{RankList,_} = lists:split(?RANK_ANSWER_TOTLE_NUM,lists:reverse(AllRankList)),
					RankList;
			  true ->
				   RankList = lists:reverse(AllRankList),
				   RankList
	end.

can_challenge_rank(_)->
	todo.

challenge_rank(_,_) ->
	todo.

is_top(RoleId)->
	TopList = get(?ANSWER_RANK_LIST),
	case lists:keyfind(RoleId,1,TopList) of
		false ->
			false;
		_ ->
			true
	end.

gather(RoleId,Score)->
	Time = now(),
	case get(?ANSWER_RANK_LIST) of
		[]->
			nothing;
		RankList ->
			lists:foreach(fun({RoleIdTemp,_,_})->
						game_rank_manager_op:lose_rank(RoleIdTemp,?RANK_TYPE_ANSWER),
						game_rank_manager_op:lose_top(RoleIdTemp,?RANK_TYPE_ANSWER)
					end,RankList),
			put(?ANSWER_RANK_LIST,[])
	end,
	case lists:keyfind(RoleId,1,get(?COLLECT_ANSWER_LIST)) of		
		false ->
			put(?COLLECT_ANSWER_LIST,[{RoleId,Score,Time}|get(?COLLECT_ANSWER_LIST)]);
		_ ->
			put(?COLLECT_ANSWER_LIST,lists:keyreplace(RoleId, 1, get(?COLLECT_ANSWER_LIST), {RoleId,Score,Time}))
	end.

refresh_gather()->
	case get(?ANSWER_RANK_LIST) of
		[] ->
			NewList = get(?COLLECT_ANSWER_LIST),
			NewRankList = make_rank(NewList),
			lists:foreach(fun({RoleIdTemp,Score,Time})->
						game_rank_manager_op:join_rank(RoleIdTemp,?RANK_TYPE_ANSWER,Score,Time),
						game_rank_manager_op:join_top(RoleIdTemp,?RANK_TYPE_ANSWER)
					end,NewRankList),
			put(?ANSWER_RANK_LIST,NewRankList);
		_ ->
			put(?COLLECT_ANSWER_LIST,[])
	end.
	
send_rank_list(RoleId) ->
	RankList = get(?ANSWER_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Score,_})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,RoleGender,[Score])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_answer_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).









	
	
