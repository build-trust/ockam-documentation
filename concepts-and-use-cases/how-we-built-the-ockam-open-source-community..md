# How we built the Ockam Open Source community.

I've been fortunate to be part of some amazing teams that have had even larger communities around the products they're building. That kind of success rarely happens by accident and a great product alone is not enough to make it happen. It requires a lot of intentional nurturing of those earliest of adopters, lots of listening to people, supporting them, making yourselves and the project approachable and accessible. Those early years can be really hard but the payoff is so exciting when you look around and realize millions of people are using the products you've been building. Getting to be part of that growth story again is one of the reasons I joined Ockam! So I thought it was a good excuse to unpack some of the ways the team have been able to build the success they've had so far.

### Be a small part of an existing excited community <a href="#be-a-small-part-of-an-existing-excited-community" id="be-a-small-part-of-an-existing-excited-community"></a>

Back in 2005/2006 I was fortunate enough to find myself exploring ruby as a language. Whatever your thoughts of the language itself, the community around it back then was incredible. So welcoming. So supportive. They even had an acronym of MINASWAN that they'd reference in forums, it stood for "Matz is nice, so we are nice". Matz being the creator of the language and so his soft demeanor was used as something to role model and take the heat out of potential flame wars. Then Rails arrived on the scene and brought with it a whole new level of excitement. It's opinionated approach to web development showed a whole new level of productivity was possible. Then Heroku arrived and did the same for deploying and running those apps at scale. The language, the tools, the community. It was like each layered on top of each other, each amplifying the excitement and impact of the previous. It was intoxicating to be part of.

While at Heroku I saw the same happen with the NodeJS community. Starting off as a cute idea of running a browser engine on a server, and before I knew it conferences and hackathons were everywhere. Filled with amazing people using Node to build robots, fly drones, and bringing with them a new perspective and excitement for app development. The story repeated again with Golang. And now Rust.

The idea of "just rewrite X in Rust" seems like it's officially become a meme now, even if there's a legitimate reason for a project to embrace the safety and performance improvements of Rust. Treat it like a meme though and you end up overlooking the huge community of passionate people who want to improve things. To bring safety and performance improvements to everyone. To make the things we build secure by design.

If at all possible, make technology choices where the existing community is already aligned to the core beliefs and principles of the product you're building. Where those communities are established but growing. It's not to say you'll fail to build your own community if you don't do these things, and you shouldn't make critical technical decisions based _purely_ on the community. But you'll really have the wind at your back if these things align.

<figure><img src="https://www.ockam.io/blog/how_grow_popular_open_source_github/rust-sponsorship.png" alt=""><figcaption></figcaption></figure>

Then make sure to give back to the community wherever and however you can. That can be contributing patches upstream, sponsoring conferences and events, or sponsoring other projects or community members. We run a sponsorship program where we make regular financial contributions to a number of people or projects. We plan to regularly grow that and will be looking for input on where we should direct that support, so if you’re interested in helping shape that please join the community.

### Keystrokes > Clicks <a href="#keystrokes--clicks" id="keystrokes--clicks"></a>

<figure><img src="https://www.ockam.io/blog/how_grow_popular_open_source_github/star-history.png" alt=""><figcaption></figcaption></figure>

