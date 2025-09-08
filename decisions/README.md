# AI Development Decision Records (ADRs)

This directory contains Architecture Decision Records adapted for AI-assisted development patterns, capturing the reasoning behind framework choices, tool adoption, and client workflow decisions.

## Purpose

ADRs help maintain institutional knowledge about **why** specific AI development patterns were chosen, not just what was implemented. This is crucial for:

- **Client communication**: Explaining AI tool choices and risk mitigation
- **Team consistency**: Ensuring framework decisions persist across projects  
- **Future decisions**: Learning from past successes and failures
- **QED integrity**: Documenting the evidence behind "proven practices"

## ADR Structure for AI Development

Each ADR follows this template adapted for AI development contexts:

1. **Context**: Client requirements, project constraints, team capabilities
2. **Decision**: What AI pattern/framework/tool was chosen
3. **Alternatives**: Other options considered and why they were rejected
4. **Consequences**: Benefits realized, risks accepted, lessons learned
5. **Client Impact**: How this affects deliverables, timeline, quality
6. **Evidence**: Metrics, outcomes, validation data

## Naming Convention

`YYYY-MM-NN-descriptive-title.md`

Examples:
- `2025-01-01-claude-code-framework-selection.md`
- `2025-01-02-mcp-integration-approach.md`
- `2025-01-03-multi-agent-rejection-decision.md`

## Decision Categories

### Framework Selection ADRs
- AI coding assistant tool choices (Claude Code, Cursor, etc.)
- Framework pattern adoption (command systems, multi-agent, etc.)
- Integration architecture decisions

### Client Workflow ADRs  
- Risk tolerance assessment approaches
- Communication patterns with clients about AI usage
- Quality assurance and review processes

### Tool Integration ADRs
- MCP server selections and configurations
- Custom tool development vs. off-the-shelf
- Testing and validation frameworks

### Process ADRs
- Knowledge intake and evaluation workflows
- Experimental validation approaches
- Documentation and handoff standards

## Current ADRs

See [DECISION_REGISTRY.md](DECISION_REGISTRY.md) for a searchable index of all decisions.

## Contributing New ADRs

1. **Use the template**: Copy `adr-template.md`
2. **Number sequentially**: Next available YYYY-MM-NN number
3. **Include evidence**: Metrics, client feedback, implementation results
4. **Update registry**: Add entry to searchable index
5. **Cross-reference**: Link to related QED content and analysis documents

## ADR Lifecycle

### Status Values
- **Proposed**: Decision under consideration
- **Accepted**: Decision implemented and validated  
- **Superseded**: Replaced by newer decision (with reference)
- **Deprecated**: No longer recommended but still documented

### Review Process
- **Quarterly reviews**: Assess ADR currency and relevance
- **Project retrospectives**: Update with actual outcomes
- **Client feedback**: Incorporate lessons learned from implementations

## Integration with QED Tiers

ADRs bridge the knowledge tiers:

**Tier 1 → Tier 2**: Research analysis references relevant ADRs
**Tier 2 → Tier 3**: Successful experiments become ADRs before promotion
**Tier 3 maintenance**: ADRs provide rationale for established practices

This ensures decision context is preserved even as practices evolve.