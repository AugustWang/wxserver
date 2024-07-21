%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-14
%% Description: TODO: Add description to mail_op
-module(mail_op).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("mail_def.hrl").
-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
-include("slot_define.hrl").
-define(MAX_MAIL_COUNT,50).
-define(MAIL_SILVER_LEVEL_RESTRICT,40).
-define(MAIL_TIMEOUT,14*24*3600).
-define(MAIL_TYPE_SYSTEM,1).
-define(MAIL_TYPE_NORMAL,2).
-define(MAIL_TYPE_AUCTION,3).
-define(MAX_TITLE_LENGTH,60).
-define(MAX_CONTENT_LENGTH,700).
-define(INIT_MAX_MAIL_NUM,20).
-define(CONTENT_PREVIEW_LENGTH,10).		%%10 utf-8
%%
%% Exported Functions
%%
-export([mail_status_query_c2s/0,
		 mail_query_detail_c2s/1,
		 mail_get_addition_c2s/1,
		 mail_send_c2s/5,
		 mail_delete_c2s/1,
		 new_notify/2]).
-export([gm_send/7,gm_send_by_roleid/7,gm_send_multi/6,on_playeronline/0,auction_send_by_playeritems/7,gm_send_with_gold/8]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("item_struct.hrl").
%%
%% API Functions
%%
on_playeronline()->
	mail_status_query_c2s().


mail_status_query_c2s()->
	RoleId = get(roleid),
	MailObjects = mail_db:load_mails(RoleId),
	LeftMailObjects = delete_time_out_mail(MailObjects,fun(_)-> nothing end),
	send_init_step(LeftMailObjects).	
%%	MailStatus = lists:map(fun(MailObject)-> mail_to_ms(MailObject,Now) end, LeftMailObjects),
%%	Message = #mail_status_query_s2c{mail_status=MailStatus},
%%	MsgBin = login_pb:encode_mail_status_query_s2c(Message),
%%	role_op:send_data_to_gate(MsgBin).
	
send_init_step(MailObjects)->
	Now = timer_center:get_correct_now(),
	LeftMailStatus = 	
	lists:foldl(fun(MailObject,MailStatus)->
		case length(MailStatus)>=?INIT_MAX_MAIL_NUM of
			true->
				Message = #mail_status_query_s2c{mail_status=MailStatus},
				MsgBin = login_pb:encode_mail_status_query_s2c(Message),
				role_op:send_data_to_gate(MsgBin),
				[mail_to_ms(MailObject,Now)];
			false->
				[mail_to_ms(MailObject,Now)|MailStatus]
		end end,[],MailObjects),
	Message = #mail_status_query_s2c{mail_status=LeftMailStatus},
	MsgBin = login_pb:encode_mail_status_query_s2c(Message),
	role_op:send_data_to_gate(MsgBin).	

mail_query_detail_c2s(MailId)->
	RoleId = get(roleid),
	check_time_out_mail(RoleId),
	case get_mail(MailId,RoleId) of
		[]->
			mail_failed(?ERRNO_MAIL_NO_MAIL);
		MailObject-> 
			Message = #mail_query_detail_s2c{mail_detail=mail_to_md(MailObject)},
			MsgBin = login_pb:encode_mail_query_detail_s2c(Message),
			role_op:send_data_to_gate(MsgBin),
			set_mail_read(MailId)
	end.

mail_get_addition_c2s(MailId)->
	RoleId = get(roleid),
	check_time_out_mail(RoleId),
	case get_mail(MailId,RoleId) of
		[]-> mail_failed(?ERRNO_MAIL_NO_MAIL);
		MailObject-> 
			     ItemIds = MailObject#mail.add_items,
				 Add_Silver = MailObject#mail.add_silver,
				 Add_Gold = MailObject#mail.add_gold,
				 MailObject1=setelement(#mail.add_silver,MailObject,0),
				 MailObject2=setelement(#mail.add_gold,MailObject1,0),				 
				 MailObject3=setelement(#mail.add_items,MailObject2,[]),
				 
				 case items_op:obtain_from_mail_by_itemids(ItemIds) of
					 full->
					 	mail_failed(?ERROR_PACKEGE_FULL);
					 _->
					 	role_op:money_change(?MONEY_SILVER, Add_Silver, getmail),
					 	case Add_Gold of
					 		undefined->
					 			nothing;
					 		_->	
					 			role_op:money_change(?MONEY_GOLD, Add_Gold, getmail)
					 	end,
						dal:write_rpc(MailObject3),
						Msg = #mail_get_addition_s2c{mailid=MailId},
						MsgBin = login_pb:encode_mail_get_addition_s2c(Msg),
						role_op:send_data_to_gate(MsgBin),
						gm_logger_role:role_read_mail(RoleId,MailId,[],0,0)
				end
	end.


mail_send_c2s(ToName,Title,Content,Add_Item,Add_Silver)->
	case (length(Title) =< ?MAX_TITLE_LENGTH) and (length(Content)=<?MAX_CONTENT_LENGTH) of
		true->
			case trade_role:is_trading() of
				false-> 
					case check_money(Add_Silver) of
						true->
							ItemIds =  get_mail_item(Add_Item),
							if is_list(ItemIds)->
								   case role_db:get_roleid_by_name_rpc(ToName) of
									   []-> mail_failed(?ERRNO_MAIL_NO_ROLE);
									   [ToId]->
										   case check_max_mail_count(ToId) of
											   false-> mail_failed(?ERRNO_MAILBOX_FULL);
											   _-> Now = timer_center:get_correct_now(),
												   FromName = get_name_from_roleinfo(get(creature_info)),
												   {Hi,Low} = mailid_generator:gen_newid(),
												   MailId = #mid{midlow=Low,midhigh=Hi},
												   MailObject = #mail{mailid= MailId,
																	  from=FromName,
																	  toid=ToId,
																	  title=Title,
																	  content=Content,
																	  add_items=ItemIds ,
																	  add_silver=Add_Silver,
																	  status=false,
																	  send_time=Now,
																	  type=?MAIL_TYPE_NORMAL},
											case dal:write_rpc(MailObject) of
												{ok}->
													LostItemsTmpAndCount = items_op:lost_from_mail_by_itemids(ItemIds,ToId), 
													role_op:money_change(?MONEY_SILVER, -Add_Silver, sendmail),
													new_notify(MailId,ToId),
													mail_sucess(),
													gm_logger_role:role_send_mail(get(roleid),ToId,MailId,LostItemsTmpAndCount,Add_Silver,0),
													{ok};
												_Any-> 
													mail_failed(?ERRNO_MAIL_INTERL)
											end %% dal:write_rpc(MailObject)
									end%%check_max_mail_count(ToId)
								   end;%%role_db:get_roleid_by_name_rpc(ToName)
							   true->
								   mail_failed(ItemIds)
							end;
						Err->
							mail_failed(Err)
					end;
				_->
					mail_failed(?TRADE_ERROR_TRADING_NOW)
			end;
		_->
			nothing
	end.	
	
mail_delete_c2s(MailId)->
	RoleId = get(roleid),
	case get_mail(MailId,RoleId) of
		[]->
			mail_failed(?ERRNO_MAIL_NO_MAIL);
		MailObject->
			ItemIds = MailObject#mail.add_items,
			Add_Silver = MailObject#mail.add_silver,
			Add_Gold = MailObject#mail.add_gold,
			case dal:delete_rpc(mail, MailId) of
				{ok}->
					delete_mail_addition(MailObject),
					send_mail_delete(MailId),
					gm_logger_role:role_delete_mail(get(roleid),MailId,ItemIds,Add_Silver,Add_Gold,by_role);
				  _->
					mail_failed(?ERRNO_MAIL_INTERL)
			  end
	end.

%%new mail notify, online notify
new_notify(MailId,RoleId)->
	check_time_out_mail(RoleId),
	Status = get_status(MailId,RoleId),
	case Status of
		[]-> nothing;
		_-> Message = #mail_arrived_s2c{mail_status=Status},
			MsgBin = login_pb:encode_mail_arrived_s2c(Message),
			role_pos_util:send_to_role_clinet(RoleId, MsgBin)
	end.

new_notify_rpc(MailId,RoleId)->
	case node_util:get_mapnode() of
		undefined-> ignor;
		MapNode-> rpc:call(MapNode, ?MODULE, new_notify, [MailId,RoleId])
	end.
gm_mail_log(MailId,FromName,ToId,ToName,Title,Content,Items,Add_Silver,Add_Gold)->
	LineKeyValue = [{"cmd","gm_mail"},
					{"mailid",MailId},
					{"from",FromName},
					{"toname",ToName},
					{"torole",ToId},
					{"content",Content},
					{"title",Title},
					{"items",Items},
					{"silver",Add_Silver},
					{"gold",Add_Gold}
					],
	gm_msgwrite:write(gm_mail,LineKeyValue).

%% return error/{ok}   //for auction stall
auction_send_by_playeritems(FromName,ToId,Title,Content,PlayerItems,Add_Silver,Add_Gold)->
	Now = timer_center:get_correct_now(),
	{Hi,Low} = mailid_generator:gen_newid(),
	MailId = #mid{midlow=Low,midhigh=Hi},
	ItemIds = lists:map(fun(PlayerItem) -> items_op:modify_item_to_other_mail(ToId,PlayerItem),playeritems_db:get_id(PlayerItem) end,PlayerItems), 
	MailObject = #mail{mailid= MailId,
					   from=FromName,
					   toid=ToId,
					   title=Title,
					   content=Content,
					   add_items=ItemIds,
					   add_silver=Add_Silver,
					   status=false,
					   send_time=Now,
					   add_gold = Add_Gold,
					   type=?MAIL_TYPE_AUCTION},
	LogItems = lists:map(fun(PlayerItemTmp)-> {playeritems_db:get_entry(PlayerItemTmp),playeritems_db:get_count(PlayerItemTmp)}  end,PlayerItems),
	gm_mail_log(MailId,FromName,"",ToId,Title,Content,LogItems,Add_Silver,Add_Gold),
	case dal:write_rpc(MailObject) of
		{ok}-> 
			new_notify_rpc(MailId,ToId),
			{ok};
		_Any-> 
			error
	end.

gm_send_by_roleid(FromName,ToRoleId,Title,Content,TemplateId,Count,Add_SilverTmp)->
	gm_send_by_roleid_with_gold(FromName,ToRoleId,Title,Content,TemplateId,Count,Add_SilverTmp,0).

gm_send_by_roleid_with_gold(FromName,ToRoleId,Title,Content,TemplateId,Count,Add_SilverTmp,Gold)->
	if
		is_integer(Add_SilverTmp)->
			Add_Silver = Add_SilverTmp;
		true->
			Add_Silver = 0
	end,
	timer_center:start_at_process(),
	Now = timer_center:get_correct_now(),
	{Hi,Low} = mailid_generator:gen_newid(),
	MailId = #mid{midlow=Low,midhigh=Hi},
	ItemIds = case TemplateId of
				  0->[];
				  _-> [items_op:obtain_from_gm_mail_send(ToRoleId,?MAIL_SLOT,TemplateId,Count)]
			  end,
	MailObject = #mail{mailid= MailId,
					   from=FromName,
					   toid=ToRoleId,
					   title=Title,
					   content=Content,
					   add_items=ItemIds,
					   add_silver=Add_Silver,
					   add_gold = Gold,
					   status=false,
					   send_time=Now,
					   type=?MAIL_TYPE_SYSTEM},
	gm_mail_log(MailId,FromName,ToRoleId,ToRoleId,Title,Content,[{TemplateId,Count}],Add_Silver,Gold),
	case dal:write_rpc(MailObject) of
		{ok}-> new_notify_rpc(MailId,ToRoleId),{ok};
		_Any->{failed,?ERRNO_MAIL_INTERL}
	end.

gm_send(FromName,ToName,Title,Content,TemplateId,Count,Add_SilverTmp)->
	gm_send_with_gold(FromName,ToName,Title,Content,TemplateId,Count,Add_SilverTmp,0).
	
gm_send_with_gold(FromName,ToName,Title,Content,TemplateId,Count,Add_SilverTmp,Gold)->
	if
		is_integer(Add_SilverTmp)->
			Add_Silver = Add_SilverTmp;
		true->
			Add_Silver = 0
	end,
	case role_db:get_roleid_by_name_rpc(ToName) of
		[]-> {failed,?ERRNO_MAIL_NO_ROLE};
		[ToId]->
			timer_center:start_at_process(),
			Now = timer_center:get_correct_now(),
			{Hi,Low} = mailid_generator:gen_newid(),
			MailId = #mid{midlow=Low,midhigh=Hi},
			ItemIds = case TemplateId of
						  0->[];
						  _-> [items_op:obtain_from_gm_mail_send(ToId,?MAIL_SLOT,TemplateId,Count)]
					  end,
			MailObject = #mail{mailid= MailId,
							   from=FromName,
							   toid=ToId,
							   title=Title,
							   content=Content,
							   add_items=ItemIds,
							   add_silver=Add_Silver,
							   add_gold = Gold,
							   status=false,
							   send_time=Now,
							   type=?MAIL_TYPE_SYSTEM},
			gm_mail_log(MailId,FromName,ToName,ToId,Title,Content,[{TemplateId,Count}],Add_Silver,Gold),
			case dal:write_rpc(MailObject) of
				{ok}-> new_notify_rpc(MailId,ToId),{ok};
				_Any->{failed,?ERRNO_MAIL_INTERL}
			end;
		_Any-> {failed,?ERRNO_MAIL_INTERL}
	end.	

