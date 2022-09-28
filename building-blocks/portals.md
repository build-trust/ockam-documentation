# Portals



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
