%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(battle_ground_packet).

-include("login_pb.hrl").
-include("data_struct.hrl").

-compile(export_all).


make_tangle_battle_role(RoleId,RoleName,Kills,Score,RoleGender,RoleClass,RoleLevel)->
	#tr{roleid = RoleId,rolename = RoleName,rolegender = RoleGender,roleclass = RoleClass,rolelevel = RoleLevel,kills = Kills,score = Score}.

make_tp(Roleid,X,Y)->
	#tp{roleid = Roleid,x= X,y=Y}.

make_ki(KillInfo,AllRoleInfo)->
	lists:foldr(fun({RoleId,Times},TmpInfo)-> 
						case lists:keyfind(RoleId,1,AllRoleInfo) of 
							false->
								TmpInfo;
							{RoleId,RoleName,_Ranks,_Kills,{RoleClass,_RoleGender,RoleLevel}}->
								[#ki{roleid = RoleId,rolename = RoleName,roleclass = RoleClass,rolelevel = RoleLevel,times = Times}|TmpInfo]
						end
				end, [], KillInfo). 

make_yhzq_gbinfo_param(GbInfo)->
	lists:foldl(fun({_,Index,Name,Score,WinInfo},Acc)-> 
					  case lists:keyfind(yhzq,1,WinInfo) of
						  false->
							  Acc;
						  {_,WinNum,LoseNum}->
							  [#gbw{index=Index,name=Name,score=Score,winnum=WinNum,losenum=LoseNum}|Acc]
					  end
				end,[],GbInfo).

make_jszd_gbinfo_param(GbInfo)->
	lists:map(fun({_,Index,Name,Score,_})->
						#gbw{index=Index,name=Name,score=Score,winnum=0,losenum=0}
				end,GbInfo).

make_gbinfo_param(GbInfo)->
	lists:map(fun({_,Index,Name,Score,TScore,_})->
					  case lists:keyfind(yhzq,1,Score) of
						  false->
							  YhzqScore = 0,
							  case lists:keyfind(jszd_battle,1,Score) of
								  false->
									  JszdScore = 0;
								  {_,JszdScore}->
									  nothing
							  end;
						  {_,YhzqScore}->
							  case lists:keyfind(jszd_battle,1,Score) of
								  false->
									  JszdScore = 0;
								  {_,JszdScore}->
									  nothing
							  end
					  end,
					  Rankscore=TScore-JszdScore,%%@@wb20130420鏍规嵁瀹㈡埛绔坊鍔爎ankscore
					  #gbt{index=Index,name=Name,yhzqscore=YhzqScore,jszdscore=JszdScore,score=TScore,rankscore=Rankscore} 
				end,GbInfo).

make_tangle_battle_num(BattleInfo)->
	lists:map(fun({BattleId,CurNum,TotleNum})-> 
					  #tbi{battleid=BattleId,curnum=CurNum,totlenum=TotleNum} 
				end,BattleInfo).

make_guildbattle_rankinfo(RankInfo)->
	lists:map(fun({GuildName,Score,Rank})->
					  #gbr{guildname=GuildName,score=Score,rank=Rank}
				end,RankInfo).

encode_guild_battlefield_info_s2c(ParamRank)->
	login_pb:encode_guild_battlefield_info_s2c(#guild_battlefield_info_s2c{rankinfo=ParamRank}).

encode_tangle_battlefield_info_s2c(KillNum,Honor,ParamBattle)->
	login_pb:encode_tangle_battlefield_info_s2c(#tangle_battlefield_info_s2c{killnum=KillNum,honor=Honor,battleinfo=ParamBattle}).

encode_battlefield_totle_info_s2c(ParamGbInfo)->
	login_pb:encode_battlefield_totle_info_s2c(#battlefield_totle_info_s2c{gbinfo=ParamGbInfo}).
 
encode_yhzq_battlefield_info_s2c(ParamGbInfo)->
	login_pb:encode_yhzq_battlefield_info_s2c(#yhzq_battlefield_info_s2c{gbinfo=ParamGbInfo}).

encode_jszd_battlefield_info_s2c(Score,KillNum,Honor,ParamGbInfo)->
	login_pb:encode_jszd_battlefield_info_s2c(#jszd_battlefield_info_s2c{score=Score,killnum=KillNum,honor=Honor,gbinfo=ParamGbInfo}).

encode_battlefield_info_error_s2c(Error)->
	login_pb:encode_battlefield_info_error_s2c(#battlefield_info_error_s2c{error=Error}). 
					 
encode_battle_start_s2c(Type,LeftTime)->
	login_pb:encode_battle_start_s2c(#battle_start_s2c{type = Type,lefttime = LeftTime} ).

encode_tangle_update_s2c(RankInfos)->
	login_pb:encode_tangle_update_s2c(#tangle_update_s2c{trs = RankInfos}).
  
encode_tangle_remove_s2c(RoleId)->
	login_pb:encode_tangle_remove_s2c(#tangle_remove_s2c{roleid = RoleId}).

encode_battle_end_s2c(Honor,Exp)->
	login_pb:encode_battle_end_s2c(#battle_end_s2c{honor = Honor,exp = Exp}).

encode_battle_other_join_s2c(Commer)->
	login_pb:encode_battle_other_join_s2c(#battle_other_join_s2c{commer = Commer}).
 
encode_battle_self_join_s2c(RankInfos,BattleType,BattleId,LeftTime)->
	login_pb:encode_battle_self_join_s2c(#battle_self_join_s2c{trs = RankInfos,battletype = BattleType,battleid = BattleId,lefttime = LeftTime}).

encode_tangle_records_s2c({Year,Month,Day},Class,TotalBattle,MyBattle)->
	login_pb:encode_tangle_records_s2c(#tangle_records_s2c{year = Year,month = Month,day = Day,
							type = Class,totalbattle = TotalBattle,mybattleid = MyBattle}).

encode_join_battle_error_s2c(Errno)->
	login_pb:encode_join_battle_error_s2c(#join_battle_error_s2c{errno=Errno}).
	
encode_tangle_topman_pos_s2c(Poses)->
	login_pb:encode_tangle_topman_pos_s2c(#tangle_topman_pos_s2c{roleposes = Poses} ).

encode_battle_waiting_s2c(Time_s)->
	login_pb:encode_battle_waiting_s2c(#battle_waiting_s2c{waitingtime = Time_s} ).

encode_tangle_more_records_s2c(RankInfos,Myrank,Has_Reward)->
	login_pb:encode_tangle_more_records_s2c(#tangle_more_records_s2c{
			trs = RankInfos,year = 0,month = 0,day = 0,type = 0,myrank = Myrank,battleid = 0,has_reward = Has_Reward} ).

encode_notify_to_join_yhzq_s2c(Battle_id,Camp)->%%@@wb20130422鍔犲叆鍥界帇浜夊ず鎴業d
	login_pb:encode_notify_to_join_yhzq_s2c(#notify_to_join_yhzq_s2c{battle_id=Battle_id,camp=Camp}).

encode_yhzq_camp_info_s2c(RedNum,BlueNum,RedScore,BlueScore,RGName,BGName)->
	login_pb:encode_yhzq_camp_info_s2c(#yhzq_camp_info_s2c{redplayernum = RedNum,
														   blueplayernum = BlueNum,
														   redscore = RedScore,
														   bluescore = BlueScore,
														   redguild = RGName,
														   blueguild = BGName}). 

encode_yhzq_zone_info_s2c(ZoneList)->
	MapZoneList = lists:map(fun({Id,State})-> #zoneinfo{zoneid=Id,state = State} end, ZoneList),
	login_pb:encode_yhzq_zone_info_s2c(#yhzq_zone_info_s2c{zonelist = MapZoneList}).

encode_yhzq_award_s2c(Winner,Honor,AddExp)->
	login_pb:encode_yhzq_award_s2c(#yhzq_award_s2c{winner = Winner,honor = Honor,exp = AddExp}).	

encode_yhzq_battle_self_join_s2c(RedInfo,BlueInfo,BattleId,LeftTime)->
	login_pb:encode_yhzq_battle_self_join_s2c(#yhzq_battle_self_join_s2c{redroles = RedInfo,blueroles = BlueInfo,battleid = BattleId,lefttime = LeftTime}).

encode_yhzq_battle_other_join_s2c(RoleInfo,RoleCamp)->
	login_pb:encode_yhzq_battle_other_join_s2c(#yhzq_battle_other_join_s2c{role = RoleInfo,camp = RoleCamp}).

encode_yhzq_battle_update_s2c(RoleInfo,RoleCamp)->
	login_pb:encode_yhzq_battle_update_s2c(#yhzq_battle_update_s2c{role = RoleInfo,camp = RoleCamp}).

encode_yhzq_battle_remove_s2c(RoleId,RoleCamp)->
	login_pb:encode_yhzq_battle_remove_s2c(#yhzq_battle_remove_s2c{roleid = RoleId,camp = RoleCamp}).

encode_yhzq_battle_player_pos_s2c(PlayerPosInfo)->
	Players = lists:map(fun({RoleId,X,Y})-> #tp{roleid = RoleId,x = X, y = Y} end, PlayerPosInfo),
	login_pb:encode_yhzq_battle_player_pos_s2c(#yhzq_battle_player_pos_s2c{players = Players}).

encode_yhzq_battle_end_s2c()->
	login_pb:encode_yhzq_battle_end_s2c(#yhzq_battle_end_s2c{}).

encode_yhzq_error_s2c(Errno)->
	login_pb:encode_yhzq_error_s2c(#yhzq_error_s2c{reason = Errno}).

encode_yhzq_all_battle_over_s2c()->
	login_pb:encode_yhzq_all_battle_over_s2c(#yhzq_all_battle_over_s2c{}).

encode_tangle_kill_info_request_s2c({Year,Month,Day},BattleType,BattleId,KillInfo,BeKillInfo)->
	login_pb:encode_tangle_kill_info_request_s2c(#tangle_kill_info_request_s2c{year = Year,month = Month,day = Day,battletype = BattleType,battleid = BattleId,killinfo = KillInfo,bekillinfo = BeKillInfo}).

handle(#battle_join_c2s{type=Type},RolePid)->
	role_processor:battle_join_c2s(RolePid,Type);

handle(#battle_leave_c2s{},RolePid)->
	role_processor:battle_leave_c2s(RolePid);

handle(#battle_reward_c2s{},RolePid)->
	role_processor:battle_reward_c2s(RolePid);

handle(#get_instance_log_c2s{},RolePid)->
	role_processor:get_instance_log_c2s(RolePid);

handle(#tangle_records_c2s{year = Year,month = Month,day = Day,type =Class},RolePid)->
	role_processor:tangle_records_c2s({Year,Month,Day},Class,RolePid);

handle(#tangle_more_records_c2s{year = _Year,month = _Month,day = _Day,type = _Class,battleid = _BattleId},RolePid)->
	role_processor:tangle_more_records_c2s(RolePid);

handle(#join_yhzq_c2s{reject = Reject},RolePid)->
	role_processor:join_yhzq_c2s(Reject,RolePid);

handle(#leave_yhzq_c2s{},RolePid)->
	role_processor:leave_yhzq_c2s(RolePid);

handle(#yhzq_award_c2s{},RolePid)->
	role_processor:yhzq_award_c2s(RolePid);

handle(#battle_reward_by_records_c2s{year = Year,month = Month,day = Day,battletype =BattleType,battleid = BattleId},RolePid)->
	role_processor:battle_reward_by_records_c2s({Year,Month,Day},BattleType,BattleId,RolePid);

handle(#tangle_kill_info_request_c2s{year = Year,month = Month,day = Day,battletype = BattleType,battleid = BattleId},RolePid)->
	%%io:format("tangle_kill_info_request_c2s,date:~p,Class:~p,BattleId:~p,RolePid:~p~n",[{Year,Month,Day},BattleType,BattleId,RolePid]),
	role_processor:tangle_kill_info_request_c2s({Year,Month,Day},BattleType,BattleId,RolePid);

handle(Message,RolePid)->
	RolePid ! {battle_ground,Message}.

process_msg(#battlefield_info_c2s{battle=Battle})-> 
	battle_ground_op:handle_rule_description(Battle);

process_msg(_)->
	ignor.
