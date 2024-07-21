%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-11
%% Description: TODO: Add description to gm_logger_role
-module(gm_logger_role).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("mnesia_table_def.hrl").
-include("welfare_activity_define.hrl").
%%
%% API Functions
%%

%% @doc by xiaodya
%% invoke write/1( KeyValueList::string() ) This is default function
%% invoke write/2(KeyValueList::string(),Type::atom()) has a special param
%% buffer|directly|merge|nodb These are atom()
%% write/1 == write/2 Type=buffer

role_vip(RoleId,Type,RoleLevel)->
	LineKeyValue = [{"cmd","role_vip"},
					{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel}		
		 ],
	Log = [{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel}		
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_vip, Log),
	gm_msgwrite:write(role_vip,LineKeyValue).

role_exchange_item(RoleId,Level,ItemId,ItemCount,ConsumeItem,ConsumeCount)->
	LineKeyValue = [{"cmd","role_exchange_item"},
					{"roleid",RoleId},
					{"level",Level},
					{"itemid",ItemId},
					{"itemcount",ItemCount},
					{"consumeitem",ConsumeItem},
					{"consumecount",ConsumeCount}
		 ],
	Log = [{"roleid",RoleId},
					{"level",Level},
					{"itemid",ItemId},
					{"itemcount",ItemCount},
					{"consumeitem",ConsumeItem},
					{"consumecount",ConsumeCount}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_exchange_item, Log),
	gm_msgwrite:write(role_exchange_item,LineKeyValue).

role_offline_exp(RoleId,Level,Hours,Exp,Multi)->
	LineKeyValue = [{"cmd","role_offline_exp"},
					{"roleid",RoleId},
					{"level",Level},
					{"hours",Hours},
					{"exp",Exp},
					{"multi",Multi}
		 ],
	Log = [{"roleid",RoleId},
					{"level",Level},
					{"hours",Hours},
					{"exp",Exp},
					{"multi",Multi}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_offline_exp, Log),
	gm_msgwrite:write(role_offline_exp,LineKeyValue).

role_offline_everquest(RoleId,EverQuestId,Level,Multi)->
	LineKeyValue = [{"cmd","role_offline_everquest"},
					{"roleid",RoleId},
					{"everquestid",EverQuestId},
					{"level",Level},
					{"multi",Multi}
		 ],
	Log = [{"roleid",RoleId},
					{"everquestid",EverQuestId},
					{"level",Level},
					{"multi",Multi}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_offline_everquest, Log),
	gm_msgwrite:write2(role_offline_everquest,LineKeyValue,nodb).

role_venation(RoleId,Venation,Point,Opt,RoleLevel)->		
	LineKeyValue = [{"cmd","role_venation"},
					{"roleid",RoleId},
					{"venation",Venation},
					{"point",Point},
					{"opt",Opt},
					{"rolelevel",RoleLevel}],
	Log = [{"roleid",RoleId},
					{"venation",Venation},
					{"point",Point},
					{"opt",Opt},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_venation, Log),
	gm_msgwrite:write(role_venation,LineKeyValue).

role_venation_advanced(RoleId,Venation,Bone,Opt,UseItem,ConsumeItem,Money)->
	LineKeyValue = [{"cmd","role_venation_advanced"},
					{"roleid",RoleId},
					{"venation",Venation},
					{"point",Bone},
					{"opt",Opt},
					{"useitem",UseItem},
					{"consumeitem",ConsumeItem},
					{"money",Money}
		 ],
	Log = [{"roleid",RoleId},
					{"venation",Venation},
					{"point",Bone},
					{"opt",Opt},
					{"useitem",UseItem},
					{"consumeitem",ConsumeItem},
					{"money",Money}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_venation_advanced, Log),
	gm_msgwrite:write(role_venation_advanced,LineKeyValue).

role_soulpower(RoleId,Consume,Remain,RoleLevel)->	
	LineKeyValue = [{"cmd","role_soulpower"},
					{"roleid",RoleId},
					{"consume",Consume},
					{"remain",Remain},
					{"rolelevel",RoleLevel}   
		 ],
	Log = [{"roleid",RoleId},
					{"consume",Consume},
					{"remain",Remain},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_soulpower, Log),
	gm_msgwrite:write(role_soulpower,LineKeyValue).

pet_level_up(RoleId,PetId,PetProtoId,RoleLevel,PetLevel)->
	LineKeyValue = [{"cmd","pet_level_up"}, 
					{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
					{"rolelevel",RoleLevel},
					{"petlevel",PetLevel}
		 ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
					{"rolelevel",RoleLevel},
					{"petlevel",PetLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_level_up, Log),
	gm_msgwrite:write(pet_level_up,LineKeyValue).

pet_advance(RoleId,PetId,PetProtoId,StepOld,StepNew)->
	LineKeyValue = [{"cmd","pet_advance"}, 
					{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
					{"petoldstep",StepOld},
					{"petnewstep",StepNew}
		 ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
				{"petoldstep",StepOld},
					{"petnewstep",StepNew}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_advance, Log),
	gm_msgwrite:write(pet_advance,LineKeyValue).

pet_inherit(RoleId,PetId,PetProtoId,NewPetInfo,Pid)->
	LineKeyValue = [{"cmd","pet_inherit"}, %%@@wb20130327 pet_advance
					{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
					{"mainpinfo",NewPetInfo},
					{"spid",Pid}
		 ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
				{"mainpinfo",NewPetInfo},
					{"spid",Pid}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_advance, Log),
	gm_msgwrite:write(pet_inherit,LineKeyValue).

pet_change(RoleId,FromPet,FromPetId,ToPet,ToPetId)->	
	LineKeyValue = [{"cmd","pet_change"},
					{"roleid",RoleId},
					{"frompetidid",FromPetId},
					{"from_pet",FromPet},
					{"to_pet",ToPet},
					{"to_petid",ToPetId}
		 ],
	Log = [{"roleid",RoleId},
					{"frompetidid",FromPetId},
					{"from_pet",FromPet},
					{"to_pet",ToPet},
					{"to_petid",ToPetId}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_change, Log),
	gm_msgwrite:write(pet_change,LineKeyValue).


pet_delete(RoleId,PetId,Flag,PetProto)->	
	LineKeyValue = [{"cmd","pet_delete"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"flag",Flag}
		 ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"flag",Flag}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_delete, Log),
	gm_msgwrite:write(pet_delete,LineKeyValue).

pet_feed(RoleId,PetId,Happiness,PetProto)->
	LineKeyValue = [{"cmd","pet_feed"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"happiness",Happiness}
		 ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"happiness",Happiness}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_feed, Log),
	gm_msgwrite:write(pet_feed,LineKeyValue).

role_trad_log(MyRoleId,ToRoleId,Money,PlayerItems)->
	ItemString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_trad_log"},
					{"my_roleid",MyRoleId},
					{"to_roleid",ToRoleId},
					{"money",Money},
					{"items",ItemString}
		 ],
	Log = [{"my_roleid",MyRoleId},
					{"to_roleid",ToRoleId},
					{"money",Money},
					{"items",ItemString}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_trad_log, Log),
	gm_msgwrite:write(role_trad_log,LineKeyValue).

role_new_trad_log(MyRoleId,OtherRoleId,MyMoney,MyPlayerItems,OtherMoney,OtherPlayerItems)->
	MyItemString = player_items_to_string(playeritems_union(MyPlayerItems)),
	OtherItemString = player_items_to_string(playeritems_union(OtherPlayerItems)),
	LineKeyValue = [{"cmd","role_new_trad_log"},
					{"my_roleid",MyRoleId},
					{"other_roleid",OtherRoleId},
					{"mymoney",MyMoney},
					{"myitems",MyItemString},
					{"othermoney",OtherMoney},
					{"otheritems",OtherItemString}
		 ],
	Log = [{"my_roleid",MyRoleId},
					{"other_roleid",OtherRoleId},
					{"mymoney",MyMoney},
					{"myitems",MyItemString},
					{"othermoney",OtherMoney},
					{"otheritems",OtherItemString}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_new_trad_log, Log),
	gm_msgwrite:write(role_new_trad_log,LineKeyValue).

ever_quest_completed(RoleId,EverQuestId,QuestId,CurrentRound,CurrentCount,RoleLevel)->		
	LineKeyValue = [{"cmd","ever_quest_completed"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel}   
		 ],
	Log = [{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel}  
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), ever_quest_completed, Log),
	gm_msgwrite:write(ever_quest_completed,LineKeyValue).

