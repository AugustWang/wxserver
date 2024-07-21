%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhangting 
%% Created: 2012-7-10
%% Description: TODO: Add description to invite_friend_op
-module(invite_friend_op).

%%
%% Include files
%%
-export([load_from_db/1,export_for_copy/0,load_by_copy/1,invite_friend_board_c2s/0,get_gift/1,process_message/1]).

%% Exported Functions
%%
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("string_define.hrl").
-include("login_pb.hrl").
-include("invite_friend_def.hrl").

%%处理获取礼物协议 by zhangting
process_message({invite_friend_gift_get_c2s,_,Amount})->
   %slogger:msg("invite_friend_op:process_message invite_friend_gift_c2s invite_friend_gift_c2s Amount:~p  ~n",[Amount]),
	get_gift(Amount);

%%处理弹出好友送礼模板协议  by zhangting
process_message({invite_friend_board_c2s,_})->
	%slogger:msg("invite_friend_op:process_message  invite_friend_board_c2s  ~n"),
	invite_friend_board_c2s();

%%处理加入好友模板协议  by zhangting
process_message({invite_friend_add_c2s,_,JoinFriends})->
	%slogger:msg("invite_friend_op:process_message  invite_friend_add_c2s  ~n"),
	invite_friend_add_c2s(JoinFriends).

%%初始化模板  by zhangting
load_from_db(RoleId)->
	Info = invite_friend_db:get_invite_friend_info(RoleId),
	%slogger:msg("invite_friend_op:load_from_db Info:~p ~n",[Info]),
	if Info=:= undefined orelse Info=:= [] ->
		  put(role_invite_friend_info,{RoleId,[],[]});
	true -> 
		{role_invite_friend_info,_,Friends,Amount_awards}= Info, 
		put(role_invite_friend_info,{RoleId,Friends,Amount_awards})
	end,
	invite_friend_board_c2s().	


export_for_copy()->
	[get(role_invite_friend_info)].


load_by_copy([Role_invite_friend_info])->
	put(role_invite_friend_info,Role_invite_friend_info).

%%处理新增邀请好友的消息
invite_friend_add_c2s(JoinFriends)->
	%slogger:msg("invite_friend_op:invite_friend_add_c2s get(role_invite_friend_info):~p ~n",[ get(role_invite_friend_info)]),
	{RoleId,Friends,Amount_awards} = get(role_invite_friend_info),
	NewFriends = 
	lists:foldl(fun(Elem,Acc0) ->
		 Bool1 = lists:keyfind(Elem, 1, Acc0),				
		 if Bool1=:=false ->
				[{Elem,0}|Acc0];
			 true->Acc0
        end
	end, Friends, JoinFriends),
	put(role_invite_friend_info,{RoleId,NewFriends,Amount_awards}),		
	invite_friend_db:sync_updata({RoleId,NewFriends,Amount_awards}),
	invite_friend_board_s2c(RoleId,NewFriends,Amount_awards).

%%处理邀请好友面板的消息
invite_friend_board_c2s()->
	{RoleId,Friends,Amount_awards} = get(role_invite_friend_info),
	invite_friend_board_s2c(RoleId,Friends,Amount_awards).

%%获取对应邀请好友的礼品
get_gift(Amount)->
	{RoleId,Friends,Amount_awards} = get(role_invite_friend_info),
	Ret1 =  lists:member(Amount,Amount_awards),
	if Ret1 =:= false ->
		   {invite_friend,_Amount,GiftList} = invite_friend_db:get_info_gift(Amount),
		   if GiftList =:=[] ->  Result = ?ERROR_NO_MATCH_GIFTS;
		   true->
			    case package_op:can_added_to_package_template_list(GiftList) of
					 false ->
						  Result = ?ERROR_PACKEGE_FULL;
					 true ->
						lists:foreach(fun({Gift,Count})->
											role_op:auto_create_and_put(Gift,Count,invite_friend_gift) end,GiftList),
						Amount_awards_new = [Amount|Amount_awards],
				       put(role_invite_friend_info,{RoleId,Friends,Amount_awards_new}),		
				       invite_friend_db:sync_updata({RoleId,Friends,Amount_awards_new}),
						Result = ?AWARD_OK
				end
			end;   
	true ->	
		 Result = ?ERROR_HAD_REWARDED
	end,	   
	send_opt_result(Result,Amount).

%%给客户端发送好友送礼信息	
invite_friend_board_s2c(RoleId,Friends,Amount_awards)->
	{Sum,ChangeFlag,NewFriends}=lists:foldl(fun({Elem,Flag},{Sum0,ChangeFlag0,NewFriends0})->
		if 	Flag=:=1->{Sum0+1,ChangeFlag0,[{Elem,Flag}|NewFriends0]};
		true->
			%%读取#account.username=openid，
			Account=dal:read_rpc(account,Elem),
			%%假如邀请好友已经参与游戏
			if Account=:=undefined orelse Account =:= [] ->{Sum0,ChangeFlag0,[{Elem,Flag}|NewFriends0]};
			true ->   {Sum0+1,true,[{Elem,1}|NewFriends0]}
			end   
       end
	end,{0,false,[]},Friends),	
	if ChangeFlag =:=true ->
		 put(role_invite_friend_info,{RoleId,NewFriends,Amount_awards}),		
		 invite_friend_db:sync_updata({RoleId,NewFriends,Amount_awards});
	true->nothing   
	end,	   
	Message = invite_friend_packet:encode_invite_friend_board_s2c(Sum,Amount_awards),
	role_op:send_data_to_gate(Message).

%%给客户端回复好友送礼信息的收取信息	
send_opt_result(Result,Amount)->
	Message = invite_friend_packet:encode_invite_friend_gift_get_ret_s2c(Result,Amount),
	role_op:send_data_to_gate(Message).

	
	
