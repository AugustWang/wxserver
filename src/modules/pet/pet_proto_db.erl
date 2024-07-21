%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%
-module(pet_proto_db).

%% 
%% Include
%% 
-include("pet_def.hrl").

-define(PET_PROTO_ETS,pet_proto_ets).
-define(PET_ITEM,pet_item).
-define(PET_ATTR_TANSFORM,pet_attr_transform).

-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0,get_pet_item_info/1,get_pet_transform_by_quality/1]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_proto,record_info(fields,pet_proto),[],set),
	db_tools:create_table_disc(pet_attr_transform, record_info(fields,pet_attr_transform),[],set),
	db_tools:create_table_disc(pet_shop_info, record_info(fields,pet_shop_info), [],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_proto,proto},{pet_shop_info,proto},{pet_attr_transform,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_PROTO_ETS,[set,named_table]),
	ets:new(?PET_ITEM,[set,named_table]),%%宠物商店信息表《枫少》
	ets:new(?PET_ATTR_TANSFORM, [set,named_table]).
	

init()->
	db_operater_mod:init_ets(pet_proto, ?PET_PROTO_ETS,#pet_proto.protoid),
	db_operater_mod:init_ets(pet_item_mall, ?PET_ITEM,#pet_item_mall.keynum),%%宠物商店信息表《枫少》
	db_operater_mod:init_ets(pet_attr_transform, ?PET_ATTR_TANSFORM, #pet_attr_transform.quality).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Id)->
	case ets:lookup(?PET_PROTO_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%%	 return : Value | []
%%
get_name(ProtoInfo)->
	element(#pet_proto.name,ProtoInfo).


get_species(ProtoInfo)->
	element(#pet_proto.species,ProtoInfo).
%%
%%	 return : Value | []
%%
get_femina_rate(ProtoInfo)->
	element(#pet_proto.femina_rate,ProtoInfo).

%%
%%	 return : Value | []
%%
get_class(ProtoInfo)->
	element(#pet_proto.class,ProtoInfo).

%%
%%	 return : Value | []
%%
get_min_take_level(ProtoInfo)->
	element(#pet_proto.min_take_level,ProtoInfo).

%%
%%	 return : Value | []
%%
get_quality_to_growth(ProtoInfo)->
	element(#pet_proto.quality_to_growth,ProtoInfo).
	
%%
%%	 return : Value | []
%%							
get_born_abilities(ProtoInfo)->
	element(#pet_proto.born_abilities,ProtoInfo).
	
%%
%%	 return : Value | []
%%							
get_born_talents(ProtoInfo)->
	element(#pet_proto.born_talents,ProtoInfo).


%%
%%	 return : Value | []
%%
get_born_skills(ProtoInfo)->
	element(#pet_proto.born_skills,ProtoInfo).

%%
%% return : Value | []
%%
get_born_attr(ProtoInfo)->
	element(#pet_proto.born_attr,ProtoInfo).

%%
%% return : Value | []
%%
get_happiness_cast(ProtoInfo)->
	element(#pet_proto.happiness_cast,ProtoInfo).

%%
%% return : Value | []
%%
get_born_quality(ProtoInfo)->
	element(#pet_proto.born_quality,ProtoInfo).

%%
%% return : Value | []
%%
get_born_quality_up(ProtoInfo)->
	element(#pet_proto.born_quality_up,ProtoInfo).

%%
%% return : Value | []
%%
get_can_delete(ProtoInfo)->
	element(#pet_proto.can_delete,ProtoInfo).

%%
%% return : Value | []
%%
get_can_explore(ProtoInfo)->
	element(#pet_proto.can_explore,ProtoInfo).
		
get_pet_item_info(RandomList)->
	lists:map(fun(Num)->
					case ets:lookup(?PET_ITEM, Num) of
					 	[Object]->Object,
								  erlang:element(2,Object);
						_->[] end end, RandomList).

get_pet_proto_from_itemshop(ShopInfo)->
	#pet_item_mall{protoid=ProtoId}=ShopInfo,
	ProtoId.
ge_pet_classtype_from_itemshop(ShopInfo)->
	#pet_item_mall{classtype=Type}=ShopInfo,
	Type.

%%得到宠物转化率
get_pet_transform_by_quality(Quality_value)->
	try
		case ets:lookup(?PET_ATTR_TANSFORM, Quality_value) of
			[{_,{_,_,Transform}}]->
				Transform;
			[]->
				0;
			Error->
				0
		end
	catch
		_:_->
			io:format("miss quality transform~p~n",[Quality_value]),
			0
	end.

%%得到宠物商店信息，因为是一小时更新一次，所以世界在mnesia数据库读写
get_pet_shopinfo(RoleId)->
	case dal:read_rpc(pet_shop_info, RoleId) of
		{ok,[]}->
			[];
		{ok,[Info]}->
			Info;
		_->
			[]
	end.
write_pet_shopinfo_to_mnesia(ShopInfo)->
	{Time1,Time2}=calendar:now_to_local_time(now()),
	Secounds=calendar:time_to_seconds(Time2),
	RoleId=get(roleid),
	PetShopInfo=#pet_shop_info{roleid=RoleId,shopinfo=ShopInfo,time=Secounds},
	dal:write_rpc(PetShopInfo).

pet_shopinfo_update(ShopInfo,Time)->
	RoleId=get(roleid),
	PetShopInfo=#pet_shop_info{roleid=RoleId,shopinfo=ShopInfo,time=Time},
	dal:write_rpc(PetShopInfo).

get_pet_shopinfo_from_shopinfo(Info)->
	#pet_shop_info{shopinfo=ShopInfo}=Info,
	ShopInfo.
get_pet_shoptime_from_shopinfo(Info)->
	#pet_shop_info{time=Time}=Info,
	Time.