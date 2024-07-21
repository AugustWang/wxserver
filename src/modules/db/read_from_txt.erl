%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-6-20
%% Description: TODO: Add description to read_from_txt
-module(read_from_txt).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_files/1,get_object/1,get_file_text/2,string_to_term/1]).
-define(ETS_ITEM_PROTO,item_proto_ets).

%%
%% API Functions
%%



%%
%% Local Functions
%%
get_object(Path)->
	Filenames=get_files(Path),
	get_file_text(Path,Filenames).
	

get_files(Path)->
	case file:list_dir(Path) of
		{ok, Filenames}->
			Filenames;
		{error, Reason}->
			io:format("get files error,error is ~p~n",[Reason]),
			[]
	end.

get_file_text(Path,Names)->
	lists:map(fun(File_name)->
					  File_path=Path++"/"++File_name,
					  	case file:open(File_path, read) of
						{ok,Fd}->
							read_file(File_name,Fd,1);
						{error,Reason}->
							io:format(" file ~p  open error ,error is ~p~n",[Path,Reason])
						end
					  end, Names).

read_file(FileName,Fd,Num)->
	case file:read_line(Fd) of
		{ok, Data}->
			if Num>2->
				  Len=string:len(FileName),
				 Name=string:left(FileName,Len-4),
				AName=erlang:list_to_atom(Name),
				 if AName=:=auto_name->
						ListValue=explain_auto_name(Data,Num);
					true->
						ListValue=explain_text(Data,Num)
				 end,
				Value=erlang:list_to_tuple([AName|ListValue]),
				 dal:write(Value);
			   true->
				   nothing
			end,
			read_file(FileName,Fd,Num+1);
		 eof->
			 nothing;
		{error, Reason}->
			nothing
	end.

explain_text(Data,Num)->
	if Num>2->
		   Len=string:len(Data),
		   NewData=string:left(Data, Len-1),
		   Str=string:tokens(NewData, "\t"),
		   NewValue=lists:map(fun(X)->
							 case string_to_term(X) of
								error->
									[X1|_]=X,
									if X1=:=91->
										   NewX=string:tokens(X, "[]"),
										   Result=lists:map(fun(Y)->erlang:list_to_binary(Y) end,NewX),
										   Result;
									   true->
											erlang:list_to_binary(X)
									end;
								 Value->
									 Value
									end end , Str);
	   true->
		   nothing
	end.

explain_auto_name(Data,Num5)->
	if Num5>2->
		[Name_Num|_]=Data,
		if Name_Num=:=49->
			   Len=string:len(Data),
		  	   NewData=string:left(Data, Len-1),
			   Str=string:tokens(NewData, "\t"),
			    [Num,First_Name,LastName]=Str,
			    Num1=string_to_term(Num),
			    NewFirstName=string:tokens(First_Name, ","),
			    First_Name_value=lists:map(fun(X)->
												  erlang:list_to_binary(X) end, NewFirstName),
			    Str_Last_Name=string:tokens(LastName, "[]"),
			   Vlaue_names_lsit=lists:map(fun(Value2)-> case string_to_term of
										   error->
											   [];
										   Value->
											   if (Value2=:="{") or (Value2=:="}")->
													  [];
												  true->
													   NewList=string:tokens(Value2, ","),
													   lists:map(fun(X)-> erlang:list_to_binary(X) end,NewList) 
											   end
									   end
									   end,Str_Last_Name),
			 Value_name_termlistq1=lists:foldl(fun(Q1,Acc1)-> if Q1=:=[]->Acc1;true->[Q1|Acc1] end end,[],Vlaue_names_lsit),
			 [Num1,First_Name_value,erlang:list_to_tuple(Value_name_termlistq1)];
		   true->
			   Len=string:len(Data),
		  	   NewData=string:left(Data, Len-1),
			   Str=string:tokens(NewData, "\t"),
			   [Num,First_Name,LastName]=Str,
			   Num1=string_to_term(Num),
			   NewFirstName=string:tokens(First_Name, ","),
			   First_Name_value=lists:map(fun(X)->
												  erlang:list_to_binary(X) end, NewFirstName),
			   Str_Last_Name=string:tokens(LastName, "{}"),
			   [Value1,_,Value2]=Str_Last_Name,
			   Value_name1=string:tokens(Value1,"[]"),
			   Value_name2=string:tokens(Value2, "[]"),
			   Value_name_termlist1=lists:map(fun(P1)-> lists:map(fun(PP1)->erlang:list_to_binary(PP1) end, string:tokens(P1, ",")) end,Value_name1),
			   Value_name_termlist2=lists:map(fun(P2)-> lists:map(fun(PP2)->erlang:list_to_binary(PP2) end, string:tokens(P2, ",")) end,Value_name2),
			   Value_name_termlistq1=lists:foldl(fun(Q1,Acc1)-> if Q1=:=[]->Acc1;true->[Q1|Acc1] end end,[],Value_name_termlist1),
			   Value_name_termlistq2=lists:foldl(fun(Q2,Acc2)-> if Q2=:=[]->Acc2;true->[Q2|Acc2] end end,[],Value_name_termlist2),
			   Value_name_tuplelsit1=erlang:list_to_tuple(lists:reverse(Value_name_termlistq1)),
			   Value_name_tuplelsit2=erlang:list_to_tuple(lists:reverse(Value_name_termlistq2)),
			   [Num1,First_Name_value,{[Value_name_tuplelsit1],[Value_name_tuplelsit2]}]
		end;
	   ture->
		   nothing
	end.

string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> error
            end;
        _Error ->
           undefine
    end.

check_tuple_term(Value) when erlang:is_tuple(Value)->
	erlang:list_to_tuple(check_tuple_term(erlang:tuple_to_list(Value)));
check_tuple_term(Value) when erlang:is_list(Value)->
	case string_to_term(Value) of
		error->
			
			erlang:list_to_binary(Value);
		Value->
			check_tuple_term(Value)
	end.

