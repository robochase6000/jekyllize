# jekyllize
a handy layer on top of hxudp (https://github.com/andyli/hxudp)
WIP.
designed to make your network communication relatively simple - queue up some NetEvent objects and they will be sent out for you. a NetEvent has the means to pack itself into a bit stream, read itself from a bit stream, and execute actions.
