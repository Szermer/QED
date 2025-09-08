# QED Knowledge Management Structure

## Visual Kanban Board

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   TIER 1        │    │   TIER 2        │    │   TIER 3        │
│   Research      │───▶│   Analysis      │───▶│   Proven        │
│   Collection    │    │   (Kanban)      │    │   Practice      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Tier 1: Research Collection (`docs/tier1-research/`)

### By Priority (Workflow Management)
```
docs/tier1-research/
├── high-priority/           # Immediate analysis candidates
├── medium-priority/         # Interesting but not urgent
├── low-priority/           # Background reading
└── archive/                # Processed or irrelevant
```

### By Topic (Content Organization)
```
docs/tier1-research/by-topic/
├── ai-architecture/        # System designs, patterns
├── framework-analysis/     # Tool comparisons
├── tooling-patterns/      # Implementation practices  
├── client-patterns/       # Engagement strategies
└── security-compliance/   # Privacy, regulatory
```

## Tier 2: Critical Analysis (`src/tier2-analysis/`)

### Kanban Status Workflow
```
src/tier2-analysis/
├── in-review/             # Currently being analyzed
├── needs-validation/      # Complete but needs testing
├── ready-for-experiment/  # Ready for pilot projects
├── blocked/               # Waiting on dependencies
└── rejected/              # Unsuitable for client work
```

### By Client Risk Profile
```
src/tier2-analysis/by-risk-profile/
├── conservative-clients/   # Low-risk, proven patterns
├── moderate-clients/      # Balanced innovation
└── aggressive-clients/    # Cutting-edge patterns
```

## Tier 3: Proven Practice (`src/tier3-proven/`)

### By Book Integration Target
```
src/tier3-proven/
├── book1-foundation/      # Foundation Patterns
├── book2-production/      # Production Frameworks
├── book3-advanced/        # Advanced Integration
└── ready-for-integration/ # Ready for main book
```

## Knowledge Flow Examples

### Example 1: Context Engineering Pattern
1. **Tier 1**: `high-priority/JasonLiu_Context_Engineering_2025-08.md`
2. **Tier 2**: `ready-for-experiment/analysis-context-engineering-slash-commands-2025-09.md`  
3. **Tier 3**: (Pending client validation) → `book2-production/context-engineering-proven.md`

### Example 2: Framework Selection
1. **Tier 1**: `medium-priority/Framework_Comparison_Article.md`
2. **Tier 2**: `needs-validation/analysis-framework-selection-2025-09.md`
3. **Tier 3**: (After testing) → `book1-foundation/framework-selection-criteria.md`

## Quality Gates

### Tier 1 → Tier 2
- ✅ Relevant to client work
- ✅ Credible source
- ✅ Novel insights or patterns

### Tier 2 → Tier 3  
- ✅ Successfully used in client project
- ✅ Measurable positive outcomes
- ✅ Reproducible by others
- ✅ Risk factors understood

## Workflow Commands

### Daily Research Collection
```bash
# Save article to appropriate priority
cp "New_Pattern_Article.md" docs/tier1-research/high-priority/

# Log in research tracker
echo "$(date): New AI pattern - potential for React project" >> docs/tier1-research/research-log.md
```

### Weekly Analysis Review
```bash
# Check high priority items needing analysis
ls docs/tier1-research/high-priority/

# Create new analysis
touch src/tier2-analysis/in-review/analysis-new-pattern-$(date +%Y-%m).md
```

### Monthly Practice Updates
```bash
# Review items ready for promotion
ls src/tier2-analysis/ready-for-experiment/

# Check proven practices ready for book integration  
ls src/tier3-proven/ready-for-integration/
```

## Benefits of This Structure

1. **Visual Progress**: Clear kanban-style movement through stages
2. **Quality Control**: Explicit gates between tiers
3. **Client Focus**: Risk profile organization in Tier 2
4. **Book Integration**: Clear path from research to publication
5. **Workflow Support**: Folder structure reinforces process
6. **Archive Management**: Nothing gets lost, everything has a place

This structure transforms your knowledge management from a pile of articles into a systematic pipeline that delivers client value.