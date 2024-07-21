%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : MacX
%%% Description :
%%%
%%% Created : 2011-9-3
%%% -------------------------------------------------------------------
-module(gm_msgwrite_mysql).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,
		 write_db/1,
		 write_db_to_buffer/1,
		 write_db_to_merge/1,
		 flush_buffer/0,
		 update_db/4,
		 update_db_buffer/4,
		 update_db_merge_roleuser/2,
		 convert_ip2int/1,
		 vonvert_int2ip/1,
		 value_to_list/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {cur_lines,buffer_lines,interval,interval_ext}).
-define(TABLE_PREFIX, "log_").
%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	case erlang:whereis(?MODULE) of
		undefined->	gen_server:start_link({local,?MODULE}, ?MODULE, [], []);
		Pid->{ok,Pid}
	end.

update_db(Table,Fields,Vals,Where)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("update_db error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					gs_rpc:cast(GmNode, ?MODULE, {msg_update_db,Table,Fields,Vals,Where})
			end;
		GmNode->
			gs_rpc:cast(GmNode, ?MODULE, {msg_update_db,Table,Fields,Vals,Where})
	end.

update_db_buffer(Table,Fields,Vals,Where)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("update_db_buffer error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					gs_rpc:cast(GmNode, ?MODULE, {msg_update_db_buffer,Table,Fields,Vals,Where})
			end;
		GmNode->
			gs_rpc:cast(GmNode, ?MODULE, {msg_update_db_buffer,Table,Fields,Vals,Where})
	end.

update_db_merge_roleuser(RoleId,FieldsVals)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("update_db_merge_roleuser error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					gs_rpc:cast(GmNode, ?MODULE, {msg_update_db_merge_roleuser,RoleId,FieldsVals})
			end;
		GmNode->
			gs_rpc:cast(GmNode, ?MODULE, {msg_update_db_merge_roleuser,RoleId,FieldsVals})
	end.

%%cmd=create_role&
%%username=zu_2282000018%401&
%%userid=0&
%%rolename=%E5%B0%8F%E9%AD%94&
%%roleid=50060000001&
%%roleclass=2&
%%gender=1&
%%ipaddress=114.32.176.75&
%%visitor=false&
%%time=1313638246
write_db(KeyValueList)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("write_db error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
					TimeSeconds = Secs+MegaSecs*1000000,
					gs_rpc:cast(GmNode, ?MODULE, {msg_write_db,KeyValueList ++ 
													  [{"create_time",TimeSeconds}]})
			end;
		GmNode->
			{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
			TimeSeconds = Secs+MegaSecs*1000000,
			gs_rpc:cast(GmNode, ?MODULE, {msg_write_db,KeyValueList ++ 
											  [{"create_time",TimeSeconds}]})
	end.

write_db_to_buffer(KeyValueList)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("write_db_to_buffer error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
					TimeSeconds = Secs+MegaSecs*1000000,
					gs_rpc:cast(GmNode, ?MODULE, {msg_write_db_to_buffer,
												  KeyValueList ++ [{"create_time",TimeSeconds}]})
			end;
		GmNode->
			{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
			TimeSeconds = Secs+MegaSecs*1000000,
			gs_rpc:cast(GmNode, ?MODULE, {msg_write_db_to_buffer,
										  KeyValueList ++ [{"create_time",TimeSeconds}]})
	end.

write_db_to_merge(KeyValueList)->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("write_db_to_merge error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
					TimeSeconds = Secs+MegaSecs*1000000,
					gs_rpc:cast(GmNode, ?MODULE, {msg_write_db_to_merge,
												  KeyValueList ++ [{"create_time",TimeSeconds}]})
			end;
		GmNode->
			{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
			TimeSeconds = Secs+MegaSecs*1000000,
			gs_rpc:cast(GmNode, ?MODULE, {msg_write_db_to_merge,
										  KeyValueList ++ [{"create_time",TimeSeconds}]})
	end.

flush_buffer()->
	case get(gm_node) of
		undefined->
			case node_util:get_gmnode() of
				undefined-> slogger:msg("flush_buffer error : can not find gm node~n");
				GmNode->
					put(gm_node,GmNode),
					gs_rpc:cast(GmNode, ?MODULE, {flush_buffer})
			end;
		GmNode->
			gs_rpc:cast(GmNode, ?MODULE, {flush_buffer})
	end.
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
	put(insert_buffer_log,[]),
	put(update_buffer_log,[]),
	put(merge_role_user,[]),
	BufferLines = env:get2(gm_insert_mysql, buffer_lines, 1000),
    Interval = env:get2(gm_insert_mysql, interval, 300000),
	IntervalExt = env:get2(gm_insert_mysql, interval_ext, []),
	timer_center:start_at_process(),	
	timer:send_interval(Interval,{flush_buffer}),	
    {ok, #state{cur_lines=0,buffer_lines=BufferLines,
				interval=Interval,interval_ext=IntervalExt}}.

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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({flush_buffer},State)->
	flush_buffer_lines(),
	flush_update_buffer_lines(),
	flush_role_user_merge(),
	{noreply,State#state{cur_lines=0}};
	
handle_info({msg_write_db,KeyValueList}, State) ->
	{_,Table} = lists:keyfind("cmd", 1, KeyValueList),
	Convert_List = convert_log(Table,KeyValueList),
	{Fields,Vals} = lists:unzip(lists:keydelete("cmd", 1, Convert_List)),
	ConvertVals = lists:map(fun(X)->
								Value = value_to_list(X),
								case string:str(Value, "%") of
									0-> Value;
									_-> X
								end
							end, Vals),
	case Table of
		"create_role"->
			mysql_queries:insert("role_user",Fields,ConvertVals);
		"feedback"->
			mysql_queries:insert("role_feedback",Fields,ConvertVals);
		_->
			nothing
	end,
	mysql_queries:insert_log_exclude_fiels(?TABLE_PREFIX++Table, ConvertVals),
	{noreply, State};

handle_info({msg_write_db_to_buffer,KeyValueList}, 
			#state{cur_lines=CurLines,buffer_lines=BufferLines}=State) ->
	{_,Table} = lists:keyfind("cmd", 1, KeyValueList),
	Convert_List = convert_log(Table,KeyValueList),
	AtomTable = erlang:list_to_atom(Table),
	{Fields,Vals} = lists:unzip(lists:keydelete("cmd", 1, Convert_List)),
	ConvertVals = lists:map(fun(X)->
								Value = value_to_list(X),
								case string:str(Value, "%") of
									0-> Value;
									_-> X
								end
							end, Vals),
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	case get(insert_buffer_log) of
		[]->
			put(insert_buffer_log,[{AtomTable,TimeSeconds,Fields,[ConvertVals]}]);
		Buffer_log->
			case lists:keyfind(AtomTable, 1, Buffer_log) of
				false->
					NewBuffer_log = Buffer_log ++
									[{AtomTable,TimeSeconds,Fields,[ConvertVals]}];
				SubBuffer_log->
					{_,FirstTime,FieldsTemp,ValsList} = SubBuffer_log,
					NewBuffer_log = lists:keyreplace(AtomTable, 1, Buffer_log, 
													 {AtomTable,FirstTime,FieldsTemp,
													  ValsList++[ConvertVals]})
			end,
			put(insert_buffer_log,NewBuffer_log)
	end,
	if
		CurLines+1<BufferLines->
			NewCurLines = CurLines+1;
		true->
			flush_buffer_lines(),
			flush_update_buffer_lines(),
			flush_role_user_merge(),
			NewCurLines = 0
	end,
    {noreply, State#state{cur_lines=NewCurLines}};

handle_info({msg_write_db_to_merge,KeyValueList}, 
			#state{cur_lines=CurLines,buffer_lines=BufferLines}=State) ->
	{_,Table} = lists:keyfind("cmd", 1, KeyValueList),
	Convert_List = convert_log(Table,KeyValueList),
	AtomTable = erlang:list_to_atom(Table),
	{Fields,Vals} = lists:unzip(lists:keydelete("cmd", 1, Convert_List)),
	ConvertVals = lists:map(fun(X)->
								Value = value_to_list(X),
								case string:str(Value, "%") of
									0-> Value;
									_-> X
								end
							end, Vals),
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	case get(insert_buffer_log) of
		[]->
			put(insert_buffer_log,[{AtomTable,TimeSeconds,Fields,[ConvertVals]}]);
		Buffer_log->
			case lists:keyfind(AtomTable, 1, Buffer_log) of
				false->
					NewBuffer_log = Buffer_log ++
									[{AtomTable,TimeSeconds,Fields,[ConvertVals]}];
				SubBuffer_log->
					{_,FirstTime,FieldsTemp,ValsList} = SubBuffer_log,
					NewBuffer_log = lists:keyreplace(AtomTable, 1, Buffer_log, 
													 {AtomTable,FirstTime,FieldsTemp,
													  ValsList++[ConvertVals]})
			end,
			put(insert_buffer_log,NewBuffer_log)
	end,
	if
		CurLines+1<BufferLines->
			NewCurLines = CurLines+1;
		true->
			flush_buffer_lines(),
			flush_update_buffer_lines(),
			flush_role_user_merge(),
			NewCurLines = 0
	end,
    {noreply, State#state{cur_lines=NewCurLines}};

handle_info({msg_update_db,Table,Fields,Vals,Where}, State) ->
	mysql_queries:update(Table, Fields, Vals, Where),
	{noreply, State};

handle_info({msg_update_db_buffer,Table,Fields,Vals,Where}, 
			#state{cur_lines=CurLines,buffer_lines=BufferLines}=State) ->
	case get(update_buffer_log) of
		[]->
			put(update_buffer_log,[{Table,Fields,Vals,Where}]);
		Buffer_log->
			NewBuffer_log = Buffer_log ++
							[{Table,Fields,Vals,Where}],
			put(update_buffer_log,NewBuffer_log)
	end,
	if
		CurLines+1<BufferLines->
			NewCurLines = CurLines+1;
		true->
			flush_buffer_lines(),
			flush_update_buffer_lines(),
			flush_role_user_merge(),
			NewCurLines = 0
	end,
    {noreply, State#state{cur_lines=NewCurLines}};

handle_info({msg_update_db_merge_roleuser,RoleId,FieldsVals}, 
			#state{cur_lines=CurLines,buffer_lines=BufferLines}=State) ->
	case get(merge_role_user) of
		[]->
			NewCurLines = CurLines+1,
			put(merge_role_user,[{RoleId,FieldsVals}]);
		Buffer_log->
			case lists:keyfind(RoleId, 1, Buffer_log) of
				false->
					NewCurLines = CurLines+1,
					NewBuffer_log = Buffer_log++[{RoleId,FieldsVals}];
				{_,UpdateList}->
					NewCurLines = CurLines,
					NewFieldsVals = lists:foldl(fun({Field,Val},Acc)->
										case lists:keyfind(Field, 1, Acc) of
											false->
												Acc++[{Field,Val}];
											_->
												lists:keyreplace(Field, 1, Acc, {Field,Val})
										end
								end, UpdateList, FieldsVals),
					NewBuffer_log = lists:keyreplace(RoleId, 1, Buffer_log, {RoleId,NewFieldsVals})
			end,
			put(merge_role_user,NewBuffer_log)
	end,
	if
		NewCurLines<BufferLines->
			ReturnLines = NewCurLines;
		true->
			flush_buffer_lines(),
			flush_update_buffer_lines(),
			flush_role_user_merge(),
			ReturnLines = 0
	end,
    {noreply, State#state{cur_lines=ReturnLines}}.

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
convert_log(Table,KeyValueList)->
	case Table of
		"create_role"->
			Temp1 = convert_log_ipaddress(KeyValueList),
			convert_log_bool2int(Temp1);
		"role_login"->
			convert_log_ipaddress(KeyValueList);
		"role_logout"->
			convert_log_ipaddress(KeyValueList);
		"role_rename"->
			convert_log_ipaddress(KeyValueList);
		_->
			KeyValueList
	end.

convert_log_ipaddress(KeyValueList)->
	case lists:keyfind("ipaddress", 1, KeyValueList) of
		false->
			KeyValueList;
		{_,IpAddress}->
			lists:keyreplace("ipaddress", 1, KeyValueList, 
							 {"ipaddress",convert_ip2int(IpAddress)})
	end.

convert_log_bool2int(KeyValueList)->
	lists:map(fun({Key,Value})->
					  case string:str(Key, "_bool") of
						  0->
							  {Key,Value};
						  _->
							  {Key,bool_to_int(Value)}
					  end
			  end, KeyValueList).

convert_ip2int(IpAddress)->
	[Ip0,Ip1,Ip2,Ip3] = lists:map(fun(Ip)-> list_to_integer(Ip) end, 
								  string:tokens(IpAddress, ".")),
 	Ip0*16777216+Ip1*65536+Ip2*256+Ip3*1.

vonvert_int2ip(IpInt)->
	IpString = lists:map(fun(Ip)-> integer_to_list(Ip) end, 
						 [IpInt div 16777216 rem 256,IpInt div 65536 rem 256,
						  IpInt div 256 rem 256,IpInt rem 256]),
	string:join(IpString, ".").
		
bool_to_int("true")-> 1;
bool_to_int(true)-> 1;
bool_to_int(1)-> 1;
bool_to_int("1")-> 1;
bool_to_int(_)-> 0.

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
		_-> binary_to_list(Value)
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

flush_buffer_lines()->
	case get(insert_buffer_log) of
		[]->
			nothing;
		Buffer_log->
			lists:foreach(
			  fun(SubBuffer_log)->
				{AtomTable,_,Fields,ValsList} = SubBuffer_log,
				Table = atom_to_list(AtomTable),
				case Table of
					"create_role"->
						mysql_queries:insert_log_batched("role_user", Fields, ValsList);
					"feedback"->
						mysql_queries:insert_log_batched("role_feedback", 
																	   Fields, ValsList);
					_->
						nothing
			 	end,
				mysql_queries:insert_log_batched_exclude_fiels(?TABLE_PREFIX++Table, ValsList)
			  end, Buffer_log),
			put(insert_buffer_log,[])
	end.

flush_update_buffer_lines()->
	case get(update_buffer_log) of
		[]->
			nothing;
		Buffer_log->
			lists:foreach(
			  fun(SubBuffer_log)->
				{Table,Fields,Vals,Where} = SubBuffer_log,
				mysql_queries:update(Table, Fields, Vals, Where)
			  end, Buffer_log),
			put(update_buffer_log,[])
	end.

flush_role_user_merge()->
	case get(merge_role_user) of
		[]->
			nothing;
		Buffer_log->
			lists:foreach(
			  fun({RoleId,FieldsVals})->
				{Fields,Vals} = lists:unzip(FieldsVals),
				mysql_queries:update("role_user",Fields,Vals,
									 "roleid="++integer_to_list(RoleId))
			  end, Buffer_log),
			put(merge_role_user,[])
	end.