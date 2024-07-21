%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 角色信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-include("common_define.hrl").
-include("data_struct.hrl").
-include("map_info_struct.hrl").
-compile({inline, [{get_id_from_roleinfo, 1},
		   {get_pos_from_roleinfo, 1},
		   {get_life_from_roleinfo, 1}]}).

-record(gm_role_info, {gs_system_role_info, 
		       gs_system_map_info,
		       gs_system_gate_info,
		       pos, name, 
			   view,				%%星级
			   life, mana,
		       gender,				%%性别
		       icon,				%%头衔
		       speed, state,  
		       extra_states,
		       path, level,
		       silver,				%%游戏币，银币
		       boundsilver,			%%绑定游戏币,银币
		       gold,				%%元宝
		       ticket,				%%礼券
		       hatredratio,			%%仇恨比率
		       expratio,			%%经验比率
		       lootflag,			%%掉落系数
		       exp,					%%经验
		       levelupexp,			%%升级所需经验
		       agile,				%%敏
		       strength,			%%力
		       intelligence,		%%智
		       stamina,				%%体质
		       hpmax,		
		       mpmax,
		       hprecover,
		       mprecover,
		       power,				%%攻击力
		       class,				%%职业
		       commoncool,			%%公共冷却
		       immunes,				%%免疫力{魔，远，近}
		       hitrate,				%%命中
		       dodge,				%%闪避
		       criticalrate,		%%暴击
		       criticaldamage,		%%暴击伤害
		       toughness,			%%韧性
		       debuffimmunes,		%%debuff免疫{定身，沉默，昏迷，抗毒,一般}
		       defenses,			%%防御力{魔，远，近}
		       %%2010.9.20
		       buffer,				%%buffer
		       guildname,			%%公会名
		       guildposting,	    %%职位
		       cloth,				%%衣服
		       arm,					%%武器
		       pkmodel,				%%PK模式
		       crime,				%%罪恶值
			   viptag,				%%vip标志
		       %%2010.1.18
		       pet_id,
		       ride_display,		%%坐骑模型	
			   %%
			   camp,				%%阵营(0无1红2蓝)
			   displayid,			%%人物模型
			   companion_role,		%%双修对象
			   serverid,			%%当前服务器id
			   cur_designation,		%%人物称号
			   treasure_transport,	%%镖车
			   petexpratio,			%%宠物经验比率
			   group_id,			%%组队id
			   fighting_force,		%%战斗力
			   guildtype,			%%帮会类型
			   honor				%%荣誉值
		       }).

create_roleinfo() ->
	#gm_role_info{gs_system_role_info=#gs_system_role_info{},
		      icon = 0,
		      path=[],
			  view = 0,
		      hatredratio = 1,
		      expratio = [],
		      lootflag = 1,
		      extra_states = [],
		   	  debuffimmunes = {0,0,0,0,0},
		   	  immunes = {0,0,0},
		   	  defenses = {0,0,0},
		   	  buffer= [],
		      pet_id = 0,
			  camp = 0,
			  ride_display = 0,
			  companion_role = 0,
			  displayid = ?DEFAULT_ROLE_DISPLAYID,
			  treasure_transport = 0,
			  petexpratio = 1,
			  group_id = 0,
			  fighting_force = 0,
			  guildtype = 0,
			  honor = 0
		     }.	

