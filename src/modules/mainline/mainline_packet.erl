%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(mainline_packet).

-include("login_pb.hrl").

-compile(export_all).


handle(Message, RolePid)->
	RolePid ! {mainline_client_msg,Message}.

make_stagetop([])->
	#stagetop{
			  	serverid = 0,
				roleid = 0,
				name = [],
				bestscore = 0
			  }.

make_stagetop(ServerId,RoleId,Name,BestScore)->
	#stagetop{
			  	serverid = ServerId,
				roleid = RoleId,
				name = Name,
				bestscore = BestScore
			  }.

make_stage(Chapter,Stage,State,BestScore,RewardFlag,EntryTime,StageTop)->
	#stage{chapter = Chapter,
		   stageindex = Stage,
		   state = State,
		   bestscore = BestScore,
		   rewardflag = RewardFlag,
		   entrytime = EntryTime,
		   topone = StageTop
		  }.

encode_mainline_init_s2c(StageInfos)->
	%%io:format("send mainline_init_s2c ~p  ~p ~n",[StageInfos,get(roleid)]),
	login_pb:encode_mainline_init_s2c(#mainline_init_s2c{st = StageInfos}).

encode_mainline_update_s2c(StageInfo,Reason)->
	%%io:format("send mainline_update_s2c ~p  ~p ~n",[StageInfo,get(roleid)]),
	login_pb:encode_mainline_update_s2c(#mainline_update_s2c{st = StageInfo,type = Reason}).

encode_mainline_start_entry_s2c(Chapter,Stage,Difficulty,OpCode)->
	%%io:format("send mainline_start_entry_s2c ~p ~n",[get(roleid)]),
	login_pb:encode_mainline_start_entry_s2c(
	  	#mainline_start_entry_s2c{chapter = Chapter,
								  stage = Stage,
								  difficulty = Difficulty,
								  opcode = OpCode
								  }).

encode_mainline_start_s2c(Chapter,Stage,Difficulty,OpCode)->
	%%io:format("send mainline_start_s2c ~p ~n",[get(roleid)]),
	login_pb:encode_mainline_start_s2c(
	  	#mainline_start_s2c{chapter = Chapter,
							stage = Stage,
							difficulty = Difficulty,
							opcode = OpCode
						   }).

encode_mainline_end_s2c()->
	%%io:format("send mainline_end_s2c ~p ~n",[get(roleid)]),
	login_pb:encode_mainline_end_s2c(#mainline_end_s2c{}).

encode_mainline_result_s2c(Chapter,Stage,Difficulty,Result,Reward,BestScore,Score,Duration)->
	%%io:format("send mainline_result_s2c ~p ~n",[get(roleid)]),
	login_pb:encode_mainline_result_s2c(
	  #mainline_result_s2c{
						   chapter = Chapter,
						   stage = Stage,
						   difficulty = Difficulty,
						   result = Result,
						   reward = Reward,
						   bestscore = BestScore,
						   score = Score,
						   duration = Duration}).

encode_mainline_lefttime_s2c(Chapter,Stage,LeftTime)->
	%%io:format("send mainline_lefttime_s2c ~p ~n",[get(roleid)]),
	login_pb:encode_mainline_lefttime_s2c(
	  	#mainline_lefttime_s2c{
							   	chapter = Chapter,
								stage = Stage,
								lefttime = LeftTime}).

encode_mainline_remain_monsters_info_s2c(Chapter,Stage,KillNum,RemainNum)->
	login_pb:encode_mainline_remain_monsters_info_s2c(
	  	#mainline_remain_monsters_info_s2c{
								chapter = Chapter,
								stage = Stage,
							   	kill_num = KillNum,
								remain_num = RemainNum}).

encode_mainline_kill_monsters_info_s2c(Chapter,Stage,NpcProtoId,NeedNum)->
	login_pb:encode_mainline_kill_monsters_info_s2c(
	  	#mainline_kill_monsters_info_s2c{
								chapter = Chapter,
								stage = Stage,
							   	npcprotoid = NpcProtoId,
								neednum = NeedNum}).

encode_mainline_opt_s2c(Errno)->
	login_pb:encode_mainline_opt_s2c(#mainline_opt_s2c{errno = Errno}).

encode_mainline_section_info_s2c(CurSection,NextSection_s)->
	login_pb:encode_mainline_section_info_s2c(
	  		#mainline_section_info_s2c{cur_section = CurSection,
									   next_section_s = NextSection_s}).

encode_mainline_protect_npc_info_s2c(NpcId,MaxHp,CurHp)->
	login_pb:encode_mainline_protect_npc_info_s2c(
	  		#mainline_protect_npc_info_s2c{npcprotoid = NpcId,
									   		maxhp = MaxHp,
											curhp = CurHp}).

encode_mainline_reward_success_s2c(Chapter,Stage)->
	login_pb:encode_mainline_reward_success_s2c(
	  		#mainline_reward_success_s2c{chapter = Chapter,
									   		stage = Stage
											}).

