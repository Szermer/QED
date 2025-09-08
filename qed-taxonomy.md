# QED Pattern Taxonomy Framework

## Primary Classification Dimensions

### 1. PROBLEM DOMAIN
*What challenge does this pattern address?*

#### Architecture & Design
- System boundaries and AI integration points
- Context management strategies
- State and memory patterns
- API design for AI services
- Microservices vs monolithic AI integration

#### Implementation & Development
- Prompt engineering techniques
- Code generation workflows
- Testing AI-assisted code
- Debugging AI outputs
- Version control for AI artifacts

#### Operations & Maintenance
- Monitoring AI system health
- Performance optimization
- Cost management
- Update and migration strategies
- Incident response for AI failures

#### Security & Compliance
- Data privacy patterns
- Audit trail implementation
- Access control for AI tools
- Compliance documentation
- Vulnerability assessment

#### Team & Process
- AI tool adoption strategies
- Knowledge transfer methods
- Code review protocols
- Skill development paths
- Client communication patterns

#### Quality & Validation
- Output verification methods
- Acceptance criteria for AI work
- Regression prevention
- Quality metrics and KPIs
- User acceptance testing

### 2. RISK PROFILE
*What's at stake if this goes wrong?*

#### Low Risk (Green)
- Reversible changes
- Non-critical systems
- Internal tools only
- No data exposure
- Clear rollback path

#### Managed Risk (Yellow)
- Client-facing but non-critical
- Requires specific safeguards
- Limited data exposure
- Needs approval process
- Documented contingencies

#### High Risk (Red)
- Production critical systems
- Regulatory implications
- Financial impact
- Data privacy concerns
- Irreversible changes

### 3. MATURITY LEVEL
*How proven is this pattern?*

#### Experimental (Tier 1)
- Theoretical or single-case
- Unvalidated in production
- Bleeding edge techniques
- High uncertainty

#### Validated (Tier 2)
- Multiple successful cases
- Known limitations documented
- Specific context requirements
- Measurable outcomes

#### Standard Practice (Tier 3)
- Industry-wide adoption
- Battle-tested across contexts
- Clear best practices
- Predictable results

### 4. CONTEXT REQUIREMENTS
*Where can this be applied?*

#### Organizational Scale
- **Startup** (<10 developers): High agility, low process
- **Mid-market** (10-100): Some process, mixed expertise
- **Enterprise** (100+): Heavy process, specialized roles
- **Agency/Consultancy**: Multiple clients, varied contexts

#### Industry Constraints
- **Unregulated**: Tech, media, e-commerce
- **Lightly regulated**: General business
- **Heavily regulated**: Finance, healthcare, government
- **Safety-critical**: Aviation, medical devices, infrastructure

#### Technical Prerequisites
- **AI Tools Required**: Specific tools/versions
- **Infrastructure Needs**: Cloud, on-prem, hybrid
- **Skill Requirements**: Junior, senior, specialist
- **Integration Complexity**: Standalone, system-wide

### 5. TEMPORAL CHARACTERISTICS
*How does time affect this pattern?*

#### Lifecycle Stage
- **Exploration**: Research and discovery
- **Pilot**: Proof of concept
- **Implementation**: Active development
- **Production**: Live operation
- **Evolution**: Scaling and optimization
- **Sunset**: Deprecation and migration

#### Stability Window
- **Volatile** (weeks): Rapid tool changes
- **Fluid** (months): Evolving best practices
- **Stable** (quarters): Established patterns
- **Persistent** (years): Fundamental principles

### 6. VALUE DELIVERY
*What kind of value does this create?*

#### Value Type
- **Efficiency**: Time/cost reduction
- **Quality**: Error reduction, consistency
- **Innovation**: New capabilities
- **Risk Mitigation**: Avoiding problems
- **Compliance**: Meeting requirements
- **Knowledge**: Learning and growth

#### Measurement Approach
- **Quantitative**: Metrics, KPIs, benchmarks
- **Qualitative**: Satisfaction, confidence
- **Comparative**: Before/after, A/B testing
- **Observational**: Behavior changes

## Secondary Classification Tags

### Pattern Relationships
- **Prerequisite for**: [Other patterns that depend on this]
- **Depends on**: [Patterns this requires]
- **Conflicts with**: [Mutually exclusive patterns]
- **Enhances**: [Patterns this improves]
- **Alternative to**: [Different approaches to same problem]

### Implementation Characteristics
- **Adoption Effort**: Trivial / Moderate / Significant
- **Maintenance Burden**: Low / Medium / High
- **Reversibility**: Easy / Possible / Difficult
- **Documentation Needs**: Minimal / Standard / Extensive

### Failure Modes
- **Common Pitfalls**: Known failure patterns
- **Warning Signs**: Early indicators of problems
- **Recovery Strategies**: How to fix when it goes wrong
- **Prevention Measures**: How to avoid failures

## Taxonomy Application Examples

### Example 1: "AI Code Review Protocol"
- **Domain**: Team & Process
- **Risk**: Managed (Yellow)
- **Maturity**: Validated (Tier 2)
- **Context**: Mid-market to Enterprise
- **Lifecycle**: Implementation to Production
- **Value**: Quality + Risk Mitigation

### Example 2: "Context Window Optimization"
- **Domain**: Architecture & Design
- **Risk**: Low (Green)
- **Maturity**: Standard Practice (Tier 3)
- **Context**: All scales, tool-specific
- **Lifecycle**: Implementation
- **Value**: Efficiency + Quality

### Example 3: "AI-Generated Code in Regulated Industries"
- **Domain**: Security & Compliance
- **Risk**: High (Red)
- **Maturity**: Experimental (Tier 1)
- **Context**: Heavily regulated only
- **Lifecycle**: Pilot
- **Value**: Compliance + Innovation

## Usage Guidelines

### For Filing New Patterns
1. Identify primary domain (must choose one)
2. Assess risk profile honestly
3. Determine maturity based on evidence
4. Map context requirements
5. Add relationship tags
6. Document failure modes

### For Searching Patterns
Users should be able to filter by:
- "Show me all Low Risk patterns for Startups"
- "What Implementation patterns are Standard Practice?"
- "Which patterns work in Regulated industries?"
- "What are the prerequisites for pattern X?"

### For Pattern Evolution
Track progression through:
- Maturity levels (Experimental → Validated → Standard)
- Risk reduction (High → Managed → Low)
- Context expansion (Specific → General)
- Relationship changes (standalone → integrated)

## Metadata Template

```yaml
pattern_id: unique-identifier
title: Clear, searchable name
domain: Architecture|Implementation|Operations|Security|Team|Quality
risk_profile: Low|Managed|High
maturity: Experimental|Validated|Standard
contexts:
  scale: [Startup, Mid-market, Enterprise, Agency]
  regulation: [Unregulated, Light, Heavy, Critical]
  prerequisites:
    tools: []
    skills: []
    infrastructure: []
lifecycle_stage: [Exploration, Pilot, Implementation, Production, Evolution, Sunset]
stability: Volatile|Fluid|Stable|Persistent
value_type: [Efficiency, Quality, Innovation, Risk, Compliance, Knowledge]
relationships:
  requires: []
  enables: []
  conflicts: []
  alternatives: []
last_validated: YYYY-MM-DD
validation_context: "Client type and project"
```