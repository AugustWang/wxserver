%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2013-2-25
%% Description: TODO: Add description to pet_skill_book
-module(pet_skill_book).
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("login_pb.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-define(COUNT,10).
-define(RANDOM,100).
-define(RANSKILL,11).
-define(DEFAULT,12).
-define(COUNTBAT,110).
-define(COPYGOLD,50).
-define(BOUND,1).
-define(BOUNDBOOK,23000121).
-define(NBOUNDBOOK,23000120).
-define(BATREFRESH,2).
-define(REFRESH,1).
%%
%% Include files
%%
-compile(export_all).
%%
%% Exported Functions
%%


%%
%% API Functions
%%
init_pet_skill_book()->
		case pet_skill_book_db:get_pet_skill_info_by_store() of
		[]->
			nothing;
				%io:format("@@@@@@@@@  no store skill~n",[]);
		Skillinfo->
			Skilllist=pet_skill_book_db:get_skill_info_from_store_term(Skillinfo),
			Lucky=pet_skill_book_db:get_skill_lucky_from_store_term(Skillinfo),
			Message=pet_packet:encode_pet_skill_book_init_s2c(1,Lucky,Skilllist),
			role_op:send_data_to_gate(Message)
		end.
			
pet_skill_book(?REFRESH,MoneyType)->
case  pet_skill_book_db:get_pet_skill_info_by_store() of
		[]->
			Lucky=1;
		Pet_SkillInfo->
			Lucky=pet_skill_book_db:get_skill_lucky_from_store_term(Pet_SkillInfo)
	end,
	case pet_skill_book_db:get_skill_rate_info(Lucky) of
		[]->
			nothing;
			%io:format("@@@@@@@@@@@@   no Lucky~n",[]);
		RateInfo->
			HasMoney=role_op:check_money(MoneyType, ?COUNT),
			if not HasMoney ->
				   Error=?ERROR_PET_NOT_ENOUGH_MONEY,
				   Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  	role_op:send_data_to_gate(Message);
			 true->
				 Ratelist=pet_skill_book_db:get_skill_rate(RateInfo),
				 Skilllevel=get_skill_level_from_ratelist(Ratelist),
				 Skill=get_random_skill(),
				 if Skill=:=0->
						role_op:money_change(MoneyType, -?COUNT, skill_book),
						pet_skill_book_db:store_pet_freshen_skill(Lucky+1,[#psb{skilllevel=Skilllevel,skillid=220001,slot=0}]),
						Message=pet_packet:encode_pet_skill_book_init_s2c(1,Lucky+1,[#psb{skilllevel=Skilllevel,skillid=220001,slot=0}]),
						role_op:send_data_to_gate(Message);
					true->
						role_op:money_change(MoneyType, -?COUNT, skill_book),
						pet_skill_book_db:store_pet_freshen_skill(Lucky,[#psb{skilllevel=Skilllevel,skillid=Skill,slot=0}]),
						Message=pet_packet:encode_pet_skill_book_init_s2c(1,Lucky+1,[#psb{skilllevel=Skilllevel,skillid=Skill,slot=0}]),
						role_op:send_data_to_gate(Message)
				 end
			end
	end;
pet_skill_book(?BATREFRESH,MoneyType)->
	case  pet_skill_book_db:get_pet_skill_info_by_store() of
		[]->
			Lucky=1;
	Pet_SkillInfo->
			Lucky=pet_skill_book_db:get_skill_lucky_from_store_term(Pet_SkillInfo)
	end,
			case pet_skill_book_db:get_skill_rate_info(Lucky) of
				[]->
					nothing;
					%io:format("@@@@@@@@@@   not skill book  ~n",[]);
				RateInfo->
					HasMoney=role_op:check_money(MoneyType, ?COUNT),
					if not HasMoney ->
						Error=?ERROR_PET_NOT_ENOUGH_MONEY,
						   Message=pet_packet:encode_pet_opt_error_s2c(Error),
						  	role_op:send_data_to_gate(Message);
					 true->
						 Ratelist=pet_skill_book_db:get_skill_rate(RateInfo),
						 Skilllevellist=get_skill_levelbat_from_ratelist(Ratelist,?DEFAULT,[]),
						 Skill=get_random_skill_bat(?DEFAULT,[]),
						 Info=get_pet_skill_book_level_and_skill(Skilllevellist,Skill,[],0),
						 if Info=:=[]->
								nothing;
							true->
								role_op:money_change(MoneyType, -?COUNTBAT, skill_book),
								pet_skill_book_db:store_pet_freshen_skill(Lucky+12,Info),
								Message=pet_packet:encode_pet_skill_book_init_s2c(1,Lucky+12,Info),
								role_op:send_data_to_gate(Message)
						 end
					end
	end.
				 
				 
get_skill_level_from_ratelist(Ratelist)->
    RandNum=random:uniform(100),
	{_,_,Level}=lists:foldl(fun(Num,{Acc1,Acc2,Acc3})->
						if Acc1=/=0->
								{Acc1,Acc2,Acc3};
							true->
									if RandNum=<Num+Acc2->
											{1,Acc2,Acc3+1};
									true->
										{Acc1,Acc2+Num,Acc3+1}
									end
							end
							end, {0,0,0}, Ratelist),
	Level.

get_random_skill()->
	SkillInfo=pet_skill_book_db:get_skill_book_info(),
	if SkillInfo=:=[]->
		   nothing;
	   true->
			Skilllist=pet_skill_book_db:get_skilllist(SkillInfo),
			Ran=random:uniform(?RANSKILL)+1,
			SkillId=220000+Ran,
			case  lists:member(SkillId, Skilllist)  of
				true->
					SkillId;
				false->
					0
			end
	end.


	
get_skill_levelbat_from_ratelist(Ratelist,Num,Levellist)->
	if Num =< 0->
		   Levellist;
	   true->
		 Level= get_skill_level_from_ratelist(Ratelist),
		 get_skill_levelbat_from_ratelist(Ratelist,Num-1,[Level]++Levellist)
	end.

get_random_skill_bat(Num,Skilllist)->
	if Num=<0->
		  Skilllist;
	   true->
		   Skill=get_random_skill(),
		   get_random_skill_bat(Num-1,[Skill]++Skilllist)
	end.

get_pet_skill_book_level_and_skill([],_,Info,Num)->
	Info;
get_pet_skill_book_level_and_skill([Level|Levelllist],[Skill|Skilllist],Info,Num)->
	if Skill=:=0->
		   Level1=220001;
	   true->
		   Level1=Level
	end,
	get_pet_skill_book_level_and_skill(Levelllist,Skilllist,[#psb{skilllevel=Level1,skillid=Skill,slot=Num}]++Info,Num+1).
		   
		 
skill_book_copy(Slot,SkillSlot)->
	case pet_skill_book_db:get_pet_skill_info_by_store() of
		[]->
			nothing;
				%%io:format("@@@@@@@@@  no store skill~n",[]);
		Skillinfo->
			Skilllist=pet_skill_book_db:get_skill_info_from_store_term(Skillinfo),
			{Level,Skillid}=get_skillid_and_level(Skilllist,SkillSlot),
			if Slot=:=1->
				  Hasmoney= role_op:check_money(?MONEY_GOLD, ?COPYGOLD),
				  if not Hasmoney ->
						Error=?ERROR_PET_NOT_ENOUGH_MONEY,
				       Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  	   role_op:send_data_to_gate(Message);
					 true->
						 case skill_db:get_pet_skill_info(Skillid, Level) of
							 []->
								 nothing;
								 %io:format("@@@@@@@@  skillinfor is not lookup ~n",[]);
							 {_,_,_,_,{_Skillitem1,Skillitem2}}->
								 	case package_op:can_added_to_package_template_list([{Skillitem2,1}]) of
												true->
													role_op:auto_create_and_put(Skillitem2,1,petcopyskill),
													pet_skill_book_db:delete_pet_skill_info(),
													Message=pet_packet:encode_pet_skill_book_init_s2c(1,0,[]),
													role_op:send_data_to_gate(Message),
													role_op:money_change(?MONEY_GOLD, -?COPYGOLD, petcopyskill);
												_->
													nothing
										end
						 end
				  end;
			   true->
				   case package_op:get_iteminfo_in_package_slot(Slot) of
					   []->
						   nothing;
						   %io:format("@@@@@@@@@   item is not in package ~n",[]);
					   Iteminfo->
						   Itemid= get_template_id_from_iteminfo(Iteminfo),
						   case skill_db:get_pet_skill_info(Skillid, Level) of
							   []->
								   nothing;
								    %io:format("@@@@@@@@  skillinfor is not lookup ~n",[]);
							    {_,_,_,_,{Skillitem1,Skillitem2}}->
									case get_isbonded_from_iteminfo(Iteminfo) of
										?BOUND->
											if Itemid=:=?BOUNDBOOK->
														case package_op:can_added_to_package_template_list([{Skillitem2,1}]) of
															true->
																	role_op:consume_item(Iteminfo, 1),
																	pet_skill_book_db:delete_pet_skill_info(),
																	Message=pet_packet:encode_pet_skill_book_init_s2c(1,0,[]),
																	role_op:send_data_to_gate(Message),
																	role_op:auto_create_and_put(Skillitem2,1,petcopyskill);
																_->
																	nothing
														end;
											   true->
												 Error=?ERROR_PET_UP_RESET_NEEDS_NOEXIST,
											 Message=pet_packet:encode_pet_opt_error_s2c(Error),
				  							 role_op:send_data_to_gate(Message)
											end;
										_->
											if Itemid=:=?NBOUNDBOOK->
											 	case package_op:can_added_to_package_template_list([{Skillitem1,1}]) of
															true->
																	role_op:consume_item(Iteminfo, 1),
																	pet_skill_book_db:delete_pet_skill_info(),
																	Message=pet_packet:encode_pet_skill_book_init_s2c(1,0,[]),
																	role_op:send_data_to_gate(Message),
																	%io:format("@@@@@@@@@@@@@@@ Skillitem2 ~p~n",[Skillitem1]),
																	role_op:auto_create_and_put(Skillitem1,1,petcopyskill);
																_->
																	nothing
														end;
												true->
													nothing
												   %io:format("@@@@@@@@@@  item id is not exit  ~p~n",[Itemid])
											end
									end
						   end
				   end
			end
	end.
%%skilllevel=Skilllevel,skillid=220001,slot=0						 
get_skillid_and_level(Skillinfo,SkillSlot)->
	lists:foldl(fun({psb,Skilllevel,Skillid,Slot},{Acc1,Acc2})->
						if Acc1=/=0 ->
							   {Acc1,Acc2};
						   true->
								if Slot=:=SkillSlot->
									   {Skilllevel,Skillid};
								   true->
										   {0,0}		
								end
						end
					end, {0,0}, Skillinfo).
		   
	
	
	
	
	

%%
%% Local Functions
%%

