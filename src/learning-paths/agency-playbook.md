# Agency Playbook

A practical guide for agencies and consultancies implementing AI coding assistants for clients.

## Understanding Client Contexts

### Client Assessment Framework

Before recommending patterns, evaluate:

1. **Risk Tolerance**
   - Conservative: Established enterprises, regulated industries
   - Moderate: Growth-stage companies, competitive markets
   - Aggressive: Startups, innovation-focused organizations

2. **Technical Maturity**
   - Legacy systems and technical debt
   - Modern infrastructure and practices
   - Cloud-native and DevOps culture

3. **Organizational Readiness**
   - Developer openness to AI tools
   - Management support and budget
   - Existing innovation processes

## Client Engagement Phases

### Phase 1: Discovery and Assessment

**Patterns to Review:**
1. [Philosophy and Mindset](../overview-and-philosophy.md) - Set expectations
2. [Risk Assessment](../patterns/quality/risk-assessment.md) - Evaluate readiness
3. [Framework Selection Guide](../patterns/implementation/framework-selection-guide.md) - Tool evaluation

**Deliverables:**
- Readiness assessment report
- Risk analysis and mitigation plan
- Recommended implementation approach
- ROI projections

### Phase 2: Pilot Implementation

**Patterns to Apply:**
1. [Core Architecture](../patterns/architecture/core-architecture.md) - Foundation setup
2. [Initialization Process](../patterns/implementation/initialization-process.md) - Getting started
3. [Real World Examples](../patterns/implementation/real-world-examples.md) - Practical demos

**Deliverables:**
- Pilot environment setup
- Initial use case implementation
- Performance metrics baseline
- Pilot evaluation report

### Phase 3: Production Rollout

**Patterns to Implement:**
1. [Team Workflows](../patterns/team/team-workflows.md) - Team collaboration
2. [Deployment Guide](../patterns/operations/deployment-guide.md) - Production deployment
3. [Observability and Monitoring](../patterns/operations/observability-monitoring.md) - Operations setup

**Deliverables:**
- Production deployment
- Monitoring and analytics setup
- Training materials and documentation
- Handover and support plan

## Pattern Selection by Client Type

### Startup Clients

**Recommended Patterns:**
- Start with [low-risk patterns](../by-risk/low-risk/index.md)
- Focus on velocity and iteration
- Minimal governance overhead

**Key Patterns:**
1. [Building Your Own AMP](../patterns/implementation/building-amp.md) - Custom solutions
2. [Parallel Tool Execution](../patterns/operations/parallel-tool-execution.md) - Speed optimization
3. [Feature Flag Integration](../patterns/implementation/feature-flag-integration.md) - Rapid iteration

### Mid-Market Clients

**Recommended Patterns:**
- Balance of [managed-risk patterns](../by-risk/managed-risk/index.md)
- Focus on team collaboration
- Gradual governance introduction

**Key Patterns:**
1. [From Local to Collaborative](../patterns/team/local-to-collaborative.md) - Team adoption
2. [Authentication and Identity](../patterns/security/authentication-identity.md) - Access management
3. [Comments and Collaboration](../patterns/team/comments.md) - Team communication

### Enterprise Clients

**Recommended Patterns:**
- Start with [high-risk patterns](../by-risk/high-risk/index.md) awareness
- Comprehensive governance from day one
- Integration with existing systems

**Key Patterns:**
1. [Enterprise Integration](../patterns/team/enterprise-integration.md) - System connections
2. [The Permission System](../patterns/security/the-permission-system.md) - Access control
3. [Performance at Scale](../patterns/operations/performance-at-scale.md) - Enterprise scale

### Regulated Industry Clients

**Recommended Patterns:**
- Compliance-first approach
- Extensive audit trails
- Zero-trust security model

**Key Patterns:**
1. [Sharing and Permissions](../patterns/security/sharing-permissions.md) - Data classification
2. [Risk Assessment](../patterns/quality/risk-assessment.md) - Compliance evaluation
3. [Observability and Monitoring](../patterns/operations/observability-monitoring.md) - Audit trails

## Common Client Objections

### "Our code is too sensitive"

**Response Patterns:**
- Implement [The Permission System](../patterns/security/the-permission-system.md)
- Start with non-sensitive projects
- Use on-premise deployment options
- Demonstrate security controls and compliance

### "AI will replace our developers"

**Response Patterns:**
- Focus on augmentation, not replacement
- Show [Real World Examples](../patterns/implementation/real-world-examples.md)
- Emphasize skill development opportunities
- Demonstrate productivity gains for existing team

### "It's too expensive"

**Response Patterns:**
- Calculate ROI with metrics from pilots
- Start with small team trials
- Compare to developer salary costs
- Show [Performance Tuning](../patterns/operations/performance-tuning.md) for cost optimization

### "We don't trust AI-generated code"

**Response Patterns:**
- Implement review workflows
- Start with low-risk use cases
- Show [System Prompts and Model Settings](../patterns/implementation/system-prompts-and-model-settings.md)
- Demonstrate quality improvements

## Pricing and Packaging

### Assessment Package
- 2-week engagement
- Readiness assessment
- Tool evaluation
- Implementation roadmap

### Pilot Package
- 4-6 week engagement
- Environment setup
- Use case implementation
- Team training
- Success metrics

### Implementation Package
- 3-6 month engagement
- Full production deployment
- Integration with existing systems
- Comprehensive training
- Ongoing support setup

### Transformation Package
- 6-12 month engagement
- Organization-wide rollout
- Process transformation
- COE establishment
- Continuous optimization

## Success Metrics

### Leading Indicators
- Developer activation rate
- Tool usage frequency
- Feature adoption rate
- User satisfaction scores

### Lagging Indicators
- Velocity improvement
- Bug reduction rate
- Time to market decrease
- Developer retention improvement

## Resources and Tools

### Assessment Tools
- [Risk Assessment](../patterns/quality/risk-assessment.md) template
- [Framework Selection Guide](../patterns/implementation/framework-selection-guide.md)
- ROI calculation spreadsheet

### Implementation Resources
- [Pattern Template](../PATTERN_TEMPLATE.md) for documentation
- [Migration Strategies](../patterns/implementation/migration-strategies.md) for transitions
- [Lessons Learned](../patterns/operations/lessons-learned-and-implementation-challenges.md) for pitfall avoidance

### Case Studies
- [AMP Implementation Cases](../case-studies/amp-case-studies.md)
- [Claude Code vs Anon Kode](../patterns/implementation/claude-code-vs-anon-kode.md) comparison
- [Framework Wars Analysis](../patterns/implementation/framework-wars-analysis.md) for tool selection