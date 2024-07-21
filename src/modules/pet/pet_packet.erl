%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_packet).

-compile(export_all).

-export([		
		handle/2,
		make_pet/32,
		make_pet/3,
		make_pet_xs/14,
		get_hp_xs/1,
		
		get_meleepower_xs/1,
		get_rangpower_xs/1,
		get_magicpower_xs/1,
		get_meleedefence_xs/1,
		get_rangedefence_xs/1,
		get_magicdefence_xs/1,
		encode_create_pet_s2c/1,
		encode_init_pets_s2c/3,
		encode_pet_opt_error_s2c/1,
		encode_pet_present_s2c/1,
		encode_pet_present_apply_s2c/1,
		encode_pet_delete_s2c/1,
		encode_pet_training_info_s2c/3,
		encode_pet_training_init_info_s2c/3,
		encode_pet_explore_info_s2c/5,
		encode_pet_explore_error_s2c/1,
		encode_pet_explore_gain_info_s2c/2,
		encode_pet_random_talent_s2c/4,
		encode_update_item_for_pet_s2c/2,	
		encode_pet_upgrade_quality_s2c/2,	
		encode_pet_upgrade_quality_up_s2c/3,
		encode_pet_qualification_result_s2c/3,
		encode_pet_growup_result_s2c/3,
		encode_pet_advance_update_s2c/2,
		encode_pet_talent_update_s2c/2,
		encode_pet_inheritance_s2c/0,
		encode_pet_auto_advance_result_s2c/5
		]).


-include("login_pb.hrl").
-include("data_struct.hrl").
-include("pet_struct.hrl").
-record(pet_item_mall,{keynum,protoid,playid,classtype,price,quality}).
handle(Message,RolePid)->
	RolePid ! {pet_base_msg,Message}.