set_roleinfo(RoleInfo,Role_id,Role_Class,Gender,Role_Level,RoleState,Role_pid,Role_node,Role_pos,
						Role_name,RoleSpeed,RoleLife,Hpmax,RoleMana,Mpmax,Expr,Silver,BoundSilver,LevelupExp,
						Gold,Ticket,Power,Commoncool,Hprecover,Mprecover,CriDerate,Criticalrate,Toughness,Dodge,
						Hitrate,Stamina,Agile,Strength,Intelligence,RoleIimmunes,RoleDebuffimmunes,RoleDefenses,GuildName,GuildPosting,
						RoleBuffs,Viptag,AllIcons,Crime,Pkmodel,Path,GS_GateInfo,GS_MapInfo,RoleServerId,CurDesignation,Treasure_Transport,Fighting_force,Honor)->
		RoleInfo#gm_role_info{
				gs_system_role_info=#gs_system_role_info{role_id = Role_id, role_pid = Role_pid,role_node = Role_node},
				gs_system_map_info = GS_MapInfo,
				gs_system_gate_info = GS_GateInfo,
				pos = Role_pos, 
				name = Role_name, 
				life = RoleLife, 
				mana = RoleMana,
				gender = Gender,
				icon = AllIcons,
				speed = RoleSpeed, 
				state = RoleState,  
				path = Path, 
				level = Role_Level,
				silver = Silver,
				boundsilver = BoundSilver,
				gold = Gold,
				ticket = Ticket,
				exp = Expr,	
				levelupexp = LevelupExp,
				agile = Agile,
				strength = Strength,
				intelligence = Intelligence,
				stamina = Stamina,
				hpmax = Hpmax,		
				mpmax = Mpmax,
				hprecover = Hprecover,
				mprecover = Mprecover,
				power = Power,	
				class = Role_Class,
				commoncool = Commoncool,
				immunes = RoleIimmunes,		
				hitrate = Hitrate,	
				dodge = Dodge,
				criticalrate = Criticalrate,
				criticaldamage = CriDerate,
				toughness = Toughness,			
				debuffimmunes = RoleDebuffimmunes,	
				defenses = RoleDefenses,	
				buffer = RoleBuffs,	
				guildname = GuildName,
				guildposting = GuildPosting,
				pkmodel = Pkmodel,
				crime = Crime,
				viptag = Viptag,
				serverid = RoleServerId,
				cur_designation = CurDesignation,
				treasure_transport = Treasure_Transport,		
				fighting_force = Fighting_force,
				honor = Honor
			}.
		
get_camp_from_roleinfo(RoleInfo)->
	#gm_role_info{camp=Camp} = RoleInfo,
	Camp.

set_camp_to_roleinfo(RoleInfo, Camp)->
	RoleInfo#gm_role_info{camp=Camp}.


get_pet_id_from_roleinfo(RoleInfo) ->
	#gm_role_info{pet_id=Pet_id} = RoleInfo,
	Pet_id.
set_pet_id_to_roleinfo(RoleInfo, Pet_id) ->
	RoleInfo#gm_role_info{pet_id=Pet_id}.

get_id_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_id_from_gs_system_roleinfo(GS_system_role_info).
set_id_to_roleinfo(RoleInfo, Id) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_id_to_gs_system_roleinfo(GS_system_role_info, Id),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_gender_from_roleinfo(RoleInfo) ->
	#gm_role_info{gender=Gender} = RoleInfo,
	Gender.
set_gender_to_roleinfo(RoleInfo, Gender) ->
	RoleInfo#gm_role_info{gender=Gender}.

get_icon_from_roleinfo(RoleInfo) ->
	#gm_role_info{icon=Icon} = RoleInfo,
	Icon.
set_icon_to_roleinfo(RoleInfo, Icon) ->
	RoleInfo#gm_role_info{icon=Icon}.
	
get_name_from_roleinfo(RoleInfo) ->
	#gm_role_info{name=Name} = RoleInfo,
	Name.
set_name_to_roleinfo(RoleInfo, Name) ->
	RoleInfo#gm_role_info{name=Name}.

get_pid_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_pid_from_gs_system_roleinfo(GS_system_role_info).
set_pid_to_roleinfo(RoleInfo, Pid) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_pid_to_gs_system_roleinfo(GS_system_role_info, Pid),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_node_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	get_node_from_gs_system_roleinfo(GS_system_role_info).
set_node_to_roleinfo(RoleInfo, Node) ->
	#gm_role_info{gs_system_role_info=GS_system_role_info} = RoleInfo,
	New_gs_system_roleinfo = set_node_to_gs_system_roleinfo(GS_system_role_info, Node),
	RoleInfo#gm_role_info{gs_system_role_info=New_gs_system_roleinfo}.

get_pos_from_roleinfo(RoleInfo) ->
	#gm_role_info{pos=Pos} = RoleInfo,
	Pos.
