# Authorization and Policies

```
ockam policy set --at influxdb --resource tcp-outlet 
    --expression '(= subject.component "telegraf")'
```
