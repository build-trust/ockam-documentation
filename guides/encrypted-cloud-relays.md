---
description: End-to-end encrypted, secure and private cloud relays – for any application.
---

# Private Cloud Relays

```bash
# Install Ockam
$ brew install build-trust/ockam/ockam

# Create an ockam node, called cloud-relay, that will relay
# end-to-end encrypted messages. Later we'll see how we can get such a relay
# as a managed cloud service with Ockam Orchestrator.
$ ockam node create cloud-relay

# --- APPLICATION SERVICE ----

# An application service, listening on a local ip and port, that clients would
# access through the cloud relay. We'll use a simple http server for our example.
$ python3 -m http.server --bind 127.0.0.1 5000

# Setup an ockam node, called blue, next to our application service. Create a
# tcp outlet on the blue node to send raw tcp traffic to the application service.
# Then create a forwading relay on the cloud-relay node for blue.
$ ockam node create blue
$ ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
$ ockam forwarder create --at /node/cloud-relay --from /service/forwarder-for-blue --for /node/blue

# --- APPLICATION CLIENT ----

# Setup an ockam node, called green, for use by an application client.
# Create an end-to-end encrypted secure channel with blue, through the cloud relay.
# Then tunnel traffic from a local tcp inlet through this end-to-end secure channel.
$ ockam node create green
$ ockam secure-channel create --from /node/green --to /node/cloud-relay/service/forwarder-for-blue/service/api \
    | ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service though the end-to-end encrypted, secure relay.
$ curl 127.0.0.1:7000
```
