%%consume:消耗的物品包括钱级物品，rateinfo：概率和改概率下的物品
-record(item_identify,{item_class,consume,rateinfo}).

%%坐骑合成
-record(ridepet_synthesis,{quality,consume,rateinfo}).

-record(ride_proto_db,{item_template_id,add_buff,drop_rate}). 

%%坐骑属性表
-record(attr_info,{quality,dropnum,attrrate_list}).





