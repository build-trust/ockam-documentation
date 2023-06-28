---
description: Connecting a web app and database
---

# Basic Web App

This is a demo that shows how you can use Ockam [<mark style="color:blue;">sidecars</mark>](https://learn.microsoft.com/en-us/azure/architecture/patterns/sidecar) to connect a traditional web app to a Postgres database, with minimal/no code changes.

In order to follow along, please make sure to install all the prerequisites on the machine
where you plan on carrying out the steps below.

### Prerequisites

* [<mark style="color:blue;">Ockam Command</mark>](../../#install)
  * After successfully installing this prerequisite, you will be able to run the `ockam` CLI app in your terminal.
* [<mark style="color:blue;">Python</mark>](https://www.python.org/downloads/), and libraries: [<mark style="color:blue;">Flash</mark>](https://github.com/pallets/flask/), [<mark style="color:blue;">psycopg2</mark>](https://github.com/psycopg/psycopg2)
  1. After successfully installing Python, you will be able to run the `python3` command in your terminal.
  2. Instructions on how to get the dependencies (`Flask`, `psycopg2`) are provided in the [<mark style="color:blue;">Python Code</mark>](basic-web-app.md#python-code) section below.
* [<mark style="color:blue;">Postgresql</mark>](https://www.postgresql.org/)
  1. After successfully installing this prerequisite, you will be able to run the Postgres database server on your machine on the default port of `5432`.
  2. Make sure to set a new password for the database user `postgres`. Set this password to be `password` (the Python Code below uses `postgres:password@localhost` as the connection string for the db driver). The following directions can help you set this up on Linux or macOS:
     * In a terminal, login to the database locally as the `postgres` user: `sudo -u postgres psql --username postgres --password --dbname template1`
     * Then type the following in the REPL: `ALTER USER postgres PASSWORD 'password';`, and finally type `exit`.
     * You can learn more about this [<mark style="color:blue;">here</mark>](https://stackoverflow.com/a/12721095/2085356).

### The Web App

In this demo we're going to take a very basic Python Flask app that simply increments a counter in a Postgres database, and move the connection between the application and database to be through an Ockam secure channel.

Before we get started, let's imagine a company where this will be rolled out, where we find 3 team members who will be involved in this journey:

* 🧑‍🦲 Toby is the admin for all the Ockam "things".
  * They are responsible for installing the Ockam application and creating an Ockam project using `ockam enroll`; this is the first prerequisite.
  * Toby then generates two [<mark style="color:blue;">one-time enrollment tickets</mark>](https://command.ockam.io/manual/ockam-project-ticket.html) and shares them w/ the rest of the team:
    1. One for the web app,
    2. Another for the database server.
* 🧑‍🦱 Akira is the database admin.
  * They use their one-time enrollment ticket to perform some configuration steps and
    set up an [<mark style="color:blue;">"outlet"</mark>](https://docs.ockam.io/reference/command/advanced-routing)
    to the database server.
  * We will learn more about this in the [<mark style="color:blue;">"Connecting the database"</mark>](basic-web-app.md#connecting-the-database) section below.
* 🧑‍🦳 Zora is the web app (Python Flask) developer.
  * They use their one-time enrollment ticket to perform some configuration steps and set
    up an [<mark style="color:blue;">"inlet"</mark>](https://docs.ockam.io/reference/command/advanced-routing)
    from the python app.
  * We will learn more about this in the [<mark style="color:blue;">"Connecting the web app"</mark>](basic-web-app.md#connecting-the-web-app)
    section below.

<img src="../../.gitbook/assets/file.excalidraw (2).svg" alt="" class="gitbook-drawing">

In the rest of the instructions we will walk you through which of the team members will
perform these steps. But as you follow along, you can do them all yourself 😃. The story
and these people and roles are just to help in understanding the context around what is
happening as we go through the steps.

#### Python Code

To get started, we've put everything into a single file (called `main.py`) here for the sake of readability for this demo:

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
pg_port = "5432" # 5432 is the default port
url = "postgres://postgres:password@localhost:%s/"%pg_port
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

Lines 12 to 14 are where we establish out connection to the database, at this point it's simply pointing to `localhost` on port `5432`. If you're running a local Postgres instance then starting this Flask app will now show you how many times you've visited it, storing each new visit in the database.

{% hint style="info" %}
Make a note of the `pg_port` variable. In production the port is typically loaded from an environment variable and not hardcoded into the source. But for this exercise we are setting the value in the script itself. We will change this value in the next steps when we bring Ockam into the mix.
{% endhint %}

Before doing any Ockam related tasks, feel free to run the Python script now by following the instructions below:

1. You also need to add following Python dependencies by running:
   * `Flask`: `pip3 install flask`
   * `psycopg2`: `pip3 install psycopg2-binary`
2. To run this `Flask` app (`main.py`) type:
   * `flask --app main run`
3. To see it running in a web browser open this URL: `http://127.0.0.1:5000/`

### Connecting the database

We are going to leave the database running on the default port and then we will:
1. Add Ockam to the mix.
2. Update our `main.py` file so that it connects to a new port and not the default one of
   `5432` where the Postgres database server is running.

> In our story about our imaginary company and team of three, Toby (Ockam admin) would
> perform the following steps. Toby would generate this
> [<mark style="color:blue;">one-time enrollment ticket</mark>](https://command.ockam.io/manual/ockam-project-ticket.html)
> (just plain text) and send that over to Akira. You can simply follow these steps on your
> machine.

{% hint style="info" %}
Before starting with the steps below, please read
[<mark style="color:blue;">this article</mark>](https://docs.ockam.io/guides/use-casesadd-end-to-end-encryption-to-any-client-and-server-application-with-no-code-change)
to get familiar with what steps we are going to take to configure Ockam. They will give
you a sense of things like "node", "inlet", "outlet", and "relay" that you will see
mentioned below.
{% endhint %}

To allow the database to enroll itself as a node with Ockam we first need to generate a
one-time enrollment ticket for that node:

```bash
export DB_TOKEN=$(ockam project ticket --attribute component=db)
```

We have:
1. Specified a custom attribute here called `component` and given it a value of `db`,
   which we can use later to work with the `web` node.
2. Stored the output of the command to an environment variable `DB_TOKEN`, though you
   could also copy it to your clipboard or output it to a file depending on your needs.

{% hint style="info" %}
Here is a mode detailed look at what happens when we run `ockam project ticket --attribute component=db`:

* We create a credential which will be associated to the identity using the one-time
  ticket when connecting for the first time to the Orchestrator.
* Then this credential can be presented by the database to the client so that the client
  can reject an identity wanting to establish a secure channel without that attribute.
* `"db"` does not identify the `db` node. The `db` node has an Identity and credentials
  with authenticated attributes can be associated to that identity.
{% endhint %}

Here's a diagram describing what we will do next. Note how the database connection string
used by the Python Flask app connects to port `5433` and Ockam "magically" secures &
relays the connection to port `5432` where Postgres is running, all without writing any
code 🎉.

<img src="../../.gitbook/assets/file.excalidraw (1).svg" alt="" class="gitbook-drawing">

> In our story about our imaginary company and team of three, Akira (database admin) would
> perform the following steps. Akira would use the one-time enrollment ticket data (plain
> text) to create a node called 'db' and create a
> [<mark style="color:blue;">relay</mark>](https://docs.ockam.io/reference/command/advanced-routing)
> and a [<mark style="color:blue;">tcp-outlet</mark>](https://command.ockam.io/manual/ockam-tcp-outlet.html).
> You can simply follow these steps on your machine.

In the code snippet below, we're going to:

1. Create and enroll a new Ockam [<mark style="color:blue;">node</mark>](https://docs.ockam.io/reference/command/nodes) on our
   project.
2. Then add a [<mark style="color:blue;">policy</mark>](https://command.ockam.io/manual/ockam-policy.html)
   that ensures only a component with the value `web` will be authorized to establish a
   new connection. This policy can be associated to several resources on the node.
3. Connect our node to our default Postgres port (note the `PG_PORT` value).
4. Finally setup a relay (we will use the End-to-End Encrypted Cloud Relay service,
   which was provisioned when `ockam enroll` was run, in the
   `default` project at `/project/default`) that will allow traffic to this node to flow through to our TCP outlet.

```bash
export PG_PORT=5432
ockam identity create db
ockam project enroll $DB_TOKEN --identity db
ockam node create db --identity db
ockam policy create --at db --resource tcp-outlet --expression '(= subject.component "web")'
ockam tcp-outlet create --at /node/db --from /service/outlet --to 127.0.0.1:$PG_PORT
ockam relay create db --to /node/db --at /project/default
```

### Connecting the web app

> In our story about our imaginary company and team of three, Toby (database admin) would
> perform the following steps. Toby would generate this one-time enrollment ticket (just
> plain text) and then send that over to Zora. You can simply follow these steps on your
> machine.

With our database node now running, we need to connect a corresponding node on the web
side. Let's start by creating another enrollment token, this time for a `component`
labelled `web`:

```bash
export WEB_TOKEN=$(ockam project ticket --attribute component=web)
```

> In our story about our imaginary company and team of three, Zora (web app developer)
> would perform the following steps. They would use the one-time enrollment ticket data
> (plain text) to create a node
> called 'web' and create a [<mark style="color:blue;">tcp-inlet</mark>](https://command.ockam.io/manual/ockam-tcp-inlet.html).
> You can simply follow these steps on your machine.

Next let's create and enroll our node, set a policy to say it is only allowed to create
inlet connections to the `db` component, and then finally we create that inlet:

```bash
export OCKAM_PORT=5433
ockam identity create web
ockam project enroll $WEB_TOKEN --identity web
ockam node create web --identity web
ockam policy create --at web --resource tcp-inlet --expression '(= subject.component "db")'
ockam tcp-inlet create --at /node/web --from 127.0.0.1:$OCKAM_PORT --to /project/default/service/forward_to_db/secure/api/service/outlet
```

Please take note of the `--from` and `--to` values above.

* The `--from` tells the node to listen on port `$OCKAM_PORT` (`5433`).
* And to forward it `--to` the relay service to the database that we created in the previous section.
* This means requests to `localhost:5433` will be forwarded to whatever node has registered as `db`, wherever it is!

One more change needs to be made to `main.py`. We have to update it to use the new `$OCKAM_PORT` inlet (line 12).

{% hint style="info" %}
In production environments you would typically get this from an environment variable which
wouldn't require code changes. You would have to change the machine configuration running
the web app to have the new value of `$OCKAM_PORT`. However, in this example we will just
update line 12 in the `main.py` itself to store the new value.
{% endhint %}

```py
import os
import psycopg2
from flask import Flask

CREATE_TABLE = (
    "CREATE TABLE IF NOT EXISTS events (id SERIAL PRIMARY KEY, name TEXT);"
)

INSERT_RETURN_ID = "INSERT INTO events (name) VALUES (%s) RETURNING id;"

app = Flask(__name__)
pg_port = "5433" # 5433 is the $OCKAM_PORT inlet
url = "postgres://postgres:password@localhost:%s/"%pg_port
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

Now when you start your web app (using `flask --app main run`) the counter will continue
incrementing just as it did before, with zero code changes to your application.

You could also extend this example by moving the Postgres service into a Docker container
or to an entirely different machine. Once the nodes are registered the demo will continue
to work, with no application code changes and no need to expose the Postgres ports
directly to the internet.

### Other commands to explore

Now that you've completed this example, here are some commands for you to try and see what
they do. You can always look up the details on what they do in the
[<mark style="color:blue;">manual</mark>](https://command.ockam.io/manual/).
As you try each of these, please keep an eye out for things you may have created in this
exercise.

* Try `ockam node list`. Do you see the nodes that you created in this exercise?
* Try `ockam node --help`. These are shorter examples for you to get familiar with commands.
* Try `ockam node show web`. Do you see the `tcp-inlet` that you created in this exercise?
* Try `ockam node show db`. Do you see the `tcp-outlet` that you created in this exercise?
* Try `ockam identity list`. Do you see the identities you created in this exercise?
