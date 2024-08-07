%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("error_msg.hrl").
-define(EVERQUEST_TABLE_NAME,everquests_table).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	quest_list:
%%	{Questid,State,DetailStatus,ReceiveTime,LimitTime,ExtStatus}
%%	DetailStatus = MobStatus ++ MobItemsStatus ++ OtherStatus
%%  MobStatus = {MobId,Objective,Value}
%%  MobItemsStatus = {MobId,Rate,Objective,Value} 
%%  OtherStatus = {Message,Value}
%%	finished_quests: [Questid]
%%	AddationStatus : [RequiredSomething] :鐢ㄦ潵淇濆瓨涓�浜涗腑闂寸姸鎬�,姣斿璺熼殢鑰卬pcid,閲囬泦杩囩殑npcid,姣忔寰�鍒楄〃澶磋拷鍔�
%%	relation_msgs : [{monster_kill,ID},Questid}]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%acc_script : 妫�娴嬫槸鍚﹁兘棰嗗彇璇ヤ换鍔＄殑鐗规畩鑴氭湰. 杩斿洖:true/false/{false,ERRNO},ERRNO涓洪渶瑕佹彁绀虹帺瀹剁殑淇℃伅
%%on_acc_script : 鍦ㄦ帴鍙椾换鍔″墠鎵ц鐨勮剼鏈�.	杩斿洖:true/false/{false,ERRNO},ERRNO涓洪渶瑕佹彁绀虹帺瀹剁殑淇℃伅
%%com_script : 鎺ュ彈浠诲姟鍚庢墽琛岀殑鑴氭湰,杩斿洖:鐗规畩鐩爣鐨勪换鍔″湪鎺ュ彈浠诲姟鏃剁殑鐩爣鐘舵�乕{Msg,Value}] 
%%on_com_script : 瀹屾垚浠诲姟鏃舵墽琛岀殑鑴氭湰. 杩斿洖:true/false/{false,ERRNO},ERRNO涓洪渶瑕佹彁绀虹帺瀹剁殑淇℃伅
%%on_delete_addation_state : 鏀惧純浠诲姟鍓嶆墽琛岀殑棰濆鐘舵�佹竻闄よ剼鏈�,鍒╃敤on_com_script瀛楁鐨勮剼鏈�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init()->
	put(quest_list,[]),
	put(finished_quests,[]),
	put(relation_msgs,[]),
	put(start_quest,[]).

	
load_from_db(Roleid)->
	Questinfo = quest_role_db:get_questinfo_by_roleid(Roleid),
	case quest_role_db:get_quest_list(Questinfo) of
		[]->	
			put(quest_list,[]),
			put(relation_msgs,[]),
			put(finished_quests,[]);
		{QuestList,Relation_msgs,Finished,EverList}->
			put(quest_list,QuestList),
			put(relation_msgs,Relation_msgs),
			put(finished_quests,Finished),
			everquest_op:load_from_db(EverList)
	end,			
	init_timer().
	
init_timer()->
	lists:foreach(fun({Questid,_,_,StartTime,LimitTime,_AddationStatus})->
		case LimitTime of
			0->
				nothing;
			LimitTime->				%%濡傛灉宸茬粡杩囦簡,寤惰繜涓�浼氬啀鍙� 5s
				Lefttime = erlang:max(5000,LimitTime*1000 - timer:now_diff(timer_center:get_correct_now(),StartTime)),				
				erlang:send_after(erlang:trunc(Lefttime/1000),self(),{quest_timeover,Questid})
		end								
	end,get(quest_list)).
	
get_all_questid()->
	lists:map(fun({Questid,_,_,_,_,_AddationStatus})->
			Questid
		end,get(quest_list)).
	
has_quest(Questid)->
	case lists:keyfind(Questid,1,get(quest_list)) of
		false ->
			false;
		_ ->
			true
	end.		
	
get_quest_accept_time(Questid)->
	case lists:keyfind(Questid,1,get(quest_list)) of
		false ->
			false;
		{Questid,_,_,ReceiveTime,_,_AddationStatus} ->
			ReceiveTime
	end.
	
get_quest_statu(Questid)->
	case lists:keyfind(Questid,1,get(quest_list)) of
		{_,_,DetailStatus,_,_,_AddationStatus}->
			DetailStatus;
		_->
			[]
	end.
	
get_quest_state(Questid)->
	case lists:keyfind(Questid,1,get(quest_list)) of
		{_,State,_,_,_,_AddationStatus}->
			State;
		_->
			[]
	end.
	
get_addation_state(Questid)->
	case lists:keyfind(Questid,1,get(quest_list)) of
		{_,_,_,_,_,AddationStatus}->
			AddationStatus;
		_->
			[]
	end.	

regist_mobs_msgs(MobIds,Questid) when is_list(MobIds)->
	lists:foreach(fun(MobIdTmp)-> regist_mobs_msgs(MobIdTmp,Questid) end,MobIds);

regist_mobs_msgs(MobId,Questid)->	
	regist_msgs({monster_kill,MobId},Questid).	
	
unregist_mobs_msgs(MobIds,Questid) when is_list(MobIds)->
	lists:foreach(fun(MobIdTmp)-> unregist_mobs_msgs(MobIdTmp,Questid) end,MobIds);
unregist_mobs_msgs(MobId,Questid)->	
	unregist_msgs({monster_kill,MobId},Questid).
		
