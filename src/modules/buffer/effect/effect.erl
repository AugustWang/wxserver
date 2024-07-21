%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-20
%% Description: TODO: Add description to effect
-module(effect).

%%
%% 
%%


%%
%% Exported Functions
%%
-export([get_value/2,
		 combin_effect/1,
		 get_effect_module/1,
		 is_attr_effect/1,
		 is_function_effect/1,
		 proc_buffer_function_effects/1]).


get_value(EffectsList,EffectName)->
	case lists:keyfind(EffectName, 1, EffectsList) of
		false-> 0;
		{EffectName,Value}->Value
	end.

get_info(EffectsList,EffectName)->
	case lists:keyfind(EffectName, 1, EffectsList) of
		false-> [];
		Info->Info
	end.

combin_effect(EffectsList)->
	lists:foldl(fun({Key,Value},AccEff)->
				    case lists:keyfind(Key, 1, AccEff)of
					    false-> [{Key,Value}|AccEff];
						{displayid,_OldValue}->		%%directly replace todo list
							lists:keyreplace(displayid, 1, AccEff, {displayid,Value});
					    {Key,AccValue}-> 
						    lists:keyreplace(Key, 1, AccEff, {Key,AccValue+Value})
				    end	
		    end, [], EffectsList).


is_attr_effect(EffectId)->
	get_effect_module(EffectId) =:= {undefined,undefined}.

is_function_effect(EffectId)->
	not is_attr_effect(EffectId).

%%script effect return ChangedAttrs/remove
%%ChangedAttrs->[{Attr,Value}]
get_effect_module(EffectId)->
	case EffectId of
		hpeffect -> {hpeffect,effect};
		hpeffect_percent->{hpeffect_percent,effect};
		mpeffect-> {mpeffect,effect};
		mpeffect_percent->{mpeffect_percent,effect};
		skill_hpeffect_percent->{skill_hpeffect_percent,effect};
		hp_package->{hp_package,effect};
		mp_package->{mp_package,effect};
		sitdown_effect->{sitdown_effect,effect};
		spa_effect->{spa_effect,effect};
		bonfire_effect->{bonfire_effect,effect};
		_-> {undefined,undefined}
	end.

%%return new attr after changed ChangeAttrs :[{Attr,Value}]
proc_buffer_function_effects(ChangeAttrs)->
	lists:foldl(fun({Attr,EffectValue},ChangedTmp)->
			ChangedTmp ++ proc_buffer_function_effect(Attr,EffectValue)			  
		end, [],ChangeAttrs).

%%
%% Local Functions
%%

%%return new attr after changed ChangeAttr [{Attr,NewAttr}]
proc_buffer_function_effect(hp,EffectValue)->
	CurInfo = get(creature_info),
	HPMax = creature_op:get_hpmax_from_creature_info(CurInfo),
	HPNow = creature_op:get_life_from_creature_info(CurInfo),
	case (HPNow =< HPMax) and (HPNow >0) of 
		true ->
			HPNew = erlang:max(0,erlang:min(HPMax, HPNow + EffectValue)),
			if
				HPNew=:=HPNow->
					[];
				true->
					put(creature_info,creature_op:set_life_to_creature_info(CurInfo, HPNew)),
					[{hp,HPNew}]
			end;
		false ->
			[]
	end;

proc_buffer_function_effect(mp,EffectValue)->		
	CurInfo = get(creature_info),
	MPMax  = creature_op:get_mpmax_from_creature_info(CurInfo),
	MPNow = creature_op:get_mana_from_creature_info(CurInfo),
	MPNew = erlang:max(erlang:min(MPMax, MPNow + EffectValue),0),
	if
		MPNew=:= MPNow ->
			[];
		true->
			put(creature_info, creature_op:set_mana_to_creature_info(CurInfo, MPNew )),
			[{mp,MPNew}]
	end.
				
			
			
			
			
			
			
			
			
