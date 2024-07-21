%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(quest_is_has_items).
-include("error_msg.hrl").
-export([acc_script/2]).

acc_script(_Quest,ItemTempltes)->
	IsHaveItem = lists:map(fun({TempList,Count})->
								 Result = [item_util:is_has_enough_items_onhands([{Id,Count}])||Id <- TempList],
								 lists:member(true,Result)
							end,ItemTempltes),
	case lists:member(false,IsHaveItem) of
		true->
			{false,?ERROR_MISS_ITEM};
		_->
			true	
	end.
