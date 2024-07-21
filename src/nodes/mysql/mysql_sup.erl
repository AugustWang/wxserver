%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrianx-win7
%%% Description :
%%%
%%% Created : 2011-8-31
%%% -------------------------------------------------------------------
-module(mysql_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1,
	 start_mysql/0,
	 stop_mysql/0
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================

start_link()->
	supervisor:start_link({local, ?SERVER},?MODULE, []).


%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
	{ok,{{one_for_one, 20, 60}, []}}.

%% ====================================================================
%% Internal functions
%% ====================================================================
start_mysql()->
	Configs = env:get(mysql,[]),
	{_,Host} = lists:keyfind(host, 1, Configs),
	{_,User} = lists:keyfind(usr,1,Configs),
	{_,Pass} = lists:keyfind(password,1,Configs),
	{_,Port} = lists:keyfind(port,1,Configs),
	{_,DBName} = lists:keyfind(database,1,Configs),
    slogger:msg("===============Mysql server info ============== ===:~p-~p-~p~n",[Host,Port,DBName]),
%% 	Encoding = utf8,
%% 	LoginFunc =  fun(_, _, _, _) -> ok end,
	Args = [mysql_util:get_pool(),Host,Port,User,Pass,DBName],
	try
		AChild = {mysql,{mysql,start_link,Args},
				  	      		permanent,2000,worker,[mysql]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not start mysql(~p:~p)~n",[E,R]),
			  {error,R}
 	end.

stop_mysql()->
	supervisor:terminate_child(?MODULE, mysql),
	supervisor:delete_child(?MODULE, mysql).
