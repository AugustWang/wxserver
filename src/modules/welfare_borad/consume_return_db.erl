%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(consume_return_db).


-include("active_board_def.hrl").



-export([read_consume_gold_from_db/1,write_consume_gold_to_db/2]).
  
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(consume_return_info,record_info(fields,consume_return_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{consume_return_info,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(consume_return_info, RoleId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
read_consume_gold_from_db(RoleId)->
	case dal:read_rpc(consume_return_info, RoleId) of
		{ok,[{_,_,ConsumeGold}]}->
			ConsumeGold;
		_->
			[]
	end.

write_consume_gold_to_db(RoleId,ConsumeGold)->
	Object = #consume_return_info{roleid = RoleId,consume_gold = ConsumeGold},
	dal:write_rpc(Object).	
	