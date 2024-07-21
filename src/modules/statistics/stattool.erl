%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%		统计接口
%%% Created : 2012-7-6
%%% -------------------------------------------------------------------
-module(stattool).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0, stat/6]).

%% gen_server callbacks
%% -export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([init/1, handle_cast/2, handle_cast/3, handle_info/2, terminate/2, code_change/3]).

-include("scribe_types.hrl").
-include("fb303_types.hrl").
-include("stattool.hrl").
-include("role_struct.hrl").

-record(state, {client,category,scence,serverid}).


%% ====================================================================
%% External functions
%% ====================================================================
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%TODO 暂时call to cast
stat(RoleId, OpenId, Pf, Level, Action, Log) ->
	gen_server:cast(?MODULE, {log, RoleId,  OpenId, Pf, Level, Action, Log}).
%%  	gen_server:call(?MODULE, {log, RoleId,  OpenId, Pf, Level, Action, Log}).

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
	ScribeInfos = env:get(scribe, []),
	{_,Host} = lists:keyfind(host, 1, ScribeInfos),
	{_,Port} = lists:keyfind(port,1,ScribeInfos),
	{_,Category} = lists:keyfind(category, 1, ScribeInfos),
	{_,Scence} = lists:keyfind(scence, 1, ScribeInfos),
	ServerId = env:get(serverid, 1),
    %% 打开scribe 端口
	Client = try thrift_client_util:new(Host, Port, scribe_thrift,
                       [{strict_read, false}, 
                        {strict_write, false}, 
                        {framed, true}]) of
				 {ok, C} ->
					 C;
				 _ ->
					 undefined
			 catch
				 _ : _ ->
					 undefined
			 end,
    {ok, #state{client = Client, category=Category, scence=Scence, serverid=ServerId}}.

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
handle_cast({log, RoleId,  OpenId, Pf, Level, Action, Log}, _, State) ->
%% handle_call({log, RoleId,  OpenId, Pf, Level, Action, Log}, _, State) ->
	%%@@slogger:msg("yanzengyan, stattool: Log: ~p ~n", [Log]),
	case env:get(stat_switch, 1) of
		0 ->
			{reply, ok, State};
		1 ->
			#state{category=CategoryFormat, scence=Scence, serverid=ServerId} = State,
			Platform = case Pf of
				"pengyou" ->
					'PY';
				"qzone" ->
					'QZ';
				_ ->
					'QZ'
			end,
			{{Y, Mon, D},{H,M,S}} =  erlang:localtime(),
			Category = util:sprintf(CategoryFormat, [Platform, ServerId, Y, Mon, D]),
			case util:json_encode({struct, Log}) of
				{ok, LogJson} ->	
					Message = util:sprintf(?STAT_FORMAT, [H, M, S, RoleId, Scence, Level, Action, LogJson, "", "", "",  OpenId]),
					try send_msg(State, Category, Message) of
						NewState ->
							{reply, ok, NewState}
					catch 
						E:R ->
							slogger:msg("yanzengyan, stattool: message send error ~n")
					end;
				_ ->
					slogger:msg("yanzengyan, stattool: json_encode error,  RoleId, Pf, Level, Action, Log: ~p ~p ~p ~p ~p ~n",[RoleId, Pf, Level, Action, Log]),
					{reply, ok, State}
			end
	end.


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
handle_info(Info, State) ->
    {noreply, State}.

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
send_msg(State, Category, Message) ->
	%% TODO 如果不成功，再发一次试试，再不成功就放弃
	#state{client = Client} = State,
	if Client =:= undefined ->
		   ignor;
	   true ->
		   thrift_client:call(Client, 'Log', [[#logEntry{category=Category, message=Message}]]),
		   thrift_client:call(Client, 'getStatus', [])
	end,    
    State.

	

