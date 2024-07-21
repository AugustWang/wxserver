%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-19
%% Description: TODO: Add description to group_db
-module(group_db).
-include("mnesia_table_def.hrl").
-include_lib("stdlib/include/qlc.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([add_group/6,del_group/1,
		 get_group_by_id/1,
		 get_groups_by_isrecruite/2,
		 get_group_isrecruite/1,
		 get_group_leaderid/1,
		 get_group_instance/1,
		 get_group_members/1,
		 get_group_description/1,
		 set_group_leaderid/2,
		 write_group/1]).

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing;

create_mnesia_table(ram)->
	db_tools:create_table_ram(groups, record_info(fields,groups),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{groups,ram}].

delete_role_from_db(RoleId)->
	nothing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% API Functions
%%

add_group(GroupId,Isrecruite,Leaderid,Instance,Members,Description)->
	role_server_travel:safe_do_in_travels(?MODULE,write_group_to_db,[GroupId,Isrecruite,Leaderid,Instance,Members,Description]).

del_group(GroupId)->
	role_server_travel:safe_do_in_travels(?MODULE,delete_group_from_db,[GroupId]).

get_group_by_id(GroupId)->
	role_server_travel:safe_do_in_travels(?MODULE,read_groupinfo_from_db,[GroupId]).

get_groups_by_isrecruite(Isrecruite,InstanceId)->
	role_server_travel:safe_do_in_travels(?MODULE,get_groups_by_isrecruite_from_db,[Isrecruite,InstanceId]).

write_group_to_db(GroupId,Isrecruite,Leaderid,Instance,Members,Description)->	
	write_group({groups,GroupId,Isrecruite,Leaderid,Instance,Members,Description}).
	
write_group(GroupInfo)->	
	dal:write(GroupInfo).
	
delete_group_from_db(GroupId)->	
    dal:delete(groups,GroupId).

read_groupinfo_from_db(GroupId)->
	case ets:lookup(groups, GroupId) of
		[]->[];
		[R|_]->R
	end.

get_groups_by_isrecruite_from_db(Isrecruite,InstanceId)->
	if
		InstanceId=/=0->
			ets:match_object(groups, {'_','_',Isrecruite,'_',InstanceId,'_','_'});
		true->
			ets:match_object(groups, {'_','_',Isrecruite,'_','_','_','_'})
	end.
%%
%% GroupInfo:return by get_group_by_id() or get_groups_by_isrecruite()
%%
get_group_isrecruite(GroupInfo)->
	element(#groups.isrecruite,GroupInfo).

%%
%% GroupInfo:return by get_group_by_id() or get_groups_by_isrecruite()
%%
get_group_leaderid(GroupInfo)->
	element(#groups.leaderid,GroupInfo).

set_group_leaderid(GroupInfo,LeaderId)->
	erlang:setelement(#groups.leaderid, GroupInfo, LeaderId).

%%
%% GroupInfo:return by get_group_by_id() or get_groups_by_isrecruite()
%%
get_group_instance(GroupInfo)->
	element(#groups.instance,GroupInfo).

%%
%% GroupInfo:return by get_group_by_id() or get_groups_by_isrecruite()
%%
get_group_members(GroupInfo)->
	element(#groups.members,GroupInfo).

%%
%% GroupInfo:return by get_group_by_id() or get_groups_by_isrecruite()
%%
get_group_description(GroupInfo)->
	element(#groups.description,GroupInfo).

