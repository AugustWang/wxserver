%%% -------------------------------------------------------------------
%%% 9������ȫ���״ο�Դ����
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(guild_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-compile(export_all).
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([member_online/3,member_levelup/3,create/4,set_leader/3,apply_guild/2,%%10月18日create/2改为create/4
		join_guild/2,kick_out/3,promotion/3,demotion/3,
			set_facility_rule/4,set_notice/3,depart/2,upgrade/3,
			upgrade_speedup/6,get_recruite_info/1,contribute/4,member_offline/2,get_applicationinfo/2,application_op/4,
			change_nickname/4,change_chatandvoicegroup/4,guild_disband/2]).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("guild_define.hrl").

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
%%SomeInfo={level,lineid}
member_online(Roleid,GuildId,SomeInfo)->
	global_util:call(?MODULE,{member_online,{Roleid,GuildId,SomeInfo}}).

member_levelup(Roleid,GuildId,NewLevel)->
	global_util:send(?MODULE, {member_levelup, {Roleid,GuildId,NewLevel}}).

member_change_fightforce(Roleid,GuildId,FightForce)->
	global_util:send(?MODULE, {member_change_fightforce, {Roleid,GuildId,FightForce}}).

%create(Roid,GuildObject)->
%	global_util:call(?MODULE,{create_guild, {Roid,GuildObject}}).

%%xiaowujia
create(Roid,GuildObject,Notice,Create_Level)->
	global_util:call(?MODULE,{create_guild, {Roid,GuildObject,Notice,Create_Level}}).

upgrade(GuildId,RoleId,FacilityId)->
	global_util:send(?MODULE, {upgrade,{GuildId,RoleId,FacilityId}}).

upgrade_speedup(GuildId,Roleid,Facilitieid,SpeedType,SpeedValue,ItemInfo)->
	global_util:call(?MODULE,{upgrade_speedup,{GuildId,Roleid,Facilitieid,SpeedType,SpeedValue,ItemInfo}}).
		
contribute(GuildId,RoleId,MoneyType,MoneyCount)->
	global_util:call(?MODULE,{contribute,{GuildId,RoleId,MoneyType,MoneyCount}}).
add_contribute(GuildId,RoleId,Contribute)->
	global_util:call(?MODULE,{add_contribute,{GuildId,RoleId,Contribute}}).
	
add_impeach(GuildId,RoleId,Notice)->
	global_util:call(?MODULE, {add_impeach,{GuildId,RoleId,Notice}}).
	

member_offline(Roid,Guildid)->
	global_util:send(?MODULE, {member_offline, {Roid,Guildid}}).
	
apply_guild(Roid,Guildid)->
	global_util:send(?MODULE, {apply_guild, {Roid,Guildid}}).

join_guild(Roid,Guildid)->
	global_util:send(?MODULE, {join_guild, {Roid,Guildid}}).

%get_guild_space_info_c2s(RoleId,GuildId)->
%	global_util:send(?MODULE, {get_guild_space_info_c2s, {RoleId,GuildId}}).
	
set_leader(GuildId,LeaderId,NewLeader)->
	global_util:send(?MODULE, {set_leader,{GuildId,LeaderId,NewLeader}}).

kick_out(GuildId,Roleid,KickRoleId)->
	global_util:send(?MODULE, {kick_out,{GuildId,Roleid,KickRoleId}}).
	
promotion(GuildId,Roleid,ProRoleid)->	
	global_util:send(?MODULE, {promotion,{GuildId,Roleid,ProRoleid}}).
	
demotion(GuildId,Roleid,DeRoleid)->	
	global_util:send(?MODULE, {demotion,{GuildId,Roleid,DeRoleid}}).	
	
set_facility_rule(GuildId,RoleId,Facilityid,Requirevalue)->
	global_util:send(?MODULE, {set_facility_rule,{GuildId,RoleId,Facilityid,Requirevalue}}).	
	
set_notice(GuildId,RoleId,Notice)->
	global_util:send(?MODULE, {set_notice,{GuildId,RoleId,Notice}}).	
	
depart(GuildId,RoleId)->	
	global_util:send(?MODULE, {depart,{GuildId,RoleId}}).	
	
get_recruite_info(RoleId)->
	global_util:send(?MODULE, {get_recruite_info,RoleId}).	

get_applicationinfo(RoleId,GuildId)->
	global_util:send(?MODULE, {get_applicationinfo,{RoleId,GuildId}}).

application_op(RoleId,LeaderId,GuildId,Reject)->
	global_util:send(?MODULE, {application_op,{RoleId,LeaderId,GuildId,Reject}}).

change_nickname(LeaderId,GuildId,RoleId,NickName)->
	global_util:send(?MODULE, {change_nickname,{LeaderId,GuildId,RoleId,NickName}}).

change_chatandvoicegroup(LeaderId,GuildId,ChatGroup,VoiceGroup)->
	global_util:send(?MODULE, {change_chatandvoicegroup,{LeaderId,GuildId,ChatGroup,VoiceGroup}}).

get_guild_log(RoleId,GuildId,Type)->
	global_util:send(?MODULE, {get_guild_log,{RoleId,GuildId,Type}}).

guild_disband(RoleId,GuildId)->
	global_util:call(?MODULE, {guild_disband,{RoleId,GuildId}}).

guild_get_shop_item(RoleId,GuildId,ShopType)->
	global_util:send(?MODULE, {guild_get_shop_item,{RoleId,GuildId,ShopType}}).

%%notice gen_server:call
guild_shop_buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney)->
	global_util:call(?MODULE,{guild_shop_buy_item,{RoleId,GuildId,ShopType,Id,Count,RoleMoney}}).

