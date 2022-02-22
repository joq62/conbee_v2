%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(conbee_eunit).    
     
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------



%% External exports
-export([]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
t0_test()->
    application:ensure_all_started(gun),
    ok.
curl_test()->
    Link="172.17.0.2",
    Cmd = "curl -s GET \"" ++ Link ++ "\"",
    Output = os:cmd(Cmd),
    io:format("Output ~p~n",[{Output,?MODULE,?LINE}]),
    Output.

pass_0_test()->
    inets:start(),
    {ok, {{Version, 200, ReasonPhrase}, Headers, Body}} =
      httpc:request(get,{"https://phoscon.de/discover",[]},[],[{body_format,binary}]),
    %gl=Body,
    Map=jsx:decode(Body,[]),
    
    io:format("************~p ****************~n",[time()]),
  
    gl=Info=sensors:get_info("172.17.0.2",80,"/api/1D14A87469/sensors"),    
    io:format("Info ~p~n",[Info]),
 %   [io:format("~p~n",[{Name,Key,Value}])||[{name,Name},{id,Id},{type,Type},{status,{Key,Value}}]<-Info],
    io:format("----------------------------------------------~n"),
    glurk=Raw=conbee:sensors_raw(),    
    io:format("Raw ~p~n",[Raw]),
    ok.

   % timer:sleep(10*1000),
   % pass_0().
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass_1()->
    io:format("************~p ****************~n",[time()]),
    Info=conbee:sensors(),    
 %   io:format("Info ~p~n",[Info]),
    [io:format("~p~n",[{Name,Key,Value}])||[{name,Name},{id,_Id},{type,_Type},{status,{Key,Value}}]<-Info],
    
   
    timer:sleep(10*1000),
    pass_1().

    %ok.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

setup()->
    ok=application:start(conbee),
  
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
