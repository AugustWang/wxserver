%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Chen
%% Created: 2011-9-22
%% Description: TODO: Add description to refine_system_v2_op
-module(refine_system_op).



%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-define(NO_EMPTY_SLOT,0).
-define(UNBONDOUTPUT,1).
-define(ITEM_BOND_STATE_DECIDE,2).
-define(BONDOUTPUT,3).
-define(SINGLE,1).
-define(ONLY_HAS_UNBOND,1).
-define(ZORE_ITEM,0).
-define(NO_PROTOID,0).
-define(MAXRATE,10000).
-define(DATA_DECIDE,1).
-define(ZORE_TIMES,0).
%%
%% Exported Functions
%%
-export([single_refine_process/1,refine_process/2]).

%%
%% API Functions
%%

%%function:single refine  process 
single_refine_process(SerialNumber)->
	case package_op:get_empty_slot_in_package() of			%%check package space
		?NO_EMPTY_SLOT->
%% 			io:format("ERROR_PACKEGE_FULL~n"),
			Result = ?ERROR_PACKEGE_FULL;
		_->
			case refine_system_db:get_refine_info_by_key(SerialNumber) of			%%get refine data
				[]->
					slogger:msg("refine_system data error~n"),
					Result = ?ERROR_UNKNOWN;
				RefineInfo->
					NeedSilver = refine_system_db:get_refine_need_money(RefineInfo),
					OutputType= refine_system_db:get_refine_output_type(RefineInfo),
					NeedItems = refine_system_db:get_refine_need_items(RefineInfo),
					UnBondOutputProto = refine_system_db:get_refine_output_unbond_item(RefineInfo),
					BondOutputProto = refine_system_db:get_refine_output_bond_item(RefineInfo),
					case role_op:check_money(?MONEY_BOUND_SILVER, NeedSilver) of			%%check money if enough
						false->
%% 							io:format("ERROR_LESS_MONEY~n"),
							Result = ?ERROR_LESS_MONEY;
						true->
							case check_needitems_isenough(NeedItems,?SINGLE) of 			%%check needitems if enough
								false->
%% 									io:format("ERROR_ITEM_NOT_ENOUGH~n"),
									Result = ?ERROR_MISS_ITEM;
								true->
									role_op:money_change(?MONEY_BOUND_SILVER, -NeedSilver,refine_system),		%%consume money
									TmpOutputType = consume_need_items(NeedItems,?UNBONDOUTPUT),	%%consume needitems	
									Rate = refine_system_db:get_refine_rate(RefineInfo),
									RandomRate = random:uniform(?MAXRATE),
									if 
										RandomRate =< Rate ->
											OutputItemProto = if
																  OutputType =:= ?DATA_DECIDE ->
																	  if
																		  BondOutputProto =:= ?NO_PROTOID->
																			  UnBondOutputProto;
																		  true->
																			  BondOutputProto
																	  end;
																  OutputType =:= ?ITEM_BOND_STATE_DECIDE ->
																	  if
																		  TmpOutputType =:= ?UNBONDOUTPUT ->
																			  UnBondOutputProto;
																		  TmpOutputType =:= ?BONDOUTPUT ->
																			  BondOutputProto
																	  end
															  end,
											if
												OutputItemProto =:= ?NO_PROTOID->
													slogger:msg("refine_system data error~n"),
													Result = ?ERROR_UNKNOWN;
												true->
													Result = ?ERROR_REFINE_OK,
													gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,?SINGLE,sucess),
													role_op:auto_create_and_put(OutputItemProto,?SINGLE,refine_system),
													update_quest()
											end;
										true->
											gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,?SINGLE,failed),
%% 											io:format("ERROR_REFINE_FAILED~n"),
											Result = ?ERROR_REFINE_FAILED
									end
							end
					end
			end
	end,
	ResultMsg = refine_system_packet:encode_refine_system_s2c(Result),
	role_op:send_data_to_gate(ResultMsg).
													 
												




		


