%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(packet_object_update).

-include("login_pb.hrl").

-compile(export_all).
-export([init/0,send_pending_update/0,push_to_create_data/1,push_to_update_data/1,push_to_delete_data/1]).

-define(MAX_CREATE_NUM,20).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		object_create_info:[{Id,Type,Attrs}]
%%		object_update_info:[{Id,Type,Attrs}]
%%		object_delete_info:[Id,Type]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init()->
	put(object_create_info,[]),
	put(object_update_info,[]),
	put(object_delete_info,[]).
		
clear()->
	put(object_create_info,[]),
	put(object_update_info,[]),
	put(object_delete_info,[]).
	
send_pending_update()->
	case (get(object_create_info) =/= []) or (get(object_update_info) =/= []) or (get(object_delete_info) =/= []) of
		true->
			Message = role_packet:encode_object_update_s2c(lists:reverse(get(object_create_info)),lists:reverse(get(object_update_info)),lists:reverse(get(object_delete_info))),
			%%TODO
			try erlang:binary_to_term(Message) of
				Val-> slogger:msg("send_to_role ~p~n",[erlang:binary_to_term(Message)])
			catch
				_:_->
					<<ID:16, Data1/binary>> = Message
					%slogger:msg("send_to_role [~p] ~n",[ID])
			end,
			erlang:port_command(get(clientsock), Message, [force]);
		false->
			nothing
	end,
	clear().

push_to_create_data(NewCreates) when is_list(NewCreates)->
	[NewCreate,Pet] = NewCreates,
	put(object_create_info,[Pet,NewCreate|get(object_create_info)]);
push_to_create_data(NewCreate)->
	put(object_create_info,[NewCreate|get(object_create_info)]),
	case erlang:length(get(object_create_info)) > ?MAX_CREATE_NUM  of
		true->
			send_pending_update();
		_->
			nothing
	end.
		
push_to_update_data(NewUpdate)->
	ObjectId = erlang:element(#o.objectid,NewUpdate),
	case lists:keyfind(ObjectId,#o.objectid,get(object_update_info)) of
		false->
			put(object_update_info,[NewUpdate|get(object_update_info)]);
		OldUpdateObject->
			NewUpdateValues = erlang:element(#o.attrs, OldUpdateObject) ++ erlang:element(#o.attrs, NewUpdate), 
			put(object_update_info,
				lists:keyreplace(ObjectId,#o.objectid,get(object_update_info),erlang:setelement(#o.attrs, OldUpdateObject,NewUpdateValues)))				
	end.

push_to_delete_data(DelObject)->
	ObjectId = erlang:element(#o.objectid,DelObject),
	case lists:keymember(ObjectId,#o.objectid,get(object_create_info)) of
		false->
			nothing;
		true->
			put(object_create_info,lists:keydelete(ObjectId,#o.objectid,get(object_create_info)))
	end,
	put(object_delete_info,[DelObject|get(object_delete_info)]).