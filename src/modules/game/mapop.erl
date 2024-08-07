%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : mapop.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 22 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-include("map_define.hrl").

-module(mapop).

-export([build_mapdb_processor/1, get_aoi_roles/3]).

-compile(export_all).

-include("login_pb.hrl").
-include("data_struct.hrl").
-include("map_info_struct.hrl").
-include("creature_define.hrl").
-include("npc_struct.hrl").

%%-define(View, 15).
-define(ETS_POS_GRID,1).
-define(ETS_POS_UNITS,2).
-define(ETS_POS_ROLES,3).
-define(ETS_POS_STATE,4).

check_safe_grid(MapDb,Grid)->
%% 	case MapDb of
%% 		'300_db'->
%% 			true;%%wb20130528鏆傛椂涓嶈300鍦板浘鏈夋潃鎴涓�
%% 		_->
	mapdb_processor:query_safe_grid(MapDb,Grid) =:= 1.
%% 	end.

get_map_tag(MapId)->
	case map_info_db:get_map_info(MapId) of
		[]->
			0;
		MapInfo->
			map_info_db:get_map_tag(MapInfo)
	end.

get_map_pvptag(MapId)->
	case map_info_db:get_map_info(MapId) of
		[]->
			0;
		MapInfo->
			map_info_db:get_pvptag(MapInfo)
	end.

get_respawn_pos(MapDb)->
	BornInfo = mapdb_processor:query_born_pos(MapDb),
	case BornInfo of
		[]->
%% 			{300,{175,175}};%%wb濡傛灉绂荤嚎鏃舵暟鎹瓨鍌ㄩ敊璇紝涓婄嚎鏃堕粯璁ゅ湪涓诲煄鍥哄畾鍧愭爣澶嶆椿,涔熸槸鏅�氬湴鍥鹃潪鍘熷湴澶嶆椿鐐�
			[];
		{RespawnMapId,Poses}->
			case is_list(Poses) of
				true->
					{RespawnMapId,lists:nth(random:uniform(erlang:length(Poses)),Poses)};
				_->
					BornInfo
			end
	end.
			
%% 妫�鏌ヨ矾寰勬槸鍚﹀悎娉�
%% Path鏍煎紡锛�
check_path(undefined, _) ->
	false;
check_path(Path, MapDb) ->
	Fun = fun(Coord) ->
			      #c{x=X, y=Y} = Coord,
			      not check_pos_is_valid({X,Y},MapDb) 
	      end,
	%%鎶婅矾寰勭粍鍚堟垚{x,y}, map_id鐨勫舰寮�
	ErrorPos = lists:filter(Fun, Path),
	length(ErrorPos) =:= 0.

is_all_units_dead_but(UnitIds)->
	AllUnits = get_map_units_id(),
	is_all_dead_id(AllUnits -- UnitIds).

is_all_units_dead()->
	AllUnits = get_map_units_id(),
	is_all_dead_id(AllUnits).
	
is_all_dead_id(AllUnits)->	
	lists:foldl(fun(UnitId,Re)->
			if
				not Re->	
					Re;
				true->	
					case creature_op:get_creature_info(UnitId) of
						undefined->
								Re;
						CreatureInfo->
								creature_op:is_creature_dead(CreatureInfo)
					end
			end	end,true,AllUnits).

get_map_dead_units(AllUnits)->
	FunFilter = fun(UnitId)->
					case creature_op:get_creature_info(UnitId) of
						undefined->
								true;
						CreatureInfo->
								creature_op:is_creature_dead(CreatureInfo)
					end	
				end,
	lists:filter(FunFilter,AllUnits).

check_point_with_mapid(MapId,Pos)->
	MapDb = mapdb_processor:make_db_name(MapId),
	check_pos_is_valid(Pos,MapDb).


