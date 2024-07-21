%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(chat_op).

-compile(export_all).


-export([init/2,proc_chat_msg/1,export_for_copy/0,load_by_copy/1]).
-define(CHAT_LOUDSPEAKER_MSG_LENGTH,120).
-define(CHAT_OTHER_MSG_LENGTH,300).
-include("login_pb.hrl").
-include("data_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("country_define.hrl").
-include("festival_def.hrl").

%%-ifdef(debug).
-define(ZYDEBUG(DebugInfo),zydebug(DebugInfo)).
%%-else.
%%-define(ZYDEBUG(DebugInfo),void).
%%-endif.

init(ChatNode,ChatProc)->
	Role_id =get(roleid),
	case gm_block_db:get_block_info(Role_id,talk) of
		[]->
			StartTime = {0,0,0},
			BlockTime = -1;
		BlockInfo->
			StartTime = gm_block_db:get_start_time(BlockInfo),
			DurationTime = gm_block_db:get_duration_time(BlockInfo),
			LeftTime = erlang:trunc(DurationTime - (timer:now_diff(now(),StartTime) )/(1000*1000)),
			if
				DurationTime =:= 0->
					BlockTime = 0;
				LeftTime <0->
					BlockTime = -1,
					gm_block_db:delete_user(Role_id,talk);
				true->
					BlockTime = LeftTime
			end
	end,
	put(chat_node_name,ChatNode),		
	put(chat_info,set_chat_info(ChatNode,ChatProc,{0,0,0},{StartTime,BlockTime})).

export_for_copy()->
	{get(chat_info),get(chat_node_name)}.

load_by_copy({ChatInfo,ChatName})->
	put(chat_info,ChatInfo),
	put(chat_node_name,ChatName).
	
set_block(Duration)->
	StartTime = timer_center:get_correct_now(),
	put(chat_info,set_talk_block(get(chat_info),{StartTime,Duration})).	

get_chat_channel(Type)->
	case Type of
		?CHAT_TYPE_WORLD-> world;
		?CHAT_TYPE_INTHEVIEW->intheview;
		?CHAT_TYPE_PRIVATECHAT->private;
		?CHAT_TYPE_GROUP->group;
		?CHAT_TYPE_GUILD->guild;
		?CHAT_TYPE_LOUDSPEAKER->loudspeaker;
		?CHAT_TYPE_BATTLE->battle;
		?CHAT_TYPE_LARGE_EXPRESSION->large_expression;
		_-> undefined
	end.

proc_chat_msg({Type, RoleName, Msg,Details,ServerId,RepType})->	
	case message_length(Type,Msg) of
		true->
			case get_chat_channel(Type) of
				undefined-> nothing;
				Channel->
					MyName = get_name_from_roleinfo(get(creature_info)),
					MyId = get(roleid),
					gm_logger_role:role_chat(MyId,MyName,RoleName,Channel,Msg)
			end,
			case parse_cmd(Msg) of
				chat ->
					case is_chat_cooltime_ok(Type,get(chat_info)) of
						true-> 
							check_and_send(Type, RoleName,ServerId, Msg,Details,RepType);				
						CdTime->
							Message = chat_packet:encode_chat_failed_s2c(?ERRNO_CHAT_COOLDOWN,CdTime),
							role_op:send_data_to_gate(Message)
					end;
				_->
					nothing
			end;
     	_->
     		slogger:msg("chat message out of the length~n")
     end.
     
     
check_and_send(Type, RoleName,ServerId, Msg,Details,RepType)->	
	ConditionInfo = chat_condition_db:get_chat_conditioninfo(Type), 
	case check_chat_restict(ConditionInfo) of
		true->
			%%发送消息				
			case dispatch_chat_msg(Type, RoleName,ServerId, Msg,Details,RepType) of
				true->
					do_send_success(ConditionInfo);
				{error,norole}->				 				
					Message = chat_packet:encode_chat_failed_s2c(?ERRNO_NOT_ONLINE),				 				
					role_op:send_data_to_gate(Message);
				{error,nogroup}->
					Message = chat_packet:encode_chat_failed_s2c(?ERRNO_HAS_NOGROUP),
					role_op:send_data_to_gate(Message);
				{error,maxloudspeaker}->
					Message = chat_packet:encode_chat_failed_s2c(?ERRNO_MAX_LOUDSPEAK),
					role_op:send_data_to_gate(Message);
				{error,nobattle}->
					Message = chat_packet:encode_chat_failed_s2c(?ERRNO_HAS_NOBATTLE),
					role_op:send_data_to_gate(Message);
				Return->
					slogger:msg("chat judge dispatch return ~p ~n",[Return])					
		 	end;
		{error,level} ->							
			Message = chat_packet:encode_chat_failed_s2c(?ERROR_LESS_LEVEL),
			role_op:send_data_to_gate(Message);
		{error,items} ->			
			Message = chat_packet:encode_chat_failed_s2c(?ERROR_MISS_ITEM),
			role_op:send_data_to_gate(Message);
		{error,block,BBlock}->
			Message = role_packet:encode_block_s2c(?GM_BLOCK_TYPE_TALK,BBlock),
			role_op:send_data_to_gate(Message);
		_->
			nothing
	end.							


%%条件 true/{error,level}/{error,items}/{error,block,BBlockTime}
check_chat_restict(ConditionInfo)->
	case ConditionInfo of
		[]->
			LevelCheck = true,
			ItemCkeck = true;
		_->	
			%%等级检测	
			ResctrictLevel = chat_condition_db:get_level(ConditionInfo),
			LevelCheck = get_level_from_roleinfo(get(creature_info)) >= ResctrictLevel,
			%%物品检测 
			ResctrictItems = chat_condition_db:get_items(ConditionInfo),
			HasItems = lists:filter(
				fun({{Temp_id,Count},{Bind_Temp_id,Bind_Count}})->				
				   item_util:is_has_enough_item_in_package(Temp_id,Count) or
				   item_util:is_has_enough_item_in_package(Bind_Temp_id,Bind_Count)				    
		    end,ResctrictItems),
			ItemCkeck = erlang:length(ResctrictItems)=:=erlang:length(HasItems)
	end,
	%%禁言检测
	{StartTime,BBlock} = get_talk_block(get(chat_info)),
	if 
		not LevelCheck->
			{error,level};
		not ItemCkeck ->
			{error,items};
		BBlock =/= -1->
			LeftTime = erlang:trunc(BBlock - (timer:now_diff(now (),StartTime))/(1000*1000)),
			if
				LeftTime =< 0 ->
					true;
				true->
					{error,block,LeftTime}
			end;
		true ->
			true
	end.

do_send_success([])->
	nothing;
do_send_success(ConditionInfo)->
	case chat_condition_db:get_items(ConditionInfo) of
		[]->
			nothing;
		ConsumeItems->
			lists:foreach(
			fun({{Temp_id,Count},{Bind_Temp_id,Bind_Count}})->
					BindCheck = item_util:is_has_enough_item_in_package(Bind_Temp_id,Bind_Count),
					if
						BindCheck->
							 role_op:consume_items(Bind_Temp_id,Bind_Count);
						true->	    
				    		 role_op:consume_items(Temp_id,Count) 
					end
			end,ConsumeItems)
	end.	

%%处理消息发送
dispatch_chat_msg(Type, RoleName,ServerId, Msg,Details,RepType)->
	case Type of
		?CHAT_TYPE_WORLD->
			send_world(Type, RoleName,Msg,Details);
		?CHAT_TYPE_INTHEVIEW->
			send_intheview(Type, RoleName, Msg,Details);
		?CHAT_TYPE_PRIVATECHAT->
			send_privatechat(Type, RoleName,ServerId,Msg,Details,RepType);
		?CHAT_TYPE_GROUP->
			send_group(Type,RoleName, Msg,Details);
		?CHAT_TYPE_GUILD->
			send_guild(Type,RoleName, Msg,Details);
		?CHAT_TYPE_LOUDSPEAKER->
			RoleId = get(roleid),
			send_by_loudspeaker(RoleId,RoleName,Msg,Details);
		?CHAT_TYPE_BATTLE->
			send_battle(Type, RoleName,Msg,Details);
		?CHAT_TYPE_LARGE_EXPRESSION->
			send_expression(Type, RoleName, Msg,Details);
		_->
			slogger:msg("error the role send error type msg Type~p!!",[Type])
	end.

%%喇叭喊话
send_by_loudspeaker(RoleId,RoleName,Msg,Details)->
	MyServerId = get_serverid_from_roleinfo(get(creature_info)),
	server_travels_util:cast_for_all_server(loudspeaker_manager,send_loudspeaker,[RoleId,{RoleName,Msg,Details,get_role_iden(),MyServerId}]),
	true.

%% 向世界发送信息
send_world(Type, RoleName, Msg,Details)->	
	send_by_chat_proc(Type,RoleName,Msg,Details,[],0),
	true.

%%附近频道
send_intheview(Type, RoleName,Msg,Details)->
	%% 获得aoilist信息
	AllIdList = lists:map(fun({Id, _Pid}) ->
						Id
				      end, get(aoi_list)),
	%% 过滤npc
	RoleIdList = lists:filter(fun(Id)->
						case creature_op:what_creature(Id) of
							role->
								true;
							_->
								false
						end		
					end,
					AllIdList),			
	case role_server_travel:is_in_travel() of
		true->
			ServerId = get_serverid_from_roleinfo(get(creature_info)),
			%%跨服当前进程直接发送,不再发送到chat进程.
			FilterMsg = chat_manager:get_filter_msg(Msg),
			Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,get(roleid),RoleName,FilterMsg,Details,get_role_iden(),ServerId,0),
			role_pos_util:send_to_clinet_list(Message, [get(roleid)|RoleIdList]);
		_->			
			send_by_chat_proc(Type,RoleName,Msg,Details,[get(roleid)]++RoleIdList,0)
	end,
	true.

