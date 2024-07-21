%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-16
%% Description: TODO: Add description to friend_packet
-module(friend_packet).

%%
%% Include files
%%
-export([handle/2,process_friend/1]).
-export([encode_myfriends_s2c/1,encode_becare_s2c/2,
		 encode_add_friend_failed_s2c/1,encode_add_friend_success_s2c/1,
		 encode_delete_friend_failed_s2c/1,encode_delete_friend_success_s2c/2,%%@@
		 encode_detail_friend_s2c/1,encode_detail_friend_failed_s2c/1,
		 encode_position_friend_s2c/1,encode_position_friend_failed_s2c/1,
		 encode_online_friend_s2c/1,encode_offline_friend_s2c/1,encode_set_black_s2c/1,
		 encode_black_list_s2c/1,encode_init_signature_s2c/1,encode_get_friend_signature_s2c/1,
		 encode_delete_black_s2c/1,encode_revert_black_s2c/1,encode_add_black_s2c/1,encode_add_friend_confirm_s2c/3,
		 encode_add_friend_reject_s2c/1,encode_auto_find_friend_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").

-record(judge_friend_exit1,{fname,type}).%%å¥½å‹æ˜¯å¦å­˜åœ¨
-record(judge_friend_exit2,{fname,type}).
%%
%% Exported Functions
%%
handle(Message=#add_friend_confirm_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#myfriends_c2s{}, RolePid) ->
	RolePid!{friend,Message};
handle(Message=#add_friend_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#delete_friend_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#detail_friend_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#position_friend_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#add_signature_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#get_friend_signature_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#set_black_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#revert_black_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#delete_black_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#add_black_c2s{},RolePid)->
	RolePid!{friend,Message};
handle(Message=#search_role_c2s{},RolePid)->%%@@wb20130509 æŸ¥æ‰¾è§’è‰²
	RolePid!{friend,Message};
handle(Message=#auto_find_friend_c2s{},RolePid)->%%ä¸€é”®å¾å‹ã€xiaowuã€‘
	RolePid!{friend,Message};
handle(_Message,_RolePid)->
	ok.


process_friend(#add_friend_confirm_c2s{roleid=RoleId,type=Ntype})->
	friend_op:add_friendtype_check(get(creature_info),RoleId,Ntype);
process_friend(#myfriends_c2s{ntype=Ntype})->
	Message = friend_packet:encode_myfriends_s2c(friend_op:get_friend_list(Ntype)),
	role_op:send_data_to_gate(Message);
process_friend(#add_friend_c2s{fn=FriendName})->
	friend_op:add_friend_by_name(get(creature_info),FriendName);
process_friend(#delete_friend_c2s{fn=FriendName})->
	friend_op:delete_friend_by_name(get(creature_info),FriendName);
process_friend(#detail_friend_c2s{fn=FriendName})->
	friend_op:detail_friend_by_name(get(creature_info),FriendName);
process_friend(#position_friend_c2s{fn=FriendName})->
	friend_op:position_friend_by_name(get(creature_info),FriendName);
process_friend(#add_signature_c2s{signature=Signature})->
	friend_op:add_signature_c2s(get(creature_info),Signature);
process_friend(#get_friend_signature_c2s{fn=Fname})->
	friend_op:get_friend_signature_c2s(get(creature_info),Fname);
process_friend(#set_black_c2s{fn=Fname})->
	friend_op:set_black_c2s(get(creature_info),Fname);
process_friend(#revert_black_c2s{fn=Fname})->
	friend_op:revert_black_c2s(get(creature_info),Fname);
process_friend(#delete_black_c2s{fn=Fname})->
	friend_op:delete_black_c2s(get(creature_info),Fname);
process_friend(#add_black_c2s{bn=Fname})->
	friend_op:add_black_c2s(get(creature_info),Fname);
process_friend(#search_role_c2s{name=RoleName})->
	friend_op:other_search_role(RoleName);
process_friend(#auto_find_friend_c2s{})->%%ä¸€é”®å¾å‹ã€xiaowuã€‘
	friend_op:auto_find_friend(get(creature_info)).
%%
%% API Functions
%%
encode_myfriends_s2c(FriendList)->
	login_pb:encode_myfriends_s2c(#myfriends_s2c{friendinfos = FriendList}).
encode_black_list_s2c(BlackList)->
	login_pb:encode_black_list_s2c(#black_list_s2c{friendinfos = BlackList}).
encode_init_signature_s2c(Signature)->
	login_pb:encode_init_signature_s2c(#init_signature_s2c{signature = Signature}).
encode_add_friend_success_s2c(FriendInfo)->
	login_pb:encode_add_friend_success_s2c(#add_friend_success_s2c{friendinfo=FriendInfo}).
encode_add_friend_failed_s2c(Reason)->
	login_pb:encode_add_friend_failed_s2c(#add_friend_failed_s2c{reason=Reason}).
encode_delete_friend_success_s2c(Fid,Type)->
	login_pb:encode_delete_friend_success_s2c(#delete_friend_success_s2c{fn=Fid,type=Type}).%%@@
encode_delete_friend_failed_s2c(Reason)->
	login_pb:encode_delete_friend_failed_s2c(#delete_friend_failed_s2c{reason=Reason}).
encode_becare_s2c(FriendId,FriendName)->
	login_pb:encode_becare_friend_s2c(#becare_friend_s2c{fn=FriendName,fid=FriendId}).
encode_detail_friend_s2c(DetailFriendInfo)->
	login_pb:encode_detail_friend_s2c(#detail_friend_s2c{defr=DetailFriendInfo}).
encode_detail_friend_failed_s2c(Reason)->
	login_pb:encode_detail_friend_failed_s2c(#detail_friend_failed_s2c{reason=Reason}).
encode_position_friend_s2c(PositionFriendInfo)->
	login_pb:encode_position_friend_s2c(#position_friend_s2c{posfr=PositionFriendInfo}).
encode_position_friend_failed_s2c(Reason)->
	login_pb:encode_position_friend_failed_s2c(#position_friend_failed_s2c{reason=Reason}).
encode_online_friend_s2c(FriendId)->
	login_pb:encode_online_friend_s2c(#online_friend_s2c{fid=FriendId}).
encode_offline_friend_s2c(FriendId)->
	login_pb:encode_offline_friend_s2c(#offline_friend_s2c{fid=FriendId}).
encode_get_friend_signature_s2c(Signature)->
	login_pb:encode_get_friend_signature_s2c(#get_friend_signature_s2c{signature=Signature}).
encode_set_black_s2c(Fid)->
	login_pb:encode_set_black_s2c(#set_black_s2c{roleid=Fid}).
encode_revert_black_s2c(FriendInfo)->
	login_pb:encode_revert_black_s2c(#revert_black_s2c{friendinfo=FriendInfo}).
encode_delete_black_s2c(Bid)->
	login_pb:encode_delete_black_s2c(#delete_black_s2c{bid=Bid}).
encode_add_black_s2c(BlackInfo)->
	login_pb:encode_add_black_s2c(#add_black_s2c{blackinfo=BlackInfo}).
encode_add_friend_confirm_s2c(Id,Name,Level)->
	login_pb:encode_add_friend_confirm_s2c(#add_friend_confirm_s2c{roleid=Id,rolename=Name,level=Level}).
encode_add_friend_reject_s2c(Name)->
	login_pb:encode_add_friend_reject_s2c(#add_friend_reject_s2c{name=Name}).
encode_auto_find_friend_s2c(Friend)->
	login_pb:encode_auto_find_friend_s2c(#auto_find_friend_s2c{friend=Friend}).
%%
%% Local Functions
%%
