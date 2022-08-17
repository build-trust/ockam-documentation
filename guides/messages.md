---
description: End-to-end encrypted, secure and private cloud relays – for any application.
---

# Private Cloud Relays



```shell
# Install Ockam
$ brew install build-trust/ockam/ockam

# Create an Ockam node that will relay end-to-end encrypted messages.
# This node must be reachable from our application service and client sidecars.
# Later we'll see how you can get this as a managed service in Ockam Orchestrator.
$ ockam node create cloud-private-relay

# --- APPLICATION SERVICE ----

# A target service, listening on a local ip and port,that we want accessible to
# clients through the cloud relay. We'll use a simple http server for our example.
$ python3 -m http.server --bind 127.0.0.1 5000

# Setup an Ockam node, next to our target service.
# Create a TCP outlet on the service sidecar to send raw Tcp traffic
# to the target service. Then create a forwading relay on the cloud node for it.
$ ockam node create service-sidecar
$ ockam tcp-outlet create --at /node/service-sidecar --from /service/outlet --to 127.0.0.1:5000
$ ockam forwarder create --at /node/cloud-private-relay --from /service/forwarder-to-service-sidecar --for /node/service-sidecar

# --- APPLICATION CLIENT ----

# Setup an Ockam node for use by an application client.
# Then create an end-to-end encrypted and mutually authenticated secure channel
# with the application service, through the cloud relay.
# Then tunnel tcp traffic from an local inlet through this end-to-end secure channel.
$ ockam node create client-sidecar
$ ockam secure-channel create --from /node/client-sidecar --to /node/cloud-private-relay/service/forwarder-to-service-sidecar/service/api \
    | ockam tcp-inlet create --at /node/client-sidecar --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service though the end-to-end encrypted, secure relay
$ curl 127.0.0.1:7000
```
