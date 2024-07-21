%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-7-11
%% Description: TODO: Add description to activity_value_packet
-module(activity_value_packet).

%%
%% Include files
%%

-compile(export_all).
-include("login_pb.hrl").

%%
%% API Functions
%%
handle(Message=#activity_value_init_c2s{},RolePid)->
	RolePid ! {activity_value,Message};

handle(Message=#activity_value_reward_c2s{},RolePid)->
	RolePid ! {activity_value,Message};

handle(_,_)->
	nothing.
 
make_av(Id,Completed)->
	#av{id = Id,completed = Completed}.	

encode_activity_value_init_s2c(AvList,Value,Status)->
	login_pb:encode_activity_value_init_s2c(#activity_value_init_s2c{avlist= AvList,value = Value,status = Status}).

encode_activity_value_update_s2c(AvList,Value,Status)->
	login_pb:encode_activity_value_update_s2c(#activity_value_update_s2c{avlist = AvList,value = Value,status = Status}).

encode_activity_value_opt_s2c(Code)->
	login_pb:encode_activity_value_opt_s2c(#activity_value_opt_s2c{code = Code}).