refine_process(SerialNumber,Times)->
%%  io:format("multi_refine_process,SerialNumber:~p,Times:~p~n",[SerialNumber,Times]),
	if
		Times =< ?ZORE_TIMES->
			Result = ?ERROR_UNKNOWN;
		Times>0->
			case refine_system_db:get_refine_info_by_key(SerialNumber) of			%%get refine data
				[]->
					slogger:msg("refine_system data error~n"),
					Result = ?ERROR_UNKNOWN;
				RefineInfo->
					NeedSilver = refine_system_db:get_refine_need_money(RefineInfo),
					OutputType= refine_system_db:get_refine_output_type(RefineInfo),
					NeedItems = refine_system_db:get_refine_need_items(RefineInfo),
					UnBondOutputProto = refine_system_db:get_refine_output_unbond_item(RefineInfo),
					BondOutputProto = refine_system_db:get_refine_output_bond_item(RefineInfo),
					Rate = refine_system_db:get_refine_rate(RefineInfo),
					case check_needitems_isenough(NeedItems,Times) of			%%check needitems if enough
						false->
							Result = ?ERROR_MISS_ITEM;
						true->
							case role_op:check_money(?MONEY_BOUND_SILVER, NeedSilver*Times) of 
								false->
									Result = ?ERROR_LESS_MONEY;
								true->
									case check_packet_isenough(BondOutputProto,UnBondOutputProto,Times) of 
										false->
											Result = ?ERROR_PACKEGE_FULL;
										true->
											[TmpBondOutputNum,TmpUnBondOutputNum] = multi_consume_need_items(NeedItems,Rate,[0,0],Times),
%% 											io:format("TmpBondOutputNum:~p,TmpUnBondOutputNum:~p~n",[TmpBondOutputNum,TmpUnBondOutputNum]),
											[BondOutputNum,UnBondOutputNum] = if
																						  OutputType =:= ?DATA_DECIDE ->
																							  if
																								  BondOutputProto =:= ?NO_PROTOID->
																									  [?ZORE_TIMES,TmpBondOutputNum+TmpUnBondOutputNum];
																								  true->
																									   [TmpBondOutputNum+TmpUnBondOutputNum,?ZORE_TIMES]
																							  end;
																						  true ->
																							  [TmpBondOutputNum,TmpUnBondOutputNum]
																					  end,
%% 											io:format("BondOutputNum:~p,UnBondOutputNum:~p~n",[BondOutputNum,UnBondOutputNum]),
											if
												(BondOutputNum =:= ?ZORE_TIMES) and (UnBondOutputNum =:= ?ZORE_TIMES)->
%% 													io:format("(BondOutputNum =:= ?ZORE_TIMES) and (UnBondOutputNum =:= ?ZORE_TIMES)~n"),
													gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,Times,failed),
													Result = ?ERROR_REFINE_FAILED;
												BondOutputNum =:= ?ZORE_TIMES->
%% 													io:format("BondOutputNum =:= ?ZORE_TIMES~n"),
													Result = ?ERROR_REFINE_OK,
													creature_sysbrd_util:sysbrd({refine_system,UnBondOutputProto},UnBondOutputNum),
													gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,Times,sucess),
													role_op:auto_create_and_put(UnBondOutputProto,UnBondOutputNum,refine_system);
												UnBondOutputNum =:= ?ZORE_TIMES->
%% 													io:format("UnBondOutputNum =:= ?ZORE_TIMES~n"),
													Result = ?ERROR_REFINE_OK,
													creature_sysbrd_util:sysbrd({refine_system,BondOutputProto},BondOutputNum),
													gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,Times,sucess),
													role_op:auto_create_and_put(BondOutputProto,BondOutputNum,refine_system),
													update_quest();
												true->
%% 													io:format("true~n"),
													Result = ?ERROR_REFINE_OK,
													creature_sysbrd_util:sysbrd({refine_system,UnBondOutputProto},UnBondOutputNum),
													creature_sysbrd_util:sysbrd({refine_system,BondOutputProto},BondOutputNum),
													gm_logger_role:refine_system_log(get(roleid),get(level),SerialNumber,Times,sucess),
													role_op:auto_create_and_put(BondOutputProto,BondOutputNum,refine_system),
													role_op:auto_create_and_put(UnBondOutputProto,UnBondOutputNum,refine_system),
													update_quest()
											end
									end
							end
					end
			end
	end,
	ResultMsg = refine_system_packet:encode_refine_system_s2c(Result),
	role_op:send_data_to_gate(ResultMsg).

									
%%function:check needitems if enough in package 
%%return :false,true
check_needitems_isenough(NeedItems,Times)->
	JudgeItemCount = fun({ItemProtoList,NeedCount})->
							 ItemSumCount = lists:foldl(fun(ItemProtoId,TmpItemCount)->		%%calculated the count of a items include bond and unbond 
																ItemCount= package_op:get_counts_by_template_in_package(ItemProtoId),
																ItemCount+TmpItemCount
														end,0,ItemProtoList),
