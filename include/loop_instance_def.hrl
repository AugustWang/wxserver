%% Author: zhanglei
%% Created: 2012-1-6

-record(loop_instance_proto,{layer,exp,money,bonus,soulpower,instance_proto,type,monsters,time,targetnpclist,bornpos}). %% proto
-record(loop_instance,{id,times,members,levellimit}). %% proto

-record(role_loop_instance,{roleid,record}). %%disc

-record(loop_instance_record,{layer,besttime}).
