%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-10-9
%% Description: TODO: Add description to senswords
-module(senswords).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([word_is_sensitive/1,import_words/2,replace_sensitive/1]).
-compile(export_all).
-export([init/0,create/0]).
-behaviour(ets_operater_mod).

%%
%% API Functions
%%
%%
%% Include files
%%
-define(ETS_SENSITIVE,'$game_sensitive_words$').
-define(ETS_SENSITIVE_BLACKNAME,'$game_sensitive_words_blackname$').
-define(ETS_SENSITIVE_BLACKHEADER,'game_sensitive_words_blackheader$').


%%
%% Exported Functions
%%

create()->
	ets:new(?ETS_SENSITIVE, [named_table,set]),
	ets:new(?ETS_SENSITIVE_BLACKNAME, [named_table,set]),
	ets:new(?ETS_SENSITIVE_BLACKHEADER, [named_table,set]).
%%
%% API Functions
%%
init()->
	ets:delete_all_objects(?ETS_SENSITIVE),
	ets:delete_all_objects(?ETS_SENSITIVE_BLACKNAME),
	ets:delete_all_objects(?ETS_SENSITIVE_BLACKHEADER),
	DictionaryFile = env:get(sensitive,[]),
	BlackNameFile = env:get(nameissensitive,[]),
	BlackHeaderFile = env:get(nameisblackheader,[]),
	import_black_words(BlackNameFile,?ETS_SENSITIVE_BLACKNAME),
	import_words(BlackHeaderFile,?ETS_SENSITIVE_BLACKHEADER),
	add_word_to_ets(<<"娓稿">>,?ETS_SENSITIVE_BLACKHEADER),
	add_word_to_ets(<<"绾櫧">>,?ETS_SENSITIVE_BLACKHEADER),
	import_words(DictionaryFile,?ETS_SENSITIVE).

%%
%% Local Functions
%%

import_black_words(File,EtsName)->
	case file:consult(File) of
		{ok, [Terms]}-> 
			lists:foreach(fun(X)->
								  UniString = unicode:characters_to_list(X,unicode),
								  ets:insert(EtsName, {UniString})
						   end, Terms);
		{error,Reason}->
			slogger:msg("import_black_words error:~p~n",[Reason])
	end.

import_words(File,EtsName)->
	case file:consult(File) of
		{ok, [Terms]}->
			lists:foreach(fun(X)->
								  add_word_to_ets(X,EtsName)
						  end,Terms);
		{error,Reason}->
			slogger:msg("import_words error:~p~n",[Reason])
	end.
	

add_word_to_ets(Word,EtsName)->
	UniString = unicode:characters_to_list(Word,unicode),
	case UniString of
		[]-> ignor;
		_->
			[HeadChar|_Left] = UniString,
			case ets:lookup(EtsName, HeadChar) of
				[]-> ets:insert(EtsName, {HeadChar,[UniString]});
				[{_H,OldList}]->
					case lists:member(UniString,OldList) of
						false->ets:insert(EtsName,{HeadChar,[UniString|OldList]});
						true-> ignor
					end
			end
	end.

word_is_sensitive([])->
	false;
word_is_sensitive(Utf8String) when is_list(Utf8String)->
	Utf8Binary = list_to_binary(Utf8String),
	word_is_sensitive(Utf8Binary);
word_is_sensitive(Utf8Binary) when is_binary(Utf8Binary)->
	UniString = unicode:characters_to_list(Utf8Binary,unicode),
	case word_is_sensitive_kernel(UniString) of
		true-> true;
		false->
		case match_blackheader_char_wordlist(UniString) of
			true-> true;
			false->match_black_char_wordlist(UniString)
		end
	end.
word_is_sensitive_kernel([])->
	false;
