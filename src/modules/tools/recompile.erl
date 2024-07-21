%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(recompile).

-include_lib("kernel/include/file.hrl").

-behaviour(gen_server).
-export([start/0, start_link/0]).
-export([stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% TOOL API 
-export([compile_app/1,copy_ext/6]).

-record(state, {last}).
-define(SEONDS_RECOMPILE,10).
%% External API

%% @spec start() -> ServerRet
%% @doc Start the reloader.
start() ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

%% @spec start_link() -> ServerRet
%% @doc Start the reloader.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @spec stop() -> ok
%% @doc Stop the reloader.
stop() ->
    gen_server:call(?MODULE, stop).

%% gen_server callbacks

%% @spec init([]) -> {ok, State}
%% @doc gen_server init, opens the server in an initial state.
init([]) ->
	filelib:ensure_dir("../log/"),
	error_logger:logfile({open, "../log/recompile.log"}),
	timer:send_after(timer:seconds(1), doit), %% run at once ,first time! 
    {ok, #state{last = stamp()}}.

%% @spec handle_call(Args, From, State) -> tuple()
%% @doc gen_server callback.
handle_call(stop, _From, State) ->
    {stop, shutdown, stopped, State};
handle_call(_Req, _From, State) ->
    {reply, {error, badrequest}, State}.

%% @spec handle_cast(Cast, State) -> tuple()
%% @doc gen_server callback.
handle_cast(_Req, State) ->
    {noreply, State}.

%% @spec handle_info(Info, State) -> tuple()
%% @doc gen_server callback.
handle_info(doit, State) ->
    Now = stamp(),
    _ = doit(State#state.last, Now),
	timer:send_after(timer:seconds(?SEONDS_RECOMPILE), doit),
    {noreply, State#state{last = Now}};
handle_info(_Info, State) ->
    {noreply, State}.

%% @spec terminate(Reason, State) -> ok
%% @doc gen_server termination callback.
terminate(_Reason, State) ->
    ok.


%% @spec code_change(_OldVsn, State, _Extra) -> State
%% @doc gen_server code_change callback (trivial).
code_change(_Vsn, State, _Extra) ->
    {ok, State}.

doit(From, To) ->
	case make:all() of
		up_to_date-> 
			Stamp = stamp(),
			{{Y,M,D},{H,Min,S}}=Stamp,
			slogger:msg("Check finish @ ~p/~s/~s-~s:~s:~s~n",[Y,
															str_num:make_int_str2(M),
															str_num:make_int_str2(D),
															str_num:make_int_str2(H),
															str_num:make_int_str2(Min),
															str_num:make_int_str2(S)]);
		error->
			Stamp = stamp(),
			{{Y,M,D},{H,Min,S}}=Stamp,
			slogger:msg("Check error  @ ~p/~s/~s-~s:~s:~s~n",[Y,
															str_num:make_int_str2(M),
															str_num:make_int_str2(D),
															str_num:make_int_str2(H),
															str_num:make_int_str2(Min),
															str_num:make_int_str2(S)])
	end.

stamp() ->
    erlang:localtime().

compile_app(Args)->
	case Args of
		[InputDir,OutDir]->compile_app(InputDir,OutDir);
		_-> io:format("Error input for compile_app")
	end.

compile_app(InputDir,OutDir)->
	NewInput = if is_atom(InputDir) ->atom_to_list(InputDir);
				  true-> InputDir
			   end,
	NewOut = if is_atom(OutDir) ->atom_to_list(OutDir);
				  true-> OutDir
			   end,
	copy_ext(NewInput,NewOut,
			 ".app.src",".app",
			 "Copy success app:~p~n",
			 "Copy failed app:~p~n").

get_filename(Path)->
	case string:rchr(Path, $/) of
		0-> Path;
		I-> string:sub_string(Path, I+1)
	end.					 
	
convert_ext(File,SrcExt,NewExt)->
	case string:rstr(File, SrcExt) of
		0->File++NewExt; 
		I->string:sub_string(File, 1, I-1) ++ NewExt
	end.

convert_dest_path(SrcFile,OutDir,SrcExt,NewExt)->
	FileName = get_filename(SrcFile),
	case lists:last(OutDir) of
		$/ -> OutDir ++ convert_ext(FileName,SrcExt,NewExt);
		_->OutDir ++"/" ++ convert_ext(FileName,SrcExt,NewExt)
	end.
	
get_file_md5(File)->
	case file:read_file(File) of
		{ok,Binary}->erlang:md5(Binary);
		_-> <<>>
	end.

copy_ext(InputDir,OutDir,SrcExt,NewExt,OKPrompt,FaildPrompt)->
	CopyOp = fun(SrcFile)->
					 case string:right(SrcFile, string:len(SrcExt)) of
						 SrcExt->
							 DstFile = convert_dest_path(SrcFile, OutDir,SrcExt,NewExt),
							 SrcMd5 = get_file_md5(SrcFile),
							 DstMd5 = get_file_md5(DstFile),
							 if SrcMd5=:=DstMd5 ->
									ignor;
								true->
									case file:copy(SrcFile, DstFile) of
										{ok,_}->
											case OKPrompt of										
												[]-> ignor;
												_->io:format(OKPrompt,[DstFile])
											end;
										_->
											case FaildPrompt of
												[]-> ignor;
												_->io:format(FaildPrompt,[DstFile])
											end
									end
							 end;
						 _-> 
							 nothing
					 end
			 end,
	ExtFilter = ".*"++SrcExt,
	filelib:fold_files(InputDir, 
					   ExtFilter, 
					   true,
					   fun (F, _Acc) ->
								CopyOp(F) 
					   end,[]).
