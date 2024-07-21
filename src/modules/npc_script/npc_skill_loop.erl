%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-2-7
%% Description: TODO: Add description to npc_skill_loop
-module(npc_skill_loop).

%%
%% Include files
%%
-export([proc_special_msg/1,init/0]).


-define(CHECK_TIME_DURATION,2000).		%%2s
%%
%% Exported Functions
%%

%%
%% API Functions
%%
init()->
	loop_check().

proc_special_msg({skill_loop_check})->
	%%check hibernate
	case get(hibernate_tag) of
		false->
			%% check aoi
			case get(aoi_list) of
				[]->
					nothing;
				_->
					put(targetid,get(id)),
					npc_op:attack(get(id))
			end;
		_->
			nothing
	end,
	loop_check();

proc_special_msg(_)->
	nothing.

%%
%% Local Functions
%%

loop_check()->
	erlang:send_after(?CHECK_TIME_DURATION,self(),{skill_loop_check}).
