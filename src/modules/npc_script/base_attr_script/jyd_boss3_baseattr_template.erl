%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2011-12-27
%% Description: TODO: Add description to jyd_boss3_baseattr_template
-module(jyd_boss3_baseattr_template).

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
	erlang:trunc(33.0205*Level*Level-2163.4028*Level+36768.8934).

get_maxmp(Level,OldValue)->
	OldValue.

get_exp(Level,OldValue)->
  (16*Level).

get_minmoney(Level,OldValue)->
	erlang:trunc(11.1057*Level+11.2472).

get_maxmoney(Level,OldValue)->
	erlang:trunc(11.1057*Level+11.2472).

get_power(Level,OldValue)->
  erlang:trunc(0.0121*Level*Level+21.5339*Level-764.684).
  
get_immunes(Level,OldValue)->
	OldValue.

get_hitrate(Level,OldValue)->
	erlang:trunc((-0.0777)*Level*Level+20.839*Level+213.718).

get_dodge(Level,OldValue)->
	OldValue.

get_criticalrate(Level,OldValue)->
	OldValue.

get_criticaldamage(Level,OldValue)->
	OldValue.

get_toughness(Level,OldValue)->
	OldValue.

get_debuffimmunes(Level,OldValue)->
	OldValue.

get_defenses(Level,OldValue)->
	{MagicDefenses,RangeDefenses,MeleeDefenses} = OldValue,
	{MagicDefenses,RangeDefenses,MeleeDefenses}.


%%
%% Local Functions
%%