ever_quest_accepted(RoleId,EverQuestId,QuestId,CurrentRound,CurrentCount,RoleLevel)->	
	LineKeyValue = [{"cmd","ever_quest_accepted"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel}   
		 ],
	Log = [{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel} 
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), ever_quest_accepted, Log),
	gm_msgwrite:write(ever_quest_accepted,LineKeyValue).

refresh_ever_quest(RoleId,EverQuestId,RefreshType,Quality,RoleLevel)->	
	LineKeyValue = [{"cmd","refresh_ever_quest"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"refresh_type",RefreshType},
					{"quality",Quality},
					{"rolelevel",RoleLevel} 
		 ],
	Log = [{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"refresh_type",RefreshType},
					{"quality",Quality},
					{"rolelevel",RoleLevel} 
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), refresh_ever_quest, Log),
	gm_msgwrite:write(refresh_ever_quest,LineKeyValue).

role_power_gather(RoleId,Power,Class,RoleLevel)->			
	LineKeyValue = [{"cmd","role_power_gather"},
					{"roleid",RoleId},
					{"power",Power},
					{"class",Class},
					{"rolelevel",RoleLevel}   
		 ],
	Log = [{"roleid",RoleId},
					{"power",Power},
					{"class",Class},
					{"rolelevel",RoleLevel} 
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_power_gather, Log),
	gm_msgwrite:write2(role_power_gather,LineKeyValue,nodb).

role_batter(RoleId,Batter,RoleLevel)->		
	LineKeyValue = [{"cmd","role_batter"},
					{"roleid",RoleId},
					{"batter",Batter},
					{"rolelevel",RoleLevel}   
		 ],
	Log = [{"roleid",RoleId},
					{"batter",Batter},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_batter, Log),
	gm_msgwrite:write(role_batter,LineKeyValue).

role_ranks_info(RankList)->
	lists:foreach(fun({RoleId,Kills})->
		LineKeyValue = [{"cmd","role_ranks_info"},
						{"roleid",RoleId},
						{"kills",Kills}
					   ],
		Log = [{"roleid",RoleId},
						{"kills",Kills}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_ranks_info, Log),
		gm_msgwrite:write(role_ranks_info,LineKeyValue) 
				  end, RankList).

create_role(UserName,UserId,RoleName,RoleId,Class,Gender,IpAddress,IsVisitor)->
	LineKeyValue = [{"cmd","create_role"},
					{"username",list_to_binary(mysql_util:escape(UserName))},
					{"userid",UserId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"roleid",RoleId},
					{"roleclass",Class},
					{"gender",Gender},
					{"ipaddress",IpAddress},
					{"visitor_bool",IsVisitor}
		 ],
	Log = [{"username",list_to_binary(mysql_util:escape(UserName))},
					{"userid",UserId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"roleid",RoleId},
					{"roleclass",Class},
					{"gender",Gender},
					{"ipaddress",IpAddress},
					{"visitor_bool",IsVisitor}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), create_role, Log),
	gm_msgwrite:write2(create_role,LineKeyValue,directly).
		 
role_visitor_register(RoleId,NewUserName)->
	LineKeyValue = [{"cmd","role_visitor_register"},
					{"roleid",RoleId},
					{"username",list_to_binary(mysql_util:escape(NewUserName))}
		 ],
	Log = [{"roleid",RoleId},
					{"username",list_to_binary(mysql_util:escape(NewUserName))}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_visitor_register, Log),
	gm_msgwrite:write(role_visitor_register,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"username",
										 mysql_util:escape(NewUserName)}]).
	
role_rename(RoleId,OldName,NewName,IpAddress)->
	LineKeyValue = [{"cmd","role_rename"},
					{"roleid",RoleId},
					{"oldname",list_to_binary(mysql_util:escape(OldName))},
					{"newname",list_to_binary(mysql_util:escape(NewName))},
					{"ipaddress",IpAddress}],
	Log = [{"roleid",RoleId},
					{"oldname",list_to_binary(mysql_util:escape(OldName))},
					{"newname",list_to_binary(mysql_util:escape(NewName))},
					{"ipaddress",IpAddress}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_rename, Log),
	gm_msgwrite:write(role_rename,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
											   [{"rolename",
												 mysql_util:escape(NewName)}]).
role_login(RoleId,IpAddress,Level)->
	LineKeyValue = [{"cmd","role_login"},
					{"roleid",RoleId},
					{"ipaddress",IpAddress},
					{"rolelevel",Level}],
	Log = [{"roleid",RoleId},
					{"ipaddress",IpAddress},
					{"rolelevel",Level}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_login, Log),
	gm_msgwrite:write(role_login,LineKeyValue),
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
		[{"lastLoginIp",integer_to_list(gm_msgwrite_mysql:convert_ip2int(IpAddress))},
		 {"lastLoginTime",integer_to_list(TimeSeconds)}
		]). 

role_logout(RoleId,IpAddress,TimeOnLine,Level)->
	LineKeyValue = [{"cmd","role_logout"},
					{"roleid",RoleId},
					{"ipaddress",IpAddress},
					{"timeonline",TimeOnLine},
					{"rolelevel",Level}],
	Log = [{"roleid",RoleId},
					{"ipaddress",IpAddress},
					{"timeonline",TimeOnLine},
					{"rolelevel",Level}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_logout, Log),
	gm_msgwrite:write(role_logout,LineKeyValue),
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"lastLogoutTime",
										 integer_to_list(TimeSeconds)}]).

