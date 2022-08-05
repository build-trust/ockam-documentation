# What is Ockam?

```bash
# Install Ockam Command using Homebrew
brew install build-trust/ockam/command

# Create three Ockam nodes n1, n2 & n3
for i in {1..3}; do ockam node create "n$i"; done

# Create a mutually authenticated, authorized, end-to-end encrypted secure channel
# from node n1, via node n2, over two tcp hops to api service on node n3.
#
# Then send an end-to-end encrypted message to the uppercase service on n3,
# using this channel.
# 
# n2 cannot see or tamper the onroute message
ockam secure-channel create --from n1 --to /node/n2/node/n3/service/api
    | ockam message send "hello" --from n1 --to -/service/uppercase
HELLO
```
