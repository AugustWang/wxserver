%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(global_node).

%%
%% Include files
%%
-define(GLOBAL_ETS,global_node_ets).

%%
%% Exported Functions
%%

-export([init/0,is_in_global/1,regist_global_proc/2,get_global_proc_node/1,get_all_global_nodes/0]).

init()->
	try
		ets:new(?GLOBAL_ETS, [named_table,public ,set])
	catch
		E:R-> slogger:msg("global_node create error ~p ~p ~n",[E,R])
	end.

get_all_global_nodes()->
	ets:tab2list(?GLOBAL_ETS).

is_in_global(ModuleName)->
	case ets:lookup(?GLOBAL_ETS,ModuleName)  of
		[] ->
			false;
		[_] ->
			true
	end.

regist_global_proc(ModuleName,NodeName)->
	ets:insert(?GLOBAL_ETS,{ModuleName,NodeName}).

get_global_proc_node(ModuleName)->
	case get(global_nodes) of
		undefined->
			case ets:lookup(?GLOBAL_ETS,ModuleName) of
				[]->
					slogger:msg("ERROR global Missed ModuleName ~p in ~p ~n",[ModuleName,node()]),
					get_proc_node(ModuleName);
				[{_,Node}]->
					Node
			end;
		GlobalNodes->
			case lists:keyfind(ModuleName, 1, GlobalNodes) of
				{_,Node}->
					Node;
				_->
					slogger:msg("ERROR global Missed ModuleName ~p in ~p nodes ~p ~n",[ModuleName,node(),nodes()]),
					case get_proc_node(ModuleName) of
						[]->
							slogger:msg("ERROR global error config module ~p in ~p ~n",[ModuleName,node()]),
							[];
						Node->
							put(global_nodes,[{ModuleName,Node}|get(global_nodes)])
					end
			end
	end.

get_proc_node(ModuleName)->
	AllNodes = node_util:get_all_nodes_for_global(),
	MatchNodes = lists:filter(fun(CurNode)->
		node_util:check_snode_match(ModuleName, CurNode)				 
	end, AllNodes),
	case MatchNodes of
		[]->
			[];
		[MatchNode|_T]->
			regist_global_proc(ModuleName,MatchNode),
			MatchNode
	end.

