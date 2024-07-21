%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(gen_db_code).

-export([gen_db_code/2]).
-compile(export_all).


%% @... is args for table operator.
%% required args: 1.stroe type(disc_split/disc/ram/proto) 2.table type(set/bag)
%% not necessary args: 
%%			1.key:[xxx,yyy] is used for proto db whose type is bag. {xxx,yyy} will be the key to read tuple from ets.
%%			2.index:[xxx,yyy] is used for create db index xxx,yyy.but not auto build index_read code,user should write youself.  dal:read_index_rpc(....).


%% file format example,can use chinese:

%%							../include/db_test_def.hrl
%% -record(gm_blockade_proto,		%%table gm_blockade_proto
%% 		{roleid_type,				%%dddas
%% 		 start_time,				%%aa
%% 		duration_time				%%chinese...
%% 		}).							%%@index:[duration_time],proto,set
%% -record(gm_blockade_proto2,{roleid_type,start_time,duration_time}).					%%@proto,bag,key:[roleid_type,start_time]
%% -record(gm_blockade2,{roleid_type,start_time,duration_timea,a,d,f,wq,w}).			%%@disc_split,set,index:[d,f]
%% -record(gm_blockade3,{roleid_type,start_time,duration_timea,a,d,f,wq,w}).			%%@ram,set
%% -record(gm_blockade4,{roleid_type,start_time,duration_timea,a,d,f,wq,w}).			%%@ram,set
%% -record(gm_blockade5,{roleid_type,start_time,duration_timea,a,d,f,wq,w}).			%%@disc,bag,key:[roleid_type,start_time],index:[wq]
%% -record(gm_blockade6,{roleid_type,start_time,duration_timea,a,d,f,wq,w}).			%%@disc,set

%%usage:		gen_db_code:gen_db_code("db_test_def.hrl",db_test_db). 		will create ERL_SRC_CREATE_DIR/db_test_db.erl			


-define(HRL_INCLUDE_DIR,"../include/").
-define(ERL_SRC_CREATE_DIR,"../src/db_mods/").

%%recordname:				dbname
%%field:					fieldsname
%%type:						set/bag
%%stroe_type:				disc_split/disc/ram/proto
%%args:						key:[xxx,yyy]/index:[xxx,yyy]
-record(db_record,{recordname,field,type,stroe_type,args}).

-define(TYPES,[set,bag]).
-define(STROE_TYPES,[disc_split,disc,ram,proto]).
-define(BLANK,$\ ).
-define(ENTER,$\n).
-define(TAB,$\t).

gen_db_code(HrlFile,OutMod)->
	File = ?HRL_INCLUDE_DIR ++ HrlFile,
	OutFileName = erlang:atom_to_list(OutMod)++".erl",
	OutFile = ?ERL_SRC_CREATE_DIR++OutFileName,
	case file:open(File,[read]) of
		{ok,F}->
			AllRecord = read_all_record(F),
 			case write_to_file(AllRecord,OutFile,OutMod,HrlFile) of
				{error,exsit}->
					io:format("OutFile ~p is exist !!! not create again~n",[OutFile]);
				{error,Reason}->
					io:format("open file ~p error: ~p ~n",[OutFile,Reason]);
				ok->
					io:format("~p ~n",[AllRecord]),
					io:format("create file succese!!! OutFile: ~p ~n",[OutFile]),	
					file:close(F)
			end;
		{error,Reason}-> io:format("open file ~p error: ~p ~n",[File,Reason])
	end.
	
write_to_file(AllRecord,OutFile,OutMod,HrlFile)->	
	case filelib:is_file(OutFile) of
		true->
			{error,exsit};
		_->
			case file:open(OutFile, [write]) of
				{ok,F}->
					write_record_to_file(F,OutMod,AllRecord,HrlFile),
				  	file:close(F),
					ok;
				{error,Reason}->
					{error,Reason}
			end
	end.
		
	
write_record_to_file(F,OutMod,AllRecord,HrlFile)->
	file:write(F, get_file_str(OutMod,AllRecord,HrlFile)).
	
