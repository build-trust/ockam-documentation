# The trick behind Ockam's Magic...how Ockam works.

{% embed url="https://www.youtube.com/watch?ab_channel=Ockam&v=ufevCYmn8Do" %}

Matthew Gregory:&#x20;

Welcome to the Ockam podcast, this is going to be a fun one today. In most of our previous podcasts, we talked about the magic of Ockam. We talked about the abstractions, the user experience of Ockam, and about what you get with Ockam. In this one, we're going to show you the trick and how it all works. With me today, as usual, I have Glenn and Mrinal.

We're going to walk through how Ockam works. In previous episodes, we talked about how easy it is to use Ockam. You have two applications or an application and a database, and you want to make a secure connection between them. They're in different networks. All you have to do is install a piece of Ockam software next to the application, install a piece of Ockam software next to the database, and subscribe to Orchestrator. Magic happens, and now you have an end-to-end encrypted, mutually authenticated portal that connects your application to data.

That's it. And in fact, we've had customers say this to us before. When building Ockam into their systems, they're like, “Wait, that's it? It just works? How did that happen?”

That’s what this episode is about. Behind Portals, virtual adjacency, and networkless, let's dive into what this all means. With that, Mrinal, what do we have in this example and how are we going to walk through things here today?

Our example: connecting a remote Postgres database

Mrinal Wadhwa: We’re trying to connect things in different environments and different networks. We have to set up secure communication between them. That's our goal. To do that, Ockam provides a collection of protocols that work together to make the secure connection happen and enable end-to-end mutual trust between the two things that are talking to each other.

We're going to talk about what those protocols are and how they work together. And to do that, we'll use an example. The example we're setting up is that there are two companies, Analysis Corp and Bank Corp.

Bank Corp has a database and, Analysis Corp needs access to that database. The database is running in Bank Corp's private AWS VPC and Analysis Corp. is running in Azure, and they need to talk to this database that is at Bank Corp. This could be for several reasons, for example, Analysis Corp provides a service to Bank Corp.

So these connections need to happen. And these two networks are completely closed down. They're in different clouds, the networks are completely closed down, and we want to make the connection happen. If you look at Fig. 1, we show this end-to-end encrypted portal to Postgres.

This Postgres is sitting in Bank Corp's network, and the Postgres client is sitting in Analysis Corp’s network, and the connection happens. For the rest of this episode, we'll focus on how that green line, the end to an encrypted portal, is established and what is involved in it.&#x20;

### The stack of protocols underlying Ockam

Ockam is a stack of protocols. There is a collection of protocols inside Ockam that move end-to-end encrypted data. And the stack of protocols does two things. One, move end-to-end encrypted data, from anywhere to anywhere. And two, establish trust between all the parts that are talking to each other. Let’s take a look at the Ockam collection of protocols.&#x20;

At the bottom, we have nodes and workers. Ockam nodes are the pieces of software you run in a specific environment. This software can talk to other Ockam nodes that may be in another network. And Ockam nodes are written in a way that they can run in big massive cloud computers or they can run in tiny microcontrollers. They are independent of the runtime environment and are very efficient and can adapt to those environments. Inside an Ockam node are workers, and there can be millions of workers inside a single Ockam node. These are concurrent entities that have their own state and you can send messages to them. In response to those messages, those workers can change their state or they can respond to the messages with a reply. So that's what's going on inside a node: workers are talking to other workers. Those workers can be inside the same node, or workers can send messages to workers on other nodes in a different environment. They do this through a transport, which might be a TCP connection, a UDP connection, a web socket, etc.

And to send those messages, the protocol that's used is called Ockam Routing. And what Ockam Routing does is it sends those messages along, not just over a single transport connection, but it can do that over multiple hops of transport layer connections. What routing does is, every hop along the path of a message, it manipulates the routing information attached to the message.

