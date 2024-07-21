%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% -------------------------------------------------------------------
%%% Author  : xiaodya
%%% Description :
%%%
%%% Created : 2010-11-4
%%% -------------------------------------------------------------------
-module(mall_client).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-compile(export_all).

%% --------------------------------------------------------------------
%% External exports

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {socket,addr,port,role_info, map_info, client_config}).
-record(client_config, {life_time, user_name, user_password, server_addr, server_port,lineid}).
-include("login_pb.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("attr_keyvalue_define.hrl").
-include("data_struct.hrl").

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

connect(Address,Port)->
	io:format("~p connect~n",[Address]),
	gs_rpc:cast(node(), ?MODULE, {connect,Address,Port}).

mall_item_list(Ntype)->
	Term = #mall_item_list_c2s{ntype=Ntype},
	Binary = login_pb:encode_mall_item_list_c2s(Term),
	sendtoserver(Binary).

mall_item_list2(Ntype2)->
	Term = #mall_item_list_special_c2s{ntype2=Ntype2},
	Binary = login_pb:encode_mall_item_list_special_c2s(Term),
	sendtoserver(Binary).

mall_item_list3(Ntype)->
	Term = #mall_item_list_sales_c2s{ntype=Ntype},
	Binary = login_pb:encode_mall_item_list_sales_c2s(Term),
	sendtoserver(Binary).	

buy_mall_item(Id,Count,Price)->
	Term = #buy_mall_item_c2s{mitemid=Id,count=Count,price={ip,2,Price}},
	Binary = login_pb:encode_buy_mall_item_c2s(Term),
	sendtoserver(Binary).

myfriends()->
	Term = #myfriends_c2s{ntype=0},
	Binary = login_pb:encode_myfriends_c2s(Term),
	sendtoserver(Binary).

add_friend(Name)->
	Term = #add_friend_c2s{fn=Name},
	Binary = login_pb:encode_add_friend_c2s(Term),
	sendtoserver(Binary).

delete_friend(Name)->
	Term = #delete_friend_c2s{fn=Name},
	Binary = login_pb:encode_delete_friend_c2s(Term),
	sendtoserver(Binary).

detail_friend(Name)->
	Term = #detail_friend_c2s{fn=Name},
	Binary = login_pb:encode_detail_friend_c2s(Term),
	sendtoserver(Binary).

position_friend(Name)->
	Term = #position_friend_c2s{fn=Name},
	Binary = login_pb:encode_position_friend_c2s(Term),
	sendtoserver(Binary).

equipment_riseup(Equip,Rise,Protect)->
	Term = #equipment_riseup_c2s{equipment=Equip,riseup=Rise,protect=Protect},
	Binary = login_pb:encode_equipment_riseup_c2s(Term),
	sendtoserver(Binary).

equipment_sock(Equip,Sock)->
	Term = #equipment_sock_c2s{equipment=Equip,sock=Sock},
	Binary = login_pb:encode_equipment_sock_c2s(Term),
	sendtoserver(Binary).

equipment_inlay(Equip,Inlay,SockNum)->
	Term = #equipment_inlay_c2s{equipment=Equip,inlay=Inlay,socknum=SockNum},
	Binary = login_pb:encode_equipment_inlay_c2s(Term),
	sendtoserver(Binary).

equipment_stone_remove(Equip,Remove,SockNum)->
	Term = #equipment_stone_remove_c2s{equipment=Equip,remove=Remove,socknum=SockNum},
	Binary = login_pb:encode_equipment_stone_remove_c2s(Term),
	sendtoserver(Binary).

equipment_stonemix(Stone)->
	Term = #equipment_stonemix_single_c2s{stonelist=Stone},
	Binary = login_pb:encode_equipment_stonemix_single_c2s(Term),
	sendtoserver(Binary).

%%achieve_open()->%%@@wb
%%	Term = #achieve_open_c2s{},
%%	Binary = login_pb:encode_achieve_open_c2s(Term),
%%	sendtoserver(Binary).

%achieve_reward(Chapter,Part)->
%	Term = #achieve_reward_c2s{chapter=Chapter,part=Part},
%	Binary = login_pb:encode_achieve_reward_c2s(Term),
%	sendtoserver(Binary).

achieve_reward(Id)->
	Term = #achieve_reward_c2s{id=Id},
	Binary = login_pb:encode_achieve_reward_c2s(Term),
	sendtoserver(Binary).

loop_tower_enter(Layer,Enter,Convey)->
	Term = #loop_tower_enter_c2s{layer=Layer,enter=Enter,convey=Convey},
	Binary = login_pb:encode_loop_tower_enter_c2s(Term),
	sendtoserver(Binary).

loop_tower_challenge(Type)->
	Term = #loop_tower_challenge_c2s{type=Type},
	Binary = login_pb:encode_loop_tower_challenge_c2s(Term),
	sendtoserver(Binary).

loop_tower_reward(Bonus)->
	Term = #loop_tower_reward_c2s{bonus=Bonus},
	Binary = login_pb:encode_loop_tower_reward_c2s(Term),
	sendtoserver(Binary).

loop_tower_challenge_again(Type,Again)->
	Term = #loop_tower_challenge_again_c2s{type=Type,again=Again},
	Binary = login_pb:encode_loop_tower_challenge_again_c2s(Term),
	sendtoserver(Binary).

loop_tower_master(Master)->
	Term = #loop_tower_masters_c2s{master=Master},
	Binary = login_pb:encode_loop_tower_masters_c2s(Term),
	sendtoserver(Binary).

vip_ui()->
	Term = #vip_ui_c2s{},
	Binary = login_pb:encode_vip_ui_c2s(Term),
	sendtoserver(Binary).

vip_reward()->
	Term = #vip_reward_c2s{},
	Binary = login_pb:encode_vip_reward_c2s(Term),
	sendtoserver(Binary).

pet_up_reset(PetId,Reset,Protect,Locked,Pattr,Lattr)->
	%Term = #pet_up_reset_c2s{petid=PetId,reset=Reset,protect=Protect,locked=Locked,pattr=Pattr,lattr=Lattr},
	%Binary = login_pb:encode_pet_up_reset_c2s(Term),
	%sendtoserver(Binary).
	nothing.

%pet_up_growth(PetId,Needs,Protect)->
	%Term = #pet_up_growth_c2s{petid=PetId,needs=Needs,protect=Protect},
	%Binary = login_pb:encode_pet_up_growth_c2s(Term),
	%sendtoserver(Binary).

%pet_up_stamina_growth(PetId,Needs,Protect)->
%	Term = #pet_up_stamina_growth_c2s{petid=PetId,needs=Needs,protect=Protect},
	%Binary = login_pb:encode_pet_up_stamina_growth_c2s(Term),
	%sendtoserver(Binary).

enum_exchange_item_c2s(NpcId)->
	Term = #enum_exchange_item_c2s{npcid=NpcId},
	Binary = login_pb:encode_pet_up_growth_c2s(Term),
	sendtoserver(Binary).

answer_sign_request_c2s()->
	Term = #answer_sign_request_c2s{},
	Binary = login_pb:encode_answer_sign_request_c2s(Term),
	sendtoserver(Binary).

answer_question_c2s(Id,Answer,Flag)->
	Term = #answer_question_c2s{id=Id,answer=Answer,flag=Flag},
	Binary = login_pb:encode_answer_question_c2s(Term),
	sendtoserver(Binary).

congratulations_levelup_c2s(Level,RoleId,Type)->
	Term = #congratulations_levelup_c2s{level=Level,roleid=RoleId,type=Type},
	Binary = login_pb:encode_congratulations_levelup_c2s(Term),
	sendtoserver(Binary).

congratulations_received_c2s(Level)->
	Term = #congratulations_received_c2s{level=Level},
	Binary = login_pb:encode_congratulations_received_c2s(Term),
	sendtoserver(Binary).

split_item(Slot,Num)->
	Term = #split_item_c2s{slot=Slot,split_num=Num},
	Binary = login_pb:encode_split_item_c2s(Term),
	sendtoserver(Binary).

enchant(Equipment,Enchant)->
	Term = #equipment_enchant_c2s{equipment=Equipment,enchant=Enchant},
	Binary = login_pb:encode_equipment_enchant_c2s(Term),
	sendtoserver(Binary).

goals_init()->
	Term = #goals_init_c2s{},
	Binary = login_pb:encode_goals_init_c2s(Term),
	sendtoserver(Binary).


auth(AccountName,UserId)->
	gs_rpc:cast(node(), ?MODULE, {auth,AccountName,UserId}).
	
reset_autoname_c2s()->
	io:format("reset_autoname_c2s~n"),
	Message = login_pb:encode_reset_random_rolename_c2s(#reset_random_rolename_c2s{}),
	sendtoserver(Message).

send_create_role_request()->
	io:format("send_create_role_request~n"),
	Name = get(user_name),
	Message = login_pb:encode_create_role_request_c2s(#create_role_request_c2s{role_name = Name,gender = 0,classtype = 3}),
	sendtoserver(Message).

send_line_query(LastMapId)->
	io:format("send_line_query LastMapId:~p~n",[LastMapId]),
	Message = login_pb:encode_role_line_query_c2s(#role_line_query_c2s{mapid = LastMapId}),
	sendtoserver( Message).

send_role_select(RoleId,LineId)->
	io:format("send_role_select:roleid=~p,lineid=~p,~n",[RoleId,LineId]),
	Message = login_pb:encode_player_select_role_c2s(
						#player_select_role_c2s{roleid = RoleId,lineid = LineId}),
	sendtoserver( Message).

send_query_npc_state(NpcIds)->
	Message = login_pb:encode_questgiver_states_update_c2s(#questgiver_states_update_c2s{npcid = NpcIds}),
	sendtoserver( Message).

send_map_complete()->
	Message = login_pb:encode_map_complete_c2s(#map_complete_c2s{}),	
	sendtoserver( Message),
	put(target,0),
	put(aoi_list,[]).

sendtoserver(Binary)->
	gs_rpc:cast(node(), ?MODULE, {sendtoserver,Binary}).

quit()->
	gs_rpc:cast(node(), ?MODULE, {quit}).
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({connect,Address,Port},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined->
			case gen_tcp:connect(Address, Port, [{packet,2},binary,{active,true},{reuseaddr, true}]) of
				{ok,Socket} -> io:format("gen_tcp connect ok~n"),
							   {noreply, State#state{socket=Socket,addr=Address,port=Port}};
				{error,Reason}->
					io:format("gen_tcp connect failed~p~n",[Reason]),
					{noreply,State}
			end;
		_->
			%%io:format("client has connect to server (~p:~p)~n",[Addr,Pt]),
			{noreply,State}
	end;
handle_info({auth,AccountName,UserId},State)->
	Client_config = #client_config{life_time=0,
								   user_name = AccountName,
				       			   user_password="123456",
				       			   server_addr= "192.168.1.111",
				       			   server_port= 8080,
					   			   lineid = 2},
	{MegaSecs, Secs, _MicroSecs} = now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	AuthTerm = #user_auth_c2s{username=AccountName,userid=UserId,time=TimeSeconds,cm=1,flag=""},
	Binary = login_pb:encode_user_auth_c2s(AuthTerm),
	put(user_name,AccountName),
	put(lineid ,2),
	sendtoserver(Binary),
	{noreply,State#state{client_config=Client_config}};

handle_info(#user_auth_fail_s2c{},State)->
	io:format("user_auth_fail_s2c~n"),
	{noreply, State};

handle_info(#player_role_list_s2c{roles=RoleList},State)->
	case RoleList of
		[]->
			send_create_role_request();
		_-> 
			io:format("rolelist:~p~n",[RoleList]),
			[#r{roleid=RoleId, 
%% 						name=RoleName,
						lastmapid=LastMapId
%% 						classtype = Classtype,
%% 						gender = Gender,
%% 						level = Level
					}|_T] = RoleList,
			put(role_id,RoleId),
			send_line_query(LastMapId)
	end,
	{noreply, State};	

handle_info(#create_role_sucess_s2c{role_id=RoleId},State)->
	put(role_id,RoleId),
	send_role_select(get(role_id),get(lineid)),
	{noreply, State};

handle_info(#create_role_failed_s2c{reasonid=Reason},State)->
	io:format("create_role_failed_s2c:~p ~n",[Reason]),
	{noreply, State};

handle_info(#role_line_query_ok_s2c{},State)->
	send_role_select(get(role_id),get(lineid)),	
	{noreply, State};

handle_info(#object_update_s2c{create_attrs = NewCommers,change_attrs = _Change, deleteids = Deletes}, State)->
	%%change_my_aoi(NewCommers,Deletes),
	{noreply, State};	

handle_info(#learned_skill_s2c{skills = _Skills}, State)->
	put(skillid,530000011),
	{noreply, State};

handle_info(#role_map_change_s2c{x=X, y=Y,lineid = _LineId,mapid =Mapid}, State)->
	put(map_id,Mapid),
	put(pos,{X,Y}),
	put(path,[]),
	send_map_complete(),
	%%start_random_move(),
	{noreply, State};

handle_info(#mall_item_list_s2c{mitemlists=MItemLists},State)->
	io:format("mitemlists:~p~n",[MItemLists]),
	{noreply,State};

handle_info(#mall_item_list_special_s2c{mitemlists=MItemLists},State)->
	io:format("mitemlists2:~p~n",[MItemLists]),
	{noreply,State};

handle_info(#mall_item_list_sales_s2c{mitemlists=MItemLists},State)->
	io:format("mitemlists3:~p~n",[MItemLists]),
	{noreply,State};

handle_info(#buy_item_fail_s2c{reason=Reason},State) ->
	io:format("mall_client:buy_item_fail_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#add_item_s2c{item_attr=ItemAttr},State) ->
	io:format("mall_client:add_item_s2c,~p~n",[ItemAttr]),
	{noreply,State};

handle_info(#update_item_s2c{items=Items},State) ->
	io:format("mall_client:update_item_s2c,~p~n",[Items]),
	{noreply,State};

handle_info(#myfriends_s2c{friendinfos=Items},State) ->
	io:format("mall_client:myfriends_s2c,~p~n",[Items]),
	{noreply,State};

handle_info(#add_friend_success_s2c{friendinfo=Item},State) ->
	io:format("mall_client:add_friend_success_s2c,~p~n",[Item]),
	{noreply,State};

handle_info(#add_friend_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:add_friend_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#delete_friend_success_s2c{fn=Fname,type=Type},State) ->%%@@
	io:format("mall_client:delete_friend_success_s2c,~p~n",[Fname]),
	{noreply,State};


handle_info(#delete_friend_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:delete_friend_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#detail_friend_s2c{defr=DetailFriend},State) ->
	io:format("mall_client:detail_friend_s2c,~p~n",[DetailFriend]),
	{noreply,State};

handle_info(#position_friend_s2c{posfr=PositionFriend},State) ->
	io:format("mall_client:position_friend_s2c,~p~n",[PositionFriend]),
	{noreply,State};

handle_info(#position_friend_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:position_friend_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#detail_friend_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:detail_friend_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#equipment_riseup_s2c{result=Slot,star=Star},State) ->
	io:format("mall_client:equipment_riseup_s2c,~p~n",[{Slot,Star}]),
	{noreply,State};
handle_info(#equipment_riseup_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:equipment_riseup_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#equipment_sock_s2c{result=Result,sock=Sock},State) ->
	io:format("mall_client:equipment_sock_s2c,~p~n",[{Result,Sock}]),
	{noreply,State};
handle_info(#equipment_sock_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:equipment_sock_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#equipment_inlay_s2c{},State) ->
	io:format("mall_client:equipment_inlay_s2c"),
	{noreply,State};
handle_info(#equipment_inlay_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:equipment_inlay_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#equipment_stone_remove_s2c{},State) ->
	io:format("mall_client:equipment_stone_remove_s2c"),
	{noreply,State};
handle_info(#equipment_stone_remove_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:equipment_stone_remove_failed_s2c,~p~n",[Reason]),
	{noreply,State};

handle_info(#achieve_init_s2c{achieve_value=Achieve_value,recent_achieve=Recent_achieve,fuwen=Fuwen,achieve_info=Achieve_info,award=Award},State) ->
	io:format("mall_client:achieve_init_s2c,~p~n",[Achieve_value,Recent_achieve,Fuwen,Achieve_info,Award]),
	{noreply,State};
handle_info(#achieve_update_s2c{achieve_value=Achieve_value,recent_achieve=Recent_achieve,fuwen=Fuwen,achieve_info=Achieve_info,award=Award},State) ->
	%%io:format("mall_client:achieve_updata_s2c,~p~n",[Part]),
	{noreply,State};
handle_info(#achieve_error_s2c{reason=Reason},State) ->
	io:format("mall_client:achieve_error_s2c,~p~n",[Reason]),
	{noreply,State};
handle_info(#loop_tower_enter_failed_s2c{reason=Reason},State) ->
	io:format("mall_client:loop_tower_enter_failed_s2c,~p~n",[Reason]),
	{noreply,State};
handle_info(#loop_tower_enter_s2c{layer=Layer},State) ->
	io:format("mall_client:loop_tower_enter_s2c,~p~n",[Layer]),
	{noreply,State};
handle_info(#vip_ui_s2c{vip=Vip,gold=Gold,endtime=EndTime},State) ->
	io:format("mall_client:vip_ui_s2c,~p~n",[{Vip,Gold,EndTime}]),
	{noreply,State};
%handle_info(#pet_up_reset_s2c{petid=PetId,strength=Strength,agile=Agile,intelligence=Intelligence},State) ->
	%io:format("mall_client:pet_get_point_s2c,~p~n",[{PetId,Strength,Agile,Intelligence}]),
	%{noreply,State};
handle_info(#pet_opt_error_s2c{reason=Reason},State) ->
	io:format("mall_client:pet_opt_error_s2c,~p~n",[Reason]),
	{noreply,State};
handle_info(#pet_up_growth_s2c{result=Result,next=Next},State) ->
	io:format("mall_client:pet_up_growth_s2c,~p~n",[{Result,Next}]),
	{noreply,State};
handle_info(#pet_up_stamina_growth_s2c{result=Result,next=Next},State) ->
	io:format("mall_client:pet_up_stamina_growth_s2c,~p~n",[{Result,Next}]),
	{noreply,State};
handle_info(#init_hot_item_s2c{lists=Lists},State) ->
	io:format("mall_client:init_hot_item_s2c,~p~n",[Lists]),
	{noreply,State};
handle_info(#init_latest_item_s2c{lists=Lists},State) ->
	io:format("mall_client:init_latest_item_s2c,~p~n",[Lists]),
	{noreply,State};
handle_info(#enum_exchange_item_s2c{npcid=NpcID,dhs=Dhs},State) ->
	io:format("mall_client:init_latest_item_s2c,~p~n",[{NpcID,Dhs}]),
	{noreply,State};
handle_info(#npc_fucnction_common_error_s2c{reasonid=ID},State) ->
	io:format("mall_client:npc_fucnction_common_error_s2c,~p~n",[{ID}]),
	{noreply,State};
handle_info(#init_random_rolename_s2c{bn=Bname,gn=Gname},State) ->
	io:format("mall_client:init_random_rolename_s2c,~p~n",[{binary_to_list(Bname),Gname}]),
	{noreply,State};
handle_info(#answer_start_notice_s2c{id=Id,num=Num},State) ->
	io:format("mall_client:answer_start_notice_s2c,~p ~p ~n",[Id,Num]),
	{noreply,State};
handle_info(#answer_end_s2c{exp=Exp},State) ->
	io:format("mall_client:answer_end_s2c,~p ~n",[Exp]),
	{noreply,State};
handle_info(#answer_error_s2c{reason=Reason},State) ->
	io:format("mall_client:answer_error_s2c,~p  ~n",[Reason]),
	{noreply,State};
handle_info(#congratulations_levelup_remind_s2c{level=Level,roleid=RoleId,rolename=RoleName},State) ->
	io:format("mall_client:congratulations_levelup_remind_s2c,~p ~p ~p  ~n",[Level,RoleId,RoleName]),
	{noreply,State};
handle_info(#congratulations_levelup_s2c{exp=Exp,remain=Remain},State) ->
	io:format("mall_client:congratulations_levelup_s2c,~p ~p ~n",[Exp,Remain]),
	{noreply,State};
handle_info(#congratulations_receive_s2c{exp=Exp,level=Level,roleid=RoleId,rolename=RoleName,type=Type},State) ->
	io:format("mall_client:congratulations_receive_s2c,~p ~p ~p ~p ~p ~n",[Exp,Level,RoleId,RoleName,Type]),
	{noreply,State};
handle_info(#congratulations_error_s2c{reason=Reason},State) ->
	io:format("mall_client:congratulations_error_s2c,~p ~n",[Reason]),
	{noreply,State};
handle_info(#chat_s2c{type=Type,desroleid=RoleId,desrolename=RoleName,privateflag=Flag,msginfo=Msg,details=Details},State) ->
	io:format("mall_client:chat_s2c,~p ~n",[{Type,RoleId,RoleName,Flag,Msg,Details}]),
	{noreply,State};
handle_info(#offline_exp_init_s2c{hour=Hour,totalexp=TotalExp},State) ->
	io:format("mall_client:offline_exp_init_s2c,~p ~n",[{Hour,TotalExp}]),
	{noreply,State};
handle_info(#offline_exp_quests_init_s2c{questinfos=Infos},State) ->
	io:format("mall_client:offline_exp_quests_init_s2c,~p ~n",[{Infos}]),
	{noreply,State};
handle_info(#equipment_enchant_s2c{enchants=Enchants},State) ->
	io:format("mall_client:equipment_enchant_s2c,~p ~n",[Enchants]),
	{noreply,State};
handle_info(#equipment_recast_s2c{enchants=Enchants},State) ->
	io:format("mall_client:equipment_recast_s2c,~p ~n",[Enchants]),
	{noreply,State};
handle_info(#goals_init_s2c{parts=Parts},State) ->
	io:format("mall_client:goals_init_s2c,~p ~n",[Parts]),
	{noreply,State};

handle_info({tcp,Socket,Binary},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	Term = erlang:binary_to_term(Binary),
	ID = element(2,Term),
	BinMsg = erlang:setelement(1,Term, login_pb:get_record_name(ID)),
	io:format("msg:~p~n",[login_pb:get_record_name(ID)]),
	gs_rpc:cast(node(), ?MODULE, BinMsg),
	inet:setopts(Socket, [{active, once}]),
	{noreply, State};

handle_info({tcp_closed, _Socket},StateData) ->
	%%io:format("gm client closed ~n"),
	{noreply, #state{}};

handle_info({quit},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined-> ignor;
		_-> io:format("gm client quit~n"),gen_tcp:close(Sock)
	end,
	{noreply, #state{}};

handle_info({sendtoserver,Data},#state{socket=Sock,addr=Addr,port=Pt}=State)->
	case Sock of
		undefined -> io:format(" have not connect to gmserver");
		_->	
			case gen_tcp:send(Sock, Data) of
				ok-> ok;
				{error,Reason}->
					io:format("send to client error :~p~n",[Reason])
			end
	end,
    {noreply, State};
handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------


change_my_aoi(NewCommers,Deletes)->
	lists:foreach(fun(#o{objectid = Objectid,objecttype = _Type,attrs = _Attrs})->
						put(aoi_list,lists:keydelete(Objectid,1,get(aoi_list)))
				 end,Deletes),
	Npcs = lists:foldl(fun(#o{objectid = Objectid,objecttype = Type,attrs = Attrs}, NpcTmps)->
					{_,_,X} = lists:keyfind(?ROLE_ATTR_POSX,2,Attrs),
					{_,_,Y} = lists:keyfind(?ROLE_ATTR_POSY,2,Attrs),
					{_,_,CreatureType} = lists:keyfind(?ROLE_ATTR_CREATURE_FLAG,2,Attrs),
					put(aoi_list,[ {Objectid,CreatureType,{X,Y}}| get(aoi_list)]),
					if
						(Type =:= ?UPDATETYPE_NPC) and(CreatureType =:= ?CREATURE_NPC)->											
							[ Objectid|NpcTmps ];							
						true->
							NpcTmps
					end						
			end,[],NewCommers),
	if
		Npcs =/= []->
			send_query_npc_state(Npcs);
		true->
			nothing
	end.

t()->
	ets:new(proto_msg_id_record_map,[set,named_table]),
	login_pb:init(),
	start_link(),
	connect("127.0.0.1",8080),
	auth("123456","123qwe").
	
