%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(venation_packet).

-include("login_pb.hrl").

-export([handle/2]).

-export([encode_venation_init_s2c/5,
		encode_venation_update_s2c/3,
		encode_venation_shareexp_update_s2c/2,
		encode_venation_active_point_opt_s2c/1,
		encode_venation_opt_s2c/2,
		encode_venation_time_countdown_s2c/2,
		encode_venation_advanced_opt_result_s2c/2,
		encode_venation_advanced_update_s2c/1,
		make_vp/2,
		make_bone/2,
		encode_other_venation_info_s2c/6
		]).

handle(Message=#venation_active_point_start_c2s{},RolePid)->
	RolePid!{venation,Message};
handle(Message=#venation_active_point_end_c2s{},RolePid)->
	RolePid!{venation,Message};
handle(Message=#venation_advanced_start_c2s{},RolePid)->
	RolePid!{venation,Message};
handle(_,_)->
	nothing.

encode_venation_init_s2c(VenationInfo,VenationBone,AttrInfo,RemainTime,TotalExp)->
	login_pb:encode_venation_init_s2c(
			#venation_init_s2c{venation = VenationInfo,
							   venationbone = VenationBone,
								attr = AttrInfo,
								remaintime =RemainTime,
								totalexp = TotalExp}
				).

encode_venation_update_s2c(VenationId,PointId,AttrInfo)->
	login_pb:encode_venation_update_s2c(
			#venation_update_s2c{venation = VenationId,
								point = PointId,
								attr = AttrInfo}
				).

encode_venation_shareexp_update_s2c(RemainTime,TotalExp)->
	login_pb:encode_venation_shareexp_update_s2c(
			#venation_shareexp_update_s2c{
								remaintime = RemainTime,
								totalexp = TotalExp}
				).

encode_venation_active_point_opt_s2c(Reason)->
	login_pb:encode_venation_active_point_opt_s2c(
			#venation_active_point_opt_s2c{reason = Reason}).

encode_venation_opt_s2c(RoleId,Reason)->
	login_pb:encode_venation_opt_s2c(#venation_opt_s2c{roleid=RoleId,reason = Reason}). 
 
encode_venation_time_countdown_s2c(RoleId,Time)->
	login_pb:encode_venation_time_countdown_s2c(#venation_time_countdown_s2c{roleid = RoleId,time = Time}).

encode_venation_advanced_opt_result_s2c(Result,Bone)->
	login_pb:encode_venation_advanced_opt_result_s2c(#venation_advanced_opt_result_s2c{result=Result,bone=Bone}).

encode_venation_advanced_update_s2c(AttrInfo)->
	login_pb:encode_venation_advanced_update_s2c(#venation_advanced_update_s2c{attr=AttrInfo}).
	 
make_vp(Id,PointList)->
	#vp{id = Id,points = PointList}.

make_bone(Id,Bone)->
	#vb{id = Id,bone = Bone}.


encode_other_venation_info_s2c(RoleId,VenationInfo,AttrInfo,RemainTime,TotalExp,VenationBone)->
	login_pb:encode_other_venation_info_s2c(
			#other_venation_info_s2c{
								roleid = RoleId,
								venation = VenationInfo,
								attr = AttrInfo,
								remaintime =RemainTime,
								totalexp = TotalExp,
								venationbone = VenationBone}
				).