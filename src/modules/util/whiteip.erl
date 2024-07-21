%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2011-4-20
%% Description: TODO: Add description to whiteip
-module(whiteip).

%%
%% Include files
%%
-define(WHITE_IP_TABLE,'$whiteiplist$').
%%
%% Exported Functions
%%
-export([create/0,init/0,clear/0,match/1,add_ip/1,add_ip_to_ets/1,clear_ets/0]).

-behaviour(ets_operater_mod).
%%
%% API Functions
%%
create()->
	ets:new(?WHITE_IP_TABLE, [named_table,set]).

init()->
	ets:delete_all_objects(?WHITE_IP_TABLE),
	case env:get2(whiteip, file, []) of
		[]-> ignor;
		File-> case file:consult(File) of
				   {ok,[Terms]}-> 
					   lists:foreach(fun(IpAddr)->ets:insert(?WHITE_IP_TABLE,IpAddr) end, Terms);
				   {error,_Reason}->
					   ignor
			   end
	end.

match(IpAddr)->
	case ets:lookup(?WHITE_IP_TABLE,IpAddr) of
		[]-> false;
		_-> true
	end.

add_ip(IpAddr)->
	 lists:foreach(fun(N)-> rpc:call(N,whiteip,add_ip_to_ets,[IpAddr]) end ,node_util:get_gatenodes()).

add_ip_to_ets(IpAddr)->
	applicationex:sp_call(ets,insert,[?WHITE_IP_TABLE,{IpAddr}]).

clear()->
	lists:foreach(fun(N)-> rpc:call(N,whiteip,clear_ets,[]) end ,node_util:get_gatenodes()).

clear_ets()->
	applicationex:sp_call(ets,delete_all_objects,[?WHITE_IP_TABLE]).
	
	
	
	
