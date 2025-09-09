# Archive

Previous documentation structures and deprecated patterns preserved for historical reference.

## Previous Structure (Pre-Taxonomy Migration)

Before the taxonomy-based reorganization on 2025-09-08, QED used a three-book structure:

### Book 1: Foundation Patterns
Focused on client-safe AI integration strategies for consultants.
- Basic patterns and principles
- Low-risk implementations
- Getting started guides

### Book 2: Production Frameworks
Provided risk assessment and framework selection guidance.
- Framework comparisons
- Production deployment patterns
- Scaling strategies

### Book 3: Advanced Integration
Covered enterprise patterns and complex scaling scenarios.
- Multi-agent systems
- Enterprise integration
- Advanced architectures

## Migration Rationale

The three-book structure was replaced because:

1. **Linear progression didn't match usage patterns** - Users needed to jump between books based on specific needs
2. **Risk profiles crossed book boundaries** - High-risk patterns appeared in "Foundation" while low-risk patterns were in "Advanced"
3. **Context was more important than progression** - Startups and enterprises needed different patterns regardless of "level"
4. **Discovery was difficult** - Finding relevant patterns required checking multiple books

See ADR: Taxonomy-Based Structure (decisions/2025-09-08-taxonomy-based-structure.md) for full details.

## Deprecated Patterns

### Pattern: Monolithic AI Assistant
**Deprecated**: January 2025
**Reason**: Replaced by modular, composable patterns
**Replacement**: [Multi-Agent Orchestration](../patterns/architecture/multi-agent-orchestration.md)

### Pattern: Direct API Key Management
**Deprecated**: December 2024
**Reason**: Security and scalability concerns
**Replacement**: [Authentication and Identity](../patterns/security/authentication-identity.md)

### Pattern: Local-Only Development
**Deprecated**: November 2024
**Reason**: Team collaboration requirements
**Replacement**: [From Local to Collaborative](../patterns/team/local-to-collaborative.md)

## Historical Documents

### Original Manifesto (September 2024)
The original QED vision document emphasized:
- Practitioner-first approach
- Evidence-based methodology
- Client safety and risk awareness
- No framework evangelism

These principles remain core to QED but are now expressed through:
- [Philosophy and Mindset](../overview-and-philosophy.md)
- [Risk Assessment](../patterns/quality/risk-assessment.md)
- [Pattern Template](../PATTERN_TEMPLATE.md)

### Early Evaluation Framework (October 2024)
The initial four-tier knowledge management system:
1. Research Collection
2. Critical Analysis  
3. Proven Practice
4. Decision Records

This framework evolved into the current taxonomy system with:
- Domain classification
- Risk profiles
- Context tags
- Maturity levels

## Lessons from Previous Structures

### What Worked
- Clear progression path for beginners
- Separation of concerns by complexity
- Strong emphasis on evidence

### What Didn't Work
- Rigid linear structure
- Difficult cross-referencing
- Inconsistent risk classification
- Poor discoverability

### What We Learned
- Users need multiple navigation paths
- Context matters more than complexity
- Risk should be explicitly classified
- Patterns need rich metadata

## Accessing Historical Content

Previous versions of the documentation are available in git history:

```bash
# View the last commit before taxonomy migration
git checkout 667e726^

# View specific file history
git log --follow src/SUMMARY.md

# Compare old and new structures
git diff 667e726^ HEAD -- src/SUMMARY.md
```

## Future Considerations

As QED continues to evolve, we anticipate:

### Potential Enhancements
- Interactive pattern discovery tools
- Automated pattern recommendations
- Dynamic risk assessment calculators
- Pattern dependency visualization

### Structural Evolution
- Graph-based navigation
- AI-powered search and filtering
- Personalized learning paths
- Community-contributed patterns

## Contributing Historical Context

If you have historical context about QED's evolution:
1. Document specific dates and decisions
2. Provide evidence and rationale
3. Link to relevant commits or issues
4. Submit via repository pull request

---

*This archive preserves QED's evolution for future reference and learning.*