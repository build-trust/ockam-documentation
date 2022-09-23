# Transports

```
Transports are plugins to the Ockam Routing layer that allow Ockam Routing messages
to travel across nodes over transport layer protocols like TCP, UDP, BLUETOOTH etc.
```



An Ockam Transport is a plugin for Ockam Routing. It moves Ockam Routing messages using a specific transport protocol like TCP, UDP, WebSockets, Bluetooth etc.

Ockam Transports know how to send messages over the Transport protocol needed to the destination on our Ockam Routing address. They can move messages over multiple hops and each hop can use a different transport protocol.
