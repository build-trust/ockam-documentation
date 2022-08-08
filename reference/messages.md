# Messages

```shell
# Create an Ockam node n1
> ockam node create n1

# Send a message to the `uppercase` worker on n1
> ockam message send "hello" --to /node/n1/service/uppercase
HELLO
```