word_is_sensitive_kernel(UniString)->
	[HeadChar|TailString] = UniString,
	UniStrLen = length(UniString),
	WordList = get_key_char_wordlist(HeadChar),
	Match = fun(Word)->
					WordLen = length(Word),
					if WordLen> UniStrLen-> false; %%灏忎簬鏁忔劅璇嶉暱搴︾洿鎺alse
					   WordLen =:=	UniStrLen->	UniString =:= Word; %%绛変簬鐩存帴姣旇緝
					   true-> %%澶т簬鍙栬瘝姣旇緝
						   HeadStr = lists:sublist(UniString,WordLen),
						   HeadStr =:= Word
					end
			end,
	case lists:any(Match, WordList) of
		true-> true;
		false-> word_is_sensitive_kernel(TailString)
	end.
		
replace_sensitive(Utf8String) when is_binary(Utf8String)->
	UniString = unicode:characters_to_list(Utf8String,unicode),
	ReplacedString = replace_sensitive_kernel(UniString,[]),
	unicode:characters_to_binary(ReplacedString, utf8);
replace_sensitive(InputString)when is_list(InputString)->
	Utf8Binary = list_to_binary(InputString),
	replace_sensitive(Utf8Binary);
replace_sensitive(InputString)->
	InputString.

match_of_replace_sensitive_kernel(Word,Last,InputString,InputStrLen)->
	case Last of
		0->
		WordLen = length(Word),
		if WordLen>InputStrLen -> 0;
			WordLen=:=InputStrLen->
				if(InputString =:= Word)->
						WordLen;
				  true->
				  		0
				  end;
			true->
				HeadStr = lists:sublist(InputString,length(Word)),
				if(HeadStr =:= Word)->
					WordLen;
				  true->
				  	0
				  end
				end;
			_-> Last
		end.

replace_sensitive_kernel([],LastRepaced)->
	LastRepaced;
replace_sensitive_kernel(InputString,LastReplaced)->
	[HeadChar|TailString] = InputString,
	WordList = get_key_char_wordlist(HeadChar),
	InputStrLen = length(InputString),
	
	Match = fun(Word,Last)->
			match_of_replace_sensitive_kernel(Word,Last,InputString,InputStrLen)
			end,
			
	case lists:foldl(Match,0 ,WordList) of
		0-> 
		NewReplaced = LastReplaced ++ [HeadChar],
		replace_sensitive_kernel(TailString,NewReplaced);
		SensWordLen->
			LeftString = lists:sublist(InputString, SensWordLen + 1, InputStrLen - SensWordLen ),
			NewReplaced = LastReplaced ++ make_sensitive_show_string(SensWordLen),
			replace_sensitive_kernel(LeftString ,NewReplaced)
	end.

get_key_char_wordlist(KeyChar)->		
	case ets:lookup(?ETS_SENSITIVE,KeyChar) of
		[]-> [];
		[{_H,WordList}]-> WordList
	end.

match_black_char_wordlist(String)->
	case ets:lookup(?ETS_SENSITIVE_BLACKNAME,String) of
		[]-> false;
		_-> true
	end.


for_blackheader_any(Item_of_WordList,InputString)->
	WordLen = length(Item_of_WordList),
	InputHeader = string:substr(InputString,1,WordLen),
	if InputHeader=:=Item_of_WordList-> true;
		true-> false
	end.


match_blackheader_char_wordlist(InputString)->
	[HeadChar|_TailString] = InputString,
	BlackHeaderList = case ets:lookup(?ETS_SENSITIVE_BLACKHEADER,HeadChar) of
						[]-> [];
						[{_H,WordList}]->WordList
					  end,
	lists:any(fun(X)-> for_blackheader_any(X,InputString) end,BlackHeaderList).
	
	
make_sensitive_show_string(1)->
	"*";
make_sensitive_show_string(2)->
	"*&";
make_sensitive_show_string(3)->
	"*&^";
make_sensitive_show_string(4)->
	"*&^%";
make_sensitive_show_string(5)->
	"*&^%$";
make_sensitive_show_string(6)->
	"*&^%$#";
make_sensitive_show_string(7)->
	"*&^%$#@";
make_sensitive_show_string(8)->
	"*&^%$#@!";
make_sensitive_show_string(N)->
	M = N rem 8,
	C = N div 8,
	L1 = make_sensitive_show_string(M),
	L2 = lists:append(lists:duplicate(C,"*&^%$#@!")),
	lists:append([L2,L1]).

