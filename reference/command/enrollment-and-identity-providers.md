# Enrollment and Identity Providers

```
ockam enroll

ockam project information --output json > project.json

ockam project enroll --attribute city="San Francisco"
ockam project enroll --attribute city="New York"
```

Identity Providers

```
ockam project addon configure okta \
  --tenant https://trial-9434859.okta.com/oauth2/default \
  --client-id 0oa2pi8no6Kb04frP697 \
  --attribute email --attribute city --attribute department

ockam project information --output json > project.json
```
