%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------

-module(facebook_db).

-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([get_facebook_finished_quest/1,get_facebook_bind_state/1,put_facebook_quest_state/3]).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(facebook_bind,record_info(fields,facebook_bind),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{facebook_bind,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(facebook_bind,RoleId).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%% 
%%db opterate 
%% 

get_facebook_finished_quest(RoleId)->
	case dal:read_rpc(facebook_bind,RoleId) of
		{ok,[{_,_,FBQuest}]}->
			FBQuest;
		_->
			[]
	end.
get_facebook_bind_state(RoleId)->
	case dal:read_rpc(facebook_bind,RoleId) of
		{ok,[{_,_,[{FBID,_}|_FBQuest]}]}-> 
			FBID;
		_-> 
			[]
	end.

%%put quest state to db 
put_facebook_quest_state(RoleId,FaceBookId,MsgId)->
	case dal:read_rpc(facebook_bind,RoleId) of
		{ok,[]}->
			Info = #facebook_bind{roleid = RoleId,fb_quest = [{FaceBookId,MsgId}]},
			case dal:write_rpc(Info) of
				{ok}->
					{ok};
				_->
					{error,write_db_failed}
			end;					  					  
		{ok,[{_,_,FBQuest}]}->
			Info = #facebook_bind{roleid = RoleId,fb_quest = [{FaceBookId,MsgId}|FBQuest]},
			case dal:write_rpc(Info) of
				{ok}->
					{ok};
				_->
					{error,write_db_failed}
			end;
		_->
			{error,read_db_failed}
	end.