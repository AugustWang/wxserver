%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-4
%% Description: TODO: Add description to gm_op
-module(gm_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("festival_define.hrl").
-include("mnesia_table_def.hrl").
%%
%% API Functions
%%

gm_kick_role(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_kick_role_response",
				gm_kick_role_rpc,["rolename"]).

query_player_request(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"query_player_response",
				query_player_request_rpc,["rolename"]).

disable_player(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"disable_player_response",
				disable_player_rpc,["rolename","lefttime"]).

enable_player(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"enable_player_response",
				enable_player_rpc,["rolename"]).

disable_player_say(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"disable_player_say_response",
				disable_player_say_rpc,["rolename","lefttime"]).

enable_player_say(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"enable_player_say_response",
				enable_player_say_rpc,["rolename"]).

disable_ip_login(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"disable_ip_login_response",
				disable_ip_login_rpc,["ipaddress","lefttime"]).
	
enable_ip_login(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"enable_ip_login_response",
				enable_ip_login_rpc,["ipaddress"]).

gift_send(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gift_send_response",
				gift_send_rpc,["rolename","giftlist"]).

add_gm_notice(JsonObject)->
	process_rpc(JsonObject,get_linenode(),
				"add_gm_notice_response",
				add_gm_notice_rpc,
				["id","ntype","left_count","begin_time","end_time","interval_time","notice_content"]).

delete_gm_notice(JsonObject)->
	process_rpc(JsonObject,get_linenode(),
				"delete_gm_notice_response",
				delete_gm_notice_rpc,["id"]).

hide_gm_notice(JsonObject)->
	process_rpc(JsonObject,get_linenode(),
				"hide_gm_notice_response",
				hide_gm_notice_rpc,["id","left_count"]).

power_gather(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"power_gather_response",
				power_gather_rpc,[]).

query_gate_request(_JsonObject)->
	query_gate_state().

query_line_request(_JsonObject)->
	query_line_state().

publish_gm_notice(JsonObject)->
	process_rpc_remote(JsonObject,get_linenode(),
					   gm_notice_checker,
					   "publish_gm_notice_response",
					   publish_notice_id,["id"]).

user_charge(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"user_charge_response",
				user_charge_rpc,["username","roleid","gold"]).

gm_user_charge(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_user_charge_response",
				gm_user_charge_rpc,["username","roleid","gold"]).

gm_first_charge_gift(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_first_charge_gift_response",
				gm_first_charge_gift_rpc,["username"]).

gm_first_charge_gift_roleid(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_first_charge_gift_roleid_response",
				gm_first_charge_gift_roleid_rpc,["roleid"]).

gm_log_control(JsonObject)->
	process_rpc(JsonObject,node(),
				"gm_log_control_response",
				gm_log_control_rpc,["table","option"]).

gm_activity_finish(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_activity_finish",
				gm_activity_finish_rpc,["roleid","type","serialnumber"]).

gm_change_role_name(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_change_role_name_response",
				gm_change_role_name_rpc,["rolename","newname"]).%%@@wb20130502 "roleid"

gm_facebook_quest(JsonObject)->
%% 	io:format("gm_facebook_quest~n"),
	process_rpc(JsonObject,get_mapnode(),
				"gm_facebook_quest_response",
				gm_facebook_quest_rpc,["roleid","facebook_id","MsgId"]).

gm_import_giftcard(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_import_giftcard",
				gm_import_giftcard_rpc,["giftcard_list"]).



gm_add_whiteip(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_add_whiteip",
				gm_add_whiteip_rpc,["first_num","sec_num","third_num","four_num"]).

gm_get_role_info(JsonObject)->
	[UserName] = prepaire_argument(JsonObject,["username"]),
	[ServerId] = prepaire_argument(JsonObject,["serverid"]),
	SendStruct = case gate_op:get_role_list(UserName,ServerId) of
					 []->
						 {struct,[{<<"cmd">>,<<"gm_get_role_info_response">>},
								  {<<"result">>,<<"error">>}
								 ]};
					 Result->
						 [{_,RoleId, RoleName, _LastMapId,Classtype,Gender,Level}] = Result,
						 {struct,[{<<"cmd">>,<<"gm_get_role_info_response">>},
								  {<<"result">>,<<"ok">>},
								  {<<"roleid">>,RoleId},
								  {<<"rolename">>,list_to_binary(util:escape_uri(RoleName))},
								  {<<"class">>,Classtype},
								  {<<"gender">>,Gender},
								  {<<"level">>,Level}
								 ]}
				 end,
	{ok,SendBin} = util:json_encode(SendStruct),
	gm_client:send_data(self(),SendBin).

gm_move_user(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_move_user_response",
				gm_move_user_rpc,["rolename","mapid","posx","posy"]).
	
online_count()->
	Online=role_pos_db:get_online_count(),
	Role = 0,
	{Online,Role}.

online_count_rpc(_JsonObject)->
	%%online count
	{Online,Role} = rpc:call(get_mapnode(), ?MODULE, online_count, []),
	SendStruct={struct,[{<<"cmd">>,<<"online_count_response">>},
										  {<<"online">>,Online},
										  {<<"reg">>,Role}]},
	{ok,SendBin} = util:json_encode(SendStruct),
	gm_client:send_data(self(), SendBin).

map_data(_JsonObject)->
	MapDatas = lines_manager:get_rolenum_by_mapid(),
	MapString = map_data_to_string(MapDatas),
	SendStruct={struct,[{<<"cmd">>,<<"map_data_response">>},
										  {<<"map">>,list_to_binary(MapString)}]},
	{ok,SendBin} = util:json_encode(SendStruct),
	gm_client:send_data(self(),SendBin).

map_data_to_string(MapDatas)->
	MapString = lists:map(fun({MapId,Count})->
								   integer_to_list(MapId) ++ "," ++ integer_to_list(Count)
						   end, MapDatas),
	string:join(MapString, ";").

gm_send(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_send_response",gm_send_rpc,
				["fromName","toName","title","content","templateId","count","add_Silver"]).

%%toNames=[11111,22222,33333,aaaaa,bbbbb,ccccc]
gm_send_all(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_send_all_response",gm_send_all_rpc,
				["fromName","toNames","title","content","templateId","count","add_Silver"]).

gm_set_role_privilege(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),"gm_set_role_privilege_response",
				gm_set_role_privilege_rpc,["rolename","privilege"]).

