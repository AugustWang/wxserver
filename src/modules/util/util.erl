%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : util.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 23 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(util).

-compile(export_all).

is_has_function(Script,Fun,Arith)->
	mod_util:load_module_if_not_loaded(Script),
	erlang:function_exported(Script,Fun,Arith).

sub_unicode_string(Utf8String,Length) when is_binary(Utf8String)->
	UniString = unicode:characters_to_list(Utf8String,unicode),
	unicode:characters_to_binary(lists:sublist(UniString,Length), utf8);

sub_unicode_string(InputString,Length) when is_list(InputString)->
	Utf8Binary = list_to_binary(InputString),
	sub_unicode_string(Utf8Binary,Length).

get_adjust_move_time({X1,Y1},{X2,Y2},Speed)->
	if 
		(X2 - X1)*(Y2-Y1)>0 ->
			Rate = 1.12;
		(X2 - X1)*(Y2-Y1)<0 ->
			Rate = 0.56;
		(X2 - X1)*(Y2-Y1)=:=0 ->
			Rate = 1
	end,
	InclinedNum = min(abs(X2 - X1),abs(Y2-Y1)),
	StraightNum = max(abs(X2 - X1),abs(Y2-Y1)) - InclinedNum,
	trunc(1000/Speed*(StraightNum + InclinedNum/Rate)).   

now_to_ms({A,B,C})->
	A*1000000000+B*1000 + C div 1000.

ms_to_now(MsTime)->
	C = (MsTime rem 1000)*1000,
	STime = MsTime div 1000,
	B = STime rem 1000000,
	A = STime div 1000000,
	{A,B,C}.

change_now_time({A,B,C},MsTime)->
	NowMs = now_to_ms({A,B,C}),
	RealMs = NowMs + MsTime,
	ms_to_now(RealMs).
	

broadcast(Members, Msg) ->
	lists:foreach(fun(H) -> H ! Msg end, Members).
  
even_div(Number,Divisor)->
	FloatNum = Number/Divisor,
	if
		 FloatNum - erlang:trunc(FloatNum)>0 ->
		 	erlang:trunc(FloatNum)+1;
		 true->	
		 	erlang:trunc(FloatNum)
	end.

idle_loop(Interval) ->
	timer:sleep(Interval),
	idle_loop(Interval).