set_pos_to_roleinfo(RoleInfo, Pos) ->
	RoleInfo#gm_role_info{pos=Pos}.

get_speed_from_roleinfo(RoleInfo) ->
	#gm_role_info{speed=Speed} = RoleInfo,
	Speed.
set_speed_to_roleinfo(RoleInfo, Speed) ->
	RoleInfo#gm_role_info{speed=Speed}.

get_life_from_roleinfo(RoleInfo) ->
	#gm_role_info{life=Life} = RoleInfo,
	Life.
set_life_to_roleinfo(RoleInfo, Life) ->
	RoleInfo#gm_role_info{life=Life}.

get_view_from_roleinfo(RoleInfo) ->
	#gm_role_info{view=View} = RoleInfo,
	View.
set_view_to_roleinfo(RoleInfo, View) ->
	RoleInfo#gm_role_info{view=View}.

get_state_from_roleinfo(RoleInfo) ->
	#gm_role_info{state=State} = RoleInfo,
	State.
set_state_to_roleinfo(RoleInfo, State) ->
	RoleInfo#gm_role_info{state=State}.

get_path_from_roleinfo(RoleInfo) ->
	#gm_role_info{path=Path} = RoleInfo,
	Path.
set_path_to_roleinfo(RoleInfo, Path) ->
	RoleInfo#gm_role_info{path=Path}.

get_level_from_roleinfo(RoleInfo) ->
	#gm_role_info{level=Level} = RoleInfo,
	Level.
set_level_to_roleinfo(RoleInfo, Level) ->
	RoleInfo#gm_role_info{level=Level}.

set_silver_to_roleinfo(RoleInfo, Money) ->
	RoleInfo#gm_role_info{silver=Money}.
get_silver_from_roleinfo(RoleInfo) ->
	#gm_role_info{silver=Money} = RoleInfo,
	Money.		       	 
 
set_boundsilver_to_roleinfo(RoleInfo, Money) ->
	RoleInfo#gm_role_info{boundsilver=Money}.
get_boundsilver_from_roleinfo(RoleInfo) ->
	#gm_role_info{boundsilver=Money} = RoleInfo,
	Money.		       	 

set_ticket_to_roleinfo(RoleInfo, Ticket) ->
	RoleInfo#gm_role_info{ticket=Ticket}.
get_ticket_from_roleinfo(RoleInfo) ->
	#gm_role_info{ticket=Ticket} = RoleInfo,
	Ticket.
	
set_gold_to_roleinfo(RoleInfo, Gold) ->
	RoleInfo#gm_role_info{gold=Gold}.
get_gold_from_roleinfo(RoleInfo) ->
	#gm_role_info{gold=Gold} = RoleInfo,
	Gold.	
	
set_hatredratio_to_roleinfo(RoleInfo, Hatredratio) ->
	RoleInfo#gm_role_info{hatredratio=Hatredratio}.
get_hatredratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{hatredratio=Hatredratio} = RoleInfo,
	Hatredratio.

set_expratio_to_roleinfo(RoleInfo, ExpRate) ->
	RoleInfo#gm_role_info{expratio=ExpRate}.
get_expratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{expratio=ExpRate} = RoleInfo,
	ExpRate.
	
set_petexpratio_to_roleinfo(RoleInfo, ExpRate) ->
	RoleInfo#gm_role_info{petexpratio=ExpRate}.
get_petexpratio_from_roleinfo(RoleInfo) ->
	#gm_role_info{petexpratio=ExpRate} = RoleInfo,
	ExpRate.

set_lootflag_to_roleinfo(RoleInfo, Lootflag) ->
	RoleInfo#gm_role_info{lootflag=Lootflag}.
get_lootflag_from_roleinfo(RoleInfo) ->
	#gm_role_info{lootflag=Lootflag} = RoleInfo,
	Lootflag.

set_gateinfo_to_roleinfo(RoleInfo, GateInfo) ->
	RoleInfo#gm_role_info{gs_system_gate_info=GateInfo}.
get_gateinfo_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_gate_info=GateInfo} = RoleInfo,
	GateInfo.

