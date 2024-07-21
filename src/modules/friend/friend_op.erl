%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-11-16
%% Description: TODO: Add description to friend_op
-module(friend_op).

%%
%% Include files
%%
-include("friend_struct_def.hrl").
%%
%% Exported Functions
%%
-export([load_friend_from_db/1,load_befriend_from_db/1,load_black_from_db/1,load_signature_from_db/1,
		 export_for_copy/0,load_by_copy/1,write_to_db/0]).
-export([add_friend_by_name/2,change_role_name/2,
		 handle_other_inspect_you/2,handle_other_add_you/2,handle_other_delete_you/2,
		 handle_friend_offline/3,handle_friend_online/3,offline_notice/0,
		 delete_friend_by_name/2,detail_friend_by_name/2,position_friend_by_name/2,
		 get_befriend/1,get_friend_list/1,send_friend_list/0,is_friend_id/1,send_black_list/0,send_signature/0,
		 add_signature_c2s/2,get_friend_signature_c2s/2,set_black_c2s/2,revert_black_c2s/2,delete_black_c2s/2,
		 add_black_c2s/2,add_friend_back/2,add_friendtype_check/3,add_friend_for_inner/2,
		 other_search_role/1,auto_find_friend/1]).

-export([get_signature/0]).
-include("data_struct.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-record(add_friend_confirm_c2s,{msgid=2258,roleid,type}).
-record(delete_friend_c2s,{msgid=0,fn}).
-record(add_friend_c2s,{msgid=487,fn}).
-record(search_role_s2c,{msgid=2261,gender,level,roleclass,name,roleid,online,guildname}).
-record(search_role_error_s2c,{magid=10103,errno}).
-record(roleattr_1_0,{rolid,account,name,sex,class,level,exp,hp,mana,currencygold,currencygift,silver,boundsilver,mapid,coord,bufflist,training,packagesize,groupid,guildid,pvpinfo,pet,offline,soulpower,srallname,honor,fightforce}).
-record(guild_baseinfo,{id,name,level,silver,gold,notice,createtime,chatgroup,voicegroup,lastactivetime,sendwarningmail,applyinfo,treasure_transport,package}).

%%
%% API Functions
%%
init()->
	put(myfriends,[]).
beinit()->
	put(bemyfriends,[]).
blackinit()->
	put(myblacks,[]).
signature_init()->
	put(signature,[]).

get_signature()->
	get(signature).

change_role_name(RoleId,NewName)->
	friend_db:change_role_name_in_db(RoleId,NewName),
	%%todo online proc
	todo.

is_friend_id(RoleId)->
	lists:keymember(RoleId,1,get(myfriends)).

is_friend(RoleName) ->
	lists:keymember(RoleName,2,get(myfriends)).

is_befriend(RoleId)->
	lists:keymember(RoleId, 1, get(bemyfriends)).

get_friend(RoleName)->
	lists:keyfind(RoleName, 2, get(myfriends)).

get_black(RoleName)->
	lists:keyfind(RoleName, 2, get(myblacks)).

get_befriend(RoleId)->
	lists:keyfind(RoleId,1,get(bemyfriends)).

update_friend(Fid,Fname,Fline)->
	case lists:keyfind(Fid, 1, get(myfriends)) of
		false->
			nothing;
		{_,_,FClass,FGender,_,Fsign,Fintimacy,Flevel}->%%@@
			put(myfriends,lists:keyreplace(Fid, 1, get(myfriends), {Fid,Fname,FClass,FGender,Fline,Fsign,Fintimacy,Flevel}))%%@@
	end.

add_friendtype_check(RoleInfo,ApplyId,Type)->
 case role_pos_util:where_is_role(ApplyId) of
	 []->
		 Message_failed = friend_packet:encode_add_friend_failed_s2c(?ERROR_FRIEND_OFFLINE),
		 role_op:send_data_to_gate(Message_failed); 
	 Fpos->
		case Type of
			1->	
					Fname = role_pos_db:get_role_rolename(Fpos),
					Errno_1 = add_friend_for_inner(RoleInfo,Fname),
				if 
					Errno_1 =/= []->
					Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno_1),
					role_op:send_data_to_gate(Message_failed);
		 			true->
						nothing
				end;
			0->
				Name = get_name_from_roleinfo(RoleInfo),
				Fpos =role_pos_util:where_is_role(ApplyId),
				Fail_Message=friend_packet:encode_add_friend_reject_s2c(Name),
				role_pos_util:send_to_clinet_by_pos(Fpos, Fail_Message)
		end
 	end.
		
