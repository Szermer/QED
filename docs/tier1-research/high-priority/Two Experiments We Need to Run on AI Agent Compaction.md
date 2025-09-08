---
title: "Two Experiments We Need to Run on AI Agent Compaction - Jason Liu"
description: "If in-context learning is gradient descent, then compaction is momentum. Here are two research directions that could transform how we understand and optimize agentic systems."
keywords: ""
source: "https://jxnl.co/writing/2025/08/30/context-engineering-compaction/"
---

[](https://github.com/jxnl/blog/edit/main/docs/writing/posts/context-engineering-compaction.md "Edit this page")[](https://github.com/jxnl/blog/raw/main/docs/writing/posts/context-engineering-compaction.md "View source of this page")

**Two core insights:**

1. If in-context learning is gradient descent, then compaction is momentum.
2. We can use compaction as a compression system to understand how agents actually behave at scale.

_This is part of the [Context Engineering series](https://jxnl.co/writing/2025/08/28/context-engineering-index/). I'm focusing on compaction because it's where theory meets practice—and where we desperately need empirical research._

Through my [consulting work](https://jxnl.co/services/), I help companies build better AI systems and I've been thinking about compaction and how it connects to the research showing that [in-context learning is gradient descent](https://arxiv.org/abs/2212.07677). If that's true, then compaction is basically a momentum term. And if compaction is momentum, there are two experiments I desperately want to see someone run.

This builds on the foundational concepts I've explored in [context engineering](https://jxnl.co/writing/2025/08/27/facets-context-engineering/), where the structure of information flow becomes as critical as the information itself.

## Glossary[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#glossary "Permanent link")

**Compaction**: Automatic summarization of conversation history when context windows approach limits, preserving essential information while freeing memory space.

**Agent Trajectory**: The complete sequence of tool calls, reasoning steps, and responses an agent takes to complete a task. (basically the message array)

**Context Pollution**: When valuable reasoning context gets flooded with irrelevant information, degrading agent performance. I've written extensively about how this affects AI systems in [my analysis of slash commands versus subagents](https://jxnl.co/writing/2025/08/29/context-engineering-slash-commands-subagents/).

**Momentum**: In gradient descent optimization, a component that accelerates convergence by incorporating the direction of previous updates to smooth out oscillations.

## The Momentum Analogy[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#the-momentum-analogy "Permanent link")

Traditional gradient descent with momentum:

```
θ_{t+1} = θ_t - α∇L(θ_t) + β(θ_t - θ_{t-1})
```

Conversational learning with compaction:

```
context_{new} = compact(context_full) + β(learning_trajectory)
```

Compaction isn't just storing facts—it's preserving the _learned optimization path_. When you compact "I tried X, it failed, then Y worked because Z," you're maintaining the gradient direction that led to success.

This got me thinking: what if we could actually test this? What if we could run experiments that treat compaction as momentum and see what happens?

## Experiment 1: Compaction as Momentum for Long-Running Tasks[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#experiment-1-compaction-as-momentum-for-long-running-tasks "Permanent link")

The first experiment is about momentum. If compaction preserves learning trajectories, then timing should matter for success rates.

**The setup**: Run million-token agent trajectories on complex coding tasks. Test compaction at 50% vs 75% completion vs natural boundaries vs agent-controlled timing.

**The problem**: Public benchmarks generally run tasks that are very short and don't burn 700,000 tokens. You need those massive trajectories that only companies like Cursor, Claude Code, or GitHub actually have access to.

This connects to broader challenges in [AI engineering communication](https://jxnl.co/writing/2024/10/15/effective-communication-in-ai-engineering-moving-beyond-vague-updates/)—how do you measure and report progress on systems where the unit of work isn't a feature but a learning trajectory?

But we do have examples of long trajectories. Take the [Claude plays Pokemon](https://www.lesswrong.com/posts/HyD3khBjnBhvsp8Gb/so-how-well-is-claude-playing-pokemon) experiment—it generates "enormous amounts of conversation history, far exceeding Claude's 200k context window," so they use sophisticated summarization when the conversation history exceeds limits. That's exactly the kind of trajectory where compaction timing would matter.

**Key Metrics**:

* Task completion success rate
* Time to completion
* Number of backtracking steps after compaction
* Quality of final deliverable

**Research Questions**:

* Does compaction timing affect success rates?
* Can agents learn to self-compact at optimal moments?
* How does compaction quality correlate with momentum preservation?

Does compaction timing affect how well agents maintain their learning trajectory? Can agents learn to self-compact at optimal moments?

## Experiment 2: Compaction for Trajectory Observability and Population-Level Analysis[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#experiment-2-compaction-for-trajectory-observability-and-population-level-analysis "Permanent link")

The second experiment is more tractable: can we use specialized compaction prompts to understand what's actually happening in agent trajectories?

Basically, design different compaction prompts for different kinds of analysis:

**1. Failure Mode Detection**

```
Compact this trajectory focusing on: loops, linter conflicts,
recently-deleted code recreation, subprocess errors, and user frustration signals.
```

**2. Language Switching Analysis**

```
Compact focusing on: language transitions, framework switches,
cross-language debugging, and polyglot development patterns.
```

**3. User Feedback Clustering**

```
Compact emphasizing: correction requests, preference statements,
workflow interruptions, and satisfaction indicators.
```

### Expected Discoveries[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#expected-discoveries "Permanent link")

I suspect we'd find things like:

* 6% of coding trajectories get stuck with linters (I see this constantly in Cursor)
* A bunch of agents recreate code that was just deleted
* Excessive subprocess cycling when language servers act up
* Patterns around when users start giving lots of corrective feedback

These failure modes mirror the [common anti-patterns in RAG systems](https://jxnl.co/writing/2025/06/11/rag-anti-patterns-with-skylar-payne/) but at the trajectory level rather than the retrieval level.

Here's why this matters: [Clio](https://www.anthropic.com/research/clio) found that 10% of Claude conversations are coding-related, which probably influenced building Claude Code. But agent trajectories are totally different from chat conversations. What patterns would we find if we did Clio-style analysis specifically on agent behavior?

This type of systematic analysis aligns with the [data flywheel approaches](https://jxnl.co/writing/2024/03/28/data-flywheel/) that help AI systems improve through user feedback loops—but applied to multi-step reasoning rather than single predictions.

### The Clustering Approach[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#the-clustering-approach "Permanent link")

1. **Compact trajectories** using specialized prompts
2. **Cluster compacted summaries** using embedding similarity
3. **Identify patterns** across user bases and use cases
4. **Build diagnostic tools** for common failure modes

This is trajectory-level observability. Instead of just knowing "agents do coding tasks," we could understand "agents get stuck in linter loops" or "agents perform better when users give feedback in this specific way."

It's similar to the systematic improvement approaches I cover in [RAG system optimization](https://jxnl.co/writing/2024/08/19/rag-flywheel/), but focused on agent behavior patterns rather than search relevance.

## The Missing Infrastructure[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#the-missing-infrastructure "Permanent link")

Context windows keep getting bigger, but we still hit limits on complex tasks. More importantly, we have no systematic understanding of how agents actually learn and fail over long interactions.

This connects to fundamental questions about [how AI engineering teams should run standups](https://jxnl.co/writing/2024/10/25/running-effective-ai-standups/)—when your "product" is a learning system, traditional software metrics don't capture what matters.

Companies building agents could figure out why some trajectories work and others don't. Researchers could connect theory to practice. The field could move beyond single-turn benchmarks toward understanding actual agentic learning.

## Getting Started[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#getting-started "Permanent link")

The momentum experiment realistically needs a company already running coding agents at scale. The observability experiment could work for anyone with substantial agent usage data.

Both need access to long trajectories and willingness to run controlled experiments.

## Let's Collaborate[¶](https://jxnl.co/writing/2025/08/30/context-engineering-compaction/#lets-collaborate "Permanent link")

If you're working with agents at scale and want to explore these directions, [I'd love to collaborate](https://jxnl.co/services/). These sit at the intersection of ML theory and practical deployment—exactly where the most interesting problems live.

The future isn't just about better models. It's about understanding how agents actually learn and optimize over time. Compaction might be the key.

* * *

_This post is part of the [Context Engineering Series](https://jxnl.co/writing/2025/08/28/context-engineering-index/). For foundational concepts, start with [Beyond Chunks: Context Engineering Tool Response](https://jxnl.co/writing/2025/08/27/facets-context-engineering/). To understand how context pollution affects agent performance, read [Slash Commands vs Subagents](https://jxnl.co/writing/2025/08/29/context-engineering-slash-commands-subagents/).

For related concepts on AI system evaluation and improvement, explore [RAG system optimization techniques](https://jxnl.co/writing/2024/08/19/rag-flywheel/) and [systematic approaches to AI monitoring](https://jxnl.co/writing/2025/05/29/systematically-improving-rag-with-raindrop-and-oleve/)._