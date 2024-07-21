%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%% Author: adrianx
%% Created: 2010-11-19
%% Description: TODO: Add description to dmp_op
-module(dmp_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).
%%
%% API Functions
%%



%%
%% Local Functions
%%

async_write(BundleId,Object)->
	dmp_base:write(BundleId,Object).

async_write(BundleId,Table,TableKey,FieldIndex,FieldValue)->
	dmp_base:write(BundleId,Table,TableKey,FieldIndex,FieldValue).

async_write(BundleId,Table,TableKey,FieldIndex,FieldKey,FieldReplaceTuple)->
	dmp_base:write(BundleId,Table,TableKey,FieldIndex,FieldKey,FieldReplaceTuple).

async_delete(BundleId,Table,TableKey)->
	dmp_base:delete(BundleId,Table,TableKey).

flush_bundle(BundleId)->
	dmp_base:flush_bundle(BundleId).

flush_all()->
	dmp_base:flush_all().

sync_write(BundleId,Object)->
	dmp_base:sync_write(BundleId, Object).

sync_write(BundleId,Table,TableKey,FieldIndex,FieldValue)->
	dmp_base:sync_write(BundleId,Table,TableKey,FieldIndex,FieldValue).

sync_write(BundleId,Table,TableKey,FieldIndex,FieldKey,FieldReplaceTuple)->
	dmp_base:sync_write(BundleId,Table,TableKey,FieldIndex,FieldKey,FieldReplaceTuple).

sync_delete(BundleId,Table,TableKey)->
	dmp_base:sync_delete(BundleId,Table,TableKey).

