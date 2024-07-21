%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-15
%%% -------------------------------------------------------------------
-module(auth_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("user_auth.hrl").
-define(AUTH_FAILED,-1).
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,auth/4]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {auth_algorithm,visitor_key,authtimeout,fatigue_list,nofatigue_list}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]).

auth(FromNode,FromProc,ServerId,UserAuth)->
    global_util:send(?MODULE, {auth_player,{FromNode,FromProc,ServerId,UserAuth}}).

%%is_visitor_c2s
%% auth(FromNode,FromProc,Time,AuthResult)->
%%     global_util:send(?MODULE, {auth_player,{FromNode,FromProc,Time,AuthResult}}).

%% auth(FromNode,FromProc,Time,AuthResult,AccountName)->
%%     global_util:send(?MODULE, {auth_player,{FromNode,FromProc,Time,AuthResult,AccountName}}).

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
	timer_center:start_at_process(),
	CfgTimeOut=env:get(authtimeout, 3600),
	FatigueList = env:get2(fatigue, fatigue_list, []),
	NoFatigueList = env:get2(fatigue, nofatigue_list, []),
	VisitorKey = env:get(visitorkey,""),
	AuthAlgo = env:get(auth_module,auth_db),
    {ok, #state{auth_algorithm=AuthAlgo,visitor_key=VisitorKey,authtimeout=CfgTimeOut,fatigue_list=FatigueList,nofatigue_list=NoFatigueList}}.

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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
%% handle_info({auth_player,{FromNode,FromProc,Time,AuthResult,AccountName}},
%% 			 #state{auth_algorithm=Mod,visitor_key= VisitorKey,authtimeout=CfgTimeOut}=State)->
%% 	Fun = case VisitorKey of
%% 			""-> validate_user_test;
%% 			_->  validate_visitor
%% 		  end,
%%     case Mod:Fun(Time,AuthResult,VisitorKey,CfgTimeOut,false) of
%% 		{ok,{_PlayerId,_AccountName},IsAudult}->
%% 	    	tcp_client:auth_ok(FromNode, FromProc, {finish_visitor,AccountName},AccountName,IsAudult);
%% 		{error, Reason}-> 
%% 	    	slogger:msg("vistor login failed,Reason:~p ~n",[Reason]),
%% 	    	tcp_client:auth_failed(FromNode, FromProc, Reason)
%%     end,
%%     {noreply, State};
%% 
%% %%is_visitor_c2s
%% handle_info({auth_player,{FromNode,FromProc,Time,AuthResult}},
%% 			 #state{auth_algorithm=Mod,visitor_key= VisitorKey,authtimeout=CfgTimeOut}=State)->
%% 	Fun = case VisitorKey of
%% 			""-> validate_user_test;
%% 			_->  validate_visitor
%% 		  end,
%% 	case Mod:Fun(Time,AuthResult,VisitorKey,CfgTimeOut,true) of
%% 		{ok,{PlayerId,PlayerName},IsAudult}->
%% 		    slogger:msg("vistor login successed ~p ~p~n",[PlayerId,PlayerName]),
%% 	    	tcp_client:auth_ok(FromNode, FromProc, {visitor,PlayerId},PlayerName,IsAudult);
%% 		{error, Reason}-> 
%% 	    	slogger:msg("vistor login failed,Reason:~p ~n",[Reason]),
%% 	    	tcp_client:auth_failed(FromNode, FromProc, Reason)
%%     end,
%%     {noreply, State};

%%user_auth_c2s
handle_info({auth_player,{FromNode,FromProc,ServerId,UserAuth}},
			 #state{auth_algorithm=Mod,authtimeout=CfgTimeOut,fatigue_list=FatigueList,nofatigue_list=NoFatigueList}=State)->
	SecretKey =env:get(platformkey, ""),
	Fun = case SecretKey of
			""-> validate_user_test;
			_->  validate_user
		  end,
	#user_auth{username=UserName,userid=UserId,pf=Pf,lgtime=LogTime,userip=UserIp,openid=OpenId,openkey=OpenKey,pfkey=PfKey} = UserAuth,
	%slogger:msg("auth_player userauth:~p~n,serverid ~p ~n",[UserAuth,ServerId]),
	%slogger:msg("mod fun is ~p~n",[{Mod,Fun}]),
	try
		case Mod:Fun(UserAuth,SecretKey,CfgTimeOut,FatigueList,NoFatigueList) of
			{ok,PlayerId,IsAudult}->
				%slogger:msg("~p login successed userid=~p~n",[UserName,PlayerId]),
				tcp_client:auth_ok(FromNode, FromProc,ServerId,PlayerId,UserName,IsAudult);
			{ok,Info}->
				%slogger:msg("qq_auth_ok login successed username=~p  userid=~p~n",[UserName,UserId]),
				tcp_client:qq_auth_ok(FromNode,FromProc,ServerId,UserId,UserName,LogTime,Pf,UserIp,Info,OpenId,OpenKey,PfKey);
			{error, Reason}-> 
				slogger:msg("~p login failed,Reason:~p ~n",[UserName, Reason]),
				tcp_client:auth_failed(FromNode, FromProc, ServerId,Reason)
		end
	catch
		R:E->
			slogger:msg("auth_processor error,R:~p,E:~p,UserAuth:~p~n",[R,E,UserAuth]),
			tcp_client:auth_failed(FromNode, FromProc, ServerId,?AUTH_FAILED)
	end,
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.
%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

