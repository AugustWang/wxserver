%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_wooden_man).

-include("string_define.hrl").
-export([be_attacked/4]).

be_attacked(EnemyId,SkillId,_SkillLevel,Damage)->
	case creature_op:what_creature(EnemyId) of
		role->
			case combat_op:is_normal_attack(SkillId) of
				true->
					SendDamage = erlang:abs(Damage),
					ContextFormat = language:get_string(?WOODEN_MAN_PART),
					Context = util:sprintf(ContextFormat,[SendDamage]),
					npc_ai:speak_to_role(EnemyId,Context);
				_->
					case creature_op:get_creature_info(EnemyId) of
						undefined->
							nothing;
						OtherInfo->
							npc_op:update_touchred_into_selfinfo(EnemyId),
							npc_op:on_dead(OtherInfo),
							deading
					end
			end;
		_->
			nothing
	end.
		