set_mapinfo_to_roleinfo(RoleInfo, MapInfo) ->
	RoleInfo#gm_role_info{gs_system_map_info=MapInfo}.
get_mapinfo_from_roleinfo(RoleInfo) ->
	#gm_role_info{gs_system_map_info=MapInfo} = RoleInfo,
	MapInfo.

get_mana_from_roleinfo(RoleInfo) ->
	#gm_role_info{mana=Mana} = RoleInfo,
	Mana.
set_mana_to_roleinfo(RoleInfo, Mana) ->
	RoleInfo#gm_role_info{mana=Mana}.
	
get_exp_from_roleinfo(RoleInfo) ->
	#gm_role_info{exp=Exp} = RoleInfo,
	Exp.
set_exp_to_roleinfo(RoleInfo, Exp) ->
	RoleInfo#gm_role_info{exp=Exp}.

get_levelupexp_from_roleinfo(RoleInfo) ->
	#gm_role_info{levelupexp=Exp} = RoleInfo,
	Exp.
set_levelupexp_to_roleinfo(RoleInfo, Exp) ->
	RoleInfo#gm_role_info{levelupexp=Exp}.

get_agile_from_roleinfo(RoleInfo) ->
	#gm_role_info{agile=Agile} = RoleInfo,
	Agile.
set_agile_to_roleinfo(RoleInfo, Agile) ->
	RoleInfo#gm_role_info{agile=Agile}.

get_strength_from_roleinfo(RoleInfo) ->
	#gm_role_info{strength=Strength} = RoleInfo,
	Strength.
set_strength_to_roleinfo(RoleInfo, Strength) ->
	RoleInfo#gm_role_info{strength=Strength}.

get_intelligence_from_roleinfo(RoleInfo) ->
	#gm_role_info{intelligence=Intelligence} = RoleInfo,
	Intelligence.
set_intelligence_to_roleinfo(RoleInfo, Intelligence) ->
	RoleInfo#gm_role_info{intelligence=Intelligence}.
	
get_stamina_from_roleinfo(RoleInfo) ->
	#gm_role_info{stamina=Stamina} = RoleInfo,
	Stamina.
set_stamina_to_roleinfo(RoleInfo, Stamina) ->
	RoleInfo#gm_role_info{stamina=Stamina}.	
	
get_hpmax_from_roleinfo(RoleInfo) ->
	#gm_role_info{hpmax=Hpmax} = RoleInfo,
	Hpmax.
set_hpmax_to_roleinfo(RoleInfo, Hpmax) ->
	RoleInfo#gm_role_info{hpmax=Hpmax}.	
	
get_mpmax_from_roleinfo(RoleInfo) ->
	#gm_role_info{mpmax=Mpmax} = RoleInfo,
	Mpmax.
set_mpmax_to_roleinfo(RoleInfo, Mpmax) ->
	RoleInfo#gm_role_info{mpmax=Mpmax}.		

get_hprecover_from_roleinfo(RoleInfo) ->
	#gm_role_info{hprecover=Hprecover} = RoleInfo,
	Hprecover.
set_hprecover_to_roleinfo(RoleInfo, Hprecover) ->
	RoleInfo#gm_role_info{hprecover=Hprecover}.		
	
get_mprecover_from_roleinfo(RoleInfo) ->
	#gm_role_info{mprecover=Mprecover} = RoleInfo,
	Mprecover.
set_mprecover_to_roleinfo(RoleInfo, Mprecover) ->
	RoleInfo#gm_role_info{mprecover=Mprecover}.		
	
get_class_from_roleinfo(RoleInfo) ->
	#gm_role_info{class=Class} = RoleInfo,
	Class.
set_class_to_roleinfo(RoleInfo, Class) ->
	RoleInfo#gm_role_info{class=Class}.

get_power_from_roleinfo(RoleInfo) ->
	#gm_role_info{power=Attack} = RoleInfo,
	Attack.
set_power_to_roleinfo(RoleInfo, Attack) ->
	RoleInfo#gm_role_info{power=Attack}.

