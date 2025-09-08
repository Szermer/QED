# ADR: Migrate from 3-Book Structure to Taxonomy-Based Organization

**Status**: Implemented  
**Date**: 2025-09-08  
**Decision Makers**: Stephen Szermer  

## Context

QED initially used a 3-book linear structure (Foundation → Production → Advanced) that was proving inadequate for practitioners who needed to:
- Quickly assess risk levels before implementation
- Find patterns appropriate to their specific context (startup vs enterprise)
- Understand pattern relationships and dependencies
- Track pattern maturity as they evolve

The linear book structure forced artificial separation of related concepts and made it difficult for users to navigate based on their actual needs.

## Decision

Migrate to a multi-dimensional taxonomy-based structure that allows navigation by:
- **Domain** (Architecture, Implementation, Operations, Security, Team, Quality)
- **Risk Profile** (Low/Green, Managed/Yellow, High/Red)
- **Context** (Startup, Mid-Market, Enterprise, Regulated)
- **Maturity** (Experimental, Validated, Standard)

## Rationale

### Problems with 3-Book Structure
1. **Linear navigation** doesn't match how practitioners search for patterns
2. **Risk obscured** - dangerous patterns mixed with safe ones
3. **Context missing** - no differentiation between startup and enterprise needs
4. **Evolution difficult** - patterns couldn't mature without restructuring
5. **Relationships hidden** - dependencies and conflicts not visible

### Benefits of Taxonomy Structure
1. **Risk-first visibility** - Traffic light system immediately shows safety level
2. **Multi-dimensional discovery** - Find patterns through different lenses
3. **Context-aware guidance** - Different paths for different situations
4. **Natural evolution** - Patterns mature through tiers without moving files
5. **Explicit relationships** - Dependencies and conflicts documented

## Implementation

### Directory Structure
```
src/
├── patterns/           # Primary organization by domain
│   ├── architecture/
│   ├── implementation/
│   ├── operations/
│   ├── security/
│   ├── team/
│   └── quality/
├── by-risk/           # Alternative risk-based views
│   ├── low-risk/
│   ├── managed-risk/
│   └── high-risk/
├── by-context/        # Context-specific navigation
│   ├── startup/
│   ├── mid-market/
│   ├── enterprise/
│   └── regulated/
├── learning-paths/    # Guided journeys
└── case-studies/      # Real-world examples
```

### Pattern Metadata
Each pattern includes YAML frontmatter with:
- pattern_id, title, domain
- risk_profile, maturity level
- context requirements
- relationships (requires, enables, conflicts)
- validation date and context

### Migration Process
1. Created new directory structure
2. Moved ~40 files to appropriate domains
3. Added taxonomy metadata to key patterns
4. Created risk and context index pages
5. Updated SUMMARY.md for new navigation
6. Created pattern template for consistency
7. Built learning paths for different audiences

## Consequences

### Positive
- ✅ Practitioners can quickly find safe patterns for their context
- ✅ Risk is immediately visible through color coding
- ✅ Patterns can evolve without restructuring
- ✅ Multiple navigation paths serve different needs
- ✅ Dependencies prevent dangerous pattern combinations

### Negative
- ⚠️ More complex structure requires better search/filter tools
- ⚠️ Pattern metadata must be maintained
- ⚠️ Some redundancy in index pages
- ⚠️ Initial learning curve for navigation

### Mitigations
- Build search/filter UI for pattern discovery
- Automate metadata validation
- Create clear learning paths
- Provide multiple entry points

## Validation

The new structure successfully:
- Separates patterns by risk level (36 patterns categorized)
- Provides context-specific guidance (4 contexts defined)
- Maintains evidence-based tiers (Research → Analysis → Practice)
- Supports pattern evolution and relationship tracking

## References

- [QED Taxonomy Framework](../qed-taxonomy.md)
- [Pattern Template](../src/PATTERN_TEMPLATE.md)
- [Original 3-Book Structure](../src/archive/SUMMARY.md)

## Related ADRs

- [2025-01-01-mdbook-selection.md](2025-01-01-mdbook-selection.md) - Documentation platform choice
- [2025-01-02-github-pages-deployment.md](2025-01-02-github-pages-deployment.md) - Deployment strategy

## Future Considerations

1. **Search Enhancement**: Implement full-text search with taxonomy filters
2. **Visualization**: Create interactive pattern relationship diagrams
3. **Automation**: Build tools to validate pattern metadata
4. **Analytics**: Track which patterns are most accessed/successful