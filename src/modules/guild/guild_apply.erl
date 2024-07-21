%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_apply
-module(guild_apply).

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
apply_guild(GuildId)->
	put(guild_apply,true),
	guild_manager:apply_guild(get(roleid),GuildId).

insert_to_inviter(InviterId,GuildId)->
	case has_been_inveited_by(InviterId) of
		false->
			put(guild_invite,[{InviterId,GuildId}] ++ get(guild_invite));
		_->
			nothing
	end.

get_inviter_guild(Inviterid)->
	{Inviterid,GuildId} = lists:keyfind(Inviterid,1,get(guild_invite)),
	GuildId.

remove_from_inviter(InviterId)->
	put(guild_invite,lists:keydelete(InviterId,1,get(guild_invite))).	
	
has_been_inveited_by(InviterId)->
	lists:keymember(InviterId,1,get(guild_invite)).

get_application()->
	case guild_util:get_guild_id() of
		0->
			[];
		GuildId->
			 guild_manager:get_applicationinfo(get(roleid),GuildId)
	end.

application_op(RoleId,Reject)->
	case guild_util:get_guild_id() of
		0->
			[];
		GuildId->
			 guild_manager:application_op(RoleId,get(roleid),GuildId,Reject)
	end.
	


%%
%% Local Functions
%%

