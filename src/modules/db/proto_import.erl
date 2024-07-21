%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2011-4-14
%% Description: TODO: Add description to proto_import
-module(proto_import).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([import/2]).

%%
%% API Functions
%%



%%
%% Local Functions
%%

import(File,Tables)->
%%clear tables
	lists:foreach(fun(Tab)-> dal:clear_table(Tab) end, Tables),
%% consult
	case file:consult(File) of
		{ok, Terms} ->
			Filters = lists:filter(fun(Term)->
										   lists:member(erlang:element(1,Term), Tables)
								   end, Terms),
			
			lists:foreach(fun(Term)-> 
							 dal:write(Term)
						   end , Filters);
		{error, Reason} ->
			slogger:msg("import table error file[~p]:~p file ~p ~n",[File,Reason])
	end.
		