regist_msgs(Messages,Questid)->
	put(relation_msgs,get(relation_msgs)++[{Messages,Questid}]).

has_msg(Message)->
	lists:keymember(Message,1,get(relation_msgs)).

%%
%%return [] | real msg {obt_item,TemplateList}
%%
has_special_msg({obt_item,TemplateId})->
	Ret = lists:foldl(fun(RelationMsg,Acc)-> 
							case Acc of
								[]->
									case RelationMsg of
										{{obt_item,MsgArg},_}->
											if
												is_list(MsgArg)->
													case lists:member(TemplateId,MsgArg) of
														true->
															MsgArg;
														_->
															Acc
													end;
												true->
													Acc
											end;
										_->
											Acc
									end;				
								_->
									Acc
							end
						end,[],get(relation_msgs)),
	if
		Ret =:= []->
			[];
		true->
			Ret
	end;
has_special_msg(equipment_enchantments)->
	lists:foldl(fun(RealitionMessage,Acc)->
						case Acc of
							[]->
								case RealitionMessage of
									{{equipment_enchantments,ObLevel},_}->
										{equipment_enchantments,ObLevel};
									_->
										Acc
								end;
							_->
								Acc
						end
				end,[],get(relation_msgs));
	
has_special_msg(_)->
	[].

unregist_msgs(Messages,Questid)->
	put(relation_msgs,lists:delete({Messages,Questid},get(relation_msgs))).
	
unregist_msgs_by_quest(Questid)->
	put(relation_msgs,lists:filter(fun({_,TmpQuestid})->TmpQuestid =/= Questid end,get(relation_msgs))).	

insert_to_finished(Questid)->
	case has_been_finished(Questid) of
		false->
			put(finished_quests,get(finished_quests)++[Questid]);
		true->
			slogger:msg("insert_to_finished dup??? ~p ~n",[Questid])
		end.

