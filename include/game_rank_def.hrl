-record(game_rank_db,{type_roleid,rank_info,record_time}).

%%baseinfo:{RoleName,RoleClass,RoleGender,RoleServerId}
-record(rank_role_db,{roleid,baseinfo,equipments,guild_name,level,viptag,disdain_num,praised_num}).

-record(role_judge_left_num,{roleid,info}).

-record(role_judge_num,{roleid,disdain_num,praised_num}).
