# Nodes

An Ockam Node is an asynchronous execution environment that can run very lightweight, concurrent, stateful actors called [Ockam Workers](workers.md). A node can deliver messages from one worker to another worker. Nodes can also route messages to workers on other remote nodes.

### Create a node

```bash
> ockam node create

Node Created!

Node:
  Name: 6d3b9f7d
  Status: Running
  Services:
    Service:
      Type: TCP Listener
      Address: /ip4/127.0.0.1/tcp/60465
    Service:
      Type: Secure Channel Listener
      Address: /service/api
      Route: /ip4/127.0.0.1/tcp/60465/service/api
      Identity: P4842f385c9934b15e1cf0a4b09be9d1dddc407cb400a2c86bc6bd0fba09aaf6f
      Authorized Identities:
        - P4842f385c9934b15e1cf0a4b09be9d1dddc407cb400a2c86bc6bd0fba09aaf6f
    Service:
      Type: Uppercase
      Address: /service/uppercase
    Service:
      Type: Echo
      Address: /service/echo

```