guild_get_treasure_item(RoleId,GuildId,ShopType)->
	global_util:send(?MODULE, {guild_get_treasure_item,{RoleId,GuildId,ShopType}}).

%%notice gen_server:call
guild_treasure_buy_item(RoleId,GuildId,ShopType,Id,Count,RoleMoney)->
	global_util:call(?MODULE,{guild_treasure_buy_item,{RoleId,GuildId,ShopType,Id,Count,RoleMoney}}).

%%check is guild treasure_transporting
check_is_guild_transport(GuildId)->
	global_util:call(?MODULE,{check_is_guild_transport,GuildId}).
	
treasure_transport_call_guild_help(GuildId,RoleId,GuildPosting,RoleName,LineId,MapId,RolePos)->
	global_util:send(?MODULE, {treasure_transport_call_guild_help,GuildId,RoleId,GuildPosting,RoleName,LineId,MapId,RolePos}).
	
start_guild_treasure_transport(RoleId,GuildId)->
	global_util:send(?MODULE, {start_guild_treasure_transport,RoleId,GuildId}).

guild_treasure_set_price(RoleId,GuildId,ShopType,Id,Price)->
	global_util:send(?MODULE, {guild_treasure_set_price,{RoleId,GuildId,ShopType,Id,Price}}).

publish_guild_quest(RoleId,GuildId)->
	global_util:send(?MODULE, {publish_guild_quest,{RoleId,GuildId}}).

can_get_premiums(GuildId)->
	global_util:call(?MODULE,{can_get_premiums,{GuildId}}).

get_guild_notice(RoleId,GuildId)->
	global_util:send(?MODULE, {get_guild_notice,{RoleId,GuildId}}).

get_members_pos(RoleId,GuildId)->
	global_util:send(?MODULE, {get_members_pos,{RoleId,GuildId}}).

clear_nickname(LeaderId,GuildId,RoleId)->
	global_util:send(?MODULE, {clear_nickname,{LeaderId,GuildId,RoleId}}).

change_map(RoleId,GuildId,NewLineId,NewMapId)->
	global_util:send(?MODULE, {change_map,{RoleId,GuildId,NewLineId,NewMapId}}).
	
send_to_guildmember_client(GuildIds,BinMsg) when is_list(GuildIds)->
	global_util:send(?MODULE, {send_ro_guildmember_client,{GuildIds,BinMsg}}).
	
send_to_guildmember_proc(GuildIds,Msg) when is_list(GuildIds) ->
	global_util:send(?MODULE, {send_to_guildmember_proc,{GuildIds,Msg}}).
	
notify_guild_battle_start(GuildIds)->
	global_util:send(?MODULE, {notify_guild_battle_start,GuildIds}).
	
notify_guild_battle_stop(BestGuild)->
	global_util:send(?MODULE, {notify_guild_battle_stop,BestGuild}).

notify_jszd_battle_stop()->
	global_util:send(?MODULE, {notify_jszd_battle_stop}).
	
add_guild_battle_score(GuildId,GbScore,Reason)->
	global_util:send(?MODULE, {add_guild_battle_score,GuildId,GbScore,Reason}).
	
notify_guild_lose_battle(Loser,Score,Battle)->
	global_util:send(?MODULE, {notify_guild_lose_battle,Loser,Score,Battle}).
	
check_and_cast_money(GuildId,Money,Reason)->
	global_util:call(?MODULE, {check_and_cast_money,{GuildId,Money,Reason}}).

check_and_add_money(GuildId,Money,Reason)->
	global_util:send(?MODULE, {check_and_add_money,{GuildId,Money,Reason}}).
	