role_level_up(RoleId,NewLevel)->
	LineKeyValue = [{"cmd","role_leve_up"},
					{"roleid",RoleId},
					{"level",NewLevel}],
	Log = [{"roleid",RoleId},
					{"level",NewLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_leve_up, Log),
	gm_msgwrite:write(role_leve_up,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
										[{"level",integer_to_list(NewLevel)}]). 

role_map_change(RoleId,FromMap,ToMap)->
	LineKeyValue = [{"cmd","role_map_change"},
					{"roleid",RoleId},
					{"frommap",FromMap},
					{"tomap",ToMap}],
	Log = [{"roleid",RoleId},
					{"frommap",FromMap},
					{"tomap",ToMap}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_map_change, Log),
	gm_msgwrite:write2(role_map_change,LineKeyValue,nodb).


 %% Action = "accept" | "compelete" | "quit" | "submit"
role_quest_log(RoleId,QuestId,Action,RoleLevel)->			
	LineKeyValue = [{"cmd","role_quest_log"},
					{"roleid",RoleId},
					{"action",Action},
					{"quest",QuestId},
					{"rolelevel",RoleLevel}   
				   ],
	Log = [{"roleid",RoleId},
					{"action",Action},
					{"quest",QuestId},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_quest_log, Log),
	gm_msgwrite:write(role_quest_log,LineKeyValue).

role_skill_learn(RoleId,SkillId,SkillLevel,RoleLevel)-> 		
	LineKeyValue = [{"cmd","role_skill_learn"},
					{"roleid",RoleId},
					{"skill",SkillId},
					{"level",SkillLevel},
					{"rolelevel",RoleLevel}   
				   ],
	Log = [{"roleid",RoleId},
					{"skill",SkillId},
					{"level",SkillLevel},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_skill_learn, Log),
	gm_msgwrite:write(role_skill_learn,LineKeyValue).

%% Reason = "got_systemgive" 
%%			"lost_function" | "lost_mall"
role_ticket_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)-> 		
	LineKeyValue = [{"cmd","role_ticket_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}		
				  ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_ticket_change, Log),
	gm_msgwrite:write(role_ticket_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"ticket",integer_to_list(NewCount)}]). 

%% Reason = "gm_got_charge"|"got_charge" | "got_giftplayer" | "got_tradplayer" 
%%          "lost_function" | "lost_mall" | "lost_tradplayer" | "lost_giftplayer" 
%% 			"lost_tosilver"|lost_respawn|treasure_chest_cost |"lost_pet_quality_up"		
role_gold_change(Account,RoleId,ChangeCount,NewCount,Reason)->   
	LineKeyValue = [{"cmd","role_gold_change"},
					{"account",Account},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason}
				   ],
	Log = [{"account",Account},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_gold_change, Log),
	gm_msgwrite:write(role_gold_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_buffer("role_user", ["gold"], 
								[integer_to_list(NewCount)], 
								"username='"++mysql_util:escape(Account)++"'").

%% Reason = "got_monster" | "got_quest" |"got_npctrad" | "got_tradplayer" | "got_giftplayer" |"got_fromgold" |"got_tangle_battle"
%%			"getmail" | "sendmail" | "stall_buy" |"got_down_stall" | "got_chess_spirit"
%%          "lost_function" | "lost_skill" | "lost_repaire" | "lost_npctrad" | "lost_tradplayer"| "lost_giftplayer"
%%			"lost_stall_buy" | "lost_up_stall" | "lost_over_due" | "lost_use_up" | "consume_up" | "role_destroy" "lost_swap_stack"
%%			"lost_pet_quality_up" 
role_silver_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_silver_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_silver_change, Log),
	gm_msgwrite:write(role_silver_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									  [{"silver",integer_to_list(NewCount)}]).  

role_boundsilver_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->
	LineKeyValue = [{"cmd","role_boundsilver_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_boundsilver_change, Log),
	gm_msgwrite:write(role_boundsilver_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									  [{"boundsilver",integer_to_list(NewCount)}]).

role_charge_integral_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_charge_integral_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_charge_integral_change, Log),
	gm_msgwrite:write(role_charge_integral_change,LineKeyValue).

role_consume_integral_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_consume_integral_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_consume_integral_change, Log),
	gm_msgwrite:write(role_consume_integral_change,LineKeyValue).

role_honor_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->
	LineKeyValue = [{"cmd","role_honor_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_honor_change, Log),
	gm_msgwrite:write(role_honor_change,LineKeyValue).

%%reason <= 45 bytes
%% reason:golden_plume_awards | refine_system
role_get_item(RoleId,ItemId,Count,ItemProto,Reason,RoleLevel)->	
	LineKeyValue = [{"cmd","role_get_item"},
					{"roleid",RoleId},
					{"item",ItemId},
					{"count",Count},
					{"proto",ItemProto},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"item",ItemId},
					{"count",Count},
					{"proto",ItemProto},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_get_item, Log),
	gm_msgwrite:write(role_get_item,LineKeyValue).


role_release_item(RoleId,ItemId,ProtoId,OtherRoleId,Reason,RoleLevel)->			
	LineKeyValue = [{"cmd","role_release_item"},
					{"roleid",RoleId},
					{"protoid",ProtoId},
					{"item",ItemId},
					{"dstrole",OtherRoleId},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"protoid",ProtoId},
					{"item",ItemId},
					{"dstrole",OtherRoleId},
					{"reason",Reason},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_release_item, Log),
	gm_msgwrite:write(role_release_item,LineKeyValue).

%%Type = "star"| "socket"| "stone_mix" | "e_upgrade" | 
%%       "star_failed"| "socket_failed"| "stone_mix_failed" | "e_upgrade_failed"
role_enchantments_item(RoleId,ItemId,Type,ItemResult,RoleLevel)-> 
	LineKeyValue = [{"cmd","role_enchantments_item"},
					{"roleid",RoleId},
					{"item",ItemId},
					{"type",Type},
					{"result",ItemResult},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"item",ItemId},
					{"type",Type},
					{"result",ItemResult},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_enchantments_item, Log),
	gm_msgwrite:write(role_enchantments_item,LineKeyValue).

%%Type = "growth"| "stamina"| "riseup" 
%%       "growth_failed"| "stamina_failed"| "riseup_failed" 
role_petup(RoleId,PetId,Type,Start,End,RoleLevel)-> 
	LineKeyValue = [{"cmd","role_petup"},
					{"roleid",RoleId},
					{"petId",PetId},
					{"type",Type},
					{"start",Start},
					{"end",End},
					{"rolelevel",RoleLevel}			
				   ],
	Log = [{"roleid",RoleId},
					{"petId",PetId},
					{"type",Type},
					{"start",Start},
					{"end",End},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_petup, Log),
	gm_msgwrite:write(role_petup,LineKeyValue).

