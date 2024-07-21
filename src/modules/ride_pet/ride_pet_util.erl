%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-8-17
%% Description: TODO: Add description to ride_pet_util
-module(ride_pet_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([random_value_by_rate/1,system_bodcast/3,random_attr_by_rate/2]).


%% API Functions
%%
random_attr_by_rate(DropRateList,CanDropNum)->
	case CanDropNum of
		0->
			[];
		_->
			lists:foldl(fun(dummy,Acc)->
								[get_value(DropRateList,Acc)|Acc]
						end, [], lists:duplicate(CanDropNum, dummy))
	end.

get_value(DropRateList,Acc)->
	{AttrName,Value} = random_value_by_rate(DropRateList),
	case lists:keyfind(AttrName,1,Acc) of
		false ->
			{AttrName,Value};
		_->
			get_value(DropRateList,Acc)
	end.

%%return []/value
random_value_by_rate([])->
	[];

random_value_by_rate(RateList)->
	Sort_RateList = lists:keysort(2, RateList),
	RateSum = lists:foldl(fun({_,Rate},Acc)->
								Rate+Acc 
							end,0, Sort_RateList),
	RandomValue = random:uniform(RateSum),
	{ResultValue,_} = lists:foldl(fun({Value,Rate},{ResultValue,AccRate})->
										if
											ResultValue=/=[]->
												{ResultValue,AccRate};
											true->
												if 
													RandomValue =< Rate+AccRate->
														{Value,Rate+AccRate};
													true->
														{[],Rate+AccRate}
												end					
										end 
								end,{[],0}, Sort_RateList),
	ResultValue.

system_bodcast(SysId,RoleInfo,PetId)->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamPet = chat_packet:makeparam_by_equipid(PetId),
	MsgInfo = [ParamRole, ParamPet],
	system_chat_op:system_broadcast(SysId,MsgInfo).