change_rolename(GuildId,RoleId,NewName)->
	global_util:send(?MODULE, {change_rolename,{GuildId,RoleId,NewName}}).
	
get_guild_contribute_log(GuildId,RoleId)->
	global_util:send(?MODULE, {get_guild_contribute_log,{GuildId,RoleId}}).

get_impeach_info(GuildId,RoleId)->
	global_util:send(?MODULE, {get_impeach_info,{GuildId,RoleId}}).	
	
impeach_vote(GuildId,RoleId,Type)->
	global_util:send(?MODULE, {impeach_vote,{GuildId,RoleId,Type}}).	
	
gm_change_impeach_time(GuildId,Time_S)->
	global_util:send(?MODULE, {gm_change_impeach_time,{GuildId,Time_S}}).
	
gm_change_someone_offline(GuildId,NewOffline,RoleId)->
	global_util:send(?MODULE, {gm_change_someone_offline,{GuildId,NewOffline,RoleId}}).
	
get_guild_monster(RoleId,GuildId)->
	global_util:send(?MODULE, {get_guild_monster,{RoleId,GuildId}}).
	
change_smith_need_contribution({GuildId,NewContribution})->
	global_util:send(?MODULE, {change_smith_need_contribution,{GuildId,NewContribution}}).

change_guild_battle_limit({GuildId,NewLimit})->
	global_util:send(?MODULE, {change_guild_battle_limit,{GuildId,NewLimit}}).
	
on_killed_guild_monster(GuildId,RoleId,BeKiller)->
	global_util:send(?MODULE, {on_killed,{GuildId,RoleId,BeKiller}}).

	
get_guild_monster_info(GuildId)->
	global_util:call(?MODULE,{get_guild_monster_info,GuildId}).
	
upgrade_guild_monster(RoleId,GuildId,MonsterId)->
	global_util:send(?MODULE, {upgrade_guild_monster,RoleId,GuildId,MonsterId}).
	
check_can_call_monster(GuildId,MonsterId)->
	global_util:call(?MODULE, {check_can_call_monster,GuildId,MonsterId}).
	
callback_guild_monster(MonsterId,GuildId)->
	global_util:send(?MODULE, {callback_guild_monster,MonsterId,GuildId}).
	
notify_yhzq_start(GuildId,Camp,Node,ProcName,MapProc)->
	global_util:send(?MODULE, {notify_yhzq_start,{GuildId,Camp,Node,ProcName,MapProc}}).
	
notify_yhzq_end(GuildId)->
	global_util:send(?MODULE, {notify_yhzq_end,GuildId}).
	
gm_add_guild_score(GuildId,Value)->
	global_util:send(?MODULE,{gm_add_guild_score,GuildId,Value}).

clear_cd_by_gm(GuildId)->
	global_util:send(?MODULE, {clear_cd_by_gm,GuildId}).
	
get_guild_battle_wininfo(Battle)->
	global_util:call(?MODULE, {get_guild_battle_wininfo,Battle}).
		
notify_guild_have_guildbattle_right(GuildId)->
	global_util:call(?MODULE, {notify_guild_have_guildbattle_right,GuildId}).
%%
%%call 		
%%
guildbattle_check()->
	global_util:call(?MODULE,{guildbattle_check}).
	
get_top_guild(Top)->
	global_util:call(?MODULE,{get_top_guild,Top}).

leave_jszd_battle(GuildId)->%%2013.6.26[xiaowu]
	global_util:call(?MODULE,{leave_jszd_battle,GuildId}).
	
rename(GuildId,NewNameStr)->
	global_util:call(?MODULE,{rename,{GuildId,NewNameStr}}).
	
get_guild_name(GuildId)->
	global_util:call(?MODULE,{get_guild_name,GuildId}).

%%帮会仓库相关消息走guild节点
init_guild_package(GuildInfo,RoleId)->
	global_util:send(?MODULE, {init_guild_package,GuildInfo,RoleId}).
item_to_guild_package(ItemInfo,Count,RoleId)->
	global_util:send(?MODULE,{item_to_package,ItemInfo,Count,RoleId}).
take_out_item_from_guild_package(Slot,ItemId,Count,GuildId,RoleId)->
	global_util:send(?MODULE,{take_out_item,Slot,ItemId,Count,GuildId,RoleId}).
get_guild_storage_log(RoleId)->
	global_util:send(?MODULE,{guild_storage_log,RoleId}).

guild_package_item_apply(RoleId,GuildId,Count,ItemId,Slot)->
	global_util:send(?MODULE,{package_item_apply,RoleId,GuildId,Count,ItemId,Slot}).
