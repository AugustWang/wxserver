%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-10-12
%% Description: TODO: Add description to module_main_line_rank
-module(module_main_line_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
load_from_data(Data)->
	case Data of
		[]->
			nothing;
		_->
			ProcDict_List = fold_list(Data),
			make_rank(ProcDict_List)
	end.
			
fold_list(Data)->
	lists:foldl(fun({{Type,RoleId},Info,Time},Acc)-> 
		   			case Type of
						{?RANK_TYPE_MAIN_LINE,_} ->
						try
							{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleClass,ServerId} = Info,
							ProcDict_name = get_process_dictionary_name(Chapter,Festival,Difficulty),
							RoleInfo = role_db:get_role_info(RoleId),
							RoleName = role_db:get_name(RoleInfo),
							case get(ProcDict_name) of
								undefined ->
									put(ProcDict_name,[{RoleId,Level,UseTime,Score,Time,RoleName,RoleClass,ServerId}]),
									[ProcDict_name|Acc];
								_->
									put(ProcDict_name,[{RoleId,Level,UseTime,Score,Time,RoleName,RoleClass,ServerId}|get(ProcDict_name)]),
									Acc
							end
						catch
							E:R->
								slogger:msg("~p roleid ~p  E ~p R ~p S ~p ~n",[?MODULE,RoleId,E,R,erlang:get_stacktrace()]),
								Acc
						end;
						 _ ->
							Acc
					end
				end,[],Data).

make_rank(ProcDict_List)->
	lists:foreach(fun(ProcDict_Name)->
					ProcDict_RankList = make_rank_by_procdict_name(ProcDict_Name),
					put(ProcDict_Name,ProcDict_RankList)
				end,ProcDict_List).

make_rank_by_procdict_name(ProcDict_Name)->
	case erlang:length(get(ProcDict_Name)) > 1 of
		true->
			ProcDict_RankList = lists:sort(fun({_,_,_,A1,A2,_,_,_},{_,_,_,B1,B2,_,_,_})->
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
											end,get(ProcDict_Name)),
			if erlang:length(ProcDict_RankList) >= ?MAIN_LINE_RANK_TOTLE_NUM->
				   {RankList,LoseRank} = lists:split(?MAIN_LINE_RANK_TOTLE_NUM,ProcDict_RankList),
					lists:foreach(fun({RoleId,_,_,_,_,_,_,_})->
										game_rank_manager_op:lose_rank(RoleId,{?RANK_TYPE_MAIN_LINE,ProcDict_Name})
									end,LoseRank),
					RankList;
				true ->
		   			ProcDict_RankList
			end;
	   false->
		   get(ProcDict_Name)
	end.
		   
can_challenge_rank({Chapter,Festival,Difficulty,Score})->
	ProcDict_name = get_process_dictionary_name(Chapter,Festival,Difficulty),
	case get(ProcDict_name) of
		undefined->
			put(ProcDict_name,[]),
			true;
		RankList->
			case length(RankList) >= ?MAIN_LINE_RANK_TOTLE_NUM of
				true->
					{_,_,_,ScoreEdge,_,_,_,_} = lists:last(get(ProcDict_name)),
					if Score > ScoreEdge ->
		   					true;
	   					true ->
		   					false
					end;
				false ->
					true
			end
	end.

challenge_rank(RoleId,{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleName,RoleClass,ServerId})->
	ProcDict_name = get_process_dictionary_name(Chapter,Festival,Difficulty),
	case can_challenge_rank({Chapter,Festival,Difficulty,Score}) of
		true->
			Time = now(),
			case lists:keyfind(RoleId,1,get(ProcDict_name)) of
				false->
					game_rank_manager_op:join_rank(RoleId,{?RANK_TYPE_MAIN_LINE,ProcDict_name},{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleClass,ServerId},Time),
					put(ProcDict_name,[{RoleId,Level,UseTime,Score,Time,RoleName,RoleClass,ServerId}|get(ProcDict_name)]);
				_->
					game_rank_manager_op:update_rank(RoleId,{?RANK_TYPE_MAIN_LINE,ProcDict_name},{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleClass,ServerId},Time),
					put(ProcDict_name,lists:keyreplace(RoleId,1,get(ProcDict_name),{RoleId,Level,UseTime,Score,Time,RoleName,RoleClass,ServerId}))
			end,
			ProcDict_RankList = make_rank_by_procdict_name(ProcDict_name),
			put(ProcDict_name,ProcDict_RankList);
		_->
			nothing
	end.
			
is_top(RoleId)->
	todo.

%%return:[]/{RoleId,RoleName,RoleServerId,Score}
get_main_line_rank_top_role(Chapter,Festival,Difficulty)->
	ProcDict_name = get_process_dictionary_name(Chapter,Festival,Difficulty),
	case get(ProcDict_name) of
		undefined->
			[];
		[]->
			[];
		RankList->
			[{RoleId,_,_,Score,_,RoleName,_,ServerId}|_] = RankList,
			{RoleId,RoleName,ServerId,Score}
	end.

gather(RoleId,Level)->
	todo.

refresh_gather()->
	todo.

send_rank_list({Chapter,Festival,Difficulty,RoleId}) ->
	ProcDict_name = get_process_dictionary_name(Chapter,Festival,Difficulty),
	RankList = get(ProcDict_name),
	case RankList of
		undefined->
			Param = [];
		_->
			Param = lists:map(fun({RoleIdTemp,Level,UseTime,Score,_,RoleName,RoleClass,ServerId})->
							  		 game_rank_packet:make_param(RoleIdTemp,RoleName,[],RoleClass,ServerId,[],[Level,UseTime,Score])							  		
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_mail_line_s2c(Chapter,Festival,Difficulty,Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).
 
get_process_dictionary_name(Chapter,Festival,Difficulty)->
	integer_to_list(Chapter) ++ "_" ++ integer_to_list(Festival) ++ "_" ++ integer_to_list(Difficulty).











