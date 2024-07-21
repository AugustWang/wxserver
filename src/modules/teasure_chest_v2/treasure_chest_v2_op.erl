%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: ChenXiaowei
%% Created: 2011-7-23
%% Description: TODO: Add description to treasure_chest_op
-module(treasure_chest_v2_op).


%%
%% Include files
%%
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").
-define(MAX_TREASURE_DROP_NUM,16).
-define(GOLD_CONSUME,1).
-define(ITEM_CONSUME,0).
%%
%% Exported Functions
%%
-export([process_treasure_chest/3]).

%%
%% API Functions
%%


%% 
%%function:judge gold or beads if enough ,and consume gold or beads,then begin lottery
%%arg:pray_type,pray_times,consume_type:gold or beads
%% 
process_treasure_chest(BeadType,Times,ConsumeType)->
	ReMainSize = treasure_storage_op:get_remain_size(),
	if 		
		Times=<ReMainSize->												%% packet is enough
			if  
				ConsumeType =:= ?GOLD_CONSUME->      					%% consume gold
				    NeedConsumeGold =lists:nth(BeadType,treasure_chest_v2_db:get_need_consume_gold(Times)),
				    case role_op:check_money(?MONEY_GOLD, NeedConsumeGold) of
					    true->											%% gold is enough
						    role_op:money_change(?MONEY_GOLD, -NeedConsumeGold, treasure_chest_cost),
						    lottery_operate(BeadType,Times,0,Times,ConsumeType);
					    false->											%% gold is not enough
				   			%%maybe  hacker
						    slogger:msg("process_treasure_chest:money not enough maybe hacker~p~n",[get(roleid)]),
				   		    Msg = treasure_chest_v2_packet:encode_treasure_chest_v2_fail_s2c(?TREASURE_CHEST_GOLD_NOT_ENOUGH),
				  		    role_op:send_data_to_gate(Msg)
				    end;
			    ConsumeType =:= ?ITEM_CONSUME->      					%% consume beads
				    [BindProtoId,NonBindProtoId] = treasure_chest_v2_db:get_protoid(BeadType),
				    BindNum = item_util:get_items_count_in_package(BindProtoId),						   
				    NonBindNum = item_util:get_items_count_in_package(NonBindProtoId), 
				    if
					    BindNum+NonBindNum>=Times->						%% beads is enough
						    BindItemIds = items_op:get_items_by_template(BindProtoId),
						    NonBindItemIds = items_op:get_items_by_template(NonBindProtoId),
						    role_op:consume_items_by_ids_count(Times,BindItemIds++NonBindItemIds), 
						    if
							    BindNum=<Times->						
								    NonBindConsumeNum = Times-BindNum,
								    lottery_operate(BeadType,Times,BindNum,NonBindConsumeNum,ConsumeType);
							    true->
								    lottery_operate(BeadType,Times,Times,0,ConsumeType)
						    end;
					    true->											%% beads is not enough
						    slogger:msg("process_treasure_chest:item is not enough maybe hacker,RoleId:~p~n",[get(roleid)]),
							Msg = treasure_chest_v2_packet:encode_treasure_chest_v2_fail_s2c(?TREASURE_CHEST_ITEM_NOT_ENOUGH),
						    role_op:send_data_to_gate(Msg)
		   			 end;
			 true->												
				 slogger:msg("treasure_chest_v2_op:consumetype:error:~p~n",[ConsumeType])
			end;
		true->															%%maybe hacker
			Msg = treasure_chest_v2_packet:encode_treasure_chest_v2_fail_s2c(?TREASURE_CHEST_PACKET_NOT_ENOUGH),
		    role_op:send_data_to_gate(Msg)
	end.

%%
%%function:
%%lottery operate:lottery and make lottery_items,put treasure_chest packet	
%%args:
%% 	   BeadType:beads_type
%% 	   Times:sum lottery times
%% 	   BindTimes:BindItem lottery times
%% 	   NonBindTimes:NonBindItem lottery times	
%% 

lottery_operate(BeadType,Times,BindTimes,NonBindTimes,ConsumeType)->
	[BindProtoId,NonBindProtoId] = treasure_chest_v2_db:get_protoid(BeadType),
	Level = get(level),
	Class = get(classid),
	BindLotteryItemList = get_lottery_itemlist(BindProtoId,Level,Class,BindTimes),
	NonBindLotteryItemList = get_lottery_itemlist(NonBindProtoId,Level,Class,NonBindTimes),
	TmpLotteryItemList = BindLotteryItemList++NonBindLotteryItemList,
%% 	TmpSortItemList = lists:sort(TmpLotteryItemList),
	MergeItemList = treasure_storage_op:array_item(TmpLotteryItemList),
	LotteryItemList = lists:map(fun({Proto,Count})->
										{lti,Proto,Count}
										end, MergeItemList),
	BinMsg = treasure_chest_v2_packet:encode_treasure_chest_v2_response_s2c(BeadType,Times,LotteryItemList),
	role_op:send_data_to_gate(BinMsg),
	treasure_storage_op:add_item(MergeItemList),
	treasure_chest_log(Times,BeadType,ConsumeType,BindTimes,NonBindTimes,MergeItemList).

	

