# End-to-End Encryption

```shell
> ockam node create middle

> python3 -m http.server --bind 127.0.0.1 5000

> ockam node create blue
> ockam tcp-outlet create --at /node/blue --from /service/outlet --to 127.0.0.1:5000
> ockam forwarder create --at /node/middle --from /service/forwarder_to_blue --for /node/blue

> ockam node create green
> ockam secure-channel create --from /node/green --to /node/middle/service/forwarder_to_blue/service/api \
    | ockam tcp-inlet create --at /node/green --from 127.0.0.1:7000 --to -/service/outlet
    
> curl 127.0.0.1:7000 
```
