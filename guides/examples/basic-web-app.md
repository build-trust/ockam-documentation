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

Now we can add Ockam into the mix. To prove we're not simply using the existing communication change we'd suggest either [changing the port that your local postgres is listening on](https://www.postgresql.org/docs/current/app-pg-ctl.html#R2-APP-PGCTL-3), or running a new postgres instance in a Docker container.

Next we're going to output our Ockam project information to a JSON file so that we can load it into future commands more easily:

```bash
ockam project information --output=json > project.json
```

To allow the database to enroll itself as a node with Ockam we first need to generate a token for that node:

```
export DB_TOKEN=$(ockam project enroll --attribute component=db)
```

We've specified a custom attribute here called `component` and given it a value of `db`, which we can use later to identify this node. We've also stored the output of the command to an environment variable, though you could also copy it to your clipboard or output it to a file depending on your needs.

Next we're going to create and enroll a new Ockam node on our project, we'll add a policy that ensures only a component with the value `web` will be authorized to establish a new connection, we'll connect our node to our changed Postgres port (note the `PG_PORT` value), and finally we'll setup a forwarder that will allow traffic to this node to flow through to our TCP outlet:

```bash
export PG_PORT=5433
ockam identity create db
ockam project authenticate --identity db --token $DB_TOKEN --project-path project.json
ockam node create db --project project.json --identity db
ockam policy set --at db --resource tcp-outlet --expression '(= subject.component "web")'
ockam tcp-outlet create --at /node/db --from /service/outlet --to 127.0.0.1:$PG_PORT
ockam forwarder create db --to /node/db --at /project/default
```

### Connecting the web app

With our database node now running, we need to connect a corresponding node on the web side. We'll start by creating another enrollment token, this time for a `component` labelled `web`:

```bash
export WEB_TOKEN=$(ockam project enroll --attribute component=web)
```

Next we'll create and enroll our node, set a policy to say it is only allowed to create inlet connections to the `db` component, and then finally we create that inlet:

<pre class="language-bash"><code class="lang-bash">ockam identity create web
ockam project authenticate --identity web --token $WEB_TOKEN --project-path project.json
<strong>ockam node create web --project project.json --identity web
</strong>ockam policy set --at web --resource tcp-inlet --expression '(= subject.component "db")'
ockam tcp-inlet create --at /node/web --from 127.0.0.1:5432 --to /project/default/service/forward_to_db/secure/api/service/outlet
</code></pre>

Take note of the `--from` and `--to` values above. The `--from` is telling the node to listen on port 5432, the default postgres port, and to forward it `--to` the forwarder service to the database that we created in the previous section. This means requests to localhost:5432 will be forwarded to whatever node has registered as `db`, wherever it is!

Which means if you start your web app the counter will continue incrementing just as it did before, with zero code changes to your application

You could also extend this example by moving the Postgres service into a Docker container or to an entirely different machine. Once the nodes are registered the demo will continue to work, with no application code changes and no need to expose the Postgres ports directly to the internet.

