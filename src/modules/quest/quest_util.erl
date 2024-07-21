%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-3
%% Description: TODO: Add description to quest_util
-module(quest_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).

%%
%% API Functions
%%
get_status_code(Status)->
	case Status of
		acceptable->1;
		unaccomplished->2;
		accomplished->3;
		failed->4
	end.

get_code_from_status(Code)->
	case Code of
		1->acceptable;
		2->unaccomplished;
		3->accomplished;
		_->4
	end.


%%
%% Local Functions
%%

