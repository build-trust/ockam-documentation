# Create secure communication with a private database, from anywhere

### Setup PostgreSQL

Install PostgreSQL:

```bash
brew install postgresql
```

Start the PostgreSQL server process

```bash
# Start the PostgreSQL server process
postgres -D /opt/homebrew/var/postgresql@14

# Create a database
createdb app_db
```

Connect to the database on its default listening port `5432` on localhost `127.0.0.1`

```shell-session
psql --host='127.0.0.1' --port=5432 app_db
```

### Install Ockam

Install the Ockam command, if you haven't already.

```bash
brew install build-trust/ockam/ockam
```

If you're on linux, see how to install [precompiled binaries](../manuals/command/ockam-open-source.md#precompiled-binaries).

### Create an end-to-end encrypted relay

Create an end-to-end encrypted relay

```
ockam node create relay
```

### Create a database sidecar

```bash
ockam node create db_sidecar

ockam tcp-outlet create --at /node/db_sidecar --from /service/outlet --to 127.0.0.1:5432

ockam forwarder create db_sidecar --at /node/relay --to /node/db_sidecar
```

### Create a client sidecar

```bash
ockam node create client_sidecar

ockam secure-channel create --from /node/client_sidecar --to /node/relay/service/forward_to_db_sidecar/service/api \
  | ockam tcp-inlet create --at /node/client_sidecar --from 127.0.0.1:7777 --to -/service/outlet
```

### Connect to the application database

```
psql --host='127.0.0.1' --port=7777 app_db
```