%% 							 io:format("ItemSumCount:~p,NeedCount:~p~n",[ItemSumCount,NeedCount]),
							 if
								ItemSumCount >= (NeedCount*Times)->
									true;
								true->
									false
							end
					 end,
	Result = lists:all(JudgeItemCount,NeedItems),
%% 	io:format("check_needitems_isenough:~p~n",[Result]),
	Result.
							
					
%%check packet if enough 							
check_packet_isenough(BondOutputProto,UnBondOutputProto,Times)->
%% 	io:format("check_packet_isenough:BondOutputProto:~p,UnBondOutputProto:~p,Times:~p~n",[BondOutputProto,UnBondOutputProto,Times]),
	if
		BondOutputProto =:= ?NO_PROTOID->
			package_op:can_added_to_package_template_list([{UnBondOutputProto,Times}]);
		UnBondOutputProto =:= ?NO_PROTOID->
			package_op:can_added_to_package_template_list([{BondOutputProto,Times}]);
		true->
			if
				Times =:= ?SINGLE ->
					case package_op:get_empty_slot_in_package() of
						?NO_EMPTY_SLOT->
							false;
						_->
							true
					end;
				true->
					
					TmpTempInfo = item_template_db:get_item_templateinfo(BondOutputProto),	
					MaxStack = item_template_db:get_stackable(TmpTempInfo),
					if
						MaxStack > 1 ->
							package_op:can_added_to_package_template_list([{UnBondOutputProto,Times},{BondOutputProto,Times}]);
						true->
							update_quest(),
							package_op:can_added_to_package_template_list([{BondOutputProto,Times}])
					end
			end
	end.
							
%%function:consume need items  
%%return output type and number:[BondOutputNum,UnBondOutputNum] 
multi_consume_need_items(_NeedItems,_Rate,[BondOutputNum,UnBondOutputNum],?ZORE_TIMES)->
	[BondOutputNum,UnBondOutputNum];
multi_consume_need_items(NeedItems,Rate,[BondOutputNum,UnBondOutputNum],Times)->
	OutputType = consume_need_items(NeedItems,?UNBONDOUTPUT),
	RandomRate = random:uniform(?MAXRATE),
	if
		RandomRate =< Rate ->
			if
				OutputType =:= ?UNBONDOUTPUT->
					multi_consume_need_items(NeedItems,Rate,[BondOutputNum,UnBondOutputNum+1],Times-1);
				true->
					multi_consume_need_items(NeedItems,Rate,[BondOutputNum+1,UnBondOutputNum],Times-1)
			end;
		true->
			multi_consume_need_items(NeedItems,Rate,[BondOutputNum,UnBondOutputNum],Times-1)
	end.
	
	

%%consume needitems and return output item's type :bond or unbond
%%return:outputbondtype:1,3
consume_need_items([],OutputType)->
	OutputType;

consume_need_items([NeedItem|RemainNeedItems],OutputType)->
	{ItemProtoList,NeedCount} = NeedItem,
	ProtoNum =erlang:length(ItemProtoList),
	if
		ProtoNum =:= ?ONLY_HAS_UNBOND ->			%%the needitem only has unbond type ,consume needitem and save the original output type
			[ProtoId] = ItemProtoList,
			role_op:consume_items(ProtoId,NeedCount),
			TmpOutputType = OutputType;
		true->
			[BondProtoId,UnBondProtoId] = ItemProtoList,
			BondItemCount= package_op:get_counts_by_template_in_package(BondProtoId),
			if 
				BondItemCount =/= ?ZORE_ITEM ->			%%has  bondeditems,consume unbondeditems ,and change output items's bond type
					TmpOutputType = ?BONDOUTPUT,
					BondItemIds = items_op:get_items_by_template(BondProtoId),
					UnBondItemIds = items_op:get_items_by_template(UnBondProtoId),
					role_op:consume_items_by_ids_count(NeedCount,BondItemIds++UnBondItemIds);
				true->								%%doesn't have bondeditems ,consume unbondeditems,and save the original output type
					TmpOutputType = OutputType,
					role_op:consume_items(UnBondProtoId,NeedCount)
			end
	end,
	consume_need_items(RemainNeedItems,TmpOutputType).



update_quest()->	
	quest_op:update(refine,1).
%%
%% Local Functions
%%


													 
											