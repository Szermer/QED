# QED Taxonomy Guide

Comprehensive classification system for AI development patterns.

## Domain Classification

Patterns are organized by functional domain:

### Architecture & Design
Core system design patterns and architectural decisions.
- System structure and components
- Design patterns and principles
- Scalability and performance architecture

### Implementation & Development
Practical implementation patterns and development practices.
- Coding patterns and techniques
- Framework usage and integration
- Development workflows

### Operations & Maintenance
Production operations and system maintenance patterns.
- Deployment and scaling
- Monitoring and observability
- Performance optimization

### Security & Compliance
Security patterns and compliance requirements.
- Authentication and authorization
- Data protection and privacy
- Regulatory compliance

### Team & Process
Collaboration patterns and team processes.
- Team workflows and communication
- Knowledge sharing and documentation
- Organizational integration

### Quality & Validation
Quality assurance and validation patterns.
- Testing strategies
- Risk assessment and mitigation
- Quality metrics and standards

## Risk Profile Classification

Patterns are classified by risk level using a traffic light system:

### 🟢 Low Risk (Green)
**Characteristics:**
- Well-established patterns
- Minimal security implications
- Easy to reverse or modify
- Suitable for all contexts

**Examples:**
- Documentation generation
- Code formatting
- Simple refactoring

### 🟡 Managed Risk (Yellow)
**Characteristics:**
- Requires some expertise
- Moderate security considerations
- Needs monitoring and controls
- Context-dependent implementation

**Examples:**
- Team collaboration patterns
- Integration with existing systems
- Performance optimization

### 🔴 High Risk (Red)
**Characteristics:**
- Complex implementation
- Significant security implications
- Difficult to reverse
- Requires extensive validation

**Examples:**
- Multi-agent orchestration
- Production deployment patterns
- Compliance implementations

## Context Classification

Patterns are tagged for organizational context:

### Startup Context
**Characteristics:**
- Rapid iteration focus
- Minimal governance
- Resource constraints
- High risk tolerance

**Pattern Selection:**
- Prioritize velocity
- Minimize overhead
- Focus on MVP
- Embrace experimentation

### Mid-Market Context
**Characteristics:**
- Balancing growth and stability
- Emerging governance needs
- Team scaling challenges
- Moderate risk tolerance

**Pattern Selection:**
- Gradual process introduction
- Team collaboration focus
- Scalability planning
- Selective governance

### Enterprise Context
**Characteristics:**
- Complex governance requirements
- Multiple stakeholder management
- Integration complexity
- Low risk tolerance

**Pattern Selection:**
- Compliance first
- Comprehensive documentation
- Change management focus
- Proven patterns only

### Regulated Industries
**Characteristics:**
- Strict compliance requirements
- Audit trail necessity
- Data sovereignty concerns
- Zero risk tolerance

**Pattern Selection:**
- Regulatory compliance mandatory
- Security by default
- Extensive validation
- Conservative approach

## Maturity Classification

Patterns progress through maturity levels:

### Experimental
**Status:** Under active development
- Limited production usage
- Rapid changes expected
- Early adopter feedback
- High uncertainty

### Emerging
**Status:** Gaining adoption
- Some production usage
- Stabilizing interfaces
- Growing community
- Moderate confidence

### Validated
**Status:** Production proven
- Widespread usage
- Stable interfaces
- Well-documented
- High confidence

### Mature
**Status:** Industry standard
- Universal adoption
- Extensive tooling
- Best practices established
- Very high confidence

## Pattern Metadata Structure

Each pattern includes standardized metadata:

```yaml
---
pattern_id: unique-identifier
title: Human-readable title
domain: Architecture|Implementation|Operations|Security|Team|Quality
risk_profile: Low|Managed|High
maturity: Experimental|Emerging|Validated|Mature
contexts:
  - startup
  - mid_market
  - enterprise
  - regulated
tags:
  - collaboration
  - automation
  - security
dependencies:
  - pattern_id_1
  - pattern_id_2
author: Original author
date_created: YYYY-MM-DD
date_updated: YYYY-MM-DD
version: 1.0.0
---
```

## Using the Taxonomy

### For Pattern Discovery

1. **Start with context** - Identify your organizational context
2. **Consider risk tolerance** - Determine acceptable risk level
3. **Browse by domain** - Find patterns in relevant domains
4. **Check maturity** - Prefer validated/mature patterns
5. **Review dependencies** - Ensure prerequisites are met

### For Pattern Documentation

1. **Use the template** - Start with [Pattern Template](PATTERN_TEMPLATE.md)
2. **Apply metadata** - Include all classification fields
3. **Be specific** - Clear problem and solution statements
4. **Include examples** - Practical implementation guidance
5. **Document trade-offs** - Honest assessment of limitations

### For Pattern Evaluation

1. **Risk assessment** - Evaluate against risk profile
2. **Context fit** - Match to organizational needs
3. **Maturity check** - Consider stability requirements
4. **Dependency analysis** - Ensure feasibility
5. **ROI calculation** - Estimate implementation value

## Evolution and Governance

### Pattern Lifecycle

1. **Proposal** - New pattern identified
2. **Evaluation** - Initial assessment and classification
3. **Experimental** - Limited testing and feedback
4. **Validation** - Broader adoption and refinement
5. **Maturity** - Widespread usage and stability
6. **Deprecation** - Obsolescence and replacement

### Classification Updates

Taxonomy classifications are updated based on:
- Production usage evidence
- Community feedback
- Security assessments
- Compliance reviews
- Performance metrics

### Contribution Guidelines

When contributing patterns:
1. Use standardized metadata format
2. Provide evidence for classifications
3. Include implementation examples
4. Document known limitations
5. Reference related patterns

## Quick Reference

### By Risk Tolerance

**Conservative (Regulated/Enterprise):**
- Low risk patterns only
- Mature/Validated maturity
- Extensive documentation required

**Moderate (Mid-Market):**
- Low and Managed risk patterns
- Validated/Emerging maturity
- Balanced documentation

**Aggressive (Startup):**
- All risk levels acceptable
- Any maturity level
- Minimal documentation