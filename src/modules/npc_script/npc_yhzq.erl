%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-3-24
%% Description: TODO: Add description to npc_yhzq
-module(npc_yhzq).

%%
%% Exported Functions
%%
-export([proc_special_msg/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("battle_define.hrl").
-include("common_define.hrl").

%%
%% API Functions
%%
proc_special_msg({special_attack,Info})->
%%	io:format("proc_special_msg ~p ~n",[Info]),
	handle_attack(Info);
	
proc_special_msg({change_faction,Info})->
	handle_change_faction(Info);
		
proc_special_msg(_)->
	nothing.

%%
%% Local Functions
%%
handle_attack({EnemyId,{BattleNode,BattleProc}})->
	case creature_op:what_creature(EnemyId) of
		role->			
			EnemyInfo = creature_op:get_creature_info(EnemyId),
			if
				EnemyInfo =:= undefined ->
					nothing;
				true->
					EnemyCamp = get_camp_from_roleinfo(EnemyInfo),
					SelfInfo = get(creature_info),
					SelfFac = get_battle_state_from_npcinfo(SelfInfo),
					case get(yhzq_npc_last_faction) of
						undefined->
							NewLastFaction = ?ZONEIDLE;
						LastFaction->
							NewLastFaction = LastFaction
					end,
%%					io:format("RoleCamp ~p SelfFac ~p last faction ~p ~n",[EnemyCamp,SelfFac,NewLastFaction]),
					if
						EnemyCamp =:= SelfFac ->	%% 鍚屼竴闃佃惀 涓嶅厑璁镐簤澶�
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= ?YHZQ_CAMP_RED,SelfFac =:= ?REDGETFROMBLUE ->
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= ?YHZQ_CAMP_BLUE,SelfFac =:= ?BLUEGETFROMRED ->
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= NewLastFaction-> %% 鎶㈠埌浜嗚瀵规柟鎶㈣蛋涓�鍗婄殑鏃�
							if
								NewLastFaction =:= ?ZONEIDLE -> %%涓婃鏄櫧鏃�
									NextFaction = NewLastFaction;
								true->
									NextFaction = EnemyCamp
							end;	
						NewLastFaction =:= ?ZONEIDLE -> %% 澶哄彇鍒颁竴涓湭琚崰棰嗚繃鐨勬棗
							if
								EnemyCamp =:= ?YHZQ_CAMP_RED ->
									NextFaction = ?REDGETFROMBLUE;
								true->
									NextFaction = ?BLUEGETFROMRED
							end;
						EnemyCamp =/= SelfFac->		%%澶哄彇鍒颁竴涓鏂圭殑鏃楀笢
							if
								EnemyCamp =:= ?YHZQ_CAMP_RED ->
									NextFaction = ?REDGETFROMBLUE;
								true->
									NextFaction = ?BLUEGETFROMRED
							end;
						true->
							NextFaction = ?ZONEIDLE
					end,	
%%					io:format("NextFaction ~p ~n",[NextFaction]),		
					if
						NextFaction =:= ?ZONEIDLE ->			%%鐘舵�佽浆鎹㈤敊璇殑涓嶅鐞�
							nothing;
						true->
							case get(change_faction_timer) of
								undefined->
									nothing;
							ChangeTimer->
								timer:cancel(ChangeTimer)
						end,
						case yhzq_battle_db:get_npcproto(get(id),NextFaction) of
							[]->
%%								io:format("get_npcproto nothing ~n"),
								nothing;
							DisPlayId->
								%%鏀瑰彉鑷韩闃佃惀
								if
									NewLastFaction =:= ?ZONEIDLE->
										put(yhzq_npc_last_faction,?ZONEIDLE);
									true->
										put(yhzq_npc_last_faction,NextFaction)
								end,
								put(creature_info, set_battle_state_to_npcinfo(get(creature_info),NextFaction)),						
								%%鏀瑰彉鑷韩鏄剧ず				
								%%ProtoInfo = npc_db:get_proto_info_by_id(NewProtoId),
								put(creature_info, set_displayid_to_npcinfo(get(creature_info),DisPlayId)),
%%								io:format("id ~p displayid ~p ~n",[get(id),DisPlayId]),
								npc_op:broad_attr_changed([{displayid,DisPlayId}]),
								npc_op:update_npc_info(get(id),get(creature_info)),
								%%閫氱煡Battle 鏌愪釜鏃楀笢鐨勭姸鎬佸凡鏀瑰彉
								battle_ground_processor:take_a_zone(BattleNode,BattleProc,{NextFaction,get(id),EnemyId})
						end,
						case (NextFaction =:= ?TAKEBYRED) or (NextFaction =:= ?TAKEBYBLUE) of
							true->%%涓嶉渶瑕佷富鍔ㄦ敼鍙樿嚜韬ā鏉�
								nothing;		
							_-> %%闇�鏀瑰彉鑷韩妯℃澘
	%%							io:format("change state after ~p s ~n",[?YHZQ_CHANGE_STATE_TIME_S]),
								NewChangeTimer = timer:send_after(?YHZQ_CHANGE_STATE_TIME_S*1000,self(),{change_faction,{NextFaction,BattleNode,BattleProc,EnemyId}}),
								put(change_faction_timer,NewChangeTimer)
						end
					end
			end;
		_->
			nothing
	end.

handle_change_faction({CurFaction,BattleNode,BattleProc,PlayerId})->
%%	io:format("~p handle_change_faction ~p ~n",[get(id),CurFaction]),
	SelfInfo = get(creature_info),
	SelfFac = get_battle_state_from_npcinfo(SelfInfo),
	RealCurFaction = get_battle_state_from_npcinfo(SelfInfo),
	if
		CurFaction =/= RealCurFaction ->
			nothing;
		true->
			case CurFaction of
				?REDGETFROMBLUE->
					NextFaction = ?TAKEBYRED;	
				?BLUEGETFROMRED->
					NextFaction = ?TAKEBYBLUE;
				_->
					NextFaction = ?ZONEIDLE
			end,
			if
				NextFaction =:= ?ZONEIDLE ->
					nothing;
				true->		
					case yhzq_battle_db:get_npcproto(get(id),NextFaction) of
						[]->
							nothing;
						DisPlayId->
							%%鏀瑰彉鑷韩闃佃惀
							put(yhzq_npc_last_faction,CurFaction),
							put(creature_info, set_battle_state_to_npcinfo(get(creature_info),NextFaction)),						
							%%鏀瑰彉鑷韩鏄剧ず
							%%ProtoInfo = npc_db:get_proto_info_by_id(NewProtoId),
							put(creature_info, set_displayid_to_npcinfo(get(creature_info),DisPlayId)),
							npc_op:broad_attr_changed([{displayid,DisPlayId}]),
							npc_op:update_npc_info(get(id),get(creature_info)),
							%%閫氱煡Battle 鏌愪釜鏃楀笢鐨勭姸鎬佸凡鏀瑰彉
							battle_ground_processor:take_a_zone(BattleNode,BattleProc,{NextFaction,get(id),PlayerId})
					end
			end
	end.