gm_send_multi(FromName,ToName,Title,Content,TemplateIds,Add_Silver)->
	case role_db:get_roleid_by_name_rpc(ToName) of
		[]-> {failed,?ERRNO_MAIL_NO_ROLE};
		[ToId]->
			timer_center:start_at_process(),
			Now = timer_center:get_correct_now(),
			{Hi,Low} = mailid_generator:gen_newid(),
			MailId = #mid{midlow=Low,midhigh=Hi},
			ItemIds = case TemplateIds of
						  []->[];
						  Ids->
							  lists:foldl(fun({Id,Count},Acc)->
												  if 
													  erlang:length(Acc) < 3->
														  Acc ++ [items_op:obtain_from_gm_mail_send(ToId,?MAIL_SLOT,Id,Count)];
													  true->
														  Acc
												  end
										  end, [], Ids)
					  end,
			MailObject = #mail{mailid= MailId,
							   from=FromName,
							   toid=ToId,
							   title=Title,
							   content=Content,
							   add_items=ItemIds,
							   add_silver=Add_Silver,
							   status=false,
							   send_time=Now,
							   type=?MAIL_TYPE_SYSTEM},
			gm_mail_log(MailId,FromName,ToName,ToId,Title,Content,TemplateIds,Add_Silver,0),
			case dal:write_rpc(MailObject) of
				{ok}-> new_notify_rpc(MailId,ToId),{ok};
				_Any->{failed,?ERRNO_MAIL_INTERL}
			end;
		_Any-> {failed,?ERRNO_MAIL_INTERL}
	end.
	

