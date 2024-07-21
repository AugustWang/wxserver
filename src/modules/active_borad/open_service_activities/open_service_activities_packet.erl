%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-11-11
%% Description: TODO: Add description to open_service_activities_packet
-module(open_service_activities_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
handle(Message,RolePid)->
	RolePid ! {open_service_activities,Message}.

process_msg(#init_open_service_activities_c2s{activeid=Id})->
	open_service_activities:init_open_service_activities_c2s(Id);

process_msg({role_level_up})->
	open_service_activities:handle_role_level_up();

process_msg(#open_service_activities_reward_c2s{id=Id,part=Part})->
	open_service_activities:open_service_reward_activities(Id,Part);

process_msg({chess_spirit,CurSection})->
	open_service_activities:chess_spirit(CurSection);

process_msg(_)->
	nothing.

%encode_init_open_service_activities_s2c(Id,PartParam,StartTime,EndTime,LeftTime,Info,State)->
%	login_pb:encode_init_open_service_activities_s2c(#init_open_service_activities_s2c{activeid=Id,
%																					   partinfo=PartParam,
%																					   starttime=StartTime,
%																					   endtime=EndTime,
%																					   lefttime=LeftTime,
%																					   info=Info,
%																					   state = State}).

encode_init_open_service_activities_s2c(Info)->
	login_pb:encode_init_open_service_activities_s2c(#init_open_service_activities_s2c{info=Info}).

encode_open_sercice_activities_update_s2c(Id,Part,State)->
	login_pb:encode_open_sercice_activities_update_s2c(#open_sercice_activities_update_s2c{id=Id,part=Part,state=State}).

