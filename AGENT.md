# AGENT.md - Build Configuration for Agentic Systems Series

## Project Type
This is an mdBook documentation project for "The Agentic Systems Series" - a comprehensive guide to building AI coding assistants.

## Build Commands
- **Build**: `mdbook build` - Generate static site in `./book` directory (includes link checking)
- **Serve**: `mdbook serve` - Start local development server on http://localhost:3000
- **Clean**: `mdbook clean` - Remove generated files
- **Test**: `mdbook test` - Test code blocks in documentation
- **Link Check**: Built into `mdbook build` - Automatically checks for broken internal links

## Repository Structure
- `src/` - Markdown source files for the book
- `book.toml` - mdBook configuration
- `book/` - Generated static site (after build)
- Custom JS/CSS: `mermaid.min.js`, `mermaid-init.js`, `custom.css`

## Content Guidelines
- Use clear, technical writing focused on practical engineering patterns
- Include code examples and architectural diagrams using Mermaid
- Maintain consistent structure with numbered chapters and clear sections
- Focus on real-world implementations over theoretical concepts
- Target software engineers building AI-powered development tools

## Dependencies
- mdBook 0.4.36+ with mdbook-mermaid preprocessor for diagrams
- GitHub Pages deployment via workflow in `.github/workflows/mdbook.yml`
