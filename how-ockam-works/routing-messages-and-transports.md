# Routing, Messages, and Transports

Messages can be sent to a specific node or from one node to another.&#x20;

#### Create a node and send it a message:

```shell
# Create an Ockam node n1
> ockam node create n1

# Send a message to the `uppercase` worker on n1
> ockam message send "hello" --to /node/n1/service/uppercase
HELLO
```

#### Create two nodes and send a message from one node to another:

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Send a message from n1 to the `uppercase` worker on n2
> ockam message send "hello" --from n1 --to /node/n2/service/uppercase
HELLO
```

#### Create two nodes and send a message from one node to another (using /node in the --from argument):

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Send a message from n1 to the `uppercase` worker on n2 (with /node in the --from argument)
> ockam message send "hello" --from /node/n1 --to /node/n2/service/uppercase
HELLO
```



<pre><code><strong>The Ockam Routing Protocol is a very simple application layer protocol that allows
</strong>the sender of a message to describe the `onward_route` and `return_route` of message.

The routing layer in a node can then be used route these messages between workers within
a node or across nodes using transports. Messages can be sent over multiple hops, within
one node or across many nodes.</code></pre>





Ockam Routing is an application layer routing protocol that provides the ability to route messages between [workers](broken-reference) within a [node](nodes-workers-and-services.md) or across nodes using [transports](broken-reference).

Messages can be sent over multiple hops, within one node or across many nodes.

In our example below, messages are being sent from the source, Node n1 to Node n2 and then the final destination, Node n3.

```bash
# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i" --tcp-listener-address "127.0.0.1:600$i"; done

# Route a message 
> ockam message send "hello" --from n1 \
    --to /ip4/127.0.0.1/tcp/6002/ip4/127.0.0.1/tcp/6003/service/uppercase
HELLO

```

```bash
# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i"; done

# Route a message
> ockam message send "hello" --from n1 --to /node/n2/node/n3/service/uppercase
HELLO
```



```
Transports are plugins to the Ockam Routing layer that allow Ockam Routing messages
to travel across nodes over transport layer protocols like TCP, UDP, BLUETOOTH etc.
```



An Ockam Transport is a plugin for Ockam Routing. It moves Ockam Routing messages using a specific transport protocol like TCP, UDP, WebSockets, Bluetooth etc.

Ockam Transports know how to send messages over the Transport protocol needed to the destination on our Ockam Routing address. They can move messages over multiple hops and each hop can use a different transport protocol.
