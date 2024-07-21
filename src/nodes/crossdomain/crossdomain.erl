%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(crossdomain).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("network_setting.hrl").

-define(DEFAULT_OPENPORT,[80,8080,8081,8082,8083,8084,8085]).

-define(CROSS_DOMAIN_TCP_OPTIONS, [
								  binary, 
								  {packet, 0}, % no packaging 
								  {reuseaddr, true}, % allow rebind without waiting 
								  {active, false},
								  {exit_on_close, false}
								 ]).


-define(POLICY_PORT,843).

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0, send_file/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([add_port/1, del_port/1,make_normal_cross_file/0]).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================

start_link() ->
	gen_server:start_link({global, ?MODULE},?MODULE, [], []).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	process_flag(trap_exit, true),
	OpenPortList = env:get2(crossport,openport,?DEFAULT_OPENPORT),
	put(openport,OpenPortList),
	put(cross_file,make_cross_file()),
	start_server().

send_file(CSock) ->
	gen_tcp:controlling_process(CSock, self()),
	case gen_tcp:recv(CSock, 0) of
		{ok, ?CROSS_DOMAIN_FLAG} -> 
			CrossFile = get_crossfile(),
			Data = CrossFile,
			gen_tcp:send(CSock, Data);
		_-> error
	end,
	gen_tcp:close(CSock).

add_port(PortList)->
	try
		global:send(?MODULE,{add_port,PortList})
	catch
		E:R->slogger:msg("add port ~p error E:~p R:~p ~n",[PortList,E,R])
	end.

del_port(PortList)->
	try
		global:send(?MODULE,{del_port,PortList})
	catch
		E:R->slogger:msg("del port ~p error E:~p R:~p ~n",[PortList,E,R])
	end.

get_crossfile()->
	try
		gen_server:call({global,?MODULE},{get_crossfile})
	catch
		E:R->slogger:msg("get_crossfile error E:~p R:~p ~n",[E,R]),
		[]
	end.
    
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

handle_call({get_crossfile}, _From, State) ->
    Reply = get(cross_file),
    {reply, Reply, State};

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
handle_info({'EXIT', _Pid, normal}, State) ->
	{stop, normal, State};

handle_info({'EXIT', _Pid, Reason}, State) ->
	case erlang:is_port(State) of
		true -> gen_tcp:close(State)
	end,
	case start_server() of
		{ok, LSock} -> {noreply, LSock};
		{stop, Reason} -> {stop, Reason, State};
		_->{stop,normal}
	end;

handle_info({add_port,PortList},State)->
	add_port_rpc(PortList),
	{noreply, State};

handle_info({del_port,PortList},State)->
	del_port_rpc(PortList),
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

start_server() ->
	%%SName = node_util:get_node_sname(node()),
	SName = node_util:get_match_snode(cross,node()),
	PolicyPort = env:get2(crossport, SName,?POLICY_PORT),
	case gen_tcp:listen(PolicyPort, ?CROSS_DOMAIN_TCP_OPTIONS) of
		{ok, LSock} ->
					  spawn_link(fun() -> loop(LSock) end),
					   %%io:format("listen port :~p~n",[PolicyPort]),
					  {ok, LSock};
		%% @todo throw exception here and we must do this at our work port 
		{error, Reason} ->%%io:format("listen error:~p~n",[Reason]), 
			{stop, Reason}
	end.

loop(LSock) ->
	case gen_tcp:accept(LSock) of
		{ok, CSock} ->%%io:format("socket connect ~p~n",[CSock]),
					  spawn(fun() -> send_file(CSock) end);
		{error, Reason} -> Reason
	end,
	loop(LSock).

get_openportstr()->
	OpenPortList = get(openport),
	OpenPortStrList = lists:map(fun(Port)-> util:make_int_str(Port) end,OpenPortList),
	string:join(OpenPortStrList,",").

make_cross_file()->
	"<?xml version=\"1.0\"?>\n<!DOCTYPE cross-domain-policy SYSTEM "
	++"\"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">\n"
	++"<cross-domain-policy>\n"
    ++"<allow-access-from domain=\"*\" to-ports=\""
	++get_openportstr()
	++"\"/>\n"
    ++"</cross-domain-policy>\n\0".

make_normal_cross_file()->
	"<?xml version=\"1.0\"?>\n<!DOCTYPE cross-domain-policy SYSTEM "
	++"\"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">\n"
	++"<cross-domain-policy>\n"
    ++"<allow-access-from domain=\"*\" to-ports=\"*\"/>\n"
    ++"</cross-domain-policy>\n\0".

add_port_rpc(PortList)->
	%%OpenPortList = get(openport),
	lists:foreach(fun(Port)-> 
				case lists:member(Port,get(openport)) of
					true->
						nothing;
					_->
						put(openport,get(openport) ++ [Port])
				end		
					end,PortList),
	put(cross_file,make_cross_file()).
		

del_port_rpc(PortList)->
	lists:foreach(fun(Port)-> 
				case lists:member(Port,get(openport)) of
					true->
						put(openport,lists:delete(Port,get(openport)));
					_->
						nothing
				end		
					end,PortList),
	put(cross_file,make_cross_file()).
