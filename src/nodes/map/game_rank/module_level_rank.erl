%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_level_rank
-module(module_level_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").
-include("open_service_activities_define.hrl").

-define(LEVEL_RANK_LIST,level_rank_list).
-define(LEVEL_RANK_EDGE,level_rank_edge).
-define(LEVEL_TOP_LIST,level_top_list).

%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1,search_rank/1]).

%%
%% API Functions
%%
load_from_data(Data) ->
	case Data of
		[] ->
			put(?LEVEL_RANK_LIST,[]),
			put(?LEVEL_TOP_LIST,[]),
			put(?LEVEL_RANK_EDGE,0),
			put(open_server_activity_rank,[]);
		_ ->
			case open_service_activities_db:get_open_server_level_rank(?RANK_TYPE_ROLE_LEVEL) of
				[]->
					put(open_server_activity_rank,[]);
				{_,_,ORankList}->
					put(open_server_activity_rank,ORankList)
			end,
			RoleInfoList = case get(?LEVEL_RANK_LIST) of
								undefined ->
									put(?LEVEL_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									NewList = lists:keysort(1,fold_list(Data)),
									lists:ukeymerge(1,get(?LEVEL_RANK_LIST),NewList)
							end,
			case make_rank(RoleInfoList) of
				{RankList,0} ->
					put(?LEVEL_RANK_EDGE,0);
				{RankList,RankEdge} ->
					put(?LEVEL_RANK_EDGE,RankEdge)
			end,
			put(?LEVEL_RANK_LIST,RankList),
			case erlang:length(RankList) >= ?RANK_MAX_TOP_NUM of
				true ->
					{TopList,_} = lists:split(?RANK_MAX_TOP_NUM,RankList),
					put(?LEVEL_TOP_LIST,TopList);
				false ->
					put(?LEVEL_TOP_LIST,RankList)
			end

	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						?RANK_TYPE_ROLE_LEVEL ->
							Level = Info,
							[{RoleId,Level,Time}|Acc];
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
			if erlang:length(AllRankList) > ?RANK_TOTLE_NUM ->
							{RankList,LoseRank} = lists:split(?RANK_TOTLE_NUM,AllRankList),
							lists:foreach(fun({RoleId,_,_})->
												game_rank_manager_op:lose_rank(RoleId,?RANK_TYPE_ROLE_LEVEL)
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
%%	Attack = int
can_challenge_rank(Level)->
	RankEdge = get(?LEVEL_RANK_EDGE),
	if Level > RankEdge ->
		   true;
	   true ->
		   false
	end.

is_top(RoleId)->
	TopList = get(?LEVEL_TOP_LIST),
	case lists:keyfind(RoleId,1,TopList) of
		false ->
			false;
		_ ->
			true
	end.
%%Return:
%%	true|false
%%Args:
%%	Level = int
challenge_rank(RoleId,Level) ->
	case Level >= ?CAN_CHALLENGE_NEED_LEVEL of
		true->
			Time = now(),
			case can_challenge_rank(Level) of										
				true ->																
					case lists:keyfind(RoleId,1,get(?LEVEL_RANK_LIST)) of			
						false ->
							game_rank_manager_op:join_rank(RoleId,?RANK_TYPE_ROLE_LEVEL,Level,Time),
							put(?LEVEL_RANK_LIST,[{RoleId,Level,Time}|get(?LEVEL_RANK_LIST)]),
							open_service_activities:role_level_up(RoleId);
						{_,_OldLevel,_} ->
				   			game_rank_manager_op:update_rank(RoleId,?RANK_TYPE_ROLE_LEVEL,Level,Time),
				   			put(?LEVEL_RANK_LIST,lists:keyreplace(RoleId, 1, get(?LEVEL_RANK_LIST), {RoleId,Level,Time})),
				   			open_service_activities:role_level_up(RoleId)
					end,
					case make_rank(get(?LEVEL_RANK_LIST)) of
						{RankList,0} ->
							put(?LEVEL_RANK_EDGE,0);
						{RankList,RankEdge} ->
							put(?LEVEL_RANK_EDGE,RankEdge)
					end,
					put(?LEVEL_RANK_LIST,RankList),
					OldTopList = get(?LEVEL_TOP_LIST),
					case erlang:length(get(?LEVEL_RANK_LIST)) >= ?RANK_MAX_TOP_NUM of
						true ->
							{NewTopList,_} = lists:split(?RANK_MAX_TOP_NUM,get(?LEVEL_RANK_LIST));
						false ->
							NewTopList = get(?LEVEL_RANK_LIST)
					end,
					put(?LEVEL_TOP_LIST,NewTopList),
					lists:foreach(fun({RoleIdTemp,_,_})->
						  		case lists:keyfind(RoleIdTemp,1,NewTopList) of
							  		false ->
								  		game_rank_manager_op:lose_top(RoleIdTemp,?RANK_TYPE_ROLE_LEVEL);
							  		_ ->
								  		nothing
						  		end
							end,OldTopList),
					lists:foreach(fun({RoleIdTemp,_,_})->
						  		case lists:keyfind(RoleIdTemp,1,OldTopList) of
							  		false ->
								  		game_rank_manager_op:join_top(RoleIdTemp,?RANK_TYPE_ROLE_LEVEL);
							  		_ ->
								  		nothing
						  		end
							end,NewTopList),
					{StartTime,EndTime} = open_service_activities:get_activity_time_point(?TYPE_LEVEL_RANK),
					NowTime = calendar:local_time(),
					case timer_util:is_in_time_point(StartTime, EndTime, NowTime) of
						true->
							put(open_server_activity_rank,RankList);
						_->
							nothing
					end,
					ok;
				false ->
					failed
			end;
		_->
			ignor
	end.
	
gather(RoleId,Level)->
	todo.

refresh_gather()->
	case get(open_server_activity_rank) of
		[]->
			nothing;
		undefined->
			nothing;
		RankList ->
			open_service_activities_db:add_to_open_service_level_rank_db(?RANK_TYPE_ROLE_LEVEL,RankList)
	end.

search_rank(RoleId)->
	case get(open_server_activity_rank) of
		[]->
			RankNum = [];
		undefined->
			RankNum = [];
		RankInfo->
			{_,RankNum} = lists:foldl(fun({Role_Id,_,_},{Acc,Result})->
											  if Result =/= []->
													 {Acc,Result};
												 true->
													if (RoleId =:= Role_Id) ->
															{Acc,Acc};
											   			true->
												   			{Acc+1,[]}
													end
											  end
										end, {1,[]},RankInfo)
	end,
	case RankNum of
		[]->
			ReturnNum=0;
		_->
			ReturnNum=RankNum
	end,
	ReturnNum.


send_rank_list(RoleId) ->
	RankList = get(?LEVEL_RANK_LIST),
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
	Message = game_rank_packet:encode_rank_level_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).
	
