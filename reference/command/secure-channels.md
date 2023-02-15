# Secure Channels

```shell-session
» ockam node create n1
» ockam node create n2

» ockam secure-channel create --from /node/n1 --to /node/n2/service/api

  Created Secure Channel:
  • From: /node/n1
  •   To: /node/n2/service/api (/ip4/127.0.0.1/tcp/64114/service/api)
  •   At: /service/dc2be3083629013034c5b81479ea565e

» ockam message send hello --from /node/n1 --to /service/dc2be3083629013034c5b81479ea565e/service/uppercase
HELLO

» ockam secure-channel create --from /node/n1 --to /node/n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```
