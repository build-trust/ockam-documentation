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

This section contains hands-on examples that use [<mark style="color:blue;">Ockam</mark>](../../) to create **encrypted portals** to various AI services running in various environments.

In each example, we connect a nodejs app in one private network with an AI service in another private network. 
To understand how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, 
please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/Screenshot 2024-02-11 at 1.32.40 PM.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The examples below use a LLaMA API, however, the same setup works for any other AI models: _GPT, Claude, LaMDA, etc._
{% endhint %}

<table data-card-size="large" data-view="cards"><thead>
<tr><th></th><th></th></tr></thead><tbody><tr><td><a href="amazon_ec2/llama.md"><mark style="color:blue;"><strong>LLaMA</strong></mark></a></td><td>We connect a nodejs app in an AwS virtual private network with a LLaMA API in another AWS virtual private network. The example uses the AWS CLI to instantiate AWS resources.</td></tr>
</tbody></table>
