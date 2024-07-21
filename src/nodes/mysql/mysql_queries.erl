%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-9-6
%% Description: TODO: Add description to mysql_queries
-module(mysql_queries).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([insert/1,
		 insert/3,
		 insert_log_exclude_fiels/2,
		 insert_log_batched/3,
		 insert_log_batched_exclude_fiels/2,
		 update_t/4,
		 update/4,
		 escape/1]).

%%
%% API Functions
%%
insert(Query)->
	mysql_util:fetch(Query).

insert(Table, Fields, Vals)->
	case mysql_util:fetch(["insert into ", Table, "(", string:join(Fields, ", "),
	       ") values ('", string:join(Vals, "', '"), "');"]) of
		{updated,_AffectedRows}->
			ok;
		{data,_}->
			ok;
		{error,Reason}->
			slogger:msg("mysql_queries insert/3 error:~p=~p~n",[Table,Reason])
	end.

insert_log_exclude_fiels(Table,Vals)->
	case mysql_util:fetch(["insert into ", Table, " values ('", 
					  string:join(Vals, "', '"), "');"]) of
		{updated,_AffectedRows}->
			ok;
		{data,_}->
			ok;
		{error,Reason}->
			slogger:msg("insert_log_exclude_fiels error:~p=~p~n",[Table,Reason])
	end.

insert_log_batched(Table,Fields,ValsList)->
	BatchedFun = fun(Vals,Acc)->
						Acc++"('"++string:join(Vals, "', '")++"'),"
				 end,
	ValsString = lists:foldl(BatchedFun, [], ValsList),
	ValsString2 = string:substr(ValsString,1, length(ValsString)-1),
	case mysql_util:fetch(["insert into ", Table, "(", string:join(Fields, ", "),
	       ") values ", ValsString2, ";"]) of
		{updated,AffectedRows}->
			ok;
		{data,_}->
			ok;
		{error,Reason}->
			slogger:msg("insert_log_batched error:~p=~p~n",[Table,Reason])
	end.

insert_log_batched_exclude_fiels(Table,ValsList)->
	%io:format("@@@@@@@@@@@@@  ~p   ~p~n",[Table,ValsList]),
	BatchedFun = fun(Vals,Acc)->
						Acc++"('"++string:join(Vals, "', '")++"'),"
				 end,
	ValsString = lists:foldl(BatchedFun, [], ValsList),
	ValsString2 = string:substr(ValsString,1, length(ValsString)-1),
	case mysql_util:fetch(["insert into ", Table,
	       " values ", ValsString2, ";"]) of
		{updated,AffectedRows}->
			ok;
		{data,_}->
			ok;
		{error,Reason}->
			slogger:msg("insert_log_batched_exclude_fiels error:~p=~p~n",
						[Table,Reason])
	end.

update_t(Table, Fields, Vals, Where) ->
    UPairs = lists:zipwith(fun(A, B) -> A ++ "='" ++ B ++ "'" end,
			   Fields, Vals),
    case mysql_util:fetch_transaction(
	   ["update ", Table, " set ",
	    string:join(UPairs, ", "),
	    " where ", Where, ";"]) of
	{updated, 1} ->
	    ok;
	{error,Reason}->
		slogger:msg("update_t/4 error:~p=~p~n",
						[Table,Reason]);
	_ ->
	    ok
    end.

update(Table, Fields, Vals, Where) ->
    UPairs = lists:zipwith(fun(A, B) -> A ++ "='" ++ B ++ "'" end,
			   Fields, Vals),
    case mysql_util:fetch(
	   ["update ", Table, " set ",
	    string:join(UPairs, ", "),
	    " where ", Where, ";"]) of
	{updated, 1} ->
	    ok;
	{error,Reason}->
		slogger:msg("update_t/4 error:~p=~p~n",
						[Table,Reason]);
	_ ->
	    ok
    end.

%% Characters to escape
escape($\0) -> "\\0";
escape($\n) -> "\\n";
escape($\t) -> "\\t";
escape($\b) -> "\\b";
escape($\r) -> "\\r";
escape($')  -> "\\'";
escape($")  -> "\\\"";
escape($\\) -> "\\\\";
escape(C)   -> C.
%%
%% Local Functions
%%

