---
description: >-
  Ockam Relays make is easy to traverse NATs and run end-to-end protocols 
  between Ockam Nodes in far away private networks. Ockam Portals make far away
  applications virtually adjacent.
---

# Relays and Portals

In the previous section, we learnt how Ockam [Routing](routing.md#routing) and Ockam [Transports](routing.md#transport) give us a foundation to describe end-to-end, application layer protocols in any communication topology.

## Relay

The message in the above command took the following route:&#x20;



<img src="../../.gitbook/assets/file.excalidraw (2).svg" alt="" class="gitbook-drawing">

<img src="../../.gitbook/assets/file.excalidraw.svg" alt="" class="gitbook-drawing">

<img src="../../.gitbook/assets/file.excalidraw (3).svg" alt="" class="gitbook-drawing">

```
» ockam node create n2 --tcp-listener-address=127.0.0.1:7000

» ockam node create n3
» ockam forwarder create n3 --at /node/n2 --to /node/n3
/service/forward_to_n3

» ockam node create n1
» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
» ockam tcp-connection list --node n1
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| Transport ID                     | Transport Type | Mode              | Socket address | Worker address                     |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| 370229d91f735adffc928320bed3f2d1 | TCP            | Remote connection | 127.0.0.1:7000 | 0#1fb75f2e7234035461b261602a714b72 |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
» ockam message send hello --from /node/n1 --to /service/1fb75f2e7234035461b261602a714b72/service/forward_to_n3/service/uppercase
HELLO
```

## Portal

```
» python3 -m http.server --bind 127.0.0.1 9000
```

```
» ockam tcp-outlet create --at /node/n3 --from /service/outlet --to 127.0.0.1:9000
» ockam tcp-inlet create --at /node/n1 --from 127.0.0.1:6000 \
    --to /service/f3a318045e7b0420d02d5489ff75f126/service/forward_to_n3/service/outlet
```

```
» curl --head 127.0.0.1:6000
HTTP/1.0 200 OK
```

## Orchestrator

### Relay <a href="#orchestrator-relay" id="orchestrator-relay"></a>

```
» ockam project information --output json > project.json

» ockam node create n1 --project project.json
» ockam node create n3 --project project.json

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam message send hello --to /project/default/service/forward_to_n3/service/uppercase
HELLO
```

### Portal <a href="#orchestrator-portal" id="orchestrator-portal"></a>

```
» ockam tcp-outlet create --at /node/n3 --from /service/outlet --to 127.0.0.1:9000
» ockam tcp-inlet create --at /node/n1 --from 127.0.0.1:6000 \
    --to /project/default/service/forward_to_n3/service/outlet
```

#### Recap

{% hint style="info" %}
To cleanup and delete all nodes, run: `ockam node delete --all`
{% endhint %}



{% hint style="info" %}
If you’re stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

#### Next

Next,&#x20;
