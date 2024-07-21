%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(role_level_packet).

-include("error_msg.hrl").
-include("login_pb.hrl").

-export([encode_add_levelup_opt_levels_s2c/1,handle/2]).


handle(#levelup_opt_c2s{level = Level},RolePid)->
	RolePid	! {levelup_opt_c2s,Level}.

encode_add_levelup_opt_levels_s2c(AllLevels)->
	login_pb:encode_add_levelup_opt_levels_s2c(#add_levelup_opt_levels_s2c{levels = AllLevels}).
