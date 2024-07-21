%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2011-1-7
%% Description: TODO: Add description to role_create_design
-module(role_create_designer).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("role_template.hrl").

-define(ETS_FOR_EQUIPT,'$create_role_template_equipts$').
%%
%% Exported Functions
%%
-export([create/7,import/1]).


has_star_class(ItemClass)->
	StarClasses = [1,2,3,4,5,6,7,8,9,10,11,24],
	lists:member(ItemClass, StarClasses).
%%
%% API Functions
%%

%%
%% Local Functions
%%
import(FileName)->
	dal:clear_table(template_itemproto),
	case file:consult(FileName) of
		{ok, [Terms]} -> 
			lists:foreach(fun(Term)-> add_playeritem_proto_to_mnesia(Term)end, Terms);
		{error, Reason} ->
			slogger:msg("import playeritem_create error:~p~n",[Reason])
	end.

add_playeritem_proto_to_mnesia(Term)->
	dal:write(util:term_to_record(Term, template_itemproto)).

get_player_item_protos(SetId)->
	case dal:read_rpc(template_itemproto, SetId) of
		{ok,[]}->[];
		{ok,[{_,_,EquipList}|_]}->EquipList;
		_->[]
	end.

create(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId)->
	case create_template_role(Gender,ClassId,RoleName, AccountName,ServerId) of
		{ok,RoleId}-> case RoleName of
						  {visitor,RName} ->
							  gm_logger_role:create_role(AccountName,AccountId,RName,RoleId,ClassId,Gender,CreateIp,true);
						  _->
							  gm_logger_role:create_role(AccountName,AccountId,RoleName,RoleId,ClassId,Gender,CreateIp,false)
					  end,
					  {ok,RoleId};
		_-> {failed,?ERR_CODE_CREATE_ROLE_INTERL}
	end.


