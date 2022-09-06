# Get Started

## Command

### Install

#### Homebrew

```bash
brew install build-trust/ockam/ockam
```

#### Precompiled Binaries

{% tabs %}
{% tab title="MacOS x86_64 " %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.72.0/ockam.x86_64-apple-darwin

# rename the download binary and give it permission to execute
mv ockam.x86_64-apple-darwin ockam
chmod u+x ockam
```
{% endtab %}

{% tab title="Linux x86_64" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.72.0/ockam.x86_64-unknown-linux-gnu

# rename the download binary and give it permission to execute
mv ockam.x86_64-unknown-linux-gnu ockam
chmod u+x ockam
```
{% endtab %}

{% tab title="MacOS aarch64" %}
```bash
# download ockam command binary for your architecture
curl --proto '=https' --tlsv1.2 -sSfL -O \
  https://github.com/build-trust/ockam/releases/download/ockam_v0.72.0/ockam.aarch64-apple-darwin

# rename the download binary and give it permission to execute
mv ockam.aarch64-apple-darwin ockam
chmod u+x ockam
```
{% endtab %}
{% endtabs %}

### Upgrade&#x20;

#### Homebrew

```
brew update && brew upgrade ockam
```
