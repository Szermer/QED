## Claude Code vs. anon-kode

Before diving deeper, here's how Claude Code and anon-kode relate:

- **Claude Code** is a research preview by Anthropic, integrating AI capabilities into your terminal. It's built with Node.js, React, and Ink for terminal UIs, using Anthropic's AI via API ([docs here](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)).
- **anon-kode** is a fork of Claude Code with a few additions:
  1. **Multi-provider support**: Supports multiple AI providers through OpenAI-compatible APIs (Anthropic, OpenAI, local models, etc.).
  2. **Easy configuration**: Adds a `/model` command to quickly switch between providers.
  3. **Customizations**: UI tweaks, branding changes, and adjusted defaults.

Both share the same core architecture and execution flow—this guide focuses on those shared components, highlighting anon-kode specifics where relevant.

