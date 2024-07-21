%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-14
%%% -------------------------------------------------------------------
-module(mapdb_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_mapdb_processor/2]).

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


start_mapdb_processor(MapFile,MapId)->
	
	MapDbProcTag = make_tag(MapId),
	
	ChildSpec = {MapDbProcTag,{mapdb_processor,start_link,[MapFile,MapId]},
			  				permanent,2000,worker,[mapdb_processor]},
	supervisor:start_child(?MODULE, ChildSpec).


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

%% ====================================================================
%% Internal functions
%% ====================================================================

make_tag(MapId)->
	list_to_atom(lists:append([integer_to_list(MapId),"_db"])).
