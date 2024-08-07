%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-8
%% Description: TODO: Add description to role_util
-module(role_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).

-record(gm_role_info, {gs_system_role_info, 
		       gs_system_map_info,
		       gs_system_gate_info,
		       pos, name, view, life, mana,
		       gender,				%%鎬у埆
		       icon,				%%澶村儚
		       speed, state, skilllist, 
		       extra_states,
		       last_cast_time,
		       path, level,
		       silver,				%%娓告垙甯�,閾跺竵
		       gold,				%%鍏冨疂
		       ticket,				%%绀煎埜
		       hatredratio,			%%浠囨仺姣旂巼
		       expratio,			%%缁忛獙姣旂巼
		       lootflag,			%%鎺夎惤绯绘暟
		       exp,					%%缁忛獙
		       levelupexp,			%%鍗囩骇鎵�闇�缁忛獙
		       agile,				%%鏁�
		       strength,			%%鍔�
		       intelligence,		%%鏅�
		       stamina,				%%浣撹川
		       hpmax,		
		       mpmax,
		       hprecover,
		       mprecover,
		       power,				%%鏀诲嚮鍔�
		       class,				%%鑱屼笟
		       commoncool,			%%鍏叡鍐峰嵈
		       immunes,				%%鍏嶇柅鍔泏榄旓紝杩滐紝杩憓
		       hitrate,				%%鍛戒腑
		       dodge,				%%闂伩
		       criticalrate,		%%鏆村嚮
		       criticaldamage,		%%鏆村嚮浼ゅ
		       toughness,			%%闊ф��
		       debuffimmunes,		%%debuff鍏嶇柅{瀹氳韩锛屾矇榛橈紝鏄忚糠锛屾姉姣�,涓�鑸瑌
		       defenses,			%%闃插尽鍔泏榄旓紝杩滐紝杩憓
		       %%2010.9.20
		       buffer,				%%buffer
		       guildname,			%%鍏細鍚�
		       guildposting,	    %%鑱屼綅
		       cloth,				%%琛ｆ湇
		       arm,					%%姝﹀櫒
		       pkmodel,				%%PK妯″紡
		       crime,				%%缃伓鍊�	
		       pet_name,
		       pet_id,
		       pet_proto,
		       pet_quality	
		       }).

%%
%% API Functions
%%
get_role_info()->
	get(creature_info).

get_level(RoleInfo) when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.level, RoleInfo).

set_level(RoleInfo,Level)when is_record(RoleInfo, gm_role_info) ->
	erlang:setelement(#gm_role_info.level, RoleInfo, Level).

get_class(RoleInfo) when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.class, RoleInfo).

get_name(RoleInfo)when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.name, RoleInfo).

get_id()->
    get(roleid).
%%
%% Local Functions
%%

