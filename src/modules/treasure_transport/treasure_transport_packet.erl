%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_transport_packet).

-compile(export_all).

-include("login_pb.hrl").

handle(Message,RolePid)-> 
	RolePid ! {treasure_transport,Message}.

handle_message(#role_treasure_transport_time_check_c2s{})->
	role_treasure_transport:check_transport_overdue();

handle_message({rob_treasure_transport,OtherName,Reward})->
	role_treasure_transport:rob_treasure_transport(OtherName,Reward);

handle_message(#start_guild_treasure_transport_c2s{})->
	role_treasure_transport:start_guild_treasure_transport();

handle_message(#treasure_transport_call_guild_help_c2s{})->
	role_treasure_transport:treasure_transport_call_guild_help().

encode_treasure_transport_time_s2c(Left_time)->
	login_pb:encode_treasure_transport_time_s2c(#treasure_transport_time_s2c{left_time = Left_time}).

encode_treasure_transport_failed_s2c(Reward)->%%@@wb20130420 é•–è½¦è¢«åŠ«åŽç»éªŒå¥–åŠ±ä¸å˜
	login_pb:encode_treasure_transport_failed_s2c(#treasure_transport_failed_s2c{reward=Reward}).

encode_start_guild_transport_failed_s2c(Reason)->
	login_pb:encode_start_guild_transport_failed_s2c(#start_guild_transport_failed_s2c{reason=Reason}).

encode_guild_transport_left_time_s2c(LeftTime)->
	login_pb:encode_guild_transport_left_time_s2c(#guild_transport_left_time_s2c{left_time=LeftTime}).

encode_treasure_transport_call_guild_help_s2c()->
	login_pb:encode_treasure_transport_call_guild_help_s2c(#treasure_transport_call_guild_help_s2c{}).

encode_treasure_transport_call_guild_help_result_s2c(Result)->
	login_pb:encode_treasure_transport_call_guild_help_result_s2c(#treasure_transport_call_guild_help_result_s2c{result=Result}).

encode_server_treasure_transport_start_s2c(LeftTime)->
	login_pb:encode_server_treasure_transport_start_s2c(#server_treasure_transport_start_s2c{left_time=LeftTime}).

encode_server_treasure_transport_end_s2c()->
	login_pb:encode_server_treasure_transport_end_s2c(#server_treasure_transport_end_s2c{}).

encode_rob_treasure_transport_s2c(OtherName,RewardMoney)->
	login_pb:encode_rob_treasure_transport_s2c(#rob_treasure_transport_s2c{othername=OtherName,rewardmoney=RewardMoney}).
	


