guild_storage_apply_init(GuildId,RoleId)->
	global_util:send(?MODULE,{storage_apply_init,GuildId,RoleId}).
guild_storage_approve_apply(TRoleId,ItemId,GuildId,FRoleid)->
	global_util:send(?MODULE,{storage_approve_apply,TRoleId,ItemId,GuildId,FRoleid}).
%%拒绝申请
guild_storage_refuse_apply(TRoleId,ItemId,GuildId)->
	global_util:send(?MODULE,{storage_refuse_apply,TRoleId,ItemId,GuildId}).
%%拒绝所有申请
guild_storage_refuse_all_apply(GuildId)->
	global_util:send(?MODULE,{storage_refuse_all_apply,GuildId}).

guild_storage_distribute_item(ItemId,Count,ToRoleid,Slot,GuildId,FRole)->
	global_util:send(?MODULE,{storage_distribute_item,ItemId,Count,ToRoleid,Slot,GuildId,FRole}).

guild_storage_self_apply(GuildId,RoleId)->
	global_util:send(?MODULE,{storage_self_apply,GuildId,RoleId}).

guild_storage_cancel_apply(GuilId,RoleId,ItemId)->
	global_util:send(?MODULE,{storage_cancel_apply,GuilId,RoleId,ItemId}).

guild_storage_set_item_state(ItemId,ItemState,GuildId)->
	global_util:send(?MODULE,{package_set_item_state,ItemId,ItemState,GuildId}).

