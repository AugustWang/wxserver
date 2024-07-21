%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: MacX
%% Created: 2011-3-20
%% Description: TODO: Add description to autoname_op
-module(autoname_op).

%%
%% Include files
%%
-define(NAME_1,1).
-define(NAME_2,2).
-define(LOOP_COUNT,10).
%%
%% Exported Functions
%%
-export([init_autoname_s2c/0,create_autoname_loop/2,create_role/2]).
-include("mnesia_table_def.hrl").
-include("base_define.hrl").
%%
%% API Functions
%%
init_autoname_s2c()->
	case get(autoname) of
		?ERLNULL->
			{create_autoname_loop(?NAME_1,?LOOP_COUNT),create_autoname_loop(?NAME_2,?LOOP_COUNT)};
		[]->
			{create_autoname_loop(?NAME_1,?LOOP_COUNT),create_autoname_loop(?NAME_2,?LOOP_COUNT)};
		{Gn,Bn}->
			{Gn,Bn}
	end.

create_autoname_loop(Gender,N) when N=:=0->
	AutoName = create_autoname(Gender),
	AutoName;

create_autoname_loop(Gender,N) when N>0->
	AutoName = create_autoname(Gender),
	case autoname_db:get_autoname_used(AutoName) of
		{ok,[]} -> AutoName;
		{ok,_}->create_autoname_loop(Gender,N-1)
	end.

create_autoname(Gender)->
	Random = random:uniform(10),
	case Random of
		1-> NameType = ?NAME_1;
		_-> NameType = ?NAME_2
	end,
	case autoname_db:get_autoname_info(NameType) of
		[]->[];
		{_,Id,LastName,FirstInfo}->
			if
				NameType=:=?NAME_1->
					create_zang_name({Id,LastName,FirstInfo},Gender);
				true->
					create_han_name({Id,LastName,FirstInfo},Gender)
			end
	end.

create_zang_name(Info,Gender)->
	{_Id,LastName,{Female,Male}} = Info,
	LN_Len = erlang:length(LastName),
	FN_Female_Len = erlang:length(Female),
	FN_Male_Len = erlang:length(Male),
	LN_Random = random:uniform(LN_Len),
	FN_Female_Random = random:uniform(FN_Female_Len),
	FN_Male_Random = random:uniform(FN_Male_Len),
	if 
		Gender=:=?NAME_1->
			list_to_binary(binary_to_list(lists:nth(LN_Random, LastName)) ++ binary_to_list(lists:nth(FN_Female_Random, Female)));
		Gender=:=?NAME_2->
			list_to_binary(binary_to_list(lists:nth(LN_Random, LastName)) ++ binary_to_list(lists:nth(FN_Male_Random, Male)));
		true->
			gender_error
	end.

create_han_name(Info,Gender)->
	{_Id,LastName,{[{Female1,Female2}],[{Male1,Male2}]}} = Info,
	LN_Len = erlang:length(LastName),
	FN_Female1_Len = erlang:length(Female1),
	FN_Female2_Len = erlang:length(Female2),
	FN_Male1_Len = erlang:length(Male1),
	FN_Male2_Len = erlang:length(Male2),
	LN_Random = random:uniform(LN_Len),
	FN_Female1_Random = random:uniform(FN_Female1_Len),
	FN_Female2_Random = random:uniform(FN_Female2_Len),
	FN_Male1_Random = random:uniform(FN_Male1_Len),
	FN_Male2_Random = random:uniform(FN_Male2_Len),
	Random = random:uniform(10000),
	if 
		Gender=:=?NAME_1->
			case Random rem 2 of
				0-> 
					LN = binary_to_list(lists:nth(LN_Random, LastName)),
					FN1 = binary_to_list(lists:nth(FN_Female1_Random, Female1)),
					FN2 = binary_to_list(lists:nth(FN_Female2_Random, Female2));
				1-> 
					LN = binary_to_list(lists:nth(LN_Random, LastName)),
					FN1 = binary_to_list(lists:nth(FN_Female2_Random, Female2)),
					FN2 = binary_to_list(lists:nth(FN_Female1_Random, Female1))
			end,
			if
				erlang:length(FN1)>3->
					list_to_binary(LN ++ FN1);
				erlang:length(FN2)>3->
					list_to_binary(LN ++ FN2);
				true->
					list_to_binary(LN ++ FN1 ++ FN2)
			end;
		Gender=:=?NAME_2->
			case Random rem 2 of
				0->
					LN = binary_to_list(lists:nth(LN_Random, LastName)),
					FN1 = binary_to_list(lists:nth(FN_Male1_Random, Male1)),
					FN2 = binary_to_list(lists:nth(FN_Male2_Random, Male2));
				1->
					LN = binary_to_list(lists:nth(LN_Random, LastName)),
					FN1 = binary_to_list(lists:nth(FN_Male2_Random, Male2)),
					FN2 = binary_to_list(lists:nth(FN_Male1_Random, Male1))
			end,
			if
				erlang:length(FN1)>3->
					list_to_binary(LN ++ FN1);
				erlang:length(FN2)>3->
					list_to_binary(LN ++ FN2);
				true->
					list_to_binary(LN ++ FN1 ++ FN2)
			end;
		true->
			gender_error
	end.
	
create_role(RoleName,RoleId)->
	autoname_db:sync_update_autoname_used_to_mnesia({list_to_binary(RoleName),RoleId,[]}).
	
%%
%% Local Functions
%%

