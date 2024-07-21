%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(mail_db).
-include("mail_def.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(LOTTERY_DROP_ETS,'$lottery_drop_ets$').
-define(LOTTERY_COUNTS_ETS,'$lottery_levelcount_ets$').

-export([load_mails/1]).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(mail, record_info(fields,mail), [toid], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	case dal:read_index_rpc(mail, RoleId, #mail.toid) of
		{ok,MailObjects}-> lists:foreach(fun(Object)-> dal:delete_object_rpc(Object) end, MailObjects);
		_-> []
	end.

tables_info()->
	[{mail,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_mails(RoleId)->
	case dal:read_index_rpc(mail, RoleId, #mail.toid) of
		{ok,MailObjects}-> MailObjects;
		_-> []
	end.

