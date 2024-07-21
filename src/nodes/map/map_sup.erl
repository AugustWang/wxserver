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
-module(map_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_child/3,stop_child/1]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
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
	supervisor:start_link({local,?MODULE}, ?MODULE, []).


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
    {ok,{{one_for_one,10,10}, []}}.

start_child(MapProcName,MapId_line,Tag)->
	try
		AChild = {MapProcName,{map_processor,start_link,[MapProcName,{MapId_line,Tag}]},
				  	      		transient,2000,worker,[map_processor]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not start map(~p:~p) ~p ~p ~p~n",[E,R,MapProcName,MapId_line,Tag]),
			  {error,R}
 	end.

stop_child(MapProcName)->
	case ets:info(MapProcName) of
		undefined->
			nothing;
		_->
			ets:delete(MapProcName)
	end,
	supervisor:terminate_child(?MODULE, MapProcName),
	supervisor:delete_child(?MODULE, MapProcName).
%% ====================================================================
%% Internal functions
%% ====================================================================

