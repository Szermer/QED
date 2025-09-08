## Claude Code vs. anon-kode vs. Amp

Understanding the ecosystem helps frame the architectural patterns in this guide:

### Claude Code
Anthropic's local CLI tool that brings AI capabilities directly to your terminal:
- **Architecture**: Node.js backend with React/Ink for terminal UI
- **Focus**: Single-user local development with powerful file and code manipulation
- **Key Innovation**: Reactive terminal interface with streaming responses
- **Distribution**: Research preview, free to use ([docs here](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview))

### anon-kode
Daniel Nakov's open-source fork that extends Claude Code's capabilities:
- **Key Additions**: 
  - Multi-provider support (OpenAI, local models, etc.)
  - `/model` command for provider switching
  - UI customizations and adjusted defaults
- **Architecture**: Maintains Claude Code's core design
- **Value**: Demonstrates how the base architecture supports different AI backends

### Amp
Anthropic's collaborative platform that scales these concepts to teams:
- **Evolution**: Takes Claude Code's patterns to multi-user environments
- **Key Features**:
  - Real-time collaboration and sharing
  - Enterprise authentication (SSO, SAML)
  - Team workflows and permissions
  - Usage analytics and cost management
- **Architecture**: Distributed system with state synchronization
- **Target**: Teams and enterprises needing collaborative AI development

### Why This Matters

This guide analyzes patterns from all three systems:
- **Book 1** focuses on the local patterns shared by Claude Code and anon-kode
- **Book 2** explores how Amp scales these patterns for collaboration

The architectural decisions in Claude Code created a foundation that both anon-kode and Amp could build upon—understanding these patterns helps you build your own AI coding assistants at any scale.