%%
%% Local Functions
%%

get_status(MailId,RoleId)->
	case get_mail(MailId,RoleId) of
		[]-> [];
		MailObject->
			Now = timer_center:get_correct_now(),
			[mail_to_ms(MailObject,Now)]
	end.


get_mail(MailId,RoleId)->
	case dal:read_rpc(mail, MailId) of
		{ok,[MailObject]}->  if
								 MailObject#mail.toid =/=RoleId -> [];
								 true-> MailObject
						 end;
		_-> []
	end.

check_max_mail_count(RoleId)->
	Max = ?MAX_MAIL_COUNT,
	NormalCount = get_normal_mail_count(RoleId),
	NormalCount<Max. 

get_normal_mail_count(RoleId)->
	case dal:read_index_rpc(mail, RoleId,#mail.toid ) of
		{ok,MailObjects}-> lists:foldl(fun(MailObject,Count)->
											   case element(#mail.type,MailObject) of
												   ?MAIL_TYPE_NORMAL-> Count+1;
												   _-> Count
											   end
									   end, 0, MailObjects);
		_-> 0
	end.


mail_failed(Reason)->
	Msg = #mail_operator_failed_s2c{reason=Reason},
	BinMsg = login_pb:encode_mail_operator_failed_s2c(Msg),
	role_op:send_data_to_gate(BinMsg).

mail_sucess()->
	Msg = login_pb:encode_mail_sucess_s2c(#mail_sucess_s2c{}),
	role_op:send_data_to_gate(Msg).

mail_to_ms(MailObject,Now)->
	{{_Year,Month,Day},{_Hour,_Min,_Sec}} = calendar:now_to_local_time(element(#mail.send_time,MailObject)),
	#ms{mailid=element(#mail.mailid,MailObject),
		from=element(#mail.from,MailObject),
		titile=element(#mail.title,MailObject),
		status=element(#mail.status,MailObject),
		type=element(#mail.type,MailObject),
		has_add = check_mail_add(MailObject),
		leftseconds= get_leftseconds(MailObject,Now),
		month = Month,
		day = Day}.

mail_to_md(MailObject)->
	case element(#mail.add_gold,MailObject) of
			undefined->
				 AddGold = 0;
			Gold->
				AddGold = Gold
		end, 
	#md{mailid=element(#mail.mailid,MailObject),
		content = element(#mail.content,MailObject),
		add_silver = element(#mail.add_silver,MailObject),
		add_gold = AddGold,	
		add_item = case element(#mail.add_items,MailObject) of
					   []->[];
						Items->
				   			lists:foldl(fun(ItemId,ItemInfos)-> 
												case playeritems_db:load_item_info(ItemId,get(roleid)) of 
														[]->
															ItemInfos;
														[PlayerItem]->	
															[item_to_i(PlayerItem)|ItemInfos]
												end
										end,[],Items)
				   end
	   }.
	
item_to_i(PlayerItem)->
 	ItemInfo = items_op:build_fullinfo_by_item(PlayerItem),
	pb_util:to_item_info(ItemInfo).

get_leftseconds(MailObject,Now)->
	SendTime = element(#mail.send_time,MailObject),
	Seconds = timer:now_diff(Now,SendTime) div 1000000 + 1,
	TimeOut = ?MAIL_TIMEOUT,
	if TimeOut>=Seconds->
		   TimeOut - Seconds;
	   true-> 0
	end.

check_mail_add(X)->
	case element(#mail.add_items,X) of
		[]-> 
				Gold = case element(#mail.add_gold,X) of
						 undefined-> 0;
						 G-> G
						end,
					case element(#mail.add_silver,X) + Gold of
						0-> false; 
						_-> true
					end;
		_-> true
	end.

set_mail_read(MailId)->
	case dal:write_rpc(mail, MailId, #mail.status, true) of
		{ok}->{ok};
		_-> failed
	end.

check_money(AddSilver) when is_integer(AddSilver)->
	if AddSilver <0
		 ->?ERRNO_MAIL_NOTENOUGH_SILVER;
	   true->
		   case role_op:check_money(?MONEY_SILVER, -AddSilver) of
			   true->
				   true;
			   _-> ?ERRNO_MAIL_NOTENOUGH_SILVER
		   end
	end;
check_money(_AddSilver)->
	?ERRNO_MAIL_INTERL.

get_mail_item(Slots)->
	try
		lists:foldl(fun(Slot,Itemids)->
							if not is_list(Itemids)->
								   Itemids;
							   true->
								  case package_op:get_iteminfo_in_package_slot(Slot) of
									   []-> ?ERRNO_MAIL_NO_ITEM;
									   ItemInfo->
									   	   ItemId = get_id_from_iteminfo(ItemInfo),
										   case get_isbonded_from_iteminfo(ItemInfo) of
											   0-> 
												   case lists:member(ItemId,Itemids) of
													   true->
												   			?ERRNO_MAIL_NO_ITEM;
													   false->
													   		[ItemId|Itemids]
												   end;
											   _Bound->?ERRNO_MAIL_ITEMBOND
										   end
							   end
						end
					end, [], Slots)
	catch
		E:R->slogger:msg("check_mail_item exception ~p ~p~n",[E,R]), ?ERRNO_MAIL_INTERL
	end.

delete_mail_addition(MailObject)->
	RoleId = MailObject#mail.toid,
	ItemIds = MailObject#mail.add_items,
	lists:foreach(fun(ItemId)->
						  playeritems_db:del_playeritems(ItemId,RoleId)
				  end, ItemIds).


check_time_out_mail(RoleId)->
	MailObjects = mail_db:load_mails(RoleId),
	delete_time_out_mail(MailObjects,fun(MailId)-> send_mail_delete(MailId) end).


delete_time_out_mail(MailObjects,FunWhenDel)->
	Now = timer_center:get_correct_now(),
	FunDel = fun(MailObject)->
				  LeftSeconds = get_leftseconds(MailObject,Now),
				  if LeftSeconds=<0 -> 
						 delete_mail_addition(MailObject),
						 MailId = element(#mail.mailid,MailObject),
						 ItemIds = MailObject#mail.add_items,
						 Add_Silver = MailObject#mail.add_silver,
						 Add_Gold = MailObject#mail.add_gold,
						 dal:delete_rpc(mail, MailId),
						 FunWhenDel(MailId),
						 gm_logger_role:role_delete_mail(get(roleid),MailId,ItemIds,Add_Silver,Add_Gold,by_system),
						 false;
					 true->
						 true
				  end
		  end,
	lists:filter(FunDel, MailObjects).
	
send_mail_delete(MailId)->
	Message = #mail_delete_s2c{mailid=MailId},
	MsgBin = login_pb:encode_mail_delete_s2c(Message),
	role_op:send_data_to_gate(MsgBin).