There are two pieces of routing information attached to each message. One is called the onward route, the other is called the return route. And every hop, the message removes its address from the onward route and adds its address to the return route. This is a very simple protocol, every message carries these two pieces of metadata: an onward route (where is the message going) and a return route (where to send replies to that message). Every hop manipulates these two fields as the message moves through various hops. This very simple protocol allows us to set up lots of different types of topologies because it's sitting on top of the transport and node layers. Here we see an example of such a topology where three nodes are talking to each other. These three nodes may be in a different network and they might be going through a relay. We’ll talk more about that shortly. So far we've looked at what nodes are doing: running lots of concurrent workers. Workers on one node can send messages to workers on other nodes that may be many hops away, because of routing. And then on top of routing, we have a protocol called Secure Channels.

### Secure channels enable end-to-end encryption

Secure Channels are a way to set up an end-to-end encrypted, mutually authenticated connection. It's like Signal or some of these other secure communication protocols. We use very similar primitives to set up our secure channels. They're well-proven, formally verified cryptographic primitives. In a Secure Channel, the two parties involved have cryptographic keys to authenticate each other. They do a handshake to establish a shared secret, and then they use that shared secret to encrypt messages to each other. This is a very simplified view of what goes into it because we need to make sure that all of these messages are protected against someone on the wire snooping, manipulating, or recording messages. So there's a lot of cryptography that goes into making the secure channel happen and making sure it's safe. Simply put, it's a handshake between two entities to establish a shared secret so they can start encrypting messages to each other.

What's interesting about secure channels is that it is sandwiched between two layers of routing.

The benefit of that is that secure channels can be tunneled inside other secure channels. Not only can we set up end-to-end encrypted channels from anywhere to anywhere, but we can also have multiple channels involved along the path. That way, different parties along the way can authenticate each other and have guarantees against each other. This enables end-to-end guarantees between two applications.

Finally, there are Portals which we will look at more closely at the end. What portals do is take an existing protocol like a TCP client or a TCP server, Postgres in our example, and they move that data over Ockam. It could be any Ockam topology, but they do it in a way that it's transparent to the client and the server involved. So when we're moving Kafka over Ockam, the Kafka client doesn't know about Ockam. Or when we're moving TCP over Ockam, the TCP server and client don't know anything about Ockam. That's the benefit of Portals.&#x20;

### Ockam is a different approach to identities and credentials

At this point, we’ve taken an abstract look into these protocols that enable this end-to-end encrypted flow of data. That's not sufficient for end-to-end trust in the data. For that, we need a whole other set of pieces, involved. We looked at the bottom left corner of this picture where we have nodes and secure channels, which give us a foundation to start building trust.

To go all the way, we need cryptographic identities for every participant in the system, we need credentials and credentialing authorities (to make sure we can say who has what attributes), and an authority that can attest to those attributes. We need mechanisms to set up access controls where we can declare which specific entities, with what credentials are allowed to access a particular service or worker. We can build policies with attribute-based access controls on various things. This makes it easy to scale this trust infrastructure. Enrollment also makes it easy to scale this trust infrastructure, because you need a mechanism to bootstrap trust. That is a very hard problem. How do you, on the first go, trust somebody? What is the mechanism? Enrollment protocols are a way to bootstrap trust in a large fleet of applications or a distributed set of things.

Matthew Gregory: Mrinal, you said something really interesting there. There are a lot of pieces around cryptographic identifiers, vaults, access controls, policies, and enforcement. Could you describe how this is different from what we may have seen in the past? Where there's a credential authority, or where keys are generated and then distributed across the network. Can you explain how this stack of protocols in our trust layer is fundamentally different from what we have seen in the security space before?