format_utc_timestamp() ->
	TS = {_,_,Micro} = os:timestamp(),
	{{Year,Month,Day},{Hour,Minute,Second}} = calendar:now_to_local_time(TS),
	Mstr = element(Month,{"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}),
	io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w.~6..0w", [Day,Mstr,Year,Hour,Minute,Second,Micro]).

send_state_event(Node,ProcName,Event)->
	CurNode = node(),
	case Node of
		CurNode -> 
			gen_fsm:send_event(ProcName,Event);
		_ ->
			gen_fsm:send_event({ProcName,Node}, Event)
	end.

sync_send_state_event(Node, ProcName, Event) ->
	CurNode = node(),
	case Node of
		CurNode -> 
			gen_fsm:sync_send_event(ProcName,Event);
		_ ->
			gen_fsm:sync_send_event({ProcName,Node}, Event)
	end.

send_state_event(Pid,Event)->
	gen_fsm:send_event(Pid,Event).

is_process_alive(Pid) 
  when is_pid(Pid) ->
	rpc:call(node(Pid), erlang, is_process_alive, [Pid]).

is_process_alive(undefined, _ProcName) ->
	false;
is_process_alive(_Node, undefined) ->
	false;
is_process_alive(Node, Pid)when is_pid(Pid) ->
	case rpc:call(Node, erlang, is_process_alive, [Pid]) of
		undefined ->
			false;
		_Pid ->
			true
	end;     
is_process_alive(Node, ProcName) ->
	case rpc:call(Node, erlang, whereis, [ProcName]) of
		undefined ->
			false;
		_Pid ->
			true
	end.      

make_int_str(Int)->
	integer_to_list(Int).

make_int_str2(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0", Str);
		_-> Str
	end.

make_int_str3(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00", Str);
		2-> string:concat("0", Str);
		_-> Str
	end.

make_int_str4(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("000", Str);
		2-> string:concat("00", Str);
		3-> string:concat("0", Str);
		_-> Str
	end.

make_int_str5(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000", Str);
		2-> string:concat("000", Str);
		3-> string:concat("00", Str);
		4-> string:concat("0", Str);
		_-> Str
	end.

make_int_str6(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00000", Str);
		2-> string:concat("0000", Str);
		3-> string:concat("000", Str);
		4-> string:concat("00", Str);
		5-> string:concat("0", Str);
		_-> Str
	end.

make_int_str7(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("000000", Str);
		2-> string:concat("00000", Str);
		3-> string:concat("0000", Str);
		4-> string:concat("000", Str);
		5-> string:concat("00", Str);
		6-> string:concat("0", Str);
		_-> Str
	end.	

make_int_str8(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000000", Str);
		2-> string:concat("000000", Str);
		3-> string:concat("00000", Str);
		4-> string:concat("0000", Str);
		5-> string:concat("000", Str);
		6-> string:concat("00", Str);
		7-> string:concat("0", Str);
		_-> Str
	end.
make_int_str20(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("0000000000000000000", Str);
		2-> string:concat("000000000000000000", Str);
		3-> string:concat("00000000000000000", Str);
		4-> string:concat("0000000000000000", Str);
		5-> string:concat("000000000000000", Str);
		6-> string:concat("00000000000000", Str);
		7-> string:concat("0000000000000", Str);
		8-> string:concat("000000000000", Str);
		9-> string:concat("00000000000", Str);
		10-> string:concat("0000000000", Str);
		11-> string:concat("000000000", Str);
		12-> string:concat("00000000", Str);
		13-> string:concat("0000000", Str);
		14-> string:concat("000000", Str);
		15-> string:concat("00000", Str);
		16-> string:concat("0000", Str);
		17-> string:concat("000", Str);
		18-> string:concat("00", Str);
		19-> string:concat("0", Str);
		_-> Str
	end.
make_int_str30(Int)->
	Str = integer_to_list(Int),
	case string:len(Str) of
		1-> string:concat("00000000000000000000000000000", Str);
		2-> string:concat("0000000000000000000000000000", Str);
		3-> string:concat("000000000000000000000000000", Str);
		4-> string:concat("00000000000000000000000000", Str);
		5-> string:concat("0000000000000000000000000", Str);
		6-> string:concat("000000000000000000000000", Str);
		7-> string:concat("00000000000000000000000", Str);
		8-> string:concat("0000000000000000000000", Str);
		9-> string:concat("000000000000000000000", Str);
		10-> string:concat("00000000000000000000", Str);
		11-> string:concat("0000000000000000000", Str);
		12-> string:concat("000000000000000000", Str);
		13-> string:concat("00000000000000000", Str);
		14-> string:concat("0000000000000000", Str);
		15-> string:concat("000000000000000", Str);
		16-> string:concat("00000000000000", Str);
		17-> string:concat("0000000000000", Str);
		18-> string:concat("000000000000", Str);
		19-> string:concat("00000000000", Str);
		20-> string:concat("0000000000", Str);
		21-> string:concat("000000000", Str);
		22-> string:concat("00000000", Str);
		23-> string:concat("0000000", Str);
		24-> string:concat("000000", Str);
		25-> string:concat("00000", Str);
		26-> string:concat("0000", Str);
		27-> string:concat("000", Str);
		28-> string:concat("00", Str);
		29-> string:concat("0", Str);
		_-> Str
	end.
get_sql_res(Result,Field)->
	case lists:keyfind(Field,1,Result) of
		false-> [];
		{_,Value}->[{Field,Value}]
	end.

%% concat the atoms
cat_atom(Atom1,Atom2)->
	Str1 = case erlang:is_atom(Atom1) of
		       true->atom_to_list(Atom1);
		       _-> Atom1
	       end,
	Str2 = case erlang:is_atom(Atom2) of
		       true->atom_to_list(Atom2);
		       _-> Atom2
	       end,
	list_to_atom(string:concat(Str1,Str2)).

cat_atom(AtomList)->
	F = fun(X)->
			    case erlang:is_atom(X) of
				    true->atom_to_list(X);
				    _-> X
			    end
	    end,
	list_to_atom(lists:concat(lists:map(F, AtomList))).

make_field_list(Fields)->
	string:join(lists:map(fun(X)-> atom_to_list(X) end,Fields),",").

safe_binary_to_list(Bin) when is_binary(Bin)->
	binary_to_list(Bin);
safe_binary_to_list(Bin)->
	Bin.

safe_list_to_binary(List) when is_list(List)->
	list_to_binary(List);
safe_list_to_binary(List)->
	List.
%%
%% call script
%% 
get_script_value(Bin)->
	Str = binary_to_list(Bin), 
	{ok,Ts,_} = erl_scan:string(Str), 
	Ts1 = case lists:reverse(Ts) of 
		      [{dot,_}|_] -> Ts; 
		      TsR -> lists:reverse([{dot,1} | TsR]) 
	      end, 
	{ok,Expr} = erl_parse:parse_exprs(Ts1), 
	{value,V,_} = erl_eval:exprs(Expr, []),
	V.

call_script(Bin)->
	Str = binary_to_list(Bin), 
	{ok,Ts,_} = erl_scan:string(Str), 
	Ts1 = case lists:reverse(Ts) of 
		      [{dot,_}|_] -> Ts; 
		      TsR -> lists:reverse([{dot,1} | TsR]) 
	      end, 
	{ok,Expr} = erl_parse:parse_exprs(Ts1), 
	erl_eval:exprs(Expr, []), 
	ok.	

which_class(ClassId) ->
	if
		(ClassId >= 500000000) and (ClassId < 600000000) ->
			skill;
		true ->
			undefined
	end.
	
get_distance(PosMy,PosEnemy)->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosEnemy,
	erlang:max(erlang:abs(Myx - Enemyx),erlang:abs(Myy - Enemyy)).
	%%erlang:trunc(math:sqrt(math:pow(Myy - Enemyy, 2) + math:pow(Myx - Enemyx, 2))).	
	
is_in_range(PosMy,PosOther,Range)->
	{Myx,Myy} = PosMy,
	{Enemyx,Enemyy} = PosOther,
	((erlang:abs(Myx - Enemyx) =< Range) and (erlang:abs(Myy - Enemyy) =< Range)).

get_argument(Input) when is_atom(Input)->
	case init:get_argument(Input) of
		error-> [];
		{ok, [ArgString]}-> lists:map(fun(E)-> list_to_atom(E) end, ArgString)
	end;
get_argument(Input) when is_list(Input)->
	case init:get_argument(list_to_atom(Input)) of
		error-> [];
		{ok, [ArgString]}-> lists:map(fun(E)-> list_to_atom(E) end, ArgString)
	end;
get_argument(_Input)->
	[].
%%
%% json utils
%%

json_encode({struct,_MemberList}=Term)->
	try
		Json = json:encode(Term),
		{ok,list_to_binary(Json)}
		%%{ok,term_to_binary(Term)}
	catch
		E:R-> 
			slogger:msg("json_encode exception ~p:~p~n~p",[E,R,Term]),
			{error,"Excption!"}
	end;
json_encode(S) when is_binary(S)->
	try
		Json = json:encode(S),
		{ok,list_to_binary(Json)}
	catch
		E:R-> 
			slogger:msg("s_encode exception ~p:~p",[E,R]),
			{error,"Excption!"}
	end;
json_encode(_)->
	{error,"not support!"}.

json_decode(Json) when is_list(Json)->
	try
		Term = json:decode(Json),
		{ok,Term}
	catch
		E:R-> slogger:msg("json_decode exception ~p:~p",[E,R])
	end;
json_decode(Json) when is_binary(Json)->
	try
		Term = json:decode(binary_to_list(Json)),
		{ok,Term}
	catch
		E:R-> slogger:msg("json_decode exception ~p:~p",[E,R])
	end;
json_decode(_)->
	{error}.
	


get_json_member(JsonObj,Member) when is_list(Member)->
	get_json_member_pure(JsonObj,list_to_binary(Member));

get_json_member(JsonObj,Member)when is_binary(Member)->
	get_json_member_pure(JsonObj,Member);

get_json_member(_JsonObj,_Member)->
	{error,"bad arguments"}.

get_json_member_pure(JsonObj,Member)->
	case JsonObj of
		{struct,MemberList}-> 
			case lists:keyfind(Member, 1, MemberList) of
				false-> {error,"cannot find"};
				{_,Value}-> 
					if is_binary(Value)->
						   {ok,binary_to_list(Value)};
					   true->
						   {ok,Value}
					end
			end;
		_-> {error,"bad json"}
	end.

string_match(String,MatchList)->
	M = fun(Match,Acc)->
			case Acc of
				true-> true;
				false->
					case Match of
						"*"-> true;
						_->
							case string:right(Match,1) of
								"*"-> MatchStr = string:left(Match, erlang:length(Match)-1),
									  FindIndx = string:str(String, MatchStr),
									  if
										  FindIndx == 0->false;
										  true-> true
									  end;
								_-> Match =:= String
							end
					end
			end
		end,
	lists:foldl(M, false, MatchList).

escape_uri(S)->
	auth_util:escape_uri(S).

term_to_record(Term,RecordName) ->
	list_to_tuple([RecordName | tuple_to_list(Term)]).

term_to_record_for_list([],TableName) ->
	[];
term_to_record_for_list(Term,TableName) when is_list(Term) ->
	[list_to_tuple([TableName | tuple_to_list(Tup)]) ||Tup <- Term].

	
file_read(FunTerm,FunError,FunProc,FunEof,FileName,ProcNum)->
	case file:open(FileName, read) of
		{ok,Fd}->
			do_file_read(Fd,0,ProcNum,FunTerm,FunError,FunProc,FunEof) ;
		{error,Reason}->
			FunError(Reason)
	end.
			
do_file_read(Fd,Num,ProcNum,FunTerm,FunError,FunProc,FunEof)->
	case io:read(Fd,'') of
		{ok,Term}->
			case ((Num+1) rem ProcNum) of
				0-> FunProc(Num+1);
				_-> nothing
			end,
			FunTerm(Term),
			do_file_read(Fd,Num + 1,ProcNum,FunTerm,FunError,FunProc,FunEof);
		eof ->
			FunEof(); 
		Error-> 
			FunError(Error)
	end.

string_to_term(String)->
	case erl_scan:string(String++".") of
		{ok,Tokens,_}->
			case erl_parse:parse_term(Tokens) of
				{ok,Term}->
					{ok,Term};
				Reason->
					io:format("string_to_term ~p error: ~p ~n~p~n",[String,Reason,erlang:get_stacktrace()]),
					parse_error				
			end;
		Reason->
			io:format("string_to_trm ~p error: ~p ~n~p~n",[String,Reason,erlang:get_stacktrace()]),
			scan_error
	end.

term_to_string(Term)->
	ok.

get_qualty_color(Quality)->
	case Quality of
		0->["#ffffff"];
		1->["#00FF00"];
		2->["#3399ff"];
		3->["#ff00ff"];
		_->["#CD7F32"]
	end.

get_random_list_from_list(List,Count)->
	RandomFun = fun(dummy,{TempList,OriList})->
						Len = erlang:length(OriList),
						Random = random:uniform(Len),
						Tuple = lists:nth(Random,OriList),
						{TempList ++ [Tuple],lists:delete(Tuple, OriList)}
				end,
	{Back,_} = lists:foldl(RandomFun, {[],List}, lists:duplicate(Count, dummy)),
	Back.

%%return [] or datetime{{startyear,startmonth,startday},{starthour,startminute,startsecond}}
get_server_start_time()->
	PlatForm = env:get(platform,[]),
	if 
		PlatForm =:=[]->
			slogger:msg("platform not find in option~n"),
			[];
		true->
			BaseServerId = env:get(baseserverid,0),
			ServerId = env:get(serverid,0),
			ServerNum = ServerId-BaseServerId,
			StartTimeList = env:get2(server_start_time,PlatForm,[]),
			case lists:keyfind(ServerNum, 1, StartTimeList) of
				false->
					slogger:msg("not find server start time ~n"),
					[];
				{_,ServerStartTime}->
					ServerStartTime
			end
	end.


%%
%%return list
%%Format = list
%%Date = [any]
sprintf(Format,Data)->
	TempList = io_lib:format(Format,Data),
	lists:flatten(TempList).

get_random_pos(RateList, RandBase) ->
	Rate = random:uniform(RandBase),
	{Sum1, Pos1} = lists:foldl(fun(Elem, {Sum, Pos}) ->
									 NewSum = Sum + Elem,
									 if Rate =< NewSum ->
											{Sum, Pos};
										true ->
											{NewSum, Pos + 1}
									 end
							 end, {0, 1}, RateList),
	Pos1.