add_friend_back(RoleInfo,Fname) when is_binary(Fname)->
	add_friend_back(RoleInfo,binary_to_list(Fname));
add_friend_back(RoleInfo,Fname) when is_list(Fname)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	MyRoleLevel=get_level_from_roleinfo(RoleInfo),
	IsOwn = binary_to_list(MyRoleName) =/= Fname,
	Pos=role_pos_util:where_is_role(list_to_binary(Fname)),
	FriendId = role_pos_db:get_role_id(Pos),
	if IsOwn ->
		case get_black(list_to_binary(Fname)) of
			false ->
				case is_befriend(FriendId) of
					false ->
						FriendLength = length(get(myfriends)),
						if 
							FriendLength<100 ->
							case role_pos_util:where_is_role(list_to_binary(Fname)) of
									[] -> %%role offline
										Errno = ?ERROR_FRIEND_OFFLINE;
									RolePos ->
										Rid=role_pos_db:get_role_pid(RolePos),%%?@@
										Errno=[],
										Message_back = friend_packet:encode_add_friend_confirm_s2c(MyRoleId,MyRoleName,MyRoleLevel),
										role_pos_util:send_to_clinet_by_pos(RolePos, Message_back)
		 						end;
	   						true ->
		   						Errno = ?ERROR_FRIEND_FULL
						end;
					true ->
						Errno = ?ERROR_FRIEND_EXIST
				end;
			_ ->
				Errno = ?ERROR_ISBLACK
		end;
	   true ->
		   Errno = ?ERROR_FRIEND_MYSELF
	end,
	Errno.
	
add_friend_for_inner(RoleInfo,Fname) when is_binary(Fname)->
	add_friend_for_inner(RoleInfo,binary_to_list(Fname));
add_friend_for_inner(RoleInfo,Fname) when is_list(Fname)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	IsOwn = binary_to_list(MyRoleName) =/= Fname,
	if IsOwn ->
		case get_black(list_to_binary(Fname)) of
			false ->
				case is_friend(list_to_binary(Fname)) of
					false ->
						FriendLength = length(get(myfriends)),
						if 
							FriendLength<100 ->
								case role_pos_util:where_is_role(list_to_binary(Fname)) of
									[] -> %%role offline
										Errno = ?ERROR_FRIEND_OFFLINE;
									RolePos ->
										FriendId = role_pos_db:get_role_id(RolePos),
										FriendName = role_pos_db:get_role_rolename(RolePos),
										FriendLine = role_pos_db:get_role_lineid(RolePos),
										FriendNode = role_pos_db:get_role_mapnode(RolePos),
										OtherRoleInfo = role_manager:get_role_remoteinfo_by_node(FriendNode,FriendId),
										FriendClass = get_class_from_othernode_roleinfo(OtherRoleInfo),
										FriendGender = get_gender_from_othernode_roleinfo(OtherRoleInfo),
										FriendLevel = get_level_from_othernode_roleinfo(OtherRoleInfo),
										FriendIntimacy=10,							
										Errno=[],
										case is_befriend(FriendId)of
											true -> 
												FriendObject = #friend{owner=MyRoleId,fid=FriendId,fname=FriendName,finfo={FriendClass,FriendGender,FriendIntimacy,FriendLevel}},
												friend_db:add_friend_to_mnesia(FriendObject),
												insert(FriendId,FriendName,FriendClass,FriendGender,FriendLine,FriendIntimacy,FriendLevel),
												FriendInfo = util:term_to_record(lists:keyfind(FriendId, 1, get(myfriends)), fr),
												Message_success = friend_packet:encode_add_friend_success_s2c(FriendInfo),
												role_op:send_data_to_gate(Message_success),
												achieve_op:achieve_update({add_friend},[0],1),
												goals_op:goals_update({add_friend}, [0], FriendLength+1),%%@@wb20130311
												role_pos_util:send_to_role_by_pos(RolePos, {other_friend_add_you,{MyRoleId,MyRoleName}});
											false ->
												FriendObject = #friend{owner=MyRoleId,fid=FriendId,fname=FriendName,finfo={FriendClass,FriendGender,FriendIntimacy,FriendLevel}},
												insert(FriendId,FriendName,FriendClass,FriendGender,FriendLine,FriendIntimacy,FriendLevel),
												friend_db:add_friend_to_mnesia(FriendObject),
												RPid=role_pos_db:get_role_pid(RolePos),
												achieve_op:achieve_update({add_friend},[0],1),
												goals_op:goals_update({add_friend}, [0], FriendLength+1),%%@@wb20130311
												MessageReturn=#add_friend_confirm_c2s{roleid=MyRoleId,type=1},
												role_pos_util:send_to_role_by_pos(RolePos, {other_friend_add_you,{MyRoleId,MyRoleName}}),
												role_pos_util:send_to_role_by_pos(RolePos, {friend,MessageReturn}),
												FriendInfo = util:term_to_record(lists:keyfind(FriendId, 1, get(myfriends)), fr),
												Message_success = friend_packet:encode_add_friend_success_s2c(FriendInfo),
												role_op:send_data_to_gate(Message_success)
										end
		 						end;
	   						true ->
		   						Errno = ?ERROR_FRIEND_FULL
						end;
					true ->
						Errno = ?ERROR_FRIEND_EXIST
				end;
			_ ->
				Errno = ?ERROR_ISBLACK
		end;
	   true ->
		   Errno = ?ERROR_FRIEND_MYSELF
	end,
	Errno.

