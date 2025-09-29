# ADR-2025-09-29: Tier 1 Research mdBook Integration

## Status
Accepted and Implemented

## Context
The QED knowledge management system uses a three-tier approach:
- Tier 1: Raw research collection
- Tier 2: Critical analysis
- Tier 3: Proven practices

Previously, Tier 1 articles were stored in `docs/` outside the mdBook source directory, making them inaccessible in the published documentation. Additionally, many articles contained YAML frontmatter that mdBook doesn't support, causing rendering issues.

## Problem
1. **Accessibility**: Tier 1 research articles were not searchable or viewable in the published mdBook site
2. **Formatting**: YAML frontmatter was rendering as content instead of metadata
3. **Special Characters**: Various formatting artifacts from source sites were breaking rendering
4. **404 Errors**: Links in SUMMARY.md pointed to non-existent paths

## Decision
Move all Tier 1 research articles into the `src/tier1-research/` directory and convert YAML frontmatter to markdown headers for mdBook compatibility.

## Rationale
- **Single Source of Truth**: All knowledge artifacts should be accessible through the published documentation
- **Searchability**: Users need to search across all tiers to understand the full knowledge pipeline
- **Transparency**: Showing raw research alongside analysis demonstrates the evidence-based approach
- **mdBook Limitations**: mdBook doesn't support YAML frontmatter, requiring conversion to standard markdown

## Implementation Details

### Directory Structure
```
src/
├── tier1-research/         # Raw captured articles (NEW)
│   ├── high-priority/
│   ├── medium-priority/
│   ├── low-priority/
│   └── README.md          # Explains Tier 1 status
├── analysis/              # Tier 2 critical analysis
└── patterns/              # Tier 3 proven practices
```

### Frontmatter Conversion
Before (YAML):
```yaml
---
title: "Article Title"
source: "https://example.com"
description: "Description text"
---
```

After (Markdown):
```markdown
# Article Title

**Source**: [https://example.com](https://example.com)

> Description text
```

### SUMMARY.md Integration
Added new section "Analysis Queue" with subsections:
- Tier 1: Research Collection (all priority levels)
- Tier 2: Under Evaluation (analysis documents)

## Consequences

### Positive
- All research material now searchable in published documentation
- Clear visibility into the knowledge pipeline
- Consistent formatting across all articles
- Proper attribution with source URLs preserved

### Negative
- Larger mdBook build (more files to process)
- Tier 1 articles retain original formatting inconsistencies
- Some duplication between `docs/` and `src/` until full migration

### Neutral
- Tier 1 explicitly marked as "raw research" to set expectations
- Original formatting preserved where possible for authenticity

## Related ADRs
- **ADR-2025-09-08-TAX**: Taxonomy-Based Structure Migration (established multi-tier approach)
- **ADR-2025-01-24-PAGES**: GitHub Pages Deployment (deployment infrastructure)
- **ADR-2025-01-24-CHAPTERS**: Remove Book-Style Chapter References (content organization)

## Notes
This decision reinforces QED's commitment to transparency and evidence-based practices by making the entire knowledge pipeline visible, from raw research through critical analysis to proven practices.