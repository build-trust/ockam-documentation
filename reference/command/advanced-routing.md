---
description: >-
  Ockam Relays make is easy to traverse NATs and run end-to-end protocols 
  between Ockam Nodes in far away private networks. Ockam Portals make existing
  application protocols work over Ockam Routing.
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

» ockam message send hello --from n1 --to /service/1fb75f2e7234035461b261602a714b72/service/forward_to_n3/service/uppercase
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

### Elastic Relays

Ockam Orchestrator can create, manage, scale, and secure [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay) for you. The [<mark style="color:blue;">Project</mark>](nodes.md#project) that was created when you ran `ockam enroll` offers an Elastic Relay Service that is designed for high throughput and low latency.

Delete all your existing nodes and try this new example. If you've already enrolled, there's no need to enroll again:

```
» ockam node delete --all
» ockam enroll

» ockam project information --output json > project.json

» ockam node create n1 --project project.json
» ockam node create n3 --project project.json

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam message send hello --from n1 --to /project/default/service/forward_to_n3/service/uppercase
HELLO
```

In the example above we create two node `n1 and n3` and tell them about our Project. Unlike our [<mark style="color:blue;">first relay example</mark>](advanced-routing.md#relay), we don't create a local relay node `n2`. We instead use the Elastic Relay Service in our Orchestrator Project called `/project/default`.

Everything worked exactly the same - except we now `n3` has a forwarding relay available to any project member that can reach the Internet. We can use this to run end-to-end protocols between other project members like `n1`.

The `hello` message from `n1` travelled to project node in the cloud and was relayed back to `n3` via it's forwarding relay. The reply `HELLO` from `n3` took the return route back.

## Portal <a href="#orchestrator-portal" id="orchestrator-portal"></a>

Ockam Portals make existing application protocols work over Ockam Routing. Without any code change to the existing applications.

<img src="../../.gitbook/assets/file.excalidraw (1).svg" alt="" class="gitbook-drawing">

Continuing from our [<mark style="color:blue;">Elastic Relays</mark>](advanced-routing.md#elastic-relays) example, create a local python based web server to represent a sample web service. This web service is listening on `127.0.0.1:9000`.

```
» python3 -m http.server --bind 127.0.0.1 9000

» ockam tcp-outlet create --at /node/n3 --from /service/outlet --to 127.0.0.1:9000
» ockam tcp-inlet create --at /node/n1 --from 127.0.0.1:6000 \
    --to /project/default/service/forward_to_n3/service/outlet

» curl --head 127.0.0.1:6000
HTTP/1.0 200 OK
...
```

Then create a TCP Portal Outlet that makes `127.0.0.1:9000` available on worker address `/service/outlet` on `n3`. We already have a forwarding relay for `n3` in our [Project](nodes.md#project) node.

We then create a TCP Portal Inlet on `n1` that will listen for TCP connections to `127.0.0.1:6000`. For every new connection, the inlet creates a portal following the `--to` route all the way to the outlet. As it receives TCP data, it chunks and wraps them into Ockam Routing messages and sends them along the supplied route. The outlet receives Ockam Routing messages, unwraps them to extract TCP data and send that data along to the target web service on `127.0.0.1:9000`. It all just seamlessly works.

The HTTP requests from curl, enter the inlet on `n1`, travel to your project node in the cloud and are relayed back to `n3` via it's forwarding relay to reach the outlet and onward to the the python based web service. HTTP Responses take the return route back to the curl.

The TCP Inlet/Outlet work for the large number of TCP based protocols like HTTP. It is also simple to implement portals for other transport protocols. There is a growing base of Ockam Portal Add-Ons in our [<mark style="color:blue;">Github Repository</mark>](https://github.com/build-trust/ockam).

Ockam Portals make existing application protocols work over Ockam Routing. Without any code change to the existing applications.

#### Recap

{% hint style="info" %}
To cleanup and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [<mark style="color:blue;">Routing</mark>](advanced-routing.md#routing) and [<mark style="color:blue;">Transports</mark>](routing.md#transport) combined with the ability to model [<mark style="color:blue;">Bridges</mark>](advanced-routing.md) and [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay) make it possible to <mark style="color:orange;">create end-to-end, application layer protocols in</mark> <mark style="color:orange;"></mark><mark style="color:orange;">**any**</mark> <mark style="color:orange;"></mark><mark style="color:orange;">communication topology</mark> - across networks, clouds, and boundaries.

[Portals](advanced-routing.md#orchestrator-portal) take this powerful capability a huge step forward by making it possible to apply these end-to-end protocols and their guarantees to existing applications, <mark style="color:orange;">without changing any code!</mark>

This lays the foundation to make <mark style="color:orange;">both new and existing</mark> applications - end-to-end encrypted and secure-by-design.

{% hint style="info" %}
If you’re stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

#### Next

Next, let's learn how we can create cryptographic [<mark style="color:blue;">identities</mark>](identities.md) and store secret keys in safe [<mark style="color:blue;">vaults</mark>](identities.md).
