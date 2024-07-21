%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(treasure_spawns_packet).

%%
%% Include files
%%
-export([encode_star_spawns_section_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").


encode_star_spawns_section_s2c(Section)->
	login_pb:encode_star_spawns_section_s2c(#star_spawns_section_s2c{section = Section} ).
