%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(combin_server).
-export([backup/1,clear_loop_tower_rank/0]).
-export([recovery/1]).
-include("game_rank_define.hrl").
-define(SERVER_TAG_STRING,erlang:integer_to_list(env:get(serverid,0))++"_"++erlang:integer_to_list(calendar:time_to_seconds(now()))).
-define(BEFORE_COMBIN_BACK_FILE,"../combinout/before_combin_server_backup_"++?SERVER_TAG_STRING++".bck").
-define(COMBIN_DELETE_ROLE_IDS,"../combinout/deleted_roleids_for_combin_"++?SERVER_TAG_STRING++".bck").
-define(COMBIN_RENAME_IDS_FILE,"../combinout/rename_guild_and_role_for_combin_"++?SERVER_TAG_STRING++".bck").
-define(REPEATED_NAME_ETS,repeated_name_ets).
-define(COMBIN_RENAME_ETS,combin_rename_ets).

backup(FileName)->
	%% 1. backup before combin
	slogger:msg("start before combin backup wait... ~n"),
	db_backup:backup(?BEFORE_COMBIN_BACK_FILE),
	slogger:msg("before combin backup end,file in ~p ~n",[?BEFORE_COMBIN_BACK_FILE]),
	%% 2. dong clear before combin
	on_combin_server_doing(),
	%% 5. backup to file
	slogger:msg("start combin_server_backup wait... ~n"),
	db_backup:backup(FileName),
	slogger:msg("combin_server_backup end,file:~p ~n",[FileName]).

recovery(FileNameOrNames)->
	%% 1. backup before combin in cur server
	slogger:msg("start before combin backup wait... ~n"),
	db_backup:backup(?BEFORE_COMBIN_BACK_FILE),
	slogger:msg("before combin backup end,file in ~p ~n",[?BEFORE_COMBIN_BACK_FILE]),
	%% 2. dong clear before combin
	on_combin_server_doing(),
	%% 2. create name ets
	ets:new(?REPEATED_NAME_ETS, [named_table,set]),
	ets:new(?COMBIN_RENAME_ETS, [named_table,set]),
	%% 3. build name ets for cur server
	slogger:msg("start build rename name table ...~n"),
	build_exsit_name_ets(),
	%% 4. porc combin from file
	combin_server_from_file_or_files(FileNameOrNames),
	slogger:msg("build rename name table end~n"),
	proc_rename_after_import(),
	ets:delete(?REPEATED_NAME_ETS),
	ets:delete(?COMBIN_RENAME_ETS),
	slogger:msg("combin server finished !!!!!!!!~n").


on_combin_server_doing()->
	%% 1. delete unused roles
	slogger:msg("start delete unuesd roles,wait... ~n"),
	AllRoles = db_game_util:delete_all_unuesd_role(),
	case file:open(?COMBIN_DELETE_ROLE_IDS, [write,{encoding,utf8}]) of
		{ok,F}->
			io:format(F,"=============================delete roles==============================~n",[]),
			io:format(F,"~w.~n",[AllRoles]),
			file:close(F),
			slogger:msg("delete unuesd roles end ,deleted ids save in file ~p ~n",[?COMBIN_DELETE_ROLE_IDS]);
		_->
			slogger:msg("failed open ~p ~n",[?COMBIN_DELETE_ROLE_IDS])
	end,
	%% 2. clear tangle_battle 
	mnesia:clear_table(tangle_battle),
	%% 3. clear country
	mnesia:clear_table(country_record),
	%% 4. clear freash card
	mnesia:clear_table(giftcards),
	%% 5. clear game_rank looptower
	clear_loop_tower_rank(),
	clear_pet_rank(),
	clear_mainline_rank(),
	%% 6. clear gm_notice
	mnesia:clear_table(gm_notice).
	
build_exsit_name_ets()->
	Tables = db_split:get_table_names(roleattr)++[guild_baseinfo],
	lists:foreach(fun(Table)-> 
					{atomic,_} = mnesia:transaction(fun() -> mnesia:foldl(fun(Term,_)-> build_rename_ets_proc(Term) end,[], Table) end) 						  
				 end, Tables).

combin_server_from_file_or_files(FileNameOrNames)->
	[FileNameOrChar|_] = FileNameOrNames,
	case is_list(FileNameOrChar) of
		true->
			lists:foreach(fun(FileName)->
							combin_server_from_file(FileName)	  
						end, FileNameOrNames);
		_->
			combin_server_from_file(FileNameOrNames)
	end.
	
combin_server_from_file(FileName)->
	slogger:msg("start combin from_file ~p ,wait... ~n",[FileName]),
	case file:read_file(FileName) of
		{ok,Binarys}->
			proc_combin_file_loop(Binarys,[],[],0);
		Error->
			slogger:msg("read file FileName ~p ~p~n",[Error])
	end.

proc_combin_file_loop(Binarys,LastResult,LastTable,Start)->
	case db_backup:read_term_from_binarys(Binarys,Start) of
		{ok,OriTerm,NewStart}->
			Term = trans_combin_server_data(OriTerm),
			build_rename_ets_proc(Term),
			NewTable = element(1,Term),
			if
				LastTable=:=[]->
					data_gen:safe_change_table_type(NewTable,node(),ram_copies),
					proc_combin_file_loop(Binarys,[Term|LastResult],NewTable,NewStart);
				(LastTable=/=[]) and (NewTable=/=LastTable)->
					%% do write!!!==========================
					data_gen:write_list_ets_hack(LastResult),
					data_gen:safe_change_table_type(LastTable, node(), disc_copies),
					data_gen:safe_change_table_type(NewTable,node(),ram_copies),
					proc_combin_file_loop(Binarys,[Term],NewTable,NewStart);
			   	length(LastResult) < 300->
					proc_combin_file_loop(Binarys,[Term|LastResult],NewTable,NewStart);
			  	true->
					%% do write!!!==========================
					data_gen:write_list_ets_hack([Term|LastResult]),
					proc_combin_file_loop(Binarys,[],NewTable,NewStart)
			end;
		eof ->
			%% do write!!!==========================
			data_gen:write_list_ets_hack(LastResult),
			if
				LastTable=/=[]->
					data_gen:safe_change_table_type(LastTable, node(), disc_copies);
				true->
					nothing
			end;
		Reason-> 
			slogger:msg("proc_combin_file_loop failed:~p ~n",[Reason])
	end.

