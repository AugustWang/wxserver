%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-19
%% Description: TODO: Add description to role_recruitment_db
-module(role_recruitments_db).
-include("role_recruitments_def.hrl").
-include_lib("stdlib/include/qlc.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([add_role_recruitment/5,del_role_recruitment/1,
		 get_role_recruitment_by_id/1,
		 get_role_recruitments_by_isrecruite/1,
		 get_role_recruitment_id/1,
		 get_role_recruitment_name/1,
		 get_role_recruitment_level/1,
		 get_role_recruitment_class/1,
		 get_role_recruitment_instance/1]).

-compile(export_all).
%%
%% API Functions
%%
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
	db_tools:create_table_ram(role_recruitments, record_info(fields,role_recruitments),[],set).
	
create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_recruitments,ram}].

delete_role_from_db(RoleId)->
	nothing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

add_role_recruitment(RoleId,Name,Level,Class,Instance)->
	role_server_travel:safe_do_in_travels(?MODULE,write_role_recruitment_to_db,[RoleId,Name,Level,Class,Instance]).

del_role_recruitment(RoleId)->
	role_server_travel:safe_do_in_travels(?MODULE,delete_role_recruitment_from_db,[RoleId]).

get_role_recruitment_by_id(RoleId)->
	role_server_travel:safe_do_in_travels(?MODULE,read_role_recruitmentinfo_from_db,[RoleId]).

get_role_recruitments_by_isrecruite(InstanceId)->
	role_server_travel:safe_do_in_travels(?MODULE,get_role_recruitments_by_isrecruite_from_db,[InstanceId]).

write_role_recruitment_to_db(RoleId,Name,Level,Class,Instance)->	
	dal:write({role_recruitments,RoleId,Name,Level,Class,Instance}).
	
delete_role_recruitment_from_db(RoleId)->	
    dal:delete(role_recruitments,RoleId).

read_role_recruitmentinfo_from_db(RoleId)->
	case dal:read(role_recruitments,RoleId) of
		{ok,[R]}->R;
		_->[]
	end.

get_role_recruitments_by_isrecruite_from_db(InstanceId)->
	if
		InstanceId=/=0->
			Q = qlc:q([X|| X<-mnesia:table(role_recruitments),X#role_recruitments.instance==InstanceId]);
		true->
			Q = qlc:q([X|| X<-mnesia:table(role_recruitments)])
	end,
	F = fun() ->
		qlc:e(Q)
	end,
	case dal:run_transaction(F) of
		{ok, RolerecruitmentInfos} -> RolerecruitmentInfos;
		_->[]
	end.

%%role_recruitments id,name,level,class,instance
get_role_recruitment_id(RolerecruitmentInfo)->
	element(#role_recruitments.id,RolerecruitmentInfo).
get_role_recruitment_name(RolerecruitmentInfo)->
	element(#role_recruitments.name,RolerecruitmentInfo).
get_role_recruitment_level(RolerecruitmentInfo)->
	element(#role_recruitments.level,RolerecruitmentInfo).
get_role_recruitment_class(RolerecruitmentInfo)->
	element(#role_recruitments.class,RolerecruitmentInfo).
get_role_recruitment_instance(RolerecruitmentInfo)->
	element(#role_recruitments.instance,RolerecruitmentInfo).