get_commoncool_from_roleinfo(RoleInfo) ->
	#gm_role_info{commoncool=Commoncool} = RoleInfo,
	Commoncool.
set_commoncool_to_roleinfo(RoleInfo, Commoncool) ->
	RoleInfo#gm_role_info{commoncool=Commoncool}.
	
get_immunes_from_roleinfo(RoleInfo) ->
	#gm_role_info{immunes=Immunes} = RoleInfo,
	Immunes.
set_immunes_to_roleinfo(RoleInfo, Immunes) ->
	RoleInfo#gm_role_info{immunes=Immunes}.
	
get_hitrate_from_roleinfo(RoleInfo) ->
	#gm_role_info{hitrate=Hitrate} = RoleInfo,
	Hitrate.
set_hitrate_to_roleinfo(RoleInfo, Hitrate) ->
	RoleInfo#gm_role_info{hitrate=Hitrate}.		
	
get_dodge_from_roleinfo(RoleInfo) ->
	#gm_role_info{dodge=Missrate} = RoleInfo,
	Missrate.
set_dodge_to_roleinfo(RoleInfo, Missrate) ->
	RoleInfo#gm_role_info{dodge=Missrate}.	
	
get_criticalrate_from_roleinfo(RoleInfo) ->
	#gm_role_info{criticalrate=Criticalrate} = RoleInfo,
	Criticalrate.
set_criticalrate_to_roleinfo(RoleInfo, Criticalrate) ->
	RoleInfo#gm_role_info{criticalrate=Criticalrate}.
	
get_criticaldamage_from_roleinfo(RoleInfo) ->
	#gm_role_info{criticaldamage=Criticaldamage} = RoleInfo,
	Criticaldamage.
set_criticaldamage_to_roleinfo(RoleInfo, Criticaldamage) ->
	RoleInfo#gm_role_info{criticaldamage=Criticaldamage}.	
	
get_toughness_from_roleinfo(RoleInfo) ->
	#gm_role_info{toughness=Toughness} = RoleInfo,
	Toughness.
set_toughness_to_roleinfo(RoleInfo, Toughness) ->
	RoleInfo#gm_role_info{toughness=Toughness}.
	
get_debuffimmunes_from_roleinfo(RoleInfo) ->
	#gm_role_info{debuffimmunes=Debuffimmune} = RoleInfo,
	Debuffimmune.
set_debuffimmunes_to_roleinfo(RoleInfo, Debuffimmune) ->
	RoleInfo#gm_role_info{debuffimmunes=Debuffimmune}.	
	
get_defenses_from_roleinfo(RoleInfo) ->
	#gm_role_info{defenses=Resistances} = RoleInfo,
	Resistances.
set_defenses_to_roleinfo(RoleInfo, Resistances) ->
	RoleInfo#gm_role_info{defenses=Resistances}.

add_extra_state_to_roleinfo(RoleInfo, State) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	%%RoleInfo#gm_role_info{extra_states=lists:delete(State,ExtraState) ++ [State]}.
	RoleInfo#gm_role_info{extra_states=ExtraState ++ [State]}.
get_extra_state_from_roleinfo(RoleInfo) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	ExtraState.
remove_extra_state_to_roleinfo(RoleInfo, State) ->
	#gm_role_info{extra_states=ExtraState} = RoleInfo,
	RoleInfo#gm_role_info{extra_states=lists:delete(State,ExtraState)}.

get_buffer_from_roleinfo(RoleInfo) ->
	#gm_role_info{buffer=Buffer} = RoleInfo,
	Buffer.
set_buffer_to_roleinfo(RoleInfo, Buffer) ->
	RoleInfo#gm_role_info{buffer=Buffer}.

get_guildname_from_roleinfo(RoleInfo) ->
	#gm_role_info{guildname=Guildname} = RoleInfo,
	Guildname.
set_guildname_to_roleinfo(RoleInfo, Guildname) ->
	RoleInfo#gm_role_info{guildname=Guildname}.	

get_guildposting_from_roleinfo(RoleInfo) ->
	#gm_role_info{guildposting=Guildposting} = RoleInfo,
	Guildposting.
