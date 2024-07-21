%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-10-31
%% Description: TODO: Add description to country_packet
-module(country_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%-include("data_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

handle(Message,RolePid)->
	RolePid ! {country_client_msg,Message}.

%%make country leader info 
%%return record #cl
make_cl(Post,PostIndex,RoleId,Name,Gender,Class)->
	#cl{
		post = Post,
		postindex = PostIndex,
		roleid = RoleId,
		name = Name,
		gender = Gender,
		roleclass = Class
 		}.

encode_country_init_s2c(Leaders,Notice,TpStart,TpStop,{BestGuildLId,BestGuildHId},BestGuildName)->
	login_pb:encode_country_init_s2c(
	  	#country_init_s2c{
						  leaders = Leaders,
						  notice = Notice,
						  tp_start = TpStart,
						  tp_stop = TpStop,
						  bestguildlid = BestGuildLId,
						  bestguildhid = BestGuildHId,
						  bestguildname = BestGuildName
						 }).

encode_change_country_notice_s2c(Notice)->
	login_pb:encode_change_country_notice_s2c(
	  	#change_country_notice_s2c{
							notice = Notice
								   }).

encode_change_country_transport_s2c(TpStart,TpStop)->
	login_pb:encode_change_country_transport_s2c(
	  		#change_country_transport_s2c{tp_start = TpStart,tp_stop = TpStop}
												).

encode_country_leader_update_s2c(Leader)->
	login_pb:encode_country_leader_update_s2c(
	  #country_leader_update_s2c{
								 leader = Leader
								 }).

encode_country_leader_online_s2c(Post,PostIndex,Name)->
	login_pb:encode_country_leader_online_s2c(
	  		#country_leader_online_s2c{
									   post = Post,
									   postindex = PostIndex,
									   name = Name
									   }).
encode_country_opt_s2c(Code)->
	login_pb:encode_country_opt_s2c(
	  		#country_opt_s2c{code = Code}).

%%
%% Local Functions
%%

