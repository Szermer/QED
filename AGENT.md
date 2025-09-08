# AGENT.md - Build Configuration for QED

## Project Type
This is QED ("Quod Erat Demonstrandum") - a practitioner's knowledge base for AI-assisted development using mdBook for documentation generation.

## Build Commands
- **Build**: `mdbook build` - Generate static site in `./book` directory (includes link checking)
- **Serve**: `mdbook serve` - Start local development server on http://localhost:3000
- **Clean**: `mdbook clean` - Remove generated files
- **Test**: `mdbook test` - Test code blocks in documentation
- **Link Check**: Built into `mdbook build` - Automatically checks for broken internal links

## Repository Structure
- `src/` - Book content (Tier 3: Proven practices only)
- `src/analysis/` - Critical analysis documents (Tier 2: Under evaluation)
- `docs/` - Research collection (Tier 1: Raw material)
- `decisions/` - Architecture Decision Records with full rationale
- `book.toml` - mdBook configuration for GitHub Pages deployment
- `book/` - Generated static site (after build)
- `KNOWLEDGE_INTAKE.md` - Framework for evaluating new patterns
- Custom JS/CSS: `mermaid.min.js`, `mermaid-init.js`, `custom.css`

## Content Guidelines
- **Evidence-based only**: Every recommendation must be backed by client project outcomes
- **Risk-aware**: Always discuss trade-offs, limitations, and failure modes
- **Client-focused**: Address real constraints of consultant/agency work
- **Systematic evaluation**: Use established risk matrices and decision frameworks
- **Four-tier knowledge management**: Research → Analysis → Validation → Practice
- **Decision transparency**: Document rationale for all framework and tool choices
- Target: Developers, consultants, and agencies using AI coding assistants in production

## Knowledge Management Workflow
1. **Research Collection** (`docs/`) - Save interesting articles with priority tags
2. **Critical Analysis** (`src/analysis/`) - Evaluate using risk matrices and client context
3. **Decision Records** (`decisions/`) - Document framework choices with full rationale
4. **Experimental Validation** - Test patterns on client projects with metrics collection
5. **Practice Integration** (`src/`) - Promote only validated patterns with evidence

## Dependencies
- mdBook 0.4.36+ with mdbook-mermaid preprocessor for diagrams
- GitHub Pages deployment to `szermer.github.io/QED`
- Structured templates for analysis and decision documentation