kill_all_monster()->
	lists:foreach(fun(UnitId)->
					case creature_op:get_creature_info(UnitId) of
							undefined->
								nothing;
							NpcInfo->
								case creature_op:get_npcflags_from_creature_info(NpcInfo) of
										?CREATURE_MONSTER->
											ProtoId = get_templateid_from_npcinfo(NpcInfo),
											role_op:on_my_kill(UnitId),
											spiritspower_op:on_other_killed(UnitId),
											loop_tower_op:on_killed_monster(UnitId),
											role_mainline:update({monster_kill,ProtoId}),
											loop_instance_op:hook_kill_monster(ProtoId),
											npc_op:send_to_creature(UnitId,{forced_leave_map});			
										_->
											nothing
								end
					end					
		end,mapop:get_map_units_id()).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 浠庣敓鐗╁潗鏍囪浆鎹㈡垚鍦板浘鏍�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convert_to_grid_index(Pos, GridWidth) ->
	{X, Y} = Pos,
	Index_x = util:even_div(X,GridWidth),
	Index_y = util:even_div(Y,GridWidth),
	{Index_x, Index_y}.

%% 寰楀埌AOI鍐呯殑鐜╁
get_aoi_roles(MapInfo, Pos, IsContain) when IsContain ->
	{Map_data, Map_proc_name} = MapInfo,
	{true, StandBlock} = quadtree:hit(Pos, Map_data),
	[{_, GroupName,_}] = ets:lookup(Map_proc_name, StandBlock),
	pg2_ex:get_members(GroupName).

%%寰楀埌鏁翠釜鍦板浘涓婄殑鎬墿id
get_map_units_id()->
	MapProc = get_proc_from_mapinfo(get(map_info)),
	get_map_units_id_by_proc(MapProc).

get_map_units_id_by_proc(MapProc)->	
	ets:foldl(fun({_,Units,_,_},UnitsTmp)->Units++UnitsTmp end,[],MapProc).

%% 寰楀埌鏁翠釜鍦板浘鍐呯殑Roles
get_map_roles_id()->
	MapProc = get_proc_from_mapinfo(get(map_info)),
	get_map_roles_id_by_proc(MapProc).
	
get_map_roles_id_by_proc(MapProc)->
	ets:foldl(fun({_,_,Roles,_},RolesTmp)->Roles++RolesTmp end,[],MapProc).
	
%% 寰楀埌鏌愪釜缃戞牸鍐呯殑鎵�鏈夌敓鐗�
get_creatures_from_grid(MapProc, Grid) ->
	case ets:lookup(MapProc, Grid) of
		[] ->
			[];
		[{_,Units,Roles,_}] ->
			Units ++ Roles 
	end.
	
is_grid_active(MapProc, Grid)->
	case ets:lookup(MapProc, Grid) of
		[] ->
			false;
		[{_,_,_,Tag}] ->
			Tag
	end.


	
is_has_role_in_grid(MapProc,Grid)->
	case ets:lookup(MapProc, Grid) of
		[] ->
			false;
		[{_,_,[],_}] ->
			false;
		_->
			true 
	end.	
%%---------------------------------------------------------------------------------------------------------------------------------------------------------
%%10.9.25,鍔犲叆Grid鐨勬縺娲�,鍦╡ts閲屽鍔犱竴涓瓧娈�,濡傛灉褰撳墠grid鏈縺娲�,璁剧疆鏈猣alse,濡傛灉鏈夌帺瀹惰繘鍏�,鍒欐縺娲诲懆鍥村尯鍩�,璁句负true,鏍囧織鏈変汉,濡傛灉绂诲紑,淇敼婵�娲荤姸鎬乫alse
%%
%%---------------------------------------------------------------------------------------------------------------------------------------------------------
join_grid(CreatureId, Grid, MapProcName) ->	
 	map_processor:join_grid(MapProcName,Grid,CreatureId),
	OtherCreatureS = get_roles_from_squared_up(MapProcName, Grid),
	OtherCreatureS.

