%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(auction_stall_id_gen).
%%
%% Include files
%%
-define(MIN_STALL_ID,1000000).
-define(MAX_STALL_NUM,999999).
-compile(export_all).

init()->
	ServerId = env:get(serverid, undefined),
	put(stall_id_index,ServerId*?MIN_STALL_ID),
	put(stall_id_max,ServerId*?MIN_STALL_ID+?MAX_STALL_NUM),
	put(stall_id_cur,ServerId*?MIN_STALL_ID),
	put(stall_using_ids,[]).

load_by_db(StallId)->
	case StallId>get(stall_id_cur)of
		true->
			put(stall_id_cur,StallId);
		_->
			nothing
	end,
	put(stall_using_ids,[StallId|get(stall_using_ids)]).

gen_id()->
	case get(stall_id_cur) >= get(stall_id_max) of
		true->
			put(stall_id_cur,get(stall_id_index)),
			gen_id();
		_->
			NewId = get(stall_id_cur)+1,
			case lists:member(NewId, get(stall_using_ids)) of
				false->
					put(stall_id_cur,NewId),
					put(stall_using_ids,[NewId|get(stall_using_ids)]),
					NewId;
				_->			%%repeated
					case length(get(stall_using_ids))>= ?MAX_STALL_NUM of
						true->					%%no num can use
							[];
						_->
							put(stall_id_cur,NewId),
							gen_id()
					end
			end
	end.		

recycle_id(StallId)->
	put(stall_id_cur,lists:delete(StallId, get(stall_using_ids))).
