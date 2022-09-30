---
description: End-to-end encrypted, secure and private cloud relays – for any application.
---

# Create a Local Relay

Let’s walk through a simple example to create an end-to-end encrypted, mutually authenticated, secure and private cloud relay – for any application.

First [install](../get-started/#command) the Ockam command, if you haven't already.

```bash
brew install build-trust/ockam/ockam
```

If you're on linux, see how to installed [precompiled binaries](../get-started/#precompiled-binaries).

Then let's create a local relay node.

```bash
ockam node create relay
```

### Application Service

Next let's prepare the service side of our application.

Start our application service, listening on a local ip and port, that clients would access through the cloud relay. We'll use a simple http server for our first example but this could be some other application service.

```bash
python3 -m http.server --bind 127.0.0.1 5000
```

Setup an Ockam node, called blue, as a sidecar next to our application service.

```
ockam node create blue
```

Create a tcp outlet on the blue node to send raw tcp traffic to the application service.

```bash
ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
```

Then create a forwarding relay at your default orchestrator project to blue.

```bash
ockam forwarder create blue --at /node/relay --to /node/blue
```

### Application Client

Now on the client side:

Setup an ockam node, called green, as a sidecar next to our application service.

```bash
ockam node create green
```

Then create an end-to-end encrypted secure channel with blue, through the cloud relay. Then tunnel traffic from a local tcp inlet through this end-to-end secure channel.

```bash
ockam secure-channel create --from /node/green \
     --to /node/relay/service/forward_to_blue/service/api \
  | ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to -/service/outlet
```

Access the application service though the end-to-end encrypted, secure relay.

```bash
curl 127.0.0.1:7000
```

We just created end-to-end encrypted, mutually authenticated, and authorized secure communication between a tcp client and server. This client and server can be running in separate private networks / NATs. We didn't have to expose our server by opening a port on the Internet or punching a hole in our firewall.

The two sides authenticated and authorized each other's known, cryptographically provable identifiers. In later examples we'll see how we can build granular, attribute-based access control with authorization policies.

### Restart

If something breaks or if you'd like to start from the beginning as you try this example, please run&#x20;

```
ockam reset
```



### Full Example

```bash
brew install build-trust/ockam/ockam
ockam node create relay

# -- APPLICATION SERVICE --

python3 -m http.server --bind 127.0.0.1 5000

ockam node create blue
ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create blue --at /node/relay --to /node/blue

# -- APPLICATION CLIENT --

ockam node create green
ockam secure-channel create --from /node/green --to /node/relay/service/forward_to_blue/service/api \
  | ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to -/service/outlet

curl 127.0.0.1:7000
```