gm_delete_role_privilege(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_role_privilege_response",
				gm_delete_role_privilege_rpc,["rolename"]).

gm_update_mall_item(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),
				"gm_update_mall_item_response",
				gm_update_mall_item_rpc,
				["id","ntype","special_type","ishot","sort","price","discount"]).

gm_delete_mall_item(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_mall_item_response",
				gm_delete_mall_item_rpc,["id"]).

gm_update_sales_item(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),
				"gm_update_sales_item_response",
				gm_update_sales_item_rpc,
				["id","ntype","name","sort","price","discount","duration","sales_time","restrict","bodcast"]).

gm_delete_sales_item(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_sales_item_response",
				gm_delete_sales_item_rpc,["id"]).

gm_update_activity(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),
				"gm_update_activity_response",
				gm_update_activity_rpc,["info"]).

gm_delete_activity(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_activity_response",
				gm_delete_activity_rpc,["info"]).

gm_update_guildbattle(JsonObject)->
 	process_rpc(JsonObject,get_dbnode(),
				"gm_update_guildbattle_response",
				gm_update_guildbattle_rpc,["info"]).

gm_delete_guildbattle(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_guildbattle_response",
				gm_delete_guildbattle_rpc,["info"]).

gm_update_global_monster(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_update_global_monster",
				gm_update_global_monster_rpc,["info"]).

gm_delete_global_monster(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_global_monster",
				gm_delete_global_monster_rpc,["id"]).

gm_update_global_exp_addition(JsonObject)->
%% 	io:format("gm_update_global_exp_addition~n"),
	process_rpc(JsonObject,get_dbnode(),
				"gm_update_global_exp_addition",
				gm_update_global_exp_addition_rpc,["info"]).

gm_delete_global_exp_addition(JsonObject)->
%% 	io:format("gm_delete_global_exp_addition~n"),
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_global_exp_addition",
				gm_delete_global_exp_addition_rpc,["id"]).

gm_update_welfare_activity(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_update_welfare_activity",
				gm_update_welfare_activity_rpc,["info"]).

gm_delete_welfare_activity(JsonObject)->
%% 	io:format("gm_delete_welfare_activity~n"),
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_welfare_activity",
				gm_delete_welfare_activity_rpc,["id"]).

gm_update_pet_explore_map_data(JsonObject)->
%% 	io:format("gm_update_pet_explore_map_data~n"),
	process_rpc(JsonObject,get_dbnode(),
				"gm_update_pet_explore_map_data",
				gm_update_pet_explore_map_data_rpc,["info"]).

gm_delete_pet_explore_map_data(JsonObject)->
%% 	io:format("gm_delete_pet_explore_map_data~n"),
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_pet_explore_map_data",
				gm_delete_pet_explore_map_data_rpc,["id"]).

gm_update_festival_info(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_update_festival_info",
				gm_update_festival_info_rpc,["info"]).

gm_delete_festival_info(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_festival_info",
				gm_delete_festival_info_rpc,["id"]).

