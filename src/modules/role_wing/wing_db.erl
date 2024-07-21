%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-4-17
%% Description: TODO: Add description to wing_db
-module(wing_db).
%%
%% Include files
%%
-define(WING_LEVEL_ETS,wing_level).
-define(WING_PHASE_ETS,wing_phase).
-define(WING_QUALITY_ETS,wing_quality).
-define(WING_INTENSIFY_ETS,wing_intensify_up_ets).
-define(WING_SKILL_ETS,wing_skill_ets).
-define(ITEM_GOLD_PRICE_ETS,item_gold_price_ets).
-define(WING_ECHANT_ETS,wing_echant_ets).
-define(WING_ECHANT_GOLD_ETS,wing_echant_gold_ets).
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
-include("role_wing.hrl").



%%
%% API Functions
%%

start()->
	db_operater_mod:start_module(?MODULE,[]).
create_mnesia_table(disc)->
	db_tools:create_table_disc(wing_level,record_info(fields,wing_level),[],set),
	db_tools:create_table_disc(wing_phase,record_info(fields,wing_phase),[],set),
	db_tools:create_table_disc(wing_quality,record_info(fields,wing_quality),[],set),
	db_tools:create_table_disc(wing_intensify_up,record_info(fields,wing_intensify_up),[],set),
	db_tools:create_table_disc(wing_skill,record_info(fields,wing_skill),[],bag),
	db_tools:create_table_disc(item_gold_price,record_info(fields,item_gold_price),[],set),
	db_tools:create_table_disc(wing_echant,record_info(fields,wing_echant),[],set),
	db_tools:create_table_disc(wing_echant_lock,record_info(fields,wing_echant_lock),[],set).

create_mnesia_split_table(wing_role,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,wing_role),[],set).

