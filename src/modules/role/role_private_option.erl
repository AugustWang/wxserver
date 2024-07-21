%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-3
%% Description: TODO: Add description to role_private_option
-module(role_private_option).
-define(ROLE_PRIVATE_OPTION,'$private_options').

-define(FASHION_DISPLAY_KEY,30).
-define(WING_DISPLAY_KEY,50).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([export_for_copy/0,get_is_fashion_dispaly/0,load_by_copy/1,replace/1,get/1,load_rpc/0,flush/0]).

%%
%% API Functions
%%


export_for_copy()->
	erlang:get(?ROLE_PRIVATE_OPTION).	

load_by_copy(Info)->
	put(?ROLE_PRIVATE_OPTION,Info).

get_is_fashion_dispaly()->
	case lists:keyfind(?FASHION_DISPLAY_KEY, 1, erlang:get(?ROLE_PRIVATE_OPTION)) of
		false->
			true;
		{_,Value}->
			Value=:=1
	end.
	
set_fashion_dispaly_hook(KeyValueList)->
	case lists:keymember(?FASHION_DISPLAY_KEY,2,KeyValueList) of
		true->
			role_op:redisplay_cloth_and_arm();
		_->
			case lists:keyfind(?WING_DISPLAY_KEY, 2, KeyValueList) of
				{k,_,Value}->
						role_op:self_update_and_broad([{wing_show,Value}]);
				_->
					nothing
			end
	end.

replace(KeyValueList)->
	Options = case erlang:get(?ROLE_PRIVATE_OPTION) of
				  undefined -> [];
				  Opt-> Opt
			  end,
	Fun = fun({k,K,V},LastOption)->
				  case lists:keyfind(K, 1, LastOption) of
					  false-> [{K,V}|LastOption];
					  _-> lists:keyreplace(K, 1, LastOption, {K,V})
				  end
		  end,
	NewOptions = lists:foldl(Fun,Options, KeyValueList),
	erlang:put(?ROLE_PRIVATE_OPTION,NewOptions),
	RoleId = erlang:get(roleid),
	TableName = db_split:get_owner_table(player_option, RoleId),
	dmp_op:async_write(RoleId,{TableName,RoleId,Options}),
	set_fashion_dispaly_hook(KeyValueList).

get(Keys)when is_list(Keys)->
	Options = case erlang:get(?ROLE_PRIVATE_OPTION) of
				  undefined -> [];
				  Opt-> Opt
			  end,
	NeedList = case Keys of 
				   []-> Options ; %%if nil send all option
				   _-> lists:filter(fun({Key,_Value})-> lists:member(Key, Keys) end , Options)
			   end,
	lists:map(fun({Key,Value})-> {k,Key,Value} end, NeedList);

get(Key)->
	Options = case erlang:get(?ROLE_PRIVATE_OPTION) of
				  undefined -> [];
				  Opt-> Opt
			  end,
	case lists:keyfind(Key, 1, Options) of
		false->  [];
		{_,Value}-> [{k,Key,Value}]
	end.

load_rpc()->
	erlang:put(?ROLE_PRIVATE_OPTION,role_private_option_db:load(erlang:get(roleid))).

flush()->
	role_private_option_db:flush(erlang:get(roleid), erlang:get(?ROLE_PRIVATE_OPTION)).
	
