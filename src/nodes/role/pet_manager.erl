%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
-module(pet_manager).

-compile(export_all).

-define(PETS_DB,local_pets_datatbase).

regist_pet_info(PetId,PetInfo) ->
	ets:insert(?PETS_DB, {PetId,PetInfo}).

unregist_pet_info(PetId) ->
	ets:delete(?PETS_DB, PetId).

get_pet_info(PetId) ->
	try
		Pet = ets:lookup(?PETS_DB, PetId),
		case Pet  of
			[] ->
				undefined;
			[{_, PetInfo}] ->
				PetInfo
		end
	catch
		_:_->
		slogger:msg("get_role_info ets:lookup pet error:~p~n",[PetId]),
		undefined
	end.