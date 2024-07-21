%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-7
%% Description: TODO: Add description to loop_instance_packet
-module(loop_instance_packet).

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
handle(Message,Pid)->
	%%slogger:msg("~p handle unknownmsg ~p pid ~p ~n",[?MODULE,Message,Pid]).
	Pid ! {loop_instance_client,Message}.
	
make_votestate(RoleId,State)->
	#votestate{roleid = RoleId,
			   state = State}.

encode_entry_loop_instance_vote_s2c(Type,VoteList)->
	login_pb:encode_entry_loop_instance_vote_s2c(
	  		#entry_loop_instance_vote_s2c{type=Type,state = VoteList}).

encode_entry_loop_instance_vote_update_s2c(Vote)->
	login_pb:encode_entry_loop_instance_vote_update_s2c(
	  		#entry_loop_instance_vote_update_s2c{state = Vote}).

encode_entry_loop_instance_s2c(Layer,Result,LeftTime_s,BestTime_s,Type)->
	login_pb:encode_entry_loop_instance_s2c(
	  		#entry_loop_instance_s2c{
									 layer = Layer,
									 result = Result,
									 lefttime = LeftTime_s,
									 besttime = BestTime_s,
									 type=Type
							}).

encode_leave_loop_instance_s2c(Layer,Result)->
	login_pb:encode_leave_loop_instance_s2c(
	  		#leave_loop_instance_s2c{
									 layer = Layer,
									 result = Result
									 }).

encode_loop_instance_reward_s2c(Layer,Type,CurLayer)->
	login_pb:encode_loop_instance_reward_s2c(
	  		#loop_instance_reward_s2c{layer = Layer,type = Type,curlayer = CurLayer}).


encode_loop_instance_remain_monsters_info_s2c(KillNum,RemainNum,Type,Layer)->
	login_pb:encode_loop_instance_remain_monsters_info_s2c(
	  		#loop_instance_remain_monsters_info_s2c{
													kill_num = KillNum,
													remain_num = RemainNum,
													type = Type,
													layer = Layer}).


encode_loop_instance_kill_monsters_info_s2c(NpcProto,NeedNum,Type,Layer)->
	login_pb:encode_loop_instance_kill_monsters_info_s2c(
	  				#loop_instance_kill_monsters_info_s2c{
														  npcprotoid = NpcProto,
														  neednum = NeedNum,
														  type = Type,
														  layer = Layer
														  }).

encode_loop_instance_opt_s2c(Code)->
	login_pb:encode_loop_instance_opt_s2c(#loop_instance_opt_s2c{code = Code}).

make_kmi(NpcProto,NeedNum)->
	#kmi{npcproto = NpcProto, neednum = NeedNum}.
	
encode_loop_instance_kill_monsters_info_init_s2c(NpcInfoList,Type,Layer)->
	login_pb:encode_loop_instance_kill_monsters_info_init_s2c(
	  			#loop_instance_kill_monsters_info_init_s2c{
														   info = NpcInfoList,
														   type = Type,
														   layer = Layer}).

	
%%
%% Local Functions
%%

