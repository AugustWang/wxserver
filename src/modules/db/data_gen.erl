%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-15
%% Description: TODO: Add description to data_gen
-module(data_gen).
-compile(export_all).

-include("mnesia_table_def.hrl").
%%
%% Include files
%%
%%
%% Exported Functions
%%
%%
%% API Functions: add reginfo
%%
%%
import_config(FileName,Tables)->
	File = "../config/"++ FileName ++ ".config",
	proto_import:import(File,Tables).

import_config(FileName)->
	%%import creature_spwans first
	npc_db:import_creature_spawns("../config/creature_spawns.config"),	
	File = "../config/"++ FileName ++ ".config",
	slogger:msg("now clear table =========================~n"),
	case file:open(File, [read]) of
		{ok,Fd}-> clear_table_loop([],Fd);
		{error,Reason}-> slogger:msg("open file error:~p~n",[Reason])
	end,
	slogger:msg("now import config from file:~p~n",[File]),
	recovery(File).

clear_table_loop(UsedTables,Fd)->
	case io:read(Fd,[]) of
		{ok,Term}->
			TableName = erlang:element(1,Term),
			case lists:member(TableName,UsedTables) of
				true->
					NewUsedTables = UsedTables;
				_->
					case mnesia:clear_table(TableName) of
						{atomic, ok}->
							NewUsedTables = [TableName|UsedTables];
						{aborted, R}->
							slogger:msg("clear table ~p error ~p ~n",[TableName,R]),
							NewUsedTables = UsedTables
					end
			end,
			clear_table_loop(NewUsedTables,Fd);
		eof->
			file:close(Fd);
		Error->
			slogger:msg("clear table loop error ~p ~n",[Error])	
	end.

backup(File)->
	slogger:msg("now backup data to file:~p~n",[File]),
	case file:open(File, [write,{encoding,utf8}]) of
		{ok,F}->
			NoTempTabs = get_backup_tablelist(),
			lists:foreach(fun(T)->
								 {atomic,_} = mnesia:transaction(fun() -> mnesia:foldl(fun(Term,_)-> io:format(F,"~w.~n",[Term]) end,[],T) end)
%%								  W = mnesia_lib:val({T, wild_pattern}),
%%								  {atomic,All} = mnesia:transaction(fun() -> mnesia:match_object(T, W, read) end),
%%								  lists:foreach(fun(Term) -> io:format(F,"~w.~n", [setelement(1, Term, T)]) end, All)
						  end,NoTempTabs),
			file:close(F),
			slogger:msg("Finish backup data to file:~p~n",[File]);
		{_,_}-> slogger:msg("dump to file failed: can not open file")
	end.
	
backup_table(File,Table)->
	slogger:msg("now backup ~p to file:~p~n",[Table,File]),
	case file:open(File, [append,{encoding,utf8}]) of
		{ok,F}->
			W = mnesia_lib:val({Table, wild_pattern}),
			{atomic,All} = mnesia:transaction(fun() -> mnesia:match_object(Table, W, read) end),
			lists:foreach(fun(Term) -> io:format(F,"~w.~n", [setelement(1, Term, Table)]) end, All),
			file:close(F),
			slogger:msg("Finish backup ~p to file:~p~n",[Table,File]);
		{_,_}-> slogger:msg("dump to file failed: can not open file")
	end.

get_backup_tablelist()->
	AllMnesiaTabs = mnesia_lib:local_active_tables(),
	FilterBackTabes = get_skip_tablelist(),
	BackTables = lists:filter(fun(Tx)-> not lists:member(Tx, FilterBackTabes)  end, AllMnesiaTabs),
	BackTables.

get_skip_tablelist()->
	db_operater_mod:get_backup_filter_tables()++[schema].

do_consult(Fd,LastResult,TermCount,LastTable)->
	case io:read(Fd,'') of
		{error,Reason}->
		 	slogger:msg("reovery_from failed:~p ,rec no:~p~n",[Reason,TermCount+1]),
		 	file:close(Fd);
		eof ->
			%% do write!!!==========================
			write_list_ets_hack(LastResult),
			if
				LastTable=/=[]->
					safe_change_table_type(LastTable, node(), disc_copies);
				true->
					nothing
			end,
			{_, Duarion} = statistics(wall_clock),
			slogger:msg("Finish recovery cost time:~p recordcount:~p ~n",[Duarion,TermCount]),
			file:close(Fd);
		{ok,Term}->
			NewTable = element(1,Term),
			if
				LastTable=:=[]->
					safe_change_table_type(NewTable,node(),ram_copies),
					do_consult(Fd,[Term|LastResult],TermCount+1,NewTable);
				(LastTable=/=[]) and (NewTable=/=LastTable)->
					%% do write!!!==========================
					write_list_ets_hack(LastResult),
					safe_change_table_type(LastTable, node(), disc_copies),
					safe_change_table_type(NewTable,node(),ram_copies),
					do_consult(Fd,[Term],TermCount+1,NewTable);
			   	length(LastResult) < 300->
					do_consult(Fd,[Term|LastResult],TermCount+1,NewTable);
			  	true->
			  		%% do write!!!==========================
					write_list_ets_hack([Term|LastResult]),
					do_consult(Fd,[],TermCount+1,NewTable)
			end	
	end.

