%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_quest
-module(guild_quest).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
quest_guild_check(MinGuildLevel,MaxGuildLevel)->
	GuildLevel = guild_util:get_guild_level(),
	((MinGuildLevel =< GuildLevel ) and (GuildLevel =< MaxGuildLevel)).

guild_publish_guild_quest()->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:publish_guild_quest(get(roleid),GuildId)
	end.

can_get_premiums()->
	case guild_util:get_guild_id() of
		0->
			false;
		GuildId->
			case guild_manager:can_get_premiums(GuildId) of
				true->
					true;
				_->
					false
			end
	end.

