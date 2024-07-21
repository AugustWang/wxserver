%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-14
%% Description: TODO: Add description to version_up
-module(version_up).

%%
%% Include files
%%
-define(BEAM_VERSION_ETS,'$beams_version$').
%%
%% Exported Functions
%%
-export([up_node/1,up_new/0,up_all/0,init/0,up_one_module/1]).

%%
%% API Functions
%%
-compile(export_all).

init()->
	try 
		ets:new(?BEAM_VERSION_ETS, [set,named_table,public])
	catch
		E:R-> io:format("version up init exception:~p ~p~n",[E,R])
	end,
	ets:insert(?BEAM_VERSION_ETS, get_beams_version()).

%%
%% Local Functions
%%

up_data()->
	Nodes = nodes(),
	lists:foreach(fun(Node)-> 
						  io:format("begin to fresh option date~p ...~n",[Node]),
						  rpc:call(Node, env, fresh, []) end, Nodes),
	lists:foreach(fun(Node)-> EtsInit = db_tools:get_ets_table_mods(Node),
							  case EtsInit of
								  []-> ignor;
								  _-> io:format("begin to update date~p ...~n",[Node]),
									  rpc:call(Node, applicationex, wait_ets_init, [])
							  end
				   end, Nodes),
	io:format("update date complete~n").
	
up_all()->
	Nodes = nodes(),
	lists:foreach(fun(Node)-> io:format("begin to version update ~p ...~n",[Node]),
							  rpc:call(Node, ?MODULE, up_new, []) end, Nodes),
	io:format("version update complete~n").


up_node(ModuleList)->
	case ModuleList of
		[]-> ignor;
		_->
			io:format("updating:~n"),
			lists:foreach(fun(M)-> c:l(M) ,io:format("\t~p~n",[M]) end, ModuleList)
	end.

up_new()->
	BeamVerList = get_beams_version(),
	NeedUpVer = lists:filter(fun({Beam,Ver})->
								  OldVer = get_old_ver(Beam),
								  if OldVer =:= Ver-> false;
									 Ver==0-> false;
									 true-> true
								  end
						  end, BeamVerList),
	NeedUpBeams = lists:map(fun({Beam,_})-> Beam end, NeedUpVer),
	up_node(NeedUpBeams),
	ets:insert(?BEAM_VERSION_ETS,BeamVerList).

get_beams_version()->
	Beams = list_beam("./"),
	lists:map(fun(BeamFile)->
					  case beam_lib:version(BeamFile) of
						  {ok,{Mod,Version}}-> {Mod,Version};
						  _-> {BeamFile,0}
					  end
			  end, Beams).
	
list_beam(Dir)->
	case file:list_dir(Dir) of
		{ok,Files}-> BeamFiles = lists:filter(fun(File)->
													  case lists:reverse(File) of
														  "maeb."++_-> true; %% filter all .beam
														  _-> false
													  end
											  end, Files), 
					lists:map(fun(Beam)-> Dir ++ Beam end,BeamFiles);
		{error,Reason}-> io:format("list all beam file:~p~n",[Reason])
	end.

get_old_ver(Beam)->
	case ets:lookup(?BEAM_VERSION_ETS, Beam) of
		[]-> 0;
		[{_Beam,Version}]-> Version
	end.

up_module([])->
	io:format("module version updata complete ~n");

up_module(ModuleList)->
	[ModuleName | LastMoudles] =  ModuleList,
	Nodes = nodes(),
	io:format("begin to module ~p version update ...~n",[ModuleName]),
	lists:foreach(fun(Node)-> io:format("update ~p ...~n",[Node]),
							 rpc:call(Node, ?MODULE, up_one_module, [ModuleName])
							  end, Nodes),
	up_module(LastMoudles).

up_one_module(ModuleName)->
	BeamFile = 	atom_to_list(ModuleName) ++ ".beam",
	BeamAtom = list_to_atom(BeamFile),
	case beam_lib:version(BeamFile) of
		{ok,{Mod,Version}}-> 
				OldVer = get_old_ver(Mod),
				case OldVer =:= Version of
					 true->   
						io:format("module ~p no need updata!!!~n",[Mod]);
					 false-> 	
						c:l(BeamAtom),
						ets:insert(?BEAM_VERSION_ETS,{Mod,Version}),
						io:format("module ~p update!!!~n",[Mod])
				end;
		_->
			io:format("get ~p version error!!!~n",[BeamAtom])
		end.

up_option()->
	Nodes = nodes(),
	lists:foreach(fun(Node)-> 
						  io:format("begin to fresh option date ~p ... ~n",[Node]),
						  rpc:call(Node, env, fresh, []) end, Nodes),
	io:format("fresh option date complete ~n").

up_ets([])->
		io:format("updata ets complete ~n");
	
up_ets(EtsList)->
	[EtsName | LastEtsList] =  EtsList,
	up_one_ets(EtsName),
	up_ets(LastEtsList).
		
up_one_ets(EtsName)->
	lists:foreach(fun(Node)->
					NeedUpdate = 
						case db_tools:get_ets_table_mods(Node) of
							all->
								true;
							AppEtsIni->
								 lists:member(EtsName, AppEtsIni)		
						end,
					if
						not NeedUpdate-> ignor;
						true-> io:format("begin to update date ~p ... ~n",[Node]),
							 rpc:call(Node, applicationex, wait_ets_init_fliter, [EtsName])
					end
				end,  nodes()).

new()->
	io:format("just for test ~n").