add_friend_by_name(RoleInfo,Fname) ->
	Error = add_friend_back(RoleInfo,Fname),
	if Error =/= [] ->
		   Message = friend_packet:encode_add_friend_failed_s2c(Error),
		   role_op:send_data_to_gate(Message);
	   true ->
		   nothing
	end.

add_black_c2s(RoleInfo,Fname) when is_binary(Fname)->
	add_black_c2s(RoleInfo,binary_to_list(Fname));
add_black_c2s(RoleInfo,Fname) when is_list(Fname)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	IsOwn = binary_to_list(MyRoleName) =/= Fname,
	if IsOwn ->
		case get_black(list_to_binary(Fname)) of
			false ->
				case is_friend(list_to_binary(Fname)) of
					false ->
						BlackLength = length(get(myblacks)),
						if 
							BlackLength<100 ->
								case role_pos_util:where_is_role(list_to_binary(Fname)) of
									[] -> %%role offline
										Errno = ?ERROR_FRIEND_OFFLINE;
									RolePos ->
										BlackId = role_pos_db:get_role_id(RolePos),
										BlackName = role_pos_db:get_role_rolename(RolePos),
										BlackNode = role_pos_db:get_role_mapnode(RolePos),
										OtherRoleInfo = role_manager:get_role_remoteinfo_by_node(BlackNode,BlackId),
										BlackClass = get_class_from_othernode_roleinfo(OtherRoleInfo),
										BlackGender = get_gender_from_othernode_roleinfo(OtherRoleInfo),
										BlackObject = #black{owner=MyRoleId,
															 fid=BlackId,
															 fname=BlackName,
															 finfo={BlackClass,BlackGender}},
										friend_db:add_black_to_mnesia(BlackObject),
										insert_black(BlackId,BlackName,BlackClass,BlackGender),
										Errno=[],
										BlackInfo = {br,BlackId,BlackName,BlackClass,BlackGender},
										Message_success = friend_packet:encode_add_black_s2c(BlackInfo),
										role_op:send_data_to_gate(Message_success)
								end;
	   						true ->
		   						Errno = ?ERROR_BLACK_FULL
						end;
					true ->
						Errno = ?ERROR_FRIEND_EXIST
				end;
			_ ->
				Errno = ?ERROR_ISBLACK
		end;
	   true ->
		   Errno = ?ERROR_FRIEND_MYSELF
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

