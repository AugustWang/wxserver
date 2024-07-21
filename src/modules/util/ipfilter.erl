%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-27
%% Description: TODO: Add description to ipfilter
-module(ipfilter).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%

match_intip(IntIp,{BIp,EIp})->
	(IntIp >= BIp) and (IntIp =< EIp).

match_tupleip({A,B,C,D},IpStr1,IpStr2)->
try
	{ok, {A1,B1,C1,D1}} = inet_parse:address(IpStr1),
	{ok, {A2,B2,C2,D2}} = inet_parse:address(IpStr2),
	IpT = address_to_integer(A,B,C,D),
	Ip1T = address_to_integer(A1,B1,C1,D1),
	Ip2T = address_to_integer(A2,B2,C2,D2),
	match_intip(IpT,{Ip1T,Ip2T})
catch
	_:_-> false
end;
match_tupleip(_,_,_)->
	false.

match_ipstring(IpString,IpStr1,IpStr2)->
try
	{ok,{A,B,C,D}} = inet_parse:address(IpString),
	{ok, {A1,B1,C1,D1}} = inet_parse:address(IpStr1),
	{ok, {A2,B2,C2,D2}} = inet_parse:address(IpStr2),
	IpT = address_to_integer(A,B,C,D),
	Ip1T = address_to_integer(A1,B1,C1,D1),
	Ip2T = address_to_integer(A2,B2,C2,D2),
	match_intip(IpT,{Ip1T,Ip2T})
catch
	_:_-> false
end.

address_to_integer(A,B,C,D)->
	((A band 16#FF) bsl 24) bor ((B band 16#FF) bsl 16) bor ((C band 16#FF) bsl 8) bor (D band 16#FF).