leave_grid(CreatureId, MapProcName, Grid) ->
	map_processor:leave_grid(MapProcName,Grid,CreatureId).

activate_grid(MapProc, Grid) ->	
	case ets:lookup(MapProc, Grid) of
		[] ->			%%娌℃湁鎬墿
			ets:insert(MapProc, {Grid, [],[],true}),
			[];
		[{_, Units,_,ActiveTag}] ->		
			if
				ActiveTag =:= false->
					ets:update_element(MapProc,Grid,{?ETS_POS_STATE,true}),				 																
					lists:foreach(fun(CreatureId)->
							case creature_op:get_creature_info(CreatureId) of
								undefined->
									nothing;
								CreatureInfo->
									Pid = creature_op:get_pid_from_creature_info(CreatureInfo),												
									util:send_state_event(Pid, {activate})
							end												
						end,Units);						
				true->
					nothing
			end					
	end.
	
inactivate_grid(MapProc, Grid)->
	case ets:lookup(MapProc, Grid) of
	[] ->
		ets:insert(MapProc, {Grid, [],[],false});
	[{_, _,_,ActiveTag}] ->		
		if
			ActiveTag =:= true->
				%%璁╅噷闈㈢殑npc鍦ㄧЩ鍔ㄧ殑鏃跺�欒嚜宸卞幓hibernet
				ets:update_element(MapProc,Grid,{?ETS_POS_STATE,false});
			true->	%%琚汉hibernet杩囦簡
				nothing
		end
	end.						
	
update_grid_state(MapProcName,Grid)->
	{Index_x, Index_y} = Grid,
	SquaredLists = [{Index_x, Index_y},{Index_x + 1, Index_y + 1},{Index_x, Index_y + 1},
					{Index_x - 1, Index_y + 1},{Index_x + 1, Index_y},{Index_x - 1, Index_y},
					{Index_x + 1, Index_y - 1},{Index_x, Index_y - 1},{Index_x - 1, Index_y - 1}],
	NeedActive = lists:foldl(fun(TmpGrid,TmpResult)->			
							if
								TmpResult->
									true;
								true->
									%%娌℃湁鐜╁
									is_has_role_in_grid(MapProcName,TmpGrid)
							end		
					end,false,SquaredLists),
	if
		not NeedActive->
				inactivate_grid(MapProcName,Grid);
		true->
			nothing
	end.
	
	
%%鏇存柊鏍肩姸鎬�,ActiveGrid涓哄姞鍏ユ牸,InactiveGrid涓虹寮�鐨勬牸,娌℃湁鐨勮瘽涓�0
update_grids_state(MapProcName, ActiveGrid,InactiveGrid)->
	case ActiveGrid  of
	 	0->
	 		ActiveSquaredLists  = [];
	 	{Index_x, Index_y}->
	 		ActiveSquaredLists = [{Index_x, Index_y},{Index_x + 1, Index_y + 1},{Index_x, Index_y + 1},
					{Index_x - 1, Index_y + 1},{Index_x + 1, Index_y},{Index_x - 1, Index_y},
					{Index_x + 1, Index_y - 1},{Index_x, Index_y - 1},{Index_x - 1, Index_y - 1}]
	end,	
	case InactiveGrid of
		0->
 			InActiveSquaredLists  = [];	
		{DeIndex_x,DeIndex_y}->
			InActiveSquaredLists = [{DeIndex_x, DeIndex_y},{DeIndex_x + 1, DeIndex_y + 1},{DeIndex_x, DeIndex_y + 1},
					{DeIndex_x - 1, DeIndex_y + 1},{DeIndex_x + 1, DeIndex_y},{DeIndex_x - 1, DeIndex_y},
					{DeIndex_x + 1, DeIndex_y - 1},{DeIndex_x, DeIndex_y - 1},{DeIndex_x - 1, DeIndex_y - 1}]
	end,		
	lists:foreach(fun(Grid)->
		activate_grid(MapProcName,Grid) end,ActiveSquaredLists),	
	lists:foreach(fun(Grid)->
					case lists:member(Grid,ActiveSquaredLists) of
						true->
							nothing;
						false->
							update_grid_state(MapProcName,Grid)
					end end,InActiveSquaredLists).