gm_update_festival_recharge_gift(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_update_festival_recharge_gift",
				gm_update_festival_recharge_gift_rpc,["info"]).

gm_delete_festival_recharge_gift(JsonObject)->
	process_rpc(JsonObject,get_mapnode(),
				"gm_delete_festival_recharge_gift",
				gm_delete_festival_recharge_gift_rpc,["id"]).
gm_update_open_service_activities(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_update_open_service_activities",
				gm_update_open_service_activities_rpc,["info"]).

gm_delete_open_service_activities(JsonObject)->
	process_rpc(JsonObject,get_dbnode(),
				"gm_delete_open_service_activities",
				gm_delete_open_service_activities_rpc,["id"]).

system_option(JsonObject)->
	process_rpc(JsonObject,node(),
				"system_option_response",
				system_option_rpc,["sysIdKey"]).

loop_tower_week_reward(JsonObject)->
	process_rpc_remote(JsonObject,get_mapnode(),
					   loop_tower_op,"loop_tower_week_reward_response",
					   loop_tower_week_reward,["type"]).

get_loop_tower_curlayer(JsonObject)->
	process_rpc(JsonObject,node(),
				"get_loop_tower_curlayer_response",
				get_loop_tower_curlayer_rpc,[]).

all_role_vip(JsonObject)->
	process_rpc(JsonObject,node(),
				"all_role_vip_response",
				all_role_vip_rpc,[]).

code_hot_change(JsonObject)->
	process_rpc(JsonObject,node(),
				"code_hot_change_response",
				code_hot_change_rpc,[]).

get_server_version(JsonObject)->
	process_rpc(JsonObject,node(),
				"get_server_version_response",
				get_server_version_rpc,[]).

query_gate_state()->
	GateNodes = node_util:get_gatenodes(),
	CountFun = fun(GateNode)->
					   Count = case rpc:call(GateNode, gs_prof, pids, []) of
								   {badrpc,Reason}-> slogger:msg("bad call ~p!!~n",[Reason]),0;
								   Plist-> length(Plist)
							   end,
					   {GateNode,Count}
			   end,
	lists:map(CountFun, GateNodes).

query_line_state()->
	Lines = env:get(lines_info, []),
	MapIds = lists:foldl(fun({_LineId,LineInfo},OldList)->
								 lists:foldl(fun({MapId,_Node},OldMapIds)->
													 case lists:member(MapId, OldMapIds) of
														 true-> OldList;
														 false-> [MapId|OldMapIds]
													 end
											 end,OldList,LineInfo)
						end, [], Lines),

	CountFun = fun(MapId)-> {MapId,lines_manager:get_line_status(MapId)} end,
	lists:map(CountFun, MapIds).
%%
%% Local Functions
%%
get_mapnode()->
	MapNodes = node_util:get_mapnodes(),
	[MapNode |_]= MapNodes,
	MapNode.

get_linenode()->
	LineNodes = node_util:get_linenodes(),
	[LineNode|_] = LineNodes,
	LineNode.

get_dbnode()->
	DbNodes = node_util:get_dbnodes(),
	[DbNode|_] = DbNodes,
	DbNode.

prepaire_argument(JsonObject,AgumentNameList)->
	F = fun(X,Acc)->
			case util:get_json_member(JsonObject, X) of
				{ok,Res}-> Acc ++ [Res];
				{error,_Reason}-> Acc
			end
		end,
	lists:foldl(F, [], AgumentNameList).

process_rpc(JsonObject,Node,ResponseCmdString,RemoteCall,ArgumentNameList)->
	ArgumentList = prepaire_argument(JsonObject,ArgumentNameList),
		SendStruct = case rpc:call(Node, ?MODULE , RemoteCall , ArgumentList) of
					 {badrpc,Reason}-> slogger:msg("~p error:~p",[RemoteCall,Reason]),
									   {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
												{<<"result">>,<<"failed">>},
												{<<"addition">>,<<"bad input">>}]};
					 Ret->
						 case Ret of
							 {ok}->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
										  {<<"result">>,<<"ok">>}]};
							 {ok,ResultString}->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
                                          {<<"result">>,<<"ok">>},
										  {<<"addition">>,list_to_binary(ResultString)}]};
							 {error,Reason}->
								 if is_list(Reason)->
										{struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
												 {<<"result">>,<<"error">>},
												 {<<"addition">>,list_to_binary(Reason)}]};
								 	true->{struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
												 {<<"result">>,<<"error">>},
												 {<<"addition">>,Reason}]}
								 end;
							 []->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
										  {<<"result">>,<<"ok">>}]}
								 
						end
				 end,
	{ok,SendBin} = util:json_encode(SendStruct),
	gm_client:send_data(self(),SendBin).

