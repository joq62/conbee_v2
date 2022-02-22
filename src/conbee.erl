%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created : 
%%% Node end point 
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(conbee).   

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(SERVER,?MODULE).

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state, {pid,
		wanted_temp,
		actual_temp,
	        actual_door,
	        actual_visitor}).



%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(CheckIntervall,20*1000).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------

-export([check/0]).
-export([
	 sensors_raw/0,
	 sensors/0,
	 ping/0
	]).

-export([
	 boot/0,
	 start/0,
	 stop/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================


%%-----------------------------------------------------------------------
%% Asynchrounus Signals
boot()->
    ok=application:start(?MODULE).
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).




%%---------------------------------------------------------------
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

sensors_raw()-> 
    gen_server:call(?SERVER, {sensors_raw},infinity).

sensors()-> 
    gen_server:call(?SERVER, {sensors},infinity).

%%----------------------------------------------------------------------
check()-> 
    gen_server:cast(?MODULE, {check}).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    % call gun_client 
 

   % spawn(fun()->do_check() end),
     {ok, #state{}}.
  %  {ok, #state{actual_temp=ActualTemp,
%	        actual_door=ActualDoor,
%		actual_visitor=ActualVisitor,
%		wanted_temp=WantedTemp}}.
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({sensors_raw},_From,State) ->
   % io:format("~p~n",[{temp,?MODULE,?FUNCTION_NAME,?LINE}]),
    Reply= sensors:get_info_raw(),
    {reply, Reply, State};

handle_call({sensors},_From,State) ->
   % io:format("~p~n",[{temp,?MODULE,?FUNCTION_NAME,?LINE}]),
    Reply= sensors:get_info(),
    {reply, Reply, State};


handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast({check}, State) ->
    ActualTemp=rpc:call(node(),conbee,get_temp,[]),
    ActualDoor=rpc:call(node(),conbee,get_door,[]),
    ActualVisitor=rpc:call(node(),conbee,get_visitor,[]),

    case is_pid(State#state.pid) of
	false->
	    ok;
	true->
	    case ActualTemp=:=State#state.actual_temp of
		true->
		    ok;
		false->
		    balcony_handler:actual_temp(ActualTemp,State#state.pid)
	    end,
	    case ActualDoor=:=State#state.actual_door of
		true->
		    ok;
		false->
		    balcony_handler:actual_door(ActualDoor,State#state.pid)
	    end,
	    case ActualVisitor=:=State#state.actual_visitor of
		true->
		    ok;
		false->
		    balcony_handler:actual_visitor(ActualVisitor,State#state.pid)
	    end
    end,
    NewState=State#state{actual_temp=ActualTemp,
			 actual_door=ActualDoor,
			 actual_visitor=ActualVisitor},
    spawn(fun()->do_check() end),
    {noreply, NewState};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({gun_response,_X1,_X2,_X3,_X4,_X5}, State) ->
    {noreply, State};

handle_info({gun_up,_,_}, State) ->
    {noreply, State};


handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------
do_check()->
    timer:sleep(?CheckIntervall),
    rpc:cast(node(),?MODULE,check,[]).
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
