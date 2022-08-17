# Private Cloud Relays

```shell
# Install Ockam
> brew install build-trust/ockam/ockam

# Create an Ockam node that will relay end-to-end encrypted messages.
# Later we'll see how this can be a managed service in the cloud.
> ockam node create cloud-private-relay

# --- APPLICATION SERVICE ----

# A target service in a private network, listening on a local ip and port,
# that we want accessible to clients in other private networks. We'll use a simple http server for our example.
> python3 -m http.server --bind 127.0.0.1 5000

# Setup an Ockam node, next to our target service.
> ockam node create service-sidecar
# Create a TCP outlet on the service sidecar to send raw Tcp traffic to the target service.
> ockam tcp-outlet create --at /node/service-sidecar --from /service/outlet --to 127.0.0.1:5000
# Create a forwading relay on the cloud node at addree 
> ockam forwarder create --at /node/cloud-private-relay --from /service/forwarder-to-service-sidecar --for /node/service-sidecar

# --- APPLICATION CLIENT ----

# On a different machine in a different private network.

# Setup an Ockam node, for use by an application client
> ockam node create client-sidecar
# Create an end-to-end encrypted and mutually authenticated secure channel with the application service, through the cloud relay
# Then tunnel tcp traffic from an local inlet through this secure channel. 
> ockam secure-channel create --from /node/client-sidecar --to /node/cloud-private-relay/service/forwarder-to-service-sidecar/service/api \
    | ockam tcp-inlet create --at /node/client-sidecar --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service in another private network as though it was running locally.
> curl 127.0.0.1:7000 

# Neither the application service not its clients had to expose any ports to the internet.
```
