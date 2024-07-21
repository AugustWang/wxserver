%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: xiaowu
%% Created: 2013-4-17
%% Description: TODO: Add description to furnace_packet
-module(furnace_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([handle/2]).
-export([]).
-compile(export_all).
%%
%% API Functions
%%

handle(Message=#get_furnace_queue_info_c2s{}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#create_pill_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#get_furnace_queue_item_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#accelerate_furnace_queue_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#quit_furnace_queue_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#unlock_furnace_queue_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message};

handle(Message=#up_furnace_c2s {}, RolePid)->
	RolePid!{furnace_packet,Message}.

encode_furnace_queue_info_unit(Queueid, Num, Status, Pillid, Queue_remained_time, Create_pill_remained_time)->
	#furnace_queue_info_unit{queueid=Queueid, 
							 	num=Num, 
								status=Status,
								pillid=Pillid, 
								queue_remained_time=Queue_remained_time, 
								create_pill_remained_time=Create_pill_remained_time}.
encode_furnace_queue_info_s2c(Queues)->
	#furnace_queue_info_s2c{queues = Queues}.

encode_pill(Cur_value,Pillid)->
	#pill{cur_value=Cur_value, pillid=Pillid}.
  
encode_pill_info_s2c(Pills)->
	#pill_info_s2c {pills=Pills}.	

encode_furnace_info_s2c(Level)->
	#furnace_info_s2c {level=Level}.

encode_pill_error_s2c(Errorid)->
	#pill_error_s2c {errorid=Errorid}.