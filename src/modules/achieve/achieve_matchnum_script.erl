%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2010-12-16
%% Description: TODO: Add description to achieve_friend_script
-module(achieve_matchnum_script).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([todo/2]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("pet_struct.hrl").
-include("npc_struct.hrl").
%%
%% API Functions
%%
todo(_AchieveId,Target)->
	[{Msg,List,Count}] = Target,
	case Msg of
		add_friend->
			Myfriends = erlang:length(get(myfriends)),
			if 
				Myfriends >= Count->
					{true,0};
				true->
					{other}
			end;
		level->
			Level = get_level_from_roleinfo(get(creature_info)),
			if
				Level >= Count->
					{true,Level};
				true->
					{other}
			end;
		money->
			Money = get_boundsilver_from_roleinfo(get(creature_info)),
			if
				Money >= Count->
					{true,Money};
				true->
					{other}
			end;
		guildposting->
			GuildPosting = get_guildposting_from_roleinfo(get(creature_info)),
			if
				GuildPosting >= Count->
					{true,GuildPosting};
				true->
					{other}
			end;
		pet_level->
			MaxLevel = lists:map(fun(PetInfo)->
								  		PetLevel = get_level_from_petinfo(PetInfo)
									 end,get(gm_pets_info)),
			PetMaxLevel = lists:max(MaxLevel),
			if
				PetMaxLevel >= Count->
					{true,PetMaxLevel};
				true->
					{other}
			end;
		pet_tanlent->
			MaxScore = lists:map(fun(PetInfo)->
								  		TalentScore = get_talent_score_from_mypetinfo(PetInfo)
									 end,get(pets_info)),
			PetMaxScore = lists:min(MaxScore),
			if
				PetMaxScore >= Count->
					{true,PetMaxScore};
				true->
					{other}
			end;
		power->
			Power = get_power_from_roleinfo(get(creature_info)),
			if
				Power >= Count->
					{true,Power};
				true->
					{other}
			end;
		hpmax->
			Hpmax = get_hpmax_from_roleinfo(get(creature_info)),
			if
				Hpmax >= Count->
					{true,Hpmax};
				true->
					{other}
			end;
		defense->
			{Meleedefense,Rangedefense,Magicdefense} = get_defenses_from_roleinfo(get(creature_info)),
			case (Meleedefense + Rangedefense + Magicdefense) >= Count * 3 of
				true->
					{true,Meleedefense + Rangedefense + Magicdefense};
				false->
					{other}
			end;
		fighting_force->
			FightForce = get_fighting_force_from_roleinfo(get(creature_info)),
			if
				FightForce >= Count->
					{true,FightForce};
				true->
					{other}
			end;
		learn_skill->
			{_,_,SkillList} = get(skill_info),
			case length(SkillList) >= Count of
				true->
					{true,Count};
				_->
					{other}
			end;
		_->
			{other}
	end.
				   

%%
%% Local Functions
%%

