%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(data_change).

-export([update_db_data/1,format_db_data/2]).

-include("giftcard_def.hrl").
-include("friend_struct_def.hrl").
-include("game_rank_def.hrl").
-include("mnesia_table_def.hrl").
-include("global_monster_loot_def.hrl").
-include("guild_def.hrl").
-include("guild_define.hrl").

%%
%%this function exec at db node 
%%
%%if you need ets data  create ets yourself
%%
%%function complate  and then  server will restart
%%

%%
%%delete table
%%		if proto table record change   delete it   when server restart  the table will create again
%%		if disc table don't need 		delete it
%%
%%change table struct
%%     if disc table struce change   process it yourself
%%

update_db_data(ver_11_12_15)->
	mnesia:delete_table(festival_recharge_info),
	mnesia:delete_table(festival_control),
	mnesia:delete_table(festival_control_background);
	

update_db_data(ver_11_12_8)->
	Tables = db_split:get_table_names(quest_role),
	QuestRoleTransform = fun(X)->							
								 try
								 case  element(#quest_role.quest_list,X) of
									 	{QuestList,Relation_msgs,Finished}->
											EverList = [];
							 			{QuestList,Relation_msgs,Finished,EverList}->
											nothing	
								end,
								NewQuestList = 
								lists:map(fun(QuestTmp)-> 
										case QuestTmp of
											{Questid,State,DetailStatus,ReceiveTime,LimitTime}->
												{Questid,State,DetailStatus,ReceiveTime,LimitTime,[]};
											{Questid,State,DetailStatus,ReceiveTime,LimitTime,Ext}->
												{Questid,State,DetailStatus,ReceiveTime,LimitTime,Ext}
										end
									end, QuestList),
								 erlang:setelement(#quest_role.quest_list, X, {NewQuestList,Relation_msgs,Finished,EverList})
								 catch
									 E:R->
										 io:format("E:R ~p ~p ~p ~p n",[E,R,erlang:get_stacktrace(),X]),
										 X
								end
						end,
	lists:foreach(fun(TableTmp)-> mnesia:transform_table(TableTmp, QuestRoleTransform, record_info(fields, quest_role)) end, Tables);

update_db_data(ver_11_12_1)->
	%%
	mnesia:delete_table(quests),
	mnesia:clear_table(guild_log),
	GuildMemberTransform = fun(X)->
							try
									OldPost = element(#guild_member.authgroup,X),
									case OldPost of
										1->
											NewPost = ?GUILD_POSE_LEADER;
										2->
											NewPost = ?GUILD_POSE_MASTER;
										_->
											NewPost = ?GUILD_POSE_MEMBER
									end,
									setelement(#guild_member.authgroup,X,NewPost)
							catch
								E:R->io:format("=====E ~p R ~p S ~p X ~p ~n",[E,R,erlang:get_stacktrace(),X]),
									 X
							end
						  end,
	mnesia:transform_table(guild_member, GuildMemberTransform, record_info(fields, guild_member));

update_db_data(ver_11_11_26)->
	%%delete table
	
	%%chenge table struct
	%%guild_baseinfo
	
	%% old %%-record(guild_baseinfo,{id,name,level,silver,gold,notice}).
	%% new -record(guild_baseinfo,{id,name,level,silver,gold,notice,createtime,chatgroup,voicegroup,lastactivetime,sendwarningmail,applyinfo,treasure_transport}).
	%%-record(guild_baseinfo_ver1,{name,level,silver,gold,notice,createtime,chatgroup,voicegroup,lastactivetime,sendwarningmail}).
	GuildBaseTransform = fun(X)->
							GuildId = element(2,X),		
							TempBaseInfo = element(3,X), %%old name
							case element(1,TempBaseInfo) of
								guild_baseinfo_ver1->
									Name = element(2,TempBaseInfo),
									Level = element(3,TempBaseInfo),
									Silver = element(4,TempBaseInfo),
									Gold = element(5,TempBaseInfo),
									Notice = element(6,TempBaseInfo),
									CreateTime = element(7,TempBaseInfo),
									ChatGroup = element(8,TempBaseInfo),
									VoiceGroup = element(9,TempBaseInfo),
									LastActiveTime = element(10,TempBaseInfo),
									SendWarningMail = element(11,TempBaseInfo),
			
									ApplyInfo = element(4,X), %% old silver
									case element(5,X) of
										{TimeX,TimeY,TimeZ}->
											TreasureTransport = {TimeX,TimeY,TimeZ};
										_->
											TreasureTransport = {0,0,0}
									end,
									#guild_baseinfo{
											id = GuildId,
										   	name = Name,
											level = Level,
											silver = Silver,
											gold = Gold,
											notice = Notice,
											createtime = CreateTime,
											chatgroup = ChatGroup,
											voicegroup = VoiceGroup,
											lastactivetime = LastActiveTime,
											sendwarningmail = SendWarningMail,
											applyinfo = ApplyInfo,
											treasure_transport = TreasureTransport
											};
								_->
									X
							end
						end,
	mnesia:transform_table(guild_baseinfo, GuildBaseTransform, record_info(fields, guild_baseinfo)),
	
	%%guild_member
	%%old -record(guild_member,{key_id_member,guildid,memberid,contribution,authgroup}). 
	%%new -record(guild_member,{key_id_member,guildid,memberid,contribution,authgroup,nickname,todaymoney,totalmoney}).
	%% -record(guild_member_ver1info,{contribution,authgroup,nickname}).
	GuildMemberTransform = fun(X)->
						try
							Key = element(2,X),
							GuildId = element(3,X),
							MemberId = element(4,X),
							TempMemberInfo = element(5,X),
							if
								is_integer(TempMemberInfo)->
									Contribution = TempMemberInfo,
									AuthGroup = element(6,X),				%%change auth  add
									NickName = [],
									TodayMoney ={{0,0,0},0},
									TotalMoney = 0,
											#guild_member{
													key_id_member = Key,
													guildid = GuildId,
													memberid = MemberId,
													contribution = Contribution,
													authgroup = AuthGroup,
													nickname = NickName,
													todaymoney = TodayMoney,
													totalmoney = TotalMoney
												};
								true->
									case element(1,TempMemberInfo) of
										guild_member_ver1info->
											Contribution = element(2,TempMemberInfo),
											AuthGroup = element(3,TempMemberInfo),				%%change auth  add
											NickName = element(4,TempMemberInfo),
											TodayMoney ={{0,0,0},0},
											TotalMoney = 0,
											#guild_member{
													key_id_member = Key,
													guildid = GuildId,
													memberid = MemberId,
													contribution = Contribution,
													authgroup = AuthGroup,
													nickname = NickName,
													todaymoney = TodayMoney,
													totalmoney = TotalMoney
												};
										_->
											X
									end	
							end
							catch
								E:R->io:format("=====E ~p R ~p S ~p X ~p ~n",[E,R,erlang:get_stacktrace(),X]),
									 X
							end
						  end,
	mnesia:transform_table(guild_member, GuildMemberTransform, record_info(fields, guild_member)),
	
	%%guild_leave_member
	%% old -record(guild_leave_member,{roleid,time}).
	%% new -record(guild_leave_member,{roleid,time,lastguildid,contribution}).
	GuildLeaveMember = fun(X)->
							#guild_leave_member{
											roleid = element(2,X),
											time = element(3,X),
											lastguildid = {0,0},
											contribution = 0
											}
						   end,
	mnesia:transform_table(guild_leave_member, GuildLeaveMember, record_info(fields, guild_leave_member)),
	
	todo;
			

