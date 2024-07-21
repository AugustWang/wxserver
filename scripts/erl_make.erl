%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
#!/usr/bin/env escript
%% -*- erlang -*- 
%%! -smp enable -sname factorial -mnesia debug verbose 
main([Options]) -> 
	compile_mmake(),
	compile_all(Options);

main(_) ->
	compile_mmake(),
	compile_all(). 

compile_mmake()->
	MMake = case filelib:wildcard("../src/mmake.erl") of
				[]-> 
					case filelib:wildcard("../src/*/*/mmake.erl") of
						[]-> [];
						[MMakeF]->MMakeF
					end
			end,

	case make:files([MMake],[{outdir, "../ebin"}]) of
		error-> io:format("can not compile mmake.erl\n"),
				halt(1);
		_->	
			ok
	end.

compile_all(Options)->
	case mmake:all(get_cpu_cores(),[Options]) of 
		up_to_date ->
			halt(0); 
		error -> 
			halt(1) 
	end.

compile_all()->
	code:add_patha("../ebin"),
	case mmake:all(get_cpu_cores()) of 
		up_to_date ->
			make_version(),
			halt(0); 
		error -> 
			halt(1) 
	end.

%%
%%return all cores - 1  
%%
get_cpu_cores()->
	erlang:min(erlang:system_info(logical_processors)-1,1). 

make_version()->
	{{Y,M,D},{H,Min,_}} =  erlang:localtime(),
	VersionString = util:sprintf("~p.~2..0w.~2..0w.~2..0w.~2..0w", [Y,M,D,H,Min]),
	VersionCode = version_code(VersionString),
	compile_beam(VersionCode).
	
version_code(VersionString)->
	Header = 
		"-module(version).
		-include(\"../include/login_pb.hrl\").
		-export([make_version/0,version/0]).\n",
	Fun1 = 
		"make_version()->
			login_pb:encode_server_version_s2c(#server_version_s2c{v = \"" 
			++ VersionString ++
			"\"}).\n",
	Fun2 = 
		"version()->\"" 
			++ VersionString ++
		"\".\n",
	lists:flatten([Header,Fun1,Fun2]).
	

compile_beam(String)->
	{Module,Code} = dynamic_compile:from_string(String,[debug_info,nowarn_unused_vars, nowarn_unused_function,native]),
	VersionBeamFilePath = "../ebin/" ++ atom_to_list(Module) ++ ".beam",
	case file:open(VersionBeamFilePath, [write,binary]) of
		{ok,F}->
			file:write(F,Code),
			file:close(F);
		{_,_}-> io:format("cann't open ~p \n",[VersionBeamFilePath])
	end.
	
	