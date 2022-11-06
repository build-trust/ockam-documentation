# Use employee attributes from Okta to scale

### Enroller

```bash
ockam enroll
ockam project addon configure okta --tenant trial-9434859.okta.com --client-id 0oa2pi8no6Kb04frP697 --attribute email --attribute permission
```

```
ockam project info --output json > project.json
blue_token=$(ockam project enroll --attribute permission=data)
green_token=$(ockam project enroll --attribute permission=data)
```

### Blue

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create blue --project project.json --enable-credential-checks --enrollment-token $blue_token
ockam policy set --at blue --resource outlet --expression '(or (= subject.permission "data") (= subject.permission "support"))'
ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create blue --at /project/default --to /node/blue
```

### Green

```bash
ockam node create green --project project.json --enable-credential-checks --enrollment-token $green_token
ockam policy set --at green --resource inlet --expression '(= subject.permission "data")'
ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to /project/default/service/forward_to_blue/secure/api/service/outlet
```

```
curl --head 127.0.0.1:7000
```

### Support Engineer

```bash
ockam node create support --project project.json --enable-credential-checks
ockam project authenticate --project project.json
ockam policy set --at support --resource inlet --expression '(= subject.permission "data")'
ockam tcp-inlet create --at /node/support --from 127.0.0.1:8000 --to /project/default/service/forward_to_blue/secure/api/service/outlet
```

```
curl --head 127.0.0.1:8000
```
