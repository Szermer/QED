# The Six Laws of AI-Era Software Engineering

> Why do some AI-augmented teams achieve genuine 10x improvements while others actually regress — shipping faster but understanding less, producing more but retaining nothing?

Six structural patterns explain the difference. They emerged from a meta-synthesis of 42+ articles across eight independent research domains — context engineering, agent coordination, UX design, value economics, developer tooling, and 2026 industry predictions — refined over 12 weeks through eight rounds of evidence integration. They are not aspirational principles. They are observed regularities: teams that violate them fail in predictable ways; teams that align with them compound their capabilities over time.

## The Six Laws at a Glance

| # | Law | One-Line Summary | Primary Impact |
|---|-----|-----------------|----------------|
| 1 | [Context Is the Universal Bottleneck](law-1-context.md) | What information flows into your AI system matters more than which model processes it | Architecture, Developer Tooling |
| 2 | [Human Judgment Remains the Integration Layer](law-2-judgment.md) | AI handles tasks; humans integrate tasks into value — and this gap widens with capability | Team Structure, Role Design |
| 3 | [Architecture Matters More Than Model Selection](law-3-architecture.md) | Harness > prompt > model; coordination patterns outlast any individual model | System Design, Investment Decisions |
| 4 | [Build Infrastructure to Delete](law-4-delete.md) | Today's clever orchestration is tomorrow's obsolete complexity; invest in durable primitives | Infrastructure Strategy |
| 5 | [Orchestration Is the New Core Skill](law-5-orchestration.md) | Managing AI agents is a management problem; the spectrum runs from augmentation to delegation | Skill Development, Process Design |
| 6 | [Speed and Knowledge Are Orthogonal](law-6-speed-knowledge.md) | Zero friction can mean zero knowledge; the boundary between safe speed and dangerous speed is information completeness | Quality, Knowledge Preservation |

## How These Laws Were Derived

These laws did not come from a single research paper or a theoretical framework. They emerged from convergence:

1. **Six independent synthesis sessions** analyzed 42 articles across unrelated domains
2. **The same six patterns appeared in every session** — context management, human judgment, architecture primacy, deletion readiness, orchestration skill, and speed-knowledge tension
3. **Eight refinement rounds** (January–February 2026) integrated new evidence from RCTs, platform metrics, practitioner case studies, and industry data
4. **Each refinement either strengthened or added scope conditions** — none were contradicted

The evidence base includes:

- **Controlled experiments**: Shen & Tamkin RCT (n=52, d=0.738) on AI-assisted learning
- **Platform metrics**: Vercel v0 processing 3,200 PRs/day with non-engineers submitting production code
- **Economic data**: Anthropic Economic Index measuring 33–44% illusory productivity gains
- **Production case studies**: 100K-line C compiler built by 16 parallel agents, StrongDM's zero-human-code "Dark Factory"
- **Industry benchmarks**: SWE-Bench ceiling effects, same-day competitive model releases

## How to Use This Section

### By Role

**CTO / Technical Director** — Start with [Law 3 (Architecture)](law-3-architecture.md) and [Law 4 (Build to Delete)](law-4-delete.md). These drive infrastructure investment decisions and prevent the most expensive mistakes: over-investing in orchestration that will be deleted, or under-investing in context architecture that determines everything downstream.

**Engineering Manager / Team Lead** — Start with [Law 5 (Orchestration)](law-5-orchestration.md) and [Law 2 (Judgment)](law-2-judgment.md). Your management skills transfer directly to AI orchestration. Understanding the judgment altitude shift helps you redesign roles and workflows for AI-augmented teams.

**Individual Contributor / Senior Engineer** — Start with [Law 1 (Context)](law-1-context.md) and [Law 6 (Speed and Knowledge)](law-6-speed-knowledge.md). Context architecture is the highest-leverage skill you can develop. The speed-knowledge tension directly affects your daily workflow decisions — when to delegate, when to maintain friction, and how to avoid the debugging paradox.

**Agency / Consultant** — Read all six in order. Your clients will encounter every one of these patterns. The laws provide a diagnostic framework: when a client engagement stalls, one of these six is usually the binding constraint.

### By Decision

- **"Which model should we use?"** — Read [Law 3](law-3-architecture.md) first. The answer is almost always "it matters less than you think."
- **"How should we structure our AI team?"** — Read [Law 2](law-2-judgment.md) and [Law 5](law-5-orchestration.md). Human judgment altitude and orchestration layer selection are the key variables.
- **"Why is our AI-augmented team slower than expected?"** — Read [Law 1](law-1-context.md) and [Law 6](law-6-speed-knowledge.md). Context bottlenecks and illusory speed gains are the two most common failure modes.
- **"How much of our infrastructure should we expect to keep?"** — Read [Law 4](law-4-delete.md). The answer: about 20%.

## Cross-References to QED Patterns

These laws are the "why" behind QED's pattern recommendations:

| Law | QED Patterns That Operationalize It |
|-----|-------------------------------------|
| Law 1: Context | [System Prompts and Model Settings](../patterns/implementation/system-prompts-and-model-settings.md), [Core Architecture](../patterns/architecture/core-architecture.md) |
| Law 2: Judgment | [Team Workflows](../patterns/team/team-workflows.md), [Risk Assessment](../patterns/quality/risk-assessment.md) |
| Law 3: Architecture | [AMP Architecture](../patterns/architecture/amp-architecture.md), [Framework Selection Guide](../patterns/implementation/framework-selection-guide.md) |
| Law 4: Delete | [Tool System Evolution](../patterns/architecture/tool-system-evolution.md), [Migration Strategies](../patterns/implementation/migration-strategies.md) |
| Law 5: Orchestration | [Multi-Agent Orchestration](../patterns/architecture/multi-agent-orchestration.md), [Parallel Tool Execution](../patterns/operations/parallel-tool-execution.md) |
| Law 6: Speed/Knowledge | [Lessons Learned](../patterns/operations/lessons-learned-and-implementation-challenges.md), [Performance at Scale](../patterns/operations/performance-at-scale.md) |

## The Laws as a System

The six laws are not independent — they form a reinforcing system:

```
Law 1 (Context) ←→ Law 3 (Architecture)
  Context architecture IS the architecture decision that matters most.

Law 2 (Judgment) ←→ Law 5 (Orchestration)
  Human judgment determines orchestration layer selection;
  orchestration skill IS the new form of engineering judgment.

Law 4 (Delete) ←→ Law 6 (Speed/Knowledge)
  Building to delete requires knowing what's durable (knowledge)
  vs what's transient (speed-optimized tooling).

Law 3 (Architecture) ←→ Law 6 (Speed/Knowledge)
  "Harness engineering" is the intersection — the harness IS
  the compounding mechanism that converts speed into knowledge.
```

When an AI initiative struggles, the binding constraint is usually one of these six. Identify which law is being violated, and you have your diagnosis.
