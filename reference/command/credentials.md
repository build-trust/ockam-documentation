---
description: >-
  Scale mutual trust using lightweight, short-lived, revocable, attribute-based
  credentials.
---

# Verifiable Credentials

## Credentials

An Ockam Credential is a signed attestation by an <mark style="color:orange;">Issuer</mark> about the <mark style="color:orange;">Attributes</mark> of <mark style="color:orange;">Subject</mark>. The Issuer and Subject are both Ockam [Identities](identities.md). Attributes is a list of name and value pairs.

### Issuing Credentials

Any Ockam Identity can issue credentials about another Ockam Identity.

```
» ockam identity create a
     ✔︎ Identity P8b604a07640ecd944f379b5a1a5da0748f36f76327b00193067d1d8c6092dfae
       created successfully as a

» ockam identity create b
     ✔︎ Identity P5c14d09f32dd27255913d748d276dcf6952b7be5d0be4023e5f40787b53274ae
       created successfully as b

» ockam credential issue --as a --for $(ockam identity show b --full --encoding hex)
Subject:    P5c14d09f32dd27255913d748d276dcf6952b7be5d0be4023e5f40787b53274ae
Issuer:     P8b604a07640ecd944f379b5a1a5da0748f36f76327b00193067d1d8c6092dfae
Created:    2023-04-06T17:05:36Z
Expires:    2023-05-06T17:05:36Z
Attributes: {}
Signature:  6feeb038f0cdc28a16fbe3ed4f69feee5ccce3d2a6ac8be83e76180e7bbd3c6e0adbe37ed73c75bb3c283807ec63aeda42dd79afd3813d4658222078cad12705
```

The Issuer can include specific attributes in the attestation:

```
» ockam credential issue --as a --for $(ockam identity show b --full --encoding hex) \
    --attribute location=Chicago --attribute department=Operations
Subject:    P5c14d09f32dd27255913d748d276dcf6952b7be5d0be4023e5f40787b53274ae
Issuer:     P8b604a07640ecd944f379b5a1a5da0748f36f76327b00193067d1d8c6092dfae (OCKAM_RK)
Created:    2023-04-06T17:26:40Z
Expires:    2023-05-06T17:26:40Z
Attributes: {"department": "Operations", "location": "Chicago"}
Signature:  b235429f8dc7be2e79bca0b8f59bdb6676b06f608408085097e7fb5a2029de0d27d6352becaecd0a5488e0bf56c5e5031613c2af2e6713b03b57e08340d99002
```

### Verifying Credentials

```
» ockam reset -y

» ockam identity create a
» ockam identity create b

» ockam credential issue --as a --for $(ockam identity show b --full --encoding hex) \
    --encoding hex > b.credential

» ockam credential verify --issuer $(ockam identity show a --full --encoding hex) \
    --credential-path b.credential
✔︎ Verified Credential
```

### Storing Credentials

```
» ockam credential store c1 --issuer $(ockam identity show a --full --encoding hex) \
    --credential-path b.credential
Credential c1 stored
```

## Trust Anchors

Trust and authorization decisions must be anchored in some pre-existing knowledge.

### Anchoring Trust in an Access Control List (ACL) of Identifiers

In the previous section about Ockam [Secure Channels](secure-channels.md) we ran an example of [mutual authorization](secure-channels.md#mutual-authorization) using pre-existing knowledge of Ockam [Identifiers](identities.md#identifier). In this example `n1 knows i2` and `n2 know i1`:

```
» ockam reset -y

» ockam identity create i1
» ockam identity show i1 > i1.identifier
» ockam node create n1 --identity i1

» ockam identity create i2
» ockam identity show i2 > i2.identifier
» ockam node create n2 --identity i2

» ockam secure-channel-listener create l --at n2 \
    --identity i2 --authorized $(cat i1.identifier)

» ockam secure-channel create \
    --from n1 --to /node/n2/service/l \
    --identity i1 --authorized $(cat i2.identifier) \
      | ockam message send hello --from n1 --to -/service/uppercase
HELLO
```

### Anchoring Trust in a Credential Issuer

```
» ockam reset -y

» ockam identity create authority
» ockam identity show authority > authority.identifier
» ockam identity show authority --full --encoding hex > authority

» ockam identity create i1 
» ockam identity show i1 --full --encoding hex > i1
» ockam credential issue --as authority --for $(cat i1) --attribute city="New York" --encoding hex > i1.credential
» ockam credential store c1 --issuer $(cat authority) --credential-path i1.credential

» ockam identity create i2
» ockam identity show i2 --full --encoding hex > i2
» ockam credential issue --as authority \
	--for $(cat i2) --attribute city="San Francisco" \
	--encoding hex > i2.credential
» ockam credential store c2 --issuer $(cat authority) --credential-path i2.credential

» ockam node create n1 --identity i1 --authority-identity $(cat authority)
» ockam node create n2 --identity i2 --authority-identity $(cat authority) --credential c2

» ockam secure-channel create --from n1 --to /node/n2/service/api --credential c1 --identity i1 \
    | ockam message send hello --from n1 --to -/service/uppercase
```

## Managed Authorities

```
» ockam reset -y
» ockam enroll

» ockam project information --output json > project.json

» ockam node create a --project-path project.json
» ockam node create b --project-path project.json

» ockam relay create b --at /project/default --to /node/a/service/forward_to_b

» ockam secure-channel create --from a --to /project/default/service/forward_to_b/service/api \
    | ockam message send hello --from a --to -/service/uppercase
HELLO
```
