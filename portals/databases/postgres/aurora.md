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

# Amazon Aurora

Let's connect a nodejs app in one Amazon VPC with an Amazon RDS managed Postgres database in another Amazon VPC.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-09 at 8.51.05 AM (1).png" alt=""><figcaption></figcaption></figure>


## Run

This example requires Bash, Git, and AWS CLI. Please set up these tools for your operating system. In particular you need to [<mark style="color:blue;">login to your AWS account</mark>](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html) with `aws sso login`.

Then run the following commands:

```bash
# Clone the Ockam repo from Github.
git clone --depth 1 https://github.com/build-trust/ockam && cd ockam

# Navigate to this example’s directory.
cd examples/command/portals/databases/postgres/amazon_aurora/aws_cli

# Run the example, use Ctrl-C to exit at any point.
./run.sh
```

If everything runs as expected, you'll see the message: _The example run was successful 🥳_

## Walkthrough

The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh), that you ran above, and its [<mark style="color:blue;">accompanying files</mark>](https://github.com/build-trust/ockam/tree/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli) are full of comments and meant to be read. The example setup is only a few simple steps, so please take some time to read and explore.

### Administrator

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L14) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L27) to create an new identity, sign into Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership [<mark style="color:blue;">credential</mark>](../../../reference/protocols/identities.md#credentials).
* The run function then [<mark style="color:blue;">generates two new enrollment tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L36-L45). The tickets are valid for 10 minutes. Each ticket can be redeemed only once and assigns [<mark style="color:blue;">attributes</mark>](../../../reference/protocols/identities.md#credentials) to its redeemer. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L36-L37) is meant for the Ockam node that will run in Bank Corp.’s network. The [<mark style="color:blue;">second ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L44-L45) is meant for the Ockam node that will run in Analysis Corp.’s network.
* In a typical production setup an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project.
* The run function passes the enrollment tickets as variables of the run scripts provisioning [<mark style="color:blue;">Bank Corp.'s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L50C37-L50C56) and [<mark style="color:blue;">Analysis Corp.'s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/run.sh#L55C41-L55C64).

### Bank Corp

First, the `bank_corp/run.sh` script creates a network to host the database:

* We [<mark style="color:blue;">create a VPC</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L11-L12) and tag it.
* We [<mark style="color:blue;">create an Internet gateway</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L15-L16) and attach it to the VPC.
* We [<mark style="color:blue;">create a route table</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L19) and [<mark style="color:blue;">create a route</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L20) to the Internet via the gateway.
* We [<mark style="color:blue;">create two subnets, located in two distinct availability zones</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L23-L33), and associated to the route table.
* We finally [<mark style="color:blue;">create a security group</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L38-L41) so that there is:
  * [<mark style="color:blue;">One TCP egress to the Internet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L40),
  * And [<mark style="color:blue;">one ingress to Postgres</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L41) from within our two subnets.

Then, the `bank_corp/run.sh` script creates an Aurora database:

* This requires [<mark style="color:blue;">a subnet group</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L46-L47).
* Once the subnet group is created, we create a [<mark style="color:blue;">database cluster</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L48-L51) an a [<mark style="color:blue;">database instance</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L52-L55).
* Finally [<mark style="color:blue;">the address of the database is saved in an environment variable</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L56).

We are now ready to create an EC2 instance where the Ockam outlet node will run:

* We [<mark style="color:blue;">select an AMI</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L62-L64).
* We [<mark style="color:blue;">start an instance using the AMI</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L68-L70) above and a start script based on `run_ockam.sh` where:
  * [<mark style="color:blue;">`ENROLLMENT_TICKET`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">is replaced by the enrollment ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L66) created by the administrator and given as a parameter to `run.sh`.
  * [<mark style="color:blue;">`POSTGRES_ADDRESS`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">is replaced by the database address</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L67) that we previously saved.
* We [<mark style="color:blue;">tag the created instance</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L71) and [<mark style="color:blue;">wait for it to be available</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run.sh#L72).

When the instance is started, the `run_ockam.sh` script is executed:

* The [<mark style="color:blue;">`ockam`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">executable is installed</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run\_ockam.sh#L10-L11).
* The [<mark style="color:blue;">enrollment ticket is used to create a default identity and make it a project member</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run\_ockam.sh#L26).
* We then create an Ockam node:
  * With [<mark style="color:blue;">a TCP outlet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run\_ockam.sh#L39).
  * A [<mark style="color:blue;">policy associated to the outlet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run\_ockam.sh#L40). The policy authorizes identities with a credential containing the attribute <mark style="background-color:yellow;">postgres-inlet="true"</mark>.
  * With [<mark style="color:blue;">a relay</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/bank\_corp/run\_ockam.sh#L41) capable of forwarding the TCP traffic to the TCP outlet.

### Analysis Corp

First, the `analysis_corp/run.sh` script creates a network to host the nodejs application:

* We [<mark style="color:blue;">create a VPC</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L11-L12) and tag it.
* We [<mark style="color:blue;">create an Internet gateway</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L15-L16) and attach it to the VPC.
* We [<mark style="color:blue;">create a route table</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L19) and [<mark style="color:blue;">create a route</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L20) to the Internet via the gateway.
* We [<mark style="color:blue;">create a subnet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L23-L27), and associated to the route table.
* We finally [<mark style="color:blue;">create a security group</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L32-L35) so that there is:
  * [<mark style="color:blue;">One TCP egress to the Internet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L40),
  * And [<mark style="color:blue;">One SSH ingress</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L41) to download and install the nodejs application.

We are now ready to create an EC2 instance where the Ockam inlet node will run:

* We [<mark style="color:blue;">select an AMI</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L40).
* We [<mark style="color:blue;">start an instance using the AMI</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L47-L61) above and a start script based on `run_ockam.sh` where:
  * [<mark style="color:blue;">`ENROLLMENT_TICKET`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">is replaced by the enrollment ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L66) created by the administrator and given as a parameter to `run.sh`.

The instance is started and the `run_ockam.sh` script is executed:

* The [<mark style="color:blue;">`ockam`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">executable is installed</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run\_ockam.sh#L10-L11).
* The [<mark style="color:blue;">enrollment ticket is used to create a default identity and make it a project member</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run\_ockam.sh#L26).
* We then create an Ockam node:
  * With [<mark style="color:blue;">a TCP inlet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run\_ockam.sh#L36).
  * A [<mark style="color:blue;">policy associated to the inlet</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run\_ockam.sh#L39). The policy authorizes identities with a credential containing the attribute <mark style="background-color:yellow;">postgres-outlet="true"</mark>.

We finally wait for the instance to be ready and install the nodejs application:

* The [<mark style="color:blue;">app.js file</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/app.js) is [<mark style="color:blue;">copied to the instance</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L56) (this uses the previously created `key.pem` file to identify).
* We can then [<mark style="color:blue;">SSH to the instance</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L57) and:
  * [<mark style="color:blue;">Install nodejs</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L59).
  * [<mark style="color:blue;">Install the Postgres client library</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L60).
  * [<mark style="color:blue;">Start the nodejs application</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/run.sh#L61).

Once the nodejs application is started:

* It will [<mark style="color:blue;">connect to the Ockam inlet at port 12345</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/app.js#L9).
* It [<mark style="color:blue;">creates a database table and runs some SQL queries</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/amazon\_aurora/aws\_cli/analysis\_corp/app.js#L50-L61) to check that the connection with the Postgres database works.

## Recap

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-09 at 8.51.05 AM (2).png" alt=""><figcaption></figcaption></figure>

We connected a nodejs app in one virtual private network with a postgres database in another virtual private network over an end-to-end encrypted portal.

Sensitive business data in the postgres database is only accessible to Bank Corp. and Analysis Corp. All data is [<mark style="color:blue;">encrypted</mark>](../../../reference/protocols/secure-channels.md) with strong forward secrecy as it moves through the Internet. The communication channel is [<mark style="color:blue;">mutually authenticated</mark>](../../../reference/protocols/secure-channels.md) and [<mark style="color:blue;">authorized</mark>](../../../reference/protocols/access-controls.md). Keys and credentials are automatically rotated. Access to connect with postgres can be easily revoked.

Analysis Corp. does not get unfettered access to Bank Corp.’s network. It gets access only to run queries on the postgres server. Bank Corp. does not get unfettered access to Analysis Corp.’s network. It gets access only to respond to queries over a tcp connection. Bank Corp. cannot initiate connections.

All [<mark style="color:blue;">access controls</mark>](../../../reference/protocols/access-controls.md) are secure-by-default. Only project members, with valid credentials, can connect with each other. NAT’s are traversed using a relay and outgoing tcp connections. Bank Corp. or Analysis Corp. don’t expose any listening endpoints on the Internet. Their networks are completely closed and protected from any attacks from the Internet.

## Cleanup

To delete all AWS resources:

```sh
./run.sh cleanup
```
