%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pvp_handle).
-compile(export_all).

-include("data_struct.hrl").

-include("common_define.hrl").
-include("pvp_define.hrl").
-include("error_msg.hrl").

handle_set_pkmodel_c2s(PkModel)->
	if
		(PkModel < ?PVP_MODEL_PEACE) or (PkModel > ?PVP_MODEL_KILLALL)->
			nothing;
		true->
			pvp_op:set_pkmodel(PkModel)
	end.