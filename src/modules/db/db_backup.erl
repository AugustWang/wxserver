%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(db_backup).

-export([backup/1,recovery/1,translate_to_readable/2,read_term_from_binarys/2]).

-define(BLOCK_HEADER_SIZE,16).
-define(BLOCK_HEADER_BYTE_SIZE,2).

backup(File)->
	slogger:msg("now backup data to file:~p~n",[File]),
	case file:open(File, [write,binary]) of
		{ok,F}->
			NoTempTabs = data_gen:get_backup_tablelist(),
			lists:foreach(fun(T)->
								 {atomic,_} = mnesia:transaction(fun() -> mnesia:foldl(fun(Term,_)-> 
									Bin = erlang:term_to_binary(Term),Size = size(Bin), file:write(F,<< <<Size:?BLOCK_HEADER_SIZE/big>>/binary,Bin/binary>>) end,[],T) end)
						  end,NoTempTabs),
			file:close(F),
			slogger:msg("Finish backup data to file:~p~n",[File]);
		{_,_}-> slogger:msg("dump to file failed: can not open file")
	end.

recovery(File)->
	statistics(wall_clock),
	case file:read_file(File) of
		{ok,Binarys}-> do_consult(Binarys,[],0,[],0);
		{error,Reason}-> slogger:msg("Consult error:~p~n",[Reason])
	end.

translate_to_readable(FileIn,FileOut)->
	case file:open(FileOut, [write,binary]) of 
		{ok,Fout}->
			case file:read_file(FileIn) of
				{ok,Binarys}-> do_translate(Binarys,0,Fout,0);
				{error,Reason}-> slogger:msg("Consult error:~p~n",[Reason])
			end;
		{error,Reason}-> slogger:msg("Consult error:~p~n",[Reason])
	end.
		
read_term_from_binarys(Binarys,Start)->
	case Binarys of
		<<_:Start/binary,Len:?BLOCK_HEADER_SIZE/big,NewTermBin:Len/binary,_/binary>>->
			{ok,binary_to_term(NewTermBin),Start+Len+?BLOCK_HEADER_BYTE_SIZE};
		<<_:Start/binary,_:0/binary>>->
			eof;
		_->
			{error,read_term_error}
	end.

do_consult(Binarys,LastResult,TermCount,LastTable,Start)->
	case read_term_from_binarys(Binarys,Start) of
		{error,Reason}->
		 	slogger:msg("reovery_from failed:~p ,rec no:~p~n",[Reason,TermCount+1]);
		eof ->
			%% do write!!!==========================
			data_gen:write_list_ets_hack(LastResult),
			if
				LastTable=/=[]->
					mnesia:change_table_copy_type(LastTable, node(), disc_copies);
				true->
					nothing
			end,
			{_, Duarion} = statistics(wall_clock),
			slogger:msg("Finish recovery cost time:~p recordcount:~p ~n",[Duarion,TermCount]);
		{ok,Term,NewStart}->
			NewTable = element(1,Term),
			if
				LastTable=:=[]->
					mnesia:change_table_copy_type(NewTable,node(),ram_copies),
					do_consult(Binarys,[Term|LastResult],TermCount+1,NewTable,NewStart);
				(LastTable=/=[]) and (NewTable=/=LastTable)->
					%% do write!!!==========================
					data_gen:write_list_ets_hack(LastResult),
					mnesia:change_table_copy_type(LastTable, node(), disc_copies),
					mnesia:change_table_copy_type(NewTable,node(),ram_copies),
					do_consult(Binarys,[Term],TermCount+1,NewTable,NewStart);
			   	length(LastResult) < 300->
					do_consult(Binarys,[Term|LastResult],TermCount+1,NewTable,NewStart);
			  	true->
			  		%% do write!!!==========================
					data_gen:write_list_ets_hack([Term|LastResult]),
					do_consult(Binarys,[],TermCount+1,NewTable,NewStart)
			end	
	end.

do_translate(Binarys,TermCount,Fout,Start)->
	case read_term_from_binarys(Binarys,Start) of
		{error,Reason}->
		 	slogger:msg("reovery_from failed:~p ,rec no:~p~n",[Reason,TermCount+1]);
		eof ->
			file:close(Fout);
		{ok,Term,NewStart}->
			io:format(Fout,"~w.~n",[Term]),
			do_translate(Binarys,TermCount+1,Fout,NewStart)
	end.