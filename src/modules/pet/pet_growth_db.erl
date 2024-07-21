%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-8-23
%% Description: TODO: Add description to pet_growth_db
-module(pet_growth_db).

%%
%% Include files
%%
-include("pet_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-define(PET_GROWTH_ETS,pet_growth_ets).
-define(PET_GROWTH_UP_ETS,pet_growth_up_ets).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-export([get_growth_value/1,get_growthup_info_from_db/1,get_need_itemlist_from_db/1,get_add_growthvalue/1]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_growth,record_info(fields,pet_growth),[],set),
	db_tools:create_table_disc(pet_up_growth,record_info(fields,pet_up_growth),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_growth,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_GROWTH_ETS,[set,named_table]),
	ets:new(?PET_GROWTH_UP_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(pet_growth, ?PET_GROWTH_ETS,#pet_growth.quality),
	db_operater_mod:init_ets(pet_up_growth, ?PET_GROWTH_UP_ETS, #pet_up_growth.growth).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Id)->
	case ets:lookup(?PET_GROWTH_ETS,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

%%
%%	 return : Value | []
%%
get_growth(Info)->
	%element(#pet_growth.growth,Info),%%瀹犵墿鎴愰暱锛堟灚灏戯級
RandomList=element(#pet_growth.growth,Info),
	MaxRate = lists:foldl(fun(ItemRate,LastRate)->
						LastRate +element(2,ItemRate)
				end, 0, RandomList),
	RandomV = random:uniform(MaxRate),
	{Value,_} = lists:foldl(fun({{X1,X2},RateTmp},{Value,LastRate})->
						if
							Value=/= []->
								{Value,0};
							true->
								if
									LastRate+RateTmp >= RandomV->
										%{X1 + (RandomV rem (25-X1+1)),0};
											{X1,0};
									true->
										{[],LastRate+RateTmp}
								end
						end
				end, {[],0}, RandomList),
	Value.

get_adapt_growth(Quality_Value)->
	ets:foldl(fun({_,Info},Acc)->
				if  element(#pet_growth.quality,Info)=:=Quality_Value ->
						get_growth(Info);
				true->
						Acc
				end
			end,0,?PET_GROWTH_ETS).

get_growth_value(Quality_Value)-> 
	ets:foldl(fun({Quality,{pet_growth,_,[{{A,B},_}]}},{Acc1,Acc2})->
					  if Quality_Value=:=Quality->
							 {A,B};
						 true->
							 {Acc1,Acc2}
					  end
			  end, {0,0}, ?PET_GROWTH_ETS).
%%
%% Local Functions
%%
get_growthup_info_from_db(Growth)->
	try
		case ets:lookup(?PET_GROWTH_UP_ETS, Growth) of
			[{_,Object}]->
				Object;
			_->
				[]
		end
	catch
		_:_->
			io:format("get growthup info error~n",[]),
			[]
	end.

get_need_itemlist_from_db(UpInfo)->
	NeedItem=erlang:element(#pet_up_growth.needitem, UpInfo),
	NeedItem.
get_add_growthvalue(UpInfo)->
	ValueList=get_growthvalue_from_db(UpInfo),
	NewValue=pet_quality_op:random_value_by_rate(0,0,ValueList),
	if NewValue=<0->
		   0;
	   NewValue>=1->
		   NewValue
	end.
get_growthvalue_from_db(UpInfo)->
	Value=erlang:element(#pet_up_growth.ratevalue,UpInfo),
	Value.
	
	


