---
description: >-
  Ockam Relays make is easy to traverse NATs and run protocols with Ockam Nodes
  in far away private networks. Ockam Portals make far away applications
  virtually adjacent.
---

# Relays and Portals

In the previous section, we learnt how Ockam [Routing](advanced-routing.md#routing) and Ockam [Transports](advanced-routing.md#transports) give us a foundation to describe end-to-end, application layer protocols in any communication topology.

## Relays

The message in the above command took the following route:&#x20;

<img src="../../.gitbook/assets/file.excalidraw (1).svg" alt="" class="gitbook-drawing">

In this example, we ran a sim

```
» ockam node create n1
...

» ockam node create n2 --tcp-listener-address=127.0.0.1:7000
...

» ockam node create n3
...

» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
...

» ockam tcp-connection list --node n1
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| Transport ID                     | Transport Type | Mode              | Socket address | Worker address                     |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| 370229d91f735adffc928320bed3f2d1 | TCP            | Remote connection | 127.0.0.1:7000 | 0#1fb75f2e7234035461b261602a714b72 |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+

» ockam forwarder create n3 --at /node/n2 --to /node/n3
/service/forward_to_n3

» ockam message send hello --from /node/n1 --to /service/1fb75f2e7234035461b261602a714b72/service/forward_to_n3/service/uppercase
HELLO
```



```
» ockam node delete --all
» ockam project information --output json > project.json

» ockam node create n1 --project project.json
...

» ockam node create n3 --project project.json
...

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam message send hello --to /project/default/service/forward_to_n3/service/uppercase
HELLO
```

## Portals

```
» python3 -m http.server --bind 127.0.0.1 9000
```

```
» ockam tcp-outlet create --at /node/n3 --from /service/outlet --to 127.0.0.1:9000
...

» ockam tcp-inlet create --at /node/n1 --from 127.0.0.1:6000 \
    --to /service/f3a318045e7b0420d02d5489ff75f126/service/forward_to_n3/service/outlet
```

```
» curl --head 127.0.0.1:6000
HTTP/1.0 200 OK
```

{% hint style="info" %}
You can cleanup all the nodes with `ockam node delete --all`
{% endhint %}