get_file_str(OutMod,AllRecord,HrlFile)->	
		"%%\n%% create by gen_db_code,you can edit it, especially use db index\n%%\n"++
		"-module(" ++ erlang:atom_to_list(OutMod) ++ ").\n\n"++
		"-include(\""++HrlFile++"\").\n\n"++
		make_table_define_str(AllRecord)++	
		make_records_export_str(AllRecord)++
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
		"%% 						behaviour export\n"
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
		"-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).\n\n"++
		make_ets_export_str(AllRecord)++
		"-behaviour(db_operater_mod).\n"	
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
		"%% 				behaviour functions\n"
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n"	
		"start()->\n"
		"	db_operater_mod:start_module(?MODULE,[]).\n\n"++
		make_records_create_str(AllRecord)				++
		"delete_role_from_db(_RoleId)->\n"
		"\ttodo.\n\n"
		"tables_info()->\n\t"++
		str_util:term_to_string(lists:map(fun(#db_record{recordname = Name,stroe_type = Type})->{Name,Type} end, AllRecord))++
		".\n\n"
		++make_ets_create_str(AllRecord)
		++make_ets_init_str(AllRecord)
		++
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
		"%% 				behaviour functions end\n"
		"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n"
		++make_dbfun_create_str(AllRecord).
		
	
make_ets_export_str(AllRecord)->
	case filter_records_by_store_type([proto],AllRecord) of
		[]->
			[];
		_->
			"-export([init/0,create/0]).\n\n-behaviour(ets_operater_mod).\n"
	end.

make_record_ets_name(#db_record{recordname = RecordName})->
  	atom_to_list(RecordName)++"_ets".
make_record_ets_define_name(Record)->
	string:to_upper(make_record_ets_name(Record)).

make_ram_table_name(#db_record{recordname = RecordName})->
	atom_to_list(RecordName).
make_ram_table_define(#db_record{recordname = RecordName})->
	string:to_upper(atom_to_list(RecordName)).
	
make_table_define_str(AllRecord)->
	ProtoRecords = filter_records_by_store_type([proto],AllRecord),
	RamRecords = filter_records_by_store_type([ram],AllRecord),
	lists:foldl(fun(Record,AccStr)->
			if
				AccStr=:=[]->
					"%%ets table define\n";
				true->
					AccStr
			end
			++ "-define("++make_record_ets_define_name(Record)++","++make_record_ets_name(Record)++").\n"
		end,[], ProtoRecords)++"\n"
	++
	lists:foldl(fun(RamRecord,AccStr)->
			if
				AccStr=:=[]->
					"%%ram table define\n";
				true->
					AccStr
			end
			++"-define("++make_ram_table_define(RamRecord)++","++make_ram_table_name(RamRecord)++").\n"
		end,[], RamRecords)++"\n".


make_ets_create_str(AllRecord)->
	ProtoRecords = filter_records_by_store_type([proto],AllRecord),
	"create()->\n"++
	lists:foldl(fun(#db_record{type = Type}=Record,AccStr)->
				AccStr++		
				if
					AccStr=/=[]->
						",\n";
					true->
						[]
				end	++
				"\tets:new(?"++make_record_ets_define_name(Record)++",[named_table,"++atom_to_list(Type)++"])"
			end,[], ProtoRecords)++".\n\n".

make_ets_init_str(AllRecord)->
	ProtoRecords = filter_records_by_store_type([proto],AllRecord),
	"init()->\n"++
	lists:foldl(fun(#db_record{args = Args,recordname=RecordName}=Record,AccStr)->
				{key,Keys} = lists:keyfind(key, 1, Args),
				RecordNameStr = atom_to_list(RecordName),
				KeyStr = 
				"["	++
				lists:foldl(fun(Key,AccStrTmpKey)->
							AccStrTmpKey++		
							if			
								AccStrTmpKey=/=[]->
									",";
								true->
									[]
							end	++
							"#"++RecordNameStr++"."++atom_to_list(Key)
						end,[],Keys) ++	"]",
				AccStr++
				if
					AccStr=/=[]->
						",\n";
					true->
						[]
				end	++
				"\tdb_operater_mod:init_ets("++RecordNameStr++",?"++make_record_ets_define_name(Record)++","++KeyStr++")"
			end,[], ProtoRecords)++".\n\n".


make_records_export_str(AllRecord)->
	lists:foldl(fun(Record,AccStr)->AccStr ++ make_record_export_str(Record) end,[],AllRecord).									  
	
make_record_export_str(Record)->	
	#db_record{recordname=RocordName,stroe_type=StoreType,field=Fileds,args=Args} = Record,
	{key,Keys} = lists:keyfind(key, 1, Args),
	ReCordStr = atom_to_list(RocordName),
%% 	[FirstChar|_] = ReCordStr,
%% 	NewFirst = FirstChar+22,
%% 	ReCordInfoStr = NewFirst ++ (ReCordStr -- FirstChar) ++ "Info",  
	GetFunArgLen = 
		case StoreType of
			proto->
				erlang:length(Keys);
			disc_split->
				2;
			_->
				1
		end,
	BaseStr = "-export([\n"++
		case StoreType of
			proto->
				[];
			disc_split->
				"\t\twrite_"++ReCordStr++"_info/"++erlang:integer_to_list(erlang:length(Fileds)+1)++",\n";
			_->
				"\t\twrite_"++ReCordStr++"_info/"++erlang:integer_to_list(erlang:length(Fileds))++",\n"
		end 
		++ "\t\tget_"++ReCordStr++"_info/" ++ erlang:integer_to_list(GetFunArgLen), 
	lists:foldl(fun(Filed,LastStrTmp)-> 
					LastStrTmp++",\n\t\tget_"++ReCordStr++"_"++atom_to_list(Filed)++"/1"		
				end,BaseStr, Fileds)	++"\n\t\t]).\n\n".

filter_records_by_store_type(StaorTypes,AllRecord)->
	lists:filter(fun(ReCord)->#db_record{stroe_type=Stroe_type} = ReCord,lists:member(Stroe_type, StaorTypes) end,AllRecord).

make_dbfun_create_str(AllRecord)->
	DiscReCords = filter_records_by_store_type([disc],AllRecord),
	ProtoReCords = filter_records_by_store_type([proto],AllRecord),
	RamReCords = filter_records_by_store_type([ram],AllRecord),
	DiscSpiltRecords = filter_records_by_store_type([disc_split],AllRecord),
	make_fun_disc_records(DiscReCords)
	++
	make_fun_disc_split_records(DiscSpiltRecords)
	++
	make_fun_ram_records(RamReCords)
	++
	make_fun_proto_records(ProtoReCords).

make_fun_disc_records(DiscReCords)->
	lists:foldl(fun(DiscReCord,AccTmp)->AccTmp++make_fun_disc_record(DiscReCord) end,[], DiscReCords).

make_fun_disc_split_records(DiscSplitReCords)->
	lists:foldl(fun(DiscSplitReCord,AccTmp)->AccTmp++make_fun_disc_split_record(DiscSplitReCord) end,[], DiscSplitReCords).

make_fun_ram_records(RamReCords)->
	lists:foldl(fun(RamReCord,AccTmp)->AccTmp++make_fun_ram_record(RamReCord) end,[], RamReCords).

make_fun_proto_records(ProtoReCords)->
	lists:foldl(fun(ProtoReCord,AccTmp)->AccTmp++make_fun_proto_record(ProtoReCord) end,[], ProtoReCords).
	
make_fun_disc_record(#db_record{recordname=RecordName,type=Type,field=Fileds,args=Args}=Record)->
	RecordNameStr = atom_to_list(RecordName),
	{key,[Key|_]} = lists:keyfind(key, 1, Args),
	KeyArg = str_util:upper_first_char(atom_to_list(Key)),
	"get_"++RecordNameStr ++"_info("++KeyArg++")->\n\tcase dal:read_rpc("++RecordNameStr++","++KeyArg++") of\n"
	"\t\t{ok,[]}->[];\n"++"\t\t%%db type is "++atom_to_list(Type) ++",result is "++
	case Type of
		set->
			"record\n\t\t{ok,[Result]}->Result;\n";
		bag->
			"record_list\n\t\t{ok,Results}->Results;\n"
	end++
	"\t\tError->  slogger:error(\"get_"++RecordNameStr ++"failed ~p~n\",[Error])\n\tend.\n\n"
	++
	"write_"++RecordNameStr ++"_info("++make_fun_args_by_list(Fileds)++")->\n\tdal:write_rpc({"++	
	RecordNameStr++","++make_fun_args_by_list(Fileds)++"}).\n\n"
	++make_record_db_get_fun(Record).
		
make_fun_disc_split_record(#db_record{recordname=RecordName,field=Fileds,type=Type,args=Args}=Record)->
	RecordNameStr = atom_to_list(RecordName),
	{key,[Key|_]} = lists:keyfind(key, 1, Args),
	KeyArg = str_util:upper_first_char(atom_to_list(Key)),
	"get_"++RecordNameStr ++"_info(RoleId,"++KeyArg++")->\n"++
	"\tTableName = db_split:get_owner_table("++RecordNameStr++",RoleId),\n"++
	"\tcase dal:read_rpc(TableName,"++KeyArg++") of\n"
	"\t\t{ok,[]}->[];\n"++"\t\t%%db type is "++atom_to_list(Type) ++",result is "++
	case Type of
		set->
			"record\n\t\t{ok,[Result]}->Result;\n";
		bag->
			"record_list\n\t\t{ok,Results}->Results;\n"
	end++
	"\t\tError->  slogger:error(\"get_"++RecordNameStr ++"failed ~p~n\",[Error])\n\tend.\n\n"
	++
	"write_"++RecordNameStr ++"_info(RoleId,"++make_fun_args_by_list(Fileds)++")->\n"
	"\tTableName = db_split:get_owner_table("++RecordNameStr++",RoleId),\n"++
	"\tdal:write_rpc({TableName,"++make_fun_args_by_list(Fileds)++"}).\n\n"
	++
	make_record_db_get_fun(Record).

make_fun_ram_record(#db_record{recordname=RecordName,field=Fileds,type=Type,args=Args}=Record)->
	DefineName = make_ram_table_define(Record),
	RecordNameStr = atom_to_list(RecordName),
	{key,[Key|_]} = lists:keyfind(key, 1, Args),
	KeyArg = str_util:upper_first_char(atom_to_list(Key)),
	"get_"++RecordNameStr ++"_info("++KeyArg++")->\n"++
	"\tcase ets:lookup(?"++DefineName++","++KeyArg++") of\n"
	++"\t\t[]->[];\n"
	"\t\t%%db type is "++atom_to_list(Type) ++",result is "++
	case Type of
		set->
			"tuple\n\t\t[Info|_]->Info\n\tend.\n\n";
		bag->
			"tuple_list\n\t\tInfos->Infos\n\tend.\n\n"
	end++
	"write_"++RecordNameStr ++"_info("++make_fun_args_by_list(Fileds)++")->\n\tdal:write({"++	
	RecordNameStr++","++make_fun_args_by_list(Fileds)++"}).\n\n"
	++	
	make_record_db_get_fun(Record).	

make_fun_proto_record(#db_record{recordname=RecordName,type=Type,args = Args}=ProtoReCord)->
	DefineName = make_record_ets_define_name(ProtoReCord),
	RecordNameStr = atom_to_list(RecordName),
	{key,Keys} = lists:keyfind(key, 1, Args),
	FunArgs = make_fun_args_by_list(Keys),
	case Keys of
		[_]->
			KeyArgs = FunArgs;
		_->
			KeyArgs = "{"++FunArgs++"}"
	end,
	"get_"++RecordNameStr ++"_info("++FunArgs++")->\n"++
	"\tcase ets:lookup(?"++DefineName++","++KeyArgs++") of\n"
	++"\t\t[]->[];\n"
	"\t\t%%db type is "++atom_to_list(Type) ++",result is "++
	case Type of
		set->
			"tuple\n\t\t[Info|_]->Info\n\tend.\n\n";
		bag->
			"tuple_list\n\t\tInfos->Infos\n\tend.\n\n"
	end
	++	
	make_record_db_get_fun(ProtoReCord).	

make_record_db_get_fun(#db_record{recordname=RecordName,field=Fields})->	
	RecordNameStr = atom_to_list(RecordName),						
	lists:foldl(fun(Filed,AccTmp)-> 
			FieldStr = atom_to_list(Filed),
			AccTmp ++ "get_"++RecordNameStr++"_"++FieldStr++"("++str_util:upper_first_char(RecordNameStr)++"Info"++")->\n\t"
				++"erlang:element(#"++RecordNameStr++"."++FieldStr++","++str_util:upper_first_char(RecordNameStr)++"Info"++").\n\n"
		end,[], Fields).

make_fun_args_by_list(Keys)->
	lists:foldl(fun(Key,AccStrTmpKey)->
				AccStrTmpKey++		
					if			
						AccStrTmpKey=/=[]->
							",";
						true->
							[]
					end	++
					str_util:upper_first_char(atom_to_list(Key))
	end,[],Keys).

make_records_create_str(AllRecord)->
	RamReCords = filter_records_by_store_type([ram],AllRecord),
	DiscRecords = filter_records_by_store_type([disc,proto],AllRecord),
	DiscSpiltRecords = filter_records_by_store_type([disc_split],AllRecord),
	make_ram_records_create(RamReCords)++make_disc_records_create(DiscRecords)++make_disc_split_records_create(DiscSpiltRecords).

make_disc_records_create([])->
	"create_mnesia_table(disc)->\n\tnothing.\n\n";	
make_disc_records_create(DiscRecords)->
	"create_mnesia_table(disc)->\n"++
	lists:foldl(fun(#db_record{recordname=RocordName,type=Type,args=Args},AccStrTmp)-> 
				ReCordStr = atom_to_list(RocordName),
				TypeStr = atom_to_list(Type),
				{index,TableIndex} = lists:keyfind(index,1,Args),
				AccStrTmp++
				if
					AccStrTmp=/=[]->
						",\n";
					true->
						[]
				end ++  
				"\tdb_tools:create_table_disc("++ReCordStr++",record_info(fields,"++ReCordStr++"),"++
				str_util:term_to_string(TableIndex)	++
					","++TypeStr++")"
			end,[], DiscRecords)++".\n\n".

make_ram_records_create([])->
	"create_mnesia_table(ram)->\n\tnothing;\n\n";
make_ram_records_create(RamReCords)->
	"create_mnesia_table(ram)->\n"++
	lists:foldl(fun(#db_record{recordname=RocordName,type=Type,args=Args},AccStrTmp)-> 
				ReCordStr = atom_to_list(RocordName),
				TypeStr = atom_to_list(Type),
				{index,TableIndex} = lists:keyfind(index,1,Args),
				AccStrTmp++
				if
					AccStrTmp=/=[]->
						",\n";
					true->
						[]
				end ++  
				"\tdb_tools:create_table_ram("++ReCordStr++",record_info(fields,"++ReCordStr++"),"++
				str_util:term_to_string(TableIndex)	++
					","++TypeStr++")"
			end,[], RamReCords)++";\n\n".
									  
make_disc_split_records_create([])->
	"create_mnesia_split_table(_,_)->\n\tnothing.\n\n";
make_disc_split_records_create(RamReCords)->
	lists:foldl(fun(#db_record{recordname=RocordName,type=Type,args=Args},AccStrTmp)-> 
				{index,TableIndex} = lists:keyfind(index,1,Args),		
				ReCordStr = atom_to_list(RocordName),
				TypeStr = atom_to_list(Type),
				{index,TableIndex} = lists:keyfind(index,1,Args),
				AccStrTmp++
				if
					AccStrTmp=/=[]->
						";\n";
					true->
						[]
				end++
				"create_mnesia_split_table("++ReCordStr++",TrueTabName)->\n\tdb_tools:create_table_disc(TrueTabName,record_info(fields,"++
				ReCordStr++"),"++	
				str_util:term_to_string(TableIndex)	++
				","++TypeStr++")"
			end,[], RamReCords)++".\n\n".
	
read_all_record(F)->
	read_all_record_loop(F,[],[]).

read_all_record_loop(F,LastData,AllRecords)->
	case file:read_line(F) of
		eof->
			AllRecords;
		{ok,OriData}->
			case clear_blank_edge(OriData) of
				[]->
					read_all_record_loop(F,LastData,AllRecords);
				OriDataWithArgs->	
					[OriRecordData|_]  = string:tokens(OriDataWithArgs,"%"),
					NewRecordData = clear_blank_edge(OriRecordData),
					case has_str(NewRecordData,"-record(")  of
						false->				%%not record start
							case has_str(NewRecordData,").") of
								false->		%%not end
									read_all_record_loop(F,LastData++NewRecordData,AllRecords);
								_->		%%record end!
									read_all_record_loop(F,[],AllRecords++[parse_to_db_record(LastData++OriDataWithArgs)])
							end;
						_->				%%is record start
							case has_str(NewRecordData, ").") of
								false->		%%not end
									read_all_record_loop(F,NewRecordData,AllRecords);
								_->		%%has end
									read_all_record_loop(F,[],AllRecords++[parse_to_db_record(LastData++OriDataWithArgs)])
							end
					end
			end
	end.
		
parse_to_db_record(RecordStr)->
	#db_record{
			   recordname = get_record_name(RecordStr),
			   field = get_record_fileds(RecordStr),
			   type = get_record_type(RecordStr),
			   stroe_type = get_stroe_type(RecordStr),
			   args = get_record_args(RecordStr)
			  }.

get_record_name(RecordStr)->
	Start = string:str(RecordStr, "(")+1,
	Lenth = string:str(RecordStr, ",")-Start,
	erlang:list_to_atom(string:strip(string:substr(RecordStr, Start, Lenth),both,?BLANK)).

get_record_fileds(RecordStr)->
	Start = string:str(RecordStr, "{")+1,
	Lenth = string:str(RecordStr, "}")-Start,
	RecordFieldsStr = string:strip(string:substr(RecordStr, Start, Lenth),both,?BLANK), 
	lists:map(fun(FiledStr)-> erlang:list_to_atom(string:strip(FiledStr,both,?BLANK)) end,string:tokens(RecordFieldsStr,",")). 
	
get_record_type(RecordStr)->
	[_|ArgsL] = string:tokens(RecordStr,"@"),
	[Args] = ArgsL,
	[Type|_] = lists:filter(fun(Term)->has_str(Args,erlang:atom_to_list(Term))  end,?TYPES),
	Type.

get_stroe_type(RecordStr)->
	[_|ArgsL] = string:tokens(RecordStr,"@"),
	[Args] = ArgsL,
	[Type|_] = lists:filter(fun(Term)->has_str(Args,erlang:atom_to_list(Term))  end,?STROE_TYPES),
	Type.

get_record_args(RecordStr)->
	case get_record_type(RecordStr) of	
		bag->
			[{key,get_record_keys(RecordStr)}];
		_->
			[FiledKey|_] = get_record_fileds(RecordStr),
			[{key,[FiledKey]}]
	end
	++
	[{index,get_indexes(RecordStr)}].
		
get_indexes(RecordStr)->
	[_|ArgsL] = string:tokens(RecordStr,"@"),
	[Args] = ArgsL,
	case string:str(Args,"index:") of
		0->
			[];
		EtsIndex->
			EtsStrAll = string:substr(Args, EtsIndex+6),
			[EtsStr|_] = string:tokens(EtsStrAll,"]"),
			str_util:string_to_term(EtsStr++"]")
	end.

get_record_keys(RecordStr)->
	[_|ArgsL] = string:tokens(RecordStr,"@"),
	[Args] = ArgsL,
	case string:str(Args,"key:") of
		0->
			[];
		EtsIndex->
			EtsStrAll = string:substr(Args, EtsIndex+4),
			[EtsStr|_] = string:tokens(EtsStrAll,"]"),
			str_util:string_to_term(EtsStr++"]")
	end.

has_str(Str,Strpart)->
	string:str(Str,Strpart)=/=0.

clear_blank_edge(OriData)->
	string:strip(string:strip(string:strip(OriData,both,?ENTER),both,?BLANK),both,?TAB).

