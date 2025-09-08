# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is QED ("Quod Erat Demonstrandum" - "that which is demonstrated") - a practitioner's knowledge base for AI-assisted development. It provides evidence-based patterns for integrating AI coding assistants like Claude Code into client projects and production environments.

QED follows a rigorous four-tier knowledge management system, promoting only proven patterns to authoritative guidance.

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

QED uses a structured knowledge management approach:

### Core Directories:
- `src/` - Book content (Tier 3: Proven practices only)
- `src/analysis/` - Critical analysis documents (Tier 2: Under evaluation)
- `docs/` - Research collection (Tier 1: Raw material)
- `decisions/` - Architecture Decision Records with full rationale

### Key Files:
- `src/SUMMARY.md` - Navigation structure for three-book series
- `book.toml` - mdBook configuration for GitHub Pages
- `KNOWLEDGE_INTAKE.md` - Framework for evaluating new patterns
- `decisions/DECISION_REGISTRY.md` - Searchable index of all ADRs

### Content Structure:
- **Book 1**: Foundation Patterns - Client-safe AI integration strategies
- **Book 2**: Production Frameworks - Risk assessment and selection guidance  
- **Book 3**: Advanced Integration - Enterprise patterns and scaling

## Writing Guidelines

### Style
- **Practitioner-focused**: Written by consultants for consultants, addressing real client work constraints
- **Evidence-based**: Every recommendation backed by documented client project outcomes
- **Risk-aware**: Explicit discussion of trade-offs, limitations, and failure modes
- **Client-safe**: Consider security, privacy, and professional liability in all guidance
- **Direct and practical**: No marketing language or theoretical speculation
- **Systematic**: Use established evaluation frameworks and decision matrices
- **Transparent**: Document reasoning behind all framework choices and tool selections

### Hard Rules
- **NO unproven claims**: Only document patterns successfully used in client projects
- **NO framework evangelism**: Present objective analysis, not advocacy for specific tools
- **NO theoretical patterns**: If it hasn't been tested with real clients, it doesn't belong in Tier 3
- **NO vendor marketing**: Maintain independence from tool vendors and framework authors
- **NO security handwaving**: Always address data privacy and code security implications
- **NO false certainty**: Document known limitations and failure modes honestly
- **Evidence required**: Every "proven practice" must include implementation outcomes and metrics

## Knowledge Management Approach

QED uses a systematic four-tier approach to knowledge management:

### Tier 1: Research Collection (`docs/`)
- Raw articles, blog posts, framework documentation
- No editorial filter - collect everything potentially relevant
- Priority tagging for analysis queue management
- Source attribution and capture context

### Tier 2: Critical Analysis (`src/analysis/`)  
- Professional evaluation using risk assessment matrices
- Client context analysis (Conservative/Moderate/Aggressive profiles)
- Implementation feasibility and ROI projections
- Structured analysis templates with clear recommendations

### Tier 3: Proven Practice (`src/` main content)
- Only patterns successfully used in client projects
- Documented outcomes, metrics, and lessons learned
- Risk-mitigated approaches with known limitations
- QED standard: "that which is demonstrated"

### Decision Records (`decisions/`)
- Architecture Decision Records (ADRs) for QED application development only
- Decisions about mdBook, GitHub Pages, project structure, etc.
- NOT for evaluating content (articles, frameworks, patterns) being documented
- Content evaluation belongs in Tier 2 analysis files
- Full rationale including alternatives considered and rejected

## Content Development Process

1. **Research capture**: Save interesting patterns to `docs/` with priority tags
2. **Analysis creation**: Evaluate high-priority items using structured templates in `src/analysis/`
3. **Experimental validation**: Test promising patterns on client projects
4. **Practice promotion**: Move validated patterns to main content with evidence
5. **Continuous review**: Update based on new project outcomes and client feedback

### Important Distinction
- **ADRs** (`decisions/`): Only for QED application architecture (mdBook setup, CI/CD, project structure)
- **Content evaluation**: Use Tier 2 analysis documents in `src/analysis/`
- Example: Choosing mdBook = ADR; Evaluating Google Nano Banana = Analysis document

When creating content, always consider the client impact and maintain the evidence-based standard that makes QED valuable to practitioners.