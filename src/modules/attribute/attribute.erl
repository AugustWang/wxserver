%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-28
%% Description: TODO: Add description to attribute
-module(attribute).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_base/2,put_base/3,get_effect/2,put_effect/3,get_current/2,put_current/3]).

%%
%% API Functions
%%



%%
%% Local Functions
%%

get_base(AttributeList,Key)->
	case lists:keyfind({Key,base}, 1, AttributeList) of
		false-> 0;
		{_,Value}-> Value
	end.

put_base(AttributeList,Key,Value)->
	case lists:keymember({Key,base}, 1, AttributeList) of
		false-> [{{Key,base},Value}|AttributeList];
		_-> lists:keyreplace({Key,base}, 1, AttributeList, {{Key,base},Value})
	end.

get_effect(AttributeList,Key)->
	case lists:keyfind({Key,effect}, 1, AttributeList) of
		false-> 0;
		{{Key,effect},Value}-> Value
	end.

put_effect(AttributeList,Key,Value)->
	case lists:keymember({Key,effect}, 1, AttributeList) of
		false-> [{{Key,effect},Value}|AttributeList];
		_-> lists:keyreplace({Key,effect}, 1, AttributeList, {{Key,effect},Value})
	end.

get_current(AttributeList,Key)->
	case lists:keyfind({Key,current}, 1, AttributeList) of
		false-> 0;
		{{Key,current},Value}-> Value
	end.

put_current(AttributeList,Key,Value)->
	case lists:keymember({Key,current}, 1, AttributeList) of
		false-> [{{Key,current},Value}|AttributeList];
		_-> lists:keyreplace({Key,current}, 1, AttributeList, {{Key,current},Value})
	end.

