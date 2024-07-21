%%% -------------------------------------------------------------------
%%% 9ÃëÉçÍÅÈ«ÇòÊ×´Î¿ªÔ´·¢²¼
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : pb_util.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : æ“ä½œprotobufferç”Ÿæˆçš„recordçš„å‡½æ•°
%%% Created : 11 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(pb_util).

-include("login_pb.hrl").
-include("item_struct.hrl").
-include("item_define.hrl").
-compile(export_all).

make_role_info(RoleId, RoleName, LastMapId,Classtype,Gender,Level) ->
	#r{roleid=RoleId, name=RoleName, lastmapid=LastMapId,classtype = Classtype,gender = Gender,level = Level}.

get_role_id_from_logininfo(RoleInfo)->
	erlang:element(#r.roleid,RoleInfo).
get_role_map_from_logininfo(RoleInfo)->
	erlang:element(#r.lastmapid,RoleInfo).

convert_to_pos(Coord) when is_record(Coord, c) ->
	#c{x=X, y=Y} = Coord,
	{X, Y};
convert_to_pos(Coord) ->
	Coord.

convert_pos_to_coord(Pos) when is_record(Pos, c) ->
	Pos;
convert_pos_to_coord(Pos) ->
	{X, Y} = Pos,
	#c{x=X, y=Y}.     

key_value(Key, Value) ->
	#k{key=Key, value=Value}.	
	
to_skill_info(SkillID,SkillLevel,LastCastTime)->
	SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
	LeftTime = erlang:max(0, (skill_db:get_cooldown(SkillInfo) - trunc(timer:now_diff(timer_center:get_correct_now(),LastCastTime)/1000))),
	#s{skillid=SkillID, level=SkillLevel,lefttime = LeftTime}.

loot_slot_info(Itemprotoid,Count)->
	#l{itemprotoid = Itemprotoid,count = Count}.	

item_changed(Itemid_low,Itemid_high,Attrs,ExtEnchant)->
	#ic{itemid_low = Itemid_low,itemid_high = Itemid_high,attrs = Attrs,ext_enchant = ExtEnchant}.
	
to_item_info_by_playeritem(PlayerItemInfo)->
	ID = playeritems_db:get_id(PlayerItemInfo), 
	#i{
	   itemid_low = get_lowid_from_itemid(ID),
	   itemid_high = get_highid_from_itemid(ID),
	   protoid = playeritems_db:get_entry(PlayerItemInfo),
	   enchantments = playeritems_db:get_enchantments(PlayerItemInfo),
	   count = playeritems_db:get_count(PlayerItemInfo),
	   slot = playeritems_db:get_slot(PlayerItemInfo),
	   isbonded = playeritems_db:get_isbond(PlayerItemInfo),
	   socketsinfo = lists:map(fun({_Slot,Stone})->Stone end,playeritems_db:get_sockets(PlayerItemInfo)),
	   duration = playeritems_db:get_duration(PlayerItemInfo),
	   enchant = role_attr:to_item_attribute({enchant,playeritems_db:get_enchant(PlayerItemInfo)}),
	   lefttime_s = items_op:get_left_time_by_overdueinfo(playeritems_db:get_overdueinfo(PlayerItemInfo))
	   }.

to_aoi_group_role(Roleid,Leaderid,Leadername,Leaderlevel,Member_num )->
	#ag{roleid = Roleid,leaderid = Leaderid,leadername = Leadername,leaderlevel = Leaderlevel,member_num = Member_num}.

to_item_info([])->
	#i{
		itemid_low = 0,
		itemid_high = 0,
		protoid = 0,
		enchantments = 0,
		count = 0,
		slot = 0,
		isbonded = 0,
		socketsinfo = [],
		duration = 0,
		enchant = [],
		lefttime_s = ?ITEM_NONE_OVERDUE_LEFTTIME};

to_item_info(ItemInfo)->
	#i{
	   itemid_low = get_lowid_from_iteminfo(ItemInfo),
	   itemid_high = get_highid_from_iteminfo(ItemInfo),
	   protoid = get_template_id_from_iteminfo(ItemInfo),
	   enchantments = get_enchantments_from_iteminfo(ItemInfo),
	   count = get_count_from_iteminfo(ItemInfo),
	   slot = get_slot_from_iteminfo(ItemInfo),
	   isbonded = get_isbonded_from_iteminfo(ItemInfo),
	   socketsinfo = lists:map(fun({_Slot,Stone})->Stone end,get_socketsinfo_from_iteminfo(ItemInfo)),
	   duration = get_duration_from_iteminfo(ItemInfo),
	   enchant = role_attr:to_item_attribute({enchant,get_enchant_from_iteminfo(ItemInfo)}),
	   lefttime_s = items_op:get_left_time_by_overdueinfo(get_overdueinfo_from_iteminfo(ItemInfo))
	}.
					
to_teammate_state(Roleid, Level,Life, Maxhp, Mana, Maxmp, Posx, Posy, Mapid, LineId,Cloth,Arm)->
	#t{
					roleid = Roleid,
					level = Level,
					life = Life,
					maxhp = Maxhp,
					mana = Mana,
					maxmp = Maxmp,
					posx = Posx,
					posy = Posy,
					mapid = Mapid,
					lineid = LineId,
					cloth = Cloth,
					arm = Arm}.
					
to_group_member(Roleid,RoleName,Level,Class,Gender)->
	#m{roleid = Roleid, rolename = RoleName,level = Level,classtype = Class,gender= Gender}.	


to_role_recruite_info(RoleId,Name,Level,ClassId,Instance)->
	#rr{ id = RoleId,
		 name =Name,
		 level = Level,
		 classid = ClassId,
		 instance = Instance}.

to_recruite_info(Leader_id,Leader_line,Instance,Group_members,Description)->
	#ri{ leader_id = Leader_id,
					leader_line =Leader_line,
					instance = Instance,
					members = Group_members,
					description = Description}.
					
to_object_attribute(Id,Type,Attrs)->
	#o{
			objectid = Id,
			objecttype = Type,
			attrs = Attrs}.					
							