set_guildposting_to_roleinfo(RoleInfo, Guildposting) ->
	RoleInfo#gm_role_info{guildposting=Guildposting}.		
	
get_cloth_from_roleinfo(RoleInfo) ->
	#gm_role_info{cloth=Cloth} = RoleInfo,
	Cloth.
set_cloth_to_roleinfo(RoleInfo,Cloth) ->
	RoleInfo#gm_role_info{cloth=Cloth}.	

get_arm_from_roleinfo(RoleInfo) ->
	#gm_role_info{arm=Arm} = RoleInfo,
	Arm.
set_arm_to_roleinfo(RoleInfo,ItemId) ->
	RoleInfo#gm_role_info{arm=ItemId}.	

get_pkmodel_from_roleinfo(RoleInfo) ->
	#gm_role_info{pkmodel=Pkmodel} = RoleInfo,
	Pkmodel.
set_pkmodel_to_roleinfo(RoleInfo,Pkmodel) ->
	RoleInfo#gm_role_info{pkmodel=Pkmodel}.	

get_crime_from_roleinfo(RoleInfo) ->
	#gm_role_info{crime=Crime} = RoleInfo,
	Crime.
set_crime_to_roleinfo(RoleInfo,Crime) ->
	RoleInfo#gm_role_info{crime=Crime}.	

get_ride_display_from_roleinfo(RoleInfo) ->
	#gm_role_info{ride_display=Ride_display} = RoleInfo,
	Ride_display.	
set_ride_display_to_roleinfo(RoleInfo,Ride_display) ->
	RoleInfo#gm_role_info{ride_display=Ride_display}.		

get_viptag_from_roleinfo(RoleInfo)->
	#gm_role_info{viptag=Viptag} = RoleInfo,
	Viptag.
set_viptag_to_roleinfo(RoleInfo,Viptag) ->
	RoleInfo#gm_role_info{viptag=Viptag}.	

get_companion_role_from_roleinfo(RoleInfo)->
	#gm_role_info{companion_role=Companion_role} = RoleInfo,
	Companion_role.
set_companion_role_to_roleinfo(RoleInfo,Companion_role) ->
	RoleInfo#gm_role_info{companion_role=Companion_role}.	
	
get_displayid_from_roleinfo(RoleInfo)->
	#gm_role_info{displayid=Displayid} = RoleInfo,
	Displayid.
set_displayid_to_roleinfo(RoleInfo,Displayid) ->
	RoleInfo#gm_role_info{displayid=Displayid}.	

get_serverid_from_roleinfo(RoleInfo)->
	#gm_role_info{serverid=ServerId} = RoleInfo,
	ServerId.
set_serverid_to_roleinfo(RoleInfo,ServerId) ->
	RoleInfo#gm_role_info{serverid=ServerId}.

get_group_id_from_roleinfo(RoleInfo)->
	#gm_role_info{group_id=Group_id} = RoleInfo,
	Group_id.
set_group_id_to_roleinfo(RoleInfo,Group_id) ->
	RoleInfo#gm_role_info{group_id=Group_id}.


get_treasure_transport_from_roleinfo(RoleInfo)->
	#gm_role_info{treasure_transport=Treasure_Transport} = RoleInfo,
	Treasure_Transport.
	
set_treasure_transport_to_roleinfo(RoleInfo,Treasure_Transport) ->
	RoleInfo#gm_role_info{treasure_transport=Treasure_Transport}.
	
	
		
get_cur_designation_from_roleinfo(RoleInfo)->
	#gm_role_info{cur_designation=CurDesignation} = RoleInfo,
	CurDesignation.
	
set_cur_designation_to_roleinfo(RoleInfo,CurDesignation) ->
	RoleInfo#gm_role_info{cur_designation=CurDesignation}.	
	
get_fighting_force_from_roleinfo(RoleInfo)->
	#gm_role_info{fighting_force=Fighting_force} = RoleInfo,
	Fighting_force.
	
set_fighting_force_to_roleinfo(RoleInfo,Fighting_force) ->
	RoleInfo#gm_role_info{fighting_force=Fighting_force}.
	
