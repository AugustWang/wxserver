%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-5-6
%% Description: TODO: Add description to mysql_conn
-module(mysql_test).
-compile(export_all).
-define(DB, conn).
-define(DB_HOST, "192.168.1.251").
-define(DB_PORT, 3306).
-define(DB_USER, "root").
-define(DB_PASS, "147258").
-define(DB_NAME, "qgqc").
-define(DB_ENCODE, utf8).
-include("config_db_def.hrl").
%%
%% Include files
%%

%%
%% Exported Functions
%%


%%
%% API Functions
%%



%%
%% Local Functions
%%

conn()->
	mysql:start_link(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, fun(_, _, _, _) -> ok end, ?DB_ENCODE),
	mysql:connect(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, ?DB_ENCODE, true),
%% 	mysql:fetch(?DB,<<"truncate table achieve_proto">>),
	ok.

write_term(Term)->
	 ValueList = lists:nthtail(1, tuple_to_list(Term)),
	 TableName=erlang:element(1, Term),
	  FieldList = record_info(fields, achieve_proto),
	insert(TableName, FieldList, ValueList).


insert(TableName, FieldList, ValueList)->
Sql =make_insert_sql(TableName, FieldList, ValueList),
execute(Sql).

make_insert_sql(Table_name, FieldList, ValueList) ->
    L = make_conn_sql(FieldList, ValueList, []),
    lists:concat(["insert into `", Table_name, "` set ", L]).

make_conn_sql([], _, L ) ->
    L ;
make_conn_sql(_, [], L ) ->
    L ;
make_conn_sql([F | T1], [D | T2], []) ->
    L  = ["`",to_list(F), "`='",get_sql_val(D),"'"],
    make_conn_sql(T1, T2, L);
make_conn_sql([F | T1], [D | T2], L) ->
    L1  = L ++ [",`", to_list(F),"`='",get_sql_val(D),"'"],
    make_conn_sql(T1, T2, L1).

get_sql_val(Val) ->
	case is_binary(Val) orelse is_list(Val) of 
		true ->lists:flatten(io_lib:write(Val));
		_-> to_list(Val)
	end.

execute(Sql) ->
    case mysql:fetch(?DB, Sql) of
        {updated, {_, _, _, R, _}} -> R;
        {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason])
    end.

mysql_halt([Sql, Reason]) ->
    catch erlang:error({db_error, [Sql, Reason]}).

ip(Socket) ->
  	{ok, {IP, _Port}} = inet:peername(Socket),
  	{Ip0,Ip1,Ip2,Ip3} = IP,
	list_to_binary(integer_to_list(Ip0)++"."++integer_to_list(Ip1)++"."++integer_to_list(Ip2)++"."++integer_to_list(Ip3)).


%% @doc quick sort
sort([]) ->
	[];
sort([H|T]) -> 
	sort([X||X<-T,X<H]) ++ [H] ++ sort([X||X<-T,X>=H]).

%% for
for(Max,Max,F)->[F(Max)];
for(I,Max,F)->[F(I)|for(I+1,Max,F)].


%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
	A.


%% @doc convert other type to atom
to_atom(Msg) when is_atom(Msg) -> 
	Msg;
to_atom(Msg) when is_binary(Msg) -> 
	list_to_atom2(binary_to_list(Msg));
to_atom(Msg) when is_list(Msg) -> 
   list_to_atom2(Msg);
to_atom(_) -> 
    throw(other_value).  %%list_to_atom("").

%% @doc convert other type to list
to_list(Msg) when is_list(Msg) -> 
    Msg;
to_list(Msg) when is_atom(Msg) -> 
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> 
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) -> 
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> 
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) -> 
 lists:flatten( io_lib:write(Msg));
to_list(Msg) ->
    throw(other_value).
%% @doc convert other type to binary
to_binary(Msg) when is_binary(Msg) -> 
    Msg;
to_binary(Msg) when is_atom(Msg) ->
	list_to_binary(atom_to_list(Msg));
	%%atom_to_binary(Msg, utf8);
to_binary(Msg) when is_list(Msg) -> 
	list_to_binary(Msg);
to_binary(Msg) when is_integer(Msg) -> 
	list_to_binary(integer_to_list(Msg));
to_binary(Msg) when is_float(Msg) -> 
	list_to_binary(f2s(Msg));
to_binary(_Msg) ->
    throw(other_value).

%% @doc convert other type to float
to_float(Msg)->
	Msg2 = to_list(Msg),
	list_to_float(Msg2).
%% @doc convert other type to integer
-spec to_integer(Msg :: any()) -> integer().
to_integer(Msg) when is_integer(Msg) -> 
    Msg;
to_integer(Msg) when is_binary(Msg) ->
	Msg2 = binary_to_list(Msg),
    list_to_integer(Msg2);
to_integer(Msg) when is_list(Msg) -> 
    list_to_integer(Msg);
to_integer(Msg) when is_float(Msg) -> 
    round(Msg);
to_integer(_Msg) ->
    throw(other_value).

