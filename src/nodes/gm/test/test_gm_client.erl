%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrianx
%%% Description :
%%%
%%% Created : 2010-10-2
%%% -------------------------------------------------------------------
-module(test_gm_client).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {socket,addr,port}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

connect(Address,Port)->
	io:format("~p connect~n",[node()]),
	gs_rpc:cast(node(), ?MODULE, {connect,Address,Port}).

%%send: {"cmd":"auth","username":"","userid":"","time":seonds_from_1970,"flag":secretstring} 
%%            -> auth_algorithm : md5(UserId + urlencode(UserName) + time + "secretkey") == flag 
%%			                      "secretkey"
%%recv: {"cmd":"auth_ok"}
auth(GmUserName, GmUserId)->
	SecretKey = "E3it45taadfasxcyerfs%&*&6uMu67h",
	{MegaSec,Sec,_} = now(),
	Seconds = MegaSec*1000000 + Sec,
	ValStr = integer_to_list(GmUserId)
				++ auth_util:escape_uri(GmUserName) 
				++ integer_to_list(Seconds) ++ SecretKey,
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	Term = {struct,[{<<"cmd">>,<<"auth">>},
					{<<"username">>,GmUserName},
					{<<"userid">>,GmUserId},
					{<<"time">>,Seconds},
					{<<"flag">>,Md5Str}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.

%%recv  {"cmd":Input_response,"result":Result,"addition":Addition } 
%%			Result = "failed" | "error" | "ok"
%%			Addition: Result== "ok"
%%					  Result== "error"

%%send:	{"cmd":"query_player_request","rolename":""}
query_player_request(RoleName)->
	Term = {struct,[{<<"cmd">>,<<"query_player_request">>},
					{<<"rolename">>,RoleName}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.

%%send: {"cmd":"disable_player","rolename":"","lefttime":seconds} -> lefttime= leftseconds 
%% response : cmd = "disable_player_resonse"
disable_player(RoleName,LeftTime)->
	Term = {struct,[{<<"cmd">>,<<"disable_player">>},
					{<<"rolename">>,RoleName},
					{<<"lefttime">>,LeftTime}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.

%%send: {"cmd":"enable_player","rolename":""}
%% response : cmd = "enable_player_resonse"
enable_player(RoleName)->
	Term = {struct,[{"cmd","enable_player"},
					{"rolename",RoleName}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.

%%send: {"cmd":"disable_player_say","rolename":"","lefttime":seconds} -> lefttime= leftseconds
%% response : cmd = "disable_player_say_response"
disable_player_say(RoleName,LeftTime)->
	Term = {struct,[{"cmd","disable_player_say"},
					{"rolename",RoleName},
					{"lefttime",LeftTime}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.
%%send: {"cmd":"enable_player_say","rolename":""}
%% response : cmd = "enable_player_say_response"
enable_player_say(RoleName)->
	Term = {struct,[{"cmd","enable_player_say"},
					{"rolename",RoleName}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.
	
disable_ip_login(IpAddress,LeftTime)->
	Term = {struct,[{"cmd","disable_ip_login"},
					{"ipaddress",IpAddress},
					{"lefttime",LeftTime}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.
enable_ip_login(IpAddress)->
	Term = {struct,[{"cmd","enable_ip_login"},
					{"ipaddress",IpAddress}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_change_role_name(RoleId,NewName)->
	Term = {struct,[{"cmd","gm_change_role_name"},
					{"roleid",RoleId},
					{"newname",NewName}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.
	
	
%%send: {"cmd":"gift_send","rolename":"","gift":[giftid]}
%% response : cmd = "gift_send_response"
gift_send()->
	%% TODO
	ok.
%%send: {"cmd":"gm_notice","id":"id","ntype":"ntype","left_count":"left_count","begin_time":"begin_time",
%%       "end_time":"end_time","interval_time":"interval_time","notice_content":"notice_content"}
%%recv: {"cmd":"add_notice_ok"}
add_gm_notice(Id,Ntype,Left_count,Begin_time,End_time,Interval_time,Notice_content) ->
	Term = {struct,[{"cmd","add_gm_notice"},
					{"id",Id},
					{"ntype",Ntype},
					{"left_count",Left_count},
					{"begin_time",Begin_time},
					{"end_time",End_time},
					{"interval_time",Interval_time},
					{"notice_content",Notice_content}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.
	
publish_gm_notice(Id) ->
	Term = {struct,[{<<"cmd">>,<<"publish_gm_notice">>},
					{<<"id">>,Id}]},
	case util:json_encode(Term) of
		{ok,Data}->
			send(Data);
		{error,Error}-> 
			io:format("json:encode failed:~p~n",[Error])
	end.				
	
user_charge(UserName,Gold) ->
	Term = {struct,[{<<"cmd">>,<<"user_charge">>},
					{<<"username">>,UserName},
					{<<"gold">>,Gold}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_user_charge(UserName,Gold,RoleId) ->
	Term = {struct,[{<<"cmd">>,<<"gm_user_charge">>},
					{<<"username">>,UserName},
					{<<"gold">>,Gold},
					{<<"roleid">>,RoleId}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

online_count()->
	Term = {struct,[{<<"cmd">>,<<"online_count">>}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

facebook_bind(RoleId,FaceBookId)->
	Term = {struct,[{"cmd","gm_facebook_bind"},
					{"roleid",RoleId},
					{"facebook_id",FaceBookId}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_send(FromName,ToName,Title,Content,TemplateId,Count,Add_Silver)->
	Term = {struct,[{"cmd","gm_send"},
					{"fromName",FromName},
					{"toName",ToName},
					{"title",Title},
					{"content",Content},
					{"templateId",TemplateId},
					{"count",Count},
					{"add_Silver",Add_Silver}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_send_all(FromName,ToNames,Title,Content,TemplateId,Count,Add_Silver)->
	Term = {struct,[{"cmd","gm_send"},
					{"fromName",FromName},
					{"toNames",ToNames},
					{"title",Title},
					{"content",Content},
					{"templateId",TemplateId},
					{"count",Count},
					{"add_Silver",Add_Silver}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

loop_tower_week_reward(Type)->
	Term = {struct,[{"cmd","loop_tower_week_reward"},
					{"type",Type}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

get_loop_tower_curlayer()->
	Term = {struct,[{"cmd","get_loop_tower_curlayer"}
		           ]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

system_option(SysIdKey)->
	Term = {struct,[{"cmd","system_option"},
					{"sysIdKey",SysIdKey}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

power_gather()->
	Term = {struct,[{"cmd","power_gather"}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

map_data()->
	Term = {struct,[{"cmd","map_data"}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_move_user(RoleName,MapId,PosX,PosY)->
	Term = {struct,[{"cmd","gm_move_user"},
					{"rolename",RoleName},
					{"mapid",MapId},
					{"posx",PosX},
					{"posy",PosY}]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_delete_mall_item(Id)->
	Term = {struct,[{"cmd","gm_delete_mall_item"},
					{"id",Id}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_update_mall_item(Id,Ntype,Ishot,Sort,Price,Discount)->
	Term = {struct,[{"cmd","gm_update_mall_item"},
					{"id",Id},
					{"ntype",Ntype},
					{"ishot",Ishot},
					{"sort",Sort},
					{"price",Price},
					{"discount",Discount}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_get_role_info(UserName)->
	Term = {struct,[{"cmd","gm_get_role_info"},
					{"username",UserName}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_delete_role_privilege(RoleName)->
	Term = {struct,[{"cmd","gm_delete_role_privilege"},
					{"rolename",RoleName}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_set_role_privilege(RoleName,Privilege)->
	Term = {struct,[{"cmd","gm_set_role_privilege"},
					{"rolename",RoleName},
					{"privilege",Privilege}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_update_activity(Info)->
	Term = {struct,[{"cmd","gm_update_activity"},
					{"info",Info}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_update_global_monster(Info)->
	Term = {struct,[{"cmd","gm_update_global_monster"},
					{"info",Info}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_delete_global_monster(Id)->
	Term = {struct,[{"cmd","gm_delete_global_monster"},
					{"id",Id}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_delete_activity(Info)->
	Term = {struct,[{"cmd","gm_delete_activity"},
					{"info",Info}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

gm_kick_role(RoleName)->
	Term = {struct,[{"cmd","gm_kick_role"},
					{"rolename",RoleName}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.

all_role_vip()->
	Term = {struct,[{"cmd","all_role_vip"}
					]},
	case util:json_encode(Term) of
		{ok,Data} ->
			send(Data);
		{error,Error} ->
			io:format("json:encode failed:~p~n",[Error])
	end.


send(Data)->
	gs_rpc:cast(node(), ?MODULE, {send,Data}).

quit()->
	gs_rpc:cast(node(), ?MODULE, {quit}).
	

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
    {ok, #state{}}.

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
handle_info({connect,Address,Port},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined->
			case gen_tcp:connect(Address, Port, [{packet,2},binary,{active,true},{reuseaddr, true}]) of
				{ok,Socket} ->%% io:format("gen_tcp connect ok~n"),
							   {noreply, State#state{socket=Socket,addr=Address,port=Port}};
				{error,Reason}->
					%%io:format("gen_tcp connect failed~p~n",[Reason]),
					{noreply,State}
			end;
		_->
			%%io:format("client has connect to server (~p:~p)~n",[Addr,Pt]),
			{noreply,State}
	end;
	
handle_info({tcp,Socket,Binary},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	handle_server_json(Binary),
	inet:setopts(Socket, [{active, once}]),
	{noreply, State};

handle_info({tcp_closed, _Socket},StateData) ->
	%%io:format("gm client closed ~n"),
	{noreply, #state{}};

handle_info({quit},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined-> ignor;
		_-> io:format("gm client quit~n"),gen_tcp:close(Sock)
	end,
	{noreply, #state{}};

handle_info({send,Data},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined -> io:format(" have not connect to gmserver");
		_->	case gen_tcp:send(Sock, Data) of
				ok-> io:format("send to client :~p:~p~n",[Addr,Pt]);
				{error,Reason}->
					io:format("send to client error :~p~n",[Reason])
			end
	end,
    {noreply, State};
handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	%%io:format("gm client terminate ~p~n",[Reason]),
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
handle_server_json(Bin)->
	case util:json_decode(Bin) of
		{ok,JsonObj}-> 
			handle_json(JsonObj);
		{error,_JsonError}-> ignor;
		_-> exception
	end.

handle_json({struct,_JsonMember} = JsonObj)->
	Cmd = util:get_json_member(JsonObj,"cmd"),
	io:format("cmd: ~p ~n",[Cmd]),
	case Cmd of
		{ok,"auth_ok"}-> handle_json_auth_ok(JsonObj);
		{ok,"add_gm_notice_response"}->handle_json_gmnotice_ok(JsonObj);
		{ok,"user_charge_response"}->handle_json_user_charge_ok(JsonObj);
		{ok,"online_count_response"}->handle_json_online_count_ok(JsonObj);
		{ok,"gm_send_response"}->handle_json_gm_send_ok(JsonObj);
		{ok,"loop_tower_week_reward_response"}->handle_json_loop_tower_week_reward_ok(JsonObj);
		{ok,"disable_player_response"}->handle_disable_player_ok(JsonObj);
		{ok,"disable_player_say_response"}->handle_disable_player_say_ok(JsonObj);
		{ok,"power_gather_response"}->handle_power_gather_ok(JsonObj);
		{ok,"get_loop_tower_curlayer_response"}->handle_json_get_loop_tower_curlayer_ok(JsonObj);
		{ok,"gm_set_role_privilege_response"}->handle_json_gm_set_role_privilege_ok(JsonObj);
		{ok,"gm_kick_role_response"}->handle_json_gm_kick_role_ok(JsonObj);
		{ok,"all_role_vip_response"}->handle_all_role_vip_response_ok(JsonObj);
		_-> ignor
	end.

handle_json_auth_ok(JsonObject)->
	io:format("recive auth_ok json ~p~n",[JsonObject]).
handle_json_gmnotice_ok(JsonObject)->
	io:format("recive add_gm_notice_response json ~p~n",[JsonObject]).
handle_json_user_charge_ok(JsonObject)->
	io:format("recive user_charge_response json ~p~n",[JsonObject]).
handle_json_online_count_ok(JsonObject)->
	io:format("recive online_count_response json ~p~n",[JsonObject]).
handle_json_gm_send_ok(JsonObject)->
	io:format("recive gm_send_response json ~p~n",[JsonObject]).
handle_json_loop_tower_week_reward_ok(JsonObject)->
	io:format("recive loop_tower_week_reward_response json ~p~n",[JsonObject]).
handle_disable_player_ok(JsonObject)->
	io:format("recive disable_player_response json ~p~n",[JsonObject]).
handle_disable_player_say_ok(JsonObject)->
	io:format("recive disable_player_say_response json ~p~n",[JsonObject]).
handle_power_gather_ok(JsonObject)->
	io:format("recive power_gather_response json ~p~n",[JsonObject]).
handle_json_get_loop_tower_curlayer_ok(JsonObject)->
	io:format("recive get_loop_tower_curlayer json ~p~n",[JsonObject]).
handle_json_gm_set_role_privilege_ok(JsonObject)->
	io:format("recive handle_json_gm_set_role_privilege_ok json ~p~n",[JsonObject]).
handle_json_gm_kick_role_ok(JsonObject)->
	io:format("recive handle_json_gm_kick_role_ok json ~p~n",[JsonObject]).
handle_all_role_vip_response_ok(JsonObject)->
	io:format("recive handle_all_role_vip_response_ok json ~p~n",[JsonObject]).

t()->
	start_link(),
	test_gm_client:connect("127.0.0.1",env:get2(gmport, gm, 1080)),
	test_gm_client:auth("abc",123).
%% 	lists:foreach(fun (X) ->
%%       add_gm_notice(X,X rem 3,X,1287991828+X*60,1288991828+X*10*60,30000+X*1000,[X|"xxxx"])        
%%                end,lists:seq(1,100)).
	
	%%test_gm_client:publish_gm_notice(1).
	%%test_gm_client:disable_ip_login("192.168.1.105",30).
