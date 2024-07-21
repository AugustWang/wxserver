%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrianx
%%% Description :
%%%
%%% Created : 2010-10-5
%%% -------------------------------------------------------------------
-module(gm_msgwrite).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,write/2,write2/3,gm_log_control/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {cur_io,tempdir,outdir,datedir,curname,outname}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	case erlang:whereis(?MODULE) of
		undefined->	gen_server:start_link({local,?MODULE}, ?MODULE, [], []);
		Pid->{ok,Pid}
	end.

gm_log_control(Table,Option)->
	io:format("Table:~p,Option:~p~n",[Table,Option]),
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("gm_log_control error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					gs_rpc:cast(GmNode, ?MODULE, {gm_log_control,Table,Option})
			end;
		GmNode->
			gs_rpc:cast(GmNode, ?MODULE, {gm_log_control,Table,Option})
	end.

%% [{"keyname","Value"}]
write(Table,KeyValueList)->
	write2(Table,KeyValueList,buffer).

write2(Table,KeyValueList,Type)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("gm_msgwrite error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
					TimeSeconds = Secs+MegaSecs*1000000,
					gs_rpc:cast(GmNode, ?MODULE, {msg_write,KeyValueList ++ [{"time",TimeSeconds}],Table,Type})
			end;
		GmNode->
			{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
			TimeSeconds = Secs+MegaSecs*1000000,
			gs_rpc:cast(GmNode, ?MODULE, {msg_write,KeyValueList ++ [{"time",TimeSeconds}],Table,Type})
	end.
%% 	gm_msgwrite_mysql:abstract_write_db(Table,KeyValueList,Type).
	
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	TempDir = env:get2(gm_logger, tempdir, "./"),
	OutDir  = env:get2(gm_logger, outdir, "./"),
	Interval = env:get2(gm_logger, close_file_interval, 60000),
	put(logs_control_open,[]),
	put(logs_control_close,[]),
	timer_center:start_at_process(),
	init_dir(TempDir,OutDir),
	timer:send_interval(Interval,{close_file}),	
    {ok, #state{tempdir=TempDir,outdir=OutDir}}.

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

handle_info({msg_write,KeyValueList,Table,Type},#state{cur_io=undefined,tempdir=TempDir}=State)->
	abstract_write_db(Table,lists:keydelete("time", 1, KeyValueList),Type),
	{DateDir,TimeFile} = get_current_file(),
	case msg_to_binary(KeyValueList) of
		<<>>-> {noreply, State};
		BinOfString ->
			CurName = "~" ++ DateDir ++"_"++TimeFile, %% ~Y_M_D_H_MIN_S
			OutName = DateDir ++"/"++ TimeFile, 	  %%Y_M_D/H_MIN_S
			case file:open(TempDir ++ CurName,[append,binary,raw]) of
				{ok,NewIo}-> file:write(NewIo, BinOfString),
							 NewStat = State#state{cur_io=NewIo,curname=CurName,outname=OutName,datedir=DateDir},
							 {noreply, NewStat};
				{error,_Reason}-> {noreply, State}
			end
	end;

handle_info({msg_write,KeyValueList,Table,Type},#state{cur_io=CurIo}=State)->
	abstract_write_db(Table,lists:keydelete("time", 1, KeyValueList),Type),
	case msg_to_binary(KeyValueList) of
		<<>>-> ignor;
		BinOfString ->
			file:write(CurIo, BinOfString)
	end,
	{noreply, State};

handle_info({gm_log_control,Table,Option},State)->
	case Option of
		open->
			case lists:member(Table, get(logs_control_open)) of
				false-> 
					put(logs_control_open,[Table]++get(logs_control_open));
				true->
					nothing
			end,
			case lists:member(Table, get(logs_control_close)) of
				false->
					nothing;
				true->
					put(logs_control_close,lists:delete(Table, get(logs_control_close)))
			end;
		close->
			case lists:member(Table, get(logs_control_open)) of
				false-> 
					nothing;
				true->
					put(logs_control_open,lists:delete(Table, get(logs_control_open)))
			end,
			case lists:member(Table, get(logs_control_close)) of
				false->
					put(logs_control_close,[Table]++get(logs_control_close));
				true->
					nothing
			end;
		_->
			nothing
	end,
	{noreply, State};

handle_info({close_file},
			#state{cur_io=CurIo,
				   tempdir = TempDir,
				   outdir = OutDir,
				   curname = CurName,
				   outname = OutName,
				   datedir=DateDir}=State)->
	case CurIo of
		undefined->
			ignor;
		_-> 
			file:close(CurIo),
%% 			slogger:msg("ensure_dir:~p~n",[OutDir ++ OutName]),
			filelib:ensure_dir(OutDir ++ DateDir ++ "/"),
%% 			slogger:msg("write file:~p~n",[OutDir ++ OutName]),
			file:rename(TempDir ++ CurName, OutDir ++ OutName)
	end,
    {noreply, State#state{cur_io=undefined}};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
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

get_current_file()->
	Now = timer_center:get_correct_now(),
	{{Y,M,D},{H,Min,S}} = calendar:now_to_local_time(Now),
	DatePath = string:join([util:make_int_str4(Y),	
							util:make_int_str2(M),
							util:make_int_str2(D)], "_"),
	TimeFile = string:join([util:make_int_str2(H),
							util:make_int_str2(Min),
							util:make_int_str2(S)], "_"),
	{DatePath,TimeFile}.

init_dir(TempDir,OutDir)->
	case file:list_dir(TempDir) of
		{ok,FileNames}-> lists:foreach(fun(FileName)->
											   case FileName of
												   [126|TrueInput]-> %% 126 == ~
													   case get_out_dir(TrueInput,OutDir) of
														   {nofile}-> ignor;
														   {OutSubDir,OutFile}->
															   filelib:ensure_dir(OutSubDir),
															   file:rename(TempDir++FileName,OutSubDir++OutFile)
													   end;
											   	   _-> ignor
											   end
									   end, FileNames);
		{error, _Reason}-> ignor
	end.
	
get_out_dir(InputFile,OutDir)->
	try
		[Y,M,D,H,Min,S] = string:tokens(InputFile, "_"),
		OutDir2 = lists:append([OutDir,string:join([Y,M,D], "_"),"/"]),
		OutFile = string:join([H,Min,S], "_"),
		{OutDir2,OutFile}
	catch
		_:_-> {nofile}
	end.

msg_to_binary(KeyValueList)->
	try
		ValueString = lists:map(fun({Key,Value}) ->
										util:escape_uri(list_to_binary(Key)) ++ "=" ++ value_to_list(Value) end,							
								KeyValueList),
		
		StringForWrite = string:join(ValueString, "&") ++ "\n",
		list_to_binary(StringForWrite)
	catch
		E:R-> 
			slogger:msg("bad input when call in gm_msgwrite:write \tException:~p~n\tReason:~p~n\tInpute:~p ~n",[E,R,KeyValueList]),
			<<>>
	end.
	
value_to_list(<<>>)->
	[];
value_to_list([])->
	[];
value_to_list(Value) when is_tuple(Value)->
	NewValue = lists:map(fun(X)-> value_to_list(X) end, tuple_to_list(Value)),
	"{"++string:join(NewValue, ",")++"}";
value_to_list(Value) when is_integer(Value)->
	integer_to_list(Value);
value_to_list(Value) when is_float(Value)->
	float_to_list(Value);
value_to_list(Value) when is_atom(Value)->
	atom_to_list(Value);
value_to_list(Value)when is_binary(Value)->
	case Value of
		<<>>-> [];
		_->
			ListValue = binary_to_list(Value),
			value_to_list(ListValue)
	end;
value_to_list(Value)when is_list(Value)->
	case Value of
		[]-> [];
		_-> [H|_] =Value,
			if is_tuple(H)->
				   NewValue = lists:map(fun(X)-> value_to_list(X) end, Value),
				   "["++ string:join(NewValue, ",") ++ "]";
				true-> util:escape_uri(list_to_binary(Value))
			end
	end.

abstract_write_db(Table,KeyValueList,Default)->
	case lists:member(Table, get(logs_control_close)) of
		true->
			case Default of
				directly->
					Type=Default;
				_->
					Type=nodb
			end;
		false->
			case lists:member(Table, get(logs_control_open)) of
				true->
					case Default of
						directly->
							Type=Default;
						_->
							Type=buffer
					end;
				false->
					Type=Default
			end
	end,
	case Type of
		buffer->
			gm_msgwrite_mysql:write_db_to_buffer(KeyValueList);
		directly->
			gm_msgwrite_mysql:write_db(KeyValueList);
		merge->
			gm_msgwrite_mysql:write_db_to_merge(KeyValueList);
		nodb->
			nothing;
		_->
			nothing
	end.

%% test1()->
%% 	lists:foreach(fun(_)-> 
%% 					A=list_to_atom("create_role"),
%% 					B=list_to_atom("gold_change")
%% 				  end, lists:seq(1, 1100000)).

%% test()->
%% 	start_link(),
%% 	L = lists:seq(1, 1000),
%% 	lists:foreach(fun(_)-> 
%% 					gs_rpc:cast(node(), ?MODULE, {msg_write,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n"})
%% 				  end, L).
