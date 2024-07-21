%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_db).
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files 
%%
-include("auction_def.hrl").
%%
%% API Functions
%%
-define(MNESIA_AUCTION_TABLE,auction).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(auction,record_info(fields,auction),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{auction,disc}].

delete_role_from_db(RoleId)->
	lists:foreach(fun(StallInfo)->
					case auction_db:get_roleinfo(StallInfo) of
						{RoleId,_,_}->
							dal:delete_object_rpc(StallInfo);
						_->
							nothing
					end
	end,get_auction_info()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_auction_info()->
	case dal:read_rpc(?MNESIA_AUCTION_TABLE) of
		{ok,AuctionInfo}->AuctionInfo;
		_->[]
	end.

%%{id,roleinfo,nickname,items,create_time,ext}
%%items:{ItemId,Money} Moneys:{Silver,Gold,Ticket}

save_stall_info(Id,RoleInfo,NickName,Items,Stallmoney,Time,Logs)->
	dal:write_rpc({?MNESIA_AUCTION_TABLE,Id,RoleInfo,NickName,Items,Stallmoney,Time,Logs}).

del_stall(Id)->	
	dal:delete_rpc(?MNESIA_AUCTION_TABLE,Id).

get_id(StallInfo)->
	erlang:element(#auction.id, StallInfo).

get_roleinfo(StallInfo)->
	erlang:element(#auction.roleinfo, StallInfo).

get_nickname(StallInfo)->
	erlang:element(#auction.nickname, StallInfo).

get_items(StallInfo)->
	erlang:element(#auction.items, StallInfo).

get_stallmoney(StallInfo)->
	erlang:element(#auction.stallmoney, StallInfo).


get_create_time(StallInfo)->
	erlang:element(#auction.create_time, StallInfo).

get_ext(StallInfo)->
	erlang:element(#auction.ext, StallInfo).
	