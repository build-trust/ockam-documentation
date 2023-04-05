---
description: >-
  Ockam Relays make is easy to traverse NATs and run end-to-end protocols 
  between Ockam Nodes in far away private networks. Ockam Portals make far away
  applications virtually adjacent.
---

# Relays and Portals

In the [<mark style="color:blue;">previous section</mark>](routing.md), we learnt how Ockam Routing and Ockam Transports give us a foundation to describe end-to-end, application layer protocols. When discussing [<mark style="color:blue;">Transports</mark>](routing.md#transport)<mark style="color:blue;">,</mark> we also create at a specific example communication topology.

<img src="../../.gitbook/assets/file.excalidraw (2).svg" alt="" class="gitbook-drawing">

Node `n1` wishes to access a service on node `n3`, but it can't directly connect to `n3`. This can happen for many reasons, maybe because `n3` is in a separate `IP` subnet or could be that the communication from `n1 to n2` uses UDP while from `n2 to n3` uses TCP or other similar constraints. The topology makes `n2` a bridge or gateway between these two separate networks to enables= end-to-end protocols between `n1` and `n3` even though they are not directly connected.

It is common, however, to encounter communication topologies where the machine that provides a service is unwilling or is not allowed to open a listening port or <mark style="color:orange;">expose</mark> a bridge node to other networks. This is a common security best practice in enterprise environments, home networks, OT networks, and VPCs across clouds. Application developers typically have no control over these choices.

## Relay

Relays make it possible to establish end-to-end protocols with services operating in a remote private networks, without requiring a remote service to expose listening ports on an outside hostile network like the Internet.  &#x20;

Delete all your existing nodes and try this new example:

```
» ockam node create n2 --tcp-listener-address=127.0.0.1:7000

» ockam node create n3
» ockam forwarder create n3 --at /node/n2 --to /node/n3
/service/forward_to_n3

» ockam node create n1
» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
» ockam tcp-connection list --node n1
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| Transport ID                     | Transport Type | Mode              | Socket address | Worker address                     |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| 370229d91f735adffc928320bed3f2d1 | TCP            | Remote connection | 127.0.0.1:7000 | 0#1fb75f2e7234035461b261602a714b72 |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+

» ockam message send hello --from /node/n1 --to /service/1fb75f2e7234035461b261602a714b72/service/forward_to_n3/service/uppercase
HELLO
```

In this example the direction of the second TCP connection is reversed in comparison to our first example that used a bridge. `n2` is the only node that has to listen for TCP connections.&#x20;

Node `n2` is running a relay service. `n3` makes an outgoing TCP connection to `n2` and requests a forwarding address from the relay service. `n3` then becomes reachable via `n2` at the address `/service/forward_to_n3`.

Node `n1` connects with `n2` and routes messages to `n3` via its forwarding relay.

<img src="../../.gitbook/assets/file.excalidraw.svg" alt="" class="gitbook-drawing">

The message in the above example took the following route. This is very similar to our [<mark style="color:blue;">earlier example</mark>](routing.md#transport) except the direction of the second TCP connection. The relay worker remembers the route to back to `n3`. `n1` just has to get the message to the forwarding relay and everything just works.

<img src="../../.gitbook/assets/file.excalidraw (2) (1).svg" alt="" class="gitbook-drawing">

Using this simple topology rearrangement, Ockam [Routing](routing.md) makes is possible to establish end-to-end protocols between applications that are running in completely private networks.

We can traverse NATs and pierce through network boundaries. And since this is all built using a very simple [application layer routing](routing.md) protocol we can have any number of transport connection hops, in any transport protocol and we can mix-match bridges with relays to create <mark style="color:orange;">end-to-end protocols in</mark> <mark style="color:orange;"></mark><mark style="color:orange;">**any**</mark> <mark style="color:orange;"></mark><mark style="color:orange;">communication topology</mark>.

### Managed Relays

```
» ockam project information --output json > project.json

» ockam node create n1 --project project.json
» ockam node create n3 --project project.json

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam message send hello --to /project/default/service/forward_to_n3/service/uppercase
HELLO
```

## Portal <a href="#orchestrator-portal" id="orchestrator-portal"></a>

```
» python3 -m http.server --bind 127.0.0.1 9000
```

```
» ockam tcp-outlet create --at /node/n3 --from /service/outlet --to 127.0.0.1:9000
» ockam tcp-inlet create --at /node/n1 --from 127.0.0.1:6000 \
    --to /project/default/service/forward_to_n3/service/outlet
```

```
» curl --head 127.0.0.1:6000
HTTP/1.0 200 OK
```

#### Recap

{% hint style="info" %}
To cleanup and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [<mark style="color:blue;">Routing</mark>](advanced-routing.md#routing) is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` or any other topology you can imagine. Ockam [<mark style="color:blue;">Transports</mark>](routing.md) adapt Ockam Routing to various transport protocols.

Together they give us a simple, yet extremely flexible, foundation to describe end-to-end, application layer protocols that can operate in any communication topology.

{% hint style="info" %}
If you’re stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

#### Next

Next,&#x20;
