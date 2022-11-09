---
description: Authenticate and authorize every access decision.
---

# Use employee attributes from Okta to Build Trust with Cryptographically Verifiable Credentials

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data and instructions.

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Applications must also decide if a sender of a request is **authorized** to trigger the requested action or view the requested data.

In scenarios where human users are authenticating with cloud services, we have mature protocols like OAuth 2.0 and OpenID Connect (OIDC). However, majority of data that flows within modern applications doesn’t involve humans. Microservices interact with other microservices, devices interact with other devices and cloud services, internal services interact with partner systems and infrastructure services etc.

To be **secure** **by-design**, applications must ensure that all machine-to-machine application layer communication is authenticated and authorized. For this, **applications need to prove identifiers and attributes.**



<figure><img src="../.gitbook/assets/diagrams.003 (1).jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>



First install the Ockam command, if you haven't already. If you use Homebrew, you can install Ockam using `brew`.

```bash
brew install build-trust/ockam/ockam
```

If you're on linux, see how to install [precompiled binaries](../ockam-open-source.md#precompiled-binaries).

### Administrator

```bash
ockam enroll
ockam project addon configure okta \
  --tenant https://trial-9434859.okta.com/oauth2/default --client-id 0oa2pi8no6Kb04frP697 \
  --attribute email --attribute city --attribute department

ockam project information --output json > project.json
```

```
m1_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="San Francisco")
m2_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="New York")
```

### Machine 1 in New York

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create m1 --project project.json --enrollment-token $m1_token
ockam policy set --at m1 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "San Francisco")))'
ockam tcp-outlet create --at /node/m1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create m1 --at /project/default --to /node/m1
```

### Machine 2 in San Francisco

```
python3 -m http.server --bind 127.0.0.1 6000
```

```bash
ockam node create m2 --project project.json --enrollment-token $m2_token
ockam policy set --at m2 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "New York")))'
ockam tcp-outlet create --at /node/m2 --from /service/outlet --to 127.0.0.1:6000
ockam forwarder create m2 --at /project/default --to /node/m2
```

### Platform Engineer for San Francisco

```bash
ockam node create alice --project project.json
ockam project authenticate --project project.json
ockam policy set --at alice --resource tcp-inlet --expression '(= subject.application "Smart Factory")'
```

The following is allowed:

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:8000 --to /project/default/service/forward_to_m1/secure/api/service/outlet
curl --head 127.0.0.1:8000
```

The following is denied:

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:9000 --to /project/default/service/forward_to_m2/secure/api/service/outlet
curl --head 127.0.0.1:9000
```