Mrinal Wadhwa:  Our aim with trust is that every entity involved controls its own secret keys. There is no central place that gives out secrets. Right? The benefit of that is that the secrets can be kept a lot safer. If I have control of my identity key and I keep it in a KMS, no one else has that key. It's easy to guarantee that no one can authenticate as me. However, if I create a system where some central place has my keys and it gives me my keys, then an attacker that compromises the central place can pretend to be me. The problem with that is now there is this honeypot where there are keys, not just for me, but for the entire fleet of applications at a company. That target is now really attractive for attackers, and if it gets attacked or compromised, the impact or blast radius of that target is also very big. Instead, with Ockam every entity has its own secret keys. For an attacker to compromise our entire system, they would have to go to every entity and compromise every secret in our system. It becomes very hard to enter from one place and then take over an entire system. That's the benefit of this mechanism where every entity controls their own keys. However, we still have to establish trust. All these entities have their own keys, but what is their mechanism for deciding to trust another party or not?

And that's where credentials play a role. A credential is an attestation from one entity about another entity, and it's a cryptographically signed attestation. An authority might say this entity is a member of this project. The benefit of that is that other members of the project can have an access control rule, which says if this particular entity says someone is a member of this project, then allow it to access the service. So, credentials are a mechanism to scale trust in an environment where keys are now distributed and everybody has an individual cryptographic key.

### &#x20;Bootstrapping and Scaling Trust is a hard problem that Ockam has solved

Glenn Gillen: That brings up an interesting point, Mrinal. You talked about bootstrapping trust, and the attestation in particular jumped out at me. If a credential authority says to trust something, how can you trust that message? That’s where having secure connections and cryptographically provable attestations is critical. Could you delve into that? I think that's easy to miss in what you just said.

Mrinal Wadhwa: That is why enrollment protocols are a critical piece of doing this at scale. It sounds simple to establish trust between two entities and build your system from there. But the problem is, how does that first trust get established? When you try to build systems that need trust at scale, you need to define exactly what those mechanisms are. And how does trust go from one entity to two entities to 10 entities to 10,000 entities? We need a mechanism for that. And that's what enrollment protocols are. Enrollment protocols use the same building blocks, they're a mechanism to scale this infrastructure. For example, I might start by trusting a particular credentialing authority, such as Ockam Orchestrator. Once I have that trust, I could ask Ockam Orchestrator to tell me who else I should trust. If I can establish a secure channel with Ockam Orchestrator, Ockam Orchestrator can give me some policy that says, to trust anyone who belongs to the same project as you. Then I can ask, what defines who belongs to the same project, node, or system as me? That's where trust anchors are important. My anchor might be a particular credentialing authority, and if it says someone belongs to my project, then that’s my basis for deciding who belongs to my project. With these very simple steps, we're able to go from just trusting Orchestrator, to trusting a credentialing authority, to trusting anyone who is a member of the project. And now every member of the project can run an enrollment protocol with the credentialing authority to get a credential that proves they’re a member of the project. Once this has happened, each member can trust each other. So we went from trusting one thing to trusting two things to suddenly trusting 10,000 things. But we didn't create an N-squared relationship problem. Instead, we just did one-to-one exchanges and suddenly the system could scale.

Glenn Gillen: And you've done that over secure channels, which enable it to happen in a way that can’t be tampered with. Once initial trust is established, further trust can be built on top of it, and the system scales.

Mrinal Wadhwa: Precisely. You need one starting point of trust, and then you can scale from there. Secure channels can happen from anywhere to anywhere, because of Ockam routing, we're not constrained by different points of deciding trust and setting up connections. We just need one bootstrap point and we can very quickly scale to very large systems.

Matthew Gregory: Mrinal, let's go back to the original diagram from the beginning of the podcast, where we had Analysis Corp and Bank Corp. They have a Postgres database and their analysis application. And they need to make this connection between Azure and AWS. How are we going to do this with Ockam?

Mrinal Wadhwa: To make this connection happen, both sides need to set up an Ockam node and then some magic will happen. And that's what we're going to look at: what happens to make the connection? Before we can get both sides to set up these Ockam nodes, we need to do some initial setup of our own.

### Getting started: Ockam enroll

At the very beginning, an administrator downloads Ockam command on their laptop and enrolls with Ockam Orchestrator. This creates a brand new Ockam Orchestrator project. A project is another Ockam node, but it's a very large, highly scalable, managed Ockam node that provides two services.

