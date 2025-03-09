# MCPTool (MCP): Model Context Protocol Integration

MCPTool implements the Model Context Protocol (MCP), enabling Claude to connect with external tool servers and dynamically extend its capabilities through standardized interfaces.

## Complete Prompt

```typescript
// Actual prompt and description are overridden in mcpClient.ts
export const PROMPT = ''
export const DESCRIPTION = ''
```

> **Tool Prompt: MCP**
>
> The prompt for MCPTool is dynamically generated based on the connected MCP server and specific tool. Each MCP-provided tool has its own description and schema that gets exposed to Claude at runtime.

## Implementation Details

MCPTool provides a foundational architecture for external tool integration with placeholders that get dynamically customized:

```typescript
// Base MCPTool implementation
const inputSchema = z.object({}).passthrough()

export const MCPTool = {
  // Overridden at runtime
  name: 'mcp',
  async description() {
    return DESCRIPTION  // Overridden per tool
  },
  async prompt() {
    return PROMPT  // Overridden per tool
  },
  inputSchema,
  async *call() {
    yield {
      type: 'result',
      data: '',
      resultForAssistant: '',
    }
  },
  needsPermissions() {
    return true
  },
  userFacingName: () => 'mcp',  // Overridden per tool
  renderToolResultMessage(output, { verbose }) {
    // Handles various output formats including text and images
  }
}
```

The actual implementation extends this base through the MCP client service:

```typescript
// Dynamic tool creation in mcpClient.ts
export const getMCPTools = memoize(async (): Promise<Tool[]> => {
  const toolsList = await requestAll<ListToolsResult>(
    { method: 'tools/list' },
    ListToolsResultSchema,
    'tools',
  )

  return toolsList.flatMap(({ client, result: { tools } }) =>
    tools.map((tool): Tool => ({
      ...MCPTool,
      name: 'mcp__' + client.name + '__' + tool.name,
      async description() {
        return tool.description ?? ''
      },
      async prompt() {
        return tool.description ?? ''
      },
      inputJSONSchema: tool.inputSchema as Tool['inputJSONSchema'],
      async *call(args: Record<string, unknown>) {
        const data = await callMCPTool({ client, tool: tool.name, args })
        yield {
          type: 'result',
          data,
          resultForAssistant: data,
        }
      },
      userFacingName() {
        return `${client.name}:${tool.name} (MCP)`
      },
    })),
  )
})
```

## Key Components

MCPTool provides several critical features:

1. **Dynamic Tool Creation**
   - Base skeleton tool that gets customized at runtime
   - Tool name format: `mcp__[serverName]__[toolName]`
   - User-facing name: `[serverName]:[toolName] (MCP)`
   - Passthrough schema to support any input object

2. **Server Configuration Management**
   - Three-level configuration scope hierarchy:
     - Project-specific (highest priority)
     - `.mcprc` file (middle priority)
     - Global configuration (lowest priority)
   - Security model for server approval
   - Server connection tracking and error handling

3. **Flexible Transport Mechanisms**
   - `StdioClientTransport` for command-line based servers
   - `SSEClientTransport` for HTTP servers with Server-Sent Events
   - Connection timeouts and retry mechanisms

4. **Output Processing**
   - Support for text outputs formatted as strings
   - Image handling with base64 encoding
   - Multi-part content arrays
   - Standardized error reporting

## Architecture

The MCPTool implementation follows a layered architecture:

```
MCPTool (Base)
  ↓
getMCPTools() → Discovers and converts server tools to Claude tools
  ↓
getClients() → Manages connections to registered MCP servers
  ↓
requestAll() → Sends requests to all connected servers
  ↓
callMCPTool() → Executes specific tool on a specific server
  ↓
Result Processing → Formats outputs for Claude's consumption
```

This architecture prioritizes:
- **Extensibility**: Easy addition of new MCP servers and tools
- **Isolation**: Each server operates independently
- **Fault Tolerance**: Failures in one server don't affect others
- **Standardization**: Consistent interfaces regardless of backend

## Configuration System

MCPTool employs a sophisticated configuration system:

```typescript
export function addMcpServer(
  name: McpName,
  server: McpServerConfig,
  scope: ConfigScope = 'project',
): void {
  if (scope === 'mcprc') {
    // Write to .mcprc file in current directory
  } else if (scope === 'global') {
    // Update global configuration
    const config = getGlobalConfig()
    if (!config.mcpServers) {
      config.mcpServers = {}
    }
    config.mcpServers[name] = server
    saveGlobalConfig(config)
  } else {
    // Update project-specific configuration
    const config = getCurrentProjectConfig()
    if (!config.mcpServers) {
      config.mcpServers = {}
    }
    config.mcpServers[name] = server
    saveCurrentProjectConfig(config)
  }
}
```

The configuration prioritization ensures:
- Project-specific settings override all others
- `.mcprc` settings override global ones
- Security approval required for certain server types
- Configuration persistence across sessions

## Usage Examples

MCPTool is primarily used through the dynamically generated tools. From a user perspective:

1. **Server Registration**
   ```
   kode mcp add myserver --command="python -m my_mcp_server"
   ```

2. **Tool Usage (for an example calculator server)**
   ```
   myserver:calculate(expression: "2 + 2 * 10")
   ```

3. **Server Configuration**
   ```
   kode mcp list
   kode mcp approve myserver
   ```

MCPTool significantly extends Claude's capabilities by enabling integration with external tools and services through a standardized protocol. It allows Claude to:
- Access specialized functionality implemented in any language
- Interact with external APIs and services through mediator servers 
- Utilize domain-specific tools beyond the core toolset
- Access private tools specific to a user's project