update_db_data(ver_11_11_18)->
	%%delete table
	mnesia:delete_table(pet_up_stamina),
	mnesia:delete_table(pet_up_riseup),
	mnesia:delete_table(pet_up_reset),
	mnesia:delete_table(pet_up_abilities),
	mnesia:delete_table(everyday_show),%%delete everyday_show
	mnesia:delete_table(loudspeaker),%%delete loudspeaker
	mnesia:delete_table(global_monster_loot_db),
	TreasureChestTables = db_split:get_splitted_tables(treasure_chest_role),
	lists:foreach(fun(TableName)-> mnesia:delete_table(TableName) end,TreasureChestTables),
	
	%%chenge table struct
	GiftCardTransform = fun(X)->
							CardId = element(#giftcards.cardid,X),
							OldRoleId = element(#giftcards.roleid,X),
							if
								OldRoleId =:= []->
									NewX = setelement(#giftcards.roleid,X,CardId);
								true->
									NewX = X
							end,
							NewX
						end,
	mnesia:transform_table(giftcards, GiftCardTransform, record_info(fields, giftcards)),
	
	SignatureTransform = fun(X)->
							#signature{roleid = element(2,X),sign = element(4,X)}	 
						 end,
	mnesia:transform_table(signature, SignatureTransform, record_info(fields, signature)),				
	
	RankTransform = fun(X)->
							case element(#game_rank_db.type_roleid,X) of
								{12,_}->
									case element(#game_rank_db.rank_info,X) of
										{PetName,_RoleName,TalentScore}->
											NewX = setelement(#game_rank_db.rank_info,X,{PetName,TalentScore});
										_->
											NewX = X
									end;
								{{13,_},_}->
									case element(#game_rank_db.rank_info,X) of
										{Chapter,Festival,Difficulty,Level,UseTime,Score,_RoleName,RoleClass,ServerId}->
											NewX = setelement(#game_rank_db.rank_info,X,{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleClass,ServerId});
										_->
											NewX = X
									end;
								_->
									NewX = X
							end,
							NewX
					end,
	mnesia:transform_table(game_rank_db, RankTransform, record_info(fields, game_rank_db)),
	
	%%gm_role_privilege
  	RolePrivilegeTransform = fun(X)->
							#gm_role_privilege{roleid = element(2,X),privilege =  element(4,X)}
					end,
	mnesia:transform_table(gm_role_privilege, RolePrivilegeTransform, record_info(fields, gm_role_privilege)),
	ok;

update_db_data(What)->
	slogger:msg("~p update_db_data what ~p ~n",[?MODULE,What]),
	nothing.


format_db_data(FileName,FileOut)->
	case file:open(FileOut, [write,{encoding,utf8}]) of
		{ok,FOut}->
			case file:open(FileName, [read,{encoding,utf8}]) of
				{ok,FRead}->
					read_and_transwrite(FRead,FOut,0),	
					file:close(FRead),
					file:close(FOut);
				Error1->
					slogger:msg("open file[~p] error ~p ~n",[FileName,Error1])
			end;
		Error2->
			slogger:msg("open file[~p] error ~p ~n",[FileOut,Error2])
	end.

read_and_transwrite(Fd,Fout,Count)->
	case io:read(Fd,'') of
		{ok,Term}->
			case trans_term_11_17(Term) of
				false->
					nothing;
				{ok,NewTerm}->
					io:format(Fout,"~w.~n",[NewTerm])
			end,
			read_and_transwrite(Fd,Fout,Count+1);
		eof->
			slogger:msg("format_db_data end Count ~p ~n",[Count]);
		Error->
			slogger:msg("format_db_data read error ~p ~p ~n",[Error])
	end.

%%table [gm_role_privilege] attributes are different

%%table [global_monster_loot_db] attributes are different

%%return false / {ok,Term}			
trans_term_11_17(Term)->
	case Term of
		{everyday_show,_,_}->
			false;
		{loudspeaker,_,_}->
			false;
		{giftcards,Card,[]}->
			{ok,{giftcards,Card,Card}};
		{signature,RoleId,_Name,Sig}->
			{ok,{signature,RoleId,Sig}};
		{game_rank_db,{12,PetId},{PetName,_RoleName,TalentScore},Time}->
			{ok,{game_rank_db,{12,PetId},{PetName,TalentScore},Time}};
		{game_rank_db,{13,RoleId},{Chapter,Festival,Difficulty,Level,UseTime,Score,_RoleName,RoleClass,ServerId},Time}->
			{ok,{game_rank_db,{13,RoleId},{Chapter,Festival,Difficulty,Level,UseTime,Score,RoleClass,ServerId},Time}};
		{Table,_,_,_,_}->
			 case string:str(atom_to_list(Table), "treasure_chest_role") of
				1-> false;
				_->
					{ok,Term}
			 end;
		_->
			{ok,Term}
	end.


