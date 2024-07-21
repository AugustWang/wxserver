%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-8
%% Description: TODO: Add description to drop
-module(drop).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([apply_rulelist/2,apply_rule/2,apply_npc_droplist/4,apply_quest_droplist/1,apply_lottery_droplist/1]).
-export([test/0]).

%% -> {ItemList}
%% call this function need to seed such as :random:seed(erlang:now())
apply_npc_droplist(NpcId,RoleFlag,NpcLevel,RoleLevel)->
	case drop_db:get_rules_from_npc(NpcId) of
		[] ->
			[];
		DropInfo->
			RuleList = drop_db:get_npc_drop_ruleids(DropInfo,RoleLevel),
			case drop_db:get_npc_drop_rate(DropInfo) of
				0-> [];
				Rate-> CurN = random:uniform(100),
					if  Rate < CurN -> [];
						true->
							apply_rulelist(RuleList ++ global_monster_loot:get_global_drop_list(NpcId,NpcLevel),RoleFlag) 
					end
			end
	end.

apply_quest_droplist(RuleList)->
	apply_rulelist(RuleList,1).

apply_lottery_droplist(RuleList)->
	apply_rulelist(RuleList,1).

apply_rulelist(RuleList,RoleFlag)->
	lists:foldl(fun(RuleId,Acc)->
						case apply_rule(RuleId,RoleFlag) of
							[]->  Acc;
							[{Item,Count}]-> 
								gm_logger_role:drop_rule(RuleId, Item, Count, RoleFlag),
								case lists:keyfind(Item, 1, Acc) of
										 false-> [{Item,Count}|Acc];
										 {Item,V}-> lists:keyreplace(Item, 1, Acc, {Item,V+Count})
								end
						end
				end, [], RuleList).
	
apply_rule(RuleId,_RoleFlag)->
	case drop_db:get_rule(RuleId) of
		[]->[];	%% item []
		DropInfo->
			ItemsDropRate = drop_db:get_rule_itemsdroprate(DropInfo),
			apply_drop_rule(ItemsDropRate)
	end.

calc_max_rate(ItemsDropRate)->
	lists:foldl(fun(ItemRate,LastRate)->
						LastRate +element(2,ItemRate)
				end, 0, ItemsDropRate).

select_item({Item,Rate},{SelItem,LeftRate}=LastSel)->
	case SelItem of
		[]->
			CurRate = LeftRate - Rate,
			if
				CurRate =<0 -> 
					{[{Item,1}],0};
				true->
					{[],CurRate}
			end;
		_->
			LastSel
	end;

select_item({Item,Rate,Count},{SelItem,LeftRate}=LastSel)->
	case SelItem of
		[]->
			CurRate = LeftRate - Rate,
			if
				CurRate =<0 -> {[{Item,Count}],0};
				true-> {[],CurRate}
			end;
		_->
			LastSel
	end.
	
apply_drop_rule(ItemsDropRate)->
	MaxRate = calc_max_rate(ItemsDropRate),
	NowVal = random:uniform(MaxRate),
	{Items,_}=lists:foldl(fun(X,Acc)->select_item(X,Acc) end, {[],NowVal}, ItemsDropRate),
	lists:filter(fun({I,_Count})-> I =/= 0  end, Items).


test()->
	random:seed(erlang:now()),
	apply_npc_droplist(1090007,1,1,10).
