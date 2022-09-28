# Relays and Portals&#x20;



An Ockam forwarder automatically forwards messages to a specified destination.

#### Create a forwarder and send a message through it:

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Create a forwarder at n1 to n2
> ockam fowarder create n1 --at /node/n1 --to /node/n2

# Send a message through the forwarder to `uppercase` worker on n2
> ockam message send hello --to /node/n1/service/forward_to_n1/service/uppercase
```

#### Create forwarder with a dynamic name and send a message through it:

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Create a forwarder at n1 to n2
> ockam fowarder create --at /node/n1 --to /node/n2

# Send a message through the forwarder to `uppercase` worker on n2
> ockam message send hello --to /node/n1/-/service/uppercase
```



```
Forwarders enable an ockam node to register a forwarding address on another node.
Any message that arrives at this forwarding address is immediately dispatched
to the node that registered the forwarding address.

# Create two nodes blue and green
$ ockam node create blue
$ ockam node create green

# Create a forwarder to node n2 at node n1
$ ockam forwarder create blue --at /node/green --to /node/blue
/service/forward_to_blue

# Send a message to the uppercase service on blue via its forwarder on green
$ ockam message send hello --to /node/green/service/forward_to_blue/service/uppercase

This can be very useful in establishing communication between applications
that cannot otherwise reach each other over the network.

For instance, we can use forwarders to create an end-to-end secure channel between
two nodes that are behind private NATs

# Create another node called yellow
$ ockam node create yellow

# Create an end-to-end secure channel between yellow and blue.
# This secure channel is created trough blue's forwarder at green and we can
# send end-to-end encrypted messages through it.
$ ockam secure-channel create --from /node/yellow --to /node/green/service/forward_to_blue/service/api \
    | ockam message send hello --from /node/yellow --to -/service/uppercase

In this topology green acts an an encrypted relay between yellow and blue. Yellow and
blue can be running in completely separate private networks. Green needs to be reachable
from both yellow and blue and only sees encrypted traffic.
```



TCP Inlets and TCP Outlets are sidecars through which communication takes place.

#### Create an inlet/outlet pair and move TCP traffic through it:

<pre class="language-shell"><code class="lang-shell"># Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Create a TCP Outlet on n1 that communicates from the service outlet on n1 to 127.0.0.1:5000
<strong>> ockam tcp-outlet create --at /node/n1 --from /service/outlet --to 127.0.0.1:5000
</strong><strong>
</strong><strong># Create a TCP Inlet on n2 that communicates from 127.0.0.1:6000 to the service outlet on n1
</strong>> ockam tcp-inlet create --at /node/n2 --from 127.0.0.1:6000 --to /node/n1/service/outlet

> curl 127.0.0.1:6000
</code></pre>

#### Create an inlet/outlet pair with a relay node through a forwarder and move TCP traffic through it:

<pre class="language-shell"><code class="lang-shell"># Create an Ockam node relay
> ockam node create relay

# Create an Ockam node n1
> ockam node create n1

# Create a TCP Outlet on n1 that communicates from the service outlet on n1 to 127.0.0.1:5000
> ockam tcp-outlet create --at /node/n1 --from /service/outlet --to 127.0.0.1:5000

# Create a forwarder on relay going to n1
> ockam forwarder create n1 --at /node/relay --to /node/n1


# Create an Ockam node n2
> ockam node create n2

# Create a Secure Channel from n2 to the forwarder and a TCP Inlet from 127.0.0.1:7000 to the service outlet on n2
<strong>> ockam secure-channel create --from /node/n2 --to /node/relay/service/forward_to_n1/service/api \
</strong>    | ockam tcp-inlet create --at /node/n2 --from 127.0.0.1:7000 --to -/service/outlet

> curl 127.0.0.1:7000</code></pre>
