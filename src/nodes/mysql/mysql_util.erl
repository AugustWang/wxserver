%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx-win7
%% Created: 2011-9-1
%% Description: TODO: Add description to mysql_util
-module(mysql_util).

%%
%% Include files
%%
-include("mysql.hrl").
-define(TRANSACTION_TIMEOUT, 60000). % milliseconds
-define(KEEPALIVE_TIMEOUT, 60000).
-define(KEEPALIVE_QUERY, "SELECT 1;").
-define(MYSQL_ENCODING, "set names 'utf8';").

%%
%% Exported Functions
%%
-export([handle_fetch/1,
		 get_pool/0,
		 fetch/1,fetch/2,
		 fetch_transaction/1,
		 fetch_transaction/2,
		 escape/1,
	 	 escape_like/1,
		 keep_alive/0]).

%%
%% API Functions
%%
-define(DEF_POOLID,pmxy_pool).

%%
%% Local Functions
%%
handle_fetch(OrgResult)->
	{R,Result} = OrgResult,
	case R of
		data -> Result#mysql_result.rows;
		update->[];
		error->[]
	end.

get_pool()->
	?DEF_POOLID.

fetch(Query)->
	Result = mysql:fetch(?DEF_POOLID,Query),
    slogger:msg("fetch info===========================:~p~n",[Result]),
	mysql_to_term(Result).

fetch(Query,Timeout)->
	Result = mysql:fetch(?DEF_POOLID,Query,Timeout),
	mysql_to_term(Result).

fetch_transaction(Fun)->
	Result = mysql:transaction(?DEF_POOLID, Fun),
	mysql_to_term(Result).

fetch_transaction(Fun,Timeout)->
	Result = mysql:transaction(?DEF_POOLID, Fun, Timeout),
	mysql_to_term(Result).

keep_alive()->
	ok.

%% Convert MySQL query result to Erlang ODBC result formalism

mysql_to_term({updated, MySQLRes}) ->
    {updated, mysql:get_result_affected_rows(MySQLRes)};
mysql_to_term({data, MySQLRes}) ->
    mysql_item_to_term(mysql:get_result_field_info(MySQLRes),
		       mysql:get_result_rows(MySQLRes));
mysql_to_term({error, MySQLRes}) when is_list(MySQLRes) ->
    {error, MySQLRes};
mysql_to_term({error, MySQLRes}) ->
    {error, mysql:get_result_reason(MySQLRes)}.

	

%% When tabular data is returned, convert it to the ODBC formalism
mysql_item_to_term(Columns, Recs) ->
    %% For now, there is a bug and we do not get the correct value from MySQL
    %% module:
    {selected,
     [element(2, Column) || Column <- Columns],
     [list_to_tuple(Rec) || Rec <- Recs]}.

%% Escape character that will confuse an SQL engine
escape(S) when is_list(S) ->
    [mysql_queries:escape(C) || C <- S];
escape(S) when is_binary(S) ->
    escape(binary_to_list(S)).

%% Escape character that will confuse an SQL engine
%% Percent and underscore only need to be escaped for pattern matching like
%% statement
escape_like(S) when is_list(S) ->
    [escape_like(C) || C <- S];
escape_like($%) -> "\\%";
escape_like($_) -> "\\_";
escape_like(C)  -> mysql_queries:escape(C).