It provides a credential authority that decides who is a member of the project, and it provides a relay service that facilitates connections across various environments. So the administrator comes in, installs Ockam command on their laptop, and runs Ockam enroll. This signs them up with Ockam Orchestrator, and then a project is provisioned for them.

This project has an authority service and a relay service, but no one is talking to these services yet. Now this administrator needs to set up nodes in these two environments. There's Bank Corp and there's Analysis Corp.

Let’s say Bank Corp set up the initial Ockam Orchestrator project. Inside their network, they can set up the first Ockam node. A simple way to do that is to run Ockam enroll again inside the machine where you want to set up the Ockam node.

Since you're the administrator, the administrator is already enrolled, you can enroll again and sign up from a different machine.

But usually, this doesn't scale. If I'm the administrator of Bank Corp, I can't go to Analysis Corp’s network and enroll as an admin. We need some other mechanism. This is where we'll see our first enrollment protocol, which we call one-time-use enrollment tokens. This is the typical mechanism of scaling deployments.

So as an admin, I run Ockam Enroll. I set up an Ockam Orchestrator project. And then I generate an enrollment token and I give it to the applications I want to provision. The Bank Corp administrator generates an enrollment token and they pass it to the provisioning node inside their network.

Similarly, the Bank Corp administrator can generate a one-time use enrollment token and give it to someone at Analysis Corp to enroll in the Ockam Orchestrator project. These tokens are one-time use and they are time-limited. We can kind of control the risk profile of these tokens.

So Bank Corp sets up their node, and let's see what's going on inside that node. The first thing that happens is a cryptographic key is generated. And a cryptographic Ockam identity is generated on that machine. The secret keys of this identity are put in a vault.

This vault could be on the file system of that node, or it could be an external KMS or an HSM. All sorts of things are supported. But this cryptographic identity is generated using the enrollment token and is then enrolled with the authority inside your Ockam Orchestrator project.

This project authority then issues a credential to the entity stating that it's a member of the Bank Corp project. All of that happens when someone enrolls with an enrollment token. Once they've enrolled, they're now a member of the project and they can use the services of the project.

### Creating the TCP Outlet & Inlet

The next thing they do is create a TCP outlet. The TCP outlet, when it receives a message, will unwrap all the Ockam routing information, take the raw TCP part of that message, and deliver it to Postgres. This outlet is like a companion to Postgres, it's sitting next to Postgres.

The outlet could be on the same machine, it could be on a machine that's a sidecar to that machine or sidecar container, or it could be in the same network. A lot of variations are possible. Regardless of the setup, the outlet will receive messages, unwrap all the routing information, and send the TCP segment to Postgres.

That's what the outlet is doing. It's given the address of the Postgres server, which is port 5432, and it's sitting there waiting for messages. The next thing we do is create a relay at the address Postgres. We talk to the relay service in our Ockam Orchestrator project, and we tell it to create a relay for us.

This is a very important step. If we had control over the network of Bank Corp, we could simply open the Postgres database port to the Internet. We could open our firewall and expose port 5432 on the Internet, and then anyone can come from the Internet and access that port.

That would be the simple way of doing this. The problem with that is now your database is on the Internet, and unless you do a lot of things to protect it, it can very easily be compromised. You get attacked and scanned, and all sorts of things will happen. The risk of compromising your data becomes very high.

Typically IT or compliance departments at Bank Corp will not allow the database port to be exposed to the internet. If you can’t expose the database to the internet, how does Analysis Corp reach it? This is where relays are helpful. When we create a relay, it creates an outgoing TCP connection to the project node in Ockam Orchestrator. Because it is an outgoing connection, and machines inside networks make outgoing connections all the time, it's allowed. They talk to the internet, they download software, they do all sorts of things. Outgoing connections are allowed in most firewalls.&#x20;