%%私聊
send_privatechat(Type, RoleName,ServerId,Msg,Details,RepType)->
	%% 判断用户是否在线,不在线,返回错误
	MyserverId = get_serverid_from_roleinfo(get(creature_info)),
	case (ServerId=:=0) or (MyserverId=:=ServerId) of
		true->
			case role_pos_util:get_online_roleid_by_name(RoleName) of
				[]->
					{error,norole};
				Id->
					send_by_chat_proc(Type,RoleName,Msg,Details,[Id],RepType),
					true
			end;
		_->		%%跨服聊天
			case role_pos_util:where_is_role_by_serverid(ServerId,RoleName) of
				[]->		%%未在线
					{error,norole};
				RolePos->
					Messageback = chat_packet:encode_chat_s2c(Type,?SRC_CHAT,role_pos_db:get_role_id(RolePos),RoleName,Msg,Details,get_role_iden(),ServerId,RepType),
					role_op:send_data_to_gate(Messageback),
					Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,get(roleid),make_role_name(),Msg,Details,get_role_iden(),MyserverId,RepType),
					role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoleName,Message)
			end
	end.
						

%%队伍
send_group(Type, RoleName,Msg,Details)->
%% 获得group信息
	Member=group_op:get_member_id_list(),
	case Member of
		[]->
			{error,nogroup};
		_->	
			send_by_chat_proc(Type,RoleName,Msg,Details,Member,0),			
			true
	end.		
	
