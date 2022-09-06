# Services

```
One or more Ockam Workers can work as a team to offer a Service. Services have
addressed represented by /service/{ADDRESS}. Services can be attached to identities and
authorization policies to enforce attribute based access control rules.

Nodes created using `ockam` command usually start a pre-defined set of default services.

This includes:
    - A uppercase service at /service/uppercase
    - A secure channel listener at /service/api
    - A tcp listener listening at some TCP port
```
