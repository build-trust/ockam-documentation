# Routing and Transports

```
» ockam message send hello --to /node/n1/service/echo
hello
```

<figure><img src="../../.gitbook/assets/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/echo
hello
```

<figure><img src="../../.gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/hop/service/echo
hello
```

<figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>