process_rpc_remote(JsonObject,Node,Mod,ResponseCmdString,RemoteCall,ArgumentNameList) ->
	ArgumentList = prepaire_argument(JsonObject,ArgumentNameList),
	SendStruct = case rpc:call(Node, Mod , RemoteCall , ArgumentList) of
					 {badrpc,Reason}-> slogger:msg("~p error:~p",[RemoteCall,Reason]),
									   {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
												{<<"result">>,<<"failed">>},
												{<<"addition">>,<<"bad input">>}]};
					 Ret->
						 case Ret of
							 {ok}->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
										  {<<"result">>,<<"ok">>}]};
							 {ok,ResultString}->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
										  {<<"result">>,<<"ok">>},
										  {<<"addition">>,list_to_binary(ResultString)}]};
							 {error,Reason}->
								 {struct,[{<<"cmd">>,list_to_binary(ResponseCmdString)},
										  {<<"result">>,<<"error">>},
										  {<<"addition">>,list_to_binary(Reason)}]}
						end
				 end,
	{ok,SendBin} = util:json_encode(SendStruct),
	gm_client:send_data(self(),SendBin).


query_player_request_rpc({RoleName})->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]-> {error,"norole"};
		[RoleId]->role_db:get_role_info(RoleId)
	end.

gm_kick_role_rpc(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]-> {error,"norole"};
		[RoleId]->
			case gm_order_op:kick_user(RoleId) of
				nothing->
					{error,"notonline"};
				_->
					{ok}
			end
	end.

disable_player_rpc(RoleName,LeftTime)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->{error,"norole"};
		[RoleId]->case gm_order_op:block_user(RoleId, LeftTime) of
					  {ok}->
						  case dal:read_rpc(gm_blockade) of
							  {ok,Result}->
								  case Result of
									  []->[];
									  _->
								  Fun=fun({_,{RoleId,Type},StartTime,Duration},Acc)->
											  case Type of
												  login->
													  %Now=timer_center:get_correct_now(),
													  Diff=timer:now_diff(timer_center:get_correct_now(),StartTime),
													  if 
														  trunc(Diff/1000000)<Duration ->
															  case role_db:get_rolename_by_id_rpc(RoleId) of
																  [_]->Acc;
																  BinName->
																	  Acc++[util:escape_uri(BinName),",",integer_to_list(Duration-trunc(Diff/1000000)),";"]
															  end;
														  true->Acc
													  end;
												  _->Acc
											  end
									  end,
								  Str=lists:foldl(Fun,[],Result),
								  {ok,Str}
								  end;
							  _->{error,"read error"}
						  end;
					  _-> {error,[]}
				  end
	end.