role_join_guild(RoleId,GuildId)->
	LineKeyValue = [{"cmd","role_join_guild"},
					{"roleid",RoleId},
					{"guild",GuildId}
					],
	Log = [{"roleid",RoleId},
					{"guild",GuildId}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_join_guild, Log),
	gm_msgwrite:write(role_join_guild,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
											   [{"guild",gm_msgwrite_mysql:value_to_list(GuildId)}]). 

role_leave_guild(RoleId,GuildId,Reason)->        
	LineKeyValue = [{"cmd","role_leave_guild"},
					{"roleid",RoleId},
					{"guild",GuildId},
				   	{"reason",Reason}
				   ],
	Log = [{"roleid",RoleId},
					{"guild",GuildId},
				   	{"reason",Reason}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_leave_guild, Log),
	gm_msgwrite:write(role_leave_guild,LineKeyValue).

role_consume_item(RoleId,ItemId,ProtoId,Count,LeftCount)->
	LineKeyValue = [{"cmd","role_consume_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"item",ProtoId},
					{"count",Count},
					{"leftcount",LeftCount}],
	Log = [{"roleid",RoleId},
					{"itemid",ItemId},
					{"item",ProtoId},
					{"count",Count},
					{"leftcount",LeftCount}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_consume_item, Log),
	gm_msgwrite:write(role_consume_item,LineKeyValue).

role_flush_items(RoleId,PlayerItems)->
	ItemString = player_items_to_string(player_items_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_items"},
					{"roleid",RoleId},
					{"items",ItemString}
					],
	Log = [{"roleid",RoleId},
					{"items",ItemString}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_items, Log),
	gm_msgwrite:write2(role_items,LineKeyValue,nodb).

role_chat(RoleId,RoleName,ToRole,Channel,Content)->
	LineKeyValue = [{"cmd","role_chat"},
					{"roleid",RoleId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"torole",ToRole},
					{"channel",Channel},
					{"content",Content}  
					],
	Log = [{"cmd","role_chat"},
					{"roleid",RoleId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"torole",ToRole},
					{"channel",Channel},
					{"content",Content}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_chat, Log),
	gm_msgwrite:write2(role_chat,LineKeyValue,nodb).

role_buy_mall_item(RoleId,ItemId,Price,Count,PriceType,RoleLevel)-> 	
	LineKeyValue = [{"cmd","role_buy_mall_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count},
					{"pricetype",PriceType},
					{"rolelevel",RoleLevel}		
					],
	Log = [{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count},
					{"pricetype",PriceType},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_buy_mall_item, Log),
	gm_msgwrite:write(role_buy_mall_item,LineKeyValue).

role_buy_guild_mall_item(RoleId,ItemId,Price,Count)->
	LineKeyValue = [{"cmd","role_buy_guild_mall_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count}
					],
	Log = [{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_buy_guild_mall_item, Log),
	gm_msgwrite:write(role_buy_guild_mall_item,LineKeyValue).

role_guild_contribution_change(RoleId,GuildId,Contribution,Reason)->
	LineKeyValue = [{"cmd","role_guild_contribution_change"},
					{"roleid",RoleId},
					{"guildid",GuildId},
					{"contribution",Contribution},
					{"reason",Reason}
					],
	Log = [{"roleid",RoleId},
					{"guildid",GuildId},
					{"contribution",Contribution},
					{"reason",Reason}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_guild_contribution_change, Log),
	gm_msgwrite:write(role_guild_contribution_change,LineKeyValue).

role_loop_tower(RoleId,Layer,LayerTime)->		
	LineKeyValue = [{"cmd","role_loop_tower"},
					{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime}
					],
	Log = [{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_loop_tower, Log),
	gm_msgwrite:write(role_loop_tower,LineKeyValue).

role_loop_tower_detail(RoleId,Layer,LayerTime,Detail,RoleLevel)->		
	LineKeyValue = [{"cmd","role_loop_tower_detail"},
					{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime},
					{"detail",Detail},
					{"rolelevel",RoleLevel}	
					],
	Log = [{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime},
					{"detail",Detail},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_loop_tower_detail, Log),
	gm_msgwrite:write(role_loop_tower_detail,LineKeyValue).

drop_rule(RuleId,ItemId,Count,RoleFlag)->
	LineKeyValue = [{"cmd","drop_rule"},
					{"ruleid",RuleId},
					{"itemid",ItemId},
					{"count",Count},
					{"roleflag",RoleFlag}
					],
	Log = [{"ruleid",RuleId},
					{"itemid",ItemId},
					{"count",Count},
					{"roleflag",RoleFlag}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), drop_rule, Log),
	gm_msgwrite:write(drop_rule,LineKeyValue).

answer_log(RoleId,Score,Rank,Exp,RoleLevel)->
	LineKeyValue = [{"cmd","role_answer_log"},
					{"roleid",RoleId},
					{"score",Score},
					{"rank",Rank},
					{"exp",Exp},
					{"rolelevel",RoleLevel}		%%add
					],
	Log = [{"roleid",RoleId},
					{"score",Score},
					{"rank",Rank},
					{"exp",Exp},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_answer_log, Log),
	gm_msgwrite:write(role_answer_log,LineKeyValue).

answering_log(RoleId,Status,AnswerTime,Flag,Score)->
	LineKeyValue = [{"cmd","role_answering_log"},
					{"roleid",RoleId},
					{"status",Status},
					{"answer_time",AnswerTime},
					{"flag",Flag},
					{"score",Score}
					],
	Log = [{"roleid",RoleId},
					{"status",Status},
					{"answer_time",AnswerTime},
					{"flag",Flag},
					{"score",Score}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_answering_log, Log),
	gm_msgwrite:write(role_answering_log,LineKeyValue).

%%Status=1,join|2,
spa_log(RoleId,RoleLevel,Status,Exp)->
	LineKeyValue = [{"cmd","role_spa_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"status",Status},
					{"exp",Exp}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"status",Status},
					{"exp",Exp}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_spa_log, Log),
	gm_msgwrite:write(role_spa_log,LineKeyValue).

%%
%%Reset the number of consecutive login
%%
role_clear_continuous_days(RoleId,Days)->
	LineKeyValue = [{"cmd","role_continuous_log"},
					{"roleid",RoleId},
					{"days",Days}
					],
	Log = [{"roleid",RoleId},
					{"days",Days}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_continuous_log, Log),
	gm_msgwrite:write(role_continuous_log,LineKeyValue).

role_continuous_days_reward(RoleId,Days,IsVip)->
	LineKeyValue = [{"cmd","role_continuous_reward_log"},
					{"roleid",RoleId},
					{"days",Days},
					{"isvip",IsVip}
					],
	Log = [{"roleid",RoleId},
					{"days",Days},
					{"isvip",IsVip}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_continuous_reward_log, Log),
	gm_msgwrite:write(role_continuous_reward_log,LineKeyValue).

%%
%%Activity changes
%%
role_activity_value_change(RoleId,Type,RoleLevel,CompleteTimes,TotalTimes)->
	LineKeyValue = [{"cmd","role_activity_value_change_log"},
					{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel},
					{"complete",CompleteTimes},
					{"total",TotalTimes}		
					],
	Log = [{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel},
					{"complete",CompleteTimes},
					{"total",TotalTimes}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_activity_value_change_log, Log),
	gm_msgwrite:write(role_activity_value_change_log,LineKeyValue).


role_activity_value(RoleId,AddValue,NewValue,Type,RoleLevel)->
	LineKeyValue = [{"cmd","role_activity_value_log"},
					{"roleid",RoleId},
					{"addvalue",AddValue},
					{"newvalue",NewValue},
					{"type",Type},
					{"rolelevel",RoleLevel}		
					],
	Log = [{"roleid",RoleId},
					{"addvalue",AddValue},
					{"newvalue",NewValue},
					{"type",Type},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_activity_value_log, Log),
	gm_msgwrite:write(role_activity_value_log,LineKeyValue).

%%
%%Redemption activity
%%
role_activity_value_reward(RoleId,Value,Id,Remain,RoleLevel)->
	LineKeyValue = [{"cmd","role_activity_value_reward_log"},
					{"roleid",RoleId},
					{"value",Value},
					{"itemid",Id},
					{"remain",Remain},
					{"rolelevel",RoleLevel}		
					],
	Log = [{"roleid",RoleId},
					{"value",Value},
					{"itemid",Id},
					{"remain",Remain},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_activity_value_reward_log, Log),
	gm_msgwrite:write(role_activity_value_reward_log,LineKeyValue).
 
%%
%%first charge gift
%%Opt :has_get_reward 
%%
role_first_charge_gift(RoleId,Opt,RoleLevel)->
	LineKeyValue = [{"cmd","role_first_charge_gift_log"},
					{"roleid",RoleId},
					{"opt",Opt},
					{"rolelevel",RoleLevel}
					],
	Log = [{"roleid",RoleId},
					{"opt",Opt},
					{"rolelevel",RoleLevel}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_first_charge_gift_log, Log),
	gm_msgwrite:write(role_first_charge_gift_log,LineKeyValue).


role_join_instance(RoleId,RoleLevel,GroupMember,InstanceId,InstanceProtoId,Times)->
	GroupMemberStr = roleids_to_string(GroupMember),
	LineKeyValue = [{"cmd","role_join_instance"},
					{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId},
					{"times",Times}
					],
	Log = [{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId},
					{"times",Times}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_join_instance, Log),
	gm_msgwrite:write(role_join_instance,LineKeyValue).

role_level_instance(RoleId,RoleLevel,GroupMember,InstanceId,InstanceProtoId)->
	GroupMemberStr = roleids_to_string(GroupMember),
	LineKeyValue = [{"cmd","role_level_instance"},
					{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId}
					],
	Log = [{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_level_instance, Log),
	gm_msgwrite:write(role_level_instance,LineKeyValue).

role_send_mail(RoleId,ToRoleId,MailId,PlayerItems,Silver,Gold)->
	ItemsString = player_items_to_string(PlayerItems),
	LineKeyValue = [{"cmd","role_send_mail"},
					{"roleid",RoleId},
					{"toid",ToRoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold}
					],
	Log = [{"roleid",RoleId},
					{"toid",ToRoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_send_mail, Log),
	gm_msgwrite:write(role_send_mail,LineKeyValue).

role_read_mail(RoleId,MailId,PlayerItems,Silver,Gold)->
	ItemsString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_read_mail"},
					{"roleid",RoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold}
					],
	Log = [{"roleid",RoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_read_mail, Log),
	gm_msgwrite:write(role_read_mail,LineKeyValue).

role_delete_mail(RoleId,MailId,ItemIds,Silver,Gold,Type)->
	LineKeyValue = [{"cmd","role_delete_mail"},
					{"roleid",RoleId},
					{"mailid",MailId},
					{"itemids",ItemIds},
					{"silver",Silver},
					{"gold",Gold},
					{"type",Type}
					],
	Log = [{"roleid",RoleId},
					{"mailid",MailId},
					{"itemids",ItemIds},
					{"silver",Silver},
					{"gold",Gold},
					{"type",Type}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_delete_mail, Log),
	gm_msgwrite:write(role_delete_mail,LineKeyValue).

role_auction_log(SellerId,BuyerId,PlayerItems,Silver,Gold)->
	LineKeyValue = [{"cmd","role_auction_log"},
					{"sellid",SellerId},
					{"buyerid",BuyerId},
					{"items",PlayerItems},
					{"silver",Silver},
					{"gold",Gold}
					],
	Log = [{"sellid",SellerId},
					{"buyerid",BuyerId},
					{"items",PlayerItems},
					{"silver",Silver},
					{"gold",Gold}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_auction_log, Log),
	gm_msgwrite:write(role_auction_log,LineKeyValue).


role_chess_spirits_reward(RoleId,Level,Type,PlayerItems,Exp)->
	ItemsString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_chess_spirits_reward"},
					{"roleid",RoleId},
					{"level",Level},
					{"type",Type},
					{"items",ItemsString},
					{"exp",Exp}
					],
	Log = [{"roleid",RoleId},
					{"level",Level},
					{"type",Type},
					{"items",ItemsString},
					{"exp",Exp}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_chess_spirits_reward, Log),
	gm_msgwrite:write(role_chess_spirits_reward,LineKeyValue).


%%role_npc_exchange(RoleId,NpcId,PlayerItems,)->
	
	
%% 	
%%treasure_chest  
%%
treasure_chest_lottery_items(RoleId,BeadType,ConsumeType,Gold,BindConsumeNum,NonBindConsumeNum,TreasureItems,RoleLevel)->
	ItemString = player_items_to_string(TreasureItems),
	LineKeyValue = [{"cmd","treasure_chest_lottery_items_log"},
					{"roleid",RoleId},
					{"bead_type",BeadType},
					{"consume_type",ConsumeType},
					{"gold",Gold},			
					{"bind_item_consume_num",BindConsumeNum},
					{"nonbind_item_consume_num",NonBindConsumeNum},
					{"lottery_items",ItemString},
					{"rolelevel",RoleLevel}		
		 ],
	Log = [{"roleid",RoleId},
					{"bead_type",BeadType},
					{"consume_type",ConsumeType},
					{"gold",Gold},			
					{"bind_item_consume_num",BindConsumeNum},
					{"nonbind_item_consume_num",NonBindConsumeNum},
					{"lottery_items",ItemString},
					{"rolelevel",RoleLevel}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), treasure_chest_lottery_items_log, Log),
	gm_msgwrite:write(treasure_chest_lottery_items_log,LineKeyValue).


%% 
%%treasure_chest_package 
%% 
treasure_chest_package_get_items(RoleId,ItemList)->
	ItemString = player_items_to_string(ItemList),
	LineKeyValue = [{"cmd","treasure_chest_package_get_items_log"},
					{"roleid",RoleId},
					{"get",ItemString}
					],
	Log = [{"roleid",RoleId},
					{"get",ItemString}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), treasure_chest_package_get_items_log, Log),
	gm_msgwrite:write(treasure_chest_package_get_items_log,LineKeyValue).


%% 
%%facebook bind
%% 
facebook_bind(RoleId,FaceBookId,MsgId,Result)->
	LineKeyValue = [{"cmd","facebook_bind_log"},
					{"roleid",RoleId},
					{"facebookid",FaceBookId},
					{"msgid",MsgId},		
					{"result",Result}		
					],
	Log = [{"roleid",RoleId},
					{"facebookid",FaceBookId},
					{"msgid",MsgId},		
					{"result",Result}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), facebook_bind_log, Log),
	gm_msgwrite:write(facebook_bind_log,LineKeyValue).

%%
%%honor_stores
%%
role_buy_item_by_honor(RoleId,ItemId,Count,Price)->
	LineKeyValue = [{"cmd","role_buy_item_by_honor_log"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"count",Count},
					{"price",Price}		
					],
	Log = [{"roleid",RoleId},
					{"itemid",ItemId},
					{"count",Count},
					{"price",Price}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_buy_item_by_honor_log, Log),
	gm_msgwrite:write(role_buy_item_by_honor_log,LineKeyValue).

%%
%%chess spirit result 
%%Type:1:single 2:team
%%
chess_spirit_log(Type,RoleId,RoleLevel,ConsumeTime_S,SectionNum,Roleids)->
	GroupMemberStr = roleids_to_string(Roleids),
	LineKeyValue = [{"cmd","chess_spirit_log"},
					{"roleid",RoleId},
					{"type",Type},
					{"level",RoleLevel},
					{"use_time_s",ConsumeTime_S},
					{"section",SectionNum},
					{"roleids",GroupMemberStr},
					{"teamnum",erlang:length(Roleids)}
					],
	Log = [{"roleid",RoleId},
					{"type",Type},
					{"level",RoleLevel},
					{"use_time_s",ConsumeTime_S},
					{"section",SectionNum},
					{"roleids",GroupMemberStr},
					{"teamnum",erlang:length(Roleids)}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), chess_spirit_log, Log),
	gm_msgwrite:write(chess_spirit_log,LineKeyValue).

%% 
%%welfare borad activity 
%% 
welfare_activity_log(RoleId,TypeNumber,SerialNumber)->
	LineKeyValue = [{"cmd","welfare_activity_log"},
					{"roleid",RoleId},
					{"typenumber",TypeNumber},		
					{"serialnumber",SerialNumber}	
					],
	Log = [{"roleid",RoleId},
					{"typenumber",TypeNumber},		
					{"serialnumber",SerialNumber}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), welfare_activity_log, Log),
	gm_msgwrite:write(welfare_activity_log,LineKeyValue).

