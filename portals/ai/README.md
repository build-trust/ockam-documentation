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

# AI

Create an Ockam **Portal** from any application, to any AI model, in any environment.

In each example, we connect a nodejs app in one private network with an AI service in another private network.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/portals-ai.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The Amazon EC2 example uses a LLaMA model and the Amazon Bedrock model uses an Amazon Titan model. However, the same setup works for any other AI models: _GPT, Claude, LaMDA, etc._
{% endhint %}

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><mark style="color:blue;"><strong>Amazon EC2</strong></mark></td><td>We connect a nodejs app in an AWS virtual private network with a LLaMA model provisioned on an EC2 instance in another AWS virtual private network. The example uses the AWS CLI to instantiate AWS resources.</td><td><a href="amazon_ec2.md">amazon_ec2.md</a></td></tr><tr><td><mark style="color:blue;"><strong>Amazon Bedrock</strong></mark></td><td>We connect a nodejs app in an AWS virtual private network with an Amazon Bedrock API in another AWS virtual private network. The example uses the AWS CLI to instantiate AWS resources.</td><td><a href="amazon_bedrock.md">amazon_bedrock.md</a></td></tr></tbody></table>
