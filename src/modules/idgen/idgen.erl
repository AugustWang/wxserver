%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-8-31
%% Description: TODO: Add description to idgen
-module(idgen).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_idmax/1,get_idmax/2,update_idmax/2]).

%%
%% API Functions
%%
get_idmax(Type)->
	case dal:read_rpc(idmax,Type) of
		{ok,[R]}->{_,_,Counter} = R,Counter;
		_->0
	end.

get_idmax(Type,OrigId)->
	case dal:read_rpc(idmax,Type) of
		{ok,[R]}->{_,_,Counter} = R,Counter;
		_->OrigId
	end.


update_idmax(Type,NewValue)->
	dal:async_write_rpc({idmax,Type,NewValue}).


%%
%% Local Functions
%%

