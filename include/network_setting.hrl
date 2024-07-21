%% packet max size 64kb and safety ,otherwise may be there is too large packet
-define(TCP_OPT_PACKET,{packet, 2}).
-define(PACKAGE_HEADER_BIT_LENGTH,16).

-define(INIT_PACKET,{packet,0}).

-define(TCP_OPTIONS,[binary,?INIT_PACKET, {reuseaddr, true},{keepalive, true}, {backlog, 256}, {active, false}]).

-define(TCP_CLIENT_SOCKET_OPTIONS,[binary, {active, once}, ?TCP_OPT_PACKET]).

-define(ORI_TCP_CLIENT_SOCKET_OPTIONS,[binary, {active, false},?INIT_PACKET]).

%% equal to <<"<policy-file-request/>\0">>
-define(CROSS_DOMAIN_FLAG, <<60,112,111,108,105,99,121,45,102,105,108,101,45,114,101,113,117,101,115,116,47,62,0>>).

-define(CROSS_DOMAIN_FLAG_HEADER,<<60,112,111,108>>).
