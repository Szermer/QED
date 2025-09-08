# QED Project TODO

## Current Status: Project Review and Cleanup (September 2025)

### Completed ✅
- [x] Clean up code or dead code (removed .DS_Store files, updated .gitignore)
- [x] Verify architecture and ADR compliance (confirmed alignment with existing ADRs)
- [x] Conduct appropriate tests (validated markdown structure, checked for build issues)
- [x] Visual inspection with Playwright (verified live site rendering at szermer.github.io/QED)
- [x] Update relevant README files (aligned main README and src/README with QED identity)

### In Progress 🔄
- [ ] Update relevant ADRs (reviewing current ADR status)
- [ ] Update TODO.md (this file - creating project status documentation)
- [ ] Review and update DECISION_REGISTRY.md (ensure all ADRs are properly indexed)
- [ ] Review and update C4_ARCHITECTURE.md (verify architecture documentation is current)
- [ ] Cross-link all relevant ADRs (ensure proper references between decisions)

### Pending 📋
- [ ] Apply GitHub Issue labels (create/update repository labels for project management)
- [ ] Push to origin (commit and push all changes)
- [ ] Monitor GitHub workflows (verify MCP and build workflows are functioning)

## Current Project Priorities

### High Priority
1. **Complete project review checklist** - Systematic cleanup and verification
2. **Ensure documentation consistency** - All README files reflect QED identity
3. **Verify architecture alignment** - Confirm ADRs and documentation match implementation

### Medium Priority
1. **Enhance knowledge management workflow** - Improve tier progression processes
2. **Expand proven practices** - Add more validated client patterns
3. **Improve navigation and cross-references** - Better linking between concepts

### Low Priority
1. **Visual design improvements** - Enhanced CSS and layout
2. **Interactive features** - Search, filtering, tagging
3. **Community features** - Contribution guidelines, feedback mechanisms

## Recent Major Changes
- Established QED's unique practitioner identity (September 2025)
- Integrated Gerred's "Building an Agentic System" knowledge into analysis tier
- Fixed mdbook linkcheck errors throughout documentation
- Reorganized knowledge management structure for clarity

## Next Sprint Goals
1. Complete current review checklist
2. Ensure all documentation reflects QED practitioner focus
3. Verify all cross-references and links are working
4. Push stable version to production

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
*Last updated: September 8, 2025*