%%公会	
send_guild(Type, RoleName,Msg,Details)->
%% 获得guild信息
	MemberidList=guild_util:get_guild_members(),
	case MemberidList of
		[]->
			{error,noguild};
		_->
			send_by_chat_proc(Type,RoleName,Msg,Details,MemberidList,0),			
			true
	end.
	

%%战场
send_battle(Type, RoleName,Msg,Details)->
	case battle_ground_op:is_can_chat() of
		true->
			battle_ground_op:battle_chat({Type, make_role_name(),Msg,Details,get_role_iden()}),
			true;
		_->
			{error,nobattle}
	end.
%%大表情
send_expression(Type, RoleName,Msg,Details)->
	%% 获得aoilist信息
	AllIdList = lists:map(fun({Id, _Pid}) ->
						Id
				      end, get(aoi_list)),
	%% 过滤npc
	RoleIdList = lists:filter(fun(Id)->
						case creature_op:what_creature(Id) of
							role->
								true;
							_->
								false
						end		
					end,
					AllIdList),			
	case role_server_travel:is_in_travel() of
		true->
			ServerId = get_serverid_from_roleinfo(get(creature_info)),
			%%跨服当前进程直接发送,不再发送到chat进程.
			FilterMsg = chat_manager:get_filter_msg(Msg),
			Message = chat_packet:encode_chat_s2c(Type,?DEST_CHAT,get(roleid),RoleName,FilterMsg,Details,get_role_iden(),ServerId,0),
			role_pos_util:send_to_clinet_list(Message, [get(roleid)|RoleIdList]);
		_->			
			send_by_chat_proc(Type,RoleName,Msg,Details,[get(roleid)]++RoleIdList,0)
	end,
	true.


send_by_chat_proc(Type,DestName,Msg,Details,SendList,RepType)->
	Chat_Info = get(chat_info),
	ChatNode = get_chatnode_from_chat_info(Chat_Info),	
	ChatProc = get_chatproc_from_chat_info(Chat_Info),
	%%设置时间
	case Type of
		?CHAT_TYPE_WORLD->
			put(chat_info,set_chat_last_time(Chat_Info,now()));
		_->
			nothing
	end,	
	
	chat_process:sendmsg(ChatNode,ChatProc,{Type,get(roleid),make_role_name(),DestName,Msg,Details,SendList,get_role_iden(),RepType}).

send_binary_message(Message)->
	Chat_Info = get(chat_info),
	ChatNode = get_chatnode_from_chat_info(Chat_Info),	
	ChatProc = get_chatproc_from_chat_info(Chat_Info),
	chat_process:send_binary_msg(ChatNode,ChatProc,Message).

