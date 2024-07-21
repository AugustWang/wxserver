%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-5
%% Description: TODO: Add description to game_rank_util
-module(game_rank_collect_util).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
load_from_data(Data,RankList,RankTopList,RankFreshList,CollectList,RankType)->
	case Data of
		[]->
			put(RankList,[]),
			put(RankTopList,[]),
			put(RankFreshList,[]),
			put(CollectList,[]);
		_->
			put(CollectList,[]),
			put(RankFreshList,[]),
			AllRankList = case get(RankList) of
							  undefined->
								  put(RankList,[]),
								  fold_list(Data,RankType);
							  _->
								  fold_list(Data,RankType)
						  end,
			ResultRankList = make_rank(AllRankList,get(RankList),RankType),
			put(RankList,ResultRankList),
			case erlang:length(ResultRankList) >= ?RANK_MAX_TOP_NUM of
				true->
					{TopList,_} = lists:split(?RANK_MAX_TOP_NUM,ResultRankList),
					put(RankTopList,TopList);
				_->
					put(RankTopList,ResultRankList)
			end
	end.
		
fold_list(Data,RankType)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						RankType ->
							[{RoleId,Info,Time}|Acc];
						 _ ->
							Acc
					end
				end,[],Data).

make_rank(AllRankList,OldRankList,RankType)->
	case erlang:length(AllRankList) > 1 of
		true->
			ResultRankList = lists:sort(fun({_,A1,A2},{_,B1,B2})->
												if
													A1 > B1 ->
														true;
													A1 =:= B1 ->
														A2 < B2;
													true->
														false
												end
										end,AllRankList);
		false->
			ResultRankList = AllRankList
	end,
	if
		erlang:length(ResultRankList) >= ?RANK_TOTLE_NUM ->
			{RankList,_} = lists:split(?RANK_TOTLE_NUM,ResultRankList),
			lists:foreach(fun({RoleIdTemp,Info,Time})->
								  case lists:keyfind(RoleIdTemp,1,OldRankList) of
									  false ->
										  game_rank_manager_op:join_rank(RoleIdTemp,RankType,Info,Time);
									  _->
										  nothing
								  end
							end,RankList),
			lists:foreach(fun({RoleIdTemp,_,_})->
								  case lists:keyfind(RoleIdTemp,1,RankList) of
									  false->
										  game_rank_manager_op:lose_rank(RoleIdTemp,RankType);
									  _->
										  nothing
								  end
							end,OldRankList),
			RankList;
		true->
			lists:foreach(fun({RoleIdTemp,Info,Time})->
								  case lists:keyfind(RoleIdTemp,1,OldRankList) of
									  false->
										  game_rank_manager_op:join_rank(RoleIdTemp,RankType,Info,Time);
									  _->
										  nothing
								  end
							end,ResultRankList),
			ResultRankList
	end.

is_top(RoleId,RankType)->
	TopList = get(RankType),
	case lists:keyfind(RoleId,1,TopList) of
		false->
			false;
		_->
			true
	end.

gather(RoleId,Info,RankList,RankTopList,RankFreshList,CollectList,RankType)->
	case creature_op:get_remote_role_info(RoleId) of
		undefined->			
			ignor;
		RemoteInfo->			
			case get_level_from_othernode_roleinfo(RemoteInfo) >= ?CAN_CHALLENGE_NEED_LEVEL of
				true->
					Time = now(),
					case lists:keyfind(RoleId,1,get(CollectList)) of
						false->
							
							case lists:keyfind(RoleId,1,get(RankList)) of
								{_,OriInfo,_}->
									if
										Info =/= OriInfo ->
											put(RankFreshList,[{RoleId,Info,Time}|get(RankFreshList)]),
											put(CollectList,[{RoleId,Info,Time}|get(CollectList)]);
										true->
											nothing
									end;
								false->
									put(CollectList,[{RoleId,Info,Time}|get(CollectList)])
							end;
						_->
							put(CollectList,lists:keyreplace(RoleId,1,get(CollectList),{RoleId,Info,Time}))
					end,
					Length = erlang:length(get(CollectList)),
					if
						Length >= ?COLLECT_LIST_MAX_NUM ->
							refresh_gather(RankList,RankTopList,RankFreshList,CollectList,RankType);
						true->
							nothing
					end;
				_->
					ignor
			end
	end.

refresh_gather(RankList,RankTopList,RankFreshList,CollectList,RankType)->
	NeedFreshList = get(RankFreshList),
	lists:foreach(fun({RoleIdTemp,Info,Time})->
						  game_rank_manager_op:update_rank(RoleIdTemp,RankType,Info,Time)
					end,NeedFreshList),
	Rank_List = lists:filter(fun({RoleIdTemp,_,_})->
									 case lists:keyfind(RoleIdTemp,1,NeedFreshList) of
										 false -> true;
										 _ -> false
									 end
								end,get(RankList)),
	ResultRankList = make_rank(Rank_List ++ get(CollectList),get(RankList),RankType),
	put(RankFreshList,[]),
	put(CollectList,[]),
	put(RankList,ResultRankList),
	if
		RankType =/= []->
			OldTopList = get(RankTopList),
			case erlang:length(get(RankList)) >= ?RANK_MAX_TOP_NUM of
						true ->
							{NewTopList,_} = lists:split(?RANK_MAX_TOP_NUM,get(RankList));
						false ->
							NewTopList = get(RankList)
			end,
			put(RankTopList,NewTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  		case lists:keyfind(RoleIdTemp,1,NewTopList) of
							  		false ->
								  		game_rank_manager_op:lose_top(RoleIdTemp,RankType);
							  		_ ->
								  		nothing
						  		end
							end,OldTopList),
			lists:foreach(fun({RoleIdTemp,_,_})->
						  		case lists:keyfind(RoleIdTemp,1,OldTopList) of
							  		false ->
								  		game_rank_manager_op:join_top(RoleIdTemp,RankType);
							  		_ ->
								  		nothing
						  		end
							end,NewTopList);
		true->
			ignor
	end.
	
send_rank_list(RoleId,RankListType)->
	RankList = get(RankListType),
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
	Param.
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
							  
