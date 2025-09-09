# QED System Architecture (C4 Model)

## System Context (Level 1)

```mermaid
C4Context
    Person(practitioners, "Practitioners", "Developers, consultants, agencies using AI coding assistants")
    System(qed, "QED Knowledge Base", "Evidence-based AI development patterns and guidance")
    
    System_Ext(github_pages, "GitHub Pages", "Static site hosting")
    System_Ext(github_repo, "GitHub Repository", "Source code and content management")
    System_Ext(claude_code, "Claude Code", "AI coding assistant being analyzed")
    System_Ext(client_projects, "Client Projects", "Real-world implementations providing evidence")
    
    Rel(practitioners, qed, "Consults for AI development patterns")
    Rel(qed, github_pages, "Deployed to")
    Rel(qed, github_repo, "Managed in")
    Rel(qed, claude_code, "Analyzes and documents patterns from")
    Rel(qed, client_projects, "Evidence validated through")
```

**Purpose**: QED serves as a practitioner-focused knowledge base for AI-assisted development, providing evidence-based patterns validated through real client project implementations.

**Key Interactions**:
- Practitioners consult QED for proven AI development patterns
- Evidence is gathered from successful client project implementations
- Content is managed through GitHub and deployed via GitHub Pages
- Analysis focuses on practical tools like Claude Code and similar AI assistants

## Container Diagram (Level 2)

```mermaid
C4Container
    Person(practitioners, "Practitioners", "Developers, consultants, agencies")
    
    Container(static_site, "Static Site", "HTML/CSS/JS", "Rendered knowledge base")
    Container(content_repo, "Content Repository", "Markdown/Git", "Source content and knowledge management")
    Container(build_system, "Build System", "mdBook + GitHub Actions", "Content processing and deployment")
    
    Container_Ext(github_pages, "GitHub Pages", "Static Hosting", "Site delivery")
    Container_Ext(github_actions, "GitHub Actions", "CI/CD", "Automated building and deployment")
    
    System_Boundary(knowledge_tiers, "Knowledge Management System") {
        Container(tier1, "Tier 1: Research", "Markdown files", "Raw research collection")
        Container(tier2, "Tier 2: Analysis", "Markdown files", "Professional evaluation and analysis")
        Container(tier3, "Tier 3: Practice", "Markdown files", "Proven patterns with evidence")
        Container(decisions, "Decision Records", "ADR Markdown", "Architecture decisions with rationale")
    }
    
    Rel(practitioners, static_site, "Reads", "HTTPS")
    Rel(static_site, github_pages, "Hosted on")
    Rel(content_repo, build_system, "Triggers builds")
    Rel(build_system, github_actions, "Executes via")
    Rel(build_system, static_site, "Generates")
    
    Rel(tier1, tier2, "Analyzed into")
    Rel(tier2, tier3, "Validated and promoted to")
    Rel(tier2, decisions, "Decision rationale documented in")
    Rel(decisions, tier3, "Supports practices in")
```

**Architecture Principles**:
- **Static-first**: No server-side dependencies, maximum reliability
- **Git-based workflow**: Version control for all content and decisions
- **Evidence-driven**: Promotion between tiers requires validation
- **Transparent decision-making**: All framework choices documented with rationale

## Component Diagram (Level 3) - Content Management System

```mermaid
C4Component
    System_Boundary(content_management, "QED Content Management") {
        Component(intake_framework, "Knowledge Intake", "Process", "Evaluation framework for new patterns")
        Component(tier_progression, "Tier Progression", "Workflow", "Promotion criteria and process")
        Component(validation_system, "Evidence Validation", "Process", "Client project outcome verification")
        Component(decision_tracking, "Decision Registry", "Index", "Searchable ADR management")
        Component(cross_linking, "Cross-Reference System", "Navigation", "Inter-content relationships")
        Component(quality_control, "Quality Assurance", "Review", "Content accuracy and consistency")
        
        Component(taxonomy_system, "Taxonomy Organization", "Structure", "Multi-dimensional pattern classification")
        Component(patterns_domain, "Domain Patterns", "Content", "Architecture/Implementation/Operations/Security/Team/Quality")
        Component(patterns_risk, "Risk Navigation", "Content", "Green/Yellow/Red traffic light system")
        Component(patterns_context, "Context Guides", "Content", "Startup/Mid-market/Enterprise/Regulated specific")
        Component(patterns_maturity, "Maturity Tracking", "Content", "Experimental/Validated/Standard progression")
        
        Component(risk_matrices, "Risk Assessment", "Tools", "Client-appropriate technology evaluation")
        Component(client_profiles, "Client Profiles", "Framework", "Conservative/Moderate/Aggressive patterns")
        Component(pattern_template, "Pattern Template", "Standard", "Consistent pattern documentation format")
    }
    
    Person(author, "Author/Maintainer", "Stephen Szermer - CTO and practitioner")
    System_Ext(client_projects, "Client Projects", "Real implementations providing evidence")
    
    Rel(author, intake_framework, "Evaluates new patterns")
    Rel(intake_framework, tier_progression, "Manages content promotion")
    Rel(tier_progression, validation_system, "Requires evidence")
    Rel(validation_system, client_projects, "Validates against")
    Rel(decision_tracking, cross_linking, "Enables navigation")
    Rel(taxonomy_system, patterns_domain, "Organizes")
    Rel(taxonomy_system, patterns_risk, "Classifies")
    Rel(taxonomy_system, patterns_context, "Contextualizes")
    Rel(taxonomy_system, patterns_maturity, "Tracks evolution")
    Rel(quality_control, taxonomy_system, "Reviews organization")
    Rel(pattern_template, patterns_domain, "Standardizes format")
    Rel(risk_matrices, client_profiles, "Informs")
```

