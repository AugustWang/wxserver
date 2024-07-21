%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2011-12-27
%% Description: TODO: Add description to jyt_boss_baseattr_template
-module(jyt_boss_baseattr_template).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([get_maxhp/2,get_maxmp/2,get_exp/2,get_minmoney/2,get_maxmoney/2]).
-export([get_power/2,get_immunes/2,get_hitrate/2,get_dodge/2,get_criticalrate/2]).
-export([get_criticaldamage/2,get_toughness/2,get_debuffimmunes/2,get_defenses/2]).

%%
%% API Functions
%%
get_maxhp(Level,OldValue)->
	erlang:trunc(39.929*Level*Level+911.1092*Level-58216.3714).

get_maxmp(Level,OldValue)->
	OldValue.

get_exp(Level,OldValue)->
	if
			Level < 40->
				106667;
			true->
				erlang:trunc(2666.6661*Level+0.0351)
	end.

get_minmoney(Level,OldValue)->
	OldValue.

get_maxmoney(Level,OldValue)->
	OldValue.

get_power(Level,OldValue)->
	erlang:trunc(0.1115*Level*Level+8.3375*Level-371.5447).

get_immunes(Level,OldValue)->
	OldValue.

get_hitrate(Level,OldValue)->
	erlang:trunc(-0.058*Level*Level+20.6959*Level+219.54).

get_dodge(Level,OldValue)->
	erlang:trunc(-0.059*Level*Level+21.5646*Level-710.7708).

get_criticalrate(Level,OldValue)->
	erlang:trunc(-0.0595*Level*Level+20.139*Level-608.3948).

get_criticaldamage(Level,OldValue)->
	erlang:trunc(-0.0595*Level*Level+20.139*Level-158.3948).

get_toughness(Level,OldValue)->
	erlang:trunc(-0.0605*Level*Level+21.0065*Level-688.6117).

get_debuffimmunes(Level,OldValue)->
	OldValue.

get_defenses(Level,OldValue)->
	{MagicDefenses,RangeDefenses,MeleeDefenses} = OldValue,
	{MagicDefenses,RangeDefenses,MeleeDefenses}.


%%
%% Local Functions
%%