has_been_finished(QuestId)->
	lists:member(QuestId,get(finished_quests)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							鐘舵�佹洿鏂�
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update({obt_item,TemplateId} = Message)->
	case has_msg(Message) of
		true->
			update(Message,item_util:get_items_count_onhands(TemplateId));
		_->
			case has_special_msg(Message) of
				[]->
					nothing;
				ItemList->
					NewMessage = {obt_item,ItemList},
					ItemNum = lists:foldl(fun(Id,Acc)-> Acc + item_util:get_items_count_onhands(Id) end,0,ItemList),
					update(NewMessage,ItemNum)
			end		
	end;

update({equipment_enchantments,Level}=Message)->
		case has_special_msg(equipment_enchantments) of
			[]->
				nothing;
			{equipment_enchantments,ObLevel}->
				update({equipment_enchantments,ObLevel},item_util:get_enchantments_on_item_body(ObLevel))
		end;
update(Message)->
	update(Message,1).
		
update(Message,MsgValue)->
	update_with_ext_statu(Message,MsgValue,[]).

update_with_ext_statu(Message,MsgValue,ExtStatu)->
	lists:foreach(fun({Msg,Questid})->
			if
				Msg =:= Message->
					case lists:keyfind(Questid,1,get(quest_list)) of
					{Questid,_State,DetailStatus,ReceiveTime,LimitTime,AddationStatus}->										
						NewStatus = update_statu(Questid,DetailStatus,Message,MsgValue),			
						case NewStatus =/= DetailStatus of
							true-> 						
								case can_be_finished(Questid,NewStatus) of
									true->
										NewState =  ?QUEST_STATUS_COMPLETE;
									false->
										NewState  = ?QUEST_STATUS_INCOMPLETE
								end,
								put(quest_list,lists:keyreplace(Questid,1,get(quest_list),{Questid,NewState,NewStatus,ReceiveTime,LimitTime,[ExtStatu|AddationStatus]})),
								update_quest_to_client(Questid,NewState,make_status_valuelist(NewStatus));
							false->
							nothing
						end; 		
					false->
						slogger:msg("update error has not Questid  in relation_msgs ~p ~n",[Questid]),
						unregist_msgs(Message,Questid)
					end;		
				true->
					nothing			
		end end,get(relation_msgs)).
		
set_quest_finished(QuestId)->
	case lists:keyfind(QuestId,1,get(quest_list)) of
		{QuestId,_State,DetailStatus,ReceiveTime,LimitTime,_AddationStatus}->
			NewStatus = set_status_finished(QuestId,DetailStatus),
			put(quest_list,lists:keyreplace(QuestId,1,get(quest_list),{QuestId,?QUEST_STATUS_COMPLETE,NewStatus,ReceiveTime,LimitTime,_AddationStatus})),
			update_quest_to_client(QuestId,?QUEST_STATUS_COMPLETE,make_status_valuelist(NewStatus));
		false->					
			slogger:msg("set_quest_finished error has not QuestId ~p ~n",[QuestId])
	end.
	
update_quest_to_client(Questid,State,Status)->
	Message = quest_packet:encode_quest_statu_update_s2c(Questid,State,Status),
	role_op:send_data_to_gate(Message).

%%妫�鏌bjective鏄惁瀹屾垚->鍒犻櫎娑堟伅娉ㄥ唽 
update_statu(Questid,Status,Message,MsgValue)->
	case Message of
		{monster_kill,MobId}->				%%鏉�鎬�
			apply_monster_kill_msg(MobId,Questid,Status);
		_ ->									%%闈炴潃鎬被鐨勫叾浠�
			apply_objective_msg(Questid,Status,Message,MsgValue)
	end.

%%return new value
add_mobs_msg_value(Value,Objective,MobIdOrMobIds,Questid)->
	NewValue = Value + 1,
	if 
		NewValue >= Objective->
			unregist_mobs_msgs(MobIdOrMobIds,Questid);
		true->
			nothing
	end,
	NewValue.

%%return new state
add_mobs_msg_value_with_rate(MobIdOrMobIds,Rate,Objective,Value,Questid)->	
	case random:uniform(100) =< Rate of
		true->
			NewValue = add_mobs_msg_value(Value,Objective,MobIdOrMobIds,Questid),	
			{MobIdOrMobIds,Rate,Objective,NewValue};
		false->
			{MobIdOrMobIds,Rate,Objective,Value}
	end.	

apply_monster_kill_msg(MobId,Questid,Status)->	
	lists:map(fun(Statu)->			
		case Statu of		
			{MobIds,Objective,Value} when is_list(MobIds)->
				case lists:member(MobId,MobIds) of
					true->
						NewValue = add_mobs_msg_value(Value,Objective,MobIds,Questid),
						{MobIds,Objective,NewValue};
					_->
						{MobIds,Objective,Value}
				end ;	
			{MobId,Objective,Value} ->				   	
				NewValue = add_mobs_msg_value(Value,Objective,MobId,Questid),
				{MobId,Objective,NewValue};			 
			
			{MobId,Rate,Objective,Value}->			%%鏀堕泦
				add_mobs_msg_value_with_rate(MobId,Rate,Objective,Value,Questid);
			{MobIds,Rate,Objective,Value} when is_list(MobIds)->
				case lists:member(MobId,MobIds) of
					true->
						add_mobs_msg_value_with_rate(MobIds,Rate,Objective,Value,Questid);
					_->
						{MobIds,Rate,Objective,Value}
				end;
			Other->
				Other
		end end,Status).	
			
apply_objective_msg(Questid,Status,Message,MsgValue)->
	QuestInfo = quest_db:get_info(Questid),
	lists:map(fun(Statu)->
		case Statu of		  
		{Message,Value}->
			 case lists:keyfind(Message,1,quest_db:get_objectivemsg(QuestInfo)) of
			 	{{obt_item,_}=Message,Op,ObjValue}->
			 		%%obt_item:鑾峰彇鐗╁搧浼氶噸鏂拌绠楀綋鍓嶈儗鍖呮暟閲�,鍥犱负浣跨敤add_to,鎵�浠ラ渶瑕丮sgValue-Value+Value =MsgValue 
					NewValue = get_quest_states_by_op(Op,ObjValue,MsgValue-Value,Value),	
					{Message,NewValue};	
				 {{equipment_enchantments,_},Ob,ObValue}->
					 NewValue = get_quest_states_by_op(Ob,ObValue,MsgValue,Value),	
					 {Message,NewValue};
				{Message,Op,ObjValue}->		
					NewValue = get_quest_states_by_op(Op,ObjValue,MsgValue,Value),	
					{Message,NewValue};
				false->	
					slogger:msg("apply_objective_msg get_objectivemsg error Questid:~p Message~p ~n",[Questid,Message]),
					{Message,Value}
			end;
		_->
			Statu
	end end,Status).

%%鎿嶄綔鐮�,鐩爣鍊�,娑堟伅鍊�,鍘熷鍊�
get_quest_states_by_op(Op,ObjValue,MsgValue,OldValue)->	
	case Op of
		%%鍦ㄩ�嗗悜琛屼负鏃�,鍙互灏哅sgValue璁剧疆鎴愯礋鍊�,姣斿:鑴变笅琛ｆ湇
		add_to->
			MsgValue + OldValue;
		ge->
			if
				MsgValue >= ObjValue ->
					1;
				true->			
			 		0
			 end;	
		le->
			if
				MsgValue =< ObjValue ->
					1;
				true->			
			 		0
			 end;							
		eq->
			if
				(MsgValue  =:= ObjValue)->
					1;
				true->			
			 		0
			 end
	end.		
	
make_status_valuelist(DetailStatus)->
	lists:map(fun(Statu)->
			case Statu of
				{_,_,Value}->
					Value;
				{_,_,_,Value}->
					Value;
				{_,Value}->
					Value
			end end,DetailStatus).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							缁欏嚭涓�涓换鍔�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
start_quest(QuestId,NpcId)->		
	State = quest_op:calculate_quest_state(QuestId),
	if
		(State =:= ?QUEST_STATUS_COMPLETE)
		or 
		(State =:= ?QUEST_STATUS_AVAILABLE)->
			if
				(NpcId=:=0) and (State =:= ?QUEST_STATUS_AVAILABLE)->
					put(start_quest,[QuestId|get(start_quest)]);
				true->
					nothing
			end,	
			
			Message = quest_packet:encode_quest_details_s2c(QuestId,State,NpcId),
			role_op:send_data_to_gate(Message);			
		true->
			error
	end.
	
is_in_start_quest(QuestId)->
	lists:member(QuestId,get(start_quest)).
		
remove_start_quest(QuestId)->
	put(start_quest,lists:delete(QuestId,get(start_quest))).	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							鎺ユ敹浠诲姟
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%杩斿洖{State,DetailStatus}/[]
accept_quest(QuestId)->
	remove_start_quest(QuestId),
	QuestInfo = quest_db:get_info(QuestId), 
	case can_accept_by_info(QuestInfo) of
		true->
			%%鎵ц鎺ユ敹鑴氭湰
			SriptRe = 
			case quest_db:get_on_acc_script(QuestInfo) of
				[]->
					true;
				AfterReceiveScritp->	
				 	exec_beam(AfterReceiveScritp,on_acc_script,QuestId)
			end,
			case SriptRe of
				true->
					add_quest_to_list(QuestId),
					gm_logger_role:role_quest_log(get(roleid),QuestId,accept,get(level)),
					{_,State,DetailStatus,_,_,_AddationStatus} = lists:keyfind(QuestId,1,get(quest_list)),
					{State,make_status_valuelist(DetailStatus)};
				{false,Errno}->
					Msg = quest_packet:encode_quest_accept_failed_s2c(Errno),
					role_op:send_data_to_gate(Msg),
					[];
				_->
					[]	
			end;
		{false,Errno}->
			Msg = quest_packet:encode_quest_accept_failed_s2c(Errno),
			role_op:send_data_to_gate(Msg),
			[];	
		_->
			[]	
	end.	

						
%%娣诲姞涓�涓柊浠诲姟,娣诲姞鐨勬椂鍊欏氨瑕佹娴嬬姸鎬�,娉ㄥ唽鍏宠仈娑堟伅TODO:limittime :涓嶈兘鐩存帴鍒�,瑕佺畻鏃堕棿
add_quest_to_list(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	%%鐢变簬铏氭嫙浠诲姟鐗╁搧,鎵�浠ユ潃鎬暟鍜岀墿鍝佹暟寮�濮嬪潎涓�0
	MobStatus = lists:foldl(fun({MobId,Objective},TmpStatus)->
					regist_mobs_msgs(MobId,QuestId),
					TmpStatus ++ [{MobId,Objective,0}]
				end
	,[],quest_db:get_reqmob(QuestInfo)),
	MobItemStatus =  lists:foldl(fun({MobId,Rate,Objective},TmpStatus)->
					regist_mobs_msgs(MobId,QuestId),
					TmpStatus ++ [{MobId,Rate,Objective,0}]
					end
	,[],quest_db:get_reqmobitem(QuestInfo)),
	DefaultMsgStates = 
	lists:map(fun({Msg,_Op,_Value})->
					regist_msgs(Msg,QuestId),
					{Msg,0}
		end,quest_db:get_objectivemsg(QuestInfo)),	
	%%鐗规畩msg闇�瑕佽剼鏈娴嬩笅							
	Srcipt = quest_db:get_com_script(QuestInfo),
	if 
		Srcipt =/= []->		%%鍒濆妫�楠屼笅鏄惁宸茬粡杈惧埌瑕佹眰,姣斿鏌愪欢琛ｆ湇宸茬粡鍦ㄨ韩涓婄┛鐫�{Message,Statu = 0/1}
			case exec_beam(Srcipt,com_script,QuestId) of
				false-> 		%%exec error
					OthersStatu = DefaultMsgStates;
				OthersStatu->
					nothing
			end;
		true->
			OthersStatu = DefaultMsgStates
	end,
	FullStatu = MobStatus ++ MobItemStatus ++ OthersStatu,
	case can_be_finished(QuestId,FullStatu) of
		true-> State = ?QUEST_STATUS_COMPLETE;
		false-> State = ?QUEST_STATUS_INCOMPLETE
	end,
	LimitTime = quest_db:get_limittime(QuestInfo),
	case LimitTime of
		0->
			nothing;
		LimitTime->
			erlang:send_after(LimitTime,self(),{quest_timeover,QuestId})
	end,
	AddationStatus = [],
	put(quest_list,get(quest_list) ++ [{QuestId,State,FullStatu,timer_center:get_correct_now(),LimitTime,AddationStatus}]).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			 			鏀惧純浠诲姟
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_role_quest_quit(QuestId)->		
	QuestInfo = quest_db:get_info(QuestId),
	case get_addation_state(QuestId) of
		[]->
			nothing;
		_->				%%濡傛灉鏈夐澶栫姸鎬�,鍥犱负涓嶄細璋冪敤on_com_script鐨勫畬鎴愯剼鏈�,鎵�浠ュ湪璋冪敤鑴氭湰涓璷n_delete_addation_state鐨勯澶栫姸鎬佺殑澶勭悊鑴氭湰
			case quest_db:get_on_com_script(QuestInfo) of
				[]->
					true;
				OnComScript->	
					exec_beam(OnComScript,on_delete_addation_state,QuestId)
			end
	end,
	case quest_db:get_isactivity(QuestInfo) of
		0->
			nothing;
		EverQuestId->
			everquest_op:hook_on_quest_quit(EverQuestId,QuestId)
	end,	
	quest_op:delete_from_list(QuestId),
	Message = quest_packet:encode_quest_list_remove_s2c(QuestId),
	role_op:send_data_to_gate(Message),
	gm_logger_role:role_quest_log(get(roleid),QuestId,quit,get(level)).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%							瀹屾垚浠诲姟
%%1.瀹屾垚浠诲姟,2,.缁欎簣濂栬祻,3.鎵ц瀹屾垚涔嬪悗鐨勮剼鏈� return quest_finished/Other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
complete_quest(QuestId,ChoiseSlot,NpcId)->
	QuestInfo = quest_db:get_info(QuestId),
	case has_quest(QuestId) and (QuestInfo=/=[]) of
		true->
			case can_be_finished(QuestId,get_quest_statu(QuestId)) of
				true->			
					EverQuestId = quest_db:get_isactivity(QuestInfo),
					case can_complete(QuestId,ChoiseSlot,QuestInfo) of
						true->
							ScriptsRe =
							case quest_db:get_on_com_script(QuestInfo) of
								[]->
									true;
								RewSripts->	
									exec_beam(RewSripts,on_com_script,QuestId)
							end,
							case ScriptsRe of
								true->							 
									Message = quest_packet:encode_quest_complete_s2c(QuestId),
									role_op:send_data_to_gate(Message),
									delete_from_list(QuestId),
									%%鑾峰彇濂栬祻
									get_rewards(QuestId,ChoiseSlot,QuestInfo),
									if
										EverQuestId=/= 0->
											everquest_op:hookon_quest_complete_quest(EverQuestId,QuestId);
										true->
											insert_to_finished(QuestId)
									end,
									NextQuests = quest_db:get_nextquestid(QuestInfo),
									if 
										NextQuests =/= []-> 					%%鍙戦�佷笅涓�涓换鍔�						 	
											NextList = erlang:element(get_class_from_roleinfo(get(creature_info)),NextQuests),
											if
												 NextList =/= []->	
												 	RandSlot = random:uniform(erlang:length(NextList)),
												 	NextQuest = lists:nth(RandSlot,NextList),
												 	start_quest(NextQuest,NpcId);
												true->
													npc_function_frame:do_action_without_check(0,get(creature_info),NpcId,quest_action,[auto_give,NpcId])
											end;				
										true->
											nothing
									end,
									gm_logger_role:role_quest_log(get(roleid),QuestId,compelete,get(level)),
									activity_value_op:update({complete_quest,QuestId}),
									quest_finished;
								{false,Errno}->
									Message = quest_packet:encode_quest_complete_failed_s2c(QuestId,Errno),
									role_op:send_data_to_gate(Message),
									error;
								_->
									error	
							end;						
						full->
							Message = quest_packet:encode_quest_complete_failed_s2c(QuestId,?ERROR_PACKEGE_FULL),
							role_op:send_data_to_gate(Message),
							error;						
						money->
							Message = quest_packet:encode_quest_complete_failed_s2c(QuestId,?ERROR_LESS_MONEY),
							role_op:send_data_to_gate(Message),
							error;
						_->
							error																	
					end;																																
				false->
					slogger:msg("hack find!complete_quest not can_be_finished Quest:~p ~n",[QuestId]),
					error
			end;
		false->
			slogger:msg("hack find!complete_quest not has Quest:~p ~n",[QuestId]),
			error
	end.		

delete_from_list(Questid)->
	 put(quest_list,lists:keydelete(Questid,1,get(quest_list))),
	 unregist_msgs_by_quest(Questid).
	 
%%妫�娴嬫槸鍚﹁兘鎻愪氦浠诲姟,璁＄畻鐗╁搧灏嗚绠椾换鍔℃湰韬鍔�+寰幆浠诲姟濂栧姳
can_complete(QuestId,ChoiseSlot,QuestInfo)->
	EverQuestId = quest_db:get_isactivity(QuestInfo),
	if
		EverQuestId =/= 0 ->
			{_EverExp,EverMoneys,EverItems} = everquest_op:hookon_get_rewards(EverQuestId,QuestId);
		true->
			EverMoneys = [],EverItems = []
	end,
	FullItems = quest_db:get_choiceitemid(QuestInfo),
	NormalItems  = quest_db:get_rewitem(QuestInfo) ++ EverItems,
	Rules = quest_db:get_rewrules(QuestInfo),
	ObOrLoseMoney = quest_db:get_reworreqmoney(QuestInfo) ++ EverMoneys,
	MoneyCheck = lists:foldl(fun({MoneyType,MoneyCount},Result)->
				if
					not Result -> Result;
					true->
						case  MoneyCount<0 of			%%LoseMoney
							true->
								role_op:check_money(MoneyType,MoneyCount);
							false->
								true
						end
				end end ,true,ObOrLoseMoney ),
	if
		MoneyCheck ->
			 case erlang:length(FullItems) < ChoiseSlot of
				true->
					error;
				false->			
					if
						ChoiseSlot =/= 0->					
							%%渚涢�夋嫨鐨勫彧鑳芥湁涓�鏍风墿鍝�	
							ObtNum = 1 + erlang:length(Rules) + erlang:length(NormalItems);
						true->
							ObtNum  = erlang:length(Rules) + erlang:length(NormalItems)																		 
					end,
					case (ObtNum =:= 0) or (package_op:get_empty_slot_in_package(ObtNum) =/= 0) of
						false->							%%鍖呰９婊�,涓嶈兘浜�
							full;
						_->
							true
			 		end
			 end;
		true->
			money
	end.
	
	
%%濂栧姳灏嗚绠椾换鍔℃湰韬鍔�+寰幆浠诲姟濂栧姳	 
get_rewards(QuestId,ChoiseSlot,QuestInfo)->
	EverQuestId = quest_db:get_isactivity(QuestInfo),
	if
		EverQuestId =/= 0 ->
			%%绂荤嚎缁忛獙鍔犳垚
%% 			OfflineRate = offline_exp_op:handle_everquest_finished(EverQuestId),
			OfflineRate = 1,%%鏍规嵁绛栧垝瑕佹眰锛岀绾垮姞鎴愭殏鏃舵敼鎴�1
			{EverExp,EverMoneys,EverItems} = everquest_op:hookon_get_rewards(EverQuestId,QuestId);
		true->
			OfflineRate = 1,
			EverExp = 0,EverMoneys = [],EverItems = []
	end,
	FullItems = quest_db:get_choiceitemid(QuestInfo),
	ChoiseLength = erlang:length(FullItems),
	NormalItems  = quest_db:get_rewitem(QuestInfo)++EverItems,
	Rules = quest_db:get_rewrules(QuestInfo),
	GlobalRate = global_exp_addition:get_role_exp_addition(quest),
	Rate = 1,%%鏍规嵁绛栧垝瑕佹眰锛屽姞鎴愭殏鏃舵敼鎴�1
%% 	Rate = fatigue:get_gainrate()+GlobalRate,
	ObXp = trunc((quest_db:get_rewxp(QuestInfo)+EverExp)*OfflineRate*Rate),
	ObOrLoseMoney = lists:map(fun({TypeTmp,CountTmp})->
						if
							CountTmp>0-> 
								{TypeTmp,trunc(CountTmp*Rate)};
							true->
								{TypeTmp,CountTmp}
						end end,quest_db:get_reworreqmoney(QuestInfo)++EverMoneys),
	%%閫夋嫨鐗╁搧 			 
	if	
		(ChoiseSlot =/= 0) and (ChoiseLength >= ChoiseSlot) ->
			ObtItemsChoise = [lists:nth(ChoiseSlot,FullItems)];		
		true->
			ObtItemsChoise = [] 			
	end,									
	%%鍥哄畾濂栧姳鐗╁搧
	if
		 NormalItems =/= []->
		 	ObtItemsNormal = NormalItems ;
		 true->
		 	ObtItemsNormal = []
	end,
	%%闅忔満濂栧姳鐗╁搧
	if
		Rules =/= [] ->												
			ObtItemsApply = drop:apply_quest_droplist(Rules);
		true->
			ObtItemsApply = []
	end,	
	%%鑾峰彇濂栧姳:1,濂栧姳鐗╁搧.2.閲戦挶鍜岀粡楠�
	lists:foreach(fun({Itemid,ItemCount})->
						role_op:auto_create_and_put(Itemid,ItemCount,got_quest),
						creature_sysbrd_util:sysbrd({quest_got_item,Itemid},ItemCount)
				end,ObtItemsChoise++ObtItemsNormal++ObtItemsApply),
	
	lists:foreach(fun({MoneyType,MoneyCount})-> role_op:money_change(MoneyType,MoneyCount,got_quest) end,ObOrLoseMoney),						
%% 	role_op:obtain_exp(EverExp).
	role_op:obtain_exp(ObXp).
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						浠诲姟鐘舵��
%%1 QUEST_STATUS_COMPLETE/2 QUEST_STATUS_INCOMPLETE/3 QUEST_STATUS_AVAILABLE/4 QUEST_STATUS_UNAVAILABLE
%%	鍙氦(瀹屾垚)  					灏氭湭瀹屾垚					 鍙帴						涓嶅彲鎺�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%妫�楠屾煇浠诲姟鐘�1/2/3/4
calculate_quest_state(QuestId)->
	case has_quest(QuestId) of
		false->	
			QuestInfo = quest_db:get_info(QuestId), 
			case can_accept_by_info(QuestInfo) of
				true-> ?QUEST_STATUS_AVAILABLE;
				_-> ?QUEST_STATUS_UNAVAILABLE
			end;
		_->
			QuestStatu = get_quest_statu(QuestId),
			case can_be_finished(QuestId,QuestStatu) of
				true-> ?QUEST_STATUS_COMPLETE;
				false->	?QUEST_STATUS_INCOMPLETE
			end			
	end.

%%杩斿洖npc澶勮缁嗕换鍔＄殑鍒楄〃[{Questid,QuestStatu}]
calculate_questgiver_details(QuestIdAccs,QuestIdSubs)->
	%%1.妫�鏌ュ彲鎺ョ殑	
	AccList = lists:foldl(fun(QuestId,TmpAccList)->
	%%npc澶勪笉杩斿洖鍙帴鐨勫惊鐜换鍔�.
					QuestInfo = quest_db:get_info(QuestId),			%%鍔犲叆鏃ュ父浠诲姟鐨勫彲鎺�
					case quest_db:get_isactivity(QuestInfo) of
						0-> 
							case can_accept_by_info(QuestInfo) of
								true->
									TmpAccList ++ [{QuestId,?QUEST_STATUS_AVAILABLE}];
								_->
									TmpAccList 
							end;
						_->
							TmpAccList
					end	
					end,[],QuestIdAccs),
					
	%%2.妫�鏌ュ彲浜ょ殑鍜屾湭瀹屾垚鐨�
	QuestListOnhands =	lists:foldl(fun({QuestId,State,_,_,_,_AddationStatus},TmpList)->
						case lists:member(QuestId,QuestIdSubs) of
							true->											
								TmpList++ [{QuestId,State}];
							false->
								TmpList
						end
					end,[],get(quest_list)),
	AccList ++ QuestListOnhands.
	
%%妫�楠宯pc鐘舵�佺粰瀹㈡埛绔樉绀哄湪澶翠笂!浼樺厛椤哄簭:QUEST_STATUS_COMPLETE/QUEST_STATUS_AVAILABLE/QUEST_STATUS_INCOMPLETE/QUEST_STATUS_UNAVAILABLE
%%铏界劧閫昏緫浠ｇ爜鍏ㄩ儴鏈�,浣嗕粠鎬ц兘瑙掑害涓婅�冭檻,灏介噺涓嶈鍋氭病鐢ㄧ殑妫�娴�,鎵�浠ュ鎴风搴旇鎶婅兘鍋氱殑鍒ゆ柇閮界洿鎺ヨ繃婊�,涓嶅彂璇锋眰
calculate_questgiver_state(QuestIdAccs,QuestIdSubs)->
	%%1.妫�鏌ュ綋鍓嶅垪琛ㄩ噷鏄惁鏈夊彲浜ょ殑鎴栬�呮湭瀹屾垚鐨�
	{HasComplete,HasIncomplete} = 
	lists:foldl(fun({QuestId,State,_,_,_,_AddationStatus},{TmpStatu,TmpHasInComplete})->
				if
					TmpStatu -> {TmpStatu,TmpHasInComplete};
					true->
						if
							State =:= ?QUEST_STATUS_COMPLETE-> 
								 	{lists:member(QuestId,QuestIdSubs),TmpHasInComplete};
							true-> 
								if
									TmpHasInComplete =:= false -> 
										{TmpStatu,lists:member(QuestId,QuestIdSubs)};
									true->
										{TmpStatu,TmpHasInComplete}
								end	
						end
				end	end,{false,false},get(quest_list)),
	%%2.濡傛灉娌″彲浜ょ殑,妫�鏌ユ槸鍚︽湁鍙帴鐨�
	if 				
		HasComplete -> ?QUEST_STATUS_COMPLETE;					%%鍙氦				
		true->											
			HasAcceptable = lists:foldl(fun(QuestId,Statu)->
				if 
					Statu-> Statu;
					true->
						QuestInfo = quest_db:get_info(QuestId),			%%鍔犲叆鏃ュ父浠诲姟鐨勫彲鎺�
						case quest_db:get_isactivity(QuestInfo) of
							0-> 
								case can_accept_by_info(QuestInfo) of
									true->
										true;
									_->
										false
								end;	
							EverId->
								everquest_op:hookon_adapt_can_accpet(EverId)
						end								
				end	end,false,QuestIdAccs),
			if
				HasAcceptable ->?QUEST_STATUS_AVAILABLE;						%%鍙帴
				true->
					if 
						HasIncomplete->?QUEST_STATUS_INCOMPLETE;			%%鏈夋湭瀹屾垚鐨� 
						true->?QUEST_STATUS_UNAVAILABLE
					end
			end
	end.
						
					

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%										妫�娴�							
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_status_finished(QuestId,QuestStatus)->
	QuestInfo = quest_db:get_info(QuestId),										
	lists:map( fun(Statu)->
			case Statu of
				{MobId,Objective,_Value}->				%%mob
						{MobId,Objective,Objective};
				{MobId,Rate,Objective,_Value}->				%%mob
						{MobId,Rate,Objective,Objective};			
				{Message,_Value}->
						case lists:keyfind(Message,1,quest_db:get_objectivemsg(QuestInfo)) of
							false->
								slogger:msg("error Message ~p in quest ~p ,objectivemsg error in quest_db and script~n",[QuestId,Message]),
								throw(error_quest_msg);
							{Message,Op,ObjValue}->		
								case Op of
									add_to-> {Message,ObjValue};
									ge -> {Message,1}; 
									le -> {Message,1};
									eq -> {Message,1}									
								end
						end
			end	end,QuestStatus).
			
can_be_finished(QuestId,QuestStatus)->
	QuestInfo = quest_db:get_info(QuestId),										
	lists:foldl( fun(Statu,CanFinish)->
			if 
				not CanFinish ->CanFinish;
				true->
					case Statu of
						{_MobId,Objective,Count}->				%%mob
								if
									Objective =< Count -> true;
									true-> false
								end;
						{_MobId,_Rate,Objective,Count}->				%%mob
								if
									Objective =< Count -> true;
									true-> false
								end;			
						{Message,Value}->
								case lists:keyfind(Message,1,quest_db:get_objectivemsg(QuestInfo)) of
									false->
										slogger:msg("error Message ~p in quest ~p ,objectivemsg error in quest_db and script~n",[QuestId,Message]),
										throw(error_quest_msg);
									{Message,Op,ObjValue}->		
										case Op of
											add_to-> Value >= ObjValue;
											ge -> Value=:= 1; 
											le -> Value=:= 1;
											eq -> Value=:= 1									
										end
								end
					end
			end	end,true,QuestStatus).

quest_get_adapt_c2s()->
	Level = get_level_from_roleinfo(get(creature_info)),
	List1 = ets:foldl(fun({QuestId,QuestInfo},Acc)->
				QuestLevel = quest_db:get_level(QuestInfo),
				EverQuestId = quest_db:get_isactivity(QuestInfo),
				if
%% 					(EverQuestId=:=0)and(Level >= QuestLevel) ->
					(EverQuestId=:=0) and (Level < QuestLevel+?QUEST_SCAN_RANGE) and(Level > QuestLevel -?QUEST_SCAN_RANGE )-> 
						case can_accept_by_info(QuestInfo,?QUEST_SCAN_RANGE) of
							true->	
								Acc ++	[QuestId ];
							_->
								Acc
						end;
					true->
						Acc
				end			
			end, [], ets_quest_info),
	List2 = ets:foldl(fun({EverQId,EverQInfo},Acc)->
				case everquest_op:hookon_adapt_can_accpet_info(EverQId,EverQInfo) of
					true->
						EveryQuestInfo=everquest_db:get_info(EverQId),
						QIds=everquest_db:get_quests(EveryQuestInfo),
						[QId|_]=lists:sort(QIds),
						[QId|Acc];
					_->
						Acc
				end end,[],?EVERQUEST_TABLE_NAME),%%@@wb20130322 ets_everquest_db
	Msg = quest_packet:encode_quest_get_adapt_s2c(List1,List2),
	role_op:send_data_to_gate(Msg).

%%return:true/false/{false,ERRNO} : ERRNO鏉ヨ嚜acc_script鑴氭湰閲岃繑鍥�
can_accept_by_info(QuestInfo)->
	can_accept_by_info(QuestInfo,0).	
	
can_accept_by_info(QuestInfo,Levelextend)->
	QuestId = quest_db:get_id(QuestInfo),
	EverQuestId = quest_db:get_isactivity(QuestInfo),
	CheckScript = quest_db:get_acc_script(QuestInfo),
	if
		EverQuestId =/= 0 ->			%%娲诲姩璧拌嚜宸辩殑鍙帴妫�娴嬪拰鑴氭湰妫�娴�
			BaseCheck = everquest_op:hookon_quest_can_accept(EverQuestId,QuestId);
		true->								%%姝ｅ父浠诲姟
			MyClass = get_class_from_roleinfo(get(creature_info)),
			MyLevel = get_level_from_roleinfo(get(creature_info)),
			{ClassId,Minlevel,Maxlevel} = quest_db:get_required(QuestInfo),
			BaseCheck =
			case has_quest(QuestId) of
				false->
					if 		
						ClassId =/= 0 ->
							SimpleCheck = (ClassId =:= MyClass)  and (MyLevel >= Minlevel) and (MyLevel =< Maxlevel);
						ClassId =:= 0 ->
							SimpleCheck = (MyLevel+Levelextend >= Minlevel) and (MyLevel =< Maxlevel)
					end,
					if 
						SimpleCheck->					
							case has_been_finished(QuestId) of
								true->
									false;			%%宸茬粡鍋氳繃
								_->
									true
							end;	
						true->
							false
					end;
				true->							%%宸茬粡鎺ヤ簡
					false
			end
	end,
	PreQuestCheck = 
	case quest_db:get_prevquestid(QuestInfo) of
		[]->
			true;
		PreQuests->	
			lists:foldl(fun(QuestIdTmp,ReTmp)->
				if
					ReTmp->
						true;
					true->	
						has_been_finished(QuestIdTmp)
				end
			 end,false,PreQuests)
	end,
	if
		PreQuestCheck and BaseCheck ->
			if
				CheckScript =/= []->
					exec_beam(CheckScript,acc_script,QuestId);
				true->
					true
			end;
		true->
			false
	end.
	
exec_beam({Mod,Args},Fun,QuestId)->
	try 
		apply(Mod,Fun,[QuestId|Args])
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p QuestId: ~p ~p:~p ~p ~n",[Mod,Fun,QuestId,Errno,Reason,erlang:get_stacktrace()]),
			false
	end;

exec_beam(Mod,Fun,QuestId)->
	try 
		Mod:Fun(QuestId)
	catch
		Errno:Reason -> 	
			slogger:msg("exec_beam error Script : ~p fun:~p QuestId: ~p ~p:~p  ~p ~n",[Mod,Fun,QuestId,Errno,Reason,erlang:get_stacktrace()]),
			false
	end.		

send_quest_list()->
	Questlist = lists:map(fun({Questid,State,DetailStatus,StartTime,LimitTime,_AddationStatus})->
	if
		LimitTime > 0->
			Lefttime = erlang:max(0,LimitTime*1000 - timer:now_diff(timer_center:get_correct_now(),StartTime));				
		true ->
			Lefttime = 0
	end,
	quest_packet:encode_role_quest(Questid,State,make_status_valuelist(DetailStatus),erlang:trunc(Lefttime/1000))
	end,get(quest_list)),	
	Message = quest_packet:encode_quest_list_update_s2c(Questlist),
	role_op:send_data_to_gate(Message).

export_for_copy()->
	{get(quest_list),get(finished_quests),get(relation_msgs),get(start_quest)}.

load_by_copy({Quest_info,Finished,Relation_msg,StartQuest})->
	put(quest_list,Quest_info),
	put(finished_quests,Finished),
	put(relation_msgs,Relation_msg),	
	put(start_quest,StartQuest),
	init_timer().

write_to_db()->
	Questinfo = {get(quest_list),get(relation_msgs),get(finished_quests),everquest_op:export_to_db()},
	quest_role_db:update_quest_role_now(get(roleid),Questinfo).	

async_write_to_db()->
	Questinfo = {get(quest_list),get(relation_msgs),get(finished_quests),everquest_op:export_to_db()},
	quest_role_db:async_update_quest_role(get(roleid),Questinfo).	
	
get_finished()->
	get(finished_quests).	
		
