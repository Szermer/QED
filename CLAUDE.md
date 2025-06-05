# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an mdBook documentation project - "The Agentic Systems Series" - a comprehensive two-book guide about building AI coding assistants. It analyzes architecture patterns from Claude Code, anon-kode, and Amp to provide practical insights for engineers building production AI development tools.

The series covers everything from single-user local tools (Book 1) to collaborative enterprise platforms (Book 2).

## Common Commands

```bash
# Local development
mdbook serve        # Start local server at http://localhost:3000
mdbook build        # Build static site to book/ directory
mdbook clean        # Clean build artifacts

# Testing
mdbook test         # Test code examples in documentation
```

## Project Structure

The documentation follows mdBook conventions:
- `src/` - All markdown content files
- `src/SUMMARY.md` - Navigation structure and chapter ordering
- `book.toml` - mdBook configuration
- `amp/` - Contains analyzed source code from amp/Claude Code
- `src/second-edition/` - Book 2: Amping Up an Agentic System

Key content areas:
- **Book 1**: Core architecture patterns (reactive UI, streaming, permissions), tool systems, command systems
- **Book 2**: Collaborative architecture, enterprise features, scaling patterns, production deployment

## Writing Guidelines

### Style
- Technical but relaxed: Clear explanations without formal language, avoiding buzzwords or unnecessary complexity
- Concise and direct: Minimal filler or extra detail; each sentence contributes meaningfully
- Casual yet authoritative: Written as a peer talking to other engineers—approachable but clearly knowledgeable
- No forced enthusiasm or marketing tone: Avoids phrases like "snappy," "seamless," or overly enthusiastic claims
- Markdown-friendly: Well-structured for readability, cleanly organized headings and lists, avoiding unnecessary punctuation (especially em dashes)
- IRC-inspired pragmatism: Direct and practical, straightforward phrasing reminiscent of a developer chat rather than corporate communication
- Varied article usage: Diverse use of articles ("a", "the", "this", etc.) rather than repetitive patterns

### Hard Rules
- **NO speculation**: Only document what's observable in the code. Never speculate about intentions, roadmaps, or development status.
- **NO prescriptive language**: Avoid "should", "must", "need to", "have to" when giving recommendations. Use "consider" or simply state options directly.
- **NO obvious details**: Skip mentioning basic implementation details like UTF-8 encoding or standard language features that any developer would expect.
- **NO LLM-like language**: Avoid flowery or overly formal descriptions. Write like a programmer talking to another programmer.
- **NO weasel words**: Avoid hedging language like "perhaps", "seems to", "appears to", "might be", "this approach", "this pattern", "this system", unless truly uncertain. Be direct and assertive.
- **Facts only**: Base all technical documentation on direct code evidence, not assumptions.

## Architecture Notes

The series analyzes real implementations from multiple systems:

**Book 1 (Claude Code/anon-kode patterns):**
- Reactive UI built with Ink and Yoga for terminal interfaces
- Parallel tool execution for performance
- Permission system for safe operations
- Extensible tool architecture with standardized interfaces
- Command system with slash commands and contextual help

**Book 2 (Amp collaborative patterns):**
- Conversation management and state synchronization
- Enterprise authentication and identity management
- Real-time collaboration and team workflows
- Multi-agent orchestration and performance optimization
- Production deployment and scaling strategies

When documenting architecture patterns, reference actual source files in `amp/core/src/` for concrete examples, but generalize proprietary implementation details into reusable patterns.