%%%-------------------------------------------------------------------
%% @doc conbee public API
%% @end
%%%-------------------------------------------------------------------

-module(conbee_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok,_}=application:ensure_all_started(gun),   
    conbee_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
