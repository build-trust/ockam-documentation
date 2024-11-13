---
description: Create an Ockam Bedrock outlet node using Cloudformation template
---

# Ockam Node for Amazon Bedrock

[Amazon Bedrock ](https://aws.amazon.com/bedrock/)is a fully managed service that makes high-performing foundation models (FMs) from leading AI companies and Amazon available for your use through a unified API. Organizations building innovative generative AI applications with Amazon Bedrock often need to ensure their proprietary data remains secure and private while accessing these powerful models.&#x20;

By default, You can access Amazon Bedrock over the public internet, which means:

1. Your API calls to Bedrock travel across the public internet.
2. Your client must have public internet connectivity
3. You must implement additional security measures to protect your data in transit

### The Security Challenge

When you build AI applications with sensitive or proprietary data, exposing them to the public internet creates several risks:

* Your data may travel through unknown network paths
* Attackers gain more potential entry points
* Your compliance requirements may prohibit public internet usage
* You must maintain extra security controls and monitoring

**Understanding VPC Endpoints for Amazon Bedrock**

**How VPC Endpoints Work**

AWS PrivateLink powers VPC endpoints, which let you access Amazon Bedrock privately without exposing data to the public internet. When you create a private connection between your VPC and Bedrock:

1. Your traffic stays within AWS network infrastructure
2. You eliminate the need for public endpoints
3. Your data remains on private AWS networks

However, organizations often need additional capabilities:

* Access to Bedrock from outside AWS
* Secure connections from other cloud providers
* Private access from on-premises environments

This is where Ockam comes helps.

Read: “[How does Ockam work?](https://docs.ockam.io/how-does-ockam-work)” to learn about end-to-end trust establishment.

<figure><img src="../../../../.gitbook/assets/aws marketplace (1).png" alt=""><figcaption></figcaption></figure>

### PreRequisite

* You have permission to subscribe and launch Cloudformation stack from AWS Marketplace on the AWS Account running Amazon Redshift.
* Make sure AWS Bedrock is available in the region you are deploying the cloudformation template.&#x20;

### Create an Orchestrator Project

1. [Sign up for Ockam](https://www.ockam.io/download) and pick a subscription plan through the guided workflow on Ockam.io.
2. Run the following commands to install Ockam Command and enroll with the Ockam Orchestrator.

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source "$HOME/.ockam/env"

ockam enroll
```

3. Control which identities are allowed to enroll themselves into your project by issuing unique one-time use enrollment tickets. Generate two enrollment tickets, one for the Outlet and one for the Inlet.

```bash
# Enrollment ticket for Ockam Outlet Node
ockam project ticket --expires-in 10h --usage-count 1 \
  --attribute amazon-bedrock-outlet \
  --relay bedrock \
    > "outlet.ticket"

# Enrollment ticket for Ockam Inlet Node
ockam project ticket --expires-in 10h --usage-count 1 \
  --attribute amazon-bedrock-inlet --tls \
    > "inlet.ticket"
```

### Setup Ockam Bedrock Outlet Node

* Login to AWS Account you would like to use
* Subscribe to "Ockam - Node for Amazon Bedrock"  in AWS Marketplace&#x20;
* Navigate to `AWS Marketplace -> Manage subscriptions`. Select `Ockam - Node for Amazon Bedrock` from the list of subscriptions. Select `Actions-> Launch Cloudformation stack`&#x20;
* Select the Region you want to deploy and click `Continue to Launch`. Under Actions, select `Launch Cloudformation`
* Create stack with the following details
  * **Stack name**: `bedrock-ockam-outlet` or any name you prefer
  * Network Configuration
    * **VPC ID:** Choose a VPC ID where the VPC Endpoint for Bedrock and EC2 instance will be deployed.
    * **Subnet ID:** Select a suitable Subnet ID within the chosen VPC.
    * **EC2 Instance Type**: Default instance type is `m6a.large`. please use different instance types based on your use case.
  * Ockam Node Configuration
    * **Enrollment ticket**: Copy and paste the content of the `outlet.ticket` generated above
    * **JSON Node Configuration**: Copy and paste the below configuration. Note that the configuration values (relay, allow attribute) match with the enrollment tickets created in the previous step. `$BEDROCK_RUNTIME_ENDPOINT` will be replaced during runtime.

```json
{
    "http-server-port": 23345,
    "relay": "bedrock",
    "tcp-outlet": {
        "to": "$BEDROCK_RUNTIME_ENDPOINT:443",
        "allow": "amazon-bedrock-inlet",
        "tls": true
    }
}
```

* Click Next to launch the CloudFormation run.
* A successful CloudFormation stack run&#x20;
  * Creates a VPC Endpoint for Bedrock Runetime API
  * Configures an Ockam Bedrock Outlet node on an EC2 machine.
  * EC2 machine mounts an EFS volume created in the same subnet. Ockam state is stored in the EFS volume.
  * A security group with ingress access within the security group and egress access to the internet will be attached to the EC2 machine and VPC Endpoint.
* Connect to the EC2 machine via AWS Session Manager.&#x20;
  * To view the log file, run `sudo cat /var/log/cloud-init-output.log`.
  * _Note: DNS Resolution for the EFS drive may take up to 10 minutes. The script will retry_
  * A Successful run will show `Ockam node setup completed successfully` in the above log.
  * To view the status of Ockam node run `curl http://localhost:23345/show | jq`
* View the Ockam node status in CloudWatch.
  * Navigate to `Cloudwatch -> Log Group` and select `bedrock-ockam-outlet-status-logs`. Select the Logstream for the EC2 instance.&#x20;
  * The Cloudformation template creates a subscription filter which sends data to a Cloudwatch alarm `bedrock-ockam-outlet-OckamNodeDownAlarm.`Alarm will turn green upon ockam node successfully running.&#x20;
* An Autoscaling group keeps atleast one EC2 instance is running.

Ockam bedrock outlet node setup is complete. You can now create Ockam bedrock inlet nodes in any network to establish secure communication.

### Setup Bedrock Ockam Inlet Node

You can set up an Ockam Bedrock Inlet Node locally using Docker.  You can then use any library (aws cli, python, javascript etc)  to access AWS Bedrock via Ockam inlet

* Create a file named `docker-compose.yml` with the following content:

```yaml
services:
  ockam:
    image: ghcr.io/build-trust/ockam
    container_name: bedrock-inlet
    environment:
      ENROLLMENT_TICKET: ${ENROLLMENT_TICKET:-}
      OCKAM_DEVELOPER: ${OCKAM_DEVELOPER:-false}
      OCKAM_LOGGING: true
      OCKAM_LOG_LEVEL: debug
    ports:
      - "443:443"  # Explicitly expose port 443
    command:
      - node
      - create
      - --enrollment-ticket
      - ${ENROLLMENT_TICKET}
      - --foreground
      - --configuration
      - |
        tcp-inlet:
          from: 0.0.0.0:443
          via: bedrock
          allow: amazon-bedrock-outlet
          tls: true
    network_mode: bridge
```

Run the following command from the same location as the `docker-compose.yml` and the `inlet.ticket` to create an Ockam bedrock inlet that can connect to the outlet running in AWS , along with psql client container.&#x20;

```bash
ENROLLMENT_TICKET=$(cat inlet.ticket) docker-compose up -d
```

* Check status of Ockam inlet node. You will see `The node is UP` when ockam is configured successfully and ready to accept connection

```bash
docker exec -it bedrock-inlet /ockam node show
```

*   Find your Ockam project id and use it to create to endpoint to bedrock

    ```bash
    # Below command will find your ockam project id 
    ockam project show --jq .id 
    ```
* Construct bedrock endpoint url

```bash
https://ANY_STRING_YOU_LIKE.YOUR_PROJECT_ID.ockam.network
```

* An example bedrock endpoint url will look like below

```bash
BEDROCK_ENDPOINT=https://bedrock-runtime.d8eafd41-ff3e-40ab-8dbe-936edbe3ad3c.ockam.network
```

* Run below AWS CLI Command.

{% hint style="info" %}
NOTE:&#x20;

1\) You should have `amazon-titan-text-lite-v1` model enabled on the Account/Region&#x20;

2\) You need AWS Credentials for the account with permission to run the below command.
{% endhint %}

```bash
export AWS_REGION=<YOUR_REGION> 
aws bedrock-runtime invoke-model \
--endpoint-url $BEDROCK_ENDPOINT \
--model-id amazon.titan-text-lite-v1 \
--body '{"inputText": "Describe the purpose of a \"hello world\" program in one line.", "textGenerationConfig" : {"maxTokenCount": 512, "temperature": 0.5, "topP": 0.9}}' \
--cli-binary-format raw-in-base64-out \
invoke-model-output-text.txt
```

The above command should produce similar result

```bash
> cat invoke-model-output-text.txt
{"inputTextTokenCount":15,"results":[{"tokenCount":26,"outputText":"\nThe purpose of a \"hello world\" program is to print the text \"hello world\" to the console.","completionReason":"FINISH"}]}
```

* Cleanup

```bash
docker compose down --volumes --remove-orphans
```

### **Summary**&#x20;

This guide walked you through:

* Understanding the security challenges of accessing Amazon Bedrock over the public internet
* How VPC endpoints secure your Bedrock communications within AWS
* Setting up Ockam to extend this security beyond AWS boundaries
* Deploying and configuring both Outlet and Inlet nodes
* Testing your secure connection with a simple Bedrock API call
