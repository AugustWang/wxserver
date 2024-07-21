%%经脉配置
-record(venation_proto,{id,point_num,attr_addition}).

%%经脉穴位
-record(venation_point_proto,{id,venation,parent_point,attr_addition,soulpower,money,active_rate,needlevel}).

%%经脉穴位
%%-record(venation_point_proto,{id,venation,parent_point,attr_addition,soulpower,money,active_rate}).

%%经脉信息记录
-record(role_venation,{roleid,active_point,share_exp,ext}).

-record(share_exp,{total_share_exp,remain_share_time,last_time}).

%%经脉道具加� ��
-record(venation_item_rate,{num,rate}).

%%冲穴经验奖励
-record(venation_exp_proto,{level,exp,shareexp}).

%%人物经脉领悟精通信息
%%venation_info = {venationid,venation_bone}
-record(role_venation_advanced,{roleid,venation_info}). 

%%经脉领悟精通信息
-record(venation_advanced,{venationinfo,effect,success_rate,need_money,need_gold,useitem,protect_item}).  