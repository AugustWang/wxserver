%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_destroy_items).

-include("error_msg.hrl").

-export([on_acc_script/2,check_item_has_count/2]).

on_acc_script(_Quest,ItemTemplates)->
	IsHaveItem = lists:foldl(fun({[BoundItemId,ItemId],Count},Acc)->
								 case check_item_has_count(BoundItemId,Count) of
									 {true,_}->
										 script_op:destory_item(BoundItemId,Count),
										 [true|Acc];
									 {false,{Num,LeftNum}}->
										  case check_item_has_count(ItemId,LeftNum) of
											  {true,_}->
												  script_op:destory_item(BoundItemId,Num),
												  script_op:destory_item(ItemId,LeftNum),
												  [true|Acc];
											  _->
												  [false|Acc]
										  end
								 end
							end,[],ItemTemplates),
	case lists:member(false,IsHaveItem) of
		true->
			{false,?ERROR_MISS_ITEM};
		_->
			true	
	end.

check_item_has_count(ItemId,Count)->
	Num = package_op:get_counts_by_template_in_package(ItemId),
	if
		Num >= Count ->
			{true,{Count,0}};
		true->
			LeftNum = Count - Num,
			{false,{Num,LeftNum}}
	end.			








