# Nodes

An Ockam Node is an asynchronous execution environment that can run very lightweight, concurrent, stateful actors called [Ockam Workers](workers.md). A node can deliver messages from one worker to another worker. Nodes can also route messages to workers on other remote nodes.

### Create a node

```bash
> ockam node create n1

Node Created!

Node:
  Name: n1
  Status: Running
  API Address: 127.0.0.1:59747
  Default Identity: P4842f385c9934b15e1cf0a4b09be9d1dddc407cb400a2c86bc6bd0fba09aaf6f
  Secure Channel Listener Address: /service/api
```
