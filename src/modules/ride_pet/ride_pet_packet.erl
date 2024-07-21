%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-17
%% Description: TODO: Add description to ride_pet_packet
-module(ride_pet_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
handle(Message=#ride_pet_synthesis_c2s{},RolePid)-> 
	RolePid!{ride_pet_synthesis,Message};

handle(Message=#item_identify_c2s{},RolePid)-> 
	RolePid!{item_identify,Message};

handle(#ride_opt_c2s{opcode = Op},RolePid)-> 
	RolePid!{ride_opt_c2s,Op};

handle(_,_)->
	nothing.

encode_ride_opt_result_s2c(Error)->
	login_pb:encode_ride_opt_result_s2c(#ride_opt_result_s2c{errno = Error}).

encode_ridepet_synthesis_error_s2c(Error)->
	login_pb:encode_ridepet_synthesis_error_s2c(#ridepet_synthesis_error_s2c{error = Error}). 

encode_ridepet_synthesis_opt_result_s2c(PetTempId,AttrParam)->
	login_pb:encode_ridepet_synthesis_opt_result_s2c(#ridepet_synthesis_opt_result_s2c{pettmpid = PetTempId,resultattr=AttrParam}).

encode_item_identify_error_s2c(Error)->
	login_pb:encode_item_identify_error_s2c(#item_identify_error_s2c{error = Error}). 

encode_item_identify_opt_result_s2c(ItemTmpId)->
	login_pb:encode_item_identify_opt_result_s2c(#item_identify_opt_result_s2c{itemtmpid = ItemTmpId}). 
	
	
	
	
	