get_roles_from_squared_up(MapProcName, Center) ->
	{Index_x, Index_y} = Center,
	%% 鏍规嵁鎸囧畾鐨凪apProcName, 鍜屽潗鏍囦綅缃�, 鏌ヨ灞炰簬璇ュ潗鏍囧湴鍧楃殑pg2_ex缁勫唴鐨勬垚nn鍛�
	Get_members_from_pg2 = fun(MapProc, Grid) ->
					       get_creatures_from_grid(MapProc, Grid)
			       end,    
	Center_roles     = Get_members_from_pg2(MapProcName, {Index_x, Index_y}),
	TopLeft_roles    = Get_members_from_pg2(MapProcName, {Index_x + 1, Index_y + 1}),
	TopMid_roles     = Get_members_from_pg2(MapProcName, {Index_x, Index_y + 1}),
	TopRight_roles   = Get_members_from_pg2(MapProcName, {Index_x - 1, Index_y + 1}),
	CenterLeft_roles = Get_members_from_pg2(MapProcName, {Index_x + 1, Index_y}),
	CenterRight_roles= Get_members_from_pg2(MapProcName, {Index_x - 1, Index_y}),
	BottomLeft_roles = Get_members_from_pg2(MapProcName, {Index_x + 1, Index_y - 1}),
	BottomMid_roles  = Get_members_from_pg2(MapProcName, {Index_x, Index_y - 1}),
	BottomRig_roles  = Get_members_from_pg2(MapProcName, {Index_x - 1, Index_y - 1}),
 	TopLeft_roles ++ TopMid_roles ++ TopRight_roles ++ CenterLeft_roles ++ 
		Center_roles ++	CenterRight_roles ++ BottomLeft_roles ++ BottomMid_roles ++ BottomRig_roles.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal function
build_terrain_db(QuadTree, MapProcName) ->
	insert_block_into_terriandb(QuadTree, MapProcName).    

insert_block_into_terriandb({_Bounding, [H|T]}, MapProcName) ->
	insert_block_into_terriandb(H, MapProcName),
	insert_block_into_terriandb(T, MapProcName);
insert_block_into_terriandb([H|T], MapProcName) ->
	insert_block_into_terriandb(H, MapProcName),
	insert_block_into_terriandb(T, MapProcName);
insert_block_into_terriandb({{L,T},{R,B}}, MapProcName) ->
	Block = {{L,T},{R,B}},
	GroupName = make_group_name(Block, MapProcName),
	pg2_ex:create(GroupName),
	ets:insert(MapProcName, {Block, GroupName});
insert_block_into_terriandb([], _MapProcName) ->
	{ok}.

calcute_view_bounding(Coord, View) ->
	%% TODO: 1000(map max width) is hardcode, must be get it from map datafile.
	{X, Y} = Coord,
	Coord_TL = {erlang:max(0, X - View), erlang:min(1000, Y + View)},
	Coord_TR = {erlang:min(1000, X + View), erlang:min(1000, Y + View)},
	Coord_BL = {erlang:max(0, X - View), erlang:max(0, Y - View)},
	Coord_BR = {erlang:min(1000, X + View), erlang:max(0, Y - View)},

	Coord_TM = {X, erlang:min(1000, Y + View)},
	Coord_BM = {X, erlang:max(0, Y - View)},
	Coord_LM = {erlang:max(0, X - View), Y},
	Coord_RM = {erlang:min(1000, X + View), Y},
	[Coord_TL, Coord_TM ,Coord_TR, Coord_LM, Coord_RM, Coord_BL, Coord_BM, Coord_BR].

