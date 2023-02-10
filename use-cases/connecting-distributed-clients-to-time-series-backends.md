---
description: >-
  Individually authenticated producers and point-to-point connectivity to ensure
  high trust data
---

# Connecting distributed clients to time series backends

Time series databases (e.g., InfluxDB, TimescaleDB, Graphite, Prometheus, etc.) have become increasingly popular in recent years. Especially for use cases where many discrete devices need to aggregate and store large volumes of time-stamped data for monitoring, alerting, or just general product/device usage.

### The problem

The producer of this data could be a microservice cluster operating in a public cloud, an IoT device in someone's home, an industrial device running within a warehouse, an environmental monitor in a smart city installation, or anything inbetween. This presents a series of challenges that vary based on how much control you have over the device in question, how much you need to ensure the integrity of the information you receive, and the network topolgy between the producer and time series backend.

For many of these use cases the data needs to be sent from a remote network to time series backend, which involves exposing the time series backend directly to the public internet. These backends also typically do not support the access controls essential to support hundreds or thousands of discrete devices connection resulting in coarsed grained credentials being shared across numerous producers. This in turn creates an opportunity for an exposed credential to allow a third-party to generate erroneous data that can not be easily removed from the aggregated results. Or possibly even worse: a privilege escalation.

### How Ockam simplifies it

To start, your time series backend is able to register itself as a service that some authorized subset of your Ockam nodes can connect to. Whether your backend is running on a public cloud provider or on a private network in a warehouse, successfully authenticated producer nodes will be able to establish a connection direct to you backend without exposing any ports directly to the public internet.

Ockam's enrollment protocol means that each producer is able to be registered separately as unique node. Each producer node is then able to setup an end-to-end encrypted and authenticated channel to your time series backend. Given no ports on the backend were opened to the public internet, these secure channels are the only way to connect remotely to the backend.&#x20;

These connections are established and authenticated on-demand and, for supported backends, short-lived credentials are generated for the connecting node. This ensures that not only is each node and the data it generates is uniquely identifiable but any risk of an exposed credential is mitigated based on the session length of the generated token.

### Get started

You can see an end-to-end example of this in our [Telegraf + InfluxDB code example](../code-examples/telegraf-+-influxdb.md), or follow our [getting started guide to install Ockam](../#quick-start) and start using it in just a few minutes.

We're also actively recruiting people to provide feedback on new features we're making to the Ockam add-ons that enable enhanced capabilities with event stream processing and time series databases. If this is an area of interest to you [please reach out to the team](https://www.ockam.io/contact/form) to talk about your use cases.
