%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-6-30
%% Description: TODO: Add description to quest_package
-module(quest_packet).

%%
%% Include files
%%
-export([handle/2,send_data_to_gate/1]).

-export([encode_questgiver_quest_details_s2c/3,
		 encode_quest_list_add_s2c/3,
		 encode_quest_details_s2c/3,
		 encode_quest_list_remove_s2c/1,
		 encode_quest_statu_update_s2c/3,
		 encode_quest_complete_s2c/1,
		 encode_quest_complete_failed_s2c/2,
		 encode_quest_list_update_s2c/1,
		 encode_questgiver_states_update_s2c/2,
		 encode_role_quest/4,
		 encode_quest_get_adapt_s2c/2,
		 encode_start_everquest_s2c/8,
		 encode_refresh_everquest_s2c/5,
		 encode_update_everquest_s2c/6,
		 encode_npc_everquests_enum_s2c/2,
		 encode_everquest_list_s2c/1,
		 encode_quest_accept_failed_s2c/1,
		 make_everquest/6,
		 process_msg/1,
		 encode_refresh_everquest_result_s2c/3]).


-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%
%%
%% API Functions
%%


handle(#questgiver_hello_c2s{npcid=NpcId},RolePid)->
	role_processor:questgiver_hello_c2s(RolePid,NpcId);

handle(#questgiver_accept_quest_c2s{npcid = NpcId,questid=QuestId},RolePid)->
	role_processor:questgiver_accept_quest_c2s(RolePid,NpcId,QuestId);

handle(#quest_quit_c2s{questid=QuestId},RolePid)->
	role_processor:quest_quit_c2s(RolePid,QuestId);

handle(#questgiver_complete_quest_c2s{questid=QuestId,npcid = Npcid,choiceslot=ChoiceItem},RolePid)->
	role_processor:questgiver_complete_quest_c2s(RolePid,Npcid,QuestId,ChoiceItem);

handle(#quest_details_c2s{questid=QuestId},RolePid)->
	role_processor:quest_details_c2s(RolePid,QuestId);
	
handle(#questgiver_states_update_c2s{npcid=Npcids},RolePid)->
	role_processor:questgiver_states_update_c2s(RolePid,Npcids);

handle(#quest_get_adapt_c2s{},RolePid)->
	role_processor:quest_get_adapt_c2s(RolePid);

handle(#refresh_everquest_c2s{everqid = EverId,freshtype = Type,maxquality = MaxQuality,maxtimes = MaxTimes},RolePid)->
	role_processor:refresh_everquest_c2s(RolePid,EverId,Type, MaxQuality, MaxTimes);

handle(#npc_start_everquest_c2s{npcid =NpcId,everqid =EverQId},RolePid)->
	role_processor:npc_start_everquest_c2s(RolePid,EverQId,NpcId);

handle(#npc_everquests_enum_c2s{npcid =NpcId},RolePid)->
	role_processor:npc_everquests_enum_c2s(RolePid,NpcId);

handle(#quest_direct_complete_c2s{questid = QuestId},RolePid)->
	role_processor:quest_direct_complete_c2s(RolePid,QuestId);

handle(_Message,_RolePid)->
	ok.

encode_questgiver_quest_details_s2c(Npcid,QuestIds,Status)->
	login_pb:encode_questgiver_quest_details_s2c(#questgiver_quest_details_s2c{npcid = Npcid,quests = QuestIds,queststate = Status}).

encode_quest_list_add_s2c(QuestId,State,Values)->
	login_pb:encode_quest_list_add_s2c(#quest_list_add_s2c{
									quest = #q{questid= QuestId,status= State,values = Values,lefttime=0}}).

encode_quest_details_s2c(QuestId,State,NpcId)->
	login_pb:encode_quest_details_s2c(#quest_details_s2c{npcid = NpcId,questid= QuestId,queststate= State}).

encode_quest_list_remove_s2c(QuestId)->
	login_pb:encode_quest_list_remove_s2c(#quest_list_remove_s2c{questid= QuestId}).

encode_quest_statu_update_s2c(QuestId,State,Values)->
	login_pb:encode_quest_statu_update_s2c(#quest_statu_update_s2c{
									quests = #q{questid= QuestId,status= State,values = Values,lefttime = 0}}).

encode_quest_list_update_s2c(Lists)->
	login_pb:encode_quest_list_update_s2c(#quest_list_update_s2c{quests = Lists} ).

encode_questgiver_states_update_s2c(Npcid,States)->
	login_pb:encode_questgiver_states_update_s2c(#questgiver_states_update_s2c{npcid = Npcid,queststate = States} ).

encode_quest_complete_s2c(Questid)->
	login_pb:encode_quest_complete_s2c(#quest_complete_s2c{questid = Questid} ).
	
encode_quest_complete_failed_s2c(Questid,Errno)->
	login_pb:encode_quest_complete_failed_s2c(#quest_complete_failed_s2c{questid = Questid,errno=Errno} ).
   
encode_role_quest(QuestId,State,Values,LeftTime)->
	#q{questid= QuestId,status= State,values = Values,lefttime = LeftTime}.

send_data_to_gate(Message) ->
	role_op:send_data_to_gate(Message).	

encode_quest_get_adapt_s2c(QuestIds,EverQIds)->
	login_pb:encode_quest_get_adapt_s2c(#quest_get_adapt_s2c{questids = QuestIds,everqids = EverQIds}).
	
encode_start_everquest_s2c(EverQId,QuestId,Freetimes,Round,Section,Qua,NpcId,FreeSetTimeTmp)->
	login_pb:encode_start_everquest_s2c(#start_everquest_s2c{everqid = EverQId,questid = QuestId,
										free_fresh_times = Freetimes,round = Round,section=Section,quality = Qua,npcid = NpcId,resettime = FreeSetTimeTmp}).

encode_refresh_everquest_s2c(Everqid,Questid,Quality,Free_fresh_times,FreeSetTime)->
	login_pb:encode_refresh_everquest_s2c(#refresh_everquest_s2c{everqid = Everqid,questid = Questid,quality = Quality,free_fresh_times = Free_fresh_times,resettime = FreeSetTime}).

encode_update_everquest_s2c(EverQId,QuestId,Freetimes,Round,Section,Qua)->
	login_pb:encode_update_everquest_s2c(#start_everquest_s2c{everqid = EverQId,questid = QuestId,
										free_fresh_times = Freetimes,round = Round,section=Section,quality = Qua}).

encode_npc_everquests_enum_s2c(NpcId,Everquests)->
	login_pb:encode_npc_everquests_enum_s2c(#npc_everquests_enum_s2c{everquests = Everquests,npcid = NpcId}).

make_everquest(EverQId,QuestId,Freetimes,Round,Section,Qua)->
	#eq{everqid = EverQId,questid = QuestId,free_fresh_times = Freetimes,round = Round,section=Section,quality = Qua}.

encode_everquest_list_s2c(Everquests)->
	login_pb:encode_everquest_list_s2c(#everquest_list_s2c{everquests = Everquests}).

encode_quest_accept_failed_s2c(Errno)->
	login_pb:encode_quest_accept_failed_s2c(#quest_accept_failed_s2c{errno = Errno}).

encode_refresh_everquest_result_s2c(UseFreeTime, UseItem, UseMoney) ->
	login_pb:encode_refresh_everquest_result_s2c(#refresh_everquest_result_s2c{freetime = UseFreeTime, itemcount = UseItem, sliver = UseMoney}).
%%
%% Local API
%%

%%
%%
%%
%%make_status(QuestId,Status,Var1,Var2,Var3)->
%%		#role_quest{questid=QuestId,
%%					status=quest_util:get_status_code(Status),
%%					objective_var1=Var1,
%%					objective_var2=Var2,
%%					objective_var3=Var3}.

process_msg({quest_join_guild})->
	quest_op:update(join_guild,1);

process_msg(_)->
	ignor.