%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(instance_packet).

%%
%% Include files
%%
-export([handle/2]).

-export([encode_instance_leader_join_s2c/1, encode_refresh_instance_quality_s2c/4, encode_refresh_instance_quality_opt_s2c/1,
		 encode_refresh_instance_quality_result_s2c/3]).


-include("login_pb.hrl").
-include("data_struct.hrl").

handle(#instance_leader_join_c2s{},RolePid)->
	RolePid ! {instance_leader_join_c2s};

handle(Message=#instance_entrust_c2s{},RolePid)->
	RolePid ! {instance_entrust,Message};

handle(#instance_exit_c2s{},RolePid)->
	RolePid ! {instance_exit_c2s};

handle(Message,RolePid)->
	RolePid ! {instance_from_client,Message}.

encode_instance_leader_join_s2c(InstanceProtoId)->
	login_pb:encode_instance_leader_join_s2c(#instance_leader_join_s2c{instanceid = InstanceProtoId}).

encode_refresh_instance_quality_s2c(InstanceId, FreeTime, AllFreeTime, Nq) ->
	login_pb:encode_refresh_instance_quality_s2c(#refresh_instance_quality_s2c{instanceid = InstanceId, freetime = FreeTime, totalfreetime = AllFreeTime, npclist = Nq}).

encode_refresh_instance_quality_opt_s2c(ErrorId) ->
	login_pb:encode_refresh_instance_quality_opt_s2c(#refresh_instance_quality_opt_s2c{errno = ErrorId}).

encode_refresh_instance_quality_result_s2c(FreeTimes, ItemTimes, Gold) ->
	login_pb:encode_refresh_instance_quality_result_s2c(#refresh_instance_quality_result_s2c{freetimes = FreeTimes, itemtimes = ItemTimes, gold = Gold}).
 