**Key Components**:
- **Knowledge Intake Framework**: Systematic evaluation of new AI development patterns
- **Four-Tier System**: Research → Analysis → Decision → Practice progression
- **Taxonomy Organization**: Multi-dimensional classification (Domain, Risk, Context, Maturity)
- **Evidence Validation**: All practices must be proven through client project outcomes
- **Risk-Based Frameworks**: Traffic light system (Green/Yellow/Red) for immediate risk visibility
- **Pattern Template**: Standardized format ensuring consistent documentation

## Deployment Diagram (Level 4)

```mermaid
C4Deployment
    Deployment_Node(dev_environment, "Development Environment", "Local machine") {
        Container(local_mdbook, "mdBook", "Local development server")
        Container(content_files, "Content Files", "Markdown source")
    }
    
    Deployment_Node(github_cloud, "GitHub Cloud") {
        Container(source_repo, "Source Repository", "Git repository with content")
        Container(actions_runner, "Actions Runner", "CI/CD automation")
        Container(pages_hosting, "Pages Hosting", "Static site delivery")
    }
    
    Deployment_Node(user_browser, "User Device", "Practitioner's browser") {
        Container(web_browser, "Web Browser", "Content consumption")
    }
    
    Rel(local_mdbook, actions_runner, "Push triggers", "Git/HTTPS")
    Rel(actions_runner, source_repo, "Builds from")
    Rel(actions_runner, pages_hosting, "Deploys to")
    Rel(web_browser, pages_hosting, "Requests", "HTTPS")
    Rel(pages_hosting, web_browser, "Serves content", "HTTPS")
```

**Deployment Characteristics**:
- **Zero server dependencies**: Pure static site deployment
- **Automated pipeline**: Git push triggers build and deployment
- **Global CDN**: GitHub Pages provides worldwide content delivery
- **HTTPS by default**: Secure content delivery for practitioners

## Architecture Decisions

### Core Design Decisions

1. **Static Site Generation** (mdBook)
   - **Rationale**: Maximum reliability, no server dependencies, fast loading
   - **Trade-offs**: Limited dynamic features vs. operational simplicity
   - **Status**: Accepted (see [ADR-2025-09-01](decisions/2025-09-01-claude-code-framework-selection.md) for framework selection approach)

2. **Four-Tier Knowledge Management**
   - **Rationale**: Evidence-based progression from research to proven practice
   - **Trade-offs**: Content creation overhead vs. practitioner trust and quality
   - **Status**: Core architectural principle

3. **Taxonomy-Based Structure**
   - **Rationale**: Multi-dimensional navigation better serves practitioner needs than linear book structure
   - **Trade-offs**: More complex organization vs. improved discoverability and context-awareness
   - **Status**: Implemented (see [ADR-2025-09-08-TAX](decisions/2025-09-08-taxonomy-based-structure.md))

4. **GitHub-Based Workflow** 
   - **Rationale**: Version control, automated deployment, practitioner-familiar tools
   - **Trade-offs**: GitHub dependency vs. workflow efficiency
   - **Status**: Accepted and implemented

5. **Evidence-First Approach**
   - **Rationale**: Practitioner credibility requires documented client outcomes
   - **Trade-offs**: Slower content creation vs. higher quality and trust
   - **Status**: Fundamental QED principle

### Technology Stack Decisions

- **mdBook**: Static site generator optimized for technical documentation
- **Mermaid**: Architecture diagrams integrated into documentation
- **GitHub Pages**: Reliable, fast, zero-configuration hosting
- **GitHub Actions**: Automated build and deployment pipeline
- **Markdown**: Universal format for technical content creation

### Quality Attributes

- **Reliability**: Static deployment ensures maximum uptime
- **Performance**: Fast loading through CDN and minimal dependencies
- **Maintainability**: Clear separation of content tiers and decision documentation
- **Discoverability**: Multi-dimensional taxonomy enables finding patterns through different lenses
- **Usability**: Practitioner-focused navigation with risk-first visibility
- **Security**: HTTPS by default, no server-side attack surface
- **Consistency**: Pattern template ensures uniform documentation quality

## Future Architecture Considerations

### Potential Enhancements
- **Search Integration**: Enhanced search capabilities beyond basic text search
- **Interactive Elements**: Dynamic filtering and content personalization
- **Community Features**: Contribution workflows and feedback mechanisms
- **Analytics Integration**: Usage tracking for content optimization

### Architectural Constraints
- Must maintain static-first approach for reliability
- All enhancements must preserve evidence-based quality standards
- Cannot introduce dependencies that compromise practitioner access
- Must remain cost-effective for independent practitioner maintenance

---

**Architecture Document Version**: 1.1  
**Last Updated**: 2025-09-09  
**Review Cycle**: Quarterly or with major architectural changes  
**Recent Changes**: Added taxonomy-based structure components and relationships