_(Take a look any any projects GitHub star growth over time with_ [_Star History_](https://star-history.com/#build-trust/ockam\&Timeline)_)_

That's an impressive looking chart! Stars alone don't tell the success of an early project though, clicks aren't the same level of commitment as keystrokes. All it really tells you is someone, somehow, at least came across the name of your project. Then they clicked a button. Because they're immediately going to use what you're working on in their production stack? Because they had a personal emergency and wanted to make sure they come back later, maybe, to work out what exactly it does? Just because they like making people feel good by giving them stars? You've no real way to know. It's a curious directional input and a good early indicator. If those stars aren't turning into more visible activity then it's probably a red flag that people can't work out how to engage.

### Make people feel welcome and safe <a href="#make-people-feel-welcome-and-safe" id="make-people-feel-welcome-and-safe"></a>

If you're not already an active contributor to an open source project or two it can seem very daunting. You don't want to do the wrong thing and embarrass yourself. Remove that anxiety for people by giving them an easy way to do something low risk. Matt did that a couple of years ago by creating a long-lived issue for people to simply [say hello](https://github.com/build-trust/ockam/discussions/137). That's it. Say hi, introduce yourself. It's a safe place to make a first step.

When people do make a contribution, don't forget your manners -- say thanks! 😁 In our constant rush to get things done it can be easy, especially in our online interactions, to let our normal cordiality lapse. It costs so little to be kind to people, especially those that are going to the effort to help you! I've seen the Ockam engineering team consistently support people through their first few PRs, thanking and congratulating them on their contributions ([here's a recent example](https://github.com/build-trust/ockam/pull/4202)). Not at all a place where people who do the wrong thing are chastised and told to RTFM. Not here, it's nothing but 🙏 & 💙.

The results speak for themselves: the number of contributors has doubled year-on-year, the releases this month alone have had over 60 different contributors. That's people actively submitting code changes to the core product! In addition to that there's all the bug reports, feature requests, improvements to documentation. Every little bit helps, even if it's raising an issue to tell us when and where things don't work.

### Guiding people on their first step <a href="#guiding-people-on-their-first-step" id="guiding-people-on-their-first-step"></a>

I'll call out again just how daunting it can be for people when they're trying to get started. If I can stress just one thing to focus on it is fixing that. Another place that feeling manifests is in not knowing where to start. If you've been using the product already, hit a bug, and have the skills to know how to fix it then you've already got yourself a plan. Hopefully you don't have hundreds of people hitting bugs every day though. So what about everyone else? They're facing a blank canvas of possibility with no idea where to start.

So show them!

We're regularly tagging issues as ["good first issue"](https://github.com/build-trust/ockam/labels/good%20first%20issue) to help first time contributors find something to cut their teeth on. More than that though, the team makes a special effort to ensure everything is detailed enough to make sense in isolation. If you had to be on the weekly planning call to make sense of an issue then it's not something anybody else would be able to provide input on. If that’s not enough though, give people a place to ask for help on how to start too.

### Complete GitHub's Community Standards <a href="#complete-githubs-community-standards" id="complete-githubs-community-standards"></a>

<figure><img src="https://www.ockam.io/blog/how_grow_popular_open_source_github/github-community-standards.png" alt=""><figcaption></figcaption></figure>

You may not have seen it, but over on the "Insights" tab of your repo is a "Community Standards". They've got a paint-by-numbers checklist of things to complete, go check it out and do it. There's no point in me re-iterating everything they've already done a great job of pulling together.

### Expand your visibility <a href="#expand-your-visibility" id="expand-your-visibility"></a>

Pretty early in the journey your community will exist beyond a single project repository. Contributions will be spread across multiple repos. People will follow you on Twitter or join your Discord server. Being hyper-focussed on a single project risks missing the forest for the trees. Success then brings its own challenges: there's a lot of activity, too much to guarantee you're always seeing the important bits.&#x20;

### The compounding effect of dozens of little things <a href="#the-compounding-effect-of-dozens-of-little-things" id="the-compounding-effect-of-dozens-of-little-things"></a>

<figure><img src="https://www.ockam.io/blog/how_grow_popular_open_source_github/ockam-community-github-contribution-growth.png" alt=""><figcaption></figcaption></figure>

There are no silver bullets here. It starts with building a useful product, but that really is the start. None of the things here guarantee you grow a successful team but they're a valuable incremental step, each making all the other efforts more valuable. Over time all the little things really do add up. So far things are looking good! Ockam’s now [inside the top 50 most popular and fastest growing security projects](https://opensourcesecurityindex.io/), though there’s still many years ahead of us building this into the product and company we know it can be.

If you’d like to join the Ockam community yourself and help us build trust in the way people develop applications and services, by making them secure by design, then hopefully after reading this you already know where to start!&#x20;
