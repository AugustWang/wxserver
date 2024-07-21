%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-25
%% Description: TODO: Add description to blackip
-module(blackip).

%%
%% Include files
%%
-define(BLACK_IP_TABLE,'$blackiplist$').
%%
%% Exported Functions
%%
-export([create/0,init/0,match/1]).
-compile(export_all).
-behaviour(ets_operater_mod).
%%
%% API Functions
%%
create()->
	ets:new(?BLACK_IP_TABLE, [named_table,set]).

init()->
	ets:delete_all_objects(?BLACK_IP_TABLE),
	case env:get2( blackip, file , []) of
		[]-> ignor;
		File-> case file:consult(File) of
				   {ok,Terms}-> 
					   lists:foreach(fun({Ip1,Ip2})->add_black_ip(Ip1,Ip2) end, Terms);
				   {error,_Reason}->
					   ignor
			   end
	end.

add_black_ip(Ip1,Ip2)->
	{ok, {A1,B1,C1,D1}} = inet_parse:address(Ip1),
	{ok, {A2,B2,C2,D2}} = inet_parse:address(Ip2),
	Ip1T = ipfilter:address_to_integer(A1,B1,C1,D1),
	Ip2T = ipfilter:address_to_integer(A2,B2,C2,D2),
	if  Ip1T=<Ip2T-> 
			IntIp1 = Ip1T,
			IntIp2 = Ip2T;
		true->
			IntIp1 = Ip2T,
			IntIp2 = Ip1T
	end,
	Header =
		if A1 =:= A2 ->
			   if B1 =:= B2->
					  if C1 =:=C2->
							 if D1 =:= D2->
									{A1,B1,C1,D1};
								true->
									{A1,B1,C1}
							 end;
						 true->
							 {A1,B1}
					  end;
				  true->
					  {A1}
			   end;
		   true->
			   {undefined}
		end,
	
	case ets:lookup(?BLACK_IP_TABLE, Header) of
		[]-> 
			ets:insert(?BLACK_IP_TABLE, {Header,[{IntIp1,IntIp2}]});
		[{_,IpTupleList}]->
			ets:insert(?BLACK_IP_TABLE, {Header,[{IntIp1,IntIp2}|IpTupleList]})
	end.

match(IpAddr)->
	{A,B,C,D} = IpAddr,
	IntIp = ipfilter:address_to_integer(A,B,C,D),
	case ets:lookup(?BLACK_IP_TABLE, {A,B,C,D}) of
		[]->
			IpTupleList = case ets:lookup(?BLACK_IP_TABLE, {A,B,C}) of
							  []->
								  case ets:lookup(?BLACK_IP_TABLE, {A,B}) of
									  []->
										  case ets:lookup(?BLACK_IP_TABLE, {A}) of
											  []-> [];
											  [{_,ITL}]-> ITL
										  end;
									  [{_,ITL}]-> ITL
								  end;
							  [{_,ITL}]-> ITL
						  end,
			lists:any(fun(V)-> ipfilter:match_intip(IntIp,V) end, IpTupleList);
			[_]-> true
		end.

	
%%
%% Local Functions
%%

