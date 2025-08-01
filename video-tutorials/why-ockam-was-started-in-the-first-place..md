# Why Ockam was started in the first place.

\


{% embed url="https://www.youtube.com/watch?ab_channel=Ockam&t=1s&v=FUT-hqt7GMk" %}

**Transcript**

Matthew Gregory: Welcome to the Ockam podcast. Every week, Mrinal, Glenn, and I will get together to discuss technology, building products, security by design, how Ockam works, and a lot more. We'll also comment on industry macros from across cloud, open source, and security. We also plan on bringing guests to add some perspective and challenge some of the dogmas that we or others might have.

Today we'll spend some time allowing you to get to know us, where we come from, and what motivates us to build Ockam: the company, the product, the team. And with that, Mrinal could you start us off with what you've been up to in your professional career and what led you to what we're doing here at Ockam?

### The challenge in building Trustful systems <a href="#the-challenge-in-building-trustful-systems" id="the-challenge-in-building-trustful-systems"></a>

Mrinal Wadhwa:

Sure. Thanks, Matt. My name's Mrinal, I am CTO at Ockam and my background has been in distributed systems. I started my career working on large-scale data problems with tools like Erlang, Hadoop, etc. dealing with large amounts of streaming data. And then about 10 years ago I took on a role as CTO of a hardware business, which was strange because I had no hardware background.

It was interesting because it was a great team that wanted to turn the hardware they'd been building into a set of products of connected systems for city infrastructure. And so it's essentially IoT that was installed inside cities, airports, factories, and things like that.

And in designing that very large distributed system, we thought a lot about how we could trust the information that was flowing through that system. How do we trust a sensor sitting in a city street telling us something? Or how do we securely deliver a software update to a device installed inside a factory?

Because this was 2013/14, there weren't other systems like this that had done this at scale. There were no off-the-shelf IoT platforms you could buy from anyone. So, we were thinking about a lot of problems from scratch with no reference point.

We thought about the security and trust problem extensively. That led us to design protocols in that system to do authentication of devices, authentication of the update infrastructure, secure delivery of software updates, secure delivery of the data that was coming in from the sensors, and trustful control of things that are distributed out in the world.

A few years later, as IoT became more prevalent in the world, I noticed that a lot of people were struggling with the security problems around IoT. What I realized was that because of the type of product we were building and the type of customers we were going after, we had invested the time and energy to secure our infrastructure, which meant building a lot of stuff from scratch. And it took us a few years to get it to a secure point. However, for everyone else in the IoT market, that wasn't their core focus. They were trying to solve other problems and did not focus on security.

And what ended up happening is that IoT targets became more attractive to attack. A lot of people attacked it. I remember in 2016/17 there was this big Marai botnet incident, which brought attention to this set of problems. So my realization was, that as systems become more and more distributed, the problem of trust, security, and reliable communication becomes harder and harder.

You have to think about managing keys at scale, you have to set up secure protocols that traverse various types of networks, et cetera. And building all of that takes a lot of time, expertise, and money, which not everybody could invest. And so I started thinking about something that should exist off the shelf to solve that set of problems.

And that led me to meet Matt around 2018. In our very first conversation, what we connected on was the idea that the problems I was thinking about in IoT are more general because all systems are becoming more and more distributed. As that happens, you have to do cross-cloud communication, cross-company communication, cross-network communication, and all of those scenarios. Trust, security, and identity are hard problems. So we both resonated on this idea that a set of tools should exist that make all of this simple for anyone building a distributed system. So that's been my journey.

### The evolution of cloud architectures led us to build Ockam <a href="#the-evolution-of-cloud-architectures-led-us-to-build-ockam" id="the-evolution-of-cloud-architectures-led-us-to-build-ockam"></a>

Matthew Gregory: The first meeting we had was a meeting of the minds. We came to this conclusion, it was immediate. It's funny how people could be thinking of the same problems in parallel and come to similar conclusions.

So my background, in the 2000s I was doing IoT-like things, but the term hadn't been created at that point in time. I was building real-time data analytics systems for America's Cup teams, recording what was going on in sailboats, very similar to what happens in Formula One.

If anyone watches the Netflix show on Formula One, you'll see a lot of this in action. It was the same thing in sailing. Then in the late 2000s, I moved from a builder of systems to more of a tool maker. I worked with Weather Underground to build an API for any software developer that needs to access weather data.

If you've seen weather on your phone, it probably came from the Weather Underground API that we built right around the time that the iPhone and App Store came out. A lot of people needed weather data for their apps. Then I met Glenn at Heroku on my next hop on the journey.

And this was very early in the cloud era. I was at one of the very first AWS Re:Invents. Heroku is a massive AWS customer. We provided that abstraction that made it easy for the full-stack developer to merge and deploy things to the cloud.

I went from there to Microsoft, right after Satya took over. He put together a red team to figure out how to pivot Microsoft from a platform as a service to infrastructure as a service that could run anything. And obviously, Microsoft loves Linux. A lot of that came out of the work that our team did.