%%
%%return  true | cdtime(unit:sec)
%%
is_chat_cooltime_ok(Type,ChatInfo) ->
	if
		Type =:= ?CHAT_TYPE_WORLD->
			RestrictTime = 10*1000*1000;
		true->	
			RestrictTime = 1000*1000
	end,
	CdTime = timer:now_diff(now(),get_last_time_from_chat_info(ChatInfo)),
	if 
		CdTime >= RestrictTime->
			true;
		true->
			util:even_div(RestrictTime-CdTime, 1000*1000)
	end.
	
make_role_name()->
	RoleName = get_name_from_roleinfo(get(creature_info)),	
	case is_list(RoleName) of
		true->RoleName;
		false->binary_to_list(RoleName)
	end.
	
make_chat_proc_name(RoleId)->
		list_to_atom("zyc_"++integer_to_list(RoleId)).

%%%%%%%%%%%% 说话人身份 %%%%%%%%%%%%%%
check_chatgm()->
	gm_role_privilege_op:get_role_privilege() =:= ?ROLE_IDEN_GM.

check_chatguide()->
	gm_role_privilege_op:get_role_privilege() =:= ?ROLE_IDEN_GUIDE.

%%
%%return int 
%%
check_countryleader()->
	case country_op:get_mypost() of
		?POST_KING->
			?ROLE_IDLE_KING;
		?POST_GENERAL->
			?ROLE_IDLE_GENERAL;
		?POST_SOLIDER->
			?ROLE_IDLE_SOLIDER;	
		_->
			-1
	end.

get_role_iden()->
	Bcheckgm = check_chatgm(),
	Bcheckguide = check_chatguide(),
	CountryLeader = check_countryleader(),
	if
		CountryLeader > 0 ->
			CountryLeader;
		Bcheckgm->
			?ROLE_IDEN_GM;	
		Bcheckguide->
			?ROLE_IDEN_GUIDE;
		true->
			?ROLE_IDEN_COM
	end.
		
%%判断聊天信息的长度	 
message_length(Type,Msg)->
	MsgLength = erlang:length(Msg),
	case Type of
		?CHAT_TYPE_LOUDSPEAKER->
			if MsgLength<?CHAT_LOUDSPEAKER_MSG_LENGTH->
					true;
				true->
					false
			end;
		_->
			if MsgLength<?CHAT_OTHER_MSG_LENGTH->
					true;
			   true->
					false
			end
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%						GM指令									%%%%%%%%%%%%%%%%%%%%%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% gm command 		
gm_move(WantTo)->
	case string:tokens(WantTo," ") of
		[PosxStr,PosyStr]->
			MapId  = get_mapid_from_mapinfo(get(map_info)),
			PosX = erlang:list_to_integer(PosxStr),
			PosY = erlang:list_to_integer(PosyStr),
			role_op:transport(get(creature_info),get(map_info),get_lineid_from_mapinfo(get(map_info)),MapId,{PosX,PosY});
		[MapStr,PosxStr,PosyStr]->		
			MapId = erlang:list_to_integer(MapStr),
			PosX = erlang:list_to_integer(PosxStr),
			PosY = erlang:list_to_integer(PosyStr),
			role_op:transport(get(creature_info),get(map_info),get_lineid_from_mapinfo(get(map_info)),MapId,{PosX,PosY});
		[OtherName,MapStr,PosxStr,PosyStr]->
			case role_db:get_roleid_by_name_rpc(OtherName) of
				[]->
					nothing;
				[OtherId]->
	 				MapId = erlang:list_to_integer(MapStr),
	 				PosX = erlang:list_to_integer(PosxStr),
	 				PosY = erlang:list_to_integer(PosyStr),
	 				gm_order_op:move_user(OtherId ,MapId,PosX,PosY )
	 		end
	 end.
	

-ifdef(debug).
check_gmaccount()->
	true.
-else.
check_gmaccount()->
	Account = get(account_id),
	OptionResult = 
		case env:get(gmaccount,[]) of
			[]-> false;
			AccountList->
				lists:member(Account,AccountList)
		end,
	if
		OptionResult->
			true;
		true->true%%便于压力测试，暂时让所有号都可以使用GM命令
%% 			gm_role_privilege_op:get_role_privilege() =:= ?GM_ACCOUNT_FLAG
	end.
