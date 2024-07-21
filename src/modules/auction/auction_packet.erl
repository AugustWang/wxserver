%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%
-export([handle/2]).

-export([encode_stall_detail_s2c/6,
		 encode_stalls_search_s2c/3,
		 encode_stall_log_add_s2c/2,
		 encode_stall_opt_result_s2c/1,
		 encode_stalls_search_item_s2c/3,
		 make_stall_item/4,
		 make_serch_item_info/9,
		 make_stall_base_info/6]).

-compile(export_all).

%%
%% API Functions
%%

handle(Message=#stall_sell_item_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#paimai_sell_c2s{}, RolePid)->%%2月19日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_detail_c2s{}, RolePid)->%%2月22日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_recede_c2s{}, RolePid)->%%2月25日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_search_by_sort_c2s{}, RolePid)->%%3月4日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_search_by_string_c2s{}, RolePid)->%%3月6日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_search_by_grade_c2s{}, RolePid)->%%3月7日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#paimai_buy_c2s{}, RolePid)->%%3月7日加【xiaowu】
	RolePid!{auction_packet,Message};

handle(Message=#stall_recede_item_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stalls_search_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stalls_search_item_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stall_detail_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stall_buy_item_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stall_rename_c2s{}, RolePid)->
	RolePid!{auction_packet,Message};

handle(Message=#stall_role_detail_c2s{}, RolePid)->
	RolePid!{auction_packet,Message}.

make_stall_item(Item,Silver,Gold,Ticket)->
	#si{item = Item,money = Silver,gold = Gold,silver = Ticket}.

make_paimai_item_siv(Item,Silver,Gold,Type,Indexid)->%%2月22日加【xiaowu】
	#siv{gold=Gold, item=Item, type=Type, silver=Silver, indexid=Indexid}.

make_paimai_item_sm(Value,Silver,Gold,Type,Indexid)->%%2月22日加【xiaowu】
	#sm{gold=Gold, value=Value, type=Type, silver=Silver, indexid=Indexid}.

make_stall_base_info(Id,Name,Ownerid,Ownername,Ownerlevel,Itemnum)->
	#a{id = Id,name = Name,ownerid = Ownerid,ownername = Ownername,ownerlevel = Ownerlevel,itemnum = Itemnum}.

make_serch_item_info(Item,Silver,Gold,Ticket,Stallid,Ownerid,Ownername,Itemnum,IsOnline)->
	#ssi{item = make_stall_item(Item,Silver,Gold,Ticket),stallid = Stallid,ownerid = Ownerid,ownername = Ownername,itemnum = Itemnum,isonline = IsOnline}.

encode_stalls_search_s2c(Index,TotalNum,Stalls)->
	login_pb:encode_stalls_search_s2c(#stalls_search_s2c{index = Index,totalnum = TotalNum,stalls = Stalls}).  

encode_paimai_search_item_s2c(Totalnum,Index,Searchitems,Searchmoney)->
	login_pb:encode_paimai_search_item_s2c(#paimai_search_item_s2c{totalnum=Totalnum, index=Index, searchitems=Searchitems, searchmoney=Searchmoney}). 

make_paimai_item_ssiv(Itemnum,Ownerid,Item,Stallid,Isonline,Ownername)->
	#ssiv{itemnum=Itemnum, ownerid=Ownerid, item=Item, stallid=Stallid, isonline=Isonline, ownername=Ownername}.

make_paimai_item_ssm(Money,Ownerid,Itemnum,Stallid,Isonline,Ownername)->
	#ssm{money=Money, ownerid=Ownerid, itemnum=Itemnum, stallid=Stallid, isonline=Isonline, ownername=Ownername}.

encode_stall_detail_s2c(Ownerid,Stallid,Stallname,Stallitems,Logs,Isonline)->
	login_pb:encode_stall_detail_s2c(#stall_detail_s2c{ownerid= Ownerid,stallid=Stallid,stallname=Stallname,stallitems=Stallitems,logs=Logs,isonline=Isonline}).

encode_paimai_detail_s2c(Ownerid,Stallid,Stallname,Stallitems,Logs,Isonline,Stallmoney)->%%2月22日加【xiaowu】
	login_pb:encode_paimai_detail_s2c(#paimai_detail_s2c{stallitems=Stallitems, isonline=Isonline, stallname=Stallname, ownerid=Ownerid, stallmoney=Stallmoney, stallid=Stallid, logs=Logs}).

encode_stalls_search_item_s2c(Index,TotalNum,StallItems)->
	login_pb:encode_stalls_search_item_s2c(#stalls_search_item_s2c{index = Index,totalnum = TotalNum,serchitems = StallItems}).

encode_stall_log_add_s2c(Stallid,Logs) ->
	login_pb:encode_stall_log_add_s2c(#stall_log_add_s2c{stallid = Stallid,logs = Logs}).

encode_stall_opt_result_s2c(Errno)->
	login_pb:encode_stall_opt_result_s2c(#stall_opt_result_s2c{errno = Errno}).

encode_paimai_opt_result_s2c(Errno)->
	login_pb:encode_paimai_opt_result_s2c(#paimai_opt_result_s2c{errno = Errno}).	

build_stallmoney_by_fullifo(Gold,Value,Type,Silver,Indexid)->
	#sm{gold=Gold, value=Value, type=Type, silver=Silver, indexid=Indexid}.				
