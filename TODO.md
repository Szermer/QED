# QED Project TODO

## Current Status: Taxonomy Migration Complete (2025-09-09)

### Recently Completed ✅
- [x] **MAJOR: Fixed mdbook-linkcheck build failures** (2025-09-09)
  - Removed accidentally committed node_modules from git
  - Fixed all broken links in SUMMARY.md after taxonomy migration
  - Created missing index.md files for navigation sections
  - Updated book.toml linkcheck configuration
  - Verified successful GitHub Actions deployment
- [x] **MAJOR: Migrated from 3-book structure to taxonomy-based organization** (2025-09-08)
  - Created comprehensive pattern taxonomy with multi-dimensional classification
  - Reorganized ~40 patterns into domain-based structure
  - Added risk-based navigation (Low/Managed/High)
  - Created context-specific guides (Startup/Enterprise/Regulated)
  - Built learning paths and pattern template
  - Created ADR-2025-09-08-TAX for taxonomy migration
- [x] Comprehensive project cleanup and verification (2025-09-09)
  - Cleaned up code and removed dead code
  - Verified architecture and ADR compliance
  - Conducted tests (mdbook build and test)
  - Visual inspection with Playwright (confirmed site at szermer.github.io/QED)
  - Updated all relevant README files
  - Cross-linked ADRs appropriately

### In Progress 🔄
- [ ] Apply GitHub Issue labels for project management
- [ ] Monitor GitHub Actions workflows for stability

## Current Project Priorities

### High Priority
1. **Process new knowledge intake** - Google Gemini Nano Banana evaluation completed (Tier 2)
2. **Create pattern evaluation ADR** - Document decision process for tool-specific assessments
3. **Expand Tier 2 analysis collection** - Continue systematic evaluation of AI development patterns

### Medium Priority
1. **Enhance knowledge management workflow** - Improve tier progression processes
2. **Expand proven practices** - Add more validated client patterns
3. **Improve navigation and cross-references** - Better linking between concepts

### Low Priority
1. **Visual design improvements** - Enhanced CSS and layout
2. **Interactive features** - Search, filtering, tagging
3. **Community features** - Contribution guidelines, feedback mechanisms

## Recent Major Changes
- **Taxonomy-based structure migration** (2025-09-08/09)
  - Replaced linear 3-book structure with multi-dimensional navigation
  - Implemented traffic light risk system (Green/Yellow/Red)
  - Created domain-based organization (Architecture/Implementation/Operations/Security/Team/Quality)
  - Fixed critical mdbook-linkcheck build failures
  - Successfully deployed to GitHub Pages
- **Knowledge intake automation** (2025-09-08)
  - Established systematic evaluation pipeline with Jina Reader API
  - Added Google Gemini Nano Banana as first Tier 2 analysis
  - Demonstrated risk assessment framework in practice
- **QED identity establishment** (September 2025)
  - Positioned as practitioner's guide for AI development patterns
  - Evidence-based approach with 4-tier knowledge management
  - Client-safe patterns with explicit risk profiles

## Next Sprint Goals
1. Expand Tier 2 analysis collection with more tool evaluations
2. Add more validated patterns from recent client projects
3. Enhance search and filtering capabilities
4. Create interactive pattern relationship diagrams

## Architecture Notes
- QED uses 4-tier knowledge management: Research → Analysis → Decision → Practice
- All recommendations must be backed by client project evidence
- Risk-aware approach with explicit trade-off discussions
- mdBook with GitHub Pages deployment
- Mermaid diagrams for architecture visualization

## Dependencies
- mdBook 0.4.36+ with linkcheck and Mermaid preprocessor
- GitHub Actions for automated deployment
- Live site deployment to szermer.github.io/QED

---
*Last updated: 2025-09-09*