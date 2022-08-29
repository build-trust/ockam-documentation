# Messages

Messages can be sent to a specific node or from one node to another.&#x20;

#### Create a node and send it a message:

```shell
# Create an Ockam node n1
> ockam node create n1

# Send a message to the `uppercase` worker on n1
> ockam message send "hello" --to /node/n1/service/uppercase
HELLO
```

#### Create two nodes and send a message from one node to another:

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Send a message from n1 to the `uppercase` worker on n2
> ockam message send "hello" --from n1 --to /node/n2/service/uppercase
HELLO
```

#### Create two nodes and send a message from one node to another (using /node in the --from argument):

```shell
# Create an Ockam node n1
> ockam node create n1

# Create an Ockam node n2
> ockam node create n2

# Send a message from n1 to the `uppercase` worker on n2 (with /node in the --from argument)
> ockam message send "hello" --from /node/n1 --to /node/n2/service/uppercase
HELLO
```