trans_combin_server_data({account,Account,RoleList,Gold}=Term)->
	case dal:read(account,Account) of
		{ok,[AccountRole]}->
			OriRoleList = role_db:get_account_roleids(AccountRole),
			OriGold = role_db:get_account_gold(AccountRole),
			{account,Account,OriRoleList++RoleList,OriGold+Gold};
		_->
			Term
	end;
trans_combin_server_data(Term)->
	Term.

build_rename_ets_proc(Term)->
	TableName = erlang:element(1, Term),
	case atom_to_list(TableName) of
		"roleattr_"++_->
			combin_to_name_ets(role,role_db:get_roleid(Term),role_db:get_name(Term),role_db:get_level(Term));
		"guild_baseinfo"->
			combin_to_name_ets(guild,guild_spawn_db:get_guild_id(Term),list_to_binary(guild_spawn_db:get_guild_name(Term)),guild_spawn_db:get_guild_level(Term));
		_->
			nothing
	end.

combin_to_name_ets(Type,Id,Name,Level)->
	case ets:lookup(?REPEATED_NAME_ETS,{Type,Name}) of
		[]->
			ets:insert(?REPEATED_NAME_ETS,{{Type,Name},[{Id,Level}]});
		[{_,OriInfo}]->
			ets:insert(?REPEATED_NAME_ETS,{{Type,Name},OriInfo++[{Id,Level}]})
	end.
		
proc_rename_after_import()->
	ets:foldl(fun({{Type,Name},NameList},_)->
				case NameList of
					[_]->
						nothing;
					NameList->
						[_|T] = lists:reverse(lists:keysort(2, NameList)),
						rename_repeated_list(Type,Name,T)						
				end	
			end,[],?REPEATED_NAME_ETS),
	{ok,F} = file:open(?COMBIN_RENAME_IDS_FILE, [write,binary]),
	ets:foldl(fun({Id,Type,Name,NewName},_)->
			try
				IdStr = 
						if
							is_integer(Id)->
								erlang:integer_to_list(Id);
							true->
								{H,L} = Id,
								"{" ++ integer_to_list(H) ++"," ++ integer_to_list(L) ++"}"
						end,
				file:write(F, list_to_binary(IdStr ++ ","
												++ erlang:atom_to_list(Type) ++ "," 
												++ util:escape_uri(Name) ++ "," 
												++ util:escape_uri(NewName) ++ "\n")),	  
				case Type of
					role->
						db_game_util:rename_role_in_db(Id,NewName);
					guild->
						db_game_util:rename_guild_in_db(Id,binary_to_list(NewName))
				end
			catch
					E:R->
						slogger:msg("error E:~p R:~p S:~p ~n",[E,R,erlang:get_stacktrace()])
			end
			end,[],?COMBIN_RENAME_ETS),
	file:close(F),
	slogger:msg("rename over,save rename info in ~p ~n",[?COMBIN_RENAME_IDS_FILE]).

rename_repeated_list(Type,Name,RepeatedList)->
	lists:foldl(fun({Id,_Level},Index)-> 
						{NewName,NewIndex} = get_unrepead_name(Type,Name,Index),
						ets:insert(?COMBIN_RENAME_ETS,{Id,Type,Name,NewName}),
						NewIndex
					end,1,RepeatedList).

%%return {NewName,NewIndex}
get_unrepead_name(Type,Name,Index)->
	NewName = erlang:list_to_binary(erlang:binary_to_list(Name) ++ "[" ++ erlang:integer_to_list(Index) ++ "]"),
	case ets:lookup(?REPEATED_NAME_ETS,{Type,NewName}) of
		[]->
			{NewName,Index+1};
		_->
			get_unrepead_name(Type,Name,Index+1)
	end.
	
clear_loop_tower_rank()->
	DbData = game_rank_db:load_from_db(),
	lists:foreach(fun({{Type,RoleId},RankInfo,Time})->
						  case Type =:= ?RANK_TYPE_LOOP_TOWER_MASTER of
							  true->
								  dal:delete_object({game_rank_db,{Type,RoleId},RankInfo,Time});
							  _->
								  nothing
						  end
					end,DbData).

clear_pet_rank()->
	DbData = game_rank_db:load_from_db(),
	lists:foreach(fun({{Type,RoleId},RankInfo,Time})->
						  case Type =:= ?RANK_TYPE_PET_TALENT_SCORE of
							  true->
								  dal:delete_object({game_rank_db,{Type,RoleId},RankInfo,Time});
							  _->
								  nothing
						  end
					end,DbData).

clear_mainline_rank()->
	DbData = game_rank_db:load_from_db(),
	lists:foreach(fun({{Type,RoleId},RankInfo,Time})->
						  case Type of
							  {?RANK_TYPE_MAIN_LINE,_}->
								  dal:delete_object({game_rank_db,{Type,RoleId},RankInfo,Time});
							  _->
								  nothing
						  end
					end,DbData).
	
	
	
	
	
	
	
	
	
	
	
	