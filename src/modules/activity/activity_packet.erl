%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-9
%% Description: TODO: Add description to activity_packet
-module(activity_packet).

%%
%% Exported Functions
%%
-export([encode_activity_forecast_begin_s2c/5,encode_activity_forecast_end_s2c/1,encode_play_effects_s2c/3]).

%%
%% Include files
%%
-include("login_pb.hrl").


%%
%% API Functions
%%
encode_activity_forecast_begin_s2c(Type,BeginH,BeginM,EndH,EndM)->
	login_pb:encode_activity_forecast_begin_s2c(
					#activity_forecast_begin_s2c{
							type = Type,
							beginhour = BeginH,
							beginmin = BeginM,
							beginsec = 0,
							endhour = EndH,
							endmin = EndM,
							endsec = 0}).

encode_activity_forecast_end_s2c(Type)->
	login_pb:encode_activity_forecast_end_s2c(
					#activity_forecast_end_s2c{type = Type}).

encode_play_effects_s2c(Type,OptRoleId,EffectId)->
	login_pb:encode_play_effects_s2c(#play_effects_s2c{type=Type,optroleid=OptRoleId,effectid=EffectId}).


