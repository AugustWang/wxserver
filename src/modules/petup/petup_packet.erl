%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-1-21
%% Description: TODO: Add description to petup_packet
-module(petup_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2,send_data_to_gate/1,process_petup/1]).
-export([encode_pet_opt_error_s2c/1,encode_pet_up_growth_s2c/2,
		 encode_pet_up_stamina_growth_s2c/2,encode_pet_riseup_s2c/2
		]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% API Functions
%%
%handle(Message=#pet_up_reset_c2s{}, RolePid) ->
	%RolePid!{pet_up,Message};
%handle(Message=#pet_up_growth_c2s{}, RolePid) ->
%	RolePid!{pet_up,Message};
%handle(Message=#pet_up_stamina_growth_c2s{}, RolePid) ->
%	RolePid!{pet_up,Message};
handle(Message=#pet_up_exp_c2s{}, RolePid) ->
	RolePid!{pet_up,Message};
handle(Message=#pet_riseup_c2s{}, RolePid)->
	RolePid!{pet_up,Message};
handle(_Message,_RolePid)->
	ok.

%process_petup(#pet_up_reset_c2s{petid=PetId,reset=Reset,protect=Protect,locked=Locked,pattr=Pattr,lattr=Lattr})->	
%	petup_op:pet_up_reset_c2s(PetId,Reset,Protect,Locked,Pattr,Lattr);
%process_petup(#pet_up_growth_c2s{petid=PetId,needs=Needs,protect=Protect})->
	%petup_op:pet_up_growth_c2s(PetId,Needs,Protect);
%process_petup(#pet_up_stamina_growth_c2s{petid=PetId,needs=Needs,protect=Protect})->
%	petup_op:pet_up_stamina_growth_c2s(PetId,Needs,Protect);
process_petup(#pet_up_exp_c2s{petid=PetId,needs=Needs})->
	item_pet_up_exp:handle_pet_exp(PetId,Needs);
process_petup(#pet_riseup_c2s{petid=PetId,needs=Needs,protect=Protect})->
	petup_op:pet_riseup_c2s(PetId,Needs,Protect).

%encode_pet_up_reset_s2c(PetId,Strength,Agile,Intelligence)->
	%login_pb:encode_pet_up_reset_s2c(#pet_up_reset_s2c{petid=PetId,strength=Strength,agile=Agile,intelligence=Intelligence}).
encode_pet_up_growth_s2c(Result,Next)->
	login_pb:encode_pet_up_growth_s2c(#pet_up_growth_s2c{result=Result,next=Next}).
encode_pet_riseup_s2c(Result,Next)->
	login_pb:encode_pet_up_growth_s2c(#pet_riseup_s2c{result=Result,next=Next}).
encode_pet_up_stamina_growth_s2c(Result,Next)->
	login_pb:encode_pet_up_stamina_growth_s2c(#pet_up_stamina_growth_s2c{result=Result,next=Next}).
encode_pet_opt_error_s2c(Reason)->
	login_pb:encode_pet_opt_error_s2c(#pet_opt_error_s2c{reason=Reason}).

send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).
%%
%% Local Functions
%%

