%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(npc_script).

-export([run_script/2]).

%%return: []/Result
run_script(Fun,Args)->
	case get(npc_script) of
		[]->
			[];
		Script->
			try
				apply(Script,Fun,Args)
			catch
				_E:Reason->
					case Reason of
						undef->
							nothing;
						_->
							slogger:msg("npc ai error Script~p Reason ~p ~p ~n",[Script,Reason,erlang:get_stacktrace()])
					end,
					[]
			end
	end.