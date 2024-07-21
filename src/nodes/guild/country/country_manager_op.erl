%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-31
%% Description: TODO: Add description to country_manager_op
-module(country_manager_op).

%%
%% Include files
%%
-include("string_define.hrl").
-include("country_define.hrl").
-include("country_def.hrl").
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("system_chat_define.hrl").
-include("guildbattle_define.hrl").

-record(postinfo,{post,
				  roleid,
				  name,
				  class,
				  gender,
				  starttime,
				  reward,
				  blocktalk,
				  remit,
				  punish,
				  appoint
				  }).

-record(countryinfo,{
					notice,
					tpstart,
					starttime,
					bestguild,
					bestguildname					
					}).


%%
%% Exported Functions
%%
-compile(export_all).
%% -record(country_record,{countryid,postinfo,countryinfo,ext}).
%%
%% API Functions
%%
%%country_info [{id,postinfo,starttime}]
init()->
	put(country_info,[]),
	put(kingstatuelist,[]),
	put(contry_msg_chche,[]),
	AllPostInfo = make_allpostinfo(),
	Func = fun(CountryId)->
				case dal:read_rpc(country_record,CountryId) of
					{ok,[]}->
						NewInfo = #country_record{countryid = CountryId,
												  postinfo = AllPostInfo,
												  countryinfo = make_countryinfo(),
												  ext = []};				
					{ok,[CountryInfo]}->						
						PostInfo = erlang:element(#country_record.postinfo,CountryInfo),
						SortFunc = fun(PostInfoA,PostInfoB)-> 
										{PostA,PostIndexA} = element(#postinfo.post,PostInfoA),
										{PostB,PostIndexB} =  element(#postinfo.post,PostInfoB), 
										if
											PostA =:= PostB ->
												PostIndexA < PostIndexB;
											true->
												PostA < PostB
										end
									end,
						NewPostInfo = lists:ukeymerge(#postinfo.post,
												lists:sort(SortFunc,PostInfo), 
												lists:sort(SortFunc,AllPostInfo)),
						NewInfo = CountryInfo#country_record{postinfo = NewPostInfo};
					_->					
						NewInfo = #country_record{countryid = CountryId,
												  postinfo = AllPostInfo,
												  countryinfo = make_countryinfo(),
												  ext = []}
				end,
				put(country_info,[NewInfo|get(country_info)])
		   end,
	lists:foreach(Func, lists:seq(1, ?TOTAL_COUNTRYS)),
	update_client_msg_chche().

member_online({RoleId})->
	member_online(RoleId,?COUNTRY_FIRST).
	
member_online(RoleId,CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			{?POST_COMMON,{0,0}};
		CountryRecord->
			PostInfo = erlang:element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(RoleId,#postinfo.roleid,PostInfo) of
				false->
					ReturnPost = ?POST_COMMON;
				MyPostInfo->
					{Post,Index} = erlang:element(#postinfo.post,MyPostInfo),
					ReturnPost = Post
			end,
			CountryInfo = erlang:element(#country_record.countryinfo,CountryRecord),
			BestGuildId = erlang:element(#countryinfo.bestguild,CountryInfo),
			{ReturnPost,BestGuildId}
	end.
	
init_client_country(RoleId)->
	init_client_country(RoleId,?COUNTRY_FIRST).	
	
init_client_country(RoleId,CountryId)->
	case lists:keyfind(CountryId,1,get(contry_msg_chche)) of
		false->
			nothing;
		{_,Msg}->
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.
	
change_notice(RoleId,Notice)->
	change_notice(RoleId,?COUNTRY_FIRST,Notice).

change_notice(RoleId,CountryId,Notice)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			PostInfo = erlang:element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(RoleId,#postinfo.roleid,PostInfo) of
				false->
					nothing;
				MyPostInfo->
					{Post,Index} = erlang:element(#postinfo.post,MyPostInfo),
					if
						Post =:= ?POST_KING->
							CountryInfo = erlang:element(#country_record.countryinfo,CountryRecord),
							NewCountryInfo = CountryInfo#countryinfo{notice = Notice},
							NewCountryRecord = CountryRecord#country_record{countryinfo = NewCountryInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info),NewCountryRecord)),
							save_to_db(CountryId),
							update_client_msg_chche(),
							init_client_country(RoleId,CountryId),
							todo;
						true->
							nothing
					end
			end
	end.

get_bestguild()->
	get_bestguild(?COUNTRY_FIRST).

get_bestguild(CountryRecord) when is_record(CountryRecord,country_record)->
	CountryInfo = element(#country_record.countryinfo,CountryRecord),
	element(#countryinfo.bestguild,CountryInfo);
	
get_bestguild(CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			{0,0};
		CountryRecord->
			CountryInfo = element(#country_record.countryinfo,CountryRecord),
			element(#countryinfo.bestguild,CountryInfo)
	end.

change_king_and_bestguild(RoleId,BestGuildId,BestGuildName)->
	broadcast_to_all_role_proc({country_proc_msg,{bestguildchange,BestGuildId}}),
	change_king_and_bestguild(RoleId,BestGuildId,BestGuildName,?COUNTRY_FIRST).
	
change_king_and_bestguild(0,{0,0},[],CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			PostInfos = erlang:element(#country_record.postinfo,CountryRecord),
			lists:foreach(fun(PostInfo)->
						{Post,_} = erlang:element(#postinfo.post,PostInfo),
						RoleId = erlang:element(#postinfo.roleid,PostInfo),
						if
							RoleId =:= 0 ->
								nothing;
							true->
								gm_logger_guild:country_leader_change(RoleId,Post,lost)
						end
					end,PostInfos)
	end,
	AllPostInfo = make_allpostinfo(),
	NewInfo = #country_record{countryid = CountryId,
							postinfo = AllPostInfo,
							countryinfo = make_countryinfo(),
							ext = []},
	put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info),NewInfo)),
	change_king_statue_name([],CountryId),
	save_to_db(CountryId),
	update_client_msg_chche();

change_king_and_bestguild(RoleId,BestGuildId,BestGuildName,CountryId)->
	Now = now(),
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			case get_bestguild(CountryRecord) of
				BestGuildId->
					%%just change king	
					PostInfo = erlang:element(#country_record.postinfo,CountryRecord),
					case lists:keyfind({?POST_KING,1},#postinfo.post,PostInfo) of
						false->
							nothing;
						KingPostInfo->
							OldKingRoleId = erlang:element(#postinfo.roleid,KingPostInfo),
							if
								RoleId =:= OldKingRoleId ->		%% countiue
									%% broadcast
									NewPostInfo = PostInfo;
								true->						%%update
									OldPostProcMsg = {country_proc_msg,{country_post_change,?POST_COMMON}},
									role_pos_util:send_to_role(OldKingRoleId,OldPostProcMsg),
									case read_memberinfo_from_remote(RoleId) of
										[]->
											Role_Name = [],
											Role_Class = 0,
											Gender = 0;
										{Role_Name,Role_Class,Gender}->
											nothing
									end,								
									NewKingPostInfo = make_postinfo(?POST_KING,1,RoleId,Role_Name,Role_Class,Gender,Now),
									case lists:keyfind(RoleId,#postinfo.roleid,PostInfo) of
										false->
											NewPostInfoTemp = PostInfo;
										KingOldPostInfo->
											{FindOldPost,FindOldPostIndex} = element(#postinfo.post,KingOldPostInfo),								
											NewPostInfoTemp = lists:keyreplace({FindOldPost,FindOldPostIndex},#postinfo.post,PostInfo,init_postinfo(FindOldPost,FindOldPostIndex))
									end,
									NewPostInfo = lists:keyreplace({?POST_KING,1},#postinfo.post,NewPostInfoTemp,NewKingPostInfo),
									NewPostProcMsg = {country_proc_msg,{country_post_change,?POST_KING}},
									role_pos_util:send_to_role(RoleId,NewPostProcMsg),
									change_king_statue_name(Role_Name,CountryId)
							end,
							CountryInfo = erlang:element(#country_record.countryinfo,CountryRecord),
							case get_battle_endtime(Now) of
								[]->
									BattleStopTime = Now;
								BattleStopTime->
									nothing
							end,
							NewCountryInfo = CountryInfo#countryinfo{starttime = BattleStopTime},
							NewCountryRecord = CountryRecord#country_record{countryinfo = NewCountryInfo,postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info),NewCountryRecord))	
					end;
				_->
					case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
						false->
							nothing;
						CountryRecord->
							PostInfos = erlang:element(#country_record.postinfo,CountryRecord),
							lists:foreach(fun(PostInfo)->
									{_Post,_} = erlang:element(#postinfo.post,PostInfo),
									_RoleId = erlang:element(#postinfo.roleid,PostInfo),
									if
										RoleId =:= 0 ->
											nothing;
										true->
											gm_logger_guild:country_leader_change(_RoleId,_Post,lost)
									end
								end,PostInfos)
					end,
					%%change king and bestguild
					PostInfo = make_allpostinfo(),
					case read_memberinfo_from_remote(RoleId) of
						[]->
							Role_Name = [],
							Role_Class = 0,
							Gender = 0;
						{Role_Name,Role_Class,Gender}->
							nothing
					end,
					OldPostInfo = erlang:element(#country_record.postinfo,CountryRecord),
					lists:foreach(fun(OldInfo)-> 
										case element(#postinfo.roleid,OldInfo) of
											0->
												nothing;
											OldRoleId->
												role_pos_util:send_to_role(OldRoleId,{country_proc_msg,{country_post_change,?POST_COMMON}})
										end
									end,OldPostInfo),
					NewPostProcMsg = {country_proc_msg,{country_post_change,?POST_KING}},
					role_pos_util:send_to_role(RoleId,NewPostProcMsg),
					change_king_statue_name(Role_Name,CountryId),
					NewKingPostInfo = make_postinfo(?POST_KING,1,RoleId,Role_Name,Role_Class,Gender,Now),
					NewPostInfo = lists:keyreplace({?POST_KING,1},#postinfo.post,PostInfo,NewKingPostInfo),
					CountryInfo = make_countryinfo(),
					case get_battle_endtime(Now) of
						[]->
							BattleStopTime = Now;
						BattleStopTime->
							nothing
					end,
					NewCountryInfo = CountryInfo#countryinfo{starttime = BattleStopTime,bestguild = BestGuildId,bestguildname = BestGuildName},
					NewCountryRecord = CountryRecord#country_record{countryinfo = NewCountryInfo,postinfo = NewPostInfo},
					put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info),NewCountryRecord))
		end,
		save_to_db(CountryId),
		update_client_msg_chche(),
		init_client_country(RoleId,CountryId)
	end.

leader_promotion(Post,PostIndex,{OtherId,OtherName,OtherClass,OtherGender},RoleId)->
	leader_promotion(Post,PostIndex,{OtherId,OtherName,OtherClass,OtherGender},RoleId,?COUNTRY_FIRST).

leader_promotion(Post,PostIndex,{OtherId,OtherName,OtherClass,OtherGender},LeaderRoleId,CountryId)->
	try case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
%%			io:format("111111111111~n"),
			nothing;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
%%					io:format("2222222~n"),
					nothing;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					if
						LeaderPost >= Post ->
%%							io:format("33333333333~n"),
							throw(nothing);
						true->
							nothing
					end,
					case country_db:get_info(LeaderPost) of
						[]->
							nothing;
						LeaderProtoInfo->
							AppointTimes = country_db:get_appointtimes(LeaderProtoInfo),
							if
								AppointTimes =:= 0 ->
%%									io:format("44444444444444~n"),
									throw(nothing);
								true->
									nothing
							end,
							Now = now(),
							{UsedTimes,TimeStamp} = element(#postinfo.appoint,LeaderPostInfo),
							case timer_util:check_same_day(TimeStamp, Now) of
								true->
									NewUsedTimes = UsedTimes;
								_->
									NewUsedTimes = 0
							end,
							if
								AppointTimes =< NewUsedTimes ->
									ErrnoMsg = country_packet:encode_country_opt_s2c(?ERRNO_NO_TIMES_TODAY),
									role_pos_util:send_to_role_clinet(LeaderRoleId,ErrnoMsg),
									throw(nothing);
								true->
									nothing
							end,
							case lists:keyfind({Post,PostIndex}, #postinfo.post, PostInfo) of
								false->
									nothing;
								OtherPostInfo->
									OldRoleId = element(#postinfo.roleid,OtherPostInfo),
									if
										OldRoleId =:= 0->
											nothing;
										OldRoleId =:= OtherId->
											throw(same_role);
										true->
											OldPostProcMsg = {country_proc_msg,{country_post_change,?POST_COMMON}},
											gm_logger_guild:country_leader_change(OldRoleId,Post,lost),
											role_pos_util:send_to_role(OldRoleId,OldPostProcMsg)
									end
							end,
							case lists:keyfind(OtherId, #postinfo.roleid, PostInfo) of
								false->
									TempPostInfo = PostInfo;
								OtherOldPostInfo->
									{OtherPost,OtherPostIndex} = element(#postinfo.post,OtherOldPostInfo),
									TempPostInfo = 
										lists:keyreplace({OtherPost,OtherPostIndex},#postinfo.post,PostInfo,init_postinfo(OtherPost,OtherPostIndex))
							end,
							gm_logger_guild:country_leader_change(OtherId,Post,get),
							LeaderId = element(#postinfo.roleid,LeaderPostInfo),
							LeaderName = element(#postinfo.name,LeaderPostInfo),
							broadcast_post_change(Post,OtherId,OtherName,LeaderId,LeaderName,LeaderPost),						
							NewOtherPostInfo =  make_postinfo(Post,PostIndex,OtherId,OtherName,OtherClass,OtherGender,Now),
							NewLeaderPostInfo = LeaderPostInfo#postinfo{appoint = {NewUsedTimes+1,Now}},
							NewPostInfoTemp = lists:keyreplace({Post,PostIndex},#postinfo.post,TempPostInfo,NewOtherPostInfo),
							NewPostInfo = lists:keyreplace(LeaderRoleId,#postinfo.roleid,NewPostInfoTemp,NewLeaderPostInfo),
							NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
							OtherPostChangeProcMsg = {country_proc_msg,{country_post_change,Post}},
							role_pos_util:send_to_role(OtherId,OtherPostChangeProcMsg),
							save_to_db(CountryId),
							update_client_msg_chche(),
							init_client_country(LeaderRoleId,CountryId)
					end	
			end
	end
	catch
			E:R->slogger:msg("E ~p R ~p S ~p ~n",[E,R,erlang:get_stacktrace()])
	end.

leader_demotion(Post,PostIndex,RoleId)->
	leader_demotion(Post,PostIndex,RoleId,?COUNTRY_FIRST).

leader_demotion(Post,PostIndex,LeaderRoleId,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					nothing;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					if
						LeaderPost >= Post ->
							throw(nothing);
						true->
							nothing
					end,
					case lists:keyfind({Post,PostIndex}, #postinfo.post, PostInfo) of
						false->
							nothing;
						OtherPostInfo->
							OldRoleId = element(#postinfo.roleid,OtherPostInfo),
							if
								OldRoleId =:= 0->
									throw(nothing);							
								true->
									OldPostProcMsg = {country_proc_msg,{country_post_change,?POST_COMMON}},
									gm_logger_guild:country_leader_change(OldRoleId,Post,lost),
									role_pos_util:send_to_role(OldRoleId,OldPostProcMsg)
							end
					end,
					NewOtherPostInfo =  init_postinfo(Post,PostIndex),
					NewPostInfo = lists:keyreplace({Post,PostIndex},#postinfo.post,PostInfo,NewOtherPostInfo),
					NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
					put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
					save_to_db(CountryId),
					update_client_msg_chche(),
					init_client_country(LeaderRoleId,CountryId)
			end
	end.

check_leader_right(Type,RoleId)->
	check_leader_right(Type,RoleId,?COUNTRY_FIRST).
	
check_leader_right(block_talk,LeaderRoleId,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			?ERRNO_NO_RIGHT;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					?ERRNO_NO_RIGHT;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					case country_db:get_info(LeaderPost) of
						[]->
							?ERROR_UNKNOWN;
						LeaderProtoInfo->
							BTTimes = country_db:get_blocktalktimes(LeaderProtoInfo),
							if
								BTTimes =:= 0 ->
									throw(?ERRNO_NO_RIGHT);
								true->
									nothing
							end,
							Now = now(),
							{UsedTimes,TimeStamp} = element(#postinfo.blocktalk,LeaderPostInfo),
							case timer_util:check_same_day(TimeStamp, now()) of
								true->
									NewUsedTimes = UsedTimes;
								_->
									NewUsedTimes = 0
							end,
							if
								BTTimes =< NewUsedTimes ->
									throw(?ERRNO_NO_TIMES_TODAY);
								true->
									nothing
							end,
							NewLeaderPostInfo =  LeaderPostInfo#postinfo{blocktalk = {NewUsedTimes+1,Now}},
							NewPostInfo = lists:keyreplace(LeaderRoleId,#postinfo.roleid,PostInfo,NewLeaderPostInfo),
							NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
							save_to_db(CountryId),
							ok
					end
			end
	end;

check_leader_right(remit,LeaderRoleId,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			?ERRNO_NO_RIGHT;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					?ERRNO_NO_RIGHT;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					case country_db:get_info(LeaderPost) of
						[]->
							?ERROR_UNKNOWN;
						LeaderProtoInfo->
							RemitTimes = country_db:get_remittimes(LeaderProtoInfo),
							if
								RemitTimes =:= 0 ->
									throw(?ERRNO_NO_RIGHT);
								true->
									nothing
							end,
							Now = now(),
							{UsedTimes,TimeStamp} = element(#postinfo.remit,LeaderPostInfo),
							case timer_util:check_same_day(TimeStamp, now()) of
								true->
									NewUsedTimes = UsedTimes;
								_->
									NewUsedTimes = 0
							end,
							if
								RemitTimes =< NewUsedTimes ->
									throw(?ERRNO_NO_TIMES_TODAY);
								true->
									nothing
							end,
							NewLeaderPostInfo =  LeaderPostInfo#postinfo{remit = {NewUsedTimes+1,Now}},
							NewPostInfo = lists:keyreplace(LeaderRoleId,#postinfo.roleid,PostInfo,NewLeaderPostInfo),
							NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
							save_to_db(CountryId),
							ok
					end
			end
	end;

check_leader_right(punish,LeaderRoleId,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			?ERRNO_NO_RIGHT;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					?ERRNO_NO_RIGHT;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					case country_db:get_info(LeaderPost) of
						[]->
							?ERROR_UNKNOWN;
						LeaderProtoInfo->
							PunishTimes = country_db:get_punishtimes(LeaderProtoInfo),
							if
								PunishTimes =:= 0 ->
									throw(?ERRNO_NO_RIGHT);
								true->
									nothing
							end,
							Now = now(),
							{UsedTimes,TimeStamp} = element(#postinfo.punish,LeaderPostInfo),
							case timer_util:check_same_day(TimeStamp, now()) of
								true->
									NewUsedTimes = UsedTimes;
								_->
									NewUsedTimes = 0
							end,
							if
								PunishTimes =< NewUsedTimes ->
									throw(?ERRNO_NO_TIMES_TODAY);
								true->
									nothing
							end,
							NewLeaderPostInfo =  LeaderPostInfo#postinfo{punish = {NewUsedTimes+1,Now}},
							NewPostInfo = lists:keyreplace(LeaderRoleId,#postinfo.roleid,PostInfo,NewLeaderPostInfo),
							NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
							save_to_db(CountryId),
							ok
					end
			end
	end;

check_leader_right(_,_,_)->
	nothing.


get_leader_items(RoleId,Level)->
	get_leader_items(RoleId,Level,?COUNTRY_FIRST).

get_leader_items(LeaderRoleId,Level,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			[];
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					[];
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					case country_db:get_info(LeaderPost) of
						[]->
							[];
						LeaderProtoInfo->
							Items = country_db:get_items_by_level(LeaderProtoInfo,Level),
							if
								Items =:= [] ->
									throw([]);
								true->
									nothing
							end,
							CountryInfo = element(#country_record.countryinfo,CountryRecord),
							element(#countryinfo.starttime,CountryInfo)
					end
			end
	end.

get_leader_ever_reward(RoleId)->
	get_leader_ever_reward(RoleId,?COUNTRY_FIRST).
	
get_leader_ever_reward(LeaderRoleId,CountryId)->
	catch case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			error;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(LeaderRoleId,#postinfo.roleid,PostInfo) of
				false->
					error;
				LeaderPostInfo->
					{LeaderPost,_} = element(#postinfo.post,LeaderPostInfo),
					case country_db:get_info(LeaderPost) of
						[]->
							error;
						LeaderProtoInfo->
							Rewards = country_db:get_punishtimes(LeaderProtoInfo),
							if
								Rewards =:= [] ->
									throw(error);
								true->
									nothing
							end,
							Now = now(),
							TimeStamp = element(#postinfo.reward,LeaderPostInfo),
							StartTime = element(#postinfo.starttime,LeaderPostInfo),
							LastRewardTime = element(#postinfo.reward,LeaderPostInfo),
							case timer_util:check_same_day(LastRewardTime, Now) of
								true->
									throw(alreay_get);
								_->
									nothing
							end,
							TimeDiff_s = trunc(timer:now_diff(Now, StartTime)/1000000),
							if
								TimeDiff_s =< ?LEADER_CAN_REWARD_TIME_S ->
									throw(less_time);
								true->
									nothing
							end,
							NewLeaderPostInfo =  LeaderPostInfo#postinfo{reward = Now},
							NewPostInfo = lists:keyreplace(LeaderRoleId,#postinfo.roleid,PostInfo,NewLeaderPostInfo),
							NewCountryRecord = CountryRecord#country_record{postinfo = NewPostInfo},
							put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
							save_to_db(CountryId),
							ok
					end
			end
	end.


reg_king_statue(Pid,Node)->
	reg_king_statue(Pid,Node,?COUNTRY_FIRST).

reg_king_statue(Pid,Node,CountryId)->
	case lists:keyfind(CountryId,1,get(kingstatuelist)) of
		false->
			put(kingstatuelist,[{CountryId,[{Pid,Node}]}|get(kingstatuelist)]);
		{_,KingStaueList}->
			 NewKingStaueList = lists:umerge(KingStaueList, [{Pid,Node}]),
			 NewKingStaueInfo = lists:keyreplace(CountryId,1,get(kingstatuelist),{CountryId,NewKingStaueList}),
			 put(kingstatuelist,NewKingStaueInfo)
	end,
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			[];
		CountryRecord->
			PostInfo =  element(#country_record.postinfo,CountryRecord),
			case lists:keyfind({?POST_KING,1},#postinfo.post,PostInfo) of
				false->
					[];
				KingInfo->
					element(#postinfo.name,KingInfo)
			end
	end.

change_king_statue_name(NewName)->
	change_king_statue_name(NewName,?COUNTRY_FIRST).

change_king_statue_name(NewName,CountryId)->
	case lists:keyfind(CountryId,1,get(kingstatuelist)) of
		false->
			nothing;
		{_,KingStaueList}->
			lists:foreach(fun({Pid,_Node}) -> 
							Pid ! {king_statue_change_name,NewName}	  
						end,KingStaueList)
	end.
	

change_leader_name(RoleId,NewName)->
	change_leader_name(RoleId,NewName,?COUNTRY_FIRST).	
	
change_leader_name(RoleId,NewName,CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind(RoleId,#postinfo.roleid,PostInfo) of
				false->
					nothing;
				RolePostInfo->
					NewRolePostInfo = setelement(#postinfo.name,RolePostInfo,NewName),
					NewPostInfo = lists:keyreplace(RoleId,#postinfo.roleid,PostInfo,NewRolePostInfo),
					NewCountryRecord = setelement(#country_record.postinfo,CountryRecord,NewPostInfo),
					put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
					save_to_db(CountryId),
					update_client_msg_chche(),
					init_client_country(RoleId,CountryId)
			end
	end.
	
get_king_roleid()->
	get_king_roleid(?COUNTRY_FIRST).
	
get_king_roleid(CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			PostInfo = element(#country_record.postinfo,CountryRecord),
			case lists:keyfind({?POST_KING,1},#postinfo.post,PostInfo) of
				false->
					[];
				RolePostInfo->
					element(#postinfo.roleid,RolePostInfo)
			end
	end.

change_guild_name(GuildId,NewName)->	
	change_guild_name(GuildId,NewName,?COUNTRY_FIRST).

change_guild_name(GuildId,NewName,CountryId)->	
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			CountryInfo = element(#country_record.countryinfo,CountryRecord),
			BestGuildId = element(#countryinfo.bestguild,CountryInfo),
			if
				BestGuildId =:= GuildId->
					NewCountryInfo = CountryInfo#countryinfo{bestguildname = NewName},
					NewCountryRecord = CountryRecord#country_record{countryinfo = NewCountryInfo},
					put(country_info,lists:keyreplace(CountryId,#country_record.countryid,get(country_info), NewCountryRecord)),
					save_to_db(CountryId),
					update_client_msg_chche();
				true->
					nothing
			end
	end.
	
%%
%% Local Functions
%%
save_to_db(CountryId)->
	case lists:keyfind(CountryId,#country_record.countryid,get(country_info)) of
		false->
			nothing;
		CountryRecord->
			dal:write_rpc(CountryRecord)
	end.

make_countryinfo()->
	#countryinfo{
				 notice = [],
				 tpstart = -1,
				 starttime = {0,0,0},
				 bestguild = {0,0},
				 bestguildname = []
				}.

make_allpostinfo()->
	AllPostInfo = lists:map(fun(Post)-> 
								#postinfo{
										  post = Post,
										  roleid = 0,
										  name = [],
										  class = 0,
										  gender = 0,
										  starttime = {0,0,0},
										  reward = {0,0,0},
										  blocktalk = {0,{0,0,0}},
										  remit = {0,{0,0,0}},
										  punish = {0,{0,0,0}},
										  appoint = {0,{0,0,0}}
										  } 
				end,country_db:get_allinfo()).

make_postinfo(Post,PostIndex,RoleId,Name,Class,Gender)->
	make_postinfo(Post,PostIndex,RoleId,Name,Class,Gender,now()).

make_postinfo(Post,PostIndex,RoleId,Name,Class,Gender,StartTime)->
								#postinfo{
										  post = {Post,PostIndex},
										  roleid = RoleId,
										  name = Name,
										  class = Class,
										  gender = Gender,
										  starttime = StartTime,
										  reward = {0,0,0},
										  blocktalk = {0,{0,0,0}},
										  remit = {0,{0,0,0}},
										  punish = {0,{0,0,0}},
										  appoint = {0,{0,0,0}}
										  }. 

init_postinfo(Post,PostIndex)->
	make_postinfo(Post,PostIndex,0,[],0,0,{0,0,0}).


%%%{Role_Name,Role_Class,Gender}/[]	
read_memberinfo_from_remote(RoleId)->
	case creature_op:get_remote_role_info(RoleId) of
		undefined->			%%ä¸åœ¨çº¿,ä»Ždbå–
			read_memberinfo_from_roledb(RoleId);
		RemoteInfo->		%%åœ¨çº¿,å–å†…å­˜æ•°æ®	
			Role_Name = get_name_from_othernode_roleinfo(RemoteInfo),
			Role_Class = get_class_from_othernode_roleinfo(RemoteInfo),
			Gender = get_gender_from_othernode_roleinfo(RemoteInfo),
			{Role_Name,Role_Class,Gender}
	end.
			
%%%{Role_Name,Role_Class,Gender}/[]				
read_memberinfo_from_roledb(Role_id)->
	RoleInfo = role_db:get_role_info(Role_id),
	case RoleInfo of
		[]->
			slogger:msg("read_memberinfo_from_roledb error!~p~n",[Role_id]),
			[];
		_->	 
			Role_Name = role_db:get_name(RoleInfo),
			Role_Class = role_db:get_class(RoleInfo),
			Gender = role_db:get_sex(RoleInfo),					
			{Role_Name,Role_Class,Gender}
	end.
	
update_client_msg_chche()->
	put(contry_msg_chche,[]),
	lists:foreach(fun(CountryRecord)->
					CountryId = element(#country_record.countryid,CountryRecord),
					CountryInfo = element(#country_record.countryinfo,CountryRecord),
					PostInfo = element(#country_record.postinfo,CountryRecord),
					Notice = element(#countryinfo.notice,CountryInfo),
					TpStart = element(#countryinfo.tpstart,CountryInfo),
					TpStop = 0,			%%todo
					BestGuild = element(#countryinfo.bestguild,CountryInfo),
					BestGuildName = element(#countryinfo.bestguildname,CountryInfo),
					LeadersInfo = lists:map(fun(LeaderInfo)->
											{Post,PostIndex} = element(#postinfo.post,LeaderInfo),
											RoleId =  element(#postinfo.roleid,LeaderInfo),
											Name =  element(#postinfo.name,LeaderInfo),
											Class =  element(#postinfo.class,LeaderInfo),
											Gender = element(#postinfo.gender,LeaderInfo),
											country_packet:make_cl(Post,PostIndex,RoleId,Name,Gender,Class)
										end, PostInfo),
					Msg = country_packet:encode_country_init_s2c(LeadersInfo,Notice,TpStart,TpStop,BestGuild,BestGuildName),
					put(contry_msg_chche,[{CountryId,Msg}|get(contry_msg_chche)])
				end,get(country_info)).	
				
broadcast_post_change(Post,RoleId,RoleName,LeaderId,LeaderName,LeaderPost)->
	if
		Post =:= ?POST_GENERAL->
			BrdId = ?SYSTEM_CHAT_COUNTRY_GENERAL;
		Post =:= ?POST_SOLIDER->
			BrdId = ?SYSTEM_CHAT_COUNTRY_SOLIDER;
		true->
			BrdId = 0
	end,
	LeaderStr = language:get_string(lists:nth(LeaderPost,?POST_STR)),
	NewLeaderStr = 	util:safe_binary_to_list(LeaderStr),
	if
		BrdId =:= 0->
			nothing;
		true->
			ParamLeaderStr = system_chat_util:make_string_param(NewLeaderStr),
			ServerId = 0,
			NewLeaderName = util:safe_binary_to_list(LeaderName),
			ParamLeader = chat_packet:makeparam(role,{NewLeaderName,RoleId,ServerId}),
			NewRoleName = util:safe_binary_to_list(RoleName),
			ParamRole = chat_packet:makeparam(role,{NewRoleName,RoleId,ServerId}),
			MsgInfo = [ParamLeaderStr,ParamLeader,ParamRole],
			system_chat_op:system_broadcast(BrdId,MsgInfo)
	end.
			
get_battle_endtime()-> 
	get_battle_endtime(now()).
	
get_battle_endtime(Now)->
	LocalTime = calendar:now_to_local_time(Now),
	{Today,NowTime} = LocalTime, 
	Week = calendar:day_of_the_week(Today),
	case guildbattle_db:get_info(Week) of
		[]->
			[];
		Info->
			BattleStartTime = guildbattle_db:get_starttime(Info),
			BattleStartTime_S = calendar:time_to_seconds(BattleStartTime),
			CurTime_s = calendar:time_to_seconds(NowTime),
			DiffTime_s1 =?GUILDBATTLE_DURATION_TIME_S + BattleStartTime_S - CurTime_s,
			DiffTime_s = erlang:max(DiffTime_s1,0),
			EndTime_ms = util:now_to_ms(Now) + DiffTime_s*1000,
			util:ms_to_now(EndTime_ms)
	end.
	
broadcast_to_all_role_proc(Message)->
	S = fun(RolePos)->
					role_pos_util:send_to_role_by_pos(RolePos,Message)
				end,
	role_pos_db:foreach(S).
	
