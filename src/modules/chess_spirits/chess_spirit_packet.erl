%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(chess_spirit_packet).

%%
%% Include files
%%
-export([handle/2]).
-export([encode_chess_spirit_info_s2c/5,encode_chess_spirit_role_info_s2c/8,encode_chess_spirit_update_power_s2c/1,encode_chess_spirit_update_skill_s2c/1,
		encode_chess_spirit_update_chess_power_s2c/1,encode_chess_spirit_opt_result_s2s/1,encode_chess_spirit_log_s2c/8,encode_chess_spirit_game_over_s2c/4,
		 encode_chess_spirit_prepare_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").


handle(Msg,RolePid)->
	RolePid ! {npc_chess_spirit,Msg}.

encode_chess_spirit_info_s2c(CurSection,UsedTime,NextSecTime,MaxHp,CurHp)->
	login_pb:encode_chess_spirit_info_s2c(#chess_spirit_info_s2c{cur_section = CurSection,
			used_time_s = UsedTime,next_sec_time_s = NextSecTime,spiritmaxhp = MaxHp,spiritcurhp = CurHp}).

encode_chess_spirit_role_info_s2c(Power,ChessPower,MaxPower,MaxChessPower,Share_skills,Self_skills,ChessSkills,Type)->
	login_pb:encode_chess_spirit_role_info_s2c(#chess_spirit_role_info_s2c{power = Power,chesspower = ChessPower,max_power = MaxPower,
																			max_chesspower = MaxChessPower,share_skills = Share_skills,
																		   self_skills = Self_skills,chess_skills=ChessSkills,type = Type}).

encode_chess_spirit_update_power_s2c(NewPower)->
	login_pb:encode_chess_spirit_update_power_s2c(#chess_spirit_update_power_s2c{newpower = NewPower}).
	
encode_chess_spirit_update_skill_s2c(Skills)->
	login_pb:encode_chess_spirit_update_skill_s2c(#chess_spirit_update_skill_s2c{update_skills = Skills}).
 
encode_chess_spirit_update_chess_power_s2c(Power)->
	login_pb:encode_chess_spirit_update_chess_power_s2c(#chess_spirit_update_chess_power_s2c{newpower = Power}).

encode_chess_spirit_game_over_s2c(Type,Section,UsedTime,Reason)->
	login_pb:encode_chess_spirit_game_over_s2c(#chess_spirit_game_over_s2c{type = Type,section = Section,used_time_s = UsedTime,reason = Reason}).

encode_chess_spirit_opt_result_s2s(Errno)->
	login_pb:encode_chess_spirit_opt_result_s2s(#chess_spirit_opt_result_s2s{errno = Errno}).

encode_chess_spirit_log_s2c(Type,LastSec,LastTime,BestSec,BestTime,CanReward,Rewardexp,RewardItems)->
	SendRewardItems = lists:map(fun({ItemProtoId,Count})-> pb_util:loot_slot_info(ItemProtoId,Count) end,RewardItems),
	login_pb:encode_chess_spirit_log_s2c(#chess_spirit_log_s2c{type = Type,lastsec = LastSec,lasttime = LastTime,bestsec = BestSec,
															   bestsectime = BestTime,canreward = CanReward,rewardexp = Rewardexp,rewarditems = SendRewardItems}).

encode_chess_spirit_prepare_s2c(Seconds)->
	login_pb:encode_chess_spirit_prepare_s2c(#chess_spirit_prepare_s2c{time_s = Seconds}).
