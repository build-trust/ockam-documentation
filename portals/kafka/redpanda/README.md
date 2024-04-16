# Redpanda

This section contains hands-on examples that use [<mark style="color:blue;">Ockam</mark>](../../../) to send encrypted Kafka messages to a Redpanda instance, through an encrypted portal running in various environments.

[<mark style="color:blue;">Ockam</mark>](../../../) encrypts Kafka messages so that only the consumer can decrypt it. This gives the guarantee of tamper-proof data transfer and eliminate exposure in case the Kafka messages are exposed.

<table data-view="cards"><thead><tr><th></th><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><strong>Docker</strong></a></td><td>We connect a Kafka consumer with a Redpanda server in another virtual private network.</td><td></td></tr></tbody></table>
