# Tier 2: Critical Analysis

**Status**: Under professional evaluation  
**Standard**: Your expert assessment with client context

## Kanban Status Folders

### `in-review/`
Analysis documents currently being written or reviewed. Items move here from Tier 1.

### `needs-validation/` 
Analysis complete but needs real-world testing or additional evidence before recommendation.

### `ready-for-experiment/`
Analysis shows promise. Ready for controlled testing on internal or low-risk client projects.

### `blocked/`
Analysis stalled due to missing information, conflicting evidence, or external dependencies.

### `rejected/`
Analysis complete. Pattern determined to be unsuitable for client work. Keep for reference.

## Client Risk Profile Folders

### `conservative-clients/`
Analysis focused on low-risk, proven patterns suitable for risk-averse enterprise clients.

### `moderate-clients/`
Balanced risk-reward analysis for clients open to tested innovations with clear ROI.

### `aggressive-clients/`
Analysis of cutting-edge patterns for innovation-focused clients willing to accept higher risk.

## Analysis Document Template

Use filename: `analysis-[topic]-[YYYY-MM].md`

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

## Workflow
1. **Create**: New analysis in `in-review/`
2. **Complete**: Move to appropriate status folder
3. **Promote**: Ready patterns move to Tier 3
4. **Archive**: Rejected patterns stay for reference