%% 	
%%function:make lottery_items_list 
%%args: 
%%		protoid:beads_protoid
%%		level:rolelevel
%%		class
%%		lottery times
%%return:
%%		ItemList:[{ItemProto,ItemCount}]	   
%% 
get_lottery_itemlist(ProtoId,Level,Class,Times)->
	if
		Times =:= 0->
			[];
		true->
			Drops = treasure_chest_v2_db:get_drops(ProtoId, Level, Class),
			case Drops of
				[]->
					slogger:msg("treasure_chest_v2_op:treasure_chest_operate:get_lottery_itemlist:error:drops is null noitem~p~n"),
					[];
				_->
					lottery_items(Drops,Times,[])
			end
	end.
	
			
lottery_items(_Drops,0,GetItemList)->
	GetItemList;

lottery_items(Drops,Times,GetItemList)->
	Items = apply_drops(Drops),
	Slot = random_items(Items),
	achieve_op:achieve_update({treasure_chest},[0],1),%%@@wb20130408绁堢鎴愬氨鏇存柊
	{TemplateId,ItemCount} = lists:nth(Slot+1, Items),
	broad_obtain(TemplateId,ItemCount),
	lottery_items(Drops,Times-1,[{TemplateId,ItemCount}|GetItemList]).


apply_drops(Drops)->
	apply_drops_max(Drops,?MAX_TREASURE_DROP_NUM).

apply_drops_max(Drops,MaxSlot)->
	LastDrop = lists:last(Drops),
	Left = MaxSlot - length(Drops),
	NewDrops = if Left >0 ->
					  Drops ++ lists:duplicate(Left, LastDrop);
				  Left == 0->
					  Drops;
				  true->
					  lists:sublist(Drops, MaxSlot)
			   end,
	lists:append(lists:map(fun(RuleId)-> X = drop:apply_rule(RuleId,1),
										 X end, confusion(NewDrops))).


random_items(ChestList)->
	MaxNum = get_totoal_num(ChestList),
	Num = random:uniform(MaxNum),
	{Slot,_,_}= lists:foldl(fun({Item,Count},Acc)->
									case Acc of
										{-1,Rate,I}->
											Result = Rate + treasure_chest_v2_db:get_rate(Item, Count),
											if Num =< Result->
												   {I,0,0};
											   true->
												   {-1,Result,I+1}
											end;
										{Indx,_,_}->
											{Indx,0,0}
									end
							end, {-1,0,0}, ChestList),
	case Slot of
		-1-> length(ChestList)-1;
		_-> Slot
	end.

get_totoal_num(ChestList)->
	Fun = fun({Item,Count},Acc)->
				  treasure_chest_v2_db:get_rate(Item, Count)+ Acc 
		  end,
	lists:foldl(Fun, 0, ChestList).


%%
%%system broad
%%	
broad_obtain(ProtoId,Count)->
	creature_sysbrd_util:sysbrd({treasure_chest,ProtoId},Count).


confusion(Drops)->
	{NewDrops,_} = lists:foldl(fun(_,{NewList,OldList})->
									LeftCount = length(OldList),
									RNum = random:uniform(LeftCount),
									NewRule = lists:nth(RNum, OldList),
									NewList2 = [NewRule|NewList],
									{L1,L2} = lists:split(RNum-1,OldList),
									 OldList2 = L1 ++ case L2 of
														  []->[];
														  [_|T]-> T
													  end,
									{NewList2,OldList2}
							 end, {[],Drops},Drops),
	NewDrops.

%% 
%% function:
%%	   record role treasure chest message 
%% 
%%args:
%%	   Times:sum lottery times 
%% 	   BeadType:beads_type
%% 	   BindTimes:BindItem lottery times
%% 	   NonBindTimes:NonBindItem lottery times	
%%	   TreasureItems:[{ProtoId,Count}] 
%% 

treasure_chest_log(Times,BeadType,ConsumeType,BindTimes,NonBindTimes,TreasureItems)->
	[_,ProtoId] = treasure_chest_v2_db:get_protoid(BeadType),
	RoleId = get(roleid),
	BeadTemplateInfo = item_template_db:get_item_templateinfo(ProtoId),
	BeadName = item_template_db:get_name(BeadTemplateInfo),
	if
		ConsumeType =:= ?GOLD_CONSUME ->
			ConsumeMoney = lists:nth(BeadType,treasure_chest_v2_db:get_need_consume_gold(Times)),
			BindConsumeNum = 0,
			NonBindConsumeNum = 0;
		ConsumeType =:= ?ITEM_CONSUME ->
			ConsumeMoney = 0,
			BindConsumeNum = BindTimes,
			NonBindConsumeNum = NonBindTimes			
	end,
	gm_logger_role:treasure_chest_lottery_items(RoleId,BeadName,ConsumeType,ConsumeMoney,BindConsumeNum,NonBindConsumeNum,TreasureItems,get(level)).
											
%%
%% Local Functions
%%