Through what I saw during that cloud era, there was this trend. In the Heroku days, there was a slider bar on the website, and the more you slid it to the right, the more cloud you got. And you could just keep scaling your app until infinity.

At the time, people were building these Ruby Rail apps. As it turns out, you can't scale an app with the cloud to infinity; it will break. For the people that were around at the time, this was the era of the Twitter fail whale. There were all sorts of apps breaking, particularly as mobile apps were coming online and all the backend systems that were supporting them.

So we entered this cloud era where monolithic applications needed a solution. And the solution to that when I was at Microsoft was partnerships with companies like Docker and Mesosphere. You take a monolithic application, divide it up into little pieces, call them containers, and then we can orchestrate how many underlying resources we give all these little microservices or containers underneath it.

So you need an orchestration layer, like Mesosphere, Zookeeper, and Kubernetes. You do infrastructure as code with things like Terraform. There was an entire class of orchestration tools for managing infrastructure so that you could run thousands of applications and scale them up and down as you needed.

The cool thing about being at Microsoft at that time was that we got to see all these use cases where people were running things on-prem, and also in clouds like Azure and AWS, and consuming services from other third-party data service companies. So it wasn't just that the monoliths were being chopped up into little pieces, but they were also being distributed all over planet Earth.

If you then extend this to what problem next needs to be solved, it is "How are we going to create trust and interoperability between all these different applications?" Because you still have a job to be done. And so that concept of a monolith still exists, but you don't have the reality of it all running in the same box or the same cloud or in the same environment.

How are we going to get interoperability, have trust between applications, and move data between them in a trustful way, so that we can have these massive-scale enterprise applications that are distributed all around the world? And as I said, I met Glenn over 10 years ago now when we were working together at Heroku, and that's where we met. I've mentioned HashiCorp where you spent some time, why don't you give us the background about what brings you to Ockam?

### Lessons from Heroku, AWS, and Hashicorp <a href="#lessons-from-heroku-aws-and-hashicorp" id="lessons-from-heroku-aws-and-hashicorp"></a>

Glenn Gillen: I started as a developer, doing dotnet, Ruby, PHP, a whole bunch of stuff. But ultimately I think the interesting part of that story is ending up at Heroku, which is more than 15 years ago at this point.

I think people who weren't around at the time underestimated the impact it had on so many things. Git-based deployments of code were something they pioneered. Docker wasn't around then. Containerization and deployment of apps to containers at scale was a thing that Heroku helped bring to the masses.

So Matt and I worked on the add-ons marketplace there, which is the way to connect other things. All the bits that aren't Heroku that you plug into: databases, logging services, caching providers, etc. The things that you can't run yourself on Heroku, that's what the add-ons marketplace did. We spent years there building out a great user experience to make it easy to connect to other things.

After Heroku, I went to AWS for a little while. I was helping companies that were at the forefront of trying to adopt the cloud, especially startups, people that were pushing the envelope. I was helping them be successful on AWS. My experience there was that AWS is great at a lot of things, they built an incredible product. But they don't provide a great developer experience. On top of that, you've got access to all these tools. But you're left to do a lot of the plumbing yourself. Especially coming from Heroku, which focused on providing a great abstraction, that friction was felt deeply day to day. I was getting a bit frustrated with it and couldn't work out how to fix that at a company the size and scale of AWS.

How can you fix that? Terraform seemed like the best place to do it. They had a much better UX than AWS and had better coverage in cloud formation at the time if you wanted to do infrastructure as code. So I managed to get myself a job at HashiCorp, working on Terraform and ultimately was Product Lead for Terraform.

We did pretty well with that, but good things come to an end. And after the IPO I started looking around for what might come next, and that's when I reached out to Matt to see what he was up to. It wasn't meant to be a job conversation. But it just evolved.

When I looked at what you were doing here at Ockam, and compared it to my journey, the consistent thing was that we kept making incremental improvements to the way we connect things. We had a set of tools, we'd make them slightly better and we'd still have the same problems. If Ockam existed when we launched Terraform Cloud, we could have saved over six months of development.

We built our own smaller, more focused, less functional version of Ockam to help connect Terraform Cloud to on-prem things. And that was the other thing I learned from my time at Hashicorp, the world's not as simple as it was back when we started Heroku.

You're not just deploying everything to AWS, there are heterogeneous deployments in terms of multi-cloud or hybrid approaches. You've at least got a data center on-prem still that you're trying to talk to, and it's just messy. And we're still trying to patch this in hacky ways. Or in HashiCorp's case, investing half a year trying to build a solution to fix what should be simple. We're just trying to connect two things securely. I thought, oh, this is where I should be spending my time. This is the next thing to go and improve. So that's ultimately how I ended up here.

Matthew Gregory: Glenn's been with us for a little over a year and it's just been awesome to get the band back together. It begs the question, what is Ockam?

Mrinal, when people say, "I've heard of Ockam, but tell me more about it.". What do you tell them?

### What is Ockam? For the technical <a href="#what-is-ockam-for-the-technical" id="what-is-ockam-for-the-technical"></a>

