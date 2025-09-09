# Cognition: The Devin is in the Details

Not to bury the lede: **I’ll be joining Cognition**, makers of the Devin AI software engineer and now owners of the Windsurf agentic IDE. The vast majority of my equity/investor capital at Smol AI will be rolling over their investment to Cognition as part of the deal, while I will continue to work on AI Engineer and Latent Space independently of Cognition (As part of restructuring, I’m delighted that [Lia](https://www.linkedin.com/in/lialouisemcbride/?originalSubdomain=uk) is stepping up to be General Manager of AI Engineer, and Latent Space is, unrelatedly, incorporating and also growing to relieve my workload, which I am very grateful to have the opportunity to do, more on that later).

> Note: I’ve been fairly public that I’ve [advised](https://www.swyx.io/portfolio) companies before, most recently [Fireworks](https://www.ainvest.com/news/fireworks-ai-targets-4-billion-valuation-surging-600-open-source-ai-demand-2507/), and while I will ferociously defend the neutrality and independence of AIE and LS, obviously this new Cognition deal is quite a bit bigger than others, so I’m sharing some thoughts on occasion of this fundraise, both for my future self and others scrutinizing this choice.

When I first tried [Devin in April 2024](https://x.com/swyx/status/1776771329066500589) I got a lot of shit for leaning positive, when all people wanted to talk about was the [Upwork video](https://news.ycombinator.com/item?id=40008109). But I gave them a lot of grief in private, which is, btw, how you’re actually supposed to conduct yourself in polite company. Fast forward and Cognition is announcing that they have gone from 0 to their $10B Series C in 2 years today, with me effectively packing up and joining them \[1\].

I wanted to explain why I am basically putting my Smol “chips” into Cognition despite such a historically outsized runup in valuation:

1.  Nontechnical thesis: **Short Code timelines, Long AGI timelines**
2.  Agents thesis: **The rise of Agent Labs**
3.  Engineer thesis: **Owning the Sync/Async spectrum**
4.  Business model: **Usage Based for Enterprise, Cheap Seats for Individuals**
5.  Team: **Cracked Engineers + Ramped GTM**

These are the 5 things that I believe basically walk you down the idea maze of joining Cognition. So let’s go through each of them.

## [Short Code Timelines, Long AGI Timelines](https://www.swyx.io/cognition?utm_source=tldrai#short-code-timelines-long-agi-timelines)

It may feel like a truism to say that not all things in AI are equally valuable to work on, but often our actions betray a false complacency/equivalence. The way to take a giant high dimensional space and break down the highest order bit is to think about projections down to the biggest 2 principal components that matter. For me, it is the **speed of takeoff** and the **economic value** when we hit the ideal scenario:

![Image](https://github.com/user-attachments/assets/77233e48-8982-43fc-9240-b59a8e03e50c)

I think the central realization I had was this: **Code AGI will be achieved in 20% of the time of full AGI, and capture 80% of the value of AGI.** Pareto principle of AGI is simply to just do code AI now rather than later.

Many model labs including OAI, Anthropic, GDM, [Xai](https://x.ai/news/grok-code-fast-1), even [DeepSeek](https://github.com/deepseek-ai/deepseek-coder) and [Reflection](https://www.youtube.com/watch?v=DIu7xA898go), are now seeing “Code AGI” as a critical path toward solving AGI. This was somewhat in the air to insiders 2-3 years ago, since it is widely known that adding code capabilities improves reasoning in LLMs, and of course I got [very excited about Code Interpreter in the loop](https://www.latent.space/p/code-interpreter) 2 years ago. But with OAI building [Codex](https://www.latent.space/p/codex) as part of A-SWE, Anthropic doing 3.5+ Sonnet and Claude Code, and GDM execuhiring Windsurf leadership, I think the actions have finally caught up here.

Everybody points out that Code is a **verifiable domain**, so it progresses faster than non-v domains, but of course the other nice property of working on Code AI is that it is the only\[0\] one that is **recursively improving** - the people building Code AI will be able to dogfood directly and solve their own needs. Enough said.

> ok. so you decided to work on Code. work where?

## [Agent Labs vs Model Labs](https://www.swyx.io/cognition?utm_source=tldrai#agent-labs-vs-model-labs)

> note: you may be frustrated that I shy away from a proper definition of “Agent Lab”. More on that in future…

From 2015 (when OpenAI was founded) to 2025, the right place to work was clearly at model labs, seeing through the 3 paradigms of [pretraining, scaling, and reasoning](https://x.com/swyx/status/1963122452546060748). With OpenAI now at $500B valuation, burning up to [$45B a year](https://x.com/jukanlosreve/status/1964142046551384249?s=46), and Anthropic now at $200B, with GDM and Xai and the Chinese labs and more and more scaling up with competitive models, **model diversity** is a real thing, providing a new optimization surface area for app-layer builders. While exploiting best-of models is in theory a nice win for agent labs, the *business* justification for agent labs is simple: “I cant keep up with all this AI stuff, let me hire guys who nerd out about this all day to keep us on top of things”. That is about the level of abstraction the lower 90% of the AI bell curve can deal with.

In the [Decade of Agents](https://www.latent.space/i/166191505/closing-recap) from 2025-?, the nonconsensus view is perhaps that working at ”**agent labs**” will have the relative alpha instead.

-   **Model labs are product-last, Agent labs are product-first**: In 2023 the go to move was for AI startups to raise tons of money to buy their own GPU farms, build their own models and somehow profit. This covers the likes of Inflection and Stability and Magic.dev, and those companies flamed out pretty quickly and the metagame moved on. In 2025 there has been a stronger wave of new Model Labs, and while their outcomes are TBD, again they are product-last, from Poolside to Thinking Machines. Safe Superintelligence even proudly proclaims they will not ship any product until they ship the Last Product. Cool, but meanwhile customers are waiting. Agent labs ship product first, and then work their way down as they get data, revenue and conviction and deep understanding of their problem domain. But that is not to say that Agent Labs are antagonistic to Model Labs, because…
    
-   **Model labs create frontier models, Agent Labs adapt them to domains that they don’t fully solve yet**: The future is here, but it is not evenly distributed. In interestingly opposite ways, Agent Labs either serve to “distribute” the frontier to markets that it hasn’t yet reached, or they serve to “pull forward” the future (by either burning vc money ahead of [the 1000x/1.5yrs price drop](https://www.latent.space/p/reasoning-price-war) per unit intelligence that is happening broadly in AI, or burning VC cash to get more out of current models using tricks like [self-consistency](https://x.com/swyx/status/1963153810844455025) to simulate having a future model. Because of the economic incentives of effectively being a “thick GPT Wrapper”, Agent Labs are far more incentivized to sniff out high value frontiers that the Model Labs are not yet focused on, staying ahead of that curve until the Model Labs wake up to it (as happened to Cognition)
    
-   **Agent Engineering will survive the bitter lesson**: I am obviously pro [Agent Engineering](https://www.latent.space/p/agent), but yes the Bitter Lesson pilled folks will find it very very hard to get [the Hyung Won inductive bias chart](https://www.latent.space/p/icml-2024-video-robots) out of their minds.
    
    ![Image](https://github.com/user-attachments/assets/173dca32-cce0-46d2-b1e9-c0eff66834a5)
    -   but you can [engineer your way above the Bitter Lesson](https://www.youtube.com/watch?v=qdmxApz3EJI), and harnesses can [survive even reasoning paradigm changes](https://www.qodo.ai/blog/system-2-thinking-alphacodium-outperforms-direct-prompting-of-openai-o1/#alphacodium-o1-an-incremental-step-towards-system-ii):

![Image](https://github.com/user-attachments/assets/e36e168b-1700-42fb-bf71-002236382c41)

(to be SUPER clear this is not the norm, most harnesses fall to the bitter lesson, but the good agent teams make it easy to write the next harness and surf the performance winds).

I don’t feel I have as compelling an argument in this section as in the others, which is mostly why I am not actually ready to publish a full “Why Agent Lab?” piece yet, because we still don’t have a great answer for “what if OpenAI does this?” I can digress for a little section I drafted called…

### [The Devin is in the Details](https://www.swyx.io/cognition?utm_source=tldrai#the-devin-is-in-the-details)

-   The difference between ”[unreasonably effective](https://sketch.dev/blog/agent-loop)” “[LLM in a Loop](https://x.com/swyx/status/1964473164127490095)” oversimplification and agents like Devin and Cascade is the “remaining 10%” that developers chronically underestimate.

-   Building the best AI coding agents and IDEs takes a ton of integration work and dozens of improvements every month, all tracked in our [release notes](https://docs.devinenterprise.com/release-notes/overview), everything from our [MCP Marketplace](https://cognition.ai/blog/mcp-marketplace) (including official Datadog, Sentry, Figma, Supabase, Vercel, Stripe, Playwright MCPs) to UI improvements to very long tail Enterprise integration polish from Linear to Slack to Azure DevOps and Self-Hosted GitLab.
-   10 months after launch, Windsurf is now actively used by many hundreds of thousands of developers (have you seen [the meetups?!?](https://luma.com/windsurf?period=past)), and we are investing extremely aggressively to further polish, integrate, and innovate on both our sync and async agentic coding surface areas with integrations and compliance/ security/ privacy/ observability/ deployment/ scalability requirements that are battletested from the smallest teams to the largest enterprises in the world.

The [sheer surface area of enterprise integrations is something Windsurf’s Anshul wrote about](https://www.latent.space/p/enterprise) on LS and while of course the Model Labs care about serving the enterprise, stuff like this is not high on their list:

![Image](https://github.com/user-attachments/assets/d9bbf901-8d56-4fc0-8d01-5e8fd2921a09)

> ok, so work on Code at an Agent Lab. which one?

## [Owning the Sync/Async spectrum](https://www.swyx.io/cognition?utm_source=tldrai#owning-the-syncasync-spectrum)

The question of which part of AI Coding to focus on is also a very important one. Pick the wrong one and you spin your wheels. Pick your mental framework:

-   **The AI Software Development Lifecycle** (SDLC, or even [ADLC](https://www.youtube.com/watch?v=0vBKv9yAQi4&t=18s)): this is [mine](https://www.latent.space/i/150108358/the-ai-sdlc) - if you pick this, you end up working on [testing](https://www.latent.space/p/codium-agents), [evals](https://x.com/swyx/status/1963725773355057249), or maybe a [gateway](https://www.latent.space/p/gateway). Cool, cool, obviously valuable.

-   **Software personas**: there’s the:
    -   Nontechnical Vibe Coder
    -   Professional Software Engineer Architect
    -   Professional Software Engineer Peon
    -   Semitechnical Engineering Manager/PM/Designer
    -   SRE/Pager Duty Carrier
    -   Data/Business Analyst
    -   etc. Again, they’re all great, and everyone is going to make ridiculous amounts of money, but when I think through who has the most budget and highest quality of revenue, you basically go down the same path I did.
-   **Levels of autonomy**: the Karpathy [autonomy sliders](https://www.latent.space/i/166191505/part-a-autonomy-sliders) - too little and you’re uninteresting, too much and you fail.

Here again Cognition impressed me by picking the right points on the landscape, and the superfast acquisition of Windsurf:

![Image](https://github.com/user-attachments/assets/fba18974-8dba-4ac5-857b-6f0e659af7e8)

[People like Greg Brockman](https://www.youtube.com/watch?v=avWhreBUYF0) have been talking about the seamless movement of agentic coding from local to cloud and back for a while now, and with the two established products on extreme ends of the spectrum, Cognition has the potential to do well here, though it needs to follow through on this potential at some point, because right now these coding habits and UX norms haven’t been invented yet.

I have a particular bias for the async side of the spectrum. I think ”**Slack is the killer agent UI**” because ultimately that’s what we do with humans that we work remotely with and may never meet - @ them and wait for work to get done, and chat with them through the process:

![Image](https://github.com/user-attachments/assets/ea9a839b-f679-4262-9f06-592c410919b3)

Devin has done this the longest and is the presumptive category owner, although of course this particular form factor/integration is easy to clone so it needs a lot of other features and benefits to keep its place. Business evidence (below) suggests that it is doing fine so far, despite some early quality issues.

The other pushback that I get on the other side of the spectrum is that “oh man IDEs are going away, VSCode forks are a commodity, look at my guy using Claude Code”. To which I say, the first thing people want to do when they manage a bunch of Claudes Code is build a UI to manage them. Then a file explorer, and then, and then…

> ok, so work on Code at an Agent Lab with async and sync. There’s a few of these left… and any of them can build any of the others…

## [Usage Based for Enterprise, Cheap Seats for Individuals](https://www.swyx.io/cognition?utm_source=tldrai#usage-based-for-enterprise-cheap-seats-for-individuals)

Here is where I take my AIE hat off and put my CFA hat on. Let me excerpt some disclosures that made it to the [final blogpost](https://cognition.ai/blog/funding-growth-and-the-next-frontier-of-ai-coding-agents):

> -   Before acquiring Windsurf, Cognition’s **Devin ARR grew from $1M ARR in September 2024 to $73M ARR in June 2025**, as usage increased exponentially. Our growth remained efficient throughout, with total **net burn under $20M** across the company’s entire history.

There’s more info that will come out in the next month, but I think there’s a lot to unpack even in those sentences. I’ll just emphasize this: **The large majority of the revenue base is positive margin**, which we feel is important to build a sustainable business model that engineers and enterprises can plan valuable work around, while **still getting orders of magnitude more value** from their agents.

So unlike what has been rumored in the industry of wildly negative margins, Cognition somehow has created a remarkably efficient business model, meaning it will likely stick around and pricing is sustainable. This comes from having set the right initial conditions of starting with a $500 a month subscription (to allocate some baseline capacity), but priced based on [Agent Compute Units](https://devin.ai/pricing) - NO SEATS! This means business is very aligned with customers - you grow when usage grows. Establish a healthy positive margin business doing this for enterprise, and you [THEN can indefinitely fund cheap $20 self serve seats for individual devs](https://cognition.ai/blog/devin-2), including taking on Windsurf’s entire user base in a weekend. Businesses built the other way round are much less robust. Pricing is sticky upwards and when you start low, it’s really hard to go higher, and you often become hostage to your own userbase who was drawn for one value prop and is now presented with another.

> -   Growth has accelerated post-acquisition: **combined enterprise ARR at Cognition is up over 30% in the seven weeks post buying Windsurf**. We had <5% overlap in enterprise customers pre-acquisition, and combining the rapid adoption of Devin with Windsurf’s IDE product and scaled GTM machine has been a massive unlock. Devin and Windsurf now power category-defining customers including Goldman Sachs, Citi, Dell, Cisco, Ramp, Palantir, Nubank, and Mercado Libre.

The cross-sell opportunity at CogSurf (still my preferred pet name for the combined entity) is still enormous, and if you’ve met the Windsurf GTM folks in Austin and Mountain View you’d know that this is a formidable team that could sell the ever loving shit out of freaking Apple Siri if you gave them a quota and a battle card. And of course there’s the cross-**build** - first the Cog engineers taking Windsurf’s decent traction over the past year and leveling it up to be even more compelling (more soon!), then Windsurf-Devin integrations as they become a more seamless agentic coding toolkit.

The second part of this section with all the namedrops is something I only woke up to in [my time at Temporal](http://swyx.io/why-temporal) - where our first real sale was a ~$4m deal - in enterprise sales there’s a landgrab for the lighthouse customers in your category, and once you get them you also get everyone under them. Again this wasn’t published, but I was able to see logos in Investment Banking, Consumer Banking, Financial Services, Insurance, Mature Tech Enterprises, Enterprise IT, Notable Tech Startups, Healthcare, Retail, Systems Integrators, Government, and channel Partners. With each deal closed, Cognition learns material nonpublic info about the high value agentic coding usecases across every vertical, and it seems they are finding no ceiling in the difficulty and complexity of tasks that customers ask of Devin as they themselves learn to use agents. This is why speed to market, and serving valuable customers well, is of essence.

One notable concern that many people warned me about when thinking through Cognition is the issue of **services % revenue**. Any follower of my former boardmember Chetan Puttagunta will have learned that all [enterprise sales comes with some services](https://x.com/chetanp/status/1201540828096679940), but obviously you can juice your contract values in the short term by doing glorified consulting, and yes CogSurf has the vaunted [Forward Deployed Engineer](https://newsletter.pragmaticengineer.com/p/forward-deployed-engineers) role too (and they’re actually pretty cool and -insane- at their jobs), and margins would be low in the process.

Frankly put, anyone who’s actually worried about the services mix has never spent any real time with Scott, Steven or Walden, because, no, none of them nor Peter Thiel would build a majority services business, and throw in a bunch of money to goose up some valuations to create some kind of FOMO for Greater Fools to bail them out, it’s a waste of everybody’s time and probably doesnt work when you pile up ~$750m worth of Greater Fools to later find.

The other antiproof is the scalability. Here I’ll share a remarkable stat I can’t get out of my head. After a lot of work following the initial launch, in 2025 it is now very common to see >5x contract expansions - not at renewal, but proactively - in successful Devin implementations. One banking customer I saw on a $1.5m/yr contract decided to renew and expand >10x (!) with a multiyear commitment (!!). More importantly, this spend is just tracking their expected usage growth from their trial over the past 8 months expanding from a small % of their workforce to open Devin up to the rest. They started that rollout this month.

I asked about the staffing, and Cog people shrugged. Try scaling -that- as a services business.

## [Cracked Engineers + Ramped GTM](https://www.swyx.io/cognition?utm_source=tldrai#cracked-engineers--ramped-gtm)

That leaves of course, the Team. You already know there are a bunch of IOI gold medalists (eg. [`tourist`](https://en.wikipedia.org/wiki/Gennady_Korotkevich)) in Cog. Scott has been fairly public about [the IOI mafia](https://www.youtube.com/watch?v=MmKkNmnoEvw&list=PLcoWp8pBTM3ATMYLP-hFIhJORSw-nFOiY&index=2) in AI. Not to be ageist but I’m positively ancient by Cognition standards… and sometimes that might not be a good thing when it comes to building Active Directory Sync for your Enterprise Java Beans FactoryFactory and what not, and doing 18 holes and a steak dinner with some suits. Ok, it’s not the 2000s, stuff doesn’t actually work like that anymore, but still I think the concern that outsiders (and I) have is that doing programming competitions doesn’t translate to working on boring, nasty, painful enterprise B2B SaaS.

I haven’t figured out how yet, but somehow, it works. People get in to passionate fights in [the late hours](https://www.sfgate.com/tech/article/sf-tech-ceo-buyouts-culture-20805250.php) about migrations. They celebrate little UI bugfixes and dedicate an inordinate amount of time to thinking through Jetbrains support and [Jenkins migrations](https://cognition.ai/blog/from-jenkins-to-github-actions) and working through a neverending list of [MCP integrations](https://docs.devin.ai/work-with-devin/mcp). this is balanced with working on more exotic things like [Blockdiff](https://cognition.ai/blog/blockdiff) and [DeepWiki](https://cognition.ai/blog/deepwiki) and [Kevin 32B](https://cognition.ai/blog/kevin-32b) and much more alpha than revealed in [Don’t Build Multiagents](https://news.ycombinator.com/item?id=45096962). There’s all sorts of reasons this [Tiny Team](https://www.latent.space/p/tiny) should -NOT- work, but somehow it has so far.

I’m still not full ramped up on things of course, but I think the best way I’d advise thinking about it is that these are not “a bunch of guys who do programming competitions”, but rather ”*competitive* programmers”, emphasis on **competitive**. They compete on everything from running to climbing to GTM sales to poker to Smash Bros, and they will compete with you for dominance of the AI coding agent wars. To be sure, there’s a lot of great AI coding teams, and the ocean is so large that multiple teams can “win”, but that’s how I’d explain this culture. The way this team works is similar to the insight of Transformers - instead of having too much hierarchy and structure, bias towards being “fully connected” — try to have everyone know everyone, have a low barrier for asking whats going on, high sense of urgency, have a great deal of internal transparency over everything, and let individual smart nodes organize for the good of the whole (and prune often).

If anything, this culture is more valuable than the actual source code of Cognition itself.

There are a few more personal elements to the Team side - [Prem](https://x.com/premqnair/status/1948420769945682413) is one of my close movie friends, [Lulu](https://x.com/lulumeservey) is a force of nature of her own, and [Sarah](https://x.com/saranormous/status/1965096205337403399) and [Brandon](https://x.com/breeves08) are two of the greatest investors of our generation, and [Russell](https://www.linkedin.com/in/russelljkaplan/), [Theodor](https://www.linkedin.com/in/theodormarcu/), and [Andrew](https://www.linkedin.com/in/andrewgao22/) helped greatly in my decision, and if you know Zach and Peter, you know. The “interview process” was also just really fun, I fit right in and even got to sit in on some leadership meetings to really see how the sausage is made.

Last but not least was Scott, who came down to our house and spent serious time with me and handwrote an offer when I was still hemming and hawing over considering a job when I wasn’t looking for one:

![Image](https://github.com/user-attachments/assets/898d178f-1758-4331-a80d-59f456a167ae)

---

Ok, I’m mostly done. stay a while for a quieter bonus reason.

## [some personal reflections](https://www.swyx.io/cognition?utm_source=tldrai#some-personal-reflections)

There’s a very painful game I play with myself every now and then: If you could send a post-it note to yourself from 2023 to maximize your great fortune to be alive and active at this time in AI history, what would you write down? ([my stab here](https://github.com/swyxio/ai-notes/blob/main/blog%20ideas/resolved%20debates%20in%20ai.md))

Obviously very personal situation and skillset based, but I want to guide you through my thought process. In 2023 I [launched smol developer](https://x.com/swyx/status/1657578738345979905), which was little more than a bundle of prompts and a resilient workflow built on Modal (fun fact, I showed up on their traffic charts because of this, and got advisor shares as a result); but it had one of the first markings of being a generalist software dev agent and caught a ton of excitement as a result. However when I retried the exact same agent one week later, it was no longer capable of the stuff I tested it for, on the exact same endpoints. I quickly lost faith and hacked around other things, including [AINews](https://news.smol.ai/), which survives as an every-weekday AI engineering newsletter which is 99% curated by LLMs.

![Image](https://github.com/user-attachments/assets/b39d1da5-7f48-4916-9a8c-513d8d71d895)

with Smol, AIE, and LS going on, I was never actually looking for a job, but was always mindful of [the Metacreator Ceiling](https://www.swyx.io/meta-creator-ceiling) I faced. As offers came inbound and then word got out, I think the team, the eyebrow raising traction, and finally the product and it’s superior positioning in the market kept lodged in my mind. *this is what smol developer should have become if i had the skills/believed in it hard enough*.

I failed to believe then, but I won’t make that mistake again now.

## [Cognition Labs](https://www.swyx.io/cognition?utm_source=tldrai#cognition-labs)

So I have this weird triple role doing AIE, LS, and Cognition stuff. We’ve never actually said what my role is. I’m not yet ready to share. But there are gaps in how the Cognition story is told today that holds back recruiting, sales, and even product. We couldn’t say a lot of things we’d want to say because we couldn’t really substantiate it. Fixing that can fix a lot of downstream things.

Cog definitely has a culture of “show don’t tell”. I don’t have anything to show you yet. So I guess… Keep a look out for Cognition Labs :)

---

\[0\]: well, there are some others I like, like Sales Agents and Support Agents, that have “GTM recursion”, but only Software Agents have “Product recursion”.

\[1\]: I retain the Smol AI domain with my existing code IP and AINews.

---
Source: [Cognition: The Devin is in the Details](https://www.swyx.io/cognition?utm_source=tldrai)