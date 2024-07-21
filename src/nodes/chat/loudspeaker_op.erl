%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-14
%% Description: TODO: Add description to loudspeaker_op
-module(loudspeaker_op).
-define(LOUDSPEAKER_CHECK,1000).
-define(LOUDSPEAKER_WAIT,10000).
-define(LOUDSPEAK_OK,1).
-define(MAX_LOUDSPEAKER,1000).
-include("common_define.hrl").

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init/0,answer_loudspeaker_queue_num/1,use_loudspeaker/2,loudspeaker_timer/0]).

%%
%% API Functions
%%

init()->
	put(loudspeakerlist,[]),
	put(presentloudspeaker,{}),
	loudspeaker_timer().


loudspeaker_timer()->
	LoudSpeakerList = get(loudspeakerlist),
	case LoudSpeakerList of
	  	[]->
		  	erlang:send_after(?LOUDSPEAKER_CHECK,self(),{loudspeaker_timer});
	   	_-> 
		   	[PresentLoudSpeaker|NewLoudSpeakerList] = LoudSpeakerList,
		   	{RoleId,RoleName,Message,Details,RoleIden,ServerId} = PresentLoudSpeaker,
		  	Msg = chat_packet:encode_chat_s2c(?CHAT_TYPE_LOUDSPEAKER,?DEST_CHAT,RoleId,RoleName,Message,Details,RoleIden,ServerId,0),
    	   	role_pos_util:send_to_all_online_clinet(Msg),
			WaitNum = length(NewLoudSpeakerList),
			WaitNumMsg = chat_packet:encode_loudspeaker_queue_num_s2c(WaitNum),
			role_pos_util:send_to_all_online_clinet(WaitNumMsg),
		  	put(loudspeakerlist,NewLoudSpeakerList),
			erlang:send_after(?LOUDSPEAKER_WAIT,self(),{loudspeaker_timer})
	end.


%%  request use loudspeaker
use_loudspeaker(RoleId,{RoleName,Msg,Details,RoleIden,ServerId})->	  
	   LoudSpeakerList = get(loudspeakerlist),
	   WaitNum = length(LoudSpeakerList),
	   if  WaitNum=< ?MAX_LOUDSPEAKER->	
			  SensitiveMsg = chat_manager:get_filter_msg(Msg),
	          NewLoudSpeakerList = LoudSpeakerList++[{RoleId,RoleName,SensitiveMsg,Details,RoleIden,ServerId}],
       		  put(loudspeakerlist,NewLoudSpeakerList),
			  NewWaitNum = length(NewLoudSpeakerList),
			  WaitNumMsg = chat_packet:encode_loudspeaker_queue_num_s2c(NewWaitNum),
			  role_pos_util:send_to_all_online_clinet(WaitNumMsg),
	      	  Message = chat_packet:encode_loudspeaker_opt_s2c(?LOUDSPEAK_OK),
   	 		  role_pos_util:send_to_role_clinet(RoleId,Message),
			  true;
		  true->
			  {error,maxloudspeaker}
	   end.

			  
				
%% request wait  num	
answer_loudspeaker_queue_num(RoleId)->
	WaitNum = length(get(loudspeakerlist)),
	Message = chat_packet:encode_loudspeaker_queue_num_s2c(WaitNum),
	role_pos_util:send_to_role_clinet(RoleId,Message).
	
%%
%% Local Functions
%%

