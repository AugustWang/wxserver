%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2011-4-7
%% Description: TODO: Add description to giftcard_op
-module(giftcard_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([auto_gen/2,gen_only_file/3,get_card_number/1]).

%%
%% API Functions
%%


%%
%% Local Functions
%%
%% [0] a b c d e f g h i j 
%% [10]k l m n o p q r s t 
%% [20]u v w x y z A B C D 
%% [30]E F G H I J K L M N 
%% [40]O P Q R S T U V W X 
%% [50]Y Z 0 1 2 3 4 5 6 7
%% [60]8 9 

auto_gen(Times,Count)->
	ServerIds = env:get(serverids,[]),
	AllIdStrings = gen_only_file(ServerIds,Times,Count),
	lists:foreach(fun(IdString)->
			giftcard_db:add_giftcard_to_mnesia([{IdString}])
		end,AllIdStrings).

gen_only_file(ServerIds,Times,Count)->
	EachCount = trunc(Count/erlang:length(ServerIds)), 
	AllIdStrings = lists:foldl(fun(ServerIdTmp,AccIds)->
								   CurIdStrings = gen_id_string(ServerIdTmp,Times,EachCount),
								   save_ids_to_file(ServerIdTmp,Times,CurIdStrings),
								   AccIds++CurIdStrings
								end,[], ServerIds),
	AllIdStrings.

gen_id_string(ServerId,Times,Count)->
	FBC = fun(N)->
				  UniMax = case N of
					 		   0 -> 6;
							   1 -> 6;
							   2 -> 5;
							   3 -> 5;
							   4 -> 5;
							   5 -> 5;
							   6 -> 5;
							   7 -> 5;
							   8 -> 5;
							   9 -> 5
						   end,
				  X = random:uniform(UniMax),
				  Num = X * 10 + N,
				  if (Num >=0) and (Num =< 25 )->
					   97 + Num;
					 (Num >=26) and (Num =< 51)->
					   65 + Num - 26;
					 (Num>= 52) and (Num =< 61)->
					   48 + Num - 52;
					 true
					   -> 48
				  end
		  end,
	Seed = 25931,
	BaseList = lists:seq(Seed, Seed+Count-1),
	Fun = fun(I)->
				  Id1 = I div 100000,
				  LI1 = I rem 100000,
				  Id2 = LI1 div 10000,
				  LI2 = LI1 rem 10000,
				  Id3 = LI2 div 1000,
				  LI3 = LI2 rem 1000,
				  Id4 = LI3 div 100,
				  LI4 = LI3 rem 100,
				  Id5 = LI4 div 10,
				  Id6 = LI4 rem 10,
				  util:make_int_str(ServerId) ++ util:make_int_str2(Times)++ [FBC(Id1),FBC(Id2),FBC(Id3),FBC(Id4),FBC(Id5),FBC(Id6)]
		  end,
	lists:map(Fun, BaseList).

save_ids_to_file(ServerId,Times,IdStrings)->
	case file:open("../config/gift_card-"++util:make_int_str(ServerId) ++ util:make_int_str2(Times) ++ ".config",[write,{encoding,utf8}]) of
		{ok,File}->
		lists:foreach(fun(IdString)->
							io:format(File,"{~p}.~n",[IdString])		  
							  end, IdStrings),	
	file:close(File);
		_-> io:format("Can not open file~n")
	end.

get_card_number(Card)->
    {L1,L2} = lists:split(6,lists:reverse(Card)),
	T = lists:reverse(L1),
    H = lists:reverse(L2),
	IntH = list_to_integer(H) * 1000000,
    T2 = lists:map(fun(C)-> get_char_number(C) + 48  end,T),
	IntH + list_to_integer(T2).

get_char_number(Char)->
   if (Char >= 97) and( Char =< 106) -> Char -97;
      (Char >= 107 ) and( Char =< 116) -> Char -107;
      (Char >= 117 ) and( Char =< 122) -> Char -117;
      (Char >= 65 ) and( Char =< 68) -> Char -65 + 6;
      (Char >= 69 ) and( Char =< 78) -> Char -69;
	  (Char >= 79 ) and( Char =< 88) -> Char -79;
	  (Char >= 89 ) and( Char =< 90) -> Char -89;
	  (Char >= 48 ) and( Char =< 55) -> Char -48 + 2;
      (Char >= 56 ) and( Char =< 57) -> Char -56;
	  true-> 0
   end.