add_signature_c2s(RoleInfo,Signature)->
	case length(Signature) >= 50 of
		true->
			slogger:msg("add_signature_c2s hack error Signature Length RoleId ~p ~n",get(roleid));
		_->
			MyRoleId = get_id_from_roleinfo(RoleInfo),
			insert_sign(Signature),
			SignatureToDB = #signature{roleid=MyRoleId,sign=Signature},
			friend_db:add_signature_to_mnesia(SignatureToDB),
			send_signature()
	end.

get_friend_signature_c2s(_RoleInfo,Fname)->
	case lists:keyfind(list_to_binary(Fname), 2, get(myfriends)) of
		false->
			Errno = ?ERROR_FRIEND_NOEXIST;
		{Fid,_,_,_,_,_,_,_}->
			case friend_db:get_signature_by_roleid(Fid) of
				{ok,[]}->
					Errno = ?ERROR_FRIEND_NO_SIGNATURE;
				{ok,[#signature{sign=Signature}]}->
					Errno = [],
					Message_success = friend_packet:encode_get_friend_signature_s2c(Signature),
					role_op:send_data_to_gate(Message_success)
			end
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

set_black_c2s(RoleInfo,Name)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	case length(get(myblacks))<100 of
		true->
			case is_friend(list_to_binary(Name)) of
				true ->
					{Fid,Fname,FClass,FGender,_,_,FriendIntimacy,FriendLevel} = get_friend(list_to_binary(Name)),
					BlackObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender}},
					friend_db:add_black_to_mnesia(BlackObject),
					insert_black(Fid,Fname,FClass,FGender),
					Message_success = friend_packet:encode_set_black_s2c(Fid),%%客户端：加入黑名单列表的同时从好友列表删除
					role_op:send_data_to_gate(Message_success),
					%case role_pos_util:where_is_role(list_to_binary(Name)) of
					%	Fpos->
					%{Fid,Fname,FClass,FGender,_,_,FriendIntimacy,FriendLevel} = get_friend(list_to_binary(Name)),
					%DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender,FriendIntimacy,FriendLevel}},%%???
					%friend_db:delete_friend_to_mnesia(DeleteObject),
					%remove(Fname),
					%beremove(Fid),
					%Errno=[],
					%%BlackObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender}},
					%%friend_db:add_black_to_mnesia(BlackObject),
					%%insert_black(Fid,Fname,FClass,FGender),
					%%Message_success = friend_packet:encode_set_black_s2c(),
					%%role_op:send_data_to_gate(Message_success),
					%Message=#delete_friend_c2s{fn=Name},
					%role_pos_util:send_to_role_by_pos(Fpos, {other_friend_delete_you,{MyRoleId,MyRoleName}}),
					%role_pos_util:send_to_role_by_pos(Fpos, {friend,Message});
					%	[]->
					%		{Fid,Fname,FClass,FGender,_,_,FriendIntimacy,FriendLevel} = get_friend(list_to_binary(Name)),
					%DeleteObject_Own = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender,FriendIntimacy,FriendLevel}},%%???
					%friend_db:delete_friend_to_mnesia(DeleteObject_Own)
					%end,
					Errno=[],
					delete_friend_by_name(RoleInfo,Name);
				false->
					Errno = ?ERROR_FRIEND_NOEXIST
			end;
		_->
			slogger:msg("set_black_c2s too long RoleId ~p ~n",[MyRoleId]),
			Errno = ?ERROR_BLACK_FULL
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_delete_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

revert_black_c2s(RoleInfo,Name)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	case get_black(list_to_binary(Name)) of
		false->
			Errno = ?ERROR_BLACK_NOEXIST;
		{Fid,Fname,FClass,FGender}->%%???
			FriendLength = length(get(myfriends)),
			if FriendLength < 100 ->
				case role_pos_util:where_is_role(Fname) of
					[]->%%role offline
						FriendLine = 0;
					RolePos->
						FriendLine = role_pos_db:get_role_lineid(RolePos)
		 		end,
				FriendObject = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender}},
				friend_db:add_friend_to_mnesia(FriendObject),
				BlackObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender}},
				friend_db:delete_black_to_mnesia(BlackObject),
				remove_black(Fname),
				Errno=[],
				FriendInfo = util:term_to_record(lists:keyfind(Fid, 1, get(myfriends)), fr),
				Message_success = friend_packet:encode_revert_black_s2c(FriendInfo),
				role_op:send_data_to_gate(Message_success);
	   		true ->
		   		Errno = ?ERROR_FRIEND_FULL
			end
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.
delete_friend_by_name(RoleInfo,Name) when is_list(Name)->
	delete_friend_by_name(RoleInfo,list_to_binary(Name));
