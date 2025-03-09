# Building an Agentic System

There's been a lot of asking about how Claude Code works under the hood. Usually, people see the prompts, but they don't see how it all comes together. This is that book. All of the systems, tools, and commands that go into building one of these.

A practical deep dive and code review into how to build a self-driving coding agent, execution engine, tools and commands. Rather than the prompts and AI engineering, this is the systems and design decisions that go into making agents that are real-time, self-corrective, and useful for productive work.

## Why This Guide Exists

I created this guide while building out highly specialized, vertical agents. I'll often start with a problem with a framework and then unbundle parts of it, which is why I immediately wanted to take an agent I was building in Go and see how an agent like Claude Code could improve it, with a bunch of other features like rich components, panes, effectively Devin for your terminal. More on that soon.

(Note to the reader, I did do the Rewrite it in Rust thing, and it originally was, but [Charm](https://charm.sh) is excellent. Ultimately, it came down to wanting to bind to [jujutsu](https://github.com/jj-vcs/jj) for handling safe, linearizable checkpoints and the ability for multiple agents and humans to work together)

After diving deep into Claude Code and similar architectures, I realized there's a gap in practical, engineering-focused documentation on how these systems actually work. Most resources either stay at a theoretical level or skip to implementation details without covering the critical architectural decisions. This is really a "how things work" book, and the software pieces themselves would be recognizable.

In addition, I've provided documentation on every tool and command, and its implementation. This is where this documentation shines - combining those with the execution rules reveals a lot of why Claude Code works so well. Don't skip either section!

This isn't just about Claude Code or anon-kode. It's about the underlying patterns that make real-time AI coding assistants feel responsive, safe, and genuinely useful—patterns I've found while building my own system.

## What You'll Find Inside

This guide dissects a working agentic system architecture with a focus on:

1. **Responsive Interactions** - How to build systems that stream partial results instead of making users wait for complete responses
2. **Parallel Execution** - Techniques for running operations concurrently without sacrificing safety
3. **Permission Systems** - Implementing guardrails that prevent agents from taking unauthorized actions
4. **Tool Architecture** - Creating extensible frameworks for agents to interact with the environment

I've deliberately focused on concrete engineering patterns rather than theoretical ML concepts. You'll find diagrams, code explanations, and architectural insights that apply regardless of which LLM you're using.

## Who am I?

Hi! I'm Gerred. I'm a systems engineer, with a deep background in AI and Kubernetes at global scale, but overall I care deeply about everything from frontend UX to infrastructure and I have _opinions_. My background includes:

- Early work on many CNCF projects and Kubernetes
- Creator of [KUDO](https://kudo.dev) (Kubernetes Universal Declarative Operator)
- Early deployment of GPUs onto Kubernetes for holoportation and humans in AR/VR
- Data systems at scale at Mesosphere, including migration to Kubernetes
- One of the initial engineers on the system that would grow to become [Platform One](https://p1.dso.mil/)
- Implementing AI systems in secure, regulated environments
- Designing and deploying large-scale distributed systems
- Currently developing frameworks for specialized agents with reinforcement learning, especially with VLMs

My focus has always been on the intersection of developer experience and robust engineering—how to make powerful systems that are actually pleasant to use.

## Why Build Your Own Agent?

Commercial AI coding assistants are impressive but come with limitations:

1. **Context boundaries** - Most are constrained by input/output limits
2. **Extensibility challenges** - Limited ability to add specialized capabilities
3. **Integration gaps** - Often struggle to connect with existing workflows and tools
4. **Domain specificity** - General-purpose assistants miss nuances of specialized domains

Building your own agent isn't just about technical independence—it's about creating assistants tailored to specific workflows, domains, and security requirements.

## State of This Work

This guide represents my analysis of several coding agent architectures, including Claude Code, anon-kode, and my own experimental system. It's currently in active development as my own agent enters final testing.

The patterns documented here have proven effective in practical applications, but like any engineering approach, they continue to evolve. I'm sharing this now because these architectural insights solved real problems for me, and they might help you avoid similar challenges.

## How to Use This Guide

If you're building an AI coding assistant or any agentic system:

- Start with the system architecture diagram for a high-level overview
- Explore specific components based on your immediate challenges
- Pay particular attention to the parallel execution and permission system sections, as these address common pain points

For a deeper exploration of specific subsystems, the tool and command system deep dives provide implementation-level details.

## Connect and Support

I'm actively building in this space and available for consulting. If you need help with:

- Verticalized agents for specific domains
- Production agent deployments
- Practical AI system architecture
- Making this stuff actually work in real environments

Reach out [by email](mailto:hello@gerred.org) or on X [@devgerred](https://x.com/devgerred).

If this work's valuable to you, you can support my ongoing research through [Ko-fi](https://ko-fi.com/gerred).

---

Let's dive into the architecture that makes these systems work.