get_guildtype_from_roleinfo(RoleInfo)->
	#gm_role_info{guildtype=Value} = RoleInfo,
	Value.
	
set_guildtype_to_roleinfo(RoleInfo,Value) ->
	RoleInfo#gm_role_info{guildtype=Value}.
	
get_honor_from_roleinfo(RoleInfo)->
	#gm_role_info{honor=Value} = RoleInfo,
	Value.
	
set_honor_to_roleinfo(RoleInfo,Value) ->
	RoleInfo#gm_role_info{honor=Value}.
	
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				发送给在不同节点上的人物信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
-record(othernode_role_info,{id,proc,mapid,lineid,name,class,level,gender,life,hpmax,mana,mpmax,node,pos,icon,cloth,arm,buffer,fightforce}).

make_roleinfo_for_othernode(RoleInfo)->
	#othernode_role_info{id = get_id_from_roleinfo(RoleInfo),
						lineid = get_lineid_from_gs_system_mapinfo(get_mapinfo_from_roleinfo(RoleInfo)),
						proc = list_to_atom(integer_to_list(get_id_from_roleinfo(RoleInfo))),
						mapid = get_mapid_from_gs_system_mapinfo(get_mapinfo_from_roleinfo(RoleInfo)),
						name = get_name_from_roleinfo(RoleInfo),
						gender = get_gender_from_roleinfo(RoleInfo),
						class = get_class_from_roleinfo(RoleInfo),
						level = get_level_from_roleinfo(RoleInfo),
						pos = get_pos_from_roleinfo(RoleInfo),
						life = get_life_from_roleinfo(RoleInfo),
						hpmax = get_hpmax_from_roleinfo(RoleInfo),
						mana = get_mana_from_roleinfo(RoleInfo),
						mpmax = get_mpmax_from_roleinfo(RoleInfo),
						node = get_node_from_roleinfo(RoleInfo),
						icon = get_icon_from_roleinfo(RoleInfo),
						cloth =get_cloth_from_roleinfo(RoleInfo),
						arm =get_arm_from_roleinfo(RoleInfo),
						buffer = get_buffer_from_roleinfo(RoleInfo),
						fightforce = get_fighting_force_from_roleinfo(RoleInfo)
						}.
						
get_id_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{id=ID} = OutRangeRoleInfo,
	ID.

get_lineid_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{lineid=Lineid} = OutRangeRoleInfo,
	Lineid.

get_proc_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{proc=Proc} = OutRangeRoleInfo,
	Proc.

get_mapid_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mapid=Mapid} = OutRangeRoleInfo,
	Mapid.
	
get_fightforce_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{fightforce=FightForce} = OutRangeRoleInfo,
	FightForce.
		
get_gender_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{gender=Gender} = OutRangeRoleInfo,
	Gender.

get_icon_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{icon=Icon} = OutRangeRoleInfo,
	Icon.
	
get_name_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{name=Name} = OutRangeRoleInfo,
	Name.
	
get_class_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{class=Class} = OutRangeRoleInfo,
	Class.
	
get_level_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{level=Level} = OutRangeRoleInfo,
	Level.
	
get_pos_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{pos=Pos} = OutRangeRoleInfo,
	Pos.
	
get_life_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{life=Life} = OutRangeRoleInfo,
	Life.
	
get_hpmax_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{hpmax=Hpmax} = OutRangeRoleInfo,
	Hpmax.
	
get_mana_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mana=Mana} = OutRangeRoleInfo,
	Mana.
	
get_mpmax_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{mpmax=Mpmax} = OutRangeRoleInfo,
	Mpmax.
	
get_node_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{node=Node} = OutRangeRoleInfo,
	Node.	

get_cloth_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{cloth=Cloth} = OutRangeRoleInfo,
	Cloth.	

get_arm_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{arm=Arm} = OutRangeRoleInfo,
	Arm.					

get_buffer_from_othernode_roleinfo(OutRangeRoleInfo)->
	#othernode_role_info{buffer=Buffer} = OutRangeRoleInfo,
	Buffer.