So we make an outgoing connection to the project node, and then over that outgoing TCP connection, Ockam sets up a mutually authenticated connection. The first step to do that is to decide if we trust the Ockam Orchestrator project node. We set up a mutually authenticated secure channel, which is this green part in the picture. The project presents a credential over a secure channel so that we are certain we are talking to our project.&#x20;

Inside that project is the relay service. I tell the relay service that whenever messages arrive with the address ‘Postgres’, send them back to me over the TCP connection we set up.&#x20;

So Bank Corp makes an outgoing TCP connection to the project, and it tells the relay service inside the project to send messages with the address ‘Postgres’ to the node inside Bank Corp’s network. When these messages arrive, the outlet unwraps the message and delivers the TCP segment to Postgres.&#x20;

Let's recap what's going on here. We set up a brand new node inside Bank Corp. We created an outlet from this node to Postgres. And then we created a relay to this node inside our Orchestrator project. So we've set up half of our topology, but no one is sending messages to this relay address yet, so nothing's happening. Even in this basic setup, all of these protocols were involved. We set up a node, there were workers inside the node. We set up a TCP transport connection. We use routing to set up a secure channel with our Orchestrator project. The benefit of this stack of protocols is that the route to the Orchestrator project doesn't need to be a single hop. It can be any number of topologies. You might be running multiple private subnets, and you might need to jump through multiple subnets before you reach the Orchestrator project.

Or your Bank Corp node is in a private data center, and it might first have to go through a VPC before making external connections. All of these topologies can be set up because secure channels are sitting on top of routing. Now let's see what Analysis Corp does. They get an enrollment token. This enrollment token is used to enroll with the same Orchestrator project. When enrollment is happening, we generate a cryptographic identity. We take the secret keys of that identity and store them in a vault, which could be a KMS.Then we use that identity plus the enrollment token to talk to the authority of the project. When Analysis Corp provides their identity and credentials to the authority, the authority checks that the token is valid and gives back an attestation that the entity with this specific cryptographic identity is a member of the Bank Corp Project.

The benefit of this is that Bank Corp can distribute these enrollment tokens and allow access to any number of companies to their project. In this particular case, they gave a token to Analysis Corp and Analysis Corp now can talk to services inside Bank Corp's project.

Then Analysis Corp creates a TCP inlet, which starts listening on port 15432 locally. This inlet creates a portal to the Postgres address inside the project's relay. Under the hood, this gets translated into complex routes, but on the command line you just provide the address inside the relay, and Orchestrator will figure out the rest of the route on its own.&#x20;

### Portals and Secure Channels

So, even though we wrote this very tiny command, a bunch of stuff happens. Let’s talk through what happens in layers. First, a listening TCP server is started inside that node at port 15432. This listening server is sitting there listening for raw TCP messages. It takes the raw TCP messages, wraps them in Ockam routing information, and sends them to the relay. From the relay, the message goes to the outlet of the portal on the other end. So the portal has two parts, an inlet and an outlet, and these two parts are now coming together to create the portal that we wanted to set up. The inlet is listening and will take raw TCP messages, wrap them in Ockam routing, and send them to the outlet. The outlet takes the Ockam routing messages, unwraps them, and sends the raw TCP segment to the Postgres service. That’s what the portal is doing.

In the middle is a lot of other protocol work that needs to happen to make this safe and secure. Let’s go into those layers.&#x20;

The first thing that the node inside Analysis Corp does is set up a secure channel with the Orchestrator project. Over this secure channel, it sends messages to the Postgres relay. Through this Postgres relay, it sets up a second secure channel with the node that is inside Bank Corp. Analysis Corp is actually sending data through three different secure channels in this topology.&#x20;

The first secure channel was set up by Bank Corp to the Orchestrator project. The second secure channel was set up by Analysis Corp to the Orchestrator project. And then a third, innermost secure channel was set up from Analysis Corp all the way, end-to-end, to Bank Corp.&#x20;

