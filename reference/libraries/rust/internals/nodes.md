# Nodes and Workers

```mermaid

sequenceDiagram
  User->>Context(app): 1. send("echoer", "Hello Ockam!")
  Context(app)->>Router: 2. send(SenderReq("echoer", reply_sender))
  Router->>Router: 3.resolve_address
  Router-->>Context(app): 4. address + worker channel sender
  Context(app)->>Context(app): 5. make relay message
  Context(app)->>Context(app): 6. check outgoing relay message
  Context(app)->>WorkerRelay: 7. send relay message
  WorkerRelay->>Context(worker): 8. receive_next
  Context(worker)->>Context(worker): 9. is_authorized(relay message)
  WorkerRelay->>WorkerRelay: 10. decode message
  WorkerRelay->>Worker: 11. handle_message
  Worker->>Context(worker): 12. send(return router, message body)
  Context(worker)-->>Context(app): 13. routed back message
  User->>Context(app): 14. wait on the message using the app Context receiver

```
