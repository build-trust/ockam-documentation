# Use employee attributes from Okta to scale just-enough, least-privilege application access

<figure><img src="../.gitbook/assets/diagrams.003.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

### Administrator

```bash
ockam enroll
ockam project addon configure okta \
  --tenant https://trial-9434859.okta.com/oauth2/default --client-id 0oa2pi8no6Kb04frP697 \
  --attribute email --attribute location --attribute department
```

```
ockam project information --output json > project.json

m1_token=$(ockam project enroll --attribute application="Smart Factory")
m2_token=$(ockam project enroll --attribute application="Smart Factory")
```

### Machine 1 in New York

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create m1 --project project.json --enrollment-token $m1_token
ockam policy set --at m1 --resource outlet --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.location "New York"))'
ockam tcp-outlet create --at /node/m1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create blue --at /project/default --to /node/m1
```

### Machine 2 in San Francisco

```
python3 -m http.server --bind 127.0.0.1 6000
```

```bash
ockam node create m2 --project project.json --enrollment-token $m2_token
ockam policy set --at m2 --resource outlet --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.location "San Francisco"))'
ockam tcp-outlet create --at /node/m2 --from /service/outlet --to 127.0.0.1:6000
ockam forwarder create m2 --at /project/default --to /node/m2
```

### Support Engineer

```bash
ockam node create support --project project.json
ockam project authenticate --project project.json
ockam policy set --at support --resource inlet --expression '(= subject.application "Smart Factory")'
```

```
ockam tcp-inlet create --at /node/support --from 127.0.0.1:8000 --to /project/default/service/forward_to_m1/secure/api/service/outlet
curl --head 127.0.0.1:8000
```

```
ockam tcp-inlet create --at /node/support --from 127.0.0.1:8000 --to /project/default/service/forward_to_m2/secure/api/service/outlet
curl --head 127.0.0.1:8000
```
