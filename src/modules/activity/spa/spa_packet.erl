%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to spa_packet
-module(spa_packet).

%%
%% Include files
%%
-export([handle/2,process_spa/1]).
-export([encode_spa_start_notice_s2c/1,
		 encode_spa_request_spalist_s2c/1,
		 encode_spa_join_s2c/6,
		 encode_spa_error_s2c/1,
		 encode_spa_chopping_s2c/3,
		 encode_spa_swimming_s2c/3,
		 encode_spa_leave_s2c/0,
		 encode_spa_stop_s2c/0,
		 encode_spa_update_count_s2c/2
		 ]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
handle(Message=#spa_join_c2s{},RolePid)->
	RolePid!{spa,Message};
handle(Message=#spa_swimming_c2s{},RolePid)->
	RolePid!{spa,Message};
handle(Message=#spa_chopping_c2s{},RolePid)->
	RolePid!{spa,Message};
handle(Message=#spa_request_spalist_c2s{},RolePid)->
	RolePid!{spa,Message};
handle(Message=#spa_leave_c2s{},RolePid)->
	RolePid!{spa,Message};
handle(_Message,_RolePid)->
	ok.

process_spa(#spa_join_c2s{spaid=SpaId})->
	spa_op:spa_join_c2s(SpaId);
process_spa(#spa_swimming_c2s{roleid=RoleId})->
	spa_op:spa_swimming_c2s(RoleId);
process_spa(#spa_chopping_c2s{roleid=RoleId,slot=Slot})->
	if
		Slot=:=0->
			spa_op:spa_chopping_with_gold(RoleId);
		true->
			item_spa_soap:handle_spa_soap(RoleId, Slot)
	end;
process_spa(#spa_request_spalist_c2s{})->
	spa_op:spa_request_spalist_c2s();
process_spa(#spa_leave_c2s{})->
	spa_op:spa_leave_c2s().
%%
%% Local Functions
%%
encode_spa_start_notice_s2c(Level)->
	login_pb:encode_spa_start_notice_s2c(#spa_start_notice_s2c{level=Level}).
encode_spa_request_spalist_s2c(Spas)->
	login_pb:encode_spa_request_spalist_s2c(#spa_request_spalist_s2c{spas=Spas}).
encode_spa_join_s2c(SpaId,Chopping,Swimming,LeftTime,ChoppingTime,SwimmingTime)->
	login_pb:encode_spa_join_s2c(#spa_join_s2c{spaid=SpaId,
											   chopping=Chopping,
											   swimming=Swimming,
											   lefttime=LeftTime,
											   choppingtime=ChoppingTime,
											   swimmingtime=SwimmingTime}).
encode_spa_chopping_s2c(Name,BeName,Remain)->
	login_pb:encode_spa_chopping_s2c(#spa_chopping_s2c{name=Name,bename=BeName,remain=Remain}).
encode_spa_swimming_s2c(Name,BeName,Remain)->
	login_pb:encode_spa_swimming_s2c(#spa_swimming_s2c{name=Name,bename=BeName,remain=Remain}).
encode_spa_update_count_s2c(NewChopping,NewSwimming)->
	login_pb:encode_spa_update_count_s2c(#spa_update_count_s2c{chopping=NewChopping,swimming=NewSwimming}).
encode_spa_leave_s2c()->
	login_pb:encode_spa_leave_s2c(#spa_leave_s2c{}).
encode_spa_stop_s2c()->
	login_pb:encode_spa_stop_s2c(#spa_stop_s2c{}).
encode_spa_error_s2c(Reason)->
	login_pb:encode_spa_error_s2c(#spa_error_s2c{reason=Reason}).
