---
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# Kubernetes

Let's connect a nodejs app in one kubernetes cluster with a postgres database in another private kubernetes cluster.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-13 at 8.50.52 PM.png" alt=""><figcaption></figcaption></figure>

## Run

This example requires Bash, Git, Curl, [<mark style="color:blue;">Kind</mark>](https://kind.sigs.k8s.io/), and [<mark style="color:blue;">Kubectl</mark>](https://kubernetes.io/docs/tasks/tools/#kubectl). Please set up these tools for your operating system, then run the following commands:

```bash
# Clone the Ockam repo from Github.
git clone --depth 1 https://github.com/build-trust/ockam && cd ockam

# Navigate to this example’s directory.
cd examples/command/portals/databases/postgres/kubernetes

# Run the example, use Ctrl-C to exit at any point.
./run.sh
```

If everything runs as expected, you'll see the message: _The example run was successful 🥳_

## Walkthrough

The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh), that you ran above, and its [<mark style="color:blue;">accompanying files</mark>](https://github.com/build-trust/ockam/tree/develop/examples/command/portals/databases/postgres/kubernetes) are full of comments and meant to be read. The example setup is only a few simple steps, so please take some time to read and explore.

### Administrator

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/tree/develop/examples/command/portals/databases/postgres/kubernetes) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L15) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L16-L29) to create an new identity, sign into Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership [<mark style="color:blue;">credential</mark>](../../../reference/protocols/identities.md#credentials).
* The run function then [<mark style="color:blue;">generates two new enrollment tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L31-L49). The tickets are valid for 10 minutes. Each ticket can be redeemed only once and assigns [<mark style="color:blue;">attributes</mark>](../../../reference/protocols/identities.md#credentials) to its redeemer. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L31-L40) is meant for the Ockam node that will run in Bank Corp.’s kubernetes cluster. The [<mark style="color:blue;">second ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L42-L49) is for the Ockam node that will run in Analysis Corp.’s kubernetes cluster.
* In a typical production setup an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project. It uses [<mark style="color:blue;">kubernetes secrets to give tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L63-L65) to Ockam nodes that are being provisioned in Bank Corp.’s and Analysis Corp.’s kubernetes clusters.
* The run function takes the enrollment tickets, sets them as kubernetes secrets, and [<mark style="color:blue;">uses kind with kubectl</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L51-L91) to create Bank Corp.’s and Analysis Corp.’s kubernetes clusters.

### Bank Corp

* Bank Corp.’s [<mark style="color:blue;">kubernetes manifest</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/pod.yml) defines a pod and containers to run in Bank Corp’s isolated kubernetes cluster. The run.sh script [<mark style="color:blue;">invokes kind</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L57) to create the cluster, [<mark style="color:blue;">prepares container images</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L60-L61) and [<mark style="color:blue;">calls kubectl apply</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L68)to start the pod and its containers.
* One of the containers defined in Bank Corp.’s <mark style="color:blue;">kubernetes manifest</mark> runs a [PostgreSQL database](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/pod.yml#L9-L18) makes it available on <mark style="background-color:yellow;">localhost:5432</mark> inside its pod.
* Another container defined inside that same pod runs an [<mark style="color:blue;">Ockam node</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/pod.yml#L20-L35) as a companion to the postgres container. The Ockam node container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/ockam.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh). The enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/pod.yml#L26-L35).
* When the Ockam node container starts in the Bank Corp cluster, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint script creates a new identity and uses the enrollment ticket to [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh#L6-L19) and get a project membership credential that attests to the attribute <mark style="background-color:yellow;">postgres-outlet=true.</mark> The run function [<mark style="color:blue;">assigned this attribute</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L31-L40) to the enrollment ticket.
* The entrypoint script then [<mark style="color:blue;">creates a node that uses</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh#L21-L33) this identity and membership credential to authenticate and create a [<mark style="color:blue;">relay</mark>](../../../reference/protocols/routing.md#relay) in the project, back to the node, at <mark style="background-color:yellow;">relay address: postgres</mark>. The run function [<mark style="color:blue;">gave the enrollment ticket permission</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L40C44-L40C60) to use this relay address.
* Next, the entrypoint sets an [<mark style="color:blue;">access control policy</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh#L32C56-L32C91) that only allows project members that possesses a credential with attribute <mark style="background-color:yellow;">postgres-inlet="true"</mark> to connect to tcp portal outlets on this node. It then creates tcp portal outlet to postgres at [<mark style="color:blue;">localhost:5432</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/bank\_corp/run\_ockam.sh).

### Analysis Corp

* Analysis Corp.’s [<mark style="color:blue;">kubernetes manifest</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml) defines a pod and containers to run in Analysis Corp.’s isolated kubernetes cluster. The run.sh script [<mark style="color:blue;">invokes kind</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L77) to create the cluster, [<mark style="color:blue;">prepares container images</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L80-L83) and [<mark style="color:blue;">calls kubectl apply</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L90) to start the pod and its containers. The [<mark style="color:blue;">manifest</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml) defines a pod with two containers an [<mark style="color:blue;">Ockam node container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml#L16-L31) and an [<mark style="color:blue;">app container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml#L9-L14).
* The [<mark style="color:blue;">Ockam node container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml#L16-L31) is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/ockam.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh). The enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml#L22-L31).
* When the Ockam node container starts in the Analysis Corp network, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint script creates a new identity and uses the enrollment ticket to [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L4-L19) and get a project membership credential that attests to the attribute <mark style="background-color:yellow;">postgres-inlet=true.</mark> The run function [<mark style="color:blue;">assigned this attribute</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/run.sh#L42-L49) to the enrollment ticket.
* The entrypoint script then [<mark style="color:blue;">creates a node that uses</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L21-L30) this identity and membership credential. It then sets an [<mark style="color:blue;">access control policy</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L29C55-L29C91) that only allows project members that possesses a credential with attribute <mark style="background-color:yellow;">postgres-outlet="true"</mark> to connect to tcp portal inlets on this node.
* Next, the entrypoint [<mark style="color:blue;">creates tcp portal inlet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L30) that makes the [<mark style="color:blue;">remote postgres</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L30C51-L30C64) available on all localhost IPs at [<mark style="color:blue;">0.0.0.0:15432</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/run\_ockam.sh#L30C30-L30C50). This makes postgres available at <mark style="background-color:yellow;">localhost:15432</mark> within Analysis Corp’s [<mark style="color:blue;">pod</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/pod.yml) that also has the app container.
* The app container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.dockerfile) which runs this [<mark style="color:blue;">app.js</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js) file on startup. The app.js file is a nodejs app, it [<mark style="color:blue;">connects with postgres</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js#L3-L27) on <mark style="background-color:yellow;">localhost:15432</mark>, then [<mark style="color:blue;">creates a table</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js#L41-L42) in the database, [<mark style="color:blue;">inserts some data</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js#L44-L48) into the table, [<mark style="color:blue;">queries it</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js#L51) back, and [<mark style="color:blue;">prints it</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/kubernetes/analysis\_corp/app.js#L52).

## Recap

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-13 at 8.50.52 PM (1).png" alt=""><figcaption></figcaption></figure>

We connected a nodejs app in one kubernetes cluster with a postgres database in another kubernetes cluster over an end-to-end encrypted portal.

Sensitive business data in the postgres database is only accessible to Bank Corp. and Analysis Corp. All data is [<mark style="color:blue;">encrypted</mark>](../../../reference/protocols/secure-channels.md) with strong forward secrecy as it moves through the Internet. The communication channel is [<mark style="color:blue;">mutually authenticated</mark>](../../../reference/protocols/secure-channels.md) and [<mark style="color:blue;">authorized</mark>](../../../reference/protocols/access-controls.md). Keys and credentials are automatically rotated. Access to connect with postgres can be easily revoked.

Analysis Corp. does not get unfettered access to Bank Corp.’s cluster. It gets access only to run queries on the postgres server. Bank Corp. does not get unfettered access to Analysis Corp.’s cluster. It gets access only to respond to queries over a tcp connection. Bank Corp. cannot initiate connections.

All [<mark style="color:blue;">access controls</mark>](../../../reference/protocols/access-controls.md) are secure-by-default. Only project members, with valid credentials, can connect with each other. NAT’s are traversed using a relay and outgoing tcp connections. Bank Corp. or Analysis Corp. don’t expose any listening endpoints on the Internet. Their kubernetes clusters are completely closed and protected from any attacks from the Internet.

## Cleanup

To delete all containers and images:

```sh
./run.sh cleanup
```
