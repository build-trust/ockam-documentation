# Ockam has the traits of Rust because Ockam was built in Rust.

In the early days of Ockam we were developing a C library. This is the story of why, many months in, we decided to abandon tens of thousands of lines of C and rewrite in Rust.

Before we begin, I was in a [recorded webinar](https://www.influxdata.com/resources/meet-the-founders-an-open-discussion-about-rewriting-using-rust/) this week together with Paul Dix, the CTO of InfluxData, where we both discussed InfluxDB’s and Ockam’s rewrites in Rust. Why the two open source projects chose to re-write, why we chose Rust as our new language, lessons we learnt along the way and more. Do checkout [the recording](https://www.influxdata.com/resources/meet-the-founders-an-open-discussion-about-rewriting-using-rust/). It was an insightful discussion.

Ockam enables developers to build applications that can trust data-in-motion. We give you simple tools to add end-to-end encrypted and mutually authenticated communication to - any application running in any environment. Your apps get end-to-end guarantees of data integrity, authenticity, and confidentiality … across private networks, between multiple clouds, through message streams in kafka – over any multi-hop, multi-protocol topology. All communication becomes end-to-end authenticated and private.

We also make the hard parts super easy to scale - bootstrap trust relationships, safely manage keys, rotate/revoke short-lived credentials, enforce attribute-based authorization policies etc. The end result is - you can build apps that have granular control over every trust and access decision - apps that are private and secure-by-design.

In 2019, we started building all of this in C. We wanted Ockam to run everywhere - from constrained edge devices to powerful cloud servers. We also wanted Ockam to be usable in any type of application - regardless of the language that application is built in.

This made C an obvious candidate. It can be compiled for 99% of computers and pretty much run everywhere (once you figure out how to deal with all the target specific toolchains). And all other popular languages can call C libraries through some form of a native function interface - so we could later provide language idiomatic wrappers for every other language: Typescript, Python, Elixir, Java etc.

The idea was we’ll keep the core of our communication centric protocols decoupled from any hardware specific behavior and have pluggable adapters for hardware we want to support. For example, there would be adapters to store secret keys in various HSMs, adaptors for various transport protocols etc.

Our plan was to implement our core as a C library. We would then wrap this C library with wrappers for other languages and run everywhere with help of pluggable hardware adapters.

### Simple and Safe Interfaces <a href="#simple-and-safe-interfaces" id="simple-and-safe-interfaces"></a>

But, we also care deeply about simplicity - it's in our name. We want Ockam to be simple to use, simple to build, simple to maintain.

At Ockam’s core is a layered stack of cryptographic and message based protocols like Ockam Secure Channels and Ockam Routing. These are asynchronous, multi-step, stateful communication protocols and we wanted to abstract away all of the details of these protocols from application developers. We imagined the user experience to be a single one-line function call to create an end-to-end authenticated and encrypted secure channel.

Cryptography related code also tends to have a lot of footguns, one little misstep and your system becomes insecure. So simplicity isn't just an aesthetic ideal for us, we think it's a crucial requirement to ensure that we can empower everyone to build secure systems. Knowing the nitty-gritty of every protocol involved should not be necessary. We wanted to hide these footguns away and provide developer interfaces that are easy to use correctly and impossible/difficult to use in a way that will shoot your application in the foot.

That’s where C was severely lacking.

Our attempts at exposing safe and simple interfaces, in C, were not successful. In every iteration, we found that application developers would need to know too much detail about protocol state and state transitions.

### The Elixir Prototype <a href="#the-elixir-prototype" id="the-elixir-prototype"></a>

Around that time I wrote a prototype of creating an Ockam Secure Channel over Ockam Routing in Elixir.

Elixir programs run on BEAM, the Erlang Virtual Machine. BEAM provides Erlang Processes. Erlang Processes are lightweight stateful concurrent actors. Since actors can run concurrently while maintaining internal state, it became easy to run a concurrent stack of stateful protocols - Ockam [Transports](https://docs.ockam.io/reference/command/routing) + Ockam [Routing](https://docs.ockam.io/reference/command/routing) + Ockam [Secure Channels](https://docs.ockam.io/reference/command/secure-channels).

I was able to hide all the stateful layers and create a simple one line function that someone can call to create an end-to-end encrypted secure channel over a variety of multi-hop, multi-protocol routes.

`{:ok, channel} = Ockam.SecureChannel.create(route, vault, keypair)`\


An application developer would invoke this simple function and multiple concurrent actors would run the underlying layers of stateful protocols. The function would return when the channel is established or if there is an error. This is exactly what we wanted in our interface.

But Elixir isn’t like C. It doesn’t run that well on small/constrained computers and it's not a good choice for being wrapped in language-specific idiomatic wrappers.

### Benefits of Rust <a href="#exploring-rust" id="exploring-rust"></a>

At this point we knew we wanted to implement lightweight actors but we also knew C would not make that easy. This is when I started digging into Rust and very quickly encountered a few things that made Rust very attractive:

#### Rust has compatibility with the C calling convention <a href="#compatibility-with-the-c-calling-convention" id="compatibility-with-the-c-calling-convention"></a>

Rust libraries can export an interface that is compatible with C's calling convention. Which means that any language or runtime that can statically or dynamically link and call functions in a C library can also link and call functions in a Rust library - in the exact same way. Since most languages support native functions in C, they also already support native functions in Rust. This made Rust equal to C from the perspective of our requirement of having language specific wrappers around our core library.

#### Rust has support for lots of targets <a href="#support-for-lots-of-targets" id="support-for-lots-of-targets"></a>

Rust compiles using LLVM which means that it can target a very large number of computers. This set is likely not as big as everything that C can target with GCC and various proprietary GCC forks but is still a very large subset and there’s work ongoing to make Rust compile with GCC. With growing support of new LLVM targets and potential GCC support in Rust, it seemed like a good bet from the perspective of our requirement of being able to run everywhere.

#### Rust has strong typing and a powerful type system <a href="#strong-typing-and-a-powerful-type-system" id="strong-typing-and-a-powerful-type-system"></a>

Rust’s type system allows us to turn invariants into compile-time errors. This reduces the set of possible mistakes that can be shipped to production by making them easier to catch at development time. Our team and the user of our Rust library become less likely to ship behavioral bugs or security vulnerabilities to production.

#### Rust has memory safety and the borrow checker <a href="#memory-safety-and-the-borrow-checker" id="memory-safety-and-the-borrow-checker"></a>

Rust’s memory safety features eliminate the possibility of use-after-frees, double frees, overflows, out-of-bounds access, data races and many other common mistakes that is known to cause 60-70% of high-severity vulnerabilities in large C or C++ codebases. Rust provides this safety at compile time without incurring the performance costs of safely managing memory at runtime using a garbage collector. This gives Rust a serious advantage to write code that needs to be highly performant, run in constrained environments, and be highly secure.

#### Rust has Async/await and pluggable async runtimes <a href="#asyncawait-and-pluggable-async-runtimes" id="asyncawait-and-pluggable-async-runtimes"></a>

The final piece that convinced me that Rust is a great fit for Ockam was `async/await`.

We had already identified that we need lightweight actors to create a simple and safe interface Ockam's stack of protocols. `async/await` meant that a lot of the hard work to create actors had already been done in projects like tokio and async-std. We could build Ockam's actor implementation on this foundation.

Another important aspect that stood out was that `async/await` in rust has one significant difference from `async/await` in other languages like Javascript.

In Javascript a browser engine or nodejs picks the way it will run async functions. But in Rust you can plugin a mechanism of your own choice. These are called async runtimes - tokio is a popular example of such a runtime that is optimized for highly scalable systems. But we don't always have to use tokio, we can instead chose an async runtime optimized for tiny embedded devices or microcontrollers.

This meant that Ockam's actor implementation, which we later called Ockam [Workers](https://docs.ockam.io/reference/libraries/rust/nodes), if we base it on Rust's `async/await` can present exactly the same interface to our users regardless of where it is running - big computers or tiny computers. All our protocol interfaces that would sit on top of Ockam Workers can also present the exact same simple interface - regardless of where they are running.

At this point we were convinced we should re-write Ockam in Rust.

In the [webinar](https://www.influxdata.com/resources/meet-the-founders-an-open-discussion-about-rewriting-using-rust/) conversation, that I mentioned earlier, Paul Dix and I discussed what the transition looked like for our teams at Ockam and InfluxDB after each project had decided to switch to Rust. We discussed how InfluxDB moved from Go to Rust and how Ockam moved from C to Rust. In case you're interested, in that part of our journey go listen to the [recording](https://www.influxdata.com/resources/meet-the-founders-an-open-discussion-about-rewriting-using-rust/).

Many iterations later, anyone can now use the Ockam crate in rust to create an end-to-end encrypted and mutually authenticated secure channel with a simple function call.

Here’s that one single line, we had imagined when we started:

`let channel = node.create_secure_channel(&identity, route, options).await?;`\


It creates an [authenticated and encrypted channel](https://docs.ockam.io/reference/libraries/rust/secure-channels) over arbitrary multi-hop, multi-protocol routes that can span across private networks and clouds. We are able to hide all the underlying complexity and footguns behind this simple and safe function call. The code remains the same regardless of how you use it - on scalable servers or tiny microcontrollers.

To learn more checkout Ockam on Github or try the step-by-step walk throughs of the [Ockam Rust library](https://docs.ockam.io/reference/libraries/rust)
