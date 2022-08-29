# Forwarders

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
