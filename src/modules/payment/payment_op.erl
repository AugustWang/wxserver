%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: yanzengyan
%% Created: 2012-8-23
%% Description: TODO: Add description to payment_op
-module(payment_op).

%%
%% Exported Functions
%%
-export([get_balance/0]).

%%
%% Include files
%%
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("role_struct.hrl").

%%
%% API Functions
%%

get_balance() ->
	UrlPath = "/v3/pay/get_balance",
	AppId = env:get(id_secret_appid,[]),
	OpenId = get(openid),
	OpenKey = get(openkey),
	Pf = get(pf),
	AppKey = env:get(id_secret_appkey, ""),
	PfKey = get(pfkey),
	{MegaSec,Sec,_} = timer_center:get_correct_now(),
	Seconds = MegaSec*1000000 + Sec,
	ZoneId = env:get(serverid, 1),
	Sig = make_sig(UrlPath, AppId, OpenId, OpenKey, Pf, AppKey, PfKey, Seconds, ZoneId),
	Host = env:get(id_secret_host,[]),
	Params = "openid=" ++ OpenId ++ "&openkey=" ++ OpenKey ++ "&appid=" ++ AppId ++ 
				 "&pf=" ++ Pf ++ "&pfkey=" ++ PfKey ++ "&ts=" ++ integer_to_list(Seconds) ++ 
				 "&zoneid=" ++ integer_to_list(ZoneId) ++ "&sig=" ++ url_util:urlencode(Sig),
	SendUrl = "GET " ++ UrlPath ++ "?" ++ Params ++ " " ++  "HTTP/1.1\r\nHost:" ++ Host
					 ++"\r\n\r\n",
	try
	   case gen_tcp:connect(Host, 80, [{packet,0},binary,{active, true}]) of
		   {ok, Socket} ->
			   case gen_tcp:send(Socket,SendUrl) of
				   ok ->
					   receive
						   {tcp, _, Bin} ->
							   Result = binary_to_list(Bin),
							   {_,JsonObj} = util:json_decode("{" ++ lists:last(string:tokens(Result,"{"))),
							   case handle_json(JsonObj) of
								   {ok, Balance} ->
                                   set_gold(Balance);
									{failed, Error} ->
										payment_packet:encode_qz_get_balance_error_s2c(Error)
							   end;
						   _ -> nothing
					   end;
				   {error, Reason} ->
					   slogger:msg("get_balance send error, reason: ~p~n", [Reason])
			   end,
			   gen_tcp:close(Socket);
		   {error, Reason1} ->
			   slogger:msg("get_balance connect error, reason: ~p~n", [Reason1])
	   end
	catch
		E : R ->
		slogger:msg("buy_goods failed, reason: ~p: ~p~n", [E, R])
	end,
	ok.
	

%%
%% Local Functions
%%
handle_json({struct,_} = Json) ->
	case util:get_json_member(Json,"ret") of
		{ok, 0} ->
			util:get_json_member(Json,"balance");
		{ok, ErrNo} ->
			{failed, ErrNo};
		_ ->
			{failed, 10000}
	end.

make_sig(UrlPath, AppId, OpenId, OpenKey, Pf, AppKey, PfKey, Ts, ZoneId) ->
	Urlencode = url_util:urlencode(UrlPath),
	Dataencode =  url_util:urlencode("appid="++AppId++"&openid="++OpenId++
										 "&openkey="++OpenKey++"&pf="++
										 Pf++"&pfkey="++PfKey++"&ts=" ++ integer_to_list(Ts) ++
										 "&zoneid=" ++ integer_to_list(ZoneId)),
	BaseString = "GET&"++Urlencode++"&"++Dataencode,
	base64:encode_to_string(crypto:sha_mac(AppKey ++ "&", BaseString)).

set_gold(Gold) ->
    AccountName = get(account_id),
    Roleid = get(roleid),
    RoleInfo = get(creature_info),
    Transaction = 
    fun()->
        case mnesia:read(account,AccountName) of
            []->
                [];
            [Account]->
                #account{username=User} = Account,
				  case env:get(use_qq_pay_flag, 0) of
				  0-> NewAccount = Account;	  
				  2-> 
					  if Gold> Account#account.qq_gold ->
					       NewAccount = Account#account{gold=Gold-Account#account.qq_gold+Account#account.gold,qq_gold=Gold};
					  true->
						   NewAccount = Account
					  end;
				  1->	  
                    NewAccount = Account#account{gold=Gold,qq_gold=Gold}
				  end,
                mnesia:write(NewAccount),
                NewAccount
        end
    end,
    case dal:run_transaction_rpc(Transaction) of
        {ok,Result}->
            #account{username=User,roleids=RoleIds,gold=ReGold} = Result,
			NewRoleInfo = set_gold_to_roleinfo(RoleInfo, ReGold),
			NewAttrGold =[{gold, ReGold}],
            role_op:only_self_update(NewAttrGold),
            put(creature_info, NewRoleInfo),
			gm_logger_role:role_gold_change(User,Roleid,Gold,ReGold,buy),
            FRole = fun(RoleId) ->
                case role_pos_util:where_is_role(RoleId) of
                    []->
                        nothing;
                    RolePos->
                        if
                            RoleId =/= Roleid->
                                Node = role_pos_db:get_role_mapnode(RolePos),
                                Proc = role_pos_db:get_role_pid(RolePos),
								role_processor:account_charge(Node, Proc, {account_charge,Gold,ReGold});
                            true->
                                nothing
                        end
                end
            end,
            lists:foreach(FRole, RoleIds);
        _->
            nothing
    end.  
	
