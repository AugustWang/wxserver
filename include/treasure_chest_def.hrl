%%宝箱物品抽中概率表
-record(treasure_chest_rate,{proto_count,rate_base}).
-record(treasure_chest_drop,{proto_level1_level2_class,drops}).
-record(treasure_chest_type,{type,protoid_list}).				%%天珠类型，对应的模板Id[绑定模板Id,非绑定模板Id]
-record(treasure_chest_times,{times,consume_gold_list}).		%%祈福次数，[对应天珠类型消耗的元宝数]	
-record(role_treasure_storage,{roleid,itemlist,max_item_id,ext}).	%%角色  物品模板id