# Routing and Transports

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
