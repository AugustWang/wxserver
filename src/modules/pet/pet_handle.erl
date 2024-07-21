%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("pet_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_define.hrl").
-include("login_pb.hrl").
-include("little_garden.hrl").

%%宠物元宝购买技能slot
process_base_message(#pet_unlock_skill_c2s{petid=PetId,slot=Slot})->
	pet_skill_op:pet_buy_skill_slot(Slot, PetId);

%%宠物遗忘技能
process_base_message(#pet_forget_skill_c2s{petid=PetId,slot=Slot,skillid=SkillId})->
	pet_skill_op:pet_forget_skill(Slot, PetId,SkillId);
%%宠物继承
process_base_message(#pet_inheritance_c2s{mainpet=MPetid,secondpet=Petid})->
	pet_inherit_op:inherit_c2s(MPetid,Petid);
%%宠物洗髓
process_base_message(#pet_xs_c2s{petid=Petid,usegold=Type})->
	pet_xisui_op:pet_xisui_init(Petid,Type);
%%宠物天赋
process_base_message(#pet_talent_levelup_c2s{petid=Petid,id=Type})->
	pet_talent_op:pet_talent_upgrade(Petid,Type);
%%宠物进阶
process_base_message(#pet_advance_c2s{petid=Petid})->
	pet_advanced_op:pet_advance(Petid);
%%宠物自动进阶
process_base_message(#pet_auto_advance_c2s{petid=PetId})->
	pet_advanced_op:pet_advanced_auto_init(PetId);
%%宠物技能书抄写
process_base_message(#pet_get_skill_book_c2s{usegold=Usegold, slot=Slot})->
	pet_skill_book:skill_book_copy(Usegold, Slot);
%%宠物技能刷新
process_base_message(#pet_skill_book_refresh_c2s{type=Type, moneytype=Moneytype})->
	pet_skill_book:pet_skill_book(Type, Moneytype);
%%宠物成长
process_base_message(#pet_evolution_growthvalue_c2s{petid=Petid})->
	pet_growth_up:pet_growth_s2c(Petid);
process_base_message(#pet_growup_c2s{petid=Petid,needitemslot=Slot})->
	pet_growth_up:pet_growth_up(Petid,Slot);
%%宠物加速升级
process_base_message(#pet_speed_levelup_c2s{petid=Petid})->
	pet_op:pet_addspeed_levelup(Petid);
%%商城购买宠物
process_base_message(#pet_shop_buy_c2s{slot=Slot})->
	pet_op:get_petproto_id(Slot);
%%初始化宠物商城
process_base_message(#pet_shop_init_c2s{type=Type})->
	pet_op:get_pet_shop_item_list(Type);

%%使用宠物蛋<枫少>
process_base_message(#use_pet_egg_ext_c2s{type=Type, slot=Slot, proto=Proto})->
	role_op:use_pet_egg_ext(Type,Slot,Proto);

process_base_message(#pet_move_c2s{petid = PetId,posx = PosX,posy = PosY,path=Path,time = Time})->
	pet_op:pet_move(PetId,{PosX,PosY},Path,Time);

process_base_message(#pet_stop_move_c2s{petid = PetId,posx = PosX,posy = PosY,time = Time})->
	pet_op:pet_stop_move(PetId,{PosX,PosY},Time);

process_base_message(#pet_attack_c2s{petid = PetId,skillid = Skill,creatureid = Target})->
	pet_op:pet_attack(PetId,Skill,Target);

process_base_message(#summon_pet_c2s{type = Type,petid = PetId})->
	handle_summon_pet_c2s(Type,PetId);

process_base_message(#pet_feed_c2s{petid = PetId,slot = ItemSlot})->
	item_feed_pet:handle_use_item(PetId,ItemSlot);

process_base_message(#pet_swap_slot_c2s{petid = PetId,slot=Slot})->
	pet_op:swap_slot(PetId,Slot);

process_base_message(#pet_start_training_c2s{petid = PetId,totaltime = TotalTime,type = Type})->
	pet_training:pet_training_start(PetId,TotalTime,Type);

process_base_message(#pet_stop_training_c2s{petid = PetId})->
	pet_training:pet_training_stop(PetId);

process_base_message(#pet_speedup_training_c2s{petid = PetId,speeduptime = Time})->
	pet_training:pet_training_speedup(PetId,Time);

process_base_message(#pet_rename_c2s{petid = PetId,newname = NewName,slot = ItemSlot,type = Type})->
	handle_pet_rename_c2s(PetId,NewName,ItemSlot,Type);

process_base_message(#pet_present_apply_c2s{slot = Slot})->
	nothing;

process_base_message(#pet_learn_skill_c2s{petid = PetId,slot = Slot})->
	item_skill_book:handle_learn_skill_with_book(PetId, Slot);

process_base_message(#pet_forget_skill_c2s{petid = PetId,skillid = SkillId,slot=Slot})->
	nothing;


%% pet quality upgrade 
%process_base_message(#pet_upgrade_quality_c2s{petid = PetId,needs = Needs,protect = Protect})->
	%pet_quality_op:pet_upgrade_quality(PetId,Needs,Protect);
process_base_message(#pet_qualification_c2s{petid = PetId,opt = Needs,useprotect = Protect,luckystonenum=LuckNum,luckystonesolt=LuckSolt})->
	pet_quality_op:pet_upgrade_quality(PetId,Needs,Protect,LuckNum,LuckSolt);

process_base_message(#pet_upgrade_quality_up_c2s{petid = PetId,type = Type,needs = Needs})->
	pet_quality_op:pet_upgrade_quality_up(PetId,Type,Needs);

%%pet add attr point
process_base_message(#pet_add_attr_c2s{petid = PetId,power_add = PowerPoint,hitrate_add = HitratePoint,criticalrate_add = CriticalratePoint,stamina_add = StaminaPoint})->
	pet_add_attr_op:pet_add_attr(PetId,PowerPoint,HitratePoint,CriticalratePoint,StaminaPoint);

process_base_message(#pet_wash_attr_c2s{petid = PetId,type = Type})->
	pet_add_attr_op:wash_pet_attr_point(Type,PetId);


process_base_message(#equip_item_for_pet_c2s{petid = PetId,slot = Slot})->
	handle_pet_item_equip(PetId,Slot);

process_base_message(#unequip_item_for_pet_c2s{petid = PetId,slot = Slot})->
	nothing;

process_base_message(Message = #pet_change_talent_c2s{})->
	pet_talent_op:process_message(Message);

process_base_message(Message = #pet_random_talent_c2s{})->
	pet_talent_op:process_message(Message);

process_base_message(Message = #pet_evolution_c2s{})->
	pet_evolution:process_message(Message);

process_base_message(#pet_skill_slot_lock_c2s{petid =PetId,slot = Slot,status = Status})->
	pet_skill_op:change_skill_slot_status(PetId,Slot,Status);

%%pet explore 						
process_base_message(#pet_explore_info_c2s{petid = PetId})->
	pet_explore_op:request_pet_explore_info(PetId);

process_base_message(#pet_explore_start_c2s{petid = PetId,explorestyle = ExploreStyle,siteid = SiteId,lucky =Lucky})->
	pet_explore_op:pet_explore_start(PetId,ExploreStyle,SiteId,Lucky);
	
process_base_message(#pet_explore_speedup_c2s{petid = PetId})->
	pet_explore_op:speedup_explore(PetId);

process_base_message(#pet_explore_stop_c2s{petid = PetId})->
	pet_explore_op:pet_explore_stop(PetId);

process_base_message(#buy_pet_slot_c2s{})->
	pet_op:buy_pet_slot();

%%pet explore storage 
process_base_message(#explore_storage_init_c2s{})->
	explore_storage_op:explore_storage_init();
process_base_message(#explore_storage_getitem_c2s{slot = Slot,itemsign = Sign})->
	explore_storage_op:explore_storage_getitem(Slot,Sign);
process_base_message(#explore_storage_getallitems_c2s{})->
	explore_storage_op:explore_storage_getallitems();

process_base_message(UnknownMsg)->
	slogger:msg("~p unknown pet base msg ~p ~n",[?MODULE,UnknownMsg]).


handle_summon_pet_c2s(Type,PetId)->
	case Type of
		?PET_OPT_CALLBACK->
			pet_op:call_back(PetId);
		?PET_OPT_CALLOUT->
			pet_op:call_out(PetId);
		?PET_OPT_DELETE->
			pet_op:delete_pet(PetId,true);
		?PET_OPT_RIDING->
			%%pet_op:ride_pet(PetId);
			nothing;
		?PET_OPT_DISMOUNT->
			pet_op:dismount_pet(PetId);
		_->
			todo
	end.


handle_pet_rename_c2s(PetId,NewName,ItemSlot,Type)->
	case senswords:word_is_sensitive(NewName) or (length(NewName) > ?MAX_PETNAME_LEN) of
		true->
			Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_NAME),
			role_op:send_data_to_gate(Msg);
		false->
			case Type of
				?USE_ITEM_RENAME->
					%case package_op:get_iteminfo_in_package_slot(ItemSlot) of
					%	[]->
					%		nothing;
					%	ItemInfo->
						%	case get_class_from_iteminfo(ItemInfo) of
						%		?ITEM_TYPE_PET_RENAME->
									pet_op:pet_rename(PetId,NewName);
						%			role_op:consume_item(ItemInfo,1);
						%		_->
						%			nothing
					%		end
					%end;
				_->
					case role_op:check_money(?MONEY_GOLD, ?PET_RENAME_GOLD) of
						true->
							role_op:money_change(?MONEY_GOLD, 0-?PET_RENAME_GOLD, lost_pet_rename),
							pet_op:pet_rename(PetId,NewName);
						_->
							Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_LESS_GOLD),
							role_op:send_data_to_gate(Msg)
					end
			end
	end.
						
						
handle_pet_item_equip(PetId,Slot)->
	case package_op:where_slot(Slot) of
		package->
			pet_op:proc_pet_item_equip(equip,PetId,Slot);
		pet_body->
			pet_op:proc_pet_item_equip(unequip,PetId,Slot);
		_->
			nothing
	end.


												