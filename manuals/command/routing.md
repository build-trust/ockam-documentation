# Routing and Transports

Ockam's Application Layer Routing protocol allows us to send messages over any number of hops, within one node, or across many nodes. This enables us to layer other protocols that provide end-to-end security and privacy guarantees.

## Routing

```
» ockam message send hello --to /node/n1/service/echo
hello
```

<figure><img src="../../.gitbook/assets/simple.001 (1).jpeg" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/echo
hello
```

<figure><img src="../../.gitbook/assets/two-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/hop/service/echo
hello
```

<figure><img src="../../.gitbook/assets/n-hops.001.jpeg" alt=""><figcaption></figcaption></figure>
