%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-2-13
%% Description: TODO: Add description to npc_auto_skill
-module(npc_auto_skill).
%%
%% Include files
%%
-export([proc_special_msg/1,init/0]).


-define(CHECK_TIME_DURATION,10).		%%10s
-define(LEAVE_MAP_TIME,2000).		%%2s
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
	erlang:send_after(?LEAVE_MAP_TIME,self(),{forced_leave_map});
%%	loop_check();

proc_special_msg(_)->
	nothing.

%%
%% Local Functions
%%

loop_check()->
	erlang:send_after(?CHECK_TIME_DURATION,self(),{skill_loop_check}).