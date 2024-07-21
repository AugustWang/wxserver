%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-4-1
%% Description: TODO: Add description to activity_op
-module(activity_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle_join_without_instance/4]).
-include("activity_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
%%
%% API Functions
%%

%%@spec handle all type of activity by user join request
handle_join_without_instance(ActivityType,LevelStart,LevelEnd,Args)->
	RoleLevel = get_level_from_roleinfo(get(creature_info)),
	RoleId = get(roleid),
	RoleName = get_name_from_roleinfo(get(creature_info)),
	case (RoleLevel>=LevelStart) and (RoleLevel=<LevelEnd) of
		true->
			case (not instance_op:is_in_instance()) of
				true->
					case ActivityType of
						?ANSWER_ACTIVITY->
							answer_processor:apply_join_activity({RoleId,RoleName,Args});
						?SPA_ACTIVITY->
							activity_manager:apply_join_activity(?SPA_ACTIVITY,{RoleId,RoleName,Args});
						_->
							no_activity
					end;
				_->
					instance_error
			end;
		_->
			level_error
	end.


%%
%% Local Functions
%%