enable_player_rpc(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->{error,"norole"};
		[RoleId]->
			gm_order_op:block_user(RoleId, 0),%%@@wb20130424解决解除禁止登陆后不能即刻生效的问题
			case gm_block_db:delete_user(RoleId, login) of
					  {ok}-> {ok};
					  _-> {error,[]}
				  end
	end.

enable_player_say_rpc(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->{error,"norole"};
		[RoleId]->
			gm_order_op:block_user_talk(RoleId, 0),%%@@wb20120424 解决不能解禁的问题
			case gm_block_db:delete_user(RoleId, talk) of
					  {ok}->{ok};
					  _-> {error,[]}
				  end
	end.

disable_player_say_rpc(RoleName,LeftTime)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->{error,"norole"};
		[RoleId]->
			case gm_order_op:block_user_talk(RoleId, LeftTime) of
					  {ok}-> 
						  case dal:read_rpc(gm_blockade) of
							  {ok,Result}->
								  case Result of
									  []->[];
									  _->
								  Fun=fun({_,{RoleId,Type},StartTime,Duration},Acc)->
											  case Type of
												  talk->
													  %Now=timer_center:get_correct_now(),
													  Diff=timer:now_diff(timer_center:get_correct_now(),StartTime),
													  if 
														  trunc(Diff/1000000)<Duration ->
															  case role_db:get_rolename_by_id_rpc(RoleId) of
																  [_]->Acc;
																  BinName->
																	  Acc++[util:escape_uri(BinName),",",integer_to_list(Duration-trunc(Diff/1000000)),";"]
															  end;
														  true->Acc
													  end;
												  _->Acc
											  end
									  end,
								  Str=lists:foldl(Fun,[],Result),
								  {ok,Str}
								  end;
							  _->{error,"read error"}
						  end;
				_->{error,[]}
			end
		end.

disable_ip_login_rpc(IpAddress,LeftTime)->
	gm_order_op:block_ip(IpAddress,LeftTime).

enable_ip_login_rpc(IpAddress)->
	gm_block_db:delete_user(IpAddress, connect).

disable_player_list(Table)->%%@@wb20130502
	case dal:read_rpc(Table) of
		{ok,Result}->
			{ok,Result};
		_->
			{error,"read error"}
	end.

add_gm_notice_rpc(Id,Ntype,Left_count,Begin_time,End_time,Interval_time,Notice_content)->
	gm_notice_db:add_gm_notice(Id, Ntype, Left_count, Begin_time, End_time, Interval_time, 
							   url_util:urldecode(Notice_content)).
	
delete_gm_notice_rpc(Id)->
	gm_notice_db:delete_gm_notice(Id).

hide_gm_notice_rpc(Id,LeftCount)->
	gm_notice_db:hide_gm_notice(Id, LeftCount).

gift_send_rpc(RoleName,GiftList)->
	io:format("gift send not implement ~p ~p ~n",[RoleName,GiftList]).

%%charge rpc
user_charge_rpc(UserName,Rid,Gold)->
	Transaction = 
		fun()->
			case mnesia:read(account, UserName) of
				[]->
					[];
				[Account]->
					#account{gold=OGold,local_gold=Local_gold} = Account,
					NewGold = OGold+Gold,
					
					case env:get(use_qq_pay_flag, 0) of
				     1-> 
					     NewAccount=Account;
					 _-> 
					   NewAccount = Account#account{gold=NewGold,local_gold=Local_gold+Gold}
				   end,
					
					
					mnesia:write(NewAccount),
					NewAccount
			end
		end,
	case dal:run_transaction_rpc(Transaction) of
		{failed,badrpc,_Reason}->
			{error,"badrpc"};
		{faild,Reason}->
			{error,Reason};
		{ok,[]}->
			{error,"1"};
		{ok,Result}->
			#account{username=User,roleids=RoleIds,gold=ReGold,local_gold=Local_gold} = Result,
			FRole = fun(RoleId) ->
						if
							Rid=:=RoleId->
								festival_recharge:change_recharge_num(Gold,RoleId),
								mall_op:change_role_integral(Gold,RoleId);
							true->
								nothing
						end,
						case role_pos_util:where_is_role(RoleId) of
							[]->
								if
									Rid=:=RoleId->	
										vip_op:add_sum_gold(RoleId,Gold);
									true->
										nothing
								end;
							RolePos->
								Node = role_pos_db:get_role_mapnode(RolePos),
								Proc = role_pos_db:get_role_pid(RolePos),
								role_processor:account_charge(Node, Proc, {account_charge,Gold,ReGold})
						end
					end,
			lists:foreach(FRole, RoleIds),
			gm_logger_role:role_gold_change(User,Rid,Gold,ReGold,got_charge),
			{ok};
		_->
			{error,"unknow error"}
	end.

gm_user_charge_rpc(UserName,Rid,Gold)->
	case dal:read_rpc(account, UserName) of
		{ok,[Account]}->
			#account{username=User,roleids=RoleIds,gold=OGold,local_gold=Local_gold} = Account,
			NewGold = OGold+Gold,
			case env:get(use_qq_pay_flag, 0) of
		     1-> 
			     NewAccount=Account;
			 _-> 
			   NewAccount = Account#account{gold=NewGold,local_gold=Local_gold+Gold}
		   end,
				io:format("gm_op:gm_user_charge_rpc UserName:~p ~n",[NewAccount]),
			dal:write_rpc(NewAccount),
			FRole = fun(RoleId) ->
						if
							Rid=:=RoleId->
								mall_op:change_role_integral(Gold,RoleId);
							true->
								nothing
						end,
						case role_pos_util:where_is_role(RoleId) of
							[]->
								if
									Rid=:=RoleId->	
										vip_op:add_sum_gold(RoleId,Gold);
									true->
										nothing
								end;
							RolePos->
								Node = role_pos_db:get_role_mapnode(RolePos),
								Proc = role_pos_db:get_role_pid(RolePos),
								role_processor:account_charge(Node, Proc, {account_charge,Gold,NewGold})
						end
					end,
			lists:foreach(FRole, RoleIds),
			gm_logger_role:role_gold_change(User,Rid,Gold,NewGold,gm_got_charge),
			{ok};
		_->
			{error,"1"}
	end.

gm_first_charge_gift_rpc(UserName)->
	case dal:read_rpc(account, UserName) of
		{ok,[Account]}->
			#account{roleids=RoleIds} = Account,
			FRole = fun(RoleId) ->
						first_charge_gift_op:write_record(RoleId) 
					end,
			lists:foreach(FRole, RoleIds),
			{ok};
		_->
			{error,"1"}
	end.

gm_first_charge_gift_roleid_rpc(RoleId)->
	case role_db:get_role_info(RoleId) of
		[]->
			{error,"1"};
		_->
			first_charge_gift_op:write_record(RoleId),
			{ok}
	end.

gm_activity_finish_rpc(RoleId,Type,SerialNumber)->
	welfare_activity_db:write_record(RoleId,Type,SerialNumber),
	{ok}.

gm_change_role_name_rpc(RoleName,NewName)->%%@@wb20130502 (RoleId,NewName)
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->{error,"norole"};
		[RoleId]->
			gm_order_op:change_role_name(RoleId,NewName)
	end.

gm_facebook_quest_rpc(RoleId,FaceBookId,MsgId)->
	facebook:facebook_quest_finished(RoleId,FaceBookId,MsgId).

gm_import_giftcard_rpc(GiftcardList)->
%% 	io:format("GiftcardList:~p~n",[GiftcardList]),
	case util:string_to_term(GiftcardList) of
		{ok,Terms}->
%% 			io:format("Terms:~p~n",[Terms]),
			try
				giftcard_db:add_giftcard_by_gm(Terms),
				{ok}
			catch
				E:R->slogger:msg("gm_import_giftcard_rpc,E:~p,R:~p~n",[E,R]),
				{error}
			end;
		_ ->
			{error}
	end.

gm_add_whiteip_rpc(First_Num,Sec_Num,Thir_Num,Four_Num)->
	Ip_Addr = {First_Num,Sec_Num,Thir_Num,Four_Num},
	whiteip:add_ip(Ip_Addr),
	{ok}.

gm_send_rpc(FromName,ToName,Title,Content,TemplateId,Count,Add_Silver)->
	case mail_op:gm_send(FromName, ToName, Title, Content, TemplateId, Count, Add_Silver) of
		{ok} ->
			{ok};
		{failed,Reason} ->
			{error,Reason}
	end.

gm_send_all_rpc(FromName,ToRoleIds,Title,Content,TemplateId,Count,Add_Silver)->
	case util:string_to_term(ToRoleIds) of
		{ok,Term}->
%% 			io:format("Term:~p~n",[Term]),
			lists:foldl(fun(ToRoleId,Acc)->
					case mail_op:gm_send_by_roleid(FromName,ToRoleId,Title,Content,TemplateId,Count,Add_Silver) of
				  		{ok} ->
							Acc;
						{failed,_Reason} ->
							Acc++integer_to_list(ToRoleId)++","
					end
				end , "", Term);
		_->
			{error,"ToNamesConvert"}
	end.

gm_update_mall_item_rpc(Id,Ntype,SpecialType,Ishot,Sort,Price,Discount)->
	case util:string_to_term(Price) of
		{ok,Term1} ->
			PriceTerm = Term1,
			case util:string_to_term(Discount) of
				{ok,Term2} ->
					DiscountTerm = Term2,
					mall_item_db:update_by_gm(Id,Ntype,SpecialType,Ishot,Sort,PriceTerm,DiscountTerm);				
				_->
					{error,"discountConvert"}
			end;
		_ ->
			{error,"priceConvert"}
	end.

gm_delete_mall_item_rpc(Id)->
	case dal:delete_rpc(mall_item_info, Id) of
		{ok}->
			{ok};
		{failed,Reason}->
			{error,Reason};
		_->
			{error,"badrpc"}
	end.

gm_delete_sales_item_rpc(Id)->
	case dal:delete_rpc(mall_sales_item_info, Id) of
		{ok}->
			{ok};
		{failed,Reason}->
			{error,Reason};
		_->
			{error,"badrpc"}
	end.

gm_update_guildbattle_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term1} ->
			guildbattle_db:add_proto_to_mnesia(Term1),
			version_up:up_ets([guildbattle_db]),
			{ok};
		_ ->
			{error,"Convert"}
	end.

gm_delete_guildbattle_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term} ->
			case dal:delete_object(util:term_to_record(Term,guild_battle_proto)) of
				{ok}->
					version_up:up_ets([guildbattle_db]),
					{ok};
				{failed,Reason}->
					{error,Reason}
			end;
		_->
			{error,"Convert"}
	end.



