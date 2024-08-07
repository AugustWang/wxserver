%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(magic_shield).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

-compile(export_all).

%%return:new ChangedAttr

%%鎶垫尅浼ゅ
hook_on_beattack(OriDamage,_OriChangeAttr,{BuffId,BuffLevel})->
	CurMp = creature_op:get_mana_from_creature_info(get(creature_info)),
	CurHp = creature_op:get_life_from_creature_info(get(creature_info)),
	BuffInfo = buffer_db:get_buffer_info(BuffId,BuffLevel),
	[AssValue,Rate]= buffer_db:get_buffer_effect_arguments(BuffInfo),
	MaxAssDamage = CurMp*Rate,
	AssRate = (1 - AssValue/100),
	ChangedAttr = 
	if
		OriDamage*AssRate + MaxAssDamage =< 0->		%%鍚稿共鎴� ,杩樹笉澶熶綘鍚哥殑
			LossMp = -CurMp,
			LossHp = trunc(OriDamage + MaxAssDamage),
			NewLift = erlang:max(CurHp + LossHp, 0),
			role_op:remove_buffer({BuffId,BuffLevel}),
			[{hp,NewLift},{mp,0}];
		true->									%%褰撳墠钃濊繕澶熷惛
			LossHp = trunc(OriDamage*AssRate),
			LossMp = trunc((OriDamage-LossHp)/Rate),
			%%涓㈠け钃� = 鍚告敹浼ゅ/钃濅激瀹虫瘮鐜�
			NewLift = erlang:max(CurHp + LossHp, 0),
			[{hp,NewLift},{mp,CurMp+LossMp}]
	end,
	if
		LossMp=/= 0->
			Message = role_packet:encode_buff_affect_attr_s2c(get(roleid),[role_attr:to_role_attribute({mp,LossMp}),role_attr:to_role_attribute({hp,LossHp})]),
			role_op:send_data_to_gate(Message ),
			role_op:broadcast_message_to_aoi_client(Message);
		true->
			nothing
	end,			 			
 	ChangedAttr.