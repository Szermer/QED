# QED Knowledge Intake Framework

## The Three-Tier System

### Tier 1: Research Collection (`docs/`)
**Status**: Raw research material  
**Standard**: Capture everything potentially relevant

**Process:**
1. Save articles with original filename + source attribution
2. Add brief note about why it caught your attention
3. Tag with evaluation priority (High/Medium/Low/Archive)
4. No editorial filter - collect liberally

**Example workflow:**
```bash
# Save article
cp "Framework_Wars_Article.md" docs/
# Add evaluation note
echo "Priority: High - Framework selection directly relevant to client work" >> docs/Framework_Wars_Article.md
```

### Tier 2: Critical Analysis (`src/analysis/`)
**Status**: Under professional evaluation  
**Standard**: Your expert assessment with client context

**Process:**
1. Create analysis document: `analysis-[topic]-[YYYY-MM].md`
2. Use structured template:
   - **Source material**: What you're analyzing
   - **Client context**: How this applies to your work
   - **Risk assessment**: Using your established matrices
   - **Implementation feasibility**: Cost, timeline, skills required
   - **Recommendation**: Experiment/Adopt/Monitor/Reject

**Example:**
```markdown
# Analysis: Claude Code Framework Selection (2025-01)

**Source**: Framework Wars article (Shawn's Substack)
**Client Context**: Enterprise clients with conservative risk profiles
**Risk Assessment**: Medium (requires team training, unclear long-term support)
**Recommendation**: Experiment with low-risk patterns first
```

### Tier 3: Proven Practice (`src/` main content)
**Status**: QED - "that which is demonstrated"  
**Standard**: Battle-tested with documented client success

**Promotion criteria:**
- Successfully used in real client project
- Measurable positive outcomes
- Reproducible by others
- Risk factors understood and mitigated

## Evaluation Process

### Quick Assessment (5 minutes)
For each new piece of research:
- **Relevance**: Does this apply to client work?
- **Novelty**: Is this genuinely new or rehashing known patterns?
- **Authority**: Is the source credible and experienced?
- **Actionability**: Can this be implemented practically?

### Deep Analysis (30-60 minutes)
For high-priority items:
- **Client fit analysis**: Conservative/Moderate/Aggressive risk profiles
- **Implementation analysis**: What would adoption actually require?
- **ROI projection**: Time savings vs. implementation costs
- **Risk mitigation**: How to minimize downside if it doesn't work

### Experimental Validation (Project-based)
For promising patterns:
- **Controlled testing**: Try on internal project first
- **Metrics collection**: Before/after measurements
- **Client feedback**: If used on client work
- **Documentation**: What worked, what didn't, lessons learned

## Practical Workflows

### Daily Research Collection
```bash
# Morning reading - save anything interesting
cp "New_AI_Pattern_Article.md" docs/
echo "$(date): Potential relevance to current React project" >> docs/research-log.md
```

### Weekly Analysis Review  
```bash
# Review docs/ folder for high-priority items
ls docs/ | grep -v "analyzed" 
# Create analysis for top items
touch src/analysis/analysis-new-pattern-$(date +%Y-%m).md
```

### Monthly Practice Updates
```bash
# Review successful experiments
# Update main content with proven patterns
# Archive outdated analysis documents
```

## Content Templates

### Research Capture Template
```markdown
# [Article Title]

**Source**: [URL]  
**Author**: [Name + Context]  
**Date**: [Publication Date]  
**Captured**: [Date you saved it]  
**Priority**: [High/Medium/Low]  
**Relevance**: [Brief note on why this matters]

[Original content follows...]
```

### Analysis Template  
```markdown
# Analysis: [Topic] ([YYYY-MM])

## Source Material
[What you're analyzing]

## Client Context Assessment
- **Conservative clients**: [Fit/concerns]
- **Moderate risk clients**: [Applications]  
- **Aggressive innovation**: [Opportunities]

## Risk/Benefit Analysis
[Using your established matrices]

## Implementation Considerations
- **Team skills required**: 
- **Time investment**:
- **Tool/infrastructure needs**:

## Recommendation
[Experiment/Adopt/Monitor/Reject] + reasoning

## Next Steps
[Specific actions to take]
```

### Practice Integration Template
```markdown
# [Pattern Name]: Client-Tested Implementation

## Context
[Where/when you used this successfully]

## Implementation
[Step-by-step guidance based on real experience]

## Results
[Quantitative metrics + qualitative outcomes]

## Client Communication
[How to explain this to clients]

## Lessons Learned
[What you'd do differently next time]
```

This framework lets you:
1. **Capture everything** without commitment pressure
2. **Analyze systematically** using your professional judgment  
3. **Commit only to proven patterns** that serve clients well
4. **Maintain clear distinction** between speculation and demonstrated knowledge

The key is moving slowly and deliberately from research to practice, always with client value as the filter.