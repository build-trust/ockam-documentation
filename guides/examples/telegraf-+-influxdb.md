---
description: Securely connect Telegraf to an on-prem InfluxDB
---

# Telegraf + InfluxDB

{% hint style="info" %}
We're currently partnering with InfluxData on even more enhancements to this integrations, with new features and capabilities. If you'd like early access to a beta please [contact us](https://www.ockam.io/contact/form).
{% endhint %}

### Prerequisites

* [Ockam Command](broken-reference)
* [InfluxDB](https://docs.influxdata.com/influxdb/v2.6/install/)
* [Influx CLI](https://docs.influxdata.com/influxdb/v2.6/tools/influx-cli/)
* [Telegraf](https://github.com/influxdata/telegraf)

### The setup

{% hint style="info" %}
If you already have Telegraf running and connected to InfluxDB as an output you can skip this section.
{% endhint %}

InfluxDB is a popular open source time series database that is able to provide a scalable solution for storing time series data such as metrics from services and sensor data from IoT devices. In many deployments it is paired with a service called Telegraf, which allows the aggregation and processing of many inputs sources to be sent to one or more output destinations.&#x20;

#### Starting InfluxDB

The first thing we need to do is start InfluxDB so that we have somewhere to store the metrics data we're going to generate. On most systems that will be as simple as running:

```bash
influxd
```

You should then see some log output, with the final line confirming that `influxd` is now listening on port 8086:

```
2023-02-21T23:49:43.106268Z	info	Listening	{"log_id": "0fv9CURl000", "service": "tcp-listener", "transport": "http", "addr": ":8086", "port": 8086}
```

If `influxd` started successfully then you can open a new terminal session and leave this running in the background. If `influxd` did not start successfully check the official [documentation for some common issues for different operating systems](https://docs.influxdata.com/influxdb/v2.6/install/#start-and-configure-influxdb).

Now we're going to use the `influx` CLI command to complete the initial database setup so that `influxd` can receive our data. Run the setup command and complete the required prompts, remember the organization and bucket names you use as we'll need them later:

```bash
influx setup
```

Next you'll need copy the token for the user you just created, which you can retrieve with the `auth` command:

```bash
influx auth list
```

#### Starting Telegraf

Telegraf will need a configuration file that defines our input source and our output destination. It thankfully includes a command to generate such a file, which we can specify to be preconfigured with the CPU utilization of our host machine as an input source and with InfluxDB as our output.

To generate the base configuration run:

```bash
telegraf config --section-filter agent:inputs:outputs --input-filter cpu --output-filter influxdb_v2 > telegraf.conf
```

Open the generated `telegraf.conf` file and find the `[[outputs.influxdb_v2]]` section which should look like this:

{% code title="telegraf.conf" lineNumbers="true" %}
```toml
[[outputs.influxdb_v2]]
  ## The URLs of the InfluxDB cluster nodes.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
  urls = ["http://127.0.0.1:8086"]

  ## Token for authentication.
  token = ""

  ## Organization is the name of the organization you wish to write to.
  organization = ""

  ## Destination bucket to write into.
  bucket = ""
```
{% endcode %}

Replace the empty values for `token`, `organization`, and `bucket` with the values from the previous section about [Starting InfluxDB](telegraf-+-influxdb.md#starting-influxdb) and save you changes. You can now start Telegraf:

```bash
telegraf --config telegraf.conf 
```

#### Checking it's working

To make it easy to re-use your values for future commands and testing, store the appropriate values (i.e., replace the placeholders below with your actual values) into a series of environment variables:

```bash
export INFLUX_PORT=8086 INFLUX_TOKEN=your-token-here INFLUX_ORG=your-org INFLUX_BUCKET=your-bucket
```

Now we can check that Telegraf is regularly sending data to InfluxDB. The configuration we created earlier will emit CPU stats every 10 seconds, so we can send a query to InfluxDB and as it to return all data it has for the past 1 minute:

```bash
curl \
    --header "Authorization: Token $INFLUX_TOKEN" \
    --header "Accept: application/csv" \
    --header 'Content-type: application/vnd.flux' \
    --data "from(bucket:\"$INFLUX_BUCKET\") |> range(start:-1m)" \
    http://localhost:$INFLUX_PORT/api/v2/query?org=$INFLUX_ORG
```

### Securely connect Telegraf + InfluxDB with Ockam

The example above connects these two services, running on the same host, by using the default unencrypted HTTP transport. Most non-trivial configurations will have InfluxDB running on a separate host with one or more Telegraf nodes sending data in. In configuration it is unlikely that an unencrypted transport is acceptable, it's also not always desirable to potentially expose the InfluxDB port to public internet.

In this section we'll show you how both of these problems can be solved with very minimal configuration changes to any existing services.

#### Creating and enrolling your nodes

The first step is to enroll yourself with Ockam, save your project information, and create enrollment tokens for your InfluxDB and Telegraf nodes:

<pre class="language-bash"><code class="lang-bash"><strong>ockam enroll
</strong><strong>ockam project information --output json > project.json
</strong>export OCKAM_INFLUXDB_TOKEN=$(ockam project enroll --attribute component=influxdb)
export OCKAM_TELEGRAF_TOKEN=$(ockam project enroll --attribute component=telegraf)
</code></pre>

Now we can create a node for our InfluxDB service:

```bash
ockam node create influxdb --project project.json --enrollment-token $OCKAM_INFLUXDB_TOKEN
ockam policy set --at influxdb --resource tcp-outlet --expression '(= subject.component "telegraf")'
ockam tcp-outlet create --at /node/influxdb --from /service/outlet --to 127.0.0.1:8086
ockam forwarder create influxdb --at /project/default --to /node/influxdb
```

There's a few things that have happened in those commands, so let's quickly unpack them:

* We've created a new node called `influxdb`, and enrolled it with Ockam using the token we'd generated earlier. If you look back at the command that generated the token you'll see we also tagged this token with an attribute of `component=influxdb`.&#x20;
* We than added a policy to the `influxdb` node, which states that only nodes that have a `component` attribute with a value of `telegraf` will be able to connect to a TCP outlet.
* Next we create a TCP outlet. This is like a pipe from the `influxdb` node we've just created to the TCP port of `127.0.0.1:8086` (i.e., the port our InfluxDB database is listening on). This Ockam node will now pipe any data it receives from other nodes through to that destination. However the only nodes that will be able to establish that connection are those that pass the policy defined in the previous step.
* Finally we create a forwarder on our project, which now allows other nodes in our project to discover the `influxdb` and route traffic to it.

It's now time to establish the other side of this connection by creating the corresponding client node for Telegraf:

<pre class="language-bash"><code class="lang-bash"><strong>ockam node create telegraf --project project.json --enrollment-token $OCKAM_TELEGRAF_TOKEN
</strong>ockam policy set --at telegraf --resource tcp-inlet --expression '(= subject.component "influxdb")'
ockam tcp-inlet create --at /node/telegraf --from 127.0.0.1:8087 --to /project/default/service/forward_to_influxdb/secure/api/service/outlet
</code></pre>

Now we can unpack these three commands and what they've done:

* As before, we've used the enrollment token we generated to create a new node and registered it with our project. This time it's the `telegraf` node.
* We've again applied a policy to improve our security posture. This policy allows a TCP inlet to be created, but only if the node at the other end has the attribute `component` with a value of `influxdb`.
* Finally we create the TCP inlet. This is a way of defining where the node should be listening for connections (in this case on TCP port `8087`), and where it should forward that traffic to. This node will forward data through to the forwader we created earlier, which will in turn pass it to our `influxdb` node, which then sends it to the InfluxDB database.

That's it! The listener on localhost port `8087` is now forwarding all traffic to InfluxDB, wherever that is running. If that database was on a different host, running in the cloud, or in a private data center the enrollment and forwarding would still ensure our communication with `127.0.0.1:8087` would be securely connected to wherever that database is running.

### Update the existing configuration to use the secure connection

While this is a simplified example running on a single host, the following instructions are the same irrespective of your deployment. Once the `influxdb` and `telegraf` nodes are enrolled and running, the only change you need to make is to update your `telegraf.conf` to point to the local listening port:

{% code title="telegraf.conf" lineNumbers="true" %}
```
[[outputs.influxdb_v2]]
  urls = ["http://127.0.0.1:8087"]
```
{% endcode %}

Restart the Telegraf service, and we can then check that it's still storing data by using [the same command we used earlier](telegraf-+-influxdb.md#checking-its-working).

{% hint style="info" %}
This example created the TCP inlet on port `8087` primarily because the `influxd` service was running on the same host and already bound to port `8086`. In a production deployment where Telegraf and InfluxDB are on separate hosts the TCP inlet could listen on port `8086` and this default configuration would not need to change.
{% endhint %}

