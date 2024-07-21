%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-1-15
%% Description: TODO: Add description to module_pet_growth_rank
-module(module_pet_growth_rank).

%%
%% Include files
%%
-define(GROWTH_RANK_LIST,growth_rank_list).
-define(GROWTH_RANK_EDGE,growth_rank_edge).
-define(GROWTH_RANK_TOP_LIST,growth_rank_top_list).
-include("login_pb.hrl").
-include("game_rank_define.hrl").
-include("pet_define.hrl").
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,
		 send_rank_list/1,gather/2,refresh_gather/0,is_top/1,
		 search_rank/1,lose_rank/1,updata_rank/2]).

%%
%% API Functions
%%
load_from_data(Data) ->
	case Data of
		[] ->
			put(?GROWTH_RANK_LIST,[]),
			put(?GROWTH_RANK_EDGE,0),
			put(?GROWTH_RANK_TOP_LIST,[]);
		_ ->
			PetInfoList = case get(?GROWTH_RANK_LIST) of
								undefined ->
									put(?GROWTH_RANK_LIST,[]),
									fold_list(Data);
								_ ->
									get(?GROWTH_RANK_LIST) ++ fold_list(Data)
							end,
			case make_rank(PetInfoList) of
				{RankList,0} ->
					put(?GROWTH_RANK_EDGE,0);
				{RankList,RankEdge} ->
					put(?GROWTH_RANK_EDGE,RankEdge)
			end,
			put(?GROWTH_RANK_LIST,RankList),
			case erlang:length(RankList) > ?TALENT_RANK_TOP_NUM of
				true->
					{TopList,_} = lists:split(?TALENT_RANK_TOP_NUM,RankList),
					put(?GROWTH_RANK_TOP_LIST,TopList);
				_->
					put(?GROWTH_RANK_TOP_LIST,RankList)
			end
	end.

fold_list(Data)->
	lists:foldl(fun({{Type,RankKey},Info,Time},Acc)-> 
		   			case Type of
						?RANK_TYPE_PET_GROWTH ->
							try
							{PetName,Growth} = Info,
							PetId = RankKey,
							RoleId = pets_db:get_pet_ownerid(PetId),
							RoleInfo = role_db:get_role_info(RoleId),
							RoleName = role_db:get_name(RoleInfo),
							[{PetId,PetName,RoleName,Growth,Time}|Acc]
							catch
								E:R->
									slogger:msg("~p petid ~p  E ~p R ~p S ~p ~n",[?MODULE,RankKey,E,R,erlang:get_stacktrace()]),
									Acc
							end;
						 _ ->
							Acc
					end
				end,[],Data).

make_rank(PetInfoList)->
	case erlang:length(PetInfoList) > 1 of
		true->
			AllRankList = lists:sort(fun({_,_,_,A1,A2},{_,_,_,B1,B2})->
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
										end, PetInfoList),
			if erlang:length(AllRankList) >= ?RANK_TOTLE_NUM ->
							{RankList,LoseRank} = lists:split(?RANK_TOTLE_NUM,AllRankList),
							lists:foreach(fun({PetId,_,_,_,_})->
												game_rank_manager_op:lose_rank_not_role(PetId,?RANK_TYPE_PET_GROWTH)
											end,LoseRank),
							{_,_,_,RankEdge,_} = lists:nth(?RANK_TOTLE_NUM,RankList),
							{RankList,RankEdge};
			  		true ->
				   		{AllRankList,0}
			end;
		false->
			{PetInfoList,0}
	end.

%%Return:
%%	true|false
%%Args:
%%	Growth = int
can_challenge_rank(Growth)->
	RankEdge = get(?GROWTH_RANK_EDGE),
	if Growth > RankEdge ->
		   true;
	   true ->
		   false
	end.

is_top(_)->
	todo.

