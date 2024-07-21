
%%%%%%%%%%%%%%%%%%%%%%%proto%%%%%%%%%%%%%%%%%%%%%%%

-record(guild_authorities,{id,name,disabled=0}).
-record(guild_auth_groups,{id,level,name,authids}). %% bag
-record(guild_facilities,{id,level,name,rate,check_script,require_resource,require_time}). %% bag
-record(guild_shop,{level,itemslist,preview_itemslist}).
-record(guild_shop_items,{id,itemid,showindex,guild_contribution,base_price,discount,minlevel,limitnum,itemtype}).
-record(guild_setting,{id,value}).
-record(guild_treasure,{level,itemslist}).
-record(guild_treasure_items,{id,itemid,showindex,guild_contribution,base_price,minlevel,limitnum,itemtype}).
-record(guild_monster_proto,{monsterid,needlevel,upgrademoney,callmoney,bornpos}).

%%%%%%%%%%%%%%%%%%%%%%%disc%%%%%%%%%%%%%%%%%%%%%%%

-record(guild_baseinfo,{id,name,level,silver,gold,notice,createtime,chatgroup,voicegroup,lastactivetime,sendwarningmail,applyinfo,treasure_transport,package}).
-record(guild_member,{key_id_member,guildid,memberid,contribution,tcontribution,authgroup,nickname,todaymoney,totalmoney}). %% memberid
-record(guild_log,{key_guild_time,guildid,memberid,logtype,description,time}).%%bag 
-record(guild_events,{key_guild_time,guildid,description,time}). %%bag
-record(guild_monster,{guildid,monster,lefttimes,time,lastcalltime,activmonster}).
-record(guild_battle_score,{guildid,gbscore,totlescore,wininfo}).
%%%% upgradestatus:starttime 0 ->not in upgrade
-record(guild_facility_info,{key_id_fac,guildid,facilityid,level,upgradestatus,upgrade_finished_time,required,contribution}).
-record(guild_leave_member,{roleid,time,lastguildid,contribution,tcontribution}).
-record(guild_member_shop,{key_id_member,guildid,memberid,count,time,ext}). 
-record(guild_member_treasure,{key_id_member,guildid,memberid,count,time,ext}).
-record(guild_treasure_price,{key_guild_id,guildid,price,ext}).
-record(guild_quest_info,{guildid,starttime,ext}).
-record(guild_impeach_info,{guildid,roleid,notice,support,opposite,starttime,voteids}).
-record(guild_right_limit,{guildid,smith,battle}).
%%帮会仓库<存储物品的所有信息>
-record(guilditems,{id,ownerguid,entry,enchantments,count,slot,bound,sockets,duration,cooldowninfo,enchant,overdueinfo,state}).
-record(guildpackage_apply,{guildid,roleid,itemid,count,datetime}).
