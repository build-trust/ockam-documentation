---
description: Use Ockam Orchestrator for your company's applications.
---

# Get Started

To get started, with Ockam Orchestrator you will need the Ockam CLI:

## 1. Install the Ockam CLI

### Homebrew

```bash
brew install build-trust/ockam/ockam
```

### Precompiled Binaries

{% tabs %}
{% tab title="x86_64-unknown-linux-gnu" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.73.0/ockam.x86_64-unknown-linux-gnu

# rename the download binary and give it permission to execute
mv ockam.x86_64-unknown-linux-gnu ockam
chmod u+x ockam
```
{% endtab %}

{% tab title="armv7-unknown-linux-gnueabihf" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.73.0/ockam.armv7-unknown-linux-gnueabihf

# rename the download binary and give it permission to execute
mv ockam.armv7-unknown-linux-gnueabihf ockam
chmod u+x ockam
```
{% endtab %}

{% tab title="aarch64-apple-darwin" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.73.0/ockam.aarch64-apple-darwin

# rename the download binary and give it permission to execute
mv ockam.aarch64-apple-darwin ockam
chmod u+x ockam
```
{% endtab %}

{% tab title="x86_64-apple-darwin" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.73.0/ockam.x86_64-apple-darwin

# rename the download binary and give it permission to execute
mv ockam.x86_64-apple-darwin ockam
chmod u+x ockam
```
{% endtab %}
{% endtabs %}



