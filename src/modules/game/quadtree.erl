%%% -------------------------------------------------------------------
%%% 9秒社团全球首次开源发布
%%% http://www.9miao.com
%%% -------------------------------------------------------------------
%%% File    : quadtree.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 21 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(quadtree).

-compile(export_all).

%% Description: build a quad tree that uses map rect and the view distance.
%% Rect: the whole area;
%% View: the distance of view;
%% @return: {true, Tree}|{error, Reason}
%%
build(Rect, View) ->
    {{L, T}, {R, B}} = Rect,
    Width = erlang:max(R - L, B - T),

    case Width =< View * 2 of
	true ->
	    {error, "map size too small!~n"};
	false ->
	    Depth = depth(Width, View, 1),
	    Tree = build({Rect, Depth}),
	    {true, Tree}
    end.

%% Description: build a quad tree
%% Rect: the whole area;
%% Depth: the level that you want to split the area;
%% @return: the quad tree
%%
build({Rect, Depth}) ->
    %% reduce the depth level
    case Depth of 
 	0 ->
 	    Rect;
 	_ ->
 	    [Rect1, Rect2, Rect3, Rect4] = rectangle:split(Rect),
 	    RectSplited1 = build({Rect1, Depth - 1}),
 	    RectSplited2 = build({Rect2, Depth - 1}),
 	    RectSplited3 = build({Rect3, Depth - 1}),
 	    RectSplited4 = build({Rect4, Depth - 1}),

 	    {Rect, [RectSplited1, RectSplited2, RectSplited3, RectSplited4]}
    end.

%% Description: check whether the tree contains the point
%% contains -> true|false.
%%
contains(Point, Tree) ->
    {Bounding, _} = Tree,
    rectangle:contains(Bounding, Point).

%% Description: get the depth of the map be splited
%% depth -> int(). 
%%
depth(RectWidth, View, Depth) ->
    case RectWidth =< View of
	true ->
	    Depth - 1; %% the size is 2*RectWidth
	false ->
	    depth(gm_math:ceiling(RectWidth/2), View, Depth + 1)
    end.


%% Description: get the grid that contains the point.
%% hit -> {true, rect}|{false}
%%
hit(Point, {{L,T}, {R,B}}) ->
    Rect = {{L,T}, {R,B}},
    case rectangle:contains(Rect, Point) of
	true ->
	    {true, Rect};
	false ->
	    {false}
    end;
hit(Point, {Bounding, Nodes}) ->
    case rectangle:contains(Bounding, Point) of
	true ->
	    hit(Point, Nodes);
	false ->
	    {false}
    end;
hit(Point, [H|T]) ->
    case hit(Point, H) of
	{true, Rect} ->
	    {true, Rect};
	{false} ->
	    hit(Point, T)
    end.