%%

%%pet_wash_attr_point
%%
pet_wash_attr_point_log(RoleId,RoleLevel,PetProtoId,PetId,Result)->
	LineKeyValue = [{"cmd","pet_wash_attr_point_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result}					%%noitem|sucess
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result}	
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_wash_attr_point_log, Log),
	gm_msgwrite:write(pet_wash_attr_point_log,LineKeyValue).

%%
%%pet_add_attr_point
%%
pet_add_attr_point_log(RoleId,RoleLevel,PetProtoId,PetId,Result,AddPoint,RemainPoint)->
	LineKeyValue = [{"cmd","pet_add_attr_point_log"},			
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result},					%%point_not_enough|sucess
					{"addpoint",AddPoint},
					{"remainpoint",RemainPoint}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result},					%%point_not_enough|sucess
					{"addpoint",AddPoint},
					{"remainpoint",RemainPoint}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_add_attr_point_log, Log),
	gm_msgwrite:write(pet_add_attr_point_log,LineKeyValue).

%%
%%pet_grade_quality
%%
pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,IsHasProtect,Result,Value)->
	LineKeyValue = [{"cmd","pet_grade_quality_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"ishasprotect",IsHasProtect},		%%noprotect|hasprotect
					{"result",Result},					%%failed|sucess
					{"value",Value}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"ishasprotect",IsHasProtect},		%%noprotect|hasprotect
					{"result",Result},					%%failed|sucess
					{"value",Value}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_grade_quality_log, Log),
	gm_msgwrite:write(pet_grade_quality_log,LineKeyValue).

