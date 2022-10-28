# Add end-to-end encryption to any client and server application

Let's build a solution for a very common topology. A application service and an application client running in two private networks wish to communicate with each other without exposing ports on the Internet.

<figure><img src="../.gitbook/assets/infrastructure.webp" alt=""><figcaption></figcaption></figure>





```bash
# Create a relay node that will relay end-to-end encrypted messages
ockam node create relay

# -- APPLICATION SERVICE --

# Start our application service, listening on a local ip and port, that clients
# would access through the cloud relay. We'll use a simple http server for our
# first example but this could be some other application service.
python3 -m http.server --bind 127.0.0.1 5000

# Setup an ockam node, called blue, as a sidecar next to our application service.
# Create a tcp outlet on the blue node to send raw tcp traffic to the application service.
# Then create a forwarder on the relay node to blue.
ockam node create blue
ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create blue --at /node/relay --to /node/blue

# -- APPLICATION CLIENT --

# Setup an ockam node, called green, as a sidecar next to our application client.
# Then create an end-to-end encrypted secure channel with blue, through the relay.
# Then tunnel traffic from a local tcp inlet through this end-to-end secure channel.
ockam node create green
ockam secure-channel create --from /node/green --to /node/relay/service/forward_to_blue/service/api \
  | ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service though the end-to-end encrypted, secure relay.
curl 127.0.0.1:7000
```