%%Return:
%%	ok|failed
%%Args:
%%	Growth = int
challenge_rank(PetId,{PetName,RoleName,Growth}) ->
	Time = now(),
	case can_challenge_rank(Growth) of										
		true ->																
			case lists:keyfind(PetId,1,get(?GROWTH_RANK_LIST)) of			
				false ->
					game_rank_manager_op:join_rank_not_role(PetId,?RANK_TYPE_PET_GROWTH,{PetName,Growth},Time),
					put(?GROWTH_RANK_LIST,[{PetId,PetName,RoleName,Growth,Time}|get(?GROWTH_RANK_LIST)]);
				{_,_,_,OldTalent,_} ->
					if Growth =:= OldTalent ->
						   nothing;
					   true->
						   game_rank_manager_op:update_rank(PetId,?RANK_TYPE_PET_GROWTH,{PetName,Growth},Time),
						   put(?GROWTH_RANK_LIST,lists:keyreplace(PetId, 1, get(?GROWTH_RANK_LIST), {PetId,PetName,RoleName,Growth,Time}))
					end
			end,
			case make_rank(get(?GROWTH_RANK_LIST)) of
				{RankList,0} ->
					put(?GROWTH_RANK_EDGE,0);
				{RankList,RankEdge} ->
					put(?GROWTH_RANK_EDGE,RankEdge)
			end,
			put(?GROWTH_RANK_LIST,RankList),
			OldTopList = get(?GROWTH_RANK_TOP_LIST),
			case erlang:length(get(?GROWTH_RANK_LIST)) >= ?TALENT_RANK_TOP_NUM of
				true ->
					{NewTopList,_} = lists:split(?TALENT_RANK_TOP_NUM,get(?GROWTH_RANK_LIST));
				false ->
					NewTopList = get(?GROWTH_RANK_LIST)
			end,
			put(?GROWTH_RANK_TOP_LIST,NewTopList),
			lists:foreach(fun({PetIdTemp,_,_,_,_})->
						  case lists:keyfind(PetIdTemp,1,NewTopList) of
							  false ->
								  RoleIdTemp = pets_db:get_pet_ownerid(PetIdTemp),
								  game_rank_manager_op:lose_top_not_role(RoleIdTemp,{PetIdTemp,?ICON_TYPE_PET_TALENT});
							  _ ->
								  nothing
						  end
					end,OldTopList),
			lists:foreach(fun({PetIdTemp,_,_,_,_})->
								RoleIdTemp = pets_db:get_pet_ownerid(PetIdTemp),
								RankNum = search_rank_in_top_list(PetIdTemp),
								game_rank_manager_op:join_top_not_role(RoleIdTemp,{PetIdTemp,RankNum,?ICON_TYPE_PET_TALENT})
							end,NewTopList),
			ok;
		false ->
			failed
	end.

gather(_,_)->
	todo.

refresh_gather()->
	todo.

search_rank_in_top_list(PetId)->
	{_,RankNum} = lists:foldl(fun({Pet_Id,_,_,_,_},{Acc,Result})->
									  if Result =/= []->
											 {Acc,Result};
										 true->
											if (PetId =:= Pet_Id) ->
													{Acc,Acc};
											   true->
												   {Acc+1,[]}
											end
									end
								end, {1,[]}, get(?GROWTH_RANK_TOP_LIST)),
	RankNum.
%%return:
%%	RankNum
search_rank(PetId)->
	{_,RankNum} = lists:foldl(fun({Pet_Id,_,_,_,_},{Acc,Result})->
									  if Result =/= []->
											 {Acc,Result};
										 true->
											if (PetId =:= Pet_Id) ->
													{Acc,Acc};
											   true->
												   {Acc+1,[]}
											end
									end
								end, {1,[]}, get(?GROWTH_RANK_LIST)),
	case RankNum of
		[]->
			TalentSort=?PET_TALENTS_SORT_FAILED;
		_->
			TalentSort=RankNum
	end,
	TalentSort.

lose_rank(PetId)->
	game_rank_manager_op:lose_rank_not_role(PetId,?RANK_TYPE_PET_GROWTH),
	put(?GROWTH_RANK_LIST,lists:keydelete(PetId,1,get(?GROWTH_RANK_LIST))).

updata_rank(PetId,Info)->
	case lists:keyfind(PetId,1,get(?GROWTH_RANK_LIST)) of
		false->
			nothing;
		{_,PetName,RoleName,Growth,Time}->
			put(?GROWTH_RANK_LIST,lists:keyreplace(PetId,1,get(?GROWTH_RANK_LIST),{PetId,Info,RoleName,Growth,Time})),
			game_rank_manager_op:update_rank(PetId,?RANK_TYPE_PET_GROWTH,{PetName,Growth},Time)
	end.

send_rank_list(RoleId) ->
	RankList = get(?GROWTH_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({PetId,PetName,RoleName,Growth,_})->
									  game_rank_packet:make_pet_rank_param(PetId,PetName,RoleName,[Growth])
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_growth_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).





















