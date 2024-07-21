%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-6-7
%% Description: TODO: Add description to mysql_config_db
-module(mysql_config_db).

%% Author: yanzengyan
%% Created: 2012-7-18
%% Description: ç”Ÿæˆé…ç½®æ–‡ä»¶æ•°æ®åº“

%%
%% Include files
%%
-include("config_db_def.hrl").
%%
%% Exported Functions
%%
-export([run/0]).



run() ->
	mysql_test:conn(),
 	gen_game_db(),
	gen_creature_db(),
	%mysql_test:create_table(achieve_proto,record_info(fields,achieve_proto)),
	io:format("yanzengyan, process finished!!!~n").

gen_game_db() ->
	FileName = "../config/game.config",
	case file:open(FileName,[read]) of 
		{ok,Fd}->
			write_game_db(Fd);
		{error,Reason}-> 
			slogger:msg("Consult error:~p~n",[Reason])
	end.

write_game_db_old_zt(Fd) ->
	case io:read(Fd,'') of
		{error,Reason}->
		 	slogger:msg("reovery_from failed: ~p~n",[Reason]),
		 	file:close(Fd);
		eof ->
			file:close(Fd);
		{ok,Term}->
%% 			io:format("yanzengyan, Term: ~p~n", [Term]),
           if  element(1,Term) =:= continuous_logging_gift ->
				  io:format("continuous_logging_op:init_data() 02 Item:~p~n",[Term]),
				  if erlang:size(Term)=:=3 -> 
					   dal:write( erlang:append_element(Term,[]));
					   true->	 
						   dal:write(Term)
				  end;	 
			 true->
    		 	 	dal:write(Term)
            end,           
			 write_game_db(Fd),
			 ok
	end.

write_game_db(Fd) ->
	case io:read(Fd,'') of
		{error,Reason}->
		 	slogger:msg("reovery_from failed: ~p~n",[Reason]),
		 	file:close(Fd);
		eof ->
			file:close(Fd);
		{ok,Term}->
			mysql_change:write_term(Term),
			write_game_db(Fd),
			 ok
	end.


gen_creature_db() ->
	FileName = "../config/creature_spawns.config",
	case file:consult(FileName) of
		{ok,[Terms]}->
			lists:foreach(fun(Term)->add_creature_spawns_to_mnesia(Term)
						  end,Terms);
		{error,Reason} ->
			slogger:msg("import_creature_spawns error:~p~n",[Reason])
	end.

add_creature_spawns_to_mnesia(Term)->
	try
		NewTerm = list_to_tuple([creature_spawns|tuple_to_list(Term)]),
		mysql_change:write_term(NewTerm)
		%create_mysql_table:create_table_proto(NewTerm)
	catch
		E:R-> io:format("Reason ~p: ~p~n",[E,R]),error
	end.


	




