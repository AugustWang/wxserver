%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-6
%% Description: TODO: Add description to mysqlconn
-module(mysqlconn).
-compile(export_all).
-define(DB, conn).
-define(DB_HOST, "192.168.1.251").
-define(DB_PORT, 3306).
-define(DB_USER, "root").
-define(DB_PASS, "147258").
-define(DB_NAME, "qgqc").
-define(DB_ENCODE, utf8).
-include("config_db_def.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%



%%
%% Local Functions
%%
conn()->
	mysql:start_link(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, fun(_, _, _, _) -> ok end, ?DB_ENCODE),
	mysql:connect(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, ?DB_ENCODE, true),
%% 	mysql:fetch(?DB,<<"truncate table achieve_proto">>),
	ok.
select_table_data_info()->
	Sql="select * from achieve_proto",
	mysql:fetch(?DB, Sql) .