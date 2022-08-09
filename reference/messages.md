# Messages

```shell
# Create an Ockam node n1
> ockam node create n1

# Send a message to the `uppercase` worker on n1
> ockam message send "hello" --to /node/n1/service/uppercase
HELLO
```

```shell
# Create an Ockam node n1
> ockam node create n1 --tcp-listener-address "127.0.0.1:6001"

# Send a message to the `uppercase` worker on n1
> ockam message send "hello" --to /ip4/127.0.0.1/tcp/6001/service/uppercase
HELLO
```