%% join/leave the vertex of role's bounding box into pg2
set_role_boundings([H|T], RoleInfo, {Tree, MapProcName}, Action) ->
	move_one_point(RoleInfo, MapProcName, Action, quadtree:hit(H, Tree)),
	set_role_boundings(T, RoleInfo, {Tree, MapProcName}, Action);
set_role_boundings([], _RoleInfo, {_Tree, _MapProcName}, _Action) ->
	{ok}.

%% join/leave role's position into the pg2
set_role_position(RoleInfo, MapProcName, Action, HitResult) ->    
	move_one_point(RoleInfo, MapProcName, Action, HitResult).

%% the block in the tree
move_one_point(RoleInfo, MapProcName, Action, {true, Block}) ->
	operate_group(RoleInfo, Action, ets:lookup(MapProcName, Block));
%% the block is not in the tree
move_one_point(_RoleInfo, _MapProcName, _Action, {false}) ->
	{error, "not fount in the quadtree"}.

operate_group(_RolInfo, _Action, PG2Group) when PG2Group =:= [] ->
	%% Block does not exists
	{error, "Cannot find the MapProc"};
operate_group(RolInfo, Action, PG2Group) ->
	[{_Block, GroupName}] = PG2Group,
	{_RolePos, RoleProc, _RoleId} = RolInfo,

	Pid = whereis(RoleProc),
	Members = pg2_ex:get_members(GroupName),
	IsMember = lists:member(Pid, Members),
	do_action(Action, GroupName, Pid, IsMember).

group_broadcast(GroupName, Message) ->
	Members = pg2_ex:get_members(GroupName),
	util:broadcast(Members, Message).


do_action(join, GroupName, Pid, IsMember) ->
	join_pg2(GroupName, Pid, IsMember);
do_action(leave, GroupName, Pid, IsMember) ->
	leave_pg2(GroupName, Pid, IsMember).

join_pg2(_GroupName, _Pid, IsMember) when IsMember ->
	{ok}; %% alread join the group
join_pg2(GroupName, Pid, IsMember) when not IsMember ->
	slogger:msg("join to group: ~p, Pid: ~p~n", [GroupName, Pid]),
	%% first broadcast, then join
	pg2_ex:join(GroupName, Pid),
	{ok}.

leave_pg2(_GroupName, _Pid, IsMember) when not IsMember ->
	{ok}; %% alread leave the group
leave_pg2(GroupName, Pid, IsMember) when IsMember ->
	slogger:msg("leave from group: ~p, Pid: ~p~n", [GroupName, Pid]),
	%% first delete, then broadcast
	pg2_ex:leave(GroupName, Pid),
	{ok}.

%% 妫�鏌ユ煇涓潗鏍囨槸鍚﹁兘璧�
check_pos_is_valid(Coord, MapDb) ->
 	get_map_pos_tag(Coord, MapDb) =/= ?MAP_DATA_TAG_CANNOT_WALK.
 	
is_companion_addation_pos(Pos,MapDb)->	
 	mapop:get_map_pos_tag(Pos,MapDb) =:= ?MAP_DATA_TAG_SITDOWN_ADDATION.
 	
 %% 鑾峰彇鍦板浘鍧愭爣鐗╃悊鏍囧織	
get_map_pos_tag(Coord, MapDb)->	
	mapdb_processor:query_map_stand(MapDb, Coord).

make_group_name(Grid, MapProcName) ->
	{Grid, MapProcName}.
	
build_mapdb_processor({ok, MapProc}) ->
	{true, MapProc};
build_mapdb_processor({ok, MapProc, _Info}) ->
	{true, MapProc};
build_mapdb_processor({error, {already_started, MapProc}}) ->
	{true, MapProc};
build_mapdb_processor({error, Reason}) ->
	{false, Reason}.
	
