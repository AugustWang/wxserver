%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(instance_pos_db).

%%
%% Include files
%%
-define(INSTANCE_POS,instance_pos).

%%
%% Exported Functions
%%

-export([reg_instance_pos_to_mnesia/9,unreg_instance_pos_to_mnesia/1,get_instance_pos_from_mnesia_by_creation/1]).

-export([get_instance_pos_from_mnesia/1,get_members_by_instanceid/1]).
-include("mnesia_table_def.hrl").	
-compile(export_all).
%%
%% init()
%% initialize ets tables
%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(ram)->
	db_tools:create_table_ram(instance_pos, record_info(fields,instance_pos),[],set);
create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{instance_pos,ram}].

delete_role_from_db(RoleId)->
	nothing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%if is in share_node,regest the instance to every server,for player to find 
reg_instance_pos_to_mnesia(Instanceid,Creation,StartTime,CanJoin,Node,Proc,MapId,Protoid,Members)->
	server_travels_util:cast_for_all_server_with_self_if_share_node(?MODULE,reg_instance_pos_to_db,[Instanceid,Creation,StartTime,CanJoin,Node,Proc,MapId,Protoid,Members]).

unreg_instance_pos_to_mnesia(Instanceid)->
	server_travels_util:cast_for_all_server_with_self_if_share_node(?MODULE,unreg_instance_pos_from_db,[Instanceid]).

get_instance_pos_from_mnesia(Instanceid)->
	role_server_travel:safe_do_in_travels(?MODULE,get_instance_pos_from_db,[Instanceid]).

get_instance_pos_from_mnesia_by_creation(Creation)->
	role_server_travel:safe_do_in_travels(?MODULE,match_creation_from_db,[Creation]).

get_members_by_instanceid(Instanceid)->
	role_server_travel:safe_do_in_travels(?MODULE,get_members_from_db,[Instanceid]).

get_instance_pos_from_db(Instanceid)->	
	case ets:lookup(?INSTANCE_POS, Instanceid) of
		[]->
			[];
		[{_,Id,Creation,StartTime,CanJoin,Node,Pid,MapId,Protoid,Members}]->
			{Id,Creation,StartTime,CanJoin,Node,Pid,MapId,Protoid,Members}
	end.

reg_instance_pos_to_db(Instanceid,Creation,StartTime,CanJoin,Node,Proc,MapId,Protoid,Members)->
	try		
		dal:write({instance_pos,Instanceid,Creation,StartTime,CanJoin,Node,Proc,MapId,Protoid,Members})
	catch
		_:_-> error
	end.

unreg_instance_pos_from_db(Instanceid)->
	try		
		dal:delete(instance_pos,Instanceid)
	catch
		_:_-> error
	end.

get_members_from_db(Instanceid)->	
	case ets:lookup(?INSTANCE_POS, Instanceid) of
		[]->
			[];
		[InstaceInfo|_]->
			element(#instance_pos.members,InstaceInfo)
	end.

match_creation_from_db(Creation)->
	case ets:match_object(?INSTANCE_POS, {'_','_',Creation,'_','_','_','_','_','_','_'}) of
		[]->[];
		Instances->Instances
	end.
	
