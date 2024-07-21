-record(enchantments,{level,bonuses,consum,riseup,successrate,failure,protect,return,lucky,set_attr,add_attr,successsysbrd,faildsysbrd,faildsysbrdwithprotect}).
-record(sock,{punchnum,consume,money,rate}).    
-record(inlay,{level,type,stonelevel,remove}).
-record(stonemix,{stoneclass,rate,silver,gold,result}).
-record(remove_seal,{equipid,needitem,needitemcount,needmoney,resultid}).
-record(back_echantment_stone,{id,back_stone}).
-record(equipment_upgrade,{equipid,needitem,needitemcount,needmoney,resultid}).
-record(equipment_fenjie,{quality,needmoney,result,resultcount}).
-record(enchant_opt,{id,enchant,recast,recast_gold,enchant_gold,convert_gold,property_count}).
-record(enchant_property_opt,{id,property,priority,max_count,group,min_value,max_value,min_priority,max_priority,max_quality_range}).
-record(enchant_convert,{property,convert}).
-record(enchant_extremely_property_opt,{id,property,priority,max_count,group,min_value,max_value,min_priority,max_priority,max_quality_range}).
-record(enchantments_lucky,{id,rate}).
-record(equipment_move,{flevel,tlevel,needmoney,needitem}).

%%批量合成概率  by zhangting
-record(stonemix_rateinfo,{amount,rate}).