to_bool(D) when is_integer(D) ->
	D =/= 0;
to_bool(D) when is_list(D) ->
	length(D) =/= 0;
to_bool(D) when is_binary(D) ->
	to_bool(binary_to_list(D));
to_bool(D) when is_boolean(D) ->
	D;
to_bool(_D) ->
	throw(other_value).

%% @doc convert other type to tuple
to_tuple(T) when is_tuple(T) -> T;
to_tuple(T) -> {T}.

%% @doc get data type {0=integer,1=list,2=atom,3=binary}
get_type(DataValue,DataType)->
	case DataType of
		0 ->
			DataValue2 = binary_to_list(DataValue),
			list_to_integer(DataValue2);
		1 ->
			binary_to_list(DataValue);
		2 ->
			DataValue2 = binary_to_list(DataValue),
			list_to_atom(DataValue2);
		3 -> 
			DataValue
	end.

%% @spec is_string(List)-> yes|no|unicode  
is_string([]) -> yes;
is_string(List) -> is_string(List, non_unicode).

is_string([C|Rest], non_unicode) when C >= 0, C =< 255 -> is_string(Rest, non_unicode);
is_string([C|Rest], _) when C =< 65000 -> is_string(Rest, unicode);
is_string([], non_unicode) -> yes;
is_string([], unicode) -> unicode;
is_string(_, _) -> no.



%% @doc get random list
list_random(List)->
	case List of
		[] ->
			{};
		_ ->
			RS			=	lists:nth(random:uniform(length(List)), List),
			ListTail	= 	lists:delete(RS,List),
			{RS,ListTail}
	end.

%% @doc get a random integer between Min and Max
random(Min,Max)->
	Min2 = Min-1,
	random:uniform(Max-Min2)+Min2.

%% @doc 鎺烽瀛�
random_dice(Face,Times)->
	if
		Times == 1 ->
			random(1,Face);
		true ->
			lists:sum(for(1,Times, fun(_)-> random(1,Face) end))
	end.

%% @doc 鏈虹巼
odds(Numerator, Denominator)->
	Odds = random:uniform(Denominator),
	Odds =< Numerator.

odds_list(List)->
	Sum = odds_list_sum(List),
	odds_list(List,Sum).
odds_list([{Id,Odds}|List],Sum)->
	case odds(Odds,Sum) of
		true ->
			Id;
		false ->
			odds_list(List,Sum-Odds)
	end.
odds_list_sum(List)->
	{_List1,List2} = lists:unzip(List),
	lists:sum(List2).


%% @doc 鍙栨暣 澶т簬X鐨勬渶灏忔暣鏁�
ceil(X) ->
    T = trunc(X),
	if 
		X - T == 0 ->
			T;
		true ->
			if
				X > 0 ->
					T + 1;
				true ->
					T
			end			
	end.


%% @doc 鍙栨暣 灏忎簬X鐨勬渶澶ф暣鏁�
floor(X) ->
    T = trunc(X),
	if 
		X - T == 0 ->
			T;
		true ->
			if
				X > 0 ->
					T;
				true ->
					T-1
			end
	end.
%% 4鑸�5鍏�
%% round(X)

%% subatom
subatom(Atom,Len)->	
	list_to_atom(lists:sublist(atom_to_list(Atom),Len)).

%% @doc 鏆傚仠澶氬皯姣
sleep(Msec) ->
	receive
		after Msec ->
			true
	end.

md5(S) ->        
	Md5_bin =  erlang:md5(S), 
    Md5_list = binary_to_list(Md5_bin), 
    lists:flatten(list_to_hex(Md5_list)). 
 
list_to_hex(L) -> 
	lists:map(fun(X) -> int_to_hex(X) end, L). 
 
int_to_hex(N) when N < 256 -> 
    [hex(N div 16), hex(N rem 16)]. 
hex(N) when N < 10 -> 
       $0+N; 
hex(N) when N >= 10, N < 16 ->      
	$a + (N-10).

list_to_atom2(List) when is_list(List) ->
	case catch(list_to_existing_atom(List)) of
		{'EXIT', _} -> erlang:list_to_atom(List);
		Atom when is_atom(Atom) -> Atom
	end.
	
combine_lists(L1, L2) ->
	Rtn = 
	lists:foldl(
		fun(T, Acc) ->
			case lists:member(T, Acc) of
				true ->
					Acc;
				false ->
					[T|Acc]
			end
		end, lists:reverse(L1), L2),
	lists:reverse(Rtn).


get_process_info_and_zero_value(InfoName) ->
	PList = erlang:processes(),
	ZList = lists:filter( 
		fun(T) -> 
			case erlang:process_info(T, InfoName) of 
				{InfoName, 0} -> false; 
				_ -> true 	
			end
		end, PList ),
	ZZList = lists:map( 
		fun(T) -> {T, erlang:process_info(T, InfoName), erlang:process_info(T, registered_name)} 
		end, ZList ),
	[ length(PList), InfoName, length(ZZList), ZZList ].