gm_update_activity_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term1} ->
			answer_db:add_activity_to_mnesia(Term1),
			answer_db:gm_add_activity_to_ets_rpc(Term1),
			{ok};
		_ ->
			{error,"Convert"}
	end.

gm_update_global_monster_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term1} ->
			Object = util:term_to_record(Term1,global_monster_loot_db),
			case dal:write(Object) of
				{ok}->
					version_up:up_ets([global_monster_loot]),
					{ok};
				{failed,_Reason}->
					{error,"failed"}
			end;
		_ ->
			{error,"Convert"}
	end.

gm_delete_global_monster_rpc(Id)->
	case dal:delete_rpc(global_monster_loot_db, Id) of
		{ok}->
			version_up:up_ets([global_monster_loot]),
			{ok};
		{failed,Reason}->
			{error,Reason}
	end.

gm_update_global_exp_addition_rpc(Info)->
%% 	io:format("Info:~p~n",[Info]),
	case util:string_to_term(Info) of
		{ok,Term} ->
			case global_exp_addition:add_global_exp_addition(Term) of
				ok->
					global_exp_addition:add_global_exp_addition_to_ets_rpc(Term),
					{ok};
				_->
					{error,"failed"}
			end;
		_ ->
			{error,"Convert"}
	end.

gm_delete_global_exp_addition_rpc(Id)->
%% 	io:format("gm_delete_global_exp_addition_rpc,Id:~p~n",[Id]),
	case global_exp_addition:delete_global_exp_addition(Id) of
		ok->
			global_exp_addition:del_global_exp_addition_from_ets_rpc(Id),
			{ok};
		error->
			{error,[]}
	end.

