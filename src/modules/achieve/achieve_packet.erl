%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-13
%% Description: TODO: Add description to achieve_package
-module(achieve_packet).

%%
%% Include files
%%
-export([handle/2]).
-export([encode_achieve_init_s2c/1,encode_achieve_update_s2c/1,encode_achieve_error_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
%%handle(#achieve_open_c2s{},RolePid)->%%@@wb20130228
%%	role_processor:achieve_open_c2s(RolePid);
handle(#achieve_init_c2s{},RolePid)->
	role_processor:achieve_init_c2s(RolePid);
handle(#achieve_reward_c2s{id=Id},RolePid)->
	role_processor:achieve_reward_c2s(RolePid,Id);
handle(_Message,_RolePid)->
	ok.

encode_achieve_init_s2c([{ach_send,Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}])->
	login_pb:encode_achieve_init_s2c(#achieve_init_s2c{achieve_value=Achieve_value,recent_achieve=Recent_achieve,fuwen=Fuwen,achieve_info=Achieve_info,award=Award}).
encode_achieve_update_s2c([{ach_send,Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award}])->
	login_pb:encode_achieve_update_s2c(#achieve_update_s2c{achieve_value=Achieve_value,recent_achieve=Recent_achieve,fuwen=Fuwen,achieve_info=Achieve_info,award=Award}).
encode_achieve_error_s2c(Reason)->
	login_pb:encode_achieve_error_s2c(#achieve_error_s2c{reason=Reason}).
%%
%% Local Functions
%%

