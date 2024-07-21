%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_util).

-compile(export_all).

-include("data_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("guild_define.hrl").
-include("item_define.hrl").

get_guild_id()->
	get_by_item(id).

get_guild_name()->
	get_by_item(name).
	
get_guild_level()->
	get_by_item(level).	

get_guild_posting()->
	get_by_item(posting).

get_guild_contribution()->
	get_by_item(contribution).	

get_guild_tcontribution()->
	get_by_item(totlecontribution).	
	
get_guild_facility()->
	get_by_item(facility).
		
get_guild_members()->
	get_by_item(members).	
	
get_guild_facility_info(TypeId)->
	Facility_list = get_guild_facility(),
	case lists:keyfind(TypeId,1,Facility_list) of
		false->
			[];
		FaclityInfo->
			FaclityInfo
	end.
	
get_guild_facility_level(TypeId)->
	Facility_list = get_guild_facility(),
	case lists:keyfind(TypeId,1,Facility_list) of
		{TypeId,Level,_,_,_,_}->
			Level;
		_->
			[]
	end.

get_guild_smith_addation()->
	SmithLevel = get_guild_facility_level(?GUILD_FACILITY_SMITH), 
	case (SmithLevel =:= []) or (get_guild_posting() =:= ?GUILD_POSE_PREMEMBER) of
		true-> 
			0;
		_->	
			ProtoInfo = guild_proto_db:get_facility_info(?GUILD_FACILITY_SMITH,SmithLevel),	
			lists:nth(?GUILD_ADDITION_SMITH_RATE,guild_proto_db:get_facility_rate(ProtoInfo))
	end.

get_recruite_info()->
	guild_manager:get_recruite_info(get(roleid)).

get_guild_log(Type)->
	case get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:get_guild_log(get(roleid),GuildId,Type)
	end.	
	
get_members_pos()->
	case get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:get_members_pos(get(roleid),GuildId)
	end.	
	
get_by_item(Item)->		
	{Id,Name,Level,MyPosting,Contribution,TContribution,Facilitys,MemberIdList} = get(guild_info),
	case Item of
		id->
			Id;
		name->
			Name;
		level->
			Level;
		facility->
			Facilitys;
		posting->
			MyPosting;
		contribution->
			Contribution;
		totlecontribution->
			TContribution;
		members->
			MemberIdList
	end.
	
set_guild_name(Name)->
	set_by_item(name,Name).

set_guild_level(Level)->
	set_by_item(level,Level).	

set_guild_posting(Posting)->
	set_by_item(posting,Posting).	
	
set_guild_contribution(Contribution)->
	set_by_item(contribution,Contribution).

set_guild_tcontribution(Contribution)->
	set_by_item(totlecontribution,Contribution).	


set_guild_facility(Facility)->
	set_by_item(facility,Facility).	
	
set_guild_facility_info(Typeid,NewFaInfo)->
	Facility_list = get_guild_facility(),
	case lists:keyfind(Typeid,1,Facility_list ) of
		false->
			slogger:msg("set_guild_facility_info find Facility error:~p~n",[Typeid]);
		_->						
			set_guild_facility(lists:keyreplace(Typeid,1,Facility_list,NewFaInfo)),
				if									
					Typeid =:= ?GUILD_FACILITY->	%%甯細绛夌骇鍙樺寲	
						NewGuildLevel = get_guild_facility_level(Typeid),
%% 						achieve_op:achieve_update({guild_level},[0],NewGuildLevel),				
						set_guild_level(NewGuildLevel);
					true->
						nothing
				end
	end.	

set_by_item(Item,Value)->
	{Id,Name,Level,MyPosting,Contribution,TContribution,Facilitys,MemberIdList} = get(guild_info),
	case Item of
		id->
			put(guild_info,{Value,Name,Level,MyPosting,Contribution,TContribution,Facilitys,MemberIdList});
		name->
			put(guild_info,{Id,Value,Level,MyPosting,Contribution,TContribution,Facilitys,MemberIdList});
		level->
			put(guild_info,{Id,Name,Value,MyPosting,Contribution,TContribution,Facilitys,MemberIdList});
		facility->
			put(guild_info,{Id,Name,Level,MyPosting,Contribution,TContribution,Value,MemberIdList});
		posting->
			put(guild_info,{Id,Name,Level,Value,Contribution,TContribution,Facilitys,MemberIdList});
		contribution->
			put(guild_info,{Id,Name,Level,MyPosting,Value,TContribution,Facilitys,MemberIdList});
		totlecontribution->
			put(guild_info,{Id,Name,Level,MyPosting,Contribution,Value,Facilitys,MemberIdList});
		members->
			put(guild_info,{Id,Name,Level,MyPosting,Contribution,TContribution,Facilitys,Value})
	end.
	
is_have_guild()->
	get_guild_id() =/= 0.
	
is_full()->
	case is_have_guild() of
		true->
			GuildLevel = get_guild_level(),		
			ProtoInfo = guild_proto_db:get_facility_info(?GUILD_FACILITY,GuildLevel),
			MaxNum = lists:nth(?GUILD_ADDITION_MAX_MEMBERNUM,guild_proto_db:get_facility_rate(ProtoInfo)),
			MaxNum =< erlang:length(get_guild_members());
		false->
			false
	end.	
	
is_have_right(Right)->
	case guild_proto_db:get_authgroup_info(get_guild_posting()) of
		[]->
			false;
		RightInfo->
			RightLists = guild_proto_db:get_authgroup_authids(RightInfo),
			lists:member(Right,RightLists)
	end.	
	
is_same_guild(RoleId)->
	lists:member(RoleId,get_guild_members()).
	
post_level(Post)->
	case Post of
		?GUILD_POSE_LEADER->								
			5;
		?GUILD_POSE_VICE_LEADER->							
			4;
		?GUILD_POSE_MASTER->							
			3;
		?GUILD_POSE_MEMBER->							
			2;
		?GUILD_POSE_PREMEMBER->								
			1;
		_->
			0
	end.
		
post_diff(PostA,PostB)->
	post_level(PostA) - post_level(PostB).
	
pre_post(Post)->
	case Post of
		?GUILD_POSE_LEADER->								
			0;
		?GUILD_POSE_VICE_LEADER->							
			?GUILD_POSE_LEADER;
		?GUILD_POSE_MASTER->								
			?GUILD_POSE_VICE_LEADER;
		?GUILD_POSE_MEMBER->								
			?GUILD_POSE_MASTER;
		?GUILD_POSE_PREMEMBER->								
			?GUILD_POSE_MEMBER;
		_->
			0
	end.
	
next_post(Post)->
	case Post of
		?GUILD_POSE_LEADER->								
			?GUILD_POSE_VICE_LEADER;
		?GUILD_POSE_VICE_LEADER->							
			?GUILD_POSE_MASTER;
		?GUILD_POSE_MASTER->							
			?GUILD_POSE_MEMBER;
		?GUILD_POSE_MEMBER->							
			0;
		?GUILD_POSE_PREMEMBER->								  
			0;
		_->
			0
	end.

run_check({level,Level})->
	case get_level_from_roleinfo(get(creature_info))>= Level of
		true->
			true;
		false->
			{error,level}
	end.
