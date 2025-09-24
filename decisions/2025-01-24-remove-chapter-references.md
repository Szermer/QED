# ADR: Remove Book-Style Chapter References

**Date**: 2025-01-24
**Status**: Implemented
**Relates to**: [2025-09-08 - Documentation Structure](2025-09-08-documentation-structure.md)

## Context

QED initially used book-style chapter numbering (e.g., "Chapter 1: From Local to Collaborative") inherited from earlier documentation approaches. This created a sequential, book-like structure that didn't align with QED's purpose as a modular pattern library and practitioner's reference guide.

## Problem

- Chapter numbering implied sequential reading order
- Pattern documentation should be standalone and reusable
- Book metaphor conflicted with pattern library concept
- Search results showed "Chapter XX" which wasn't meaningful
- Internal references to "next chapter" created false dependencies

## Decision

Remove all chapter references and transform to pattern-focused language throughout the documentation.

## Implementation

1. **Title Changes** (34 files updated):
   - Removed "Chapter XX: " prefixes from all H1 headings
   - Kept descriptive titles intact
   - Applied to patterns/, case-studies/, and second-edition/ directories

2. **Reference Updates**:
   - Changed "next chapter" → "next section" or "following pattern"
   - Changed "this chapter" → "this section" or "this pattern"
   - Changed "Chapter 1" references to pattern names

3. **Language Transformation**:
   - From: Sequential book chapters
   - To: Modular, standalone patterns
   - Emphasis on reference guide over linear narrative

## Consequences

### Positive
- Patterns are clearly standalone and reusable
- Better alignment with QED's practitioner focus
- Improved searchability (no meaningless chapter numbers)
- More professional pattern library presentation
- Easier to reference specific patterns

### Negative
- Lost explicit reading order for newcomers
- Some patterns may still have implicit dependencies
- Existing external links to chapters may break

## Examples

Before:
```markdown
# Chapter 2: Service-Oriented Architecture for AI Systems

In the next chapter, we'll explore authentication...
```

After:
```markdown
# Service-Oriented Architecture for AI Systems

The next pattern section explores authentication...
```

## Related Decisions

- Documentation Structure ADR - Original multi-book approach
- Platform Selection ADR - mdBook capabilities for pattern organization

## Files Changed

- 16 files in `src/patterns/`
- 1 file in `src/case-studies/`
- 17 files in `src/second-edition/`
- Various index and reference files updated