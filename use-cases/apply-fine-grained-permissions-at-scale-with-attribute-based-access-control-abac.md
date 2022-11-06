# Apply fine-grained permissions, at scale, with Attribute-Based Access Control (ABAC)

Attribute-Based Access Control (ABAC) is an authorization strategy that grants or denies access based on attributes.

A subject’s request to perform an operation on a resource is granted or denied based on attributes of the **subject**, attributes of the **operation**, attributes of the **resource**, and attributes of the **environment**. This is driven based on **policies** that define and enforced based on those attributes.

```
ockam enroll
```

```
ockam project info --output json > project.json
blue_token=$(ockam project enroll --attribute permission=data)
green_token=$(ockam project enroll --attribute permission=data)
```

```
python3 -m http.server --bind 127.0.0.1 5000
```

```
ockam node create blue --project project.json --enable-credential-checks --enrollment-token $blue_token
ockam policy set --at blue --resource outlet --expression '(= subject.permission "data")'
ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create blue --at /project/default --to /node/blue
```

```
ockam node create green --project project.json --enable-credential-checks --enrollment-token $green_token
ockam policy set --at green --resource inlet --expression '(= subject.permission "data")'
ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to /project/default/service/forward_to_blue/secure/api/service/outlet
```

```
curl --head 127.0.0.1:7000
```