recovery(File)->
	statistics(wall_clock),
	case file:open(File,[read]) of
		{ok,Fd}-> do_consult(Fd,[],0,[]);
		{error,Reason}-> slogger:msg("Consult error:~p~n",[Reason])
	end.

write_list_ets_hack(LastResult)->
	mnesia:ets(fun()-> [write_data_one_ets_hack(Term) || Term <- LastResult] end). 
	
write_table_data(L)->
	[write_data_one(Term) || Term <- L]. 

write_data_one_ets_hack(Term)->
	Table = element(1,Term),
	case catch mnesia:dirty_write(Term) of
		ok->
			ok;
		{'EXIT',{aborted,Reason}}->
			case is_miss_table_reason(Reason) of
				{true,Table}->
					slogger:msg("no table Table ~p ,create~n",[Table]),
					case db_split:create_split_table_by_name(Table) of
						error -> 
							ignor;
						ok->
							Re =
							try 
								mnesia:dirty_write(Term)
							catch
								_E:Error->
									Error	
							end,
							slogger:msg("no table: ~p ,create and write ~p ~n",[Table,Re])
					end;
				_->	
					slogger:msg("write_data_one_ets_hack ~p error ~p ~n",[Term,Reason]),
					ignor	
			end;
		Errno->	
			slogger:msg("write_data_one_ets_hack ~p error ~p ~n",[Term,Errno]),
			ignor
	end.

write_data_one(Term)->
	case catch mnesia:dirty_write(Term) of
		ok->
			ok;
		{'EXIT',{aborted,Reason}}->
			case is_miss_table_reason(Reason) of
				{true,Table}->
					case db_split:create_split_table_by_name(Table) of
						error -> 
							ignor;
						ok->
							Re =
							try 
								mnesia:dirty_write(Term)
							catch
								_E:Error->
									Error	
							end,
							slogger:msg("no table: ~p ,create and write ~p ~n",[Table,Re])
					end;
				_->	
					slogger:msg("write_table_data ~p error ~p ~n",[Term,Reason]),
					ignor
			end
	end.
	
is_table_no_exsit(Table)->
	case catch mnesia:table_info(Table,wild_pattern) of
		{'EXIT',{aborted,{no_exists,Table,_}}}->
			true;
		_->
			false
	end.	
		
is_miss_table_reason(Reason)->
	case Reason of				
		{no_exists,Table}->
			{true,Table};
		{bad_type,BadTerm}->
			Table = element(1,BadTerm),	
			case is_table_no_exsit(Table) of
				true->
					{true,Table};
				_->
					false
			end;
		_->
			false	
	end.		

backup_ext(File)->
	case mnesia:backup(File,[]) of
		ok->
			slogger:msg("backup data success!!!  file ~p~n",[File]);
		{error,R}->
			slogger:msg("backup data faild!!! ~p~n",[R]);
		Other->
			slogger:msg("backup data faild!!! ~p~n",[Other])
	end.

recovery_ext(File)->
	SkipTables = get_skip_tablelist(),
	slogger:msg("recovery_ext begin:~p~n",[File]),
	RestoreFun = 
			fun(Term,Acc)->
				CheckKey = element(1,Term),
				case lists:member(CheckKey,SkipTables) of 
					true->
						NewAcc = Acc;		
					_->
						NewAcc = Acc ++ [Term]		
				end,
				Length = length(NewAcc),
				if
					Length >= 300->
						write_table_data(NewAcc),
						{[Term],[]};
					true->			
						{[Term],NewAcc}
				end
			end,
	case mnesia:traverse_backup(File,mnesia_backup,dummy,read_only,RestoreFun,[]) of
		{ok,[]}->
			nothing;
		{ok,Terms}->
			write_table_data(Terms);
		R->
			slogger:msg("recovery_ext ret ~p~n",[R])	
	end,
	slogger:msg("recovery_ext finish!!!~n").			



safe_change_table_type(NewTable,Node,Type)->
	case mnesia:change_table_copy_type(NewTable,Node, Type) of
		{aborted,Reason}->
			case is_miss_table_reason(Reason) of
				{true,Table}->
					slogger:msg("no table Table ~p ,create~n",[Table]),
					case db_split:create_split_table_by_name(Table) of
						error -> 
							ignor;
						ok->
							safe_change_table_type(NewTable,Node,Type)
  					end;
				_->
					slogger:msg("mnesia:change_table_copy_type Error ~p Reason ~p ~n",[{NewTable,Node, Type},Reason])
			end;
		{atomic, ok}->
			nothing
	end.
