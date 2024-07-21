%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : gate_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 10 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(gate_op).

-compile(export_all).

-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").

get_role_list(AccountName,ServerId)->
	AllRoles = role_db:get_role_list_by_account_rpc(AccountName),
	lists:filter(fun(LoginRole)->
						 RoleId = pb_util:get_role_id_from_logininfo(LoginRole),
						 ServerId =:= server_travels_util:get_serverid_by_roleid(RoleId)
				 end,AllRoles).
	
get_last_mapid(RoleId) ->
	case role_db:get_role_info(RoleId) of
		[]-> 100;			%%born map
		RoleInfo->
			role_db:get_mapid(RoleInfo)		
	end.
%%
%%

create_role(AccountId,AccountName,NickName,QQGender,RoleName,Gender,ClassType,CreateIp,ServerId,
			LoginTime,Is_yellow_vip,Is_yellow_year_vip,Yellow_vip_level,Pf)->
	RegisterSwitch = env:get(register_enable,?REGISTER_ENABLE),
	RoleNum = length(get_role_list(AccountName,ServerId)),	
	if
		RoleNum >= 1 ->
			slogger:msg("account ~p ~p one role exist ~n",[AccountId,AccountName]),
			{failed,?ERR_CODE_CREATE_ROLE_EXISTED};
		RegisterSwitch =:= ?REGISTER_ENABLE ->
			case senswords:word_is_sensitive(RoleName)of
				false-> 
					case role_db:create_role_rpc(AccountId,AccountName,RoleName,Gender,ClassType,CreateIp,ServerId) of
						{ok,Result}->
							case dal:read_rpc(account,AccountName) of
								{ok,[AccountInfo]}->
									#account{roleids = OldRoleIds}  = AccountInfo,
									NewAccount = AccountInfo#account{roleids = [Result|OldRoleIds],is_yellow_vip=Is_yellow_vip,
																	 is_yellow_year_vip = Is_yellow_year_vip, yellow_vip_level = Yellow_vip_level,
																	 nickname = NickName, gender = QQGender, login_platform = Pf};
								_->
									NewAccount = #account{username=AccountName,roleids=[Result],gold=0,first_login_ip = CreateIp,first_login_time = LoginTime,
														  is_yellow_year_vip = Is_yellow_year_vip, first_login_platform = Pf, login_platform = Pf,
														  yellow_vip_level = Yellow_vip_level,login_days = 0,nickname = NickName, gender = QQGender,
														  qq_gold=0,local_gold=0}
							end,
							dal:write_rpc(NewAccount),
							{ok,Result};
						{failed,Reason}-> {failed,Reason};
							_Any->{failed,?ERR_CODE_CREATE_ROLE_INTERL}
					end;
				_-> slogger:msg("senswords:word_is_sensitive :failed~n"),
					{failed,?ERR_CODE_ROLENAME_INVALID}
			end;
		true->
			{failed,?ERR_CODE_CREATE_ROLE_REGISTER_DISABLE}	
	end.

create_role(AccountId,AccountName,CreateIp,ServerId)->
	RoleName = binary_to_list(<<"娓稿">>)++ util:make_int_str3(AccountId),
	Gender = random:uniform(2)-1,
	ClassType = random:uniform(3),
	RegisterSwitch = env:get(register_enable,?REGISTER_ENABLE),
	if
		RegisterSwitch =:= ?REGISTER_ENABLE ->	
			case role_db:create_role_rpc(AccountId,AccountName,{visitor,RoleName},Gender,ClassType,CreateIp,ServerId) of
				{ok,Result}->{ok,Result};
				{failed,Reason}-> {failed,Reason};
				_Any->{failed,?ERR_CODE_CREATE_ROLE_INTERL}
			end;
		true->
			{failed,?ERR_CODE_CREATE_ROLE_REGISTER_DISABLE}	
	end.

get_socket_peer(Socket)->
	case inet:peername(Socket) of
		{error, _ } -> [];
		{ok,{Address,_Port}}->
			{A1,A2,A3,A4}= Address,
			string:join([integer_to_list(A1),
						 integer_to_list(A2),
						 integer_to_list(A3),
						 integer_to_list(A4)], ".")
	end.
	
trans_addr_to_list({A1,A2,A3,A4})->
	string:join([integer_to_list(A1),integer_to_list(A2),integer_to_list(A3),integer_to_list(A4)], ".").	
	
check_socket(Socket)->
	case get_socket_peer(Socket) of
		[]-> false;
		IpAddress->
			Ret = gm_block_db:check_block_info(IpAddress,connect),
			if Ret >=0 -> false;
			   true-> true
			end
	end.

update_account_info(AccountName, LoginTime, LoginIp, NickName, QQGender, Pf, Is_yellow_year_vip, Yellow_vip_level) ->
	case dal:read_rpc(account,AccountName) of
		{ok,[AccountInfo]}->
			#account{login_days = LoginDays} = AccountInfo,
			NewAccount = AccountInfo#account{last_login_ip = LoginIp, last_login_time = LoginTime, login_days = LoginDays + 1,
											  is_yellow_year_vip = Is_yellow_year_vip,login_platform = Pf,
											 yellow_vip_level = Yellow_vip_level,nickname = NickName, gender = QQGender},
			dal:write_rpc(NewAccount);
		_->
			slogger:msg("update_login_time_and_ip, error, AccountName, LoginTime, LoginIp: ~p, ~p, ~p~n", [AccountName, LoginTime, LoginIp])
	end.