create_template_role(Gender,_ClassId,RoleName,Account,ServerId)->
	%%level
	NewClassId = get_class_from_account(Account),
	Level = get_level_from_account(Account),
	EquipSet = get_equipset_from_account(Account),
	EquipStar = get_equipstar_from_account(Account),
	TemplateId = {Gender,NewClassId},
	try
		RoleId = roleid_generator:gen_newid(ServerId),
		RoleTable = db_split:get_owner_table(roleattr, RoleId), 
		QuickBarTable =  db_split:get_owner_table(role_quick_bar, RoleId),
		RoleSkillTable =  db_split:get_owner_table(role_skill, RoleId),
		PlayerItemsTable =  db_split:get_owner_table(playeritems, RoleId),
		QuestRoleTable = db_split:get_owner_table(quest_role, RoleId),
		RoleAttr = case get_roleattr(TemplateId) of
					   {ok,[]}-> throw (no_roleattr_template);
					   {ok,R}-> R;
					   {failed,Reason1}-> throw (Reason1)
				   end,
		RoleQuickBar = case get_role_quick_bar(TemplateId) of
						   {ok,[]}-> throw (no_role_quick_bar_template);
						   {ok,Q}-> Q;
						   {failed,Reason2}-> throw (Reason2)
					   end,
		RoleSkill = case get_role_skill(TemplateId) of
						{ok,[]}-> throw (no_role_skill_template);
						{ok,S}-> S;
						{failed,Reason3}-> throw (Reason3)
					end,
		PlayerItems = case get_playeritems(EquipSet,EquipStar) of
						  {ok,[]}-> throw (no_playeritems_template);
						  {ok,P}-> P;
						  {failed,Reason4}-> throw (Reason4)
					  end,		
		RoleQuests = case get_quest_role(TemplateId) of
						{ok,[]}-> throw (noquest_role_template);
						{ok,QR}-> QR;
						{failed,Reason5}-> throw (Reason5)
					end,
		[RoleAttr1|_] = RoleAttr,
		RoleAttr2 = erlang:setelement(1, RoleAttr1, RoleTable),
		RoleAttr3 = erlang:setelement(#roleattr.roleid, RoleAttr2, RoleId),
		RoleAttr4 = erlang:setelement(#roleattr.name, RoleAttr3, role_name_to_presist(RoleName)),
		RoleAttr5 = erlang:setelement(#roleattr.account, RoleAttr4,Account),
		RoleAttr6 = erlang:setelement(#roleattr.level,RoleAttr5,Level),
		
		[RoleQuickBar1|_] = RoleQuickBar,
		RoleQuickBar2 = erlang:setelement(1, RoleQuickBar1, QuickBarTable),
		RoleQuickBar3 = erlang:setelement(#role_quick_bar.roleid, RoleQuickBar2, RoleId),
		[RoleSkil1|_] = RoleSkill,
		RoleSkil2 = erlang:setelement(1, RoleSkil1, RoleSkillTable),
		RoleSkil3 = erlang:setelement(#role_skill.roleid, RoleSkil2, RoleId),
		NewPlayerItems = lists:map(fun(PlayerItem)->
						  PlayerItem1 = erlang:setelement(1,PlayerItem, PlayerItemsTable),
						  PlayerItem2 = erlang:setelement(#playeritems.id, PlayerItem1,itemid_generator:gen_newid()),
						  erlang:setelement(#playeritems.ownerguid, PlayerItem2, RoleId)
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
			{ok,_}->{ok,RoleId};
			_-> {failed}
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
	case dal:read({template_roleattr,TemplateId}) of
		{ok,Result}->{ok,Result};
		{_,Reason}->{failed,Reason};
		_->{failed,[]}
	end.

get_role_quick_bar(TemplateId)->
	case dal:read({template_role_quick_bar,TemplateId}) of
		{ok,Result}->{ok,Result};
		{_,Reason}->{failed,Reason};
		_->{failed,[]}
	end.

get_role_skill(TemplateId)->
	case dal:read({template_role_skill,TemplateId}) of
		{ok,Result}->{ok,Result};
		{_,Reason}->{failed,Reason};
		_->{failed,[]}
	end.

get_playeritems(EquipSet,EquipStar)->
	EquipList = get_player_item_protos(EquipSet),
	{_,Items} = lists:foldl(fun({Entry,Count},{Num,PlayerItems})->
						ItemInfo = get_item_templateinfo(Entry),
						Duration = item_template_db:get_maxdurability(ItemInfo),
						ItemClass = item_template_db:get_clase(ItemInfo),
						TrueEquipStar = case has_star_class(ItemClass) of
											true-> EquipStar;
											_-> 0
										end,
						SockInfo = case item_template_db:get_maxsocket(ItemInfo) of
							0->[];
							1->[{1,0}];
							2->[{1,0},{2,0}];
							3->[{1,0},{2,0},{3,0}];
							4->[{1,0},{2,0},{3,0},{4,0}];
							_->[]
						end,
						PlayerItem = {playeritems,{Num,Entry},Num,Entry,TrueEquipStar,Count,1001+Num,0,SockInfo,Duration,{{0,0,0},0}},
						{Num+1,PlayerItems ++ [PlayerItem]} end,{1,[]}, EquipList),
	{ok,Items}.

get_quest_role(TemplateId)->
	case dal:read({template_quest_role,TemplateId}) of
		{ok,Result}->{ok,Result};
		{_,Reason}->{failed,Reason};
		_->{failed,[]}
	end.

get_class_from_account(Account)->
	case Account of
		[_,_,Class,_,_,_,_,_,_]-> Class - 48;
		_-> 1
	end.

get_level_from_account(Account)->
	case Account of
		[_,_,_,Level1,Level2,_,_,_,_]-> 10*(Level1 - 48) + Level2-48;
		_-> 1
	end.

get_equipset_from_account(Account)->
	case Account of
		[_,_,_,_,_,Equip1,Equip2,_,_]-> 10*(Equip1 - 48) + Equip2-48;
		_-> 11
	end.

get_equipstar_from_account(Account)->
	case Account of
		[_,_,_,_,_,_,_,Star,_]-> Star-48;
		_-> 0
	end.

get_item_templateinfo(Entry)->
	case dal:read(item_template,Entry) of
		{ok,[R]}-> R;
		_-> []
	end.