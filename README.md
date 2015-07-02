# jekyllize
WIP. a handy layer on top of hxudp (https://github.com/andyli/hxudp)

net programming is a bitch. Jekyllize should make net programming a little nicer to work with.

fire up the NetworkManager, queue up some NetEvent objects, and they will be sent out for you every frame. A NetEvent has the means to pack itself into a bit stream, read itself from a bit stream, and execute actions.

A NetEvent can be configured to -

1. require a receipt
2. resent rate if no receipt is sent back
3. decide whether to ignore old events of the same type (for example, when syncing positions)
4. more to come, if needed.

