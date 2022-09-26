# Workers

<pre><code><strong>Ockam nodes run very lightweight, concurrent, stateful actors called Ockam Workers.
</strong>Workers have addresses and a node can deliver messages to workers on the same node or
on a different node using the Ockam Routing Protocol and its Transports.</code></pre>

Ockam Workers are lightweight, concurrent, stateful actors.

Workers:

* Run in an Ockam Node.
* Have an application-defined address (like a postal mail or email address).
* Can maintain internal state.
* Can start other new workers.
* Can handle messages from other workers running on the same or a different node.
* Can send messages to other workers running on the same or a different node.