This means that even though the Orchestrator project is in the middle, it can't tamper with any of the data. It can't manipulate any of the data. it can't see any of the data, it can't spoof authentication. The project is just an encrypted relay in the middle, it’s like a handover. However because both sides made outgoing TCP connections, they were able to connect to the relay and then use the relay as a mechanism to deliver messages to each other.

And they did it over an end-to-end encrypted, mutually authenticated secure channel. Hence the relay cannot tamper anything, and anyone on the Internet cannot tamper anything. Plus, the Postgres server is not exposed to the Internet. We now have an end-to-end encrypted portal that has an inlet inside AnalysisCorp and an outlet inside BankCorp. Now we can send Postgres requests through this portal. This Postgres request starts as a raw Postgres query, over TCP. It reaches the inlet and gets turned into an Ockam routing message. This Ockam routing message gets end-to-end encrypted for Bank Corp. It gets sent down this innermost channel, it goes over to the relay, the relay then delivers the message to Bank Corp, the secure channel responder there unencrypts the message, it then delivers the message to the outlet, the outlet removes all Ockam routing information, and a raw TCP segment then gets delivered to Postgres. If Postgres replies, the reply takes the same path back and it turns into raw TCP that's delivered to the Postgres client. So that's what an end-to-end encrypted portal is doing. There are a couple of things to highlight here.

Portals can take any existing protocol and carry it over Ockam. Ockam brings an array of formally proven guarantees: end-to-end encryption, mutual authentication, forward secrecy, protection from tampering, protection from key compromise and impersonation. This means your existing applications can get all of these guarantees by starting a piece of Ockam software next to your server and another little piece of software next to your client.

And it works transparently. You don't have to change any of your code, you may just have to change the port number and address your application is talking to. That's what the portal is giving us.&#x20;

### Why Ockam is a step function improvement over current solutions

Glenn Gillen: I look at this picture and think about all the customer conversations I have, where they might say, “We already have end-to-end encryption, we’re using TLS everywhere.” How is this different? With TLS, if you draw this picture the Orchestrator relay might be a load balancer. The client talks to the load balancer, which does TLS on the backhaul. This is different though, right?&#x20;

Mrinal Wadhwa: Yeah. Relays are kind of like load balancers. You could argue that because someone has TLS, they have end-to-end encryption. What that misses, is that using TLS with a load balancer in the middle is like using one of the Ockam secure channels, the light green one in our diagram. Remember, we have three secure channels involved. One from Analysis Corp to the project, one from Bank Corp to the project. Then a third one, which is end-to-end from Analysis Corp all the way to Bank Corp. And in TLS, if you do all the hard work, you only get the first two. Typically, people only get one. They'll expose TLS to the internet, then they’ll do the hard work of setting up certificate authorities, and make sure that the load balancer TLS server is serving TLS over the internet. And clients connect to it over TLS.

But it's usually not mutual TLS, it's one-way TLS where the server is being authenticated using TLS, but the client is being authenticated using some other mechanism, like an OAuth token. And then behind the load balancer, I've seen topologies where people do nothing.

They let the data move unencrypted, or they'll set up a second TLS connection, from the load balancer to wherever their machine is. Never is there this third, end-to-end encrypted secure channel, the innermost dark green secure channel. This means that if an attacker is able to compromise the internet-facing load-balancing server, they're able to see all the data unencrypted. If you've only set up one of the secure channels, and the attacker is anywhere inside your parameter, they're able to compromise the data or steal it.

In Ockam’s case, we've set up this end-to-end channel that only the two machines that are involved have the keys for and nothing in the middle can compromise it. This is a risk profile decision to make. If you go with that TLS setup, you have orders of magnitude more risk in the ways things can get compromised. And the blast radius is also very big. If a compromise happens, all sorts of applications get compromised. With Ockam, if every application is making an end-to-end connection with another application, and one is compromised, the attacker can only access that one application. Even compromising one is very hard because you have to precisely reach a specific place in the network to get the keys. And if those keys are in a KMS, that's hard to reach.

