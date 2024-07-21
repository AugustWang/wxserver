%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: Administrator
%% Created: 2011-5-23
%% Description: TODO: Add description to language
-module(language).

%%
%% Include files
%%
-define(ETS_LANGUAGE,'$language_ets$').
%%
%% Exported Functions
%%
-export([create/0,init/0,get_string/1]).
-behaviour(ets_operater_mod).
%%
%% API Functions
%%
create()->
	ets:new(?ETS_LANGUAGE, [named_table,set]).

init()->
	ets:delete_all_objects(?ETS_LANGUAGE),
	OptionFile = env:get(language,[]),
	import_language(OptionFile,?ETS_LANGUAGE).

get_string(Id)->
	case ets:lookup(?ETS_LANGUAGE,Id) of
		[]-> [];
		[{_,String}]-> String
	end.
%%
%% Local Functions
%%
import_language(File,EtsName)->
	case file:consult(File) of
		{ok, [Terms]}->
			lists:foreach(fun(X)->
							{Id,StrBin} = X,	
							ets:insert(EtsName,{Id,binary_to_list(StrBin)})
						  end,Terms);
		{error,Reason}->
			slogger:msg("import_language error:~p~n",[Reason])
	end.