gm_update_welfare_activity_rpc(Info)->
%%	io:format("Info:~p~n",[Info]),
	case util:string_to_term(Info) of
		{ok,Term} ->
			case welfare_activity_db:write_background_welfare_data(Term) of
				ok->
					welfare_activity_db:update_welfare_activity_rpc(),
					{ok};
				_->
					{error,"failed"}
			end;
		_ ->
			{error,"Convert"}
	end.

gm_delete_welfare_activity_rpc(Id)->
	case welfare_activity_db:delete_background_welfare_data(Id) of
		ok->
			welfare_activity_db:update_welfare_activity_rpc(),
			{ok};
		_->
			{error,[]}
	end.

gm_update_pet_explore_map_data_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term} ->
%% 			io:format("Term1:~p~n",[Term]),
			Object = util:term_to_record(Term,pet_explore_background),
			case dal:write(Object) of
				{ok}->
					pet_explore_db:update_pet_explore_map_data_rpc(),
					{ok};
				{failed,Reason}->
					slogger:msg("gm_update_welfare_activity_rpc,Reason:~p~n",[Reason]),
					{error,"failed"}
			end;
		_ ->
			{error,"Convert"}
	end.

gm_delete_pet_explore_map_data_rpc(Id)->
	case dal:delete_rpc(pet_explore_background, Id) of
		{ok}->
			pet_explore_db:update_pet_explore_map_data_rpc(),
			{ok};
		{failed,Reason}->
			{error,Reason}
	end.

gm_update_festival_info_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term} ->
			FestivalId = erlang:element(1, Term),
			case festival_op:get_festival_state_by_id(FestivalId) of
				?CLOSE->
					Object = util:term_to_record(Term,festival_control_background),
					case dal:write_rpc(Object) of
						{ok}->
							Object2 = util:term_to_record(Term,festival_control),
							festival_db:gm_add_festival_control_to_ets_rpc(Object2),
							{ok};
						{failed,Reason}->
							slogger:msg("gm_update_festival_info_rpc,Reason:~p~n",[Reason]),
							{error,"failed"}
					end;
				_->
					{error,"festival_activity_has_open"}
			end;
		_ ->
						{error,"Convert"}
	end.

gm_delete_festival_info_rpc(Id)->
%% 	io:format("gm_delete_festival_info_rpc,id:~p~n",[Id]),
	case  dal:delete_rpc(festival_control_background, Id)  of
		{ok}->
			if
				Id =:= ?FESTIVAL_RECHARGE->
					dal:clear_table(festival_recharge_gift_bg);
				true->
					nothing
			end,
			festival_db:gm_del_festival_control_from_ets_rpc(),
			{ok};
		{failed,Reason}->
			slogger:msg("gm_delete_festival_info_rpc failed Reason:~p~n",[Reason]),
			{error,Reason}
	end.

gm_update_festival_recharge_gift_rpc(Info)->
%% 	io:format("gm_update_festival_recharge_gift_rpc,info:~p~n",[Info]),
	case util:string_to_term(Info) of
		{ok,Term} ->
			Id = element(1, Term),
			case ets:lookup(?FESTIVAL_RECHARGE_GIFT_ETS, Id) of
				[]->
					{error,"failed"};
				_->
					Object = util:term_to_record(Term,festival_recharge_gift_bg),
					case dal:write_rpc(Object) of
						{ok}->
							Object2 = util:term_to_record(Term,festival_recharge_gift),
							festival_db:gm_add_festival_recharge_gift_to_ets_rpc(Object2),
							{ok};
						{failed,Reason}->
							slogger:msg("gm_update_festival_info_rpc,Reason:~p~n",[Reason]),
							{error,"failed"}
					end
			end;
		_ ->
			{error,"Convert"}
	end.	