tables_info()->
	[{wing_level,proto},{wing_phase,proto},{wing_role,disc_split},{wing_skill,proto},{wing_intensify_up,proto},{item_gold_price,proto},{wing_echant,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?WING_LEVEL_ETS,[ordered_set,named_table]),
	ets:new(?WING_PHASE_ETS,[ordered_set,named_table]),
	ets:new(?WING_QUALITY_ETS,[ordered_set,named_table]),
	ets:new(?WING_INTENSIFY_ETS,[ordered_set,named_table]),
	ets:new(?WING_SKILL_ETS,[ordered_set,named_table]),
	ets:new(?ITEM_GOLD_PRICE_ETS,[ordered_set,named_table]),
	ets:new(?WING_ECHANT_ETS,[ordered_set,named_table]),
	ets:new(?WING_ECHANT_GOLD_ETS,[ordered_set,named_table]).

init()->
	db_operater_mod:init_ets(wing_level, ?WING_LEVEL_ETS,#wing_level.level),
	db_operater_mod:init_ets(wing_phase, ?WING_PHASE_ETS,#wing_phase.phase),
	db_operater_mod:init_ets(wing_quality, ?WING_QUALITY_ETS,#wing_quality.quality),
	db_operater_mod:init_ets(wing_intensify_up, ?WING_INTENSIFY_ETS,#wing_intensify_up.intensify),
	db_operater_mod:init_ets(wing_skill, ?WING_SKILL_ETS,[#wing_skill.skillid,#wing_skill.level]),
	db_operater_mod:init_ets(item_gold_price, ?ITEM_GOLD_PRICE_ETS,#item_gold_price.itemid),
	db_operater_mod:init_ets(wing_echant, ?WING_ECHANT_ETS,#wing_echant.quality),
	db_operater_mod:init_ets(wing_echant_lock, ?WING_ECHANT_GOLD_ETS,#wing_echant_lock.num).

%%
%% Local Functions
%%
get_wing_levelinfo(Level)->
	try
		case ets:lookup(?WING_LEVEL_ETS,Level ) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing%io:format("@@@@@@@@@@@     wing level ets error ~n",[])
	end.

get_wing_level_needitem(Info)->
	#wing_level{item=Item}=Info,
	Item.
get_wing_level_add_money(Info)->
	#wing_level{money=Money}=Info,
	Money.
get_wing_level_add_power(Info)->
	#wing_level{power=Power}=Info,
	Power.
get_wing_level_add_defence(Info)->
	#wing_level{defence=Defence}=Info,
	Defence.
get_wing_level_add_hpmax(Info)->
	#wing_level{hpmax=Hpmax}=Info,
	Hpmax.
get_wing_level_add_mpmax(Info)->
	#wing_level{mpmax=Mpmax}=Info,
	Mpmax.
get_role_winginfo(Roleid)->
	Tablename=db_split:get_owner_table(wing_role,Roleid),
	case dal:read_rpc(Tablename, Roleid) of
		{ok,[Info]}->
			Info;
		_->
			[]
	end.

get_wing_phase_from_winginfo(Info)->
	case Info of
		[]->
			Phase=0;
		_->
			{_,_,_,_,Phase,_,_,_,_,_,_}=Info,
			Phase
	end,
	Phase.

get_wing_phase_info(Phase)->
	try
			case ets:lookup(?WING_PHASE_ETS, Phase) of
				[{_,Info}]->
					Info;
				_->
					[]
			end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@@   error ~p~n",[Error])
	end.
get_wing_phase_from_phaseinfo(Info)->
	#wing_phase{phase=Phase}=Info,
	Phase.
get_wing_item_from_phaseinfo(Info)->
	#wing_phase{item=Item}=Info,
	Item.
get_wing_money_from_phaseinfo(Info)->
	#wing_phase{money=Money}=Info,
	Money.
get_wing_speed_from_phaseinfo(Info)->
	#wing_phase{speed=Speed}=Info,
	Speed.
get_wing_power_from_phaseinfo(Info)->
	#wing_phase{power=Power}=Info,
	Power.
get_wing_defense_from_phaseinfo(Info)->
	#wing_phase{defense=Defense}=Info,
	Defense.
get_wing_hpmax_from_phaseinfo(Info)->
	#wing_phase{hpmax=Hpmax}=Info,
	Hpmax.
get_wing_mpmax_from_phaseinfo(Info)->
	#wing_phase{mpmax=Mpmax}=Info,
	Mpmax.
get_wing_maxintensity_from_phaseinfo(Info)->
	#wing_phase{maxintensity=Maxintensity}=Info,
	Maxintensity.
get_wing_failedbless_from_phaseinfo(Info)->
	#wing_phase{failedbless=Failedbless}=Info,
	Failedbless.
get_wing_rate_from_phaseinfo(Info)->
	#wing_phase{rate=Rate}=Info,
	Rate.
get_wing_addrate_from_phaseinfo(Info)->
	#wing_phase{addrate=Addrate}=Info,
	Addrate.

get_wing_quality_info(Quality)->
	try
		case ets:lookup(?WING_QUALITY_ETS, Quality) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@    wing quality ets error ~n ",[])
	end.
get_quality_from_qualityinfo(Info)->
	#wing_quality{quality=Quality}=Info,
	Quality.
get_item_from_qualityinfo(Info)->
	#wing_quality{item=Item}=Info,
	Item.
get_money_from_qualityinfo(Info)->
	#wing_quality{money=Money}=Info,
	Money.
get_power_from_qualityinfo(Info)->
	#wing_quality{power=Power}=Info,
	Power.
get_defense_from_qualityinfo(Info)->
	#wing_quality{defense=Defense}=Info,
	Defense.
get_hpmax_from_qualityinfo(Info)->
	#wing_quality{hpmax=Hpmax}=Info,
	Hpmax.
get_mpmax_from_qualityinfo(Info)->
	#wing_quality{mpmax=Mpmax}=Info,
	Mpmax.
get_skill_from_qualityinfo(Info)->
	#wing_quality{skill=Skill}=Info,
	Skill.

get_wing_intensify_info(Intensify)->
	try
		case ets:lookup(?WING_INTENSIFY_ETS, Intensify) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@ wing intensify error is   ~p~n",[Error])
	end.

get_intensify_from_intenfifyinfo(Info)->
	#wing_intensify_up{intensify=Intensify}=Info,
	Intensify.

get_item_from_intenfifyinfo(Info)->
	#wing_intensify_up{item=Item}=Info,
	Item.

get_money_from_intenfifyinfo(Info)->
	#wing_intensify_up{money=Money}=Info,
	Money.

get_maxperfectness_from_intenfifyinfo(Info)->
	#wing_intensify_up{maxperfectness=Maxperfectness}=Info,
	Maxperfectness.

get_unlockskill_from_intenfifyinfo(Info)->
	#wing_intensify_up{unlockskill=Unlockskill}=Info,
	Unlockskill.

get_attrrate_from_intenfifyinfo(Info)->
	#wing_intensify_up{attrsate=Attrate}=Info,
	Attrate.

get_item_gold_price_info(ItemId)->
	try
		case ets:lookup(?ITEM_GOLD_PRICE_ETS, ItemId) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@@@ wing intensify error is   ~p~n",[Error])
	end.

get_itemid_from_itemgoldinfo(Info)->
	#item_gold_price{itemid=ItemId}=Info,
	ItemId.

get_gold_from_itemgoldinfo(Info)->
	#item_gold_price{price=Price}=Info,
	Price.

get_wing_echant_num_info(Quality)->
	try
		case ets:lookup(?WING_ECHANT_ETS, Quality) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@   error wing echant ~p~n",[Error])
	end.
get_quality_from_echantinfo(Info)->
	#wing_echant{quality=Quality}=Info,
	Quality.
get_item_from_echantinfo(Info)->
	#wing_echant{item=Item}=Info,
	Item.
get_money_from_echantinfo(Info)->
	#wing_echant{money=Money}=Info,
	Money.

get_echantnum_from_echantinfo(Info)->
	#wing_echant{maxnumber=MaxNum}=Info,
	MaxNum.

get_wing_echant_lockgold_info(Num)->
	try
		case ets:lookup(?WING_ECHANT_GOLD_ETS, Num) of
			[{_,Info}]->
				Info;
			_->
				[]
		end
	catch
		_:_Error->nothing
			%io:format("@@@@@@@@@   error wing echant gold error~n",[])
	end.

get_num_from_lockenchant_info(Info)->
		#wing_echant_lock{num=Num}=Info,
		Num.
get_item_from_lockenchant_info(Info)->
	#wing_echant_lock{item=Item}=Info,
	Item.

get_gold_from_lockenchant_info(Info)->
	#wing_echant_lock{gold=Gold}=Info,
	Gold.

async_write_roleattr(Object)-> 
	{RoleId,Level,Social,Quality,Streng,Strengup,Strengadd,Skill,Echants,Lucky}=Object,
	TableName=db_split:get_owner_table(wing_role, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,Level,Social,Quality,Streng,Strengup,Strengadd,Skill,Echants,Lucky}).