Glenn Gillen:  The thing that you implied there is that if two companies are talking to each other, and you are using a load balancer in the middle with TLS, you only have a guarantee from Postgres to the load balancer. You have no idea what happens after that. You see this a lot with how CDNs are deployed to move TLS termination closer to their customers. That’s because there is some implicit trust that everything behind the first connection is hopefully secure. Compare that to our protocols, which are open source and have been independently tested, and provide guarantees that your data is encrypted from its source all the way to its destination.

Mrinal Wadhwa: That's precisely right. Another thing that comes up with TLS is that Analysis Corp now needs an OAuth token to get in. And the distribution of that OAuth token can get very complex. Oftentimes people will take an API token and give it to one company, and that one company then may use the token across lots of different clients, and the token may be provided over email.&#x20;

There are a lot of risks involved in how those tokens are delivered. It’s doable if you have one or two clients, but if you have 10,000 clients it becomes difficult. How do you get the token to all the clients? How do you make sure all the clients have a unique token? If you give the same token to 10,000 clients, and one of the clients is compromised, then all of the tokens are compromised.&#x20;

That’s why Ockam’s enrollment protocol mechanism provides a low-risk, one-time-use enrollment token that is thrown away the moment things are enrolled.  Then we take the token and turn it into cryptographic credentials, and those cryptographic credentials are not bearer secrets anymore. They are much easier to manage because you don't have to keep them safe. They can only be used by someone who has the private keys of a particular identity.

To wrap up, we created this very simple green line to make this connection happen. But what we saw was, under the hood, there are a lot of pieces that worked together to make it happen in a way that is secure, safe, and works in any topology.

### Ockam’s building blocks are extensible

Another interesting point about these pieces is that they are all reusable building blocks. Ockam isn't a solution to this one specific scenario. It is a set of reusable building blocks that come together to set up secure communication in all sorts of different scenarios. In this particular case, we were making a TCP server and a TCP client, and two different private networks talk to each other.

But in a completely different scenario, we make a Kafka producer and a Kafka consumer talk to each other in a way that is end-to-end encrypted and mutually authenticated. The same building blocks make that happen as well. The same building blocks can enable end-to-end trust in highly distributed systems, such as IoT devices.

So these are reusable building blocks. And if you use our programming libraries, you can customize them to whatever your use case is. Typically, we encounter people who need TCP or Kafka connections. We made those typical scenarios very easy to use in our command line.

Glenn Gillen: To bring it full circle, our job is to make these things simple and easy to use. That's why Ockam exists. This conversation started because we were talking through the TCP example with a customer, who noted how quick and easy this is to set up. They wondered what happened behind the scenes, but they didn’t need to know to get started.

Everything we’ve talked about in this episode, you don’t actually have to know to use Ockam. That’s the point. If you want to get into the weeds, then this is the episode for you. This is the trick behind Ockam, how our magic works. Our protocols are described in detail in our documentation, and our code is open source. Anyone can build this, we’ve just made it easy to use.

Mrinal Wadhwa: In this scenario, Bank Corp probably typed 3 commands and Analysis Corp typed 2 commands. And it just worked.

Matthew Gregory: That is our ethos, to make things simple. Our mission is to make it so that every developer can create these secure connections between their applications and their data. They don't have to be network experts. They don't have to be security experts. That's why we say Ockam is networkless.&#x20;

If security experts and network experts are the barrier by which we are going to move all of our data around the internet, between companies, and across networks, then we are doomed. keep all the data. We built Ockam to enable any developer with very basic engineering skills to be able to move data securely the right way and make it very hard to do the wrong thing.

So this podcast was focused on what happens under the hood. If you got to the end of this and said, “Oh gosh, that seems like a lot.” It was a lot. It took us four years and millions of dollars to build this thing so that you don't have to. If you want to try to build this yourself, our protocols are published on our doc site, have at it, and good luck.

But that's the good part. You don't have to build any of this yourself. We've already done it and we've distilled everything down to very simple, easy-to-understand primitives that anyone can use. And that's the magic of Ockam.

\
