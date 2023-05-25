---
description: Connecting a web app and database
---

# Basic Web App

This is a demo that shows how to use Ockam sidecars to connect a traditional web app to a postgres database, with minimal/no code changes.

### Prerequisites

* [Ockam Command](../../#install)
* Python
* Postgresql

### The App

In this demo we're going to take a very basic Python Flask app that simply increments a counter in a Postgres database, and move the connection between the application and database to be through an Ockam secure channel.

#### Python Code

We've put everything into a single file here for the sake of readability for this demo:

{% code lineNumbers="true" %}
```python
import os
import psycopg2
from flask import Flask

CREATE_TABLE = (
    "CREATE TABLE IF NOT EXISTS events (id SERIAL PRIMARY KEY, name TEXT);"
)

INSERT_RETURN_ID = "INSERT INTO events (name) VALUES (%s) RETURNING id;"

app = Flask(__name__)
url = "postgres://postgres:password@localhost/"
connection = psycopg2.connect(url)

@app.route("/")
def hello_world():
    with connection:
        with connection.cursor() as cursor:
            cursor.execute(CREATE_TABLE)
            cursor.execute(INSERT_RETURN_ID, ("",))
            id = cursor.fetchone()[0]
    return "I've been visited {} times".format(id), 201
```
{% endcode %}

Lines 12 and 13 are where we establish out connection to the database, at this point it's simply pointing to localhost. If you're running a local postgres instance then starting this Flask app will now show you how many times you've visited it, storing each new visit in the database.

### Moving the database

Now we can add Ockam into the mix. To prove we're not simply using the existing communication channel we'd suggest either [changing the port that your local postgres is listening on](https://www.postgresql.org/docs/current/app-pg-ctl.html#R2-APP-PGCTL-3), or running a new postgres instance in a Docker container.

To allow the database to enroll itself as a node with Ockam we first need to generate a token for that node:

```bash
export DB_TOKEN=$(ockam project ticket --attribute component=db)
```

We've specified a custom attribute here called `component` and given it a value of `db`, which we can use later to identify this node. We've also stored the output of the command to an environment variable, though you could also copy it to your clipboard or output it to a file depending on your needs.

Next we're going to create and enroll a new Ockam node on our project, we'll add a policy that ensures only a component with the value `web` will be authorized to establish a new connection, we'll connect our node to our changed Postgres port (note the `PG_PORT` value), and finally we'll setup a forwarder that will allow traffic to this node to flow through to our TCP outlet:

```bash
export PG_PORT=5433
ockam identity create db
ockam project authenticate $DB_TOKEN --identity db
ockam node create db --identity db
ockam policy create --at db --resource tcp-outlet --expression '(= subject.component "web")'
ockam tcp-outlet create --at /node/db --from /service/outlet --to 127.0.0.1:$PG_PORT
ockam relay create db --to /node/db --at /project/default
```

### Connecting the web app

With our database node now running, we need to connect a corresponding node on the web side. We'll start by creating another enrollment token, this time for a `component` labelled `web`:

```bash
export WEB_TOKEN=$(ockam project ticket --attribute component=web)
```

Next we'll create and enroll our node, set a policy to say it is only allowed to create inlet connections to the `db` component, and then finally we create that inlet:

```bash
ockam identity create web
ockam project authenticate $WEB_TOKEN --identity web
ockam node create web --identity web
ockam policy create --at web --resource tcp-inlet --expression '(= subject.component "db")'
ockam tcp-inlet create --at /node/web --from 127.0.0.1:5432 --to /project/default/service/forward_to_db/secure/api/service/outlet
```

Take note of the `--from` and `--to` values above. The `--from` is telling the node to listen on port 5432, the default postgres port, and to forward it `--to` the forwarder service to the database that we created in the previous section. This means requests to localhost:5432 will be forwarded to whatever node has registered as `db`, wherever it is!

Which means if you start your web app the counter will continue incrementing just as it did before, with zero code changes to your application

You could also extend this example by moving the Postgres service into a Docker container or to an entirely different machine. Once the nodes are registered the demo will continue to work, with no application code changes and no need to expose the Postgres ports directly to the internet.

<!-- bats start ENROLLED_HOME -->
<!--
# Ockam binary to use
if [[ -z $OCKAM ]]; then
  OCKAM=ockam
fi

if [[ -z $BATS_LIB ]]; then
  BATS_LIB=$(brew --prefix)/lib # macos
fi

if [[ -z $ENROLLED_HOME ]]; then
  exit 1
fi

if [[ -z $PG_HOST ]]; then
  export PG_HOST='127.0.0.1'
fi

export OCKAM_HOME="$ENROLLED_HOME"
export DB_TOKEN=$(ockam project ticket --attribute component=db)
export WEB_TOKEN=$(ockam project ticket --attribute component=web)
export PG_PORT=5432
export OCKAM_PG_PORT=5433

export FLASK_PID_FILE="${ENROLLED_HOME}/python.pid"
export FLASK_SERVER="${ENROLLED_HOME}/server.py"

teardown() {
  $OCKAM node delete --all

  pid=$(cat "$FLASK_PID_FILE")
  kill -9 "$pid"
  wait "$pid" 2>/dev/null || true

  rm -rf $ENROLLED_HOME
}

setup() {
  load "$BATS_LIB/bats-support/load.bash"
  load "$BATS_LIB/bats-assert/load.bash"

  $OCKAM node delete --all

  cat > $FLASK_SERVER <<- EOM
import os
import psycopg2
from flask import Flask

CREATE_TABLE = (
  "CREATE TABLE IF NOT EXISTS events (id SERIAL PRIMARY KEY, name TEXT);"
)

INSERT_RETURN_ID = "INSERT INTO events (name) VALUES (%s) RETURNING id;"

app = Flask(__name__)
url = "postgres://postgres:password@localhost/"
connection = psycopg2.connect(port=$OCKAM_PG_PORT, database="postgres", host="localhost", user="postgres", password="password")

@app.route("/")
def hello_world():
  with connection:
    with connection.cursor() as cursor:
        cursor.execute(CREATE_TABLE)
        cursor.execute(INSERT_RETURN_ID, ("",))
        id = cursor.fetchone()[0]
  return "I've been visited {} times".format(id), 201


if __name__ == "__main__":
  app.run(port=6000)


EOM
}

start_python_server() {
  python3 $FLASK_SERVER &>/dev/null  &
  pid="$!"
  echo $pid > $FLASK_PID_FILE

  sleep 5
}

@test "test database relay" {
  run $OCKAM identity create db
  run $OCKAM project authenticate $DB_TOKEN --identity db
  run $OCKAM node create db --identity db
  run $OCKAM policy create --at db --resource tcp-outlet --expression '(= subject.component "web")'
  run $OCKAM tcp-outlet create --at /node/db --from /service/outlet --to $PG_HOST:$PG_PORT
  assert_success

  run $OCKAM relay create db --to /node/db --at /project/default
  assert_success

  run $OCKAM identity create web
  run $OCKAM project authenticate $WEB_TOKEN --identity web
  run $OCKAM node create web --identity web
  run $OCKAM policy create --at web --resource tcp-inlet --expression '(= subject.component "db")'
  run $OCKAM tcp-inlet create --at /node/web --from 127.0.0.1:$OCKAM_PG_PORT --to /project/default/service/forward_to_db/secure/api/service/outlet
  assert_success

  # Kickstart webserver
  run touch $FLASK_PID_FILE
  run start_python_server
  assert_success

  # Visit website
  run curl http://127.0.0.1:6000
  assert_output --partial "I've been visited 1 times"

  # Visit website second time
  run curl http://127.0.0.1:6000
  assert_output --partial "I've been visited 2 times"

  assert_success
}
-->
<!-- bats end -->