Mrinal Wadhwa: I'll take two different approaches, from the top down and from the bottom up. I'll attempt the top-down answer first and we can drill into the details later. Ockam is a tool for a developer to build applications that can trust the data in motion between applications.

It could be distributed parts of the same app, or it could be two apps communicating with each other. We give a developer the tools to add trust to that communication and the data that's moving through. But what does that mean? If you peel a layer below that, what that means is we've made the hard parts; mutual authentication, end-to-end encryption, and granular authorization policies on the data flow, we made all of that really easy to add to an application.

If I have an app in a data center and I want to communicate with another part of that application in AWS cloud, we can make it so that the communication is end-to-end encrypted, mutually authenticated, and has granular authorization policies enforced on it.

If you go another layer below, Ockam is a collection of cryptographic and messaging protocols that are wrapped in a programming library that you can call with very simple one or two-line functions to get these capabilities. You don't have to know the underlying secure channel protocol to establish a secure channel. You just get a function called create secure channel, and it gives you a secure, end-to-end encrypted, mutually authenticated channel. So that's what Ockam does, and I can keep talking about the details of how the layers below work, but that's my answer.

### What is Ockam? For the non-technical <a href="#what-is-ockam-for-the-non-technical" id="what-is-ockam-for-the-non-technical"></a>

Matthew Gregory: I'm looking forward to the episode where we get into the protocol and we go through all the protocol design. We collaborated with Trail of Bits, who did our security audit, on a paper describing all of this. That was a fun project and also a forcing function to lay out in simple terms how it all works.

I describe Ockam as WhatsApp for Enterprise data-in-motion systems.

I use WhatsApp because the way that WhatsApp and Ockam works is pretty similar. The other thing about this metaphor that I like is it emphasizes that this is an application layer solution. It's not at the security layer. So we operate at the application layer, and here's how the story goes with WhatsApp. Let's say, I have WhatsApp on my phone and you have WhatsApp on your phone, these two applications can reach each other through the internet without having to touch any of the underlying infrastructure.

My application can go find Mrinal's application through the internet, without him having to touch anything in his network. These two applications can set up a mutually authenticated connection with each other.

So when I'm texting with Mrinal, I know that Mrinal is the person receiving my message. I know that it's him on the other end. Or essentially the application is a proxy for Mrinal because he's the one driving it through his phone. So now we have an identity, which means that we can do mutual authentication that's exclusive between these two applications, and then we can move messages between each other in an end-to-end encrypted way.

And the unique thing about this is that WhatsApp sits in the middle. My phone is not directly connecting to Mrinal's. It has to go out of the infrastructure that I'm currently in, from this network up to the cloud, then go find the WhatsApp server, leave the WhatsApp server, traverse the internet, make it back into Mrinal's network, and then land on his phone.

So there are all these hops along the way. But the cool thing is because it's end-to-end, there's no intermediary along the way that can have access to this data. It's end-to-end encrypted, and setting that up is really difficult. And specifically, WhatsApp cannot read any of these messages. Even though we have that in this consumer product, it is exceptionally difficult to set up in an enterprise data world.

And a lot of the difficulty is because you're not dealing with a lot of the magic that comes with iPhones and Google phones. So it's very difficult to do such a seemingly simple thing. Ockam is the mutual authentication, end-to-end encryption service for any two applications sitting anywhere inside an enterprise or even between two different enterprises, two different companies that need to connect and share data in a peer-to-peer way. Glenn, how do you describe Ockam?

### Enterprise vs. Consumer end-to-end encryption options <a href="#enterprise-vs-consumer-end-to-end-encryption-options" id="enterprise-vs-consumer-end-to-end-encryption-options"></a>

Glenn Gillen: Well, in our early conversations before I joined, that analogy was part of the 'aha' moment for me, when I realized the potential of Ockam. In my personal life, 100% of the people that I message regularly are using iMessage, Signal, or WhatsApp. So the consumer experience around trusted, encrypted, private end-to-end messaging is so ubiquitous and you never think about it.

We've all been conditioned to expect that as the norm now. You message someone, you get the blue bubble. I didn't have to worry about what network I was on, or did I open up a port to my firewall. It always just works, everywhere all the time.

And then as you were telling me that story, I thought: If I've got a container or a web process and I'm trying to connect it to a database, if those two things are in the same network, then it's relatively quick and easy. But the moment I put the database in a private subnet and that process is anywhere else, even in the same VPC or another cloud, you have a much bigger challenge.

I have to change security groups, firewalls need to open, and in the best case, it's hours of work and dozens of things I need to do. And if any one of those things goes wrong, I've either accidentally exposed my data, or I don't get it working.

There are so many failure modes there. And that was part of what pulled me over here: why are our tools so poor when the consumer ones are so good? Bringing those two things together and that experience to a similar place is what was most exciting to me about Ockam.

Matthew Gregory: Great. With that, we can wrap up our first episode as I said we could keep it simple with this one. We'll dive into some nitty gritty topics as we go along. Let us know what you'd like to talk about, and we'll see you on the next episode of the Podcast. Have a good day. Bye.
