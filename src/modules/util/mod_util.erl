%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(mod_util).

-compile(export_all).

get_all_module()->
	{ok,ALLFiles} = file:list_dir("./"),
	lists:foldl(
	  			fun(FileName,AccModules)->
					case get_module_by_beam(FileName) of
						[]->
							AccModules;
						NewModule->
							[NewModule|AccModules]	
					end
				end, [] ,ALLFiles).

load_module_if_not_loaded(NewModule)->
	case erlang:module_loaded(NewModule) of
		false->
			c:l(NewModule);
		_->
			nothing
	end.

get_module_by_beam(FileName)->
	case string:right(FileName,5) of
		".beam"->
			erlang:list_to_atom(string:substr(FileName,1,string:len(FileName) - 5));
		_->
			[]
	end.
	
%%Warning!!!!!run slowly!
behaviour_apply(Behaviour,Func,Args)->
	lists:foreach(fun(Mod)->
					safe_aplly(Mod, Func, Args)
		end, get_all_behaviour_mod(Behaviour)).

get_all_behaviour_mod(Behaviour)->
	lists:filter(fun(Mod)->is_mod_is_behaviour(Mod,Behaviour) end,get_all_module()).

is_mod_is_behaviour(Mod,Behav)->
	is_behaviour_attributes(Mod:module_info(attributes),Behav).

is_behaviour_attributes([],_)->
	false;
is_behaviour_attributes([{behaviour,Behaviours}|Tail],Behav)->
	case lists:member(Behav,Behaviours) of
		true->
			true;
		_->
			is_behaviour_attributes(Tail,Behav)
	end;
is_behaviour_attributes([_|Tail],Behav)->
	is_behaviour_attributes(Tail,Behav).	

safe_aplly(Mod, Func, Args)->
	try
		erlang:apply(Mod, Func, Args)
	catch 
		E:R->
			slogger:msg("~p:~p ~p ~p ~p ~n",[Mod, Func, Args,E,R])
	end.
	