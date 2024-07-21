%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(gen_code_dir).

-export([gen_code_dir/0]).

-define(CONFIG_FILE,"../.settings/org.erlide.core.prefs").

gen_code_dir()->
	Name = "../src",
	AllNames = get_code_dir(Name),
	NewAllPath = 
	lists:foldl(fun(NameTmp,AccNameStr)->
					AccNameStr++";"++(NameTmp -- "../")	
				end,Name--"../", AllNames),
	OriAllLines = get_file_all_line(),
	backup_lines(OriAllLines),
	replace_and_write_path(OriAllLines,NewAllPath),
	io:format("refresh finish ~n").

get_file_all_line()->
	case file:open(?CONFIG_FILE,[read]) of
		{ok,F}->
			read_file_loop(F);
		{error,Reason}-> io:format("open file ~p error: ~p ~n",[?CONFIG_FILE,Reason])
	end.

read_file_loop(F)->
	case file:read_line(F) of
		{ok,Data}->
			[Data|read_file_loop(F)];
		eof->
			file:close(F),
			[];
		Error->
			slogger:error("read error ~p ~n",[Error]),
			file:close(F),
			[]
	end.
		
backup_lines(OriAllLines)->
	case file:open(?CONFIG_FILE++"_bck",[write]) of
		{ok,F}->
			lists:foreach(fun(OneLine)->file:write(F,OneLine) end, OriAllLines),
			file:close(F);
		{error,Reason}-> io:format("open file ~p error: ~p ~n",[?CONFIG_FILE++"_bck",Reason])
	end.
	
replace_and_write_path(OriAllLines,NewAllPath)->
	case file:open(?CONFIG_FILE,[write]) of
		{ok,F}->
			replace_write_loop(F,OriAllLines,NewAllPath);
		{error,Reason}-> io:format("open file ~p error: ~p ~n",[?CONFIG_FILE,Reason])
	end.

replace_write_loop(F,[],_)->
  	file:close(F);
replace_write_loop(F,[Data|T],NewAllPath)->
	NewLine = 
	case list_util:is_part_of("source_dirs=",Data) of
		true->
			"source_dirs="++NewAllPath++"\n";
		_->
			Data
	end,
	file:write(F,NewLine),
	replace_write_loop(F,T,NewAllPath).
		
get_code_dir(Name)->
	{ok,DirList} = file:list_dir(Name),
	NewDirList = 
		lists:foldl(fun(DirTmp,AccDir)->
				if 
					DirTmp=/= ".svn"->
						Newdir = Name++"/"++DirTmp,
						case filelib:is_dir(Newdir) of
							true->
								[Newdir|AccDir];
							_->
								AccDir
						end;
					true->
						AccDir
				end end,[],DirList),
	NewDirList++lists:foldl(fun(DirTmp,AccTmp)-> get_code_dir(DirTmp)++AccTmp end,[],NewDirList).
		
