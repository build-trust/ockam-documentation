<!-- bats start ENROLLED_HOME -->
<!--
# Ockam binary to use
if [[ -z $OCKAM ]]; then
  OCKAM=ockam
fi
if [[ -z $PG_HOST ]]; then
  PG_HOST="127.0.0.1"
fi
if [[ -z $ENROLLED_HOME ]]; then
  exit 1
fi
export OCKAM_HOME=$ENROLLED_HOME
export PGPASSWORD="password"
export PGHOST="$PG_HOST"
setup() {
  load "$BATS_LIB/bats-support/load.bash"
  load "$BATS_LIB/bats-assert/load.bash"
  $OCKAM node delete --all --yes
  createdb -U postgres app_db
}
teardown() {
  $OCKAM node delete --all --yes
  dropdb -U postgres app_db
  rm -rf $ENROLLED_HOME
}

@test "run create-secure-communication-with-a-private-database-from-anywhere" {
  run $OCKAM tcp-outlet create --to "$PG_HOST:5432"
  assert_success
  run $OCKAM relay create
  assert_success

  run $OCKAM tcp-inlet create --from 7777
  assert_success
  # Call the list database -l
  run psql --host="127.0.0.1" --port=7777 -U postgres app_db -l
  assert_success
}
-->
<!-- bats end -->
# Create secure communication with a private database, from anywhere

In this example we are going to install a PostgreSQL database on our local machine
(running on port `5432`), and then create a secure communication channel (running on port
`7777`) to it from anywhere.

### Setup PostgreSQL

First let's install PostgreSQL using [`brew`](https://brew.sh/) on macOS or Linux.

{% hint style="info" %}
Please make sure to follow `brew`'s instructions on adding PostgreSQL to your path.
{% endhint %}

```bash
brew install postgresql@15
```

Then, start the PostgreSQL server process.

```bash
# Start the PostgreSQL server process
brew services start postgresql@15

# Create a database
createdb app_db
```

We can verify that the database is running on its default listening port `5432` on
localhost `127.0.0.1` using `psql`. Nothing has been secured yet but our database is
running 🎉.

```shell-session
psql --host='127.0.0.1' --port=5432 app_db
```

### Install Ockam

Install the [<mark style="color:blue;">Ockam
command</mark>](https://docs.ockam.io/#quick-start), if you haven't already, by following
the instructions below.

{% hint style="info" %}
Ockam Command is our Command Line Interface (CLI) to build and orchestrate secure
distributed applications using Ockam.
{% endhint %}

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew.

```sh
# Tap and install Ockam Command
brew install build-trust/ockam/ockam
```

This will download a precompiled binary and add it to your path. If you don’t use
Homebrew, you can also install on Linux and MacOS systems using curl. See instructions for
other systems in the next tab.
{% endtab %}

{% tab title="Other Systems" %}
On Linux and MacOS, you can download precompiled binaries for your architecture using curl.

```shell
curl --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | bash
```

This will download a precompiled binary and add it to your path. If the above instructions
don't work on your machine, please [post a
question](https://github.com/build-trust/ockam/discussions), we’d love to help.
{% endtab %}
{% endtabs %}

### Create an end-to-end encrypted relay

Next, let's step through the following commands to setup secure and private communication
between our application service and an application client. In a terminal window, run the
following command, which will:

- Check that everything was installed correctly by enrolling with Ockam Orchestrator.
- This will create a Space and Project for you in Ockam Orchestrator and provision an
  End-to-End Encrypted Relay in your `default` project at
  `/project/default`.

```bash
ockam enroll
```

#### Application service (database)

Next, let's setup a `tcp-outlet` that makes a TCP service available at the given address
`5432`. We can use this to send raw TCP traffic to the HTTP server on port `5432`. And
then let's create a relay in our default Orchestrator project.

{% hint style="info" %}
Relays make it possible to establish end-to-end protocols with services operating in a
remote private networks, without requiring a remote service to expose listening ports to
an outside hostile network like the Internet.
{% endhint %}

```bash
ockam tcp-outlet create --to 5432
ockam relay create
```

#### Application client

Let's setup a a local `tcp-inlet` to allow raw TCP traffic to be received on port `7777` before
it is forwarded.

{% hint style="info" %}
A TCP inlet is a way of defining where a node should be listening for connections, and
where it should forward that traffic to.
{% endhint %}

```bash
ockam tcp-inlet create --from 7777
```

{% hint style="info" %}
Please note that you can run the application client on a different machine than the one
that is running the application service (database). In this case, you can simply run
`ockam enroll` on the machine running the application client before running the `ockam
tcp-inlet ...` command.
{% endhint %}

#### Access the application service (database) securely

Using the following command we can now access our application service (database), that may
be in a remote private network though the end-to-end encrypted secure channel, via our own
private and encrypted cloud relay 🎉.

```
psql --host='127.0.0.1' --port=7777 app_db
```
