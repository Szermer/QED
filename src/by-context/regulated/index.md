# Regulated Industries Patterns

Patterns for organizations in regulated industries (healthcare, finance, government) with strict compliance requirements.

## Compliance Patterns

Regulated industries require:
- Data residency and sovereignty
- Audit trails for all operations
- Strict access controls and data classification
- Compliance with industry-specific regulations (HIPAA, PCI-DSS, SOC2)

## Recommended Patterns

### Security & Compliance
- [The Permission System](../../patterns/security/the-permission-system.md) - Mandatory access controls
- [Authentication and Identity](../../patterns/security/authentication-identity.md) - Multi-factor authentication
- [Sharing and Permissions](../../patterns/security/sharing-permissions.md) - Data classification enforcement

### Architecture
- [Core Architecture](../../patterns/architecture/core-architecture.md) - Compliance-ready foundation
- [Thread Management at Scale](../../patterns/architecture/thread-management.md) - Audit trail preservation

### Operations
- [Observability and Monitoring](../../patterns/operations/observability-monitoring.md) - Compliance monitoring
- [Deployment Guide](../../patterns/operations/deployment-guide.md) - Secure deployment practices

### Quality
- [Risk Assessment](../../patterns/quality/risk-assessment.md) - Regulatory risk evaluation

## Key Considerations

- **Data residency** - Ensure data remains in compliant jurisdictions
- **Audit everything** - Maintain comprehensive logs for all operations
- **Zero-trust security** - Assume breach and minimize blast radius
- **Regular compliance audits** - Continuous validation of controls
- **Vendor assessment** - Ensure all third-party services meet compliance requirements

## Industry-Specific Guidance

### Healthcare (HIPAA)
- PHI data classification and handling
- Business Associate Agreements (BAAs)
- Minimum necessary access principles

### Financial Services (PCI-DSS, SOX)
- Payment card data isolation
- Financial audit trails
- Separation of duties

### Government (FedRAMP, NIST)
- Security control baselines
- Continuous monitoring
- Incident response procedures