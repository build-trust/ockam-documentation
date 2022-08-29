# Nodes

An Ockam Node is an asynchronous execution environment that can run very lightweight, concurrent, stateful [actors](https://en.wikipedia.org/wiki/Actor\_model) called [Ockam Workers](workers.md). A node can deliver messages from one worker to another worker. Nodes can also route messages to workers on other remote nodes.

### Create a node

#### Create a node without a name:

```bash
> ockam node create

Node:
  Name: c7a747a6
  Status: UP
  Services:
    Service:
      Type: TCP Listener
      Address: /ip4/127.0.0.1/tcp/52824
    Service:
      Type: Secure Channel Listener
      Address: /service/api
      Route: /ip4/127.0.0.1/tcp/52824/service/api
      Identity: P2a9237c4301398a522a0de6b4c6717f0b166d062050c395f30fc9af88f90ad0b
      Authorized Identities:
        - P2a9237c4301398a522a0de6b4c6717f0b166d062050c395f30fc9af88f90ad0b
    Service:
      Type: Uppercase
      Address: /service/uppercase
    Service:
      Type: Echo
      Address: /service/echo
  Secure Channel Listener Address: /service/api
```

#### Create a node with a name:

In this case, the name that we chose for our node is 'relay'.

```bash
> ockam node create relay

Node:
  Name: relay
  Status: UP
  Services:
    Service:
      Type: TCP Listener
      Address: /ip4/127.0.0.1/tcp/52768
    Service:
      Type: Secure Channel Listener
      Address: /service/api
      Route: /ip4/127.0.0.1/tcp/52768/service/api
      Identity: P2a9237c4301398a522a0de6b4c6717f0b166d062050c395f30fc9af88f90ad0b
      Authorized Identities:
        - P2a9237c4301398a522a0de6b4c6717f0b166d062050c395f30fc9af88f90ad0b
    Service:
      Type: Uppercase
      Address: /service/uppercase
    Service:
      Type: Echo
      Address: /service/echo
  Secure Channel Listener Address: /service/api
```

Take a look at the Messages section to see how to send messages from one node to another.