get_process_info_and_large_than_value(InfoName, Value) ->
	PList = erlang:processes(),
	ZList = lists:filter( 
		fun(T) -> 
			case erlang:process_info(T, InfoName) of 
				{InfoName, VV} -> 
					if VV >  Value -> true;
						true -> false
					end;
				_ -> true 	
			end
		end, PList ),
	ZZList = lists:map( 
		fun(T) -> {T, erlang:process_info(T, InfoName), erlang:process_info(T, registered_name)} 
		end, ZList ),
	[ length(PList), InfoName, Value, length(ZZList), ZZList ].

get_msg_queue() ->
	io:fwrite("process count:~p~n~p value is not 0 count:~p~nLists:~p~n", 
				get_process_info_and_zero_value(message_queue_len) ).

get_memory() ->
	io:fwrite("process count:~p~n~p value is large than ~p count:~p~nLists:~p~n", 
				get_process_info_and_large_than_value(memory, 1048576) ).

get_memory(Value) ->
	io:fwrite("process count:~p~n~p value is large than ~p count:~p~nLists:~p~n", 
				get_process_info_and_large_than_value(memory, Value) ).

get_heap() ->
	io:fwrite("process count:~p~n~p value is large than ~p count:~p~nLists:~p~n", 
				get_process_info_and_large_than_value(heap_size, 1048576) ).

get_heap(Value) ->
	io:fwrite("process count:~p~n~p value is large than ~p count:~p~nLists:~p~n", 
				get_process_info_and_large_than_value(heap_size, Value) ).

get_processes() ->
	io:fwrite("process count:~p~n~p value is large than ~p count:~p~nLists:~p~n",
	get_process_info_and_large_than_value(memory, 0) ).


list_to_term(String) ->
	{ok, T, _} = erl_scan:string(String++"."),
	case erl_parse:parse_term(T) of
		{ok, Term} ->
			Term;
		{error, Error} ->
			Error
	end.


substr_utf8(Utf8EncodedString, Length) ->
	substr_utf8(Utf8EncodedString, 1, Length).
substr_utf8(Utf8EncodedString, Start, Length) ->
	ByteLength = 2*Length,
	Ucs = xmerl_ucs:from_utf8(Utf8EncodedString),
	Utf16Bytes = xmerl_ucs:to_utf16be(Ucs),
	SubStringUtf16 = lists:sublist(Utf16Bytes, Start, ByteLength),
	Ucs1 = xmerl_ucs:from_utf16be(SubStringUtf16),
	xmerl_ucs:to_utf8(Ucs1).

ip_str(IP) ->
	case IP of
		{A, B, C, D} ->
			lists:concat([A, ".", B, ".", C, ".", D]);
		{A, B, C, D, E, F, G, H} ->
			lists:concat([A, ":", B, ":", C, ":", D, ":", E, ":", F, ":", G, ":", H]);
		Str when is_list(Str) ->
			Str;
		_ ->
			[]
	end.

%%鍘绘帀瀛楃涓茬┖鏍�
remove_string_black(L) ->
	lists:reverse(remove_string_loop(L,[])).

remove_string_loop([],L) ->
	L;
remove_string_loop([I|L],LS) ->
	case I of
		32 ->
			remove_string_loop(L,LS);
        _ ->
			remove_string_loop(L,[I|LS])
	end.


%%鑾峰彇鍗忚鎿嶄綔鐨勬椂闂存埑锛宼rue->鍏佽锛沠alse -> 鐩存帴涓㈠純璇ユ潯鏁版嵁
%%spec is_operate_ok/1 param: Type -> 娣诲姞鐨勫崗璁被鍨�(atom); return: true->鍏佽锛沠alse -> 鐩存帴涓㈠純璇ユ潯鏁版嵁
is_operate_ok(Type, TimeStamp) ->
	NowTime = util:unixtime(),
	case get(Type) of
		undefined ->
			put(Type, NowTime),
    		true;
		Value ->
			case (NowTime - Value) >= TimeStamp of
				true ->
					put(Type, NowTime),
					true;
				false ->
					false
			end
	end.

%%鏇挎崲鎸囧畾鐨勫垪琛ㄧ殑鎸囧畾鐨勪綅缃甆鐨勫厓绱�
%%eg: replace([a,b,c,d], 2, g) -> [a,g,c,d]
replace(List, Key, NewElem) ->
	NewList = lists:reverse(List),
	Len = length(List),
	case Key =< 0 orelse Key > Len of
		true ->
			List;
		false ->
			replace_elem(Len, [], NewList, Key, NewElem)
	end.
replace_elem(0, List, _OldList, _Key, _NewElem) ->
	List;
replace_elem(Num, List, [Elem|OldList], Key, NewElem) ->
	NewList =
		case Num =:= Key of
			true ->
				[NewElem|List];
			false ->
				[Elem|List]
		end,
	replace_elem(Num-1, NewList, OldList, Key, NewElem).

		



	
	
	
									 