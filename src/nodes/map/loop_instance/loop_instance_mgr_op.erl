%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: zhanglei
%% Created: 2012-1-4
%% Description: TODO: Add description to loop_instance_mgr_op
-module(loop_instance_mgr_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%

%%
%%loop_instance_mgr_ets  {{groupid,type},node,proc}
%%
init()->
	ets:new(loop_instance_mgr_ets,[set, protected, named_table]).

%%return {node,procname,MapProcName} | exist | error
start_instance(GroupId,Type,CreatorInfo)->
	%%find instance first	
	case get_instance(GroupId,Type) of
		[]->
			case instanceid_generator:get_procname({GroupId,Type}) of
				[]->
					error;
				{exsit,_ProcName}->
					exist;
				ProcName->
					[Node] = node_util:get_low_load_node(1),
					case rpc:call(Node,loop_instance_proc_sup,start_child, [ProcName,GroupId,Type,CreatorInfo]) of
						{ok,_}->
							add_instance({{GroupId,Type},Node,ProcName}),
							{ok,Node,ProcName};
						_->
							instanceid_generator:safe_turnback_proc(ProcName),
							error
					end
			end;
		_->
			exist
	end.

check_instance(GroupId,Type)->
	case get_instance(GroupId,Type) of
		[]->
			ok;
		_->
			exist
	end.

stop_instance(GroupId,Type,Node,ProcName)->
	case get_instance(GroupId,Type) of
		[]->
			nothing;
		_GroupInstanceInfo->
			delete_instance(GroupId,Type),
			rpc:call(Node,loop_instance_proc_sup,stop_child, [ProcName]),
			instanceid_generator:safe_turnback_proc(ProcName)		
	end.
%%
%% Local Functions
%%
get_instance(GroupId,Type)->
	case ets:lookup(loop_instance_mgr_ets,{GroupId,Type}) of
		[]->
			[];
		[GroupInstanceInfo]->
			GroupInstanceInfo	
	end.

add_instance(InstanceInfo)->
	ets:insert(loop_instance_mgr_ets,InstanceInfo).

delete_instance(GroupId,Type)->
	ets:delete(loop_instance_mgr_ets,{GroupId,Type}).


		
