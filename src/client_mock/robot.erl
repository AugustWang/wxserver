%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-4-20
%% Description: TODO: Add description to test_login
-module(robot).
-define(BASE_MAX,200).
-define(MAPLIST,[100,200,300,500,600,700,1000,1300,1400,333]).
%% -define(MAPLIST,[100,200,300,400,500,600,800,900]).
%%
%% Include files
%%
-include("login_pb.hrl").
-include("client_def.hrl").
%%
%% Exported Functions
%%
-export([test/3,start/6,start/4,start/7,start/8,start/9,call_robot/0]).
-export([start_send/0,start_rec/0,test_send/0,test_rec/0]).
-export([test_i/8]).
-define(BASE,10000).
%%
%% API Functions
%%

%%robot:test("127.0.0.1", 1, 1).
test(Server,Index,ServerId)->
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,
	test_i(Server,Index,1,8001,100,40,1,ServerId).

%%robot:start("192.168.1.251", 1, 10, 1).
start(Server,Index,Num,ServerId)->
	RealIndex = Index * ?BASE_MAX + 1,
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,
	lists:foreach(fun(IndexTmp)-> test_i(Server,IndexTmp,1,8001,100,40,10,ServerId) end,lists:seq(RealIndex,RealIndex + Num)).

start(Server,Index,Num,LineId,Port,ServerId)->
	RealIndex = Index * ?BASE_MAX + 1,
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,
	lists:foreach(fun(IndexTmp)-> test_i(Server,IndexTmp,LineId,Port,100,30,10,ServerId) end,lists:seq(RealIndex,RealIndex + Num)).

start(Server,Index,Num,LineId,Port,MapId,ServerId)->
	RealIndex = Index * ?BASE_MAX + 1,
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,
	lists:foreach(fun(IndexTmp)-> test_i(Server,IndexTmp,LineId,Port,MapId,30,10,ServerId) end,lists:seq(RealIndex,RealIndex + Num)).

start(Server,Index,Num,LineId,Port,MapId,Level,ServerId)->
	RealIndex = Index * ?BASE_MAX + 1,
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,
	lists:foreach(fun(IndexTmp)-> test_i(Server,IndexTmp,LineId,Port,MapId,Level,10,ServerId) end,lists:seq(RealIndex,RealIndex + Num)).

start(Server,Index,Num,LineId,Port,MapId,Level,SpeekRate,ServerId)->
	RealIndex = Index * ?BASE_MAX + 1,
	try
		load_map_sup:start_link(),
		login_pb:create(),
		login_pb:init()
	catch
		_:_-> ignor
	end,

	lists:foreach(fun(IndexTmp)-> test_i(Server,IndexTmp,LineId,Port,MapId,Level,SpeekRate,ServerId) end,lists:seq(RealIndex,RealIndex + Num)).		

test_i(Server,Index,LineId,Port,MapId,Level,SpeekRate,ServerId)->
	Client_config = #client_config{life_time=0,
					   user_name = 	Index,
				       user_password="123456",
				       server_addr= Server,
				       server_port= Port,
						lineid = LineId,
						mapid = MapId,
						level = Level,
						speekrate = SpeekRate,
						serverid = ServerId},
	%%io:format("start_client:~p~n", [Index]),
	client:start(list_to_atom(integer_to_list(Index)), Client_config).
start_send()->
	register(test_send,spawn(robot,test_send,[])).

test_send()->
	test_rec!{test_send,1}.
%% erlang:send_after(50,test_rec,{test_send,1}).

start_rec()->
	register(test_rec,spawn(robot,test_rec,[])).

test_rec()->
	receive
		{test_send,N}->
			robot:test("192.168.1.251",N,1),
%% 			io:format("The N is=~p~n",[N]),
			if
				N<1000->
%% 					test_rec!{test_send,N+1};
					erlang:send_after(500,test_rec,{test_send,N+1});
				true->
					io:format("finish!~n")
			end;
		_->
			nothing
	end,
	test_rec().

call_robot()->
	robot:test("192.168.1.251",1,1).
%%
%% Local Functions
%%
