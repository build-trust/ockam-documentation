# Apply fine-grained permissions, at scale, with Attribute-Based Access Control (ABAC)

Attribute-Based Access Control (ABAC) is an authorization strategy that grants or denies access based on attributes.

A subject’s request to perform an operation on a resource is granted or denied based on attributes of the **subject**, attributes of the **operation**, attributes of the **resource**, and attributes of the **environment**. This is driven based on **policies** that define and enforced based on those attributes.

### Administrator

```bash
ockam enroll
ockam project information --output json > project.json
```

```bash
cp1_token=$(ockam project enroll --attribute application=suborbital --attribute component=control)
ep1_token=$(ockam project enroll --attribute application=suborbital --attribute component=edge)
x_token=$(ockam project enroll --attribute application=suborbital --attribute component=x)
```

### Control Plane

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create control_plane1 --project project.json --enrollment-token $cp1_token
ockam policy set --at control_plane1 --resource tcp-outlet \
  --expression '(and (= subject.application "suborbital") (= subject.component "edge"))'
ockam tcp-outlet create --at /node/control_plane1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create control_plane1 --at /project/default --to /node/control_plane1
```

### Edge Plane

```bash
ockam node create edge_plane1 --project project.json --enrollment-token $ep1_token
ockam policy set --at edge_plane1 --resource tcp-inlet \
  --expression '(and (= subject.application "suborbital") (= subject.component "control"))'
ockam tcp-inlet create --at /node/edge_plane1 --from 127.0.0.1:7000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet
```

```
curl --fail --head --max-time 10 127.0.0.1:7000
```

### X

This will not be allowed.

```bash
ockam node create x --project project.json --enrollment-token $x_token
ockam policy set --at x --resource tcp-inlet \
  --expression '(and (= subject.application "suborbital") (= subject.component "control"))'
ockam tcp-inlet create --at /node/x --from 127.0.0.1:8000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet
curl --fail --head --max-time 10 127.0.0.1:8000
```

