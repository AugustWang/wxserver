%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhangting 
%% Created: 2012-7-10
%% Description: TODO: Add description to invite_friend_packet
-module(invite_friend_packet).

%%
%% Exported Functions
%%
-compile(export_all).
-include("login_pb.hrl").
%%
%% API Functions
%%
handle(Message=#invite_friend_gift_get_c2s{},RolePid)->
	RolePid!{invite_friend,Message};

handle(Message=#invite_friend_add_c2s{},RolePid)->
	RolePid!{invite_friend,Message};

handle(Message=#invite_friend_board_c2s{},RolePid)->
	RolePid!{invite_friend,Message}.

encode_invite_friend_board_s2c(JoinFriendsSize,Amount_awards)->
	%slogger:msg("invite_friend_packet:encode_invite_friend_board_s2c 20120629 zhangting JoinFriendsSize:~p,Amount_awards:~p~n",[JoinFriendsSize,Amount_awards]),
	login_pb:encode_invite_friend_board_s2c(#invite_friend_board_s2c{friends_size=JoinFriendsSize,amount_awards=Amount_awards}).

encode_invite_friend_gift_get_ret_s2c(Result,Amount)->
    %slogger:msg("invite_friend_packet:encode_invite_friend_opt_result_s2c 20120629 zhangting result:~p~n",[Result]),
	login_pb:encode_invite_friend_gift_get_ret_s2c(#invite_friend_gift_get_ret_s2c{type=Amount,result = Result}).