delete_friend_by_name(RoleInfo,Name) when is_binary(Name)->	
	FriendLength = length(get(myfriends)),
	MyRoleId=get_id_from_roleinfo(RoleInfo),
	MyRoleName=get_name_from_roleinfo(RoleInfo),
	MyRoleClass=get_class_from_roleinfo(RoleInfo),
	MyRoleGender=get_gender_from_roleinfo(RoleInfo),
	MyRoleLevel=get_level_from_roleinfo(RoleInfo),
	case get_friend(Name) of
		{FriendId,FriendName,FriendClass,FriendGender,_,_,FriendIntimacy,FriendLevel}->
			DeleteObject = #friend{owner=MyRoleId,fid=FriendId,fname=FriendName,finfo={FriendClass,FriendGender,FriendIntimacy,FriendLevel}},
			friend_db:delete_friend_to_mnesia(DeleteObject),
			remove(FriendName),
			case is_befriend(FriendId) of
				true->
			Message_success = friend_packet:encode_delete_friend_success_s2c(FriendId,1),
			role_op:send_data_to_gate(Message_success);
            %beremove(FriendId);
				false->
					Message_success = friend_packet:encode_delete_friend_success_s2c(FriendId,2),
			role_op:send_data_to_gate(Message_success)
			end,
			case is_befriend(FriendId) of
				true->
					case role_pos_util:where_is_role(FriendName) of
						[]->
							DeleteObject_Own = #friend{owner=FriendId,fid=MyRoleId,fname=MyRoleName,finfo={MyRoleClass,MyRoleGender,FriendIntimacy,MyRoleLevel}},
							friend_db:delete_friend_to_mnesia(DeleteObject_Own),
							beremove(FriendId),
							achieve_op:achieve_update({add_friend},[0],-1);%%@@                     
						RolePos->
							%%beremove(FriendId),
							beremove(FriendId),
							role_pos_util:send_to_role_by_pos(RolePos, {other_friend_delete_you,{MyRoleId,MyRoleName}}),
							Message=#delete_friend_c2s{fn=MyRoleName},
							%%role_pos_util:send_to_role_by_pos(RolePos, {friend,Message}),
							achieve_op:achieve_update({add_friend},[0],-1),
							role_pos_util:send_to_role_by_pos(RolePos, {friend,Message})					       
					end;
				false->nothing
			end,
			Errno=[];
			%case is_befriend(FriendId) of
			%	true->
			%Message_success = friend_packet:encode_delete_friend_success_s2c(FriendId,1),
			%role_op:send_data_to_gate(Message_success),
            %beremove(FriendId);
			%	false->
			%		Message_success = friend_packet:encode_delete_friend_success_s2c(FriendId,2),
			%role_op:send_data_to_gate(Message_success)
			%end;
		false->
			Errno = ?ERROR_FRIEND_NOEXIST
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_delete_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

delete_black_c2s(RoleInfo,Name)->	
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	case get_black(list_to_binary(Name)) of
		false->
			Errno = ?ERROR_BLACK_NOEXIST;
		{Fid,Fname,FClass,FGender} ->
			DeleteObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender}},
			friend_db:delete_black_to_mnesia(DeleteObject),
			remove_black(Fname),
			Errno=[],
			Message_success = friend_packet:encode_delete_black_s2c(Fid),
			role_op:send_data_to_gate(Message_success),
			role_pos_util:send_to_role(Fid, {other_friend_delete_you,{MyRoleId,MyRoleName}})
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_delete_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

detail_friend_by_name(RoleInfo,Name)->
	MyRoldId = get_id_from_roleinfo(RoleInfo),
	case is_friend(list_to_binary(Name)) of
		true ->
			{Fid,_,_,_,_,_,_} = get_friend(list_to_binary(Name)),
			case role_pos_util:where_is_role(Fid) of
			[]->%%role offline
				Errno = ?ERROR_FRIEND_OFFLINE;
			RolePos->
				FriendId = role_pos_db:get_role_id(RolePos),
				Errno=[],
				role_pos_util:send_to_role(FriendId,{other_friend_inspect_you,{MyRoldId,0}})
		 	end;
		false->
			Errno = ?ERROR_FRIEND_NOEXIST
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_detail_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

