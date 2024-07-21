%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-11-2
%% Description: TODO: Add description to npc_king_statue
-module(npc_king_statue).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init/0,proc_special_msg/1]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("string_define.hrl").


-define(REG_DURATION,60*60*1000).		%% 1 hour 
%%
%% API Functions
%%
init()->
	%% reg to country and get king info 
	reg_to_country_manager_delay().
	

proc_special_msg({king_statue_change_name,NewName})->
	change_myname(NewName);


proc_special_msg({reg_to_country_manager_loop})->
	reg_to_country_manager_delay();
		
proc_special_msg(_)->
	nothing.

%%
%% Local Functions
%%

reg_to_country_manager_delay()->
	try
		case country_manager:reg_king_statue(self(), node()) of
			[]->
				nothing;
			Name->
				erlang:send_after(1000,self(),{king_statue_change_name,Name})
		end	
	catch
			E:R->slogger:msg("reg_to_country_manager E:~p R:~p S:~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	erlang:send_after(?REG_DURATION,self(),{reg_to_country_manager_loop}).


change_myname([])->
	ProtoId = get_templateid_from_npcinfo(get(creature_info)),
	ProtoInfo =  npc_db:get_proto_info_by_id(ProtoId),
	Name = npc_db:get_proto_name(ProtoInfo),
	case Name of
		[]->
			nothing;
		_->
			update_name(Name)
	end;
		
		
change_myname(NewName)->
	KingName = make_king_name(NewName),
	update_name(KingName).

update_name(KingName)->
	put(creature_info, set_name_to_npcinfo(get(creature_info),KingName)),						
	npc_op:broad_attr_changed([{name,KingName}]),
	npc_op:update_npc_info(get(id),get(creature_info)).
	
make_king_name(Name)->
	Format = language:get_string(?STR_KING_FORMAT),
	util:sprintf(Format, [Name]).