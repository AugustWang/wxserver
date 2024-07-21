%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrian
%% Created: 2010-7-22
%% Description: TODO: Add description to compute_buffers
-module(compute_buffers).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([compute/10,compute/5]).

%%
%% API Functions
%%


%%
%% return {NewAttributes,NewAllBuffers,ChangeAttributes}
%%
%% NewAttributes:[{hpmax,NewValue}|...]
%%
%% ChangeAttributes:[{agile,NewValue}]
%%
%% NewAttributes include ChangeAttributes
%%
compute(ClassId,Level,LastAttributes,LastBuffers,AddBuffers,RemoveBuffers,AddBaseAttr,RemoveBaseAttr,AddOtherAttr,RemoveOtherAttr)->
	CurrentBuffers = combin_buffers(LastBuffers , AddBuffers , RemoveBuffers),
	CurrEffectList = get_buffers_effect(CurrentBuffers) ++ AddOtherAttr,
	RemoveEffectList = get_buffers_effect(RemoveBuffers) ++ RemoveOtherAttr,
	{AllAttribute,ChangeAttributes} = case LastAttributes of 
							[]-> compute_effects:compute_attributes(ClassId,Level);
							_->	compute_effects:compute(LastAttributes,ClassId, Level, CurrEffectList,RemoveEffectList,AddBaseAttr,RemoveBaseAttr)
						end,
	{AllAttribute,CurrentBuffers,ChangeAttributes}.


compute(NpcId,LastAttributes,LastBuffers,AddBuffers,RemoveBuffers)->
	CurrentBuffers = combin_buffers(LastBuffers , AddBuffers , RemoveBuffers),
	CurrEffectList = get_buffers_effect(CurrentBuffers),
	RemoveEffectList = get_buffers_effect(RemoveBuffers),
	{AllAttribute,ChangeAttributes} = case LastAttributes of
										[]->compute_effects:compute_attributes(NpcId);
										_ ->compute_effects:compute(LastAttributes,NpcId, 
																CurrEffectList,
																RemoveEffectList)
						end,
	{AllAttribute,CurrentBuffers,ChangeAttributes}.
	
%%
%% Local Functions
%%

combin_buffers(LastBuffers,AddBuffers,RemoveBuffers)->
	RemovedBuffers = lists:filter(fun(BufferInfo)-> not lists:member(BufferInfo, RemoveBuffers) end, LastBuffers),
	RemovedBuffers++AddBuffers.

get_buffers_effect(Buffers)->
	lists:foldl(fun({BufferId,BufferLevel},LastAcc)-> LastAcc ++ buffer_op:get_buffer_attr_effect(BufferId,BufferLevel)end,[],Buffers ).


