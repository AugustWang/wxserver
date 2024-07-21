%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-2-11
%% Description: TODO: Add description to quest_join_guild
-module(quest_join_guild).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([com_script/1]).

%%
%% API Functions
%%
com_script(QuestId)->
	QuestInfo = quest_db:get_info(QuestId),
	case lists:keyfind(join_guild,1,quest_db:get_objectivemsg(QuestInfo)) of
		{_,Op,ObjValue}->
			GuildId = guild_util:get_guild_id(),
			State = quest_op:get_quest_states_by_op(Op,ObjValue,GuildId,0),
			[{join_guild,State}];
		_->
			slogger:msg("error com_script QuestId ~p not a join_guild quest ~n",[QuestId]),
			[{join_guild,0}]
	end.


%%
%% Local Functions
%%