gm_delete_festival_recharge_gift_rpc(Id)->
%% 	io:format("gm_delete_festival_recharge_gift_rpc,Id:~p~n",[Id]),
	case dal:delete_rpc(festival_recharge_gift_bg, Id) of
		{ok}->
			festival_db:update_festival_recharge_gift_rpc(),
			{ok};
		{failed,Reason}->
			slogger:msg("gm_delete_festival_recharge_gift_rpc failed Reason:~p~n",[Reason]),
			{error,Reason}
	end.
			
gm_update_open_service_activities_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term} ->
			Object = util:term_to_record(Term,open_service_activitied_control),
			case dal:write(Object) of
				{ok}->
					version_up:up_ets([open_service_activities_db]),
					{ok};
				{failed,Reason}->
					slogger:msg("gm_update_open_service_activitied,Reason:~p~n",[Reason]),
					{error,"failed"}
			end;
		_->
			{error,"Convert"}
	end.

gm_delete_open_service_activities_rpc(Id)->
	case dal:delete_rpc(open_service_activitied_control,Id) of
		{ok}->
			version_up:up_ets([open_service_activities_db]),
			{ok};
		{failed,Reason}->
			{error,Reason}
	end.

gm_update_sales_item_rpc(Id,Ntype,Name,Sort,Price,Discount,Duration,SalesTime,Restrict,Bodcast)->
	{ok,TermPrice} = util:string_to_term(Price),
	{ok,TermDiscount} = util:string_to_term(Discount),
	{ok,TermSalesTime} = util:string_to_term(SalesTime),
	{ok,TermRestrict} = util:string_to_term(Restrict),
	Term1 = {Id,Ntype,list_to_binary(Name),Sort,TermPrice,TermDiscount,Duration,TermSalesTime,TermRestrict,Bodcast},
	mall_item_db:add_sales_item_info_to_mnesia(Term1),
	{ok}.

gm_delete_activity_rpc(Info)->
	case util:string_to_term(Info) of
		{ok,Term} ->
			case dal:delete_object(util:term_to_record(Term,activity)) of
				{ok}->
					answer_db:gm_delete_activity_from_ets_rpc(Term),
					{ok};
				{failed,Reason}->
					{error,Reason}
			end;
		_->
			{error,"Convert"}
	end.

gm_set_role_privilege_rpc(RoleName,Privilege)->
	gm_role_privilege_db:add_gm_role(RoleName,Privilege).

gm_delete_role_privilege_rpc(RoleName)->
	gm_role_privilege_db:delete_gm_role(RoleName).

gm_move_user_rpc(RoleName,MapId,PosX,PosY)->
	gm_order_op:move_user_by_name(RoleName,MapId,PosX,PosY),
	{ok}.

system_option_rpc(SysIdKey)->
	system_switch:send_system_switch_rpc(SysIdKey).

power_gather_rpc()->
	gm_order_op:power_gather(),
	{ok}.

get_loop_tower_curlayer_rpc()->
	case loop_tower_db:get_loop_tower_instance() of
		[]->
			{ok,[]};
		Loop_Tower_Layers->
			CurLayer = fun({_,Layer,RoleId,RoleName,Time},Acc)->
				Acc ++ [integer_to_list(Layer),",",integer_to_list(RoleId),",",
						util:escape_uri(RoleName),",",integer_to_list(Time),";"]
				end,
			{ok,lists:foldl(CurLayer, [], Loop_Tower_Layers)}
	end.

all_role_vip_rpc()->
	case vip_db:get_all_vip_role() of
		{ok,[]}->
			{ok,[]};
		{ok,AllVipList}->
			AllVipFun = fun({_,Roleid,_,_,Level,_,_,_},Acc)->%%@@wb20130426修正返回内容
				Acc ++ [integer_to_list(Roleid),",",integer_to_list(Level),";"]
			end,
			Str = lists:foldl(AllVipFun, [], AllVipList),
			{ok,Str}
	end.

gm_log_control_rpc(Table,Option)->
	gm_msgwrite:gm_log_control(list_to_atom(Table),list_to_atom(Option)),
	{ok}.
			
code_hot_change_rpc()->
	code_hot_change:version_up_module().
			
get_server_version_rpc()->
	{ok,code_hot_change:get_version()}.

get_version_rpc(FromProc,FromNode)->
	Version = version:version(),
	{FromProc,FromNode} ! {server_manager,{version,Version}}.
	

	
	
