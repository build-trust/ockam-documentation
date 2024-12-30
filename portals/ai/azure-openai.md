# Azure OpenAI

Let's connect a python app in one virtual private network with an Azure OpenAI model configured with private endpoint in another virtual private network. You will use the Azure CLI to create these virtual networks and resources.

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/azure-openai (2).png" alt=""><figcaption></figcaption></figure>

## Create an Orchestrator Project

1. [Sign up](https://orchestrator.ockam.io/) for Ockam and pick a subscription plan through the guided workflow
2. Run the following commands to install Ockam Command and enroll with the Ockam Orchestrator. This step creates a Project in Ockam Orchestrator.

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source "$HOME/.ockam/env"

ockam enroll
```

## Run

This example requires Bash, Git, Curl, and the Azure CLI. Please set up these tools for your operating system. In particular you need to [<mark style="color:blue;">login to your Azure</mark>](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli#sign-into-azure-with-azure-cli) with `az login`.

Then run the following commands:

```
# Clone the Ockam repo from Github.
git clone --depth 1 https://github.com/build-trust/ockam && cd ockam

# Navigate to this example’s directory.
cd examples/command/portals/ai/azure_openai

# Run the example, use Ctrl-C to exit at any point.
./run.sh
```

If everything runs as expected, you'll see the answer to the question: "What is Ockham's Razor?".

## Walkthrough

The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh) script, that you ran above, and its [<mark style="color:blue;">accompanying files</mark>](https://github.com/build-trust/ockam/tree/develop/examples/command/portals/ai/azure_openai) are full of comments and meant to be read. The example setup is only a few simple steps, so please take some time to read and explore.

### Administrator

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L14) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L27) to create an new identity, sign into Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership <mark style="color:blue;">credential</mark>.
* The run function then [<mark style="color:blue;">generates two new enrollment tickets</mark>.](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L36-L45) The tickets are valid for 60 minutes. Each ticket can be redeemed only once and assigns [<mark style="color:blue;">attributes</mark>](../../reference/protocols/identities.md#credentials) to its redeemer. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L36-L37) is meant for the Ockam node that will run in AI Corp.’s network. The [<mark style="color:blue;">second ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L44-L45) is meant for the Ockam node that will run in Health Corp.’s network.
* In a typical production setup an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project.
* The run function passes the enrollment tickets as variables of the run scripts provisioning [<mark style="color:blue;">AI Corp.'s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L54) and [<mark style="color:blue;">Health Corp.'s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/run.sh#L59).

### AI Corp

First, the `ai_corp/run.sh` script creates a network to host the application exposing the Azure OpenAI Service Endpoint

* Network Infrastructure:
  * We [create an Azure Resource Group](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L7-L8) to contain all resources.
  * We [create a Virtual Network (VNet) with a subnet](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L12-L18) to host the services.
* Azure OpenAI Service Configuration:
  * We [deploy an Azure OpenAI Service](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L22-L29) instance.
  * We set up a private endpoint for secure access:
    * [Create a private endpoint connection](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L38-L45).
    * [Establish a private DNS zone](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L49-L51).
    * [Link the DNS zone to the virtual network](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L55-L60).
    * [Configure DNS records for private endpoint resolution](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L68-L79).
    * [Disable public network access and Update network ACLs to deny public access](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L89-L92).
* OpenAI Model Deployment:
  * We [deploy the specified model (gpt-4o-mini) on the OpenAI service](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L96-L104).
  * We retrieve the API key for authentication.
  * We create an environment file (.env.azure) containing:
    * The Azure OpenAI endpoint URL.
    * The API key for authentication.
* Virtual Machine Deployment:
  * We [process the Ockam setup script (run\_ockam.sh)](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L110-L113) by replacing variables:
    * Replaces SERVICE\_NAME and TICKET placeholders.
  * We [create a Red Hat Enterprise Linux VM](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/ai_corp/run.sh#L116-L126):
    * Place it in the configured VNet/subnet.
    * Generate SSH keys for access.
    * Inject the processed Ockam setup script as custom data.
    * The default Network Security Group (NSG) is configured with basic rules: inbound SSH access (port 22), internal virtual network communication, Azure Load Balancer access, and a final deny rule for all other inbound traffic. For outbound, it allows virtual network and internet traffic, with a final deny rule for all other outbound traffic.

{% hint style="warning" %}
Ensure your Azure Subscription has access to deploy the "gpt-4o-mini" model (version: 2024-07-18). You may need to request quota/access for this model through the Azure Portal if not already enabled for your subscription.
{% endhint %}

### Health Corp

First, the `health_corp/run.sh` script creates a network to host the `client.py` application which will connect to the Azure OpenAI model:

* Network Infrastructure Setup:
  * We create an [Azure Resource Group](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L8) to contain all resources.
  * We create a [Virtual Network (VNet) with a subnet ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L12-L18)to host the services.
* VM Deployment and Ockam Setup:
  * We [process the run\_ockam.sh script ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L23-L26)by replacing:
    * ${SERVICE\_NAME} with the configured service name.
    * ${TICKET} with the provided enrollment ticket.
  * We[ create a Red Hat Enterprise Linux 8 VM ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L30-L40)where the Ockam inlet node will run:
    * Use latest RHEL 8 LVM Gen2 image.
    * Generate SSH keys automatically.
    * Inject the processed Ockam setup script as custom data.
* Client Application Deployment:
  * We wait for VM to be accessible.
  * We [copy required files to the VM](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L49-L50):
    * Transfers client.py to the VM.
    * Copies .env.azure configuration file containing OpenAI credentials.
  * We [set up the Python environment](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L55-L56):
    * Install Python 3.9 and pip.
    * Install the OpenAI SDK.
  * We [execute the client application](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/run.sh#L57).
* Client Application Operation:
  * The client.py application:
    * [Connects to the Azure OpenAI service](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/client.py#L14) using credentials from .env.azure.
    * Sends queries to the model.
    * [Receives and displays responses on the console](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/ai/azure_openai/health_corp/client.py#L21).

## Recap

<figure><img src="../../.gitbook/assets/azure-openai (3).png" alt=""><figcaption></figcaption></figure>

We connected a Python application in one virtual network with an application serving an Azure OpenAI model in another virtual network over an end-to-end encrypted portal.&#x20;

Sensitive business data coming from the Azure OpenAI model is only accessible to AI Corp. and Health Corp. All data is encrypted with strong forward secrecy as it moves through the Internet. The communication channel is mutually authenticated and authorized. Keys and credentials are automatically rotated. Access to connect with the model API can be easily revoked.&#x20;

Health Corp. does not get unfettered access to AI Corp.'s network. It gets access only to run API queries to the Azure OpenAI service. AI Corp. does not get unfettered access to Health Corp.'s network. It gets access only to respond to queries over a TCP connection. AI Corp. cannot initiate connections.&#x20;

All access controls are secure-by-default. Only project members, with valid credentials, can connect with each other. NATs are traversed using a relay and outgoing TCP connections. AI Corp. or Health Corp. don't expose any listening endpoints on the Internet. Their Azure virtual networks are completely closed and protected from any attacks from the Internet through Network Security Groups (NSGs) that only allow essential communications.

## Cleanup

To delete all Azure resources:

```
./run.sh cleanup
```

