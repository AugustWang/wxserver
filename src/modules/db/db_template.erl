%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-12
%% Description: TODO: Add description to db_template
-module(db_template).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("role_template.hrl").
%%
%% Exported Functions
%%
-export([create_template_role/4,import/1]).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%
%% behaviour functions
%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(template_roleattr,record_info(fields,roleattr),[account,name],set),
	db_tools:create_table_disc(template_role_quick_bar,record_info(fields,role_quick_bar),[],set),
	db_tools:create_table_disc(template_role_skill,record_info(fields,role_skill),[],set),
	db_tools:create_table_disc(template_playeritems,record_info(fields,playeritems),[ownerguid],set),
	db_tools:create_table_disc(template_itemproto, record_info(fields,template_itemproto), [], set),
	db_tools:create_table_disc(template_quest_role,record_info(fields,quest_role),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{template_roleattr,proto},{template_role_quick_bar,proto},{template_role_skill,proto},{template_playeritems,proto},{template_itemproto,proto},{template_quest_role,proto}].
%%
%% Local Functions
%%

create_template_role(TemplateId,RoleName,Account,ServerId)->
	 io:format("db_template create_template_role ServerId ~p Account ~p ~n",[ServerId,Account]),
	try
		RoleId = roleid_generator:gen_newid(ServerId),
		RoleTable = db_split:get_owner_table(roleattr, RoleId), 
		QuickBarTable =  db_split:get_owner_table(role_quick_bar, RoleId),
		RoleSkillTable =  db_split:get_owner_table(role_skill, RoleId),
		PlayerItemsTable =  db_split:get_owner_table(playeritems, RoleId),
		QuestRoleTable = db_split:get_owner_table(quest_role, RoleId),
		RoleAttr = case get_roleattr(TemplateId) of
					   {ok,[]}-> [];
					   {ok,R}-> R
				   end,
	
		RoleQuickBar = case get_role_quick_bar(TemplateId) of
						   {ok,[]}-> [];
						   {ok,Q}-> Q;
						   {failed,Reason2}-> throw (Reason2)
					   end,
		
		RoleSkill = case get_role_skill(TemplateId) of
						{ok,[]}-> [];
						{ok,S}-> S;
						{failed,Reason3}-> throw (Reason3)
					end,
		
		PlayerItems = case get_playeritems(TemplateId) of
						  {ok,[]}-> [];
						  {ok,P}-> P;
						  {failed,Reason4}-> throw (Reason4)
					  end,
		RoleQuests = case get_quest_role(TemplateId) of
						{ok,[]}-> [];
						{ok,QR}-> QR;
						{failed,Reason5}-> throw (Reason5)
					end,
	
		[RoleAttr1|_] = RoleAttr,
		RoleAttr2 = erlang:setelement(1, RoleAttr1, RoleTable),
		RoleAttr3 = erlang:setelement(#roleattr.roleid, RoleAttr2, RoleId),
		RoleAttr4 = erlang:setelement(#roleattr.name, RoleAttr3, role_name_to_presist(RoleName)),
		RoleAttr5 = erlang:setelement(#roleattr.account, RoleAttr4,Account),
		FatigueList = env:get2(fatigue, fatigue_list, []),
		NoFatigueList = env:get2(fatigue, nofatigue_list, []),
		RoleAttr6 = case lists:filter(fun({AccountItem,_})->
								  Account=:=AccountItem
						  end , FatigueList ++ NoFatigueList) of
			[]-> RoleAttr5;
			[{_Account,Level}]->erlang:setelement(#roleattr.level,RoleAttr5,Level);
			[{_Account,Level}|_T]->erlang:setelement(#roleattr.level,RoleAttr5,Level)
		end,
			
		[RoleQuickBar1|_] = RoleQuickBar,
		RoleQuickBar2 = erlang:setelement(1, RoleQuickBar1, QuickBarTable),
		RoleQuickBar3 = erlang:setelement(#role_quick_bar.roleid, RoleQuickBar2, RoleId),
		[RoleSkil1|_] = RoleSkill,
		RoleSkil2 = erlang:setelement(1, RoleSkil1, RoleSkillTable),
		RoleSkil3 = erlang:setelement(#role_skill.roleid, RoleSkil2, RoleId),
		
		NewPlayerItems = lists:map(fun(PlayerItem)->
						  PlayerItem1 = erlang:setelement(1,PlayerItem, PlayerItemsTable),
						  PlayerItem2 = erlang:setelement(#playeritems.id, PlayerItem1,itemid_generator:gen_newid()),
						  PlayerItem3 = erlang:setelement(#playeritems.ownerguid, PlayerItem2, RoleId),
						  PlayerItemProtoId = erlang:element(#playeritems.entry,PlayerItem3),
						  case get_item_proto(PlayerItemProtoId) of
							  []->
								  PlayerItem4 = PlayerItem3;
						      ItemProtoInfo->
								  OverDue = items_op:create_item_overdue(ItemProtoInfo),
								  PlayerItem4 = erlang:setelement(#playeritems.overdueinfo, PlayerItem3, OverDue)
						  end,
						  PlayerItem4		  
					end, PlayerItems),	
		[RoleQuests1|_]=RoleQuests,
		
		RoleQuests2 = erlang:setelement(1,RoleQuests1, QuestRoleTable),
		RoleQuests3 = erlang:setelement(#quest_role.roleid, RoleQuests2, RoleId),
		
		QF = fun()->
					mnesia:write(RoleAttr6),
					mnesia:write(RoleQuickBar3),
					mnesia:write(RoleSkil3),
					lists:foreach(fun(X)-> mnesia:write(X) end, NewPlayerItems),
					mnesia:write(RoleQuests3)
			end,
		case dal:run_transaction(QF) of
			{ok,_}-> {ok,RoleId};
			Error-> io:format("Error ~p ~n",[Error]),{failed}
		end
	
	catch
		throw : no_roleattr_template -> io:format("exception:no_roleattr_template~n"),{failed};
		throw : no_role_quick_bar_template ->io:format("exception:no_role_quick_bar_template~n"), {failed};
		throw : no_role_skill_template -> io:format("exception:no_role_skill_template~n"),{failed};
		throw : no_playeritems_template ->io:format("exception:no_playeritems_template~n"), {failed};
		throw : noquest_role_template ->io:format("exception:noquest_role_template~n"), {failed};
		throw : Reason ->io:format("exception:~p ~n",[Reason]), {failed};
		E:Re-> io:format("exception:~p ~p ~n",[E,Re]),{failed}
	end.

role_name_to_presist(RoleName) when is_list(RoleName)->
	list_to_binary(RoleName);
role_name_to_presist(RoleName) when is_binary(RoleName)->
	RoleName;
role_name_to_presist(RoleName) when is_tuple(RoleName)->
	case RoleName of
		{Key,RName}-> {Key,role_name_to_presist(RName)};
		_->RoleName
	end.

get_roleattr(TemplateId)->
	case dal:read(template_roleattr, TemplateId) of
		{ok,Result}->{ok,Result};
		_->{ok,[]}
	end.

get_role_quick_bar(TemplateId)->
	case dal:read(template_role_quick_bar, TemplateId) of
		{ok,Result}->{ok,Result};
		_->{ok,[]}
	end.

get_role_skill(TemplateId)->
	case dal:read(template_role_skill, TemplateId) of
		{ok,Result}->{ok,Result};
		_->{ok,[]}
	end.

get_playeritems(TemplateId)->
	case dal:read_index(template_playeritems, TemplateId, #playeritems.ownerguid) of
		{ok,Re} ->{ok,Re};
		_->{ok,[]}
	end.

get_quest_role(TemplateId)->
	case dal:read(template_quest_role, TemplateId) of
		{ok,Result}->{ok,Result};
		_->{ok,[]}
	end.

get_item_proto(TemplateId)->
	case dal:read(item_template, TemplateId) of
		{ok,[Result]}->Result;
		_->[]
	end.

import(File)->
	dal:clear_table(template_roleattr),
	dal:clear_table(template_role_skill),
	dal:clear_table(template_role_quick_bar),
	dal:clear_table(template_playeritems),
	dal:clear_table(template_quest_role),
	case file:consult(File) of
		{ok,Terms}->
			lists:foreach(fun(Term)->
								  dal:write(Term)
						  end,Terms);
		{error,Reason} ->
			slogger:msg("imort role template failed error:~p~n",[Reason])
	end.
