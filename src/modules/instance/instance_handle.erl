%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(instance_handle).

-include("login_pb.hrl").

-export([process_client_msg/1]).

process_client_msg(#init_instance_quality_c2s{instanceid = InstanceId}) ->
	instance_quality_op:get_init_result(InstanceId);
	
process_client_msg(#refresh_instance_quality_c2s{maxqua = MaxQuality, instanceid = InstanceId, usegold = UseGold, auto = Auto}) ->
	instance_quality_op:refresh_quality(MaxQuality, InstanceId, UseGold, Auto).