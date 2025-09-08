# Risk Assessment Matrix

This matrix helps evaluate AI development patterns and frameworks for client projects, balancing innovation with reliability.

## Assessment Criteria

**Risk Factors:**
- **Client Impact**: Potential for project delays or quality issues
- **Security**: Data privacy and code security implications  
- **Maintainability**: Long-term support and debugging complexity
- **Transparency**: Client understanding and audit trail clarity
- **Skill Dependency**: Team expertise requirements

**Scoring:** Low (1-3), Medium (4-6), High (7-10)

## Framework Pattern Assessment

### Task Management

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Markdown Backlogs | 2 | 1 | 2 | 3 | 1 | **Low** |
| Structured Text | 4 | 2 | 4 | 5 | 5 | **Medium** |
| Issue Systems | 2 | 3 | 3 | 2 | 2 | **Low** |

**Recommendation**: Issue systems for client work, markdown for internal projects.

### AI Guidance Patterns

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Command Libraries | 3 | 2 | 5 | 4 | 6 | **Medium** |
| Coding Standards | 2 | 1 | 2 | 3 | 2 | **Low** |
| Definition of Done | 1 | 1 | 2 | 2 | 2 | **Low** |
| Validation Hooks | 2 | 2 | 4 | 3 | 5 | **Medium** |

**Recommendation**: Start with standards and definitions. Add hooks for quality-critical projects.

### Multi-Agent Coordination

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Role Simulation | 6 | 4 | 7 | 8 | 7 | **High** |
| Swarm Parallelism | 8 | 5 | 9 | 9 | 9 | **High** |
| Repo Artifacts | 4 | 3 | 5 | 4 | 4 | **Medium** |

**Recommendation**: Avoid multi-agent patterns for client work until ecosystem matures.

### Session Management

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Terminal Orchestration | 3 | 2 | 4 | 4 | 5 | **Medium** |
| Parallel Worktrees | 2 | 1 | 3 | 3 | 6 | **Medium** |
| Parallel Containers | 4 | 3 | 6 | 5 | 7 | **Medium-High** |

**Recommendation**: Parallel worktrees for development, containers for specific isolation needs.

### Tool Integration

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| MCP Integrations | 5 | 4 | 6 | 5 | 6 | **Medium** |
| Custom Tools | 3 | 2 | 5 | 4 | 4 | **Medium** |
| Database Access | 6 | 8 | 4 | 6 | 5 | **High** |
| Testing Hooks | 2 | 1 | 3 | 2 | 4 | **Low-Medium** |

**Recommendation**: Testing hooks are essential. Custom tools for specific needs. Evaluate MCP carefully.

### Development Roles

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| AI as PM | 8 | 3 | 6 | 7 | 5 | **High** |
| AI as Architect | 7 | 4 | 7 | 6 | 6 | **High** |
| AI as Implementer | 3 | 2 | 4 | 3 | 3 | **Medium** |
| AI as QA | 5 | 3 | 4 | 4 | 4 | **Medium** |

**Recommendation**: AI implementation with human oversight. Human PM and architect roles.

### Code Delivery

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Small Diffs | 2 | 2 | 2 | 2 | 3 | **Low** |
| Feature Flags | 3 | 2 | 4 | 4 | 5 | **Medium** |
| Full Scaffolds | 7 | 4 | 6 | 5 | 4 | **Medium-High** |

**Recommendation**: Small diffs for production. Feature flags for experimentation. Scaffolds for prototyping only.

### Context Preservation

| Pattern | Client Impact | Security | Maintainability | Transparency | Skill Dependency | Overall Risk |
|---------|---------------|----------|-----------------|--------------|------------------|--------------|
| Documentation | 1 | 1 | 2 | 1 | 2 | **Low** |
| Persistent Memory | 3 | 3 | 4 | 4 | 5 | **Medium** |
| Session Continuity | 4 | 3 | 5 | 5 | 6 | **Medium** |

**Recommendation**: Documentation is essential. Memory and continuity provide efficiency gains.

## Client Project Risk Profiles

### Conservative (Financial, Healthcare, Government)
- **Use**: Issue systems, coding standards, small diffs, documentation
- **Avoid**: Multi-agent, AI roles, full scaffolds, database access
- **Evaluate**: Testing hooks, custom tools, feature flags

### Moderate (Standard Business Applications)
- **Use**: All low-risk patterns, selective medium-risk adoption
- **Avoid**: High-risk patterns without explicit client approval
- **Experiment**: MCP integrations, validation hooks, parallel workflows

### Aggressive (Startups, Internal Tools, Prototyping)
- **Use**: All patterns based on technical merit
- **Experiment**: Multi-agent coordination, full scaffolds, AI roles
- **Monitor**: Performance, quality, and maintainability closely

## Decision Framework

1. **Assess Client Risk Tolerance**: Conservative, Moderate, or Aggressive
2. **Evaluate Pattern Risk**: Use matrix scores
3. **Consider Team Capability**: Factor in skill dependency scores
4. **Start Conservative**: Begin with low-risk patterns
5. **Iterate Carefully**: Add complexity only with proven value
6. **Document Decisions**: Maintain rationale for pattern choices

## Red Flags

**Immediate Stop Conditions:**
- AI making architectural decisions without human review
- Multi-agent systems in production without extensive testing
- Direct database access without security review
- Client deliverables generated without human validation
- Missing audit trails for AI-generated code

**Warning Signs:**
- Increasing debugging time for AI-generated code
- Client confusion about AI involvement in project
- Team dependency on complex frameworks
- Reduced code quality or test coverage
- Difficulty explaining AI decisions to stakeholders