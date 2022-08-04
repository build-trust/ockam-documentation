# What is Ockam?

```shell
# Install Ockam Command using Homebrew
brew install build-trust/ockam/command

# Create three Ockam nodes n1, n2 & n3
for i in {1..3}; do ockam node create "n$i"; done

# Send an end-to-end encrypted service request over 2 node hops.
#
# From node n1, create a mutually authenticated, authorized,
# end-to-end encrypted secure channel with the api service on n3, via n2.
#
# Send an end-to-end encrypted message to a service on n3, using this channel.
# 
# n2 cannot see or tamper the onroute message
ockam secure-channel create --node n1 /node/n1/node/n2/node/n3/service/api
    | ockam message send --node n1 "hello" -/service/uppercase
HELLO
```
