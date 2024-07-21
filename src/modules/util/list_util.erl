%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : list_util.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 30 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(list_util).

-compile(export_all).

get_section(List1, List2) ->
	Is_section = fun(X) ->
				     lists:member(X, List2)
		     end,
	[X|| X <- List1, Is_section(X)].

get_difference(List1, List2) ->
	Section = get_section(List1, List2),
	Difference = fun(X) ->
				     not lists:member(X, Section)
		     end,
	Dif1 = [X|| X <- List1, Difference(X)],
	Dif2 = [X|| X <- List2, Difference(X)],
	Dif1 ++ Dif2.

delete([X|T], X) ->
	T;
delete([H|T], X) ->
	[H|delete(T, X)];
delete([], X) ->
	[].

trunk([X|T], X) ->
	T;
trunk([H|T], X) ->
	trunk(T, X);
trunk([], X) ->
	[].

%% zhangting add 20120718
%% list_util:split(3,[a,b,c,d,e,f,g,h,i,j]).
%% list_util:split(3,[a]).
%% list_util:split(3,[a,b]).
%% list_util:split(3,[a,b,c]).
%% list_util:split(3,[a,b,c,d]).
%% list_util:split(3,[]).
split(Num,List)->
     L1 = length(List),
    if L1>Num ->
        {List1,List2}=lists:split(Num,List),
        [List1|split(Num,List2)];
    true->
         if L1=:=0 -> [];true->[List] end
    end.


%% F = fun(List)
foreach_step(StepN,F,L) when is_integer(StepN) , is_function(F,1) , is_list(L)->
	LSize = erlang:length(L),
	if LSize >StepN->
		   {L1,L2} = lists:split(StepN, L),
		   F(L1),
		   foreach_step(StepN,F,L2);
	   true->
		   F(L)
	end;
foreach_step(_,_,_)->
	nothing.


is_part_of(_,[])->
	false;
is_part_of(List,[_|T]=WholeList)->
	case lists:prefix(List,WholeList) of
		true->
			true;
		false->
			is_part_of(List,T)
	end.
	
replace(OriList,ListReplaced,ListReplace)->
	replace(lists:reverse(OriList),lists:reverse(ListReplaced),lists:reverse(ListReplace),[]).

replace([],_,_,Result)->
	Result;
replace([C|T]=NowList,ListReplaced,ListReplace,ResultTmp)->
	case lists:prefix(ListReplaced,NowList) of
		true->
			replace(NowList -- ListReplaced,ListReplaced,ListReplace,lists:reverse(ListReplace)++ResultTmp);
		false->
			replace(T,ListReplaced,ListReplace,[C|ResultTmp])
	end.
	
	