position_friend_by_name(RoleInfo,Name)->
	MyRoldId = get_id_from_roleinfo(RoleInfo),
	case is_friend(list_to_binary(Name)) of
		true ->
			{Fid,_,_,_,_,_,_} = get_friend(list_to_binary(Name)),
			case role_pos_util:where_is_role(Fid) of
			[]->%%role offline
				Errno = ?ERROR_FRIEND_OFFLINE;
			RolePos->
				Errno=[],
				role_pos_util:send_to_role_by_pos(RolePos,{other_friend_inspect_you,{MyRoldId,1}})
		 	end;
		false->
			Errno = ?ERROR_FRIEND_NOEXIST
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_detail_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

handle_other_add_you(RoleId,RoleName)->
	LineId = get_lineid_from_mapinfo(get(map_info)),
	beinsert(RoleId,LineId),
	Message_becare = friend_packet:encode_becare_s2c(RoleId,RoleName),
	role_op:send_data_to_gate(Message_becare).

handle_other_delete_you(RoleId,_RoleName)->
	beremove(RoleId).

handle_friend_online(Fid,Fname,Fline)->
	update_friend(Fid,Fname,Fline),
	MessageOnline = friend_packet:encode_online_friend_s2c(Fid),
	role_op:send_data_to_gate(MessageOnline).

handle_friend_offline(Fid,Fname,Fline)->
	update_friend(Fid,Fname,Fline),
	MessageOffline = friend_packet:encode_offline_friend_s2c(Fid),
	role_op:send_data_to_gate(MessageOffline).

handle_other_inspect_you(RoldId,Ntype)->
	case Ntype of
		0->
			RoleInfo = get(creature_info),
			FName = get_name_from_roleinfo(RoleInfo),
			FLever = get_level_from_roleinfo(RoleInfo),
			FGender = get_gender_from_roleinfo(RoleInfo),
			FGuildName = get_guildname_from_roleinfo(RoleInfo),
			FJob = get_class_from_roleinfo(RoleInfo),
			DetailFriendInfo = {dfr,FName,FLever,FJob,FGuildName,FGender},
			Message = friend_packet:encode_detail_friend_s2c(DetailFriendInfo),	
			role_pos_util:send_to_role_clinet(RoldId,Message);
		1->
			RoleInfo = get(creature_info),
			MapInfo = get(map_info),
			Fline = get_lineid_from_mapinfo(MapInfo),
			Fmap = get_mapid_from_mapinfo(MapInfo),
			FName = get_name_from_roleinfo(RoleInfo),
			{PosX,PosY} = get_pos_from_roleinfo(RoleInfo),
			PositionFriendInfo = {pfr,FName,Fline,Fmap,PosX,PosY},
			Message = friend_packet:encode_position_friend_s2c(PositionFriendInfo),	
			role_pos_util:send_to_role_clinet(RoldId,Message);
		_->
			nothing
	end.

%%@@查找玩家20130510 add by wb
other_search_role(RoleName) when is_list(RoleName)->
	other_search_role(list_to_binary(RoleName));