encode_pet_inheritance_s2c()->
	login_pb:encode_pet_inheritance_s2c(#pet_inheritance_s2c{}).
encode_pet_xs_update_s2c(Xisui,PetId)->
	login_pb:encode_pet_xs_update_s2c(#pet_xs_update_s2c{change=Xisui,petid=PetId}).
encode_pet_talent_update_s2c(Petid,Talent)->
	login_pb:encode_pet_talent_update_s2c(#pet_talent_update_s2c{petid=Petid,talent=Talent}).
encode_pet_advance_update_s2c(Value,Petid)->
	login_pb:encode_pet_advance_update_s2c(#pet_advance_update_s2c{value=Value,petid=Petid}).
encode_pet_auto_advance_result_s2c(Money,PetId,Count,Result,Value)->
	login_pb:encode_pet_auto_advance_result_s2c(#pet_auto_advance_result_s2c{itemnum=Count,petid=PetId,money=Money,result=Result,value=Value}).
encode_pet_skill_book_init_s2c(Bound,Lucky,Books)->
	login_pb:encode_pet_skill_book_init_s2c(#pet_skill_book_init_s2c{bound=Bound, lucky=Lucky, books=Books}).
encode_pet_growup_result_s2c(Pid,Result,Growth)->
	login_pb:encode_pet_growup_result_s2c(#pet_growup_result_s2c{petid=Pid,result=Result,growth=Growth}).
encode_pet_evolution_growthvalue_s2c(Hp,Meleeattack,Rangeattack,Magicattack,Meleedefence,Rangedefence,Magicdefence)->
	login_pb:encode_pet_evolution_growthvalue_s2c(#pet_evolution_growthvalue_s2c{hp=Hp,meleeattack=Meleeattack,rangeattack=Rangeattack,magicattack=Magicattack,meleedefence=Meleedefence,rangedefence=Rangedefence,magicdefence=Magicdefence}).
encode_pet_shop_init_s2c(Remain_s,ShopInfo)->
	login_pb:encode_pet_shop_init_s2c(#pet_shop_init_s2c{remain_s = Remain_s,shops=ShopInfo}).
encode_create_pet_s2c(Pet)->
	login_pb:encode_create_pet_s2c(#create_pet_s2c{pet = Pet}).

encode_init_pets_s2c(Pets,MaxNum,Present)->
	login_pb:encode_init_pets_s2c(#init_pets_s2c{pets = Pets,max_pet_num = MaxNum,present_slot = Present}).

encode_pet_opt_error_s2c(Reason)->
	login_pb:encode_pet_opt_error_s2c(#pet_opt_error_s2c{reason=Reason}).

encode_pet_training_info_s2c(PetId,TotalTime,RemainTime)->
	login_pb:encode_pet_training_info_s2c(#pet_training_info_s2c{petid = PetId,totaltime = TotalTime,remaintime = RemainTime}).

encode_pet_training_init_info_s2c(PetId,TotalTime,RemainTime)->
	login_pb:encode_pet_training_init_info_s2c(#pet_training_init_info_s2c{petid = PetId,totaltime = TotalTime,remaintime = RemainTime}).

encode_pet_present_s2c(Pps)->
	%%login_pb:encode_pet_present_s2c(#pet_present_s2c{present_pets=Pps}).
nothing.

encode_pet_present_apply_s2c(Slot)->
	login_pb:encode_pet_present_apply_s2c(#pet_present_apply_s2c{delete_slot = Slot}). 

encode_pet_delete_s2c(PetId)->
	login_pb:encode_pet_delete_s2c(#pet_delete_s2c{petid = PetId}).



encode_pet_random_talent_s2c(Power,HitRate,Criticalrate,Stamina)->
	login_pb:encode_pet_random_talent_s2c(#pet_random_talent_s2c{power=Power,hitrate=HitRate,criticalrate=Criticalrate,stamina=Stamina}).


%%quality return message
encode_pet_upgrade_quality_s2c(Result,QualityValue)->
	login_pb:encode_pet_upgrade_quality_s2c(#pet_upgrade_quality_s2c{result = Result,value = QualityValue}).

encode_pet_upgrade_quality_up_s2c(Type,Result,QualityUpValue)->
	login_pb:encode_pet_upgrade_quality_up_s2c(#pet_upgrade_quality_up_s2c{type = Type,result = Result,value = QualityUpValue}).


encode_update_item_for_pet_s2c(PetId,ItemUpdates)->
	login_pb:encode_update_item_for_pet_s2c(#update_item_for_pet_s2c{petid = PetId,items = ItemUpdates}).

encode_pet_item_opt_result_s2c(Errno)->
	login_pb:encode_pet_item_opt_result_s2c(#pet_item_opt_result_s2c{errno = Errno}).
	
encode_update_pet_slot_num_s2c(SlotsNum)->
	login_pb:encode_update_pet_slot_num_s2c(#update_pet_slot_num_s2c{num = SlotsNum}).
encode_update_pet_skill_slot_s2c(PetId,SlotInfo)->
	login_pb:encode_update_pet_skill_slot_s2c(#update_pet_skill_slot_s2c{petid = PetId,slot = SlotInfo}).

encode_update_pet_skill_s2c(PetId,SkillInfo)->
	login_pb:encode_update_pet_skill_s2c(#update_pet_skill_s2c{petid = PetId,skills = SkillInfo}).


%%pet explore
encode_pet_explore_info_s2c(PetId,RemainTimes,SiteId,ExploreStyle,LeftTime)->
	login_pb:encode_pet_explore_info_s2c(#pet_explore_info_s2c{petid = PetId,remaintimes = RemainTimes,siteid = SiteId,explorestyle = ExploreStyle,lefttime = LeftTime}).

encode_pet_explore_error_s2c(Error)->
	login_pb:encode_pet_explore_error_s2c(#pet_explore_error_s2c{error = Error}).

encode_pet_explore_gain_info_s2c(PetId,ItemList)->
	login_pb:encode_pet_explore_gain_info_s2c(#pet_explore_gain_info_s2c{petid = PetId,gainitem = ItemList}).



encode_pet_learn_skill_cover_best_s2c(PetId,Slot,SkillId,OldLevel,NewLevel)->
	login_pb:encode_pet_learn_skill_cover_best_s2c(#pet_learn_skill_cover_best_s2c{petid = PetId,
																				   slot = Slot,
																				   skillid = SkillId,
																				   oldlevel = OldLevel,
																				   newlevel = NewLevel}).

%%pet explore storage
encode_explore_storage_info_s2c(Items)->
	login_pb:encode_explore_storage_info_s2c(#explore_storage_info_s2c{items = Items}).

encode_explore_storage_init_end_s2c()->
	login_pb:encode_explore_storage_init_end_s2c(#explore_storage_init_end_s2c{}).

encode_explore_storage_updateitem_s2c(UpdateItems)->
	login_pb:encode_explore_storage_updateitem_s2c(#explore_storage_updateitem_s2c{itemlist = UpdateItems}).

encode_explore_storage_additem_s2c(AddItems)->
	login_pb:encode_explore_storage_additem_s2c(#explore_storage_additem_s2c{items = AddItems}).

encode_explore_storage_delitem_s2c(Start,Length)->
	login_pb:encode_explore_storage_delitem_s2c(#explore_storage_delitem_s2c{start = Start,length = Length}).

encode_explore_storage_opt_s2c(Error)->
	login_pb:encode_explore_storage_opt_s2c(#explore_storage_opt_s2c{code = Error}).

encode_pet_qualification_result_s2c(Pid,Opt,Result)->
	login_pb:encode_pet_qualification_result_s2c(#pet_qualification_result_s2c{petid=Pid,qualificationValue=Opt,result=Result}).

make_pet(PetInfo,GmPetInfo,ItemsInfo)->
	#my_pet_info{
			petid = PetId,
			xs=Xs,			
			talent = Talent,
			skill=Skill,			
			quality_value = Quality_Value,			
			happinesseff = HappinessEff,
			talent_score = T_Gs,
			talent_sort = Gs_Sort,
			happiness = Happiness,
			quality_up_value = Quality_Up_Value,
			trade_lock = Trad_Lock,
			changenameflag = ChangeNameFlag,
			lucky=Lucky
			} = PetInfo,
	#gm_pet_info{
			id =PetId,
			master = RoleId,
			proto = Proto,
			level = Level,
			name = Name,
			gender = Gender,
			quality = Quality,
			class = Class,
			last_cast_time={0,0,0},
			path = [],
			state = State,
			posx = X,
			posy = Y,
			hitrate = Hitrate,		
			criticalrate = Criticalrate,
			criticaldamage = CriticalDestoryrate, 		
			fighting_force = Fighting_Force,
			icon = Icon,
			growth_value=Grouwth,%%开始添加属性信息《枫少》
			meleepower=Meleepower,
			rangepower=Rangepower,
			magicpower=Magicpower,
			meleedefence=Meleedefence,
			rangedefence=Rangedefence,
			magicdefence=Magicdefence,
			hp=Hp,
			dodge=Dodge,
			toughness=Tougness,
			meleeimu=Meleeimu,
			rangeimu=Rangeimu,
			magicimu=Magicimu,
			leveluptime_s=Leveltime,
			transform=Transform
			} = GmPetInfo,
	Pet_Items = lists:map(fun(ItemInfo)->pb_util:to_item_info(ItemInfo) end,ItemsInfo),
	PetTalent=lists:map(fun({Level,TalentId,Type})->{pt,Level,TalentId,Type} end, Talent),
	make_pet(PetId,Proto,Level,Name,Quality,Hitrate,Criticalrate,CriticalDestoryrate,Fighting_Force,Grouwth,Meleepower,
			    Rangepower,Magicpower,Meleedefence,Rangedefence,Magicdefence,Hp,Dodge,Tougness,Meleeimu,Rangeimu,Magicimu,Leveltime,Transform,PetTalent,
			 	Skill,Happiness,Class,State,Quality_Value,Xs,Lucky).

make_pet(Petid,Proto,Level,Name,Quality,Hitrate,Criticalrate,CriticalDestoryrate,Fighting_Force,Grouwth,Meleepower,
			    Rangepower,Magicpower,Meleedefence,Rangedefence,Magicdefence,Hp,Dodge,Tougness,Meleeimu,Rangeimu,Magicimu,Leveltime,Transform,Talent,
			 	Skilllist,Happiness,Class,State,Quality_Value,Xs,Lucky)->
	#p{
		petid = Petid,
		protoid = Proto,
		level = Level,
		name = Name,
		quality = Quality,
		hitrate = Hitrate,
		criticalrate = Criticalrate,
		happiness=Happiness,
		class_type = Class,
		state = State,
		quality_value = Quality_Value,
			growth_value=Grouwth,%%开始添加属性信息《枫少》
			meleepower=Meleepower,
			rangepower=Rangepower,
			magicpower=Magicpower,
			meleedefence=Meleedefence,
			rangedefence=Rangedefence,
			magicdefence=Magicdefence,
			hp=Hp,
			dodge=Dodge,
			criticaldestroyrate=CriticalDestoryrate,
			toughness=Tougness,
			meleeimu=Meleeimu,
			rangeimu=Rangeimu,
			magicimu=Magicimu,
			leveluptime_s=Leveltime,
			transform=Transform,
			talentlist=Talent,
			skilllist=make_pet_skill(Skilllist),
			xs=Xs,
			advlucky=Lucky,
			fighting_force = Fighting_Force
	}.

make_psll(Slot,Status)->
	#psll{slot = Slot,status = Status}.

make_psl(PetId,PsllInfo)->
	#psl{petid = PetId,slots = PsllInfo}.

make_psk(Slot,SkillID,Level)->
	#psk{slot = Slot,skillid = SkillID,level = Level}.

%%make_ps(PetId,SkillsInfo)->
%%	#ps{petid = PetId,skills = SkillsInfo}.

make_lti(ProtoId,Count)->
	#lti{protoid = ProtoId,item_count = Count}.

create_pet_shopinfo([],_,PetItemList)->
	PetItemList;
create_pet_shopinfo([PetItemInfo|PetItemInfoTail],Num,PetItemList)->
	Info=#ps{
		slot=Num,
		proto=element(#pet_item_mall.playid,PetItemInfo),
		price=element(#pet_item_mall.price,PetItemInfo),
		quality=element(#pet_item_mall.quality,PetItemInfo)
		},
	if Num=:=6->[Info|PetItemList];
	   true->
		create_pet_shopinfo(PetItemInfoTail,Num+1,[Info|PetItemList])
	end.

%%pet洗髓
make_pet_xs(Xshp,Basemagicpower,Baserangedefence,Xsmeleepower,Basemagicdefence,Xsmeleedefence,
					Basemeleepower,Xsrangepower,Basehpmax,Basemeleedefence,Xsrangedefence,Xsmagicpower,Baserangepower,Xsmagicdefence)->
				#pxs{
				xshpmax=Xshp,
				basemagicpower=Basemagicpower,
				baserangedefence=Baserangedefence,
				xsmeleepower=Xsmeleepower,
				basemagicdefence=Basemagicdefence,
				xsmeleedefence=Xsmeleedefence,
				basemeleepower=Basemeleepower,
				xsrangepower=Xsrangepower,
				basehpmax=Basehpmax,
				basemeleedefence=Basemeleedefence,
			   xsrangedefence=Xsrangedefence,
				xsmagicpower=Xsmagicpower,
				baserangepower=Baserangepower,
				xsmagicdefence=Xsmagicdefence
			   }.

%%生命洗髓
get_hp_xs(Info)->
	Hp=element(#pxs.xshpmax,Info),
	Hp.
%%近攻洗髓
get_meleepower_xs(Info)->
	Power=element(#pxs.xsmeleepower,Info),
	Power.
%%远攻洗髓
get_rangpower_xs(Info)->
	Power=element(#pxs.xsrangepower,Info),
	Power.
%%魔攻洗髓
get_magicpower_xs(Info)->
	Power=element(#pxs.xsmagicpower,Info),
	Power.
%%近防洗髓
get_meleedefence_xs(Info)->
	Defence=element(#pxs.xsmeleedefence,Info),
	Defence.
%%远防洗髓
get_rangedefence_xs(Info)->
	Defence=element(#pxs.xsrangedefence,Info),
	Defence.
%%魔防洗髓
get_magicdefence_xs(Info)->
	Defence=element(#pxs.xsmagicdefence,Info),
	Defence.

make_pet_skill(SkillList)->
	lists:map(fun({Slot,SId,Level})->
					  {psk,Slot,SId,Level} end, SkillList).

			




	
