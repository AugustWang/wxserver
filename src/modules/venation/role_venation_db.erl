%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_venation_db).

-compile(export_all).

-include("venation_def.hrl").

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_venation,record_info(fields,role_venation),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{role_venation,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_venation,RoleId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_info(RoleId)->
	case dal:read_rpc(role_venation,RoleId) of
		{ok,[Info]}-> Info;
		_-> []
	end.

create_venationinfo(RoleId,ActivePoint,ShareExp)->
	Info = #role_venation{roleid = RoleId,
						  active_point = ActivePoint,
						  share_exp = ShareExp,
						  ext = []	
						},
	dal:write_rpc(Info).
%%
%%å·²æ‰“é€šç»è„‰ç©´ä½
%%
get_active_point(Info)->	
	try
		erlang:element(#role_venation.active_point, Info)
	catch
  		_:_-> []
	end.

get_share_exp(Info)->
	try
		erlang:element(#role_venation.share_exp, Info)
	catch
  		_:_-> []
	end.

add_active_point(RoleId,{Venation,Point})->
	VenationInfo = get_info(RoleId),
	Active_Point =  get_active_point(VenationInfo),
	case lists:keyfind(Venation,1,Active_Point) of
		false->
			NewList = [Point],
			New_Active_Point = Active_Point ++ [{Venation,NewList}];
		{_,List}->
			NewList = List ++ [Point],
			New_Active_Point = lists:keyreplace(Venation,1,Active_Point,{Venation,NewList})
	end,
	NewVenationInfo = erlang:setelement(#role_venation.active_point, VenationInfo , New_Active_Point),
	dal:write_rpc(NewVenationInfo).

set_active_point(RoleId,ActivePointInfo)->
	VenationInfo = get_info(RoleId),
	NewVenationInfo = erlang:setelement(#role_venation.active_point, VenationInfo , ActivePointInfo),
	dal:write_rpc(NewVenationInfo).

set_share_exp(RoleId,NewShareExp)->
	VenationInfo = get_info(RoleId),
	NewVenationInfo = erlang:setelement(#role_venation.share_exp, VenationInfo , NewShareExp),
	dal:write_rpc(NewVenationInfo).

get_total_exp(ShareExp)->
	erlang:element(#share_exp.total_share_exp, ShareExp).

get_remain_share_time(ShareExp)->
	erlang:element(#share_exp.remain_share_time, ShareExp).

get_last_time(ShareExp)->
	erlang:element(#share_exp.last_time, ShareExp).

set_total_exp(ShareExp,NewTotalExp)->
	ShareExp#share_exp{total_share_exp=NewTotalExp}.

set_remain_share_time(ShareExp,NewRemainTime)->
	ShareExp#share_exp{remain_share_time=NewRemainTime}.

set_last_time(ShareExp,NewLastTime)->
	ShareExp#share_exp{last_time=NewLastTime}.

make_shareexp(TotalExp,RemainTime,LastTime)->
	#share_exp{
			total_share_exp = TotalExp,
			remain_share_time = RemainTime,
			last_time = LastTime}.
	