other_search_role(RoleName)->
	case role_db:get_roleid_by_name_rpc(RoleName) of
		[]->%%norole
			Msg=login_pb:encode_search_role_error_s2c(#search_role_error_s2c{errno=10103}),
			role_pos_util:send_to_role_clinet(get(roleid),Msg);
		[RoleId]->
			case dal:read_rpc(roleattr_1_0,RoleId) of
				{ok,[]}-> nothing;
				{ok,[Result]}->
					RoleLevel=erlang:element(#roleattr_1_0.level,Result),
					RoleClass=erlang:element(#roleattr_1_0.class,Result),
					RoleGender=erlang:element(#roleattr_1_0.sex,Result),
					GuildId=erlang:element(#roleattr_1_0.guildid,Result),
					case dal:read_rpc(guild_baseinfo,GuildId) of
						{ok,[]}->
							GuildName="";
						{ok,[Info]}->
							GuildName=Info#guild_baseinfo.name;
						_->
							GuildName=""
					end,
					case role_pos_util:where_is_role(RoleId) of
						[]->
							Msg1=login_pb:encode_search_role_s2c(#search_role_s2c{roleid=RoleId,name=RoleName,online=0,roleclass=RoleClass,gender=RoleGender,guildname=GuildName,level=RoleLevel}),
							role_pos_util:send_to_role_clinet(get(roleid),Msg1);
						_Pos->
							Msg2=login_pb:encode_search_role_s2c(#search_role_s2c{roleid=RoleId,name=RoleName,online=1,roleclass=RoleClass,gender=RoleGender,guildname=GuildName,level=RoleLevel}),
							role_pos_util:send_to_role_clinet(get(roleid),Msg2)
					end;
				_->
					nothing
			end
	end.

insert(RoleId,RoleName,RoleClass,RoleGender,LineId,RoleIntimacy,RoleLevel)->
	case friend_db:get_signature_by_roleid(RoleId) of
		{ok,[]}->
			Sign = "";
		{ok,[#signature{sign=Signature}]}->
			Sign = Signature
	end,
	case lists:keyfind(RoleId,1,get(myfriends)) of
		false->
			put(myfriends,get(myfriends)++[{RoleId,RoleName,RoleClass,RoleGender,LineId,Sign,RoleIntimacy,RoleLevel}]);	
		_ ->
			nothing
	end.

beinsert(RoleId,LineId)->
	case lists:keyfind(RoleId,1,get(bemyfriends)) of
		false->
			put(bemyfriends,get(bemyfriends)++[{RoleId,LineId}]);	
		_ ->
			nothing
	end.
insert_sign(Signature)->
	put(signature,Signature).

insert_black(RoleId,RoleName,RoleClass,RoleGender)->
	case lists:keyfind(RoleId,1,get(myblacks)) of
		false->
			put(myblacks,get(myblacks)++[{RoleId,RoleName,RoleClass,RoleGender}]);	
		_ ->
			nothing
	end.
	
remove(RoleName)->
	put(myfriends,lists:keydelete(RoleName,2,get(myfriends))).
beremove(RoleId)->
	put(bemyfriends,lists:keydelete(RoleId,1,get(bemyfriends))).
remove_black(RoleName)->
	put(myblacks,lists:keydelete(RoleName,2,get(myblacks))).

load_friend_from_db(RoleId)->
	case friend_db:get_friend_by_type(0, RoleId) of
		{ok,[]}->
			init();
		{ok,FriendList}->
			FRole = fun({friend,_Owner,Fid,Fname,{Fclass,Fgender,Fintimacy,Flevel}},Acc) ->
						case friend_db:get_signature_by_roleid(Fid) of
							{ok,[]}->
								Sign = "";
							{ok,[#signature{sign=Signature}]}->
								Sign = Signature
						end,
						case role_pos_util:where_is_role(Fid) of
							[]->
								Acc ++ [{Fid,Fname,Fclass,Fgender,0,Sign,Fintimacy,Flevel}];
							RolePos->
								LineId = role_pos_db:get_role_lineid(RolePos),
								Acc ++ [{Fid,Fname,Fclass,Fgender,LineId,Sign,Fintimacy,Flevel}]
						end
					end,
			FriendInfos = lists:foldl(FRole, [], FriendList),
			put(myfriends,FriendInfos)
	end.

load_befriend_from_db(RoleId)->
	case friend_db:get_befriend_by_type(0, RoleId) of
		{ok,[]}->
			beinit();
		{ok,FriendList}->
			FRole = fun({friend,Owner,Fid,Fname,_},Acc) ->
						case role_pos_util:where_is_role(Owner) of
							[]->
								Acc ++ [{Owner,0}];
							RolePos->
								LineId = role_pos_db:get_role_lineid(RolePos),
								role_pos_util:send_to_role_by_pos(RolePos,{other_friend_online,{Fid,Fname,LineId}}),
								Acc ++ [{Owner,LineId}]
						end
					end,
			FriendInfos = lists:foldl(FRole, [], FriendList),
			put(bemyfriends,FriendInfos)
	end.

load_black_from_db(RoleId)->
	case friend_db:get_friend_by_type(1, RoleId) of
		{ok,[]}->
			blackinit();
		{ok,BlackList}->
			FRole = fun({black,_Owner,Fid,Fname,{Fclass,Fgender}}) ->
						{Fid,Fname,Fclass,Fgender}
					end,
			BlackInfos = lists:map(FRole, BlackList),
			put(myblacks,BlackInfos)
	end.

load_signature_from_db(RoleId)->
	case friend_db:get_signature_by_roleid(RoleId) of
		{ok,[]}->
			signature_init();
		{ok,[#signature{sign=Signature}]}->
			put(signature,Signature)
	end.

offline_notice()->
	MyRoleId = get(roleid),
	MyRoleName = get_name_from_roleinfo(get(creature_info)),
	NoticeFriends = get(myfriends),
	NoticeFun = fun({Beid,RoleName,RoleClass,RoleGender,LineId,_,_,_}) ->
						case role_pos_util:where_is_role(Beid) of
							[] ->
								nothing;
							RolePos->
								role_pos_util:send_to_role_by_pos(RolePos, {other_friend_offline,{MyRoleId,MyRoleName,0}})
						end
				end,
	lists:foreach(NoticeFun,NoticeFriends).

export_for_copy()->
	{get(myfriends),get(bemyfriends),get(myblacks),get(signature)}.

write_to_db()->
	nothing.

load_by_copy({FriendInfos,BeFriendInfos,BlackInfos,Signature})->
	put(myfriends,FriendInfos),
	put(bemyfriends,BeFriendInfos),
	put(myblacks,BlackInfos),
	put(signature,Signature).

get_friend_list(Ntype)->
	case Ntype of
		0 ->%%friendlist 
			util:term_to_record_for_list(get(myfriends), fr);
		1 ->%%blacklist
			util:term_to_record_for_list(get(myblacks), br);
		_ ->
			[]
	end.

send_friend_list()->
	Message = friend_packet:encode_myfriends_s2c(get_friend_list(0)),
	role_op:send_data_to_gate(Message).

send_black_list()->
	Message = friend_packet:encode_black_list_s2c(get_friend_list(1)),
	role_op:send_data_to_gate(Message).

send_signature()->
	Message = friend_packet:encode_init_signature_s2c(get(signature)),
	role_op:send_data_to_gate(Message).

auto_find_friend(MyInfo)->%%一键征友【xiaowu】
	MyLevel = get_level_from_roleinfo(MyInfo),
	RoleOnlineList = lists:map(fun(RolePos)->
									   RoleId = role_pos_db:get_role_id(RolePos)
							   end,role_pos_db:get_all_rolepos()),
	Will_be_friend = lists:filter(fun(FriendRoleId)->
										  FriendRoleInfo = role_db:get_role_info(FriendRoleId),
										  FriendRoleLevel = role_db:get_level(FriendRoleInfo),
										  FriendBool = is_friend_id(FriendRoleId),
										  FriendBlackBool = lists:keymember(FriendRoleId,1,get(myblacks)),
										  if
											  (FriendRoleLevel =< (MyLevel+3)) and (FriendRoleLevel >= (MyLevel-3)) and (FriendBool =:= false) and (FriendBlackBool =:= false)->
												  true;
											  true->
												  false
										  end
								  end,(RoleOnlineList--[get(roleid)])),
	Friend = lists:map(fun(Will_be_friend_Id)->
							   Will_be_friend_Info = role_db:get_role_info(Will_be_friend_Id),
							   Will_be_friend_Name = role_db:get_name(Will_be_friend_Info),
							   Will_be_friend_Class = role_db:get_class(Will_be_friend_Info),
							   Will_be_friend_Gender = role_db:get_sex(Will_be_friend_Info),
							   {br,Will_be_friend_Id,Will_be_friend_Name,Will_be_friend_Class,Will_be_friend_Gender}
					   end, Will_be_friend),
	Message = friend_packet:encode_auto_find_friend_s2c(Friend),
	role_op:send_data_to_gate(Message).

%role_pos_util:send_to_role_clinet(get(roleid),ValMsg).
%%
%% Local Functions
%%

