%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-31
%% Description: TODO: Add description to url_util
-module(url_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([urlencode/1,
		 urldecode/1,
		 convert_file/2,
		 convert_file/1,
		 convert_dir/1,
		 convert_dir/2,
		 convert_dir/0]).

%%
%% API Functions
%%

%%
%% Local Functions
%%

urlencode(S) when is_list(S) ->
    urlencode(unicode:characters_to_binary(S));
urlencode(<<C:8, Cs/binary>>) when C >= $a, C =< $z ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) when C >= $A, C =< $Z ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) when C >= $0, C =< $9 ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) when C == $. ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) when C == $- ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) when C == $_ ->
    [C] ++ urlencode(Cs);
urlencode(<<C:8, Cs/binary>>) ->
    escape_byte(C) ++ urlencode(Cs);
urlencode(<<>>) ->
    "".

escape_byte(C) ->
    "%" ++ hex_octet(C).

hex_octet(N) when N =< 9 ->
    [$0 + N];
hex_octet(N) when N > 15 ->
    hex_octet(N bsr 4) ++ hex_octet(N band 15);
hex_octet(N) ->
    [N - 10 + $A].

urldecode(String)when is_list(String)->
	urldecode_binary(list_to_binary(String),<<>>);
urldecode(Binary)when is_binary(Binary)->
	urldecode_binary(Binary,<<>>).

urldecode_binary(<<>>, <<Processed/binary>>) -> Processed;

urldecode_binary(<<($\%):8, H:8, L:8, String/binary>>, <<Processed/binary>>)
when
  ((H =< 16#39) andalso (H >= 16#30))
  orelse ((H >= 16#41) andalso (H =< 16#46))
  orelse ((H >= 16#61) andalso (H =< 16#66))
  ,
  ((L =< 16#39) andalso (L >= 16#30))
  orelse ((L >= 16#41) andalso (L =< 16#46))
  orelse ((L >= 16#61) andalso (L =< 16#66))
->
  H_nibble = char_to_integer_digit(H),
  L_nibble = char_to_integer_digit(L),
  urldecode_binary(String, <<Processed/binary, H_nibble:4, L_nibble:4>>);

urldecode_binary(<<Byte:8, String/binary>>, <<Processed/binary>>) ->
  urldecode_binary(String, <<Processed/binary, Byte:8>>).

char_to_integer_digit(Char) when Char < 16#41 -> Char - 16#30;
char_to_integer_digit(Char) when Char < 16#61 -> Char - 16#37;
char_to_integer_digit(Char) -> Char - 16#57.


convert(String)->
	StringList = string:tokens(String,"&"),
	NewStringList = lists:map(fun(X)-> [Key,Value]=case string:tokens(X, "=")of
													[K]->[K,""];
                                                    [K,V]->[K,V]
													end,
									   case string:str(Value, "%") of
										   0-> Key ++ "=" ++ Value;
										   _-> WrongString = urldecode(Value),
											   CorrectValue = unicode:characters_to_list(WrongString),
											   Key ++ "=" ++ urlencode(list_to_binary(CorrectValue))
									   end
							  end, StringList),
	string:join(NewStringList, "&").
			
convert_file(InputFile)->
	convert_file(InputFile,InputFile).

convert_file(InputFile,OutputFile)->
	case file:open(InputFile, read) of
		{ok,Fd}-> NewString = process_line(Fd),
				  file:close(Fd),
				  case file:open(OutputFile, write)of
					  {ok,OutFd}-> file:write(OutFd, NewString),file:close(OutFd);
					  {error,_}-> io:format("can not write file: ~p~n",[OutputFile])
				  end;
		{error, _Reason}-> io:format("can not read file: ~p~n",[InputFile])
	end.
		
process_line(Fd)->
	case file:read_line(Fd) of
		{ok,String}-> convert(String) ++ process_line(Fd);
		eof-> [];
		 {error, _Reason}-> []
	end.

convert_dir(InputDir)->
	convert_dir(InputDir,InputDir).

convert_dir(InputDir,OutputDir)->
	case file:list_dir(InputDir) of
		{ok,FileList}->
			lists:foreach(fun(X)-> 
								  case filelib:is_dir(InputDir ++ X) of
									  true-> convert_dir(InputDir ++ X ++ "/",OutputDir ++ X ++ "/");
									  _->
										  filelib:ensure_dir(OutputDir),
										  convert_file(InputDir ++ X,OutputDir ++ X)
								  end
						  end, FileList);
		{error,Reason}-> io:format("error:~p~n",[Reason])
	end.
convert_dir()->
	{ok,[[Input]]} = init:get_argument('-input'),
	{ok,[[Output]]} = init:get_argument('-output'),
	convert_dir(Input,Output),
	erlang:halt().