guild_storage_sort_items(GuildId)->
	global_util:send(?MODULE,{storage_sort_items,GuildId}).
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: start_link/1
%% Description: start server
%% --------------------------------------------------------------------
start_link(Args) ->
	slogger:msg("guildmgr start~n"),
	gen_server:start_link({local,?MODULE}, ?MODULE, Args, []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init(_Args) ->	
    slogger:msg("guildmgr init~n"),
	try    
    	guild_manager_op:load_from_db(),
    	erlang:send_after(?UPDATE_MEMBERINFO_TO_CLIENT_INTERVAL, self(), {check_update_memberinfo})
	catch
		E:R->
			slogger:msg("init E:~p R:~p S:~p \n",[E,R,erlang:get_stacktrace()])
	end,
	{ok, #state{}}.


handle_call({member_online,{Roleid,GuildId,SomeInfo}},_From, State) ->
    Reply = my_apply(guild_manager_handle,handle_member_online,[Roleid,GuildId,SomeInfo]),
    {reply, Reply, State};

%handle_call({create_guild, {Roleid,GuildObject}},_From, State) ->
 %   Reply = my_apply(guild_manager_handle,handle_create,[Roleid,GuildObject]),
  %  {reply, Reply, State};

%%xiaowujia
handle_call({create_guild, {Roleid,GuildObject,Notice,Create_Level}},_From, State) ->
    Reply = my_apply(guild_manager_handle,handle_create,[Roleid,GuildObject,Notice,Create_Level]),
    {reply, Reply, State};

%%加速
handle_call({upgrade_speedup,{GuildId,RoleId,FacilityId,SpeedType,SpeedValue,ItemInfo}},_From, State) ->
    Reply = my_apply(guild_manager_handle,handle_upgrade_speedup,[GuildId,RoleId,FacilityId,SpeedType,SpeedValue,ItemInfo]),
    {reply, Reply, State};
			
%%捐献		
handle_call({contribute,{GuildId,RoleId,MoneyType,MoneyCount}},_From,State)->
	Reply = my_apply(guild_manager_handle,handle_contribute,[GuildId,RoleId,MoneyType,MoneyCount]),
	{reply, Reply, State};

handle_call({guild_shop_buy_item,{RoleId,GuildId,ShopType,Id,Count,RoleMoney}},_From,State)->
	Reply = my_apply(guild_manager_handle,handle_guild_shop_buy_item,[RoleId,GuildId,ShopType,Id,Count,RoleMoney]),
	{reply, Reply, State};

handle_call({guild_treasure_buy_item,{RoleId,GuildId,ShopType,Id,Count,RoleMoney}},_From,State)->
	Reply = my_apply(guild_manager_handle,handle_guild_treasure_buy_item,[RoleId,GuildId,ShopType,Id,Count,RoleMoney]),
	{reply, Reply, State};

handle_call({can_get_premiums,{GuildId}},_From,State)->
	Reply = my_apply(guild_manager_handle,handle_can_get_premiums,[GuildId]),
	{reply, Reply, State};
	
handle_call({add_contribute,{GuildId,RoleId,Contribute}},_From,State)->	
	Reply = my_apply(guild_manager_handle,handle_add_contribute,[GuildId,RoleId,Contribute]),
	{reply, Reply, State};
	
handle_call({check_is_guild_transport,GuildId},_From,State)->	
	Reply = my_apply(guild_manager_op,check_is_guild_transport,[GuildId]),
	{reply, Reply, State};
	
handle_call({guildbattle_check},_From,State)->
	Reply = my_apply(guild_manager_op,guildbattle_check,[]),
	{reply, Reply, State};
	
handle_call({get_top_guild,Top},_From,State)->
	Reply = my_apply(guild_manager_op,get_top_guild,[Top]),
	{reply, Reply, State};

handle_call({leave_jszd_battle,GuildId},_From,State)->%%2013.6.26[xiaowu]
	Reply = my_apply(guild_manager_op,leave_jszd_battle,[GuildId]),
	{reply, Reply, State};

handle_call({check_and_cast_money,{GuildId,Money,Reason}},_From,State)->
	Reply = my_apply(guild_manager_op,check_and_cast_money,[GuildId,Money,Reason]),
	{reply, Reply, State};
	
handle_call({add_impeach,{GuildId,RoleId,Notice}},_From,State)->
	Reply = my_apply(guild_manager_op,add_impeach,[GuildId,RoleId,Notice]),
	{reply, Reply, State};
	
handle_call({rename,{GuildId,NewNameStr}},_From,State)->
	Reply = my_apply(guild_manager_op,rename,[GuildId,NewNameStr]),
	{reply, Reply, State};
	
handle_call({get_guild_name,GuildId},_From,State)->
	Reply = my_apply(guild_manager_op,get_guild_name,[GuildId]),
	{reply, Reply, State};
	
handle_call({get_guild_monster_info,GuildId},_From,State)->
	Reply = my_apply(guild_monster_op,get_guild_monster_info,[GuildId]),
	{reply, Reply, State};
	
handle_call({check_can_call_monster,GuildId,MonsterId},_From,State)->
	Reply = my_apply(guild_monster_op,check_can_call_monster,[GuildId,MonsterId]),
	{reply, Reply, State};
	
handle_call({guild_disband,{RoleId,GuildId}},_From,State)->
	Reply = my_apply(guild_manager_handle,handle_guild_disband,[RoleId,GuildId]),
	{reply, Reply, State};
	
handle_call({get_guild_battle_wininfo,Battle},_From,State)->
	Reply = my_apply(guild_manager_op,get_guild_battle_wininfo,[Battle]),
	{reply, Reply, State};
	
handle_call({notify_guild_have_guildbattle_right,GuildId},_From,State)->
	Reply = my_apply(guild_manager_op,notify_guild_have_guildbattle_right,[GuildId]),
	{reply, Reply, State};

handle_call(_Request,_From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({member_levelup, {Roleid,GuildId,NewLevel}}, State) ->
	my_apply(guild_manager_handle,handle_member_levelup,[Roleid,GuildId,NewLevel]),
	{noreply, State};

handle_info({member_change_fightforce, {Roleid,GuildId,FightForce}}, State) ->
	my_apply(guild_manager_handle,handle_member_change_fightforce,[Roleid,GuildId,FightForce]),
	{noreply, State};

%%禅让
handle_info({set_leader,{GuildId,LeaderId,NewLeader}}, State) ->
	my_apply(guild_manager_handle,handle_set_leader,[GuildId,LeaderId,NewLeader]),
	{noreply, State};

%%申请入帮
handle_info({apply_guild, {Roid,Guildid}},State)->
	my_apply(guild_manager_handle,handle_apply_guild,[Roid,Guildid]),
	{noreply, State};

%%加入帮会
handle_info({join_guild, {Roid,Guildid}},State)->
	my_apply(guild_manager_handle,handle_join_guild,[Guildid,Roid]),
	{noreply, State};

%%踢出帮会
handle_info({kick_out,{GuildId,Roleid,KickRoleId}},State)->
	my_apply(guild_manager_handle,handle_kick_out,[GuildId,Roleid,KickRoleId]),
	{noreply, State};

%%升职
handle_info({promotion,{GuildId,Roleid,ProRoleid}},State)->
	my_apply(guild_manager_handle,handle_promotion,[GuildId,Roleid,ProRoleid]),
	{noreply, State};

%%降级
handle_info({demotion,{GuildId,Roleid,DeRoleid}},State)->
	my_apply(guild_manager_handle,handle_demotion,[GuildId,Roleid,DeRoleid]),
	{noreply, State};

%%设置规则
handle_info({set_facility_rule,{GuildId,RoleId,Facilityid,Requirevalue}},State)->
	my_apply(guild_manager_handle,handle_set_facility_rule,[GuildId,RoleId,Facilityid,Requirevalue]),
	{noreply, State};	

%%设置公告
handle_info({set_notice,{GuildId,RoleId,Notice}},State)->
	my_apply(guild_manager_handle,handle_set_notice,[GuildId,RoleId,Notice]),
	{noreply, State};	

%%离开
handle_info({depart,{GuildId,RoleId}},State)->
	my_apply(guild_manager_handle,handle_depart,[GuildId,RoleId]),
	{noreply, State};		
	
%%招募		
handle_info({get_recruite_info,RoleId},State)->
	my_apply(guild_manager_handle,handle_get_recruite_info,[RoleId]),
	{noreply, State};

%%下线
handle_info({member_offline, {RoleId,Guildid}},State)->
	my_apply(guild_manager_handle,handle_member_offline,[RoleId,Guildid]),
	{noreply, State};	

%%升级			   
handle_info({upgrade,{GuildId,RoleId,FacilityId}},State)->
	my_apply(guild_manager_handle,handle_upgrade,[GuildId,RoleId,FacilityId]),
	{noreply, State};						     
		   			     	
handle_info({upgrade_timer},State)->
	my_apply(guild_facility_op,proc_upgrade_timer,[]),
	{noreply, State};	

%%获取申请人员信息
handle_info({get_applicationinfo,{RoleId,GuildId}},State)->
	my_apply(guild_manager_handle,handle_get_applicationinfo,[RoleId,GuildId]),
	{noreply, State};

%handle_info({get_guild_space_info_c2s, {RoleId,GuildId}},State)->
%	my_apply(guild_manager_handle,handle_get_guild_space_info_c2s,[RoleId,GuildId]),
%	{noreply, State};


%%处理申请
handle_info({application_op,{RoleId,LeaderId,GuildId,Reject}},State)->
	my_apply(guild_manager_handle,handle_application_op,[RoleId,LeaderId,GuildId,Reject]),
	{noreply, State};

handle_info({change_nickname,{LeaderId,GuildId,RoleId,NickName}},State)->
	my_apply(guild_manager_handle,handle_change_nickname,[LeaderId,GuildId,RoleId,NickName]),
	{noreply, State};

handle_info({change_chatandvoicegroup,{LeaderId,GuildId,ChatGroup,VoiceGroup}},State)->
	my_apply(guild_manager_handle,handle_change_chatandvoicegroup,[LeaderId,GuildId,ChatGroup,VoiceGroup]),
	{noreply, State};

%%获取日志
handle_info({get_guild_log,{RoleId,GuildId,Type}},State)->
	my_apply(guild_manager_handle,handle_get_guild_log,[RoleId,GuildId,Type]),
	{noreply, State};

handle_info({guild_get_shop_item,{RoleId,GuildId,ShopType}},State)->
	my_apply(guild_manager_handle,handle_guild_get_shop_item,[RoleId,GuildId,ShopType]),
	{noreply, State};

handle_info({guild_get_treasure_item,{RoleId,GuildId,ShopType}},State)->
	my_apply(guild_manager_handle,handle_guild_get_treasure_item,[RoleId,GuildId,ShopType]),
	{noreply, State};

handle_info({guild_treasure_set_price,{RoleId,GuildId,ShopType,Id,Price}},State)->
	my_apply(guild_manager_handle,handle_guild_treasure_set_price,[RoleId,GuildId,ShopType,Id,Price]),
	{noreply, State};

handle_info({publish_guild_quest,{RoleId,GuildId}},State)->
	my_apply(guild_manager_handle,handle_publish_guild_quest,[RoleId,GuildId]),
	{noreply, State};

handle_info({get_guild_notice,{RoleId,GuildId}},State)->
	my_apply(guild_manager_handle,handle_get_guild_notice,[RoleId,GuildId]),
	{noreply, State};
	
handle_info({treasure_transport_call_guild_help,GuildId,RoleId,GuildPosting,RoleName,LineId,MapId,RolePos},State)->
	my_apply(guild_manager_op,treasure_transport_call_guild_help,[GuildId,RoleId,GuildPosting,RoleName,LineId,MapId,RolePos]),
	{noreply, State};
	
handle_info({start_guild_treasure_transport,RoleId,GuildId},State)->
	my_apply(guild_manager_op,start_guild_treasure_transport,[RoleId,GuildId]),
	{noreply, State};

handle_info({get_members_pos,{RoleId,GuildId}},State)->
	my_apply(guild_manager_handle,handle_get_members_pos,[RoleId,GuildId]),
	{noreply, State};
	
handle_info({clear_nickname,{LeaderId,GuildId,RoleId}},State)->
	my_apply(guild_manager_handle,handle_clear_nickname,[LeaderId,GuildId,RoleId]),
	{noreply, State};

handle_info({change_map,{RoleId,GuildId,NewLineId,NewMapId}},State)->
	my_apply(guild_manager_handle,handle_change_map,[RoleId,GuildId,NewLineId,NewMapId]),
	{noreply, State};	
	
handle_info({check_update_memberinfo},State)->
	my_apply(guild_manager_op,sent_memberbinmsg_to_client,[]),
	erlang:send_after(?UPDATE_MEMBERINFO_TO_CLIENT_INTERVAL, self(), {check_update_memberinfo}),
	{noreply, State};
	
%%发送消息给帮会成员

handle_info({send_to_guildmember_client,{GuildIds,BinMsg}},State)->
	lists:foreach(fun(GuildId)->
				my_apply(guild_manager_op,broad_cast_to_guild_client,[GuildId,BinMsg]) 
			end,GuildIds),
	{noreply, State};
	
handle_info({send_to_guildmember_proc,{GuildIds,Msg}},State)->
	lists:foreach(fun(GuildId)->
			my_apply(guild_manager_op,broad_cast_to_guild_proc,[GuildId,Msg])
		end,GuildIds),	
	{noreply, State};
	
handle_info({notify_guild_battle_start,GuildIds},State)->
	my_apply(guild_manager_op,guild_battle_start,[GuildIds]),
	{noreply, State};
	
handle_info({notify_guild_battle_stop,BestGuild},State)->
	my_apply(guild_manager_op,guild_battle_stop,[BestGuild]),
	{noreply, State};

handle_info({notify_jszd_battle_stop},State)->
	my_apply(guild_manager_op,jszd_battle_stop,[]),
	{noreply, State};
	
handle_info({add_guild_battle_score,GuildId,GbScore,Battle},State)->
	my_apply(guild_manager_op,add_guild_battle_score,[GuildId,GbScore,Battle]),
	{noreply, State};
	
handle_info({notify_guild_lose_battle,Loser,Score,Battle},State)->
	my_apply(guild_manager_op,notify_guild_lose_battle,[Loser,Score,Battle]),
	{noreply, State};
		
handle_info({check_and_add_money,{GuildId,Money,Reason}},State)->
	my_apply(guild_manager_op,check_and_add_money,[GuildId,Money,Reason]),
	{noreply, State};
	
handle_info({guild_rank_sort_loop},State)->
	my_apply(guild_manager_op,guild_rank_sort_loop,[]),
	{noreply, State};
	
handle_info({change_rolename,{GuildId,RoleId,NewName}},State)->
	my_apply(guild_manager_op,change_rolename,[GuildId,RoleId,NewName]),
	{noreply, State};
	
%%

handle_info({get_guild_contribute_log,{GuildId,RoleId}},State)->
	my_apply(guild_manager_op,get_guild_contribute_log,[GuildId,RoleId]),
	{noreply, State};
	
handle_info({get_impeach_info,{GuildId,RoleId}},State)->
	my_apply(guild_impeach,get_impeach_info,[GuildId,RoleId]),
	{noreply, State};
	
handle_info({impeach_vote,{GuildId,RoleId,Type}},State)->
	my_apply(guild_impeach,impeach_vote,[GuildId,RoleId,Type]),
	{noreply, State};
	
handle_info({gm_change_impeach_time,{GuildId,Time_S}},State)->
	my_apply(guild_impeach,gm_change_impeach_time,[GuildId,Time_S]),
	{noreply, State};
	
handle_info({gm_change_someone_offline,{GuildId,NewOffline,RoleId}},State)->
	my_apply(guild_manager_op,gm_change_someone_offline,[GuildId,NewOffline,RoleId]),
	{noreply, State};
	
handle_info({get_guild_monster,{RoleId,GuildId}},State)->
	my_apply(guild_monster_op,get_guild_monster,[RoleId,GuildId]),
	{noreply, State};
	
handle_info({change_smith_need_contribution,{GuildId,NewContribution}},State)->
	my_apply(guild_facility_op,set_smith_need_contribution,[GuildId,NewContribution]),
	{noreply, State};

handle_info({change_guild_battle_limit,{GuildId,NewLimit}},State)->
	my_apply(guild_manager_op,change_guild_battle_limit,[GuildId,NewLimit]),
	{noreply, State};

handle_info({on_killed,{GuildId,RoleId,BeKiller}},State)->
	my_apply(guild_monster_op,on_killed,[GuildId,RoleId,BeKiller]),
	{noreply, State};

handle_info({upgrade_guild_monster,RoleId,GuildId,MonsterId},State)->
	my_apply(guild_monster_op,upgrade_guild_monster,[RoleId,GuildId,MonsterId]),
	{noreply, State};
	
handle_info({callback_guild_monster,MonsterId,GuildId},State)->
	my_apply(guild_monster_op,callback_guild_monster,[MonsterId,GuildId]),
	{noreply, State};
	
handle_info({notify_yhzq_start,{GuildId,Camp,Node,ProcName,MapProc}},State)->
	my_apply(guild_manager_op,notify_yhzq_start,[GuildId,Camp,Node,ProcName,MapProc]),
	{noreply, State};
	
handle_info({notify_yhzq_end,GuildId},State)->
	my_apply(guild_manager_op,notify_yhzq_end,[GuildId]),
	{noreply, State};
	
handle_info({gm_add_guild_score,GuildId,Value},State)->
	my_apply(guild_manager_op,gm_add_guild_score,[GuildId,Value]),
	{noreply, State};
	
handle_info({clear_cd_by_gm,GuildId},State)->
	my_apply(guild_monster_op,clear_cd_by_gm,[GuildId]),
	{noreply, State};

%%处理背包初始化
handle_info({init_guild_package,GuildInfo,RoleId},State)->
	Reply=my_apply(guild_package_op,init_guild_package,[GuildInfo,RoleId]),
	{noreply, State};

handle_info({item_to_package,ItemInfo,Count,RoleId},State)->
	Reply=my_apply(guild_package_op,guild_package_instore_item,[ItemInfo, Count,RoleId]),
	{noreply, State};

handle_info({take_out_item,Slot,ItemId,Count,GuildId,RoleId},State)->
	Reply=my_apply(guild_package_op,guild_storage_take_out_c2s,[Slot,ItemId,Count,GuildId,RoleId]),
	{noreply, State};

handle_info({guild_storage_log,RoleId},State)->
	Reply=my_apply(guild_package_op,send_to_guild_log,[RoleId]),
	{noreply, State};

handle_info({package_item_apply,RoleId,GuildId,Count,ItemId,Slot},State)->
	Reply=my_apply(guild_package_op,guild_package_item_apply,[RoleId,GuildId,Count,ItemId,Slot]),
	{noreply, State};

handle_info({storage_apply_init,GuildId,RoleId},State)->
	Reply=my_apply(guild_package_op,guild_storage_apply_init,[GuildId,RoleId]),
	{noreply, State};

handle_info({storage_approve_apply,TRoleId,ItemId,GuildId,FRoleid},State)->
	Reply=my_apply(guild_package_op,guild_storage_approve_apply,[TRoleId,ItemId,GuildId,FRoleid]),
	{noreply, State};

handle_info({storage_refuse_apply,TRoleId,ItemId,GuildId},State)->
	Reply=my_apply(guild_package_op,guild_storage_refuse_apply,[TRoleId,ItemId,GuildId]),
	{noreply, State};

handle_info({storage_refuse_all_apply,GuildId},State)->
	Reply=my_apply(guild_package_op,guild_storage_refuse_all_apply,[GuildId]),
	{noreply, State};

handle_info({storage_distribute_item,ItemId,Count,ToRoleid,Slot,GuildId,FRole},State)->
	Reply=my_apply(guild_package_op,guild_storage_distribute_item,[ItemId,Count,ToRoleid,Slot,GuildId,FRole]),
	{noreply, State};

handle_info({storage_self_apply,GuildId,RoleId},State)->
	Reply=my_apply(guild_package_op,guild_storage_self_apply,[GuildId,RoleId]),
	{noreply, State};

handle_info({storage_cancel_apply,GuilId,RoleId,ItemId},State)->
	Reply=my_apply(guild_package_op,guild_storage_cancel_apply,[GuilId,RoleId,ItemId]),
	{noreply, State};

handle_info({package_set_item_state,ItemId,ItemState,GuildId},State)->
	Reply=my_apply(guild_package_op,guild_storage_set_item_state,[ItemId,ItemState,GuildId]),
	{noreply, State};

handle_info({storage_sort_items,GuildId},State)->
	Reply=my_apply(guild_package_op,guild_storage_sort_items,[GuildId]),
	{noreply, State};

handle_info(Info, State) ->
	slogger:msg("guild_manager handle_info error:~p~n", [Info]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
	slogger:msg("~p~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State,_Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%% 						private
%% --------------------------------------------------------------------
my_apply(Mod,Func,Args)->
	try
		apply(Mod,Func,Args)
	catch 
		E:R->
		slogger:msg("guild_manager ~p ~p ~p ~p ~p ~n",[Func, Args,E,R,erlang:get_stacktrace()]),
		error
	end.