%%
%%pet_grade_quality_up
%%
pet_grade_quality_up_log(RoleId,RoleLevel,PetProtoId,PetId,Type,Result,Value)->
	LineKeyValue = [{"cmd","pet_grade_quality_up_log"},%%@@wb20130327pet_grade_quality_log
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"type",Type},						%%gold_consume|item_consume
					{"result",Result},					%%failed|sucess
					{"value",Value}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"type",Type},						%%gold_consume|item_consume
					{"result",Result},					%%failed|sucess
					{"value",Value}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_grade_quality_log, Log),
	gm_msgwrite:write(pet_grade_quality_log,LineKeyValue).

%%

%%pet_evolution
%%
pet_evolution_log(RoleId,PetId,PetTempId,Silver,ItemClass,Count,Result)->
	LineKeyValue = [{"cmd","pet_evolution_log"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"silver",Silver},
					{"itemclass",ItemClass},
					{"count",Count},
					{"result",Result}
				   ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"silver",Silver},
					{"itemclass",ItemClass},
					{"count",Count},
					{"result",Result}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_evolution_log, Log),
	gm_msgwrite:write(pet_evolution_log,LineKeyValue).

%%
%%pet_talent_log
%%
pet_talent_consume(RoleId,PetId,PetTempId,Type,Gold)->
	LineKeyValue = [{"cmd","pet_talent_consume"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"type",Type},
					{"gold",Gold}
				   ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"type",Type},
					{"gold",Gold}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_talent_consume, Log),
	gm_msgwrite:write(pet_talent_consume,LineKeyValue).

pet_talent_change(RoleId,PetId,TalentList,PetProto)->
	LineKeyValue = [{"cmd","pet_talent_change"},
					{"roleid",RoleId},
					{"petid",PetId},
					%{"power",T_Power},
					%{"hitrate",T_HitRate},
					%{"criticalrate",T_Criticalrate},
					%{"stamina",T_Stamina},
					{"talentlist",TalentList},
					{"petproto",PetProto}
				   ],
	Log = [{"roleid",RoleId},
					{"petid",PetId},
					%{"power",T_Power},
					%{"hitrate",T_HitRate},
					%{"criticalrate",T_Criticalrate},
					%{"stamina",T_Stamina},
					{"talentlist",TalentList},
					{"petproto",PetProto}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_talent_change, Log),
	gm_msgwrite:write(pet_talent_change,LineKeyValue).

%%
%%ride_pet_synthesis_log
%%
ride_pet_synthesis_log(RoleId,RidePetA,RidePetB,ResultPet,AddAttr)->
	LineKeyValue = [{"cmd","ride_pet_synthesis_log"},
					{"roleid",RoleId},
					{"ridepeta",RidePetA},
					{"ridepetb",RidePetB},
					{"resultpet",ResultPet},
					{"addattr",AddAttr}
				   ],
	Log = [{"roleid",RoleId},
					{"ridepeta",RidePetA},
					{"ridepetb",RidePetB},
					{"resultpet",ResultPet},
					{"addattr",AddAttr}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), ride_pet_synthesis_log, Log),
	gm_msgwrite:write(ride_pet_synthesis_log,LineKeyValue).

%%role_crime
role_change_crime_log(RoleId,SelfModel,OtherModel,NewCrime,LastCrime,Ext)->
	LineKeyValue = [{"cmd","role_change_crime_log"},
					{"roleid",RoleId},
					{"selfmodel",SelfModel},
					{"othermodel",OtherModel},
					{"newcrime",NewCrime},
					{"lastcrime",LastCrime},
					{"ext",Ext}
				   ],
	Log = [{"roleid",RoleId},
					{"selfmodel",SelfModel},
					{"othermodel",OtherModel},
					{"newcrime",NewCrime},
					{"lastcrime",LastCrime},
					{"ext",Ext}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_change_crime_log, Log),
	gm_msgwrite:write2(role_change_crime_log,LineKeyValue,nodb).

%%golden_plume_awards_log
golden_plume_awards_log(RoleId,RoleLevel,Result,TmpReason,ActivityNumber)->
	Reason = if
				 TmpReason =:= ?ERROR_ACTIVITY_UPDATE_OK->
					 sucess;
				 TmpReason =:= ?ERROR_SERIAL_NUMBER_ERROR->
					 serial_number_error;
				 TmpReason =:= ?ERROR_USED_SERIAL_NUMBER->
					 used_serial_number;
				 TmpReason =:= ?ERROR_HAS_FINISHED->
					 has_finished;
				 true->
					 other_error
			 end,
	ActivityName = if
					   ActivityNumber =:= ?FIRST_PAY ->
						   first_pay;
					   ActivityNumber =:= ?NEW_BIRD ->
						   new_bird;
					   ActivityNumber =:= ?TW_MEMBER ->
						   tw_member;
					   ActivityNumber =:= ?TW_NEW_BIRD ->
						   tw_new_bird;
					   ActivityNumber =:= ?TW_FIRST_PAY ->
						   tw_first_pay;
					   ActivityNumber =:= ?GOLD_EXCHANGE_ACTIVITY ->
						   gold_exchange_ticket;
					   ActivityNumber =:= ?TW_OTHER->
						   tw_other;
					   ActivityNumber =:= ?GOLDEN_PLUME_AWARDS->
						   golden_plume_awards;
					   ActivityNumber =:= ?CONSUME_RETRURN ->
						   consume_return_gift
				   end,
	LineKeyValue = [{"cmd","golden_plume_awards_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"result",Result},
					{"reason",Reason},
					{"activityname",ActivityName}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"result",Result},
					{"reason",Reason},
					{"activityname",ActivityName}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), golden_plume_awards_log, Log),
	gm_msgwrite:write(golden_plume_awards_log,LineKeyValue).


role_expand_package(RoleId,NewPackageSize,ExpandNum)->
	LineKeyValue = [{"cmd","role_expand_package_log"},
					{"roleid",RoleId},
					{"newpackagesize",NewPackageSize},
					{"expandsize",ExpandNum}
				   ],
	Log = [{"roleid",RoleId},
					{"newpackagesize",NewPackageSize},
					{"expandsize",ExpandNum}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_expand_package_log, Log),
	gm_msgwrite:write(role_expand_package_log,LineKeyValue).

role_expand_storage(RoleId,NewStorageSize,ExpandNum)->
	LineKeyValue = [{"cmd","role_expand_storage_log"},
					{"roleid",RoleId},
					{"newstoragesize",NewStorageSize},
					{"expandsize",ExpandNum}
				   ],
	Log = [{"roleid",RoleId},
					{"newstoragesize",NewStorageSize},
					{"expandsize",ExpandNum}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), role_expand_storage_log, Log),
	gm_msgwrite:write(role_expand_storage_log,LineKeyValue).

%%refine_system_log
refine_system_log(RoleId,RoleLevel,SerilNumber,Times,Result)->
	LineKeyValue = [{"cmd","refine_system_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"serial_number",SerilNumber},
					{"times",Times},
					{"result",Result}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"serial_number",SerilNumber},
					{"times",Times},
					{"result",Result}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), refine_system_log, Log),
	gm_msgwrite:write(refine_system_log,LineKeyValue).	

%%consume_return_activity
consume_return_activity_log(RoleId,RoleLevel,Times,RemainConsumeGold)->
	LineKeyValue = [{"cmd","consume_return_activity_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"times",Times},
					{"remain_consume_gold",RemainConsumeGold}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"times",Times},
					{"remain_consume_gold",RemainConsumeGold}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), consume_return_activity_log, Log),
	gm_msgwrite:write(consume_return_activity_log,LineKeyValue).	

%%
%%item_identify
%%
item_identify_log(RoleId,ResultItem,AddAttr)->
	LineKeyValue = [{"cmd","item_identify_log"},
					{"roleid",RoleId},
					{"resultitem",ResultItem},
					{"addattr",AddAttr}
				   ],
	Log = [{"roleid",RoleId},
					{"resultitem",ResultItem},
					{"addattr",AddAttr}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), item_identify_log, Log),
	gm_msgwrite:write(item_identify_log,LineKeyValue).

%%
%%treasure_transport
%%
treasure_transport_failed(RoleId,Quality,Bonusexp,Bonusmoney,Reason)->
	LineKeyValue = [{"cmd","treasure_transport_failed_log"},
					{"roleid",RoleId},
					{"quality",Quality},
					{"bonusexp",Bonusexp},
					{"bonusmoney",Bonusmoney},
					{"reason",Reason}
				   ],
	Log = [{"roleid",RoleId},
					{"quality",Quality},
					{"bonusexp",Bonusexp},
					{"bonusmoney",Bonusmoney},
					{"reason",Reason}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), treasure_transport_failed_log, Log),
	gm_msgwrite:write(treasure_transport_failed_log,LineKeyValue).

