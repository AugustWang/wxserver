%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2012-9-4
%%% -------------------------------------------------------------------
-module(snapshot).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("mnesia_table_def.hrl").
-define(CHECK_INTERVAL, 55 * 1000).

-record(state, {prefix, category, serverid, date}).

%% ====================================================================
%% External functions
%% ====================================================================

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	SnapshotConfigs = env:get(snapshot, []),
	{_,Prefix} = lists:keyfind(prefix, 1, SnapshotConfigs),
	{_,Category} = lists:keyfind(category, 1, SnapshotConfigs),
	ServerId = env:get(serverid, 1),
	erlang:send_after(?CHECK_INTERVAL, self(), {check_ready}),
    {ok, #state{prefix = Prefix, category = Category, serverid = ServerId, date = {0, 0, 0}}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({check_ready}, State) ->
	#state{prefix = Prefix, category = Category, serverid = ServerId, date = Date} = State,
	{Today,{H,M,S}} =  erlang:localtime(),
	NewDate = case Today of
		Date ->
			Date;
		_ ->
			case {H,M,S} of
				{20, 33, _} ->
					try
						generate_account_snapshot(Prefix, Category, ServerId, Today),
	 					generate_role_snapshot(Prefix, Category, ServerId, Today),
	 					generate_payment_snapshot(Prefix, Category, ServerId, Today),
	 					generate_consume_snapshot(Prefix, Category, ServerId, Today)
					catch
						E : R ->
							slogger:msg("yanzengyan, in snapshot:handle_info:  ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()])
					end,
					Today;
				_ ->
					Date
			end
	end,
	erlang:send_after(?CHECK_INTERVAL, self(), {check_ready}),
    {noreply, State#state{date = NewDate}}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

generate_account_snapshot(Prefix, Category, ServerId, {Year, Month, Day}) ->
	case get_snapshot_file(Prefix, account, Category, ServerId, Year, Month, Day) of
		{ok, File} ->
			do_generate_account_snapshot(File),
			file:close(File);
		{error, Reason} ->
			slogger:msg("generate_account_snapshot failed, reason: ~p~n", Reason)
	end.

generate_role_snapshot(Prefix, Category, ServerId, {Year, Month, Day}) ->
	case get_snapshot_file(Prefix, role, Category, ServerId, Year, Month, Day) of
		{ok, File} ->
			do_generate_role_snapshot(File),
			file:close(File);
		{error, Reason} ->
			slogger:msg("generate_role_snapshot failed, reason: ~p~n", Reason)
	end.

generate_payment_snapshot(Prefix, Category, ServerId, {Year, Month, Day})->
	case get_snapshot_file(Prefix, payment, Category, ServerId, Year, Month, Day) of
		{ok, File} ->
			do_generate_payment_snapshot(File),
			file:close(File);
		{error, Reason} ->
			slogger:msg("generate_payment_snapshot failed, reason: ~p~n", Reason)
	end.

generate_consume_snapshot(Prefix, Category, ServerId, {Year, Month, Day}) ->
	case get_snapshot_file(Prefix, consume, Category, ServerId, Year, Month, Day) of
		{ok, File} ->
			do_generate_consume_snapshot(File),
			file:close(File);
		{error, Reason} ->
			slogger:msg("generate_consume_snapshot failed, reason: ~p~n", Reason)
	end.

get_snapshot_file(Prefix, Type, Category, ServerId, Year, Month, Day) ->
	Dir = Prefix ++ atom_to_list(Type),
	Path = Dir ++ "/" ++ util:sprintf(Category, [Type, ServerId, Year, Month, Day]),
	case filelib:ensure_dir(Path) of
		ok ->
			file:open(Path, write);
		{error, Reason} ->
			{error, Reason}
	end.

do_generate_account_snapshot(File) ->
	case dal:read_rpc(account) of
		{ok, AccountList} ->
			write_account_to_file(File, AccountList);
		_ ->
			nothing
	end.

write_account_to_file(File, [Account | AccountList]) ->
	try
		#account{username = Uid, roleids = RoleIds,local_gold = LocalGold, qq_gold = QQGold,
				  first_login_ip = FirstLoginIp, last_login_ip = LoginIp, last_login_time = LoginTime, 
				 login_days = TotalNum, nickname = Name, gender = Sex,
				 yellow_vip_level = YellowDiamondLevel,is_yellow_year_vip = IsYearYellowVip,
				 first_login_time = AddTime,first_login_platform = AddPlatform, login_platform = LoginPlatform} = Account,
		lists:foreach(fun(RoleId) ->
							  RoleInfo = role_db:get_role_info(RoleId),
							  UserSymbol = "",
							  Contact = "",
							  PrivilegedInfo = "",
							  AddIp = "",
							  Level = role_db:get_level(RoleInfo),
							  Exp = role_db:get_exp(RoleInfo),
							  LoginNum = case continuous_logging_db:get_continuous_logging_info(RoleId) of
											 [] -> 
												 0;
											 {_,{_,_,_,_,_,_,LastDays}} ->
												 LastDays
										 end,
							  PyFriendAmount = -1,
							  QzFriendAmount = -1,
							  RedDiamondLevel = -1,
							  BlueDiamondLevel = -1,
							  State = "",
							  InviteUid = case dal:read_rpc(role_invite_friend_info) of
											  {ok, Result} ->
												  InviteOpenIds = lists:foldl(fun(Record, InviteOpenIds) ->
																					  if length(InviteOpenIds) =:= 1 ->
																							 InviteOpenIds;
																						 true ->
																							 #role_invite_friend_info{roleid = OpenId, friends = Friends} = Record,
																							 case lists:member(Uid, Friends) of 
																								 true->
																									[OpenId];
																								_ ->
																									[]
																							 end
																					  end
																			  end, [], Result),
												  if length(InviteOpenIds) =:= 1 ->
														 lists:nth(1, InviteOpenIds);
													 true ->
														 []
												  end;  
											  _ ->
												  []
										  end,
							  Source = if InviteUid =:= [] ->
											  "0";
										  true -> 
											  "1"
									   end,
							  OpenId = "",
							  Copper = role_db:get_silver(RoleInfo),
							  BangdingCopper = role_db:get_boundsilver(RoleInfo),
							  Install = "",
							  
							  file:write(File, iolist_to_binary(Uid)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, unicode:characters_to_binary(Name)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(RoleId))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(UserSymbol)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(Contact)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(PrivilegedInfo)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(AddTime)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(AddIp)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(FirstLoginIp)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(AddPlatform)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(LoginTime)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(LoginIp)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(LoginPlatform)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Level))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Exp))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, unicode:characters_to_binary(Sex)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(TotalNum))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(LoginNum))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(PyFriendAmount))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(QzFriendAmount))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(RedDiamondLevel))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(YellowDiamondLevel))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(BlueDiamondLevel))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(State)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(Source)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(InviteUid)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(OpenId)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(LocalGold))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(QQGold))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Copper))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(BangdingCopper))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(IsYearYellowVip))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(Install)),
                              file:write(File, iolist_to_binary("\n"))
					  end, RoleIds)
	catch
		E : R ->
			slogger:msg("yanzengyan, in snapshot:write_account_to_file:  ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			slogger:msg("yanzengyan, in snapshot:write_account_to_file, Account: ~p~n", [Account])
	end,
	write_account_to_file(File, AccountList);

write_account_to_file(File, []) ->
	ok.

do_generate_role_snapshot(File) ->
	case dal:read_rpc(account) of
		{ok, AccountList} ->
			write_role_to_file(File, AccountList);
		_ ->
			nothing
	end.

write_role_to_file(File, [Account | AccountList]) ->
	try
		#account{username = Uid, roleids = RoleIds, local_gold = LocalGold, qq_gold = QQGold, first_login_time = RoleCreatedTime} = Account,
		lists:foreach(fun(RoleId) ->
							  RoleInfo = role_db:get_role_info(RoleId),
							  VipLevel = case vip_db:get_vip_role(RoleId) of
											{ok,RoleVip} ->
												case RoleVip of
													[] ->
														0;
													_ ->
														vip_db:get_vip_level(RoleVip)
												end;
											 _ -> 0
										 end,
							  NickName = role_db:get_name(RoleInfo),
							  Occupational = role_db:get_class(RoleInfo),
							  RoleSex = role_db:get_sex(RoleInfo),
							  Liquan = role_db:get_currencygift(RoleInfo),
							  Copper = role_db:get_silver(RoleInfo),
							  BangdingCopper = role_db:get_boundsilver(RoleInfo),
							  Level = role_db:get_level(RoleInfo),
							  Exp = role_db:get_exp(RoleInfo),
							  
							  file:write(File, iolist_to_binary(Uid)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(RoleId))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(VipLevel))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, unicode:characters_to_binary(NickName)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Occupational))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(RoleSex))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(LocalGold))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(QQGold))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Liquan))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Copper))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(BangdingCopper))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(RoleCreatedTime)),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Level))),
							  file:write(File, iolist_to_binary("\t")),
							  file:write(File, iolist_to_binary(integer_to_list(Exp))),
							  file:write(File, iolist_to_binary("\n"))
					  end, RoleIds)
	catch
		E : R ->
			slogger:msg("yanzengyan, in snapshot:write_role_to_file:  ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			slogger:msg("yanzengyan, in snapshot:write_role_to_file, Account: ~p~n", [Account])
	end,
	write_role_to_file(File, AccountList);

write_role_to_file(File, []) ->
	ok.

do_generate_payment_snapshot(File) ->
	Result = payment_db:read_recharge(),
	write_payment_to_file(File, Result).


write_payment_to_file(File, [Record | Result]) ->
	try
		#recharge1{datetime = Time, uid = Uid, money = Money, platform = PayPlatform, vip_level = YellowVip} = Record,
		RoleInfo = role_db:get_role_info(Uid),
		OpenId = role_db:get_account(RoleInfo),
		Source = "yuanbao",
		PayMoney = -1,
		{{Y, M, D}, {H, Min, S}} = Time,
		
		Data = [Y, M, D, H, Min, S, OpenId, Money, Source, PayPlatform,
				 YellowVip, PayMoney],
		Format = "~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w\r~s\r~s\r~s\r~s\r~s\r~s~n",
		io:format(File, Format, Data)
	catch
		E : R ->
			slogger:msg("yanzengyan, in snapshot:write_payment_to_file:  ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			slogger:msg("yanzengyan, in snapshot:write_payment_to_file, Record: ~p~n", [Record])
	end,
	write_payment_to_file(File, Result);

write_payment_to_file(File, []) ->
	ok.

do_generate_consume_snapshot(File) ->
	Result = payment_db:read_consume(),
	write_consume_to_file(File, Result).


write_consume_to_file(File, [Record | Result]) ->
	#consume{billno = BillNo, uid = Uid, datetime = Time, bound_gold = BouldGold,
			  platform_gold = PlatformGold, vip_level = VipLevel, item = Item, 
			 num = Num, price = Price, platform = PayPlatform} = Record,
	RoleInfo = role_db:get_role_info(Uid),
	OpenId = role_db:get_account(RoleInfo),
	Source = "",
	Status = 0,
	WpType = "",
	{{Y, M, D}, {H, Min, S}} = Time,
	
	Data = [BillNo, OpenId, Y, M, D, H, Min, S, BouldGold, PlatformGold,
			 VipLevel, Item, Num, Price, Status, PayPlatform, WpType],
	Format = "~s\r~s\r~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w\r~s\r" ++ 
				 "~s\r~s\r~s\r~s\r~s\r~s\r~s\r~s~n",
	io:format(File, Format, Data),
	write_consume_to_file(File, Result);

write_consume_to_file(File, []) ->
	ok.
		   


