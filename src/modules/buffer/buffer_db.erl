%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-19
%% Description: TODO: Add description to buffer_db
-module(buffer_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(BUFFERS_TABLE_ETS,buffers_table_ets).

%%
%% Exported Functions
%%
-export([get_buffer_info/2,
		 get_buffer_class/1,
		 get_buffer_resist_type/1,
		 get_buffer_duration/1,
		 get_buffer_effect_interval/1,
		 get_buffer_addition_threat/1,
		 get_buffer_effect_list/1,
		 get_buffer_effect_arguments/1,
		 get_buffer_deadcancel/1,
		 get_can_active_cancel/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?BUFFERS_TABLE_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(buffers, ?BUFFERS_TABLE_ETS,[#buffers.id,#buffers.level]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(buffers,record_info(fields,buffers),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{buffers,proto}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_buffer_info(BufferId,Level)->
	case ets:lookup(?BUFFERS_TABLE_ETS, {BufferId,Level}) of
		[]-> [];
		[{_,BufferInfo}]-> BufferInfo
	end.

get_buffer_resist_type(BufferInfo)->
	element(#buffers.resist_type,BufferInfo).

get_buffer_class(BufferInfo)->
	element(#buffers.class,BufferInfo).

get_buffer_duration(BufferInfo)->
	element(#buffers.duration,BufferInfo).

get_buffer_effect_interval(BufferInfo)->
	element(#buffers.effect_interval,BufferInfo).

get_buffer_addition_threat(BufferInfo)->
	element(#buffers.addition_threat,BufferInfo).

get_buffer_effect_list(BufferInfo)->
	element(#buffers.effectlist,BufferInfo).

get_buffer_effect_arguments(BufferInfo)->
	element(#buffers.effect_argument,BufferInfo).

get_buffer_deadcancel(BufferInfo)->
	element(#buffers.deadcancel,BufferInfo).

get_can_active_cancel(BufferInfo)->
	element(#buffers.can_active_cancel,BufferInfo).