%%
%%goals
%%
goals_can_reward(RoleId,RoleLevel,Days,Part)->
	LineKeyValue = [{"cmd","goals_can_reward_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), goals_can_reward_log, Log),
	gm_msgwrite:write2(goals_can_reward_log,LineKeyValue,nodb).

goals_reward(RoleId,RoleLevel,Days,Part,Bonus)->
	LineKeyValue = [{"cmd","goals_reward_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part},
					{"bonus",Bonus}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part},
					{"bonus",Bonus}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), goals_reward_log, Log),
	gm_msgwrite:write2(goals_reward_log,LineKeyValue,nodb).

%%pet explore 
pet_explore_log(RoleId,RoleLevel,SiteId,StyleId,Lucky,Key)->
	LineKeyValue = [{"cmd","pet_explore_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"siteid",SiteId},
					{"styleid",StyleId},
					{"lucky",Lucky},
					{"key",Key}
				   ],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"siteid",SiteId},
					{"styleid",StyleId},
					{"lucky",Lucky},
					{"key",Key}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_explore_log, Log),
	gm_msgwrite:write2(pet_explore_log,LineKeyValue,nodb).
	
%%pet explore get items
pet_explore_get_items_log(RoleId,RoleLevel,ItemList,Time,Key)->
	if
		ItemList =:= "stop"->
			ItemString = "stop";
		true->
			ItemString = player_items_to_string(ItemList)
	end,
	LineKeyValue = [{"cmd","pet_explore_get_items_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"get",ItemString},
					{"explore_end_time",Time},
					{"key",Key}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"get",ItemString},
					{"explore_end_time",Time},
					{"key",Key}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), pet_explore_get_items_log, Log),
	gm_msgwrite:write2(pet_explore_get_items_log,LineKeyValue,nodb).

country_leader_opt(LeaderId,Post,TargetId,Type)->
	LineKeyValue = [{"cmd","country_leader_opt_log"},
					{"leaderid",LeaderId},
					{"post",Post},
					{"targetid",TargetId},
					{"type",Type}
					],
	Log = [{"leaderid",LeaderId},
					{"post",Post},
					{"targetid",TargetId},
					{"type",Type}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), country_leader_opt_log, Log),
	gm_msgwrite:write(country_leader_opt_log,LineKeyValue).

%%
%%mainline
%%opt  entry | start | success | leave | reward | faild |
%%remark 
%%
mainline_opt(RoleId,RoleLevel,Chapter,Stage,Difficult,Opt,Remark)->
	LineKeyValue = [{"cmd","mainline_opt_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"opt",Opt},
					{"remark",Remark}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"opt",Opt},
					{"remark",Remark}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), mainline_opt_log, Log),
	gm_msgwrite:write2(mainline_opt_log,LineKeyValue,nodb).
%%
%%
%%
mainline_defend_monster(RoleId,RoleLevel,Chapter,Stage,Difficult,Section,MonstersList)->
	LineKeyValue = [{"cmd","mainline_defend_monster_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"section",Section},
					{"monsterslist",MonstersList}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"section",Section},
					{"monsterslist",MonstersList}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), mainline_defend_monster_log, Log),
	gm_msgwrite:write2(mainline_defend_monster_log,LineKeyValue,nodb).

mainline_killmonster(RoleId,RoleLevel,Chapter,Stage,Difficult,MonsterProto)->
	LineKeyValue = [{"cmd","mainline_killmonster_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"monsterproto",MonsterProto}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"monsterproto",MonsterProto}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), mainline_killmonster_log, Log),
	gm_msgwrite:write2(mainline_killmonster_log,LineKeyValue,nodb).

%%
%%festival_recharge_log
%% 
festival_recharge_log(RoleId,RoleLevel,Id,CrystalNum,ItemList)->
	ItemString = player_items_to_string(ItemList),
	LineKeyValue = [{"cmd","festival_recharge_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"id",Id},
					{"crystal_num",CrystalNum},
					{"itemlist",ItemString}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"id",Id},
					{"crystal_num",CrystalNum},
					{"itemlist",ItemString}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), festival_recharge_log, Log),
	gm_msgwrite:write2(festival_recharge_log,LineKeyValue,nodb).
	
jszd_battle_log(RoleId,RoleLevel,State,Reward)->
	LineKeyValue = [{"cmd","log_jszd_battle_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"state",State},
					{"reward",Reward}
					],
	Log = [{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"state",State},
					{"reward",Reward}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), log_jszd_battle_log, Log),
	gm_msgwrite:write2(log_jszd_battle_log,LineKeyValue,nodb).

get_battle_reward(RoleId,Battle,Honor,Exp,Item)->
	LineKeyValue = [{"cmd","get_battle_reward_log"},
					{"roleid",RoleId},
					{"honor",Honor},
					{"exp",Exp},
					{"battle",Battle},
					{"item",Item}],
	Log = [{"roleid",RoleId},
					{"honor",Honor},
					{"exp",Exp},
					{"battle",Battle},
					{"item",Item}
		 ],
	stattool:stat(get(roleid), get(openid), get(pf), get(level), get_battle_reward_log, Log),
	gm_msgwrite:write2(get_battle_reward_log,LineKeyValue,nodb).
%% Local Functions
%%
item_info_to_save(ItemInfo)->
	Item = erlang:element(2,ItemInfo),
	Entry = get_template_id_from_iteminfo(Item),
	Count = get_count_from_iteminfo(Item),
	{Entry,Count}.

playeritems_to_save(PlayerItem)->
	#playeritems{entry = Entry,count = Count} = PlayerItem,
	{Entry,Count}.

playeritems_union(ItemsInfos)->
	PlayerItems = lists:map(fun playeritems_to_save/1 , ItemsInfos),
	lists:foldl(fun({ProtoId,Count},OldItems)->
						case Count of
							0-> OldItems;
							_->
								case lists:keyfind(ProtoId, 1, OldItems) of
									false-> [{ProtoId,Count}|OldItems];
									{_,OldCount}-> 
										lists:keyreplace(ProtoId, 1, OldItems, {ProtoId,OldCount+Count})
								end
						end
				end,[], PlayerItems).

player_items_union(ItemsInfo)->
	PlayerItems = lists:map(fun item_info_to_save/1 , ItemsInfo),
	lists:foldl(fun({ProtoId,Count},OldItems)->
						case Count of
							0-> OldItems;
							_->
								case lists:keyfind(ProtoId, 1, OldItems) of
									false-> [{ProtoId,Count}|OldItems];
									{_,OldCount}-> 
										lists:keyreplace(ProtoId, 1, OldItems, {ProtoId,OldCount+Count})
								end
						end
				end,[], PlayerItems).

player_items_to_string(PlayerItems)->
	ItemString = lists:map(fun({ProtoId,Count})->
								   integer_to_list(ProtoId) ++ "," ++ integer_to_list(Count)
						   end, PlayerItems),
	string:join(ItemString, ";").

roleids_to_string([])->
	"";

roleids_to_string(RoleIdList)->
	ItemString = lists:map(fun(RoleId)->
								   integer_to_list(RoleId)
						   end, RoleIdList),
	string:join(ItemString, ";").
