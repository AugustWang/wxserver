%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(drop_db).


-define(DROP_RULE_ETS,drop_rule_ets).
-define(NPC_DROP_ETS,npc_drop_ets).

-include("mnesia_table_def.hrl").

-export([get_rules_from_npc/1,get_rule/1]).

-export([get_npc_drop_rate/1,get_npc_drop_ruleids/2,get_rule_ruleid/1,get_rule_name/1,get_rule_roleflag/1,get_rule_itemsdroprate/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?DROP_RULE_ETS, [set,named_table]),
	ets:new(?NPC_DROP_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(drop_rule, ?DROP_RULE_ETS,#drop_rule.ruleid),
	db_operater_mod:init_ets(npc_drop, ?NPC_DROP_ETS,#npc_drop.npcid).

create_mnesia_table(disc)->
	db_tools:create_table_disc(drop_rule,record_info(fields,drop_rule),[],set),
	db_tools:create_table_disc(npc_drop,record_info(fields,npc_drop),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{drop_rule,proto},{npc_drop,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_rules_from_npc(NpcId)->	
	case ets:lookup(?NPC_DROP_ETS, NpcId) of
		[]-> [];
		[{_NpcId,Value}]-> Value
	end.

get_npc_drop_rate(NpcDrop)->
	erlang:element(#npc_drop.rate,NpcDrop).

get_npc_drop_ruleids(NpcDrop,RoleLevel)->
	DropRules = erlang:element(#npc_drop.ruleids,NpcDrop),
	lists:foldl(fun(DropRule,DropAcc)->
					  case DropRule of
						  {MinLevel,MaxLevel,DorpList}->
								if
									MinLevel =< RoleLevel,MaxLevel >= RoleLevel->
										DropAcc ++ DorpList;
									true->
										DropAcc
								end;
						_->
							[DropRule|DropAcc]
					 end
				end,[],DropRules).
		

get_rule(RuleId)->
	case ets:lookup(?DROP_RULE_ETS, RuleId) of
		[]->[];
		[{_Id,Value}] -> Value 
	end.

get_rule_ruleid(RuleInfo)->
	erlang:element(#drop_rule.ruleid,RuleInfo).

get_rule_name(RuleInfo)->
	erlang:element(#drop_rule.name,RuleInfo).

get_rule_roleflag(RuleInfo)->
	erlang:element(#drop_rule.roleflag,RuleInfo).

get_rule_itemsdroprate(RuleInfo)->
	erlang:element(#drop_rule.itemsdroprate,RuleInfo).









