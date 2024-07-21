%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pvp_packet).
-compile(export_all).
-include("login_pb.hrl").
-include("data_struct.hrl").
-include("pvp_define.hrl").

handle(#set_pkmodel_c2s{pkmodel=PkModel},RolePid)->
	role_processor:set_pkmodel_c2s(RolePid,PkModel);
	
handle(#clear_crime_c2s{type=Type},RolePid)->
	role_processor:clear_crime_c2s(RolePid,Type);

handle(_Message,_RolePid)->
	ok.

encode_set_pkmodel_faild_s2c(Time)->
	login_pb:encode_set_pkmodel_faild_s2c(#set_pkmodel_faild_s2c{errno = Time}).

encode_clear_crime_time_s2c(Time,Type)->
	login_pb:encode_clear_crime_time_s2c(#clear_crime_time_s2c{lefttime = Time,type=Type}).

clear_crime_name(Type)->
	case Type of
		?CLEAR_ROLE_BLACK_NAME ->
			pvp_op:clear_black_name();
		?CLEAR_CRIME ->
			pvp_op:clear_crime()
	end.

process_msg({clear_crime_by_value,Value})->
	pvp_op:clear_crime_by_value(Value);

process_msg({add_crime_by_value,Value})->
	pvp_op:add_crime_by_value(Value).