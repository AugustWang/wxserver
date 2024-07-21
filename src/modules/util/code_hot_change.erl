%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: SQ.Wang
%% Created: 2011-12-15
%% Description: TODO: Add description to code_hot_change
-module(code_hot_change).

%%
%% Include files
%%
-define(OPTION_FILE_NAME,"code_change.option").
%%
%% Exported Functions
%%
-export([version_up_module/0,get_version/0]).

%%
%% API Functions
%%
get_version()->
	version:version().

version_up_module()->
	inets:start(permanent),
	BeamList = get_beam_list(),
	backup_oldbeam(BeamList),
	delete_oldbeam(BeamList),
	delete_option(),
	case download_beam(BeamList) of
		[]->
			version_up(BeamList),
			delete_backup_beam(BeamList),
			{ok};
		FailedDBeam->
			change_backup_filename(BeamList),
			{error,FailedDBeam}
	end.

get_beam_list()->
	OptionName = env:get(code_change_option,?OPTION_FILE_NAME),
	OptUrl = make_opturl(OptionName),
	case download(OptUrl,OptionName) of
		ok->
			case read_file(OptionName) of
				{error,_}->
					[];
				BeamList->
					BeamList
			end;
		_->
			[]
	end.

backup_oldbeam(BeamList)->
	Func = fun({Beam,_})->
				   NewBeam = make_new_file(Beam),
				   file:copy(Beam,NewBeam)
		   end,
	lists:foreach(Func,BeamList).

delete_oldbeam(BeamList)->
	Func = fun({Beam,_})->
				   file:delete(Beam)
		   end,
	lists:foreach(Func,BeamList).

download_beam(BeamList)->
	Func = fun({Beam,Url},Acc)->
				   case download(Url,Beam) of
					   ok->
						   Acc;
					   _->
						   [Beam|Acc]
				   end
		   end,
	lists:foldl(Func,[],BeamList).

version_up(BeamList)->
	Func = fun({Beam,_})->
				   case get_module_by_beam(Beam) of
					   []-> ignor;
					   Module ->
						   lists:foreach(fun(N)-> rpc:call(N,c,l,[Module]) end ,nodes())
				   end
		   end,
	lists:foreach(Func,BeamList).

delete_option()->
	OptionName = env:get(code_change_option,?OPTION_FILE_NAME),
	file:delete(OptionName).

delete_backup_beam(BeamList)->
	Func = fun({Beam,_})->
				   NewBeam = make_new_file(Beam),
				   file:delete(NewBeam)
		   end,
	lists:foreach(Func,BeamList).

change_backup_filename(BeamList)->
	Func = fun({Beam,_})->
				   NewBeam = make_new_file(Beam),
				   file:rename(NewBeam, Beam)
		   end,
	lists:foreach(Func,BeamList).
				   
download(Url,FileName)->
	case httpc:request(Url) of
		{ok, Result}->
			case erlang:element(1, Result) of 
				{"HTTP/1.1",200,"OK"}->
					write_file(FileName,Result);
				_->
					failed
			end;
		_->
			failed
	end.

write_file(FileName,Result)->
	case file:write_file(FileName,erlang:element(3,Result)) of
		ok->
			ok;
		_->
			failed
	end.

read_file(FileName)->
	case file:consult(FileName) of
		{ok,Term}->
			Term;
		Reason->
			{error,Reason}
	end.

make_opturl(OptionName)->
	lists:append("http://zygm0.my4399.com/",OptionName).

make_new_file(File)->
	File ++ ".new".

get_module_by_beam(Beam)->
	case string:tokens(Beam,".") of
		[Module,_]->
			Module;
		_->
			[]
	end.






