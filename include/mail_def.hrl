%%邮件

%% type: 1->sys | 2->normal
%% stastus: true->read | false-> unread
-record(mail,{mailid,from,toid,title,content,add_items,add_gold,add_silver,status,send_time,type}). 

