### MCPTool: External Tool Integration

MCPTool implements the Model Context Protocol (MCP) integration, allowing Claude Code to connect with external tool servers.

#### Implementation

- Uses a passthrough schema that accepts any input object
- Base implementation provides a skeleton that's dynamically customized
- Actual tools are created at runtime based on available MCP servers
- Rendering logic handles various output types including text and images

#### Integration System

- MCP servers are registered at three scope levels: project-specific, `.mcprc` file, or global
- Security model requires different approval levels based on source
- Supports two transport mechanisms:
  - `StdioClientTransport`: For command-line based MCP servers
  - `SSEClientTransport`: For HTTP-based MCP servers with Server-Sent Events
- Connection management with timeouts and error handling

MCPTool significantly extends Claude Code's capabilities by enabling integration with external tools and services through a standardized protocol.

