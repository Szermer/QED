# Claude Code Deep Dive - mdbook Guidelines

This repository contains documentation about Claude Code's architecture being structured as a book using mdbook or similar tool.

## Documentation Structure
- Content organized in chapters and sections for logical reading flow
- Maintain consistent hierarchy with clear parent-child relationships
- Use SUMMARY.md for book navigation structure

## Formatting Guidelines
- Follow standard Markdown formatting for code blocks, lists, and emphasis
- Use relative links for cross-references between book sections
- Include mermaid diagrams for visual explanations
- Use descriptive filenames with hyphens instead of spaces
- Maintain consistent heading structure (#, ##, ###)

## Navigation
- Ensure chapters flow logically from introduction to advanced topics
- Include navigation links at bottom of pages where appropriate
- Maintain table of contents for easy reference

## Writing Style
- Technical but relaxed: Clear explanations without formal language, avoiding buzzwords or unnecessary complexity
- Concise and direct: Minimal filler or extra detail; each sentence contributes meaningfully
- Casual yet authoritative: Written as a peer talking to other engineers—approachable but clearly knowledgeable
- No forced enthusiasm or marketing tone: Avoids phrases like "snappy," "seamless," or overly enthusiastic claims
- Markdown-friendly: Well-structured for readability, cleanly organized headings and lists, avoiding unnecessary punctuation (especially em dashes)
- IRC-inspired pragmatism: Direct and practical, straightforward phrasing reminiscent of a developer chat rather than corporate communication
- Varied article usage: Diverse use of articles ("a", "the", "this", etc.) rather than repetitive patterns

## Hard Rules
- **NO speculation**: Only document what's observable in the code. Never speculate about intentions, roadmaps, or development status.
- **NO prescriptive language**: Avoid "should", "must", "need to", "have to" when giving recommendations. Use "consider" or simply state options directly.
- **NO obvious details**: Skip mentioning basic implementation details like UTF-8 encoding or standard language features that any developer would expect.
- **NO LLM-like language**: Avoid flowery or overly formal descriptions. Write like a programmer talking to another programmer.
- **NO weasel words**: Avoid hedging language like "perhaps", "seems to", "appears to", "might be", "this approach", "this pattern", "this system", unless truly uncertain. Be direct and assertive.
- **Facts only**: Base all technical documentation on direct code evidence, not assumptions.