%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrianx
%%% Description :
%%%
%%% Created : 2010-10-23
%%% -------------------------------------------------------------------
-module(dbmaster).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(CHECK_SPLIT_TABLE_FIRSTINTERVAL,1000).
-define(CHECK_SPLIT_TABLE_INTERVAL,1000*60*10).
-define(DEFAULT_BACKUP_INTERVAL,60*60*1000).

-define(DAL_WRITE_INTERVAL,60*1000).

-define(DAL_WRITE_CHECK_INTERVAL,10*1000).

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,rpc_add_self_to_db_node/2,rpc_add_self_to_dbslave_node/1,is_db_prepread/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================

rpc_add_self_to_db_node(Node,TabList)->
	gs_rpc:cast(Node, ?MODULE, {add_db_ram_node, [node(),TabList]}).

rpc_add_self_to_dbslave_node(Node)->
	gs_rpc:cast(Node, ?MODULE, {add_dbslave_node, [node()]}).

is_db_prepread(Node)->
	try
		gen_server:call({?MODULE,Node}, is_db_prepread)
	catch
		E:R->
			slogger:msg("get_db_master error no_proc ,wait ~n "),
			false
	end.

%% ====================================================================
%% Server functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	put(db_prepare_finish,false),
	timer_center:start_at_process(),
	db_split:create(),
	timer_util:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, {check_split}),
	db_ini:db_init_master(),
	send_check_dump_message(),
	db_split:check_split_master_tables(),
	put(dbfile_dump,{idle,timer_center:get_correct_now()}),
	dal:init(),	
	put(db_prepare_finish,true),
	{ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(is_db_prepread, From, State) ->
    Reply = get(db_prepare_finish),
    {reply, Reply, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({check_backup},State)->
	%% get backup filename
	Dir = env:get2(dbback, output,[]),
	case Dir of
		[]-> ignor;
		_->
			%%check_today_dump(Dir),
			check_db_dump(Dir),
		   send_check_dump_message()
	end,
	{noreply,State};
handle_info({check_split},State)->
	ServerList = env:get(serverids, [0]),
	Result = lists:foldl(fun(ServerId,Acc)->
								 case Acc of
									 ignor->ignor;
									 ok->
										 db_split:check_need_split(ServerId)
								 end
						 end, ok,ServerList),	
	db_split:check_split_master_tables(),
	case Result of
		ok->erlang:send_after(?CHECK_SPLIT_TABLE_INTERVAL, self(), {check_split});
		ignor->erlang:send_after(?CHECK_SPLIT_TABLE_FIRSTINTERVAL, self(), {check_split})
	end,
	{noreply,State};
handle_info({add_db_ram_node, [NewNode,TabList]}, State)->
	db_tools:add_db_ram_node(NewNode,TabList),
	{noreply,State};

handle_info({add_dbslave_node, [NewNode]}, State)->
	db_tools:add_dbslave_node(NewNode),
	{noreply,State};

handle_info({backupdata,FromProc}, State)->
	slogger:msg("backupdata begin~n"),
	case dal:read_rpc(role_pos) of
		{ok,L}->
			OnlineNum = length(L);
		_->
			OnlineNum = 0
	end,
	if
		OnlineNum =:= 0->	
			case dal:get_write_flag() of
				undefined->
					BackupFlag = true;
				WriteTime->
					BackupFlag = timer:now_diff(now(),WriteTime) > ?DAL_WRITE_INTERVAL 
			end;
		true->
			BackupFlag = false
	end,
	if
		BackupFlag->		
			BackDir = env:get2(dbback, output,[]),
			BackPath = BackDir ++ "zybackup_db",
			data_gen:backup_ext(BackPath),
			gs_rpc:cast(FromProc,{backup_db_ok}),
			slogger:msg("data_gen backup db finish!!!");
		true->
			erlang:send_after(?DAL_WRITE_CHECK_INTERVAL, self(), {backupdata,FromProc})
	end,
	{noreply,State};


handle_info({backupdata}, State)->
	case dal:read_rpc(role_pos) of
		{ok,L}->
			OnlineNum = length(L);
		_->
			OnlineNum = 0
	end,
	if
		OnlineNum =:= 0->	
			case dal:get_write_flag() of
				undefined->
					BackupFlag = true;
				WriteTime->
					BackupFlag = timer:now_diff(now(),WriteTime) > ?DAL_WRITE_INTERVAL 
			end;
		true->
			BackupFlag = false
	end,
	if
		BackupFlag->		
			BackDir = env:get2(dbback, output,[]),
			BackPath = BackDir ++ "zybackup_db",
			data_gen:backup_ext(BackPath),
			server_control:write_flag_file(),
			slogger:msg("data_gen backup db finish!!!");
		true->
			erlang:send_after(?DAL_WRITE_CHECK_INTERVAL, self(), {backupdata})
	end,
	{noreply,State};

handle_info({recoverydata,FromProc},State)->
	slogger:msg("recoverydata start~n"),
	BackDir = env:get2(dbback, output,[]),
	BackPath = BackDir ++ "zybackup_db",
	data_gen:recovery_ext(BackPath),
	data_gen:start(),
	data_gen:import_config("game"),
	slogger:msg("data_gen recovery db finish!!!"),
	gs_rpc:cast(FromProc,{recoverydata_ok}),
	{noreply,State};


handle_info({recoverydata},State)->
	db_tools:wait_for_all_db_tables(),
	BackDir = env:get2(dbback, output,[]),
	BackPath = BackDir ++ "zybackup_db",
	data_gen:recovery_ext(BackPath),
	data_gen:start(),
	data_gen:import_config("game"),
	server_control:write_flag_file(),
	slogger:msg("data_gen recovery db finish!!!"),
	{noreply,State};

handle_info({gen_data},State)->
	%%data_gen:start(),
	db_tools:wait_for_all_db_tables(),
	data_gen:import_config("game"),
	%%ServerId = env:get(serverid,1),
	%%giftcard_op:import("../config/gift_card-"++integer_to_list(ServerId)++"01.config"),
	server_control:write_flag_file(),
	slogger:msg("data_gen gen db finish!!!"),
	{noreply,State};

handle_info({create_giftcard},State)->
	%%create giftcard and import to db
	db_tools:wait_for_all_db_tables(),
	giftcard_op:auto_gen_and_import(),
	server_control:write_flag_file(),
	slogger:msg("create_giftcard gen db finish!!!"),
	{noreply,State};

handle_info({format_data,Param},State)->
	db_tools:wait_for_all_db_tables(),
	data_change:update_db_data(Param),
	server_control:write_flag_file(),
	slogger:msg("format_data ~p finish!!!~n",[Param]),
	{noreply,State};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("dbmaster terminate Reason ~p ~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------


send_check_dump_message()->
	CheckInterval = env:get2(dbback, checkinterval , []),
	if is_integer(CheckInterval)->
		   timer_util:send_after(CheckInterval, {check_backup});
	   true-> ignor
	end.
	


%%
%% for back up 
dum_now(Dir)->
	case Dir of
		[]-> ignor;
		_-> case filelib:ensure_dir(Dir) of
			   ok->File = get_out_file(Dir),
				   data_gen:backup(File);
			   _-> slogger:msg("back database faild create dir [~p] failed!",[Dir])
		   end
	end.

check_today_dump(Dir)->
	Now = timer_center:get_correct_now(),
	{{Y,M,D},{H,_Min,_S}} = calendar:now_to_local_time(Now),
	%% check time
	Res = case env:get2(dbback, between_hour, []) of
		[]-> false;
		{B,E}-> 
			{NewB,NewE} = if B>E -> {E,B};
							 true-> {B,E}
						  end,
			if (H >= NewB) and (H =< NewE) ->
				   true;
			   true-> false
			end
	end,
	TodayFileHeader = "zyback_" ++ util:make_int_str4(Y) ++ "_" 
								++ util:make_int_str2(M) ++ "_" 
								++ util:make_int_str2(D) ++ "_",
	CheckNeedDump = case Res of
						true -> case file:list_dir(Dir) of
									{ok,FileNames}->
										lists:foldl(fun(FileName,Checked)->
															case Checked of
																false-> false;
																true->
																	case string:str(FileName, TodayFileHeader) of
																		0-> true;
																		1-> false;
																		_-> true
																	end
															end
													end,true, FileNames);
									_-> true
								end;
						_-> false
					end,
	
	case CheckNeedDump of
		true->
			dum_now(Dir);
		false->
			ignor
	end.

db_dump_now(Dir,LastTime)->
	case Dir of
		[]-> ignor;
		_-> case filelib:ensure_dir(Dir) of
			   ok->
					put(dbfile_dump,{backup,LastTime}),
				   	File = get_out_file(Dir),
				   	data_gen:backup_ext(File),
				    put(dbfile_dump,{idle,timer_center:get_correct_now()});
			   _-> slogger:msg("back database faild create dir [~p] failed!",[Dir])
		   end
	end.

check_db_dump(Dir)->
	case get(dbfile_dump) of
		undefined->
			nothing;
		{backup,_}->
			nothing;
		{idle,LastTime}->
			Now = timer_center:get_correct_now(),
			BackInterval = env:get2(dbback,backinterval,?DEFAULT_BACKUP_INTERVAL),
			TimeDiff = trunc(timer:now_diff(Now,LastTime)/1000),
			if
				BackInterval =< TimeDiff->
					db_dump_now(Dir,LastTime);
				true->
					nothing
			end;
		_->
			nothing
	end.

get_out_file(OutDir)->
	Now = timer_center:get_correct_now(),
	{{Y,M,D},{H,Min,S}} = calendar:now_to_local_time(Now),
	File = string:join(["zyback",
							util:make_int_str4(Y),	
							util:make_int_str2(M),
							util:make_int_str2(D),
							%%util:make_int_str4(S+Min*60+H*3600)
							util:make_int_str6(H*10000+Min*100+S) 
							],
							"_"),
	OutDir ++ File.
	
