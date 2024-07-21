%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(system_chat_db).
-include("system_chat_def.hrl").

-export([get_msg_option/1]).
  
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-export([get_fun_from_msg_option/1,get_scope_from_msg_option/1,get_type_from_msg_option/1]).

-define(CHAT_FORMAT_ETS,'$chat_format_ets$').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(system_chat, record_info(fields,system_chat), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{system_chat,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?CHAT_FORMAT_ETS, [set,named_table]).

init()->
	ets:delete_all_objects(?CHAT_FORMAT_ETS),
	case dal:read_rpc(system_chat) of 
		{ok,Results}->
			lists:foreach(fun(X)-> 
								  FunOpt = make_broad_msg(X) ,
								  ets:insert(?CHAT_FORMAT_ETS, FunOpt)
						  end, Results);
		_-> slogger:msg("read system_chat failed~n")
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_broad_msg(ChatOpt)->
	Id = get_id(ChatOpt),
	Fun = make_broad_fun(ChatOpt),
	Type = get_type(ChatOpt),
	Scope = get_scope(ChatOpt),
	{Id,Fun,Type,Scope}.

get_msg_option(Id)->
	case ets:lookup(?CHAT_FORMAT_ETS, Id) of
		[]-> [];
		[OptInfo]-> OptInfo
	end.

get_fun_from_msg_option(OptInfo)->
	element(2,OptInfo).

get_type_from_msg_option(OptInfo)->
	element(3,OptInfo).

get_scope_from_msg_option(OptInfo)->
	element(4,OptInfo).

%%
%% Local Functions
%%
get_msg(Option)->
	element(#system_chat.msg,Option).

get_color(Option)->
	element(#system_chat.color,Option).

get_type(Option)->
	element(#system_chat.type,Option).

get_scope(Option)->
	element(#system_chat.scope,Option).

get_id(Option)->
	element(#system_chat.id,Option).

get_color_replace(Option)->
	element(#system_chat.color_replace,Option).

make_broad_fun(ChatOpt)->
	ColrRep = get_color_replace(ChatOpt),
	MsgList =get_msg(ChatOpt),
	ColorList = get_color(ChatOpt),
	case length(MsgList) of
		1->
			[M] = MsgList,
			[C] = ColorList,
			fun([],_ClrArgs)->
				[C , M , []]
			end;
		2-> [M1,M2] = MsgList,
			[C0,C1] = ColorList,
			fun([A1],ClrArgs)->
					case ColrRep of
						[]-> [C0 , M1 , [] , A1, C1 ,M2 , []];
					    [1]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , []];
								[Clr]-> [C0 , M1 , [] , A1, Clr ,M2 , []]
							end
					end
			end;
		3-> [M1,M2,M3]= MsgList,
			[C0,C1,C2] = ColorList,
			fun([A1,A2],ClrArgs)->
					case ColrRep of
						[]-> [C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , []];
						[1]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , []];
								[Clr]-> [C0 , M1 , [] , A1, Clr ,M2 , [], A2 , C2 , M3 , []]
							end;
						[2]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , []];
								[Clr]-> [C0 , M1 , [] , A1, C1 ,M2 , [], A2 , Clr , M3 , []]
							end;
						[1,2]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , []];
								[Clr1,Clr2]-> [C0 , M1 , [] , A1, Clr1 ,M2 , [], A2 , Clr2 , M3 , []]
							end
					end
			end;
		4-> [M1,M2,M3,M4]= MsgList,
			[C0,C1,C2,C3] = ColorList,
			fun([A1,A2,A3],ClrArgs)->
					case ColrRep of
						[]-> [C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
						[1]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
								[Clr]->[C0 , M1 , [] , A1, Clr ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]]
							end;
						[2]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
								[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , Clr , M3 , [], A3, C3 ,M4 ,[]]
							end;
						[3]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
								[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, Clr ,M4 ,[]]
							end;
						[1,2]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
								[Clr1,Clr2]->[C0 , M1 , [] , A1, Clr1 ,M2 , [], A2 , Clr2 , M3 , [], A3, C3 ,M4 ,[]]
							end;
						[2,3]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[]];
								[Clr2,Clr3]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , Clr2 , M3 , [], A3, Clr3 ,M4 ,[]]
							end
					end
			end;
		5->[M1,M2,M3,M4,M5]= MsgList,
			[C0,C1,C2,C3,C4] = ColorList,
			fun([A1,A2,A3,A4],ClrArgs)->
					case ColrRep of
						[]-> [C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[]];
						[1]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[]];
								[Clr]->[C0 , M1 , [] , A1, Clr ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[], A4 ,C4 , M5 ,[]]
							end;
						[2]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[]];
								[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , Clr , M3 , [], A3, C3 ,M4 ,[], A4 ,C4 , M5 ,[]]
							end;
						[3]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[]];
								[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, Clr ,M4 ,[], A4 ,C4 , M5 ,[]]
							end;
						[4]->
							case ClrArgs of
								[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[]];
								[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[], A4 ,Clr , M5 ,[]]
							end
					end
		   end;
		6->
			[M1,M2,M3,M4,M5,M6]= MsgList,
			[C0,C1,C2,C3,C4,C5] = ColorList,
			fun([A1,A2,A3,A4,A5],ClrArgs)->
				case ColrRep of
					[]-> [C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[], A5 ,C5 , M6 ,[]];
					[1]->
						case ClrArgs of
							[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[], A5 ,C5 , M6 ,[]];
							[Clr]->[C0 , M1 , [] , A1, Clr ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[], A4 ,C4 , M5 ,[], A5 ,Clr , M6 ,[]]
						end;
					[2]->
						case ClrArgs of
							[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[], A5 ,C5 , M6 ,[]];
							[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , Clr , M3 , [], A3, C3 ,M4 ,[], A4 ,C4 , M5 ,[], A5 ,Clr , M6 ,[]]
						end;
					[3]->
						case ClrArgs of
							[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[], A5 ,C5 , M6 ,[]];
							[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, Clr ,M4 ,[], A4 ,C4 , M5 ,[], A5 ,Clr , M6 ,[]]
						end;
					[4]->
						case ClrArgs of
							[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[], A5 ,C5 , M6 ,[]];
							[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[], A4 ,Clr , M5 ,[], A5 ,Clr , M6 ,[]]
						end;
					[5]->
						case ClrArgs of
							[]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[] , A4 ,C4 , M5 ,[] , A5 ,C5 , M6 ,[]];
							[Clr]->[C0 , M1 , [] , A1, C1 ,M2 , [], A2 , C2 , M3 , [], A3, C3 ,M4 ,[], A4 ,C4 , M5 ,[],A5,Clr,M6,[]]
						end
				end
			end;
		_->error
	end.