-endif.
	
     
parse_cmd(Msg)->
	try
		case Msg of
			".zy" ++ _Other->
				case Msg of	
					 ".zymove " ++ WantTo->
					 		case check_gmaccount() of
					 			true->
					 				gm_move(WantTo);
					 			_->
					 				throw(notgmaccount)
					 		end;		
					 ".zyspeek " ++ Words->
					 		case check_gmaccount() of
					 			true->
					 				chat_manager:gm_speek(Words);
					 			_->
					 				throw(notgmaccount)
					 		end;		
					 ".zylevelup " ++ LevelStr->
					 		case check_gmaccount() of
					 			true->
							 		Level = erlang:list_to_integer(LevelStr),
									LevelR = if Level >= 100 ->
													100;
												true ->
													Level
											end,
							 		role_op:level_up(LevelR,0);
					 			_->
					 				throw(notgmaccount)
					 		end;
					 ".zypetexp " ++ ExpStr->
					 		case check_gmaccount() of
					 			true->
							 		AddExp = erlang:list_to_integer(ExpStr),
							 		pet_level_op:obt_exp(pet_op:get_out_pet(),AddExp);
					 			_->
					 				throw(notgmaccount)
					 		end;				
					 ".zybrd " ++ Words->
					 		case check_gmaccount() of
					 			true->
							 		chat_manager:gm_broad_cast(Words);	
					 			_->
					 				throw(notgmaccount)
					 		end;		
					 ".zyitem "++ItemStr->
					 		case check_gmaccount() of
					 			true->
					 				case string:tokens(ItemStr," ") of
					 					[ItemIdStr]->
					 						ItemId = erlang:list_to_integer(ItemIdStr),
					 						role_op:auto_create_and_put(ItemId,1,got_gm_order);
					 					[ItemIdStr,CountStr]->
					 						ItemId = erlang:list_to_integer(ItemIdStr),
					 						Count = erlang:list_to_integer(CountStr),
					 						role_op:auto_create_and_put(ItemId,Count,got_gm_order)
					 				end;
					 			_->
					 				throw(notgmaccount)
					 		end;
					 ".zyitemset "++ItemStr->
					 		case check_gmaccount() of
					 			true->
					 				case string:tokens(ItemStr," ") of
					 					[ItemSetIdStr]->
					 						ItemSetId = erlang:list_to_integer(ItemSetIdStr),
					 						if
					 							ItemSetId=/=0->
					 								ItemIDs = equipmentset_db:get_equipmentset_includes(ItemSetId),
							 						lists:foreach(fun(ItemId)->role_op:auto_create_and_put(ItemId,1,got_gm_order) end,ItemIDs);
							 					true->
							 						nothing
							 				end; 
					 					_->
					 						nothing
					 				end;
					 			_->
					 				throw(notgmaccount)
					 		end;
					 ".zyitemskill " ++ Nstr->
					 		case check_gmaccount() of
					 			true->
					 				N = erlang:list_to_integer(Nstr),
	 								ItemIDs = item_template_db:get_itemid_with_skill(N),
			 						lists:foreach(fun(ItemId)->role_op:auto_create_and_put(ItemId,1,got_gm_order) end,ItemIDs);
					 			_->
					 				throw(notgmaccount)
					 		end;							
					 ".zymoney "++MoneyStr->
					 		case check_gmaccount() of
					 			true->
							 		Money = erlang:list_to_integer(MoneyStr),
									MoneyR = if
												Money >= 2147483648 ->
													2147483648;
												true->
													Money
											end,
							 		role_op:money_change(?MONEY_BOUND_SILVER,MoneyR,got_quest);
					 			_->
					 				throw(notgmaccount)
					 		end;
					 ".zygold "++GoldStr->
					 		case check_gmaccount() of
					 			true->
							 		Gold = erlang:list_to_integer(GoldStr),
									GoldR = if
												Gold >= 2147483648 ->
													2147483648;
												true ->
													Gold
											end,
							 		role_op:money_change(?MONEY_GOLD,GoldR,got_quest);
					 			_->
					 				throw(notgmaccount)
					 		end;	
						".zyticket "++SticketStr->
									case check_gmaccount() of
											true->
												Ticket=erlang:list_to_integer(SticketStr),
												TicketR = if
												Ticket >= 2147483648 ->
													2147483648;
												true ->
													Ticket
											end,
												role_op:money_change(?MONEY_TICKET,TicketR,got_quest);
									_->
										throw(notgmaccount)
									end;
					 ".zybt " ++ Block->
							 case check_gmaccount() of
							 	true->
									case string:tokens(Block," ") of
										[Name,TimeStr]->					 	
							 				Time = erlang:list_to_integer(TimeStr),
									 		case role_db:get_roleid_by_name_rpc(Name) of
												[]->
													nothing;
												[OtherId]->
													gm_order_op:block_user_talk(OtherId,Time)		
											end;
							 			_->
							 				nothing	
							 		end;
								_->
									throw(notgmaccount)	
							end;
					".zybu " ++ Block->
							case check_gmaccount() of
							 	true->
									case string:tokens(Block," ") of
										[Name,TimeStr]->					 	
							 				Time = erlang:list_to_integer(TimeStr),
									 		case role_db:get_roleid_by_name_rpc(Name) of
												[]->
													nothing;
												[OtherId]->
													gm_order_op:block_user(OtherId,Time)		
											end;
							 			_->
							 				nothing	
							 		end;
								_->
									throw(notgmaccount)	
							end;
					".zystartdps"->
							case check_gmaccount() of
								true->
									gm_order_op:start_dps_stat();
								_->
									throw(notgmaccount)	
							end;
					".zystopdps"->
							case check_gmaccount() of
								true->
									gm_order_op:stop_dps_stat();
								_->
									throw(notgmaccount)	
							end;
					".zydebug "++ DebugInfo->
						case check_gmaccount() of
					 		true->
					 			io:format("DebugInfo:~p~n",[DebugInfo]),
					 			?ZYDEBUG(DebugInfo);
					 		_->
					 			throw(notgmaccount)
					 	end;		 
					".zyoffline "++ Offline->
						case check_gmaccount() of
					 		true->
					 			offline_exp_op:offline(Offline);
					 		_->
					 			throw(notgmaccount)
					 	end;
					 ".zyquest"->
					 	case check_gmaccount() of
					 		true->
					 			lists:foreach(fun(QuestId)-> quest_op:set_quest_finished(QuestId) end,quest_op:get_all_questid());
						 	_->
					 			throw(notgmaccount)
					 	end;			
					 ".zyquest " ++ QuestIdStr->
					 	case check_gmaccount() of
					 		true->
						 		QuestId = erlang:list_to_integer(QuestIdStr),
						 		case quest_op:has_quest(QuestId) of
						 			true->
						 				quest_op:set_quest_finished(QuestId);
						 			_->	
						 				quest_op:insert_to_finished(QuestId)
						 		end;
						 	_->
					 			throw(notgmaccount)
					 	end;					 	
					 ".zypower " ++ PowerStr->
						case check_gmaccount() of
				 			true->
					 			Power = erlang:list_to_integer(PowerStr),
					 			creature_op:set_power_to_creature_info(get(creature_info),Power);
					 		_->
				 				throw(notgmaccount)
						 end;
					 ".zydays " ++ Days->
					 	case check_gmaccount() of
				 			true->
					 			Day = erlang:list_to_integer(Days),
					 			continuous_logging_op:gm_test(Day);
					 		_->
				 				throw(notgmaccount)
				 		end;
					".zyaddhyd " ++ ValueStr->
					 	case check_gmaccount() of
				 			true->
					 			Value = erlang:list_to_integer(ValueStr),
					 			activity_value_op:gm_add_av_value(Value);
					 		_->
				 				throw(notgmaccount)
				 		end;
					".zyfb_quest " ++ FBQuestInfo->
					 	case check_gmaccount() of
				 			true->
								case string:tokens(FBQuestInfo," ") of 
									[FBID,MsgId]->
										facebook:gm_command(FBID,list_to_integer(MsgId));
									_->
										nothing
								end;
					 		_->
				 				throw(notgmaccount)
				 		end;
					".zyvena " ++ VenStr->
					 		case check_gmaccount() of
					 			true->
					 				case string:tokens(VenStr," ") of
					 					[VenStr]->
					 						VenId = erlang:list_to_integer(VenStr),
											venation_op:gm_venation_advanced(VenId,0);
					 					[Ven_Str,BoneStr]->
					 						VenId = erlang:list_to_integer(Ven_Str),
					 						Bone = erlang:list_to_integer(BoneStr),
											venation_op:gm_venation_advanced(VenId,Bone)
					 				end;
					 			_->
					 				throw(notgmaccount)
					 		end;
					".zyven " ++ VenStr->
					 		case check_gmaccount() of
					 			true->
					 				case string:tokens(VenStr," ") of
					 					[VenStr]->
					 						VenId = erlang:list_to_integer(VenStr),
											venation_op:gm_venation(VenId,0);
					 					[Ven_Str,CountStr]->
					 						VenId = erlang:list_to_integer(Ven_Str),
					 						Count = erlang:list_to_integer(CountStr),
											venation_op:gm_venation(VenId,Count)
					 				end;
					 			_->
					 				throw(notgmaccount)
					 		end;
					".zypethappiness " ++ ValueStr->
					 	case check_gmaccount() of
				 			true->
								AddValue = erlang:list_to_integer(ValueStr),
								pet_op:gm_change_happiness(AddValue);
					 		_->
				 				throw(notgmaccount)
				 		end;
					".zycrime " ++ Value->
						case check_gmaccount() of
							true->
								AddValue = erlang:list_to_integer(Value),
								pvp_op:change_crime_by_gm(AddValue);
							_->
								throw(notgmaccount)
						end;					
					".zyupdatestage " ++ ValueString->
						case check_gmaccount() of
							true->
								case string:tokens(ValueString," ") of
					 				[ChapterStr,StageStr]->
										Chapter = erlang:list_to_integer(ChapterStr),
										Stage = erlang:list_to_integer(StageStr),
					 					role_mainline:gm_activity_stage(Chapter,Stage);
					 				_->
					 					nothing
					 			end;
							_->
								throw(notgmaccount)
						end;					
					".zyclearstage " ++ ValueString->
						case check_gmaccount() of
							true->
								case string:tokens(ValueString," ") of
					 				[ChapterStr,StageStr]->
										Chapter = erlang:list_to_integer(ChapterStr),
										Stage = erlang:list_to_integer(StageStr),
					 					role_mainline:gm_clear_stage(Chapter,Stage);	
					 				_->
					 					nothing
					 			end;
							_->
								throw(notgmaccount)
						end;
					".zydesignation "++TmpDesignation->
						case check_gmaccount() of
							true->
								Designation = erlang:list_to_integer(TmpDesignation),
								designation_op:change_designation(Designation);
							_->
								throw(notgmaccount)
						end;
					".zyspeedexplore "++Time->
						case check_gmaccount() of
							true->
								TmpTime = erlang:list_to_integer(Time),
								pet_explore_op:gm_speedup_explore(TmpTime);
							_->
								throw(notgmaccount)
						end;
					".zyexplorerate "++Rate->
						case check_gmaccount() of
							true->
								TmpRate = erlang:list_to_integer(Rate),
								pet_explore_op:gm_change_explore_rate(TmpRate);
							_->
								throw(notgmaccount)
						end;
					".zycleargoals"->
						case check_gmaccount() of
							true->
								goals_op:gm_clear_all_goals();
							_->
								throw(notgmaccount)
						end;
					".zymallsale " ++TState->
						case check_gmaccount() of
							true->
								State = erlang:list_to_atom(TState),
								if
									State->
										gm_notice_checker:mall_sale_test();
									true->
										gm_notice_checker:cancel_mall_sale_test()
								end;
							_->
								throw(notgmaccount)
						end;
					".zyrecharge "++TGold->
						case check_gmaccount() of
							true->
								Gold = erlang:list_to_integer(TGold),
								RoleId = get(roleid),
								festival_recharge:change_recharge_num(Gold,RoleId);
							_->
								throw(notgmaccount)
						end;
					".zycharge "++TGold->
						case check_gmaccount() of
							true->
								Gold = erlang:list_to_integer(TGold),
								RoleId = get(roleid),
								mall_op:change_role_integral(Gold,RoleId);
							_->
								throw(notgmaccount)
						end;
					".zyaddofflinetime "++ValueString->
						case check_gmaccount() of
							true->
								case string:tokens(ValueString," ") of
					 				[Name,TimeStr]->
										Time = erlang:list_to_integer(TimeStr),
									 	case role_db:get_roleid_by_name_rpc(Name) of
											[]->
												nothing;
											[OtherId]->
												case role_pos_util:where_is_role(OtherId) of
													[]->
														case role_db:get_role_info(OtherId)	of
															[]->
																nothing;
															RoleDbInfo->
																OldOffline = role_db:get_offline(RoleDbInfo),
																NewOffline = util:ms_to_now(max(util:now_to_ms(OldOffline) - Time*60*60*1000,0)),
																NewRoleDbInfo =  role_db:put_offline(RoleDbInfo,NewOffline),
																dal:write_rpc(NewRoleDbInfo),
																guild_handle:gm_change_someone_offline(NewOffline,OtherId)
														end;	
													_->
														nothing
												end												
										end;
					 				_->
					 					nothing
					 			end;
							_->
								throw(notgmaccount)
						end;
					".zyaddthtime "++TimeStr->
						case check_gmaccount() of
							true->
								Time = erlang:list_to_integer(TimeStr),
								guild_handle:gm_change_impeach_time(Time*60*60);
							_->
								throw(notgmaccount)
						end;
					".zyfollowme "++TimeStr->
						case check_gmaccount() of
							true->
								NpcId = erlang:list_to_integer(TimeStr),
								case creature_op:get_creature_info(NpcId) of
									undefined->
										nothing;
									NpcInfo->
										TargetPID = creature_op:get_pid_from_creature_info(NpcInfo),
										TargetPID ! {follow_me,get(roleid)}
								end;	
							_->
								throw(notgmaccount)
						end;
					".zyletsay "++NpcWords->
						case check_gmaccount() of
							true->
								case string:tokens(NpcWords," ") of
									[NpcIdStr,WordStr]->
										NpcId = erlang:list_to_integer(NpcIdStr),
										normal_ai:let_other_say(NpcId,WordStr);
									_->
										nothing
								end;
							_->
								throw(notgmaccount)
						end;
					".zyfestivaltime "++Time->
						case check_gmaccount() of
							true->
								try
									case string:tokens(Time, "/") of 
										[TID,SYear,SMonth,SDay,EYear,EMonth,EDay,AWardYear,AWardMonth,AwardDay]->
											Id = list_to_integer(TID),
											SDate = {list_to_integer(SYear),list_to_integer(SMonth),list_to_integer(SDay)},
											EDate = {list_to_integer(EYear),list_to_integer(EMonth),list_to_integer(EDay)},
											ADate = {list_to_integer(AWardYear),list_to_integer(AWardMonth),list_to_integer(AwardDay)},
											SDateTime = {SDate,{0,0,0}},
											EDateTime = {EDate,{0,0,0}},
											ADateTime = {ADate,{0,0,0}},
											Object =#festival_control_background{id = Id,show = 2,starttime = SDateTime,endtime = EDateTime,award_limit_time = ADateTime},
											case dal:write_rpc(Object) of
												{ok}->
													Object2 =#festival_control{id = Id,show = 2,starttime = SDateTime,endtime = EDateTime,award_limit_time = ADateTime},
													festival_db:gm_add_festival_control_to_ets_rpc(Object2);
												_->
													nothing
											end;
										_->
											slogger:msg(".zyfestivaltime error,Time:~p~n ",[Time])
									end
								catch 
									_E:_R->
										nothing
								end;
							_->
								throw(notgmaccount)
						end;
					".zylianzhangeili "++ValueStr->
						case check_gmaccount() of
							true->
								Value = erlang:list_to_integer(ValueStr),
								spiritspower_op:add_value(abs(Value));
							_->
								throw(notgmaccount)
						end;
					".zykillall"++_->		%%kill all monster in this map
						case check_gmaccount() of
							true->
								mapop:kill_all_monster();
							_->
								throw(notgmaccount)
						end;
					".zygiveselfbuff "++ValueStr->
						case check_gmaccount() of
							true->
								case string:tokens(ValueStr," ") of
					 				[BuffIdStr,BuffLevelStr]->
					 					BuffId = list_to_integer(BuffIdStr),
					 					BuffLevel = list_to_integer(BuffLevelStr),
					 					role_op:add_buffers_by_self([{BuffId,BuffLevel}]);
					 				_->
					 					nothing
								end;
							_->
								throw(notgmaccount)
						end;
					".zyclearcd"->
						case check_gmaccount() of
							true->
								guild_op:clear_cd_by_gm();
							_->
								throw(notgmaccount)
						end;
					".zyhonor " ++ ValueStr->
						case check_gmaccount() of
							true->
								AddValue = erlang:list_to_integer(ValueStr),
								role_op:obtain_honor(AddValue);
							_->
								throw(notgmaccount)
						end;
					".zyaddguildscore " ++ ValueStr->
						case check_gmaccount() of
							true->
								AddValue = erlang:list_to_integer(ValueStr),
								guild_manager:gm_add_guild_score(guild_util:get_guild_id(),AddValue);
							_->
								throw(notgmaccount)
						end;
					".zyshengxing "++ValueStr->
						case check_gmaccount() of
							true->
								case string:tokens(ValueStr," ") of
					 				[SlotStr,LevelStr]->
					 					Slot = list_to_integer(SlotStr),
					 					Level = list_to_integer(LevelStr),
					 					equipment_op:gm_equipment_riseup(Slot,Level);
					 				_->
					 					nothing
								end;
							_->
								throw(notgmaccount)
						end;
					 ".zylpgoto "++ValueStr->
						case check_gmaccount() of
							true->			
					 			Layer = list_to_integer(ValueStr),
					 			loop_instance_op:gm_goto_next_layer(Layer,0);
							_->
								throw(notgmaccount)
						end;
                     ".zyclearpackage"->%%@@wb20130325清包
                         case check_gmaccount() of
							true->			
					 			package_op:clear_package();
							_->
								throw(notgmaccount)
						end; 
					 _->	
					 	chat
				end;
			_->
				chat
		end	
	catch
		E:R -> slogger:msg("Msg ~p E ~p :R ~p ~p ~n",[Msg,E,R,erlang:get_stacktrace() ]),chat
	end.	 		
	
%%-ifdef(debug).
zydebug(DebugInfo)->
	try
		case util:string_to_term(DebugInfo) of
			{ok,Term}->
				self()! Term;
			_->
				nothing
		end
	catch
		E:R -> slogger:msg("debuginfo ~p E ~p :R ~p ~p ~n",[DebugInfo,E,R,erlang:get_stacktrace() ])
	end.
%%-endif.
