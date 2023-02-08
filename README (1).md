# Get Started

### Install Ockam Command

Ockam Command is our Command Line Interface (CLI) for interfacing with Ockam processes.&#x20;

{% tabs %}
{% tab title="MacOS + Homebrew" %}
If you use Homebrew, you can install Ockam using brew:

```
brew install build-trust/ockam/ockam
```
{% endtab %}

{% tab title="Other systems" %}
```
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```

After the binary downloads, please move it to a location in your shell's $PATH, like /usr/local/bin.
{% endtab %}
{% endtabs %}

#### Check Your Install

Check that your install has worked successfully by enrolling with the Ockam Orchestrator:

```bash
ockam enroll
```

Next we'll cover some of the core concepts that enable Ockam to build secure by-design applications.
