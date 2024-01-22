---
description: Create TCP Inlet/Outlet from AWS Marketplace
---

# AWS Marketplace TCP Outlet/Inlet

In this example we will create an Ockam Portal with a TCP Inlet and a TCP Outlet by launching CloudFormation template from AWS Marketplace.

## Overview:

<figure><img src="../../.gitbook/assets/aws_marketplace.svg" alt=""><figcaption></figcaption></figure>

1. Install Ockam Command and create enrollment tickets for the Outlet and Inlet.
2. Use the enrollment ticket for the Outlet and launch CloudFormation template from AWS Marketplace.
3. Use the enrollment ticket for the Inlet and launch CloudFormation template from AWS Marketplace.

> Note that the Inlet and Outlet can be on two different EC2 machines on different AWS accounts.

### Architecture:

<figure><img src="../../.gitbook/assets/aws_marrketplace_inlet_outlet.svg" alt=""><figcaption></figcaption></figure>

### Steps:

#### 1. Install Ockam Command

Install the [<mark style="color:blue;">Ockam command</mark>](https://docs.ockam.io/#quick-start), if you haven't already, by following the instructions below.

{% hint style="info" %}
Ockam Command is our Command Line Interface (CLI) to build and orchestrate secure distributed applications using Ockam.
{% endhint %}

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew.

```sh
# Tap and install Ockam Command
brew install build-trust/ockam/ockam
```

This will download a precompiled binary and add it to your path. If you don’t use Homebrew, you can also install on Linux and MacOS systems using curl. See instructions for other systems in the next tab.
{% endtab %}

{% tab title="Other Systems" %}
On Linux and MacOS, you can download precompiled binaries for your architecture using curl.

```shell
curl --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | bash
```

This will download a precompiled binary and add it to your path. If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
{% endtab %}
{% endtabs %}

#### 2. Generate enrollment tickets

* As the administrator of Ockam project, start by enrolling with the Orchestrator. Run the following command to ensure the default project is setup and ready to use.

```shell
ockam enroll
```

* You are able to control what other identities are allowed to enroll themselves into your project by issuing unique one-time use enrollment tickets. Generate two enrollment tickets, one for the Outlet and one for the Inlet.

```shell

# Choose a name that identifies your resource.
# Below is a sample you can use for this demo.
RESOURCE_IDENTIFIER="aws:cft:demo"

# Enrollment ticket for Outlet.
ockam project ticket --expires-in 24h --usage-count 1 \
  --attribute component=${RESOURCE_IDENTIFIER}:outlet \
  --relay ${RESOURCE_IDENTIFIER}:outlet \
    > "${RESOURCE_IDENTIFIER}:outlet.enrollment.ticket"

# Enrollment ticket for Inlet.
ockam project ticket --expires-in 24h --usage-count 1 \
  --attribute component=${RESOURCE_IDENTIFIER}:inlet \
    > "${RESOURCE_IDENTIFIER}:inlet.enrollment.ticket"

```

#### 3. Setup TCP Outlet

* Open the Ockam CloudFormation template from AWS Marketplace. Choose the `AWS Region` you would like to deploy to.
* Stack name: `ockam-ec2-instance-outlet` or any name you prefer.
* Network Configuration:
  * Select suitable values for your topology.
* Ockam Configuration:
  * `Ockam TCP Outlet or Inlet`: Choose `outlet`.
  * `Enrollment ticket`: Copy and paste the content of the `outlet` ticket generated above.
  * `Resource Identifier`: Enter the value of resource identifier (`${RESOURCE_IDENTIFIER}`) used to generate enrollment tickets. If you are following this example, use `aws:cft:demo`.
  * `Resource Address`: Enter `127.0.0.1:7777`. In the upcoming steps, you will setup a webhook on the same EC2 machine listening on port `7777`. _This could be any resource in the AWS account that the EC2 machine can access_.
* Click Next to launch the CloudFormation run.
* Upon successful CloudFormation stack run, the Ockam outlet will be configured on an EC2 machine.
* Connect to the EC2 machine via AWS Session Manager. To view the log file, run `sudo cat /var/log/cloud-init-output.log`.
* Let's set up a webhook. Copy the code below to this file: `/opt/webhook_receiver.py`.

```py
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging

# Setting up the basic configuration for logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Creating a logger instance
logger = logging.getLogger(__name__)

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/webhook':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            logger.info('Received webhook: %s', post_data.decode())

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Webhook received')

def run(server_class=HTTPServer, handler_class=WebhookHandler, port=7777):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)

    # Using logger for initial server start information
    logger.info("Webhook server running on port %s...", port)
    httpd.serve_forever()

if __name__ == '__main__':
    run()

```

* Run `python3 /opt/webhook_receiver.py` to start the webhook that will listen on port `7777`. Note that the Outlet will send traffic to this webhook, so keep the window open as you setup the Inlet to test the Portal.

#### 4. Setup TCP Inlet

* Open the Ockam CloudFormation template from AWS Marketplace. Choose the `AWS Region` you would like to deploy to.
* Stack name: `ockam-ec2-instance-inlet` or name of your choice.
* Network Configuration:
  * Select suitable values.
* Ockam Configuration:
  * `Ockam TCP Outlet or Inlet`: Choose `inlet`
  * `Enrollment ticket`: Copy paste the `inlet` ticket generated above
  * `Resource Identifier`: Enter the value of resource identifier (`${RESOURCE_IDENTIFIER}`) used to generate enrollment tickets. If you are following this example, use `aws:cft:demo`.
  * `Resource Address`: Enter `127.0.0.1:7775`. The Inlet will listen at this address.
* Click Next to launch the CloudFormation run.
* Upon successful CloudFormation run, the Ockam Inlet is configured on an EC2 machine.
* Connect to the EC2 machine via AWS Session Manager. To view the log file, run `sudo cat /var/log/cloud-init-output.log`.
* Run the command below to post a request to the Inlet address. You must receive a response. Verify that the request reaches the webhook running on the Outlet machine.

```shell
curl -X POST http://localhost:7775/webhook -H "Content-Type: application/json" -d "{\"date\": \"$(date +%Y-%m-%d)\"}"
```

You have now successfully created an Ockam Portal and verified secure communication 🎉.

#### 4. Cleanup

* Delete the Outlet CloudFormation stack from the AWS Account.
* Delete the Inlet CloudFormation stack from the AWS Account.
* Delete the Ockam Project from the machine that the administrator used to generate enrollment tickets.

```shell
ockam reset --all --yes
```
