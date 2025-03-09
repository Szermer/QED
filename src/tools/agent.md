# AgentTool (dispatch_agent): Meta-Tool for Task Delegation

AgentTool enables launching autonomous sub-agents that can search, read files, and reason while maintaining security boundaries. It's optimized for parallel operations and offloading search-heavy tasks.

## Complete Prompt

```typescript
export async function getPrompt(
  dangerouslySkipPermissions: boolean,
): Promise<string> {
  const tools = await getAgentTools(dangerouslySkipPermissions)
  const toolNames = tools.map(_ => _.name).join(', ')
  return `Launch a new agent that has access to the following tools: ${toolNames}. When you are searching for a keyword or file and are not confident that you will find the right match on the first try, use the Agent tool to perform the search for you. For example:

- If you are searching for a keyword like "config" or "logger", the Agent tool is appropriate
- If you want to read a specific file path, use the ${FileReadTool.name} or ${GlobTool.name} tool instead of the Agent tool, to find the match more quickly
- If you are searching for a specific class definition like "class Foo", use the ${GlobTool.name} tool instead, to find the match more quickly

Usage notes:
1. Launch multiple agents concurrently whenever possible, to maximize performance; to do that, use a single message with multiple tool uses
2. When the agent is done, it will return a single message back to you. The result returned by the agent is not visible to the user. To show the user the result, you should send a text message back to the user with a concise summary of the result.
3. Each agent invocation is stateless. You will not be able to send additional messages to the agent, nor will the agent be able to communicate with you outside of its final report. Therefore, your prompt should contain a highly detailed task description for the agent to perform autonomously and you should specify exactly what information the agent should return back to you in its final and only message to you.
4. The agent's outputs should generally be trusted${
    dangerouslySkipPermissions
      ? ''
      : `
5. IMPORTANT: The agent can not use ${BashTool.name}, ${FileWriteTool.name}, ${FileEditTool.name}, ${NotebookEditTool.name}, so can not modify files. If you want to use these tools, use them directly instead of going through the agent.`
  }`
}
```

> **Tool Prompt: dispatch_agent**
>
> Launch a new agent that has access to the following tools: View, GlobTool, GrepTool, LS, ReadNotebook, WebFetchTool. When you are searching for a keyword or file and are not confident that you will find the right match on the first try, use the Agent tool to perform the search for you. For example:
>
> - If you are searching for a keyword like "config" or "logger", or for questions like "which file does X?", the Agent tool is strongly recommended
> - If you want to read a specific file path, use the View or GlobTool tool instead of the Agent tool, to find the match more quickly
> - If you are searching for a specific class definition like "class Foo", use the GlobTool tool instead, to find the match more quickly
>
> Usage notes:
> 1. Launch multiple agents concurrently whenever possible, to maximize performance; to do that, use a single message with multiple tool uses
> 2. When the agent is done, it will return a single message back to you. The result returned by the agent is not visible to the user. To show the user the result, you should send a text message back to the user with a concise summary of the result.
> 3. Each agent invocation is stateless. You will not be able to send additional messages to the agent, nor will the agent be able to communicate with you outside of its final report. Therefore, your prompt should contain a highly detailed task description for the agent to perform autonomously and you should specify exactly what information the agent should return back to you in its final and only message to you.
> 4. The agent's outputs should generally be trusted
> 5. IMPORTANT: The agent can not use Bash, Replace, Edit, NotebookEditCell, so can not modify files. If you want to use these tools, use them directly instead of going through the agent.

## Implementation Details

AgentTool creates a separate Claude instance to perform delegated tasks with limited permissions:

```typescript
export const AgentTool = {
  name: 'dispatch_agent',
  async *call({ prompt }, { abortController, options, readFileTimestamps }) {
    const startTime = Date.now()
    const messages = [createUserMessage(prompt)]
    const tools = await getAgentTools(dangerouslySkipPermissions)
    
    // Yield initial progress for UI feedback
    yield { type: 'progress', content: createAssistantMessage('Initializing…') }
    
    // Set up agent environment
    const [agentPrompt, context, model, maxThinkingTokens] = await Promise.all([
      getAgentPrompt(),
      getContext(),
      getSlowAndCapableModel(),
      getMaxThinkingTokens(messages),
    ])
    
    // Generate unique sidechain number for logs
    const getSidechainNumber = memoize(() => 
      getNextAvailableLogSidechainNumber(messageLogName, forkNumber)
    )
    
    // Process the agent's execution and track tools used
    let toolUseCount = 0
    for await (const message of query(messages, agentPrompt, context, ...)) {
      messages.push(message)
      
      // Log to separate sidechain to avoid polluting main logs
      overwriteLog(
        getMessagesPath(messageLogName, forkNumber, getSidechainNumber()),
        messages.filter(_ => _.type !== 'progress')
      )
      
      // Track and report tool use progress
      if (message.type === 'assistant') {
        for (const content of message.message.content) {
          if (content.type === 'tool_use') {
            toolUseCount++
            yield { type: 'progress', content: /* tool message */ }
          }
        }
      }
    }
    
    // Extract and return the final result
    const data = lastMessage.message.content.filter(_ => _.type === 'text')
    yield {
      type: 'result',
      data,
      resultForAssistant: this.renderResultForAssistant(data),
    }
  },
  isReadOnly() {
    return true // Enforces read-only operation for security
  }
}
```

## Key Components

AgentTool provides several critical features:

1. **Tool Filtering and Security**
   - Prevents recursive agent calls via tool filtering
   - Enforces read-only access for agents
   - Restricts access to modification tools

2. **Progress Tracking**
   - Real-time updates on tool execution
   - Token usage tracking and reporting
   - Execution time measurement

3. **Performance Optimization**
   - Supports concurrent agent execution
   - Separate query execution context
   - Separate log chains for each agent

4. **Prompt Engineering**
   - Tailored system prompt for agent tasks
   - Clear usage guidance for effective delegation
   - Stateless execution model

## Architecture

The AgentTool implements a delegation pattern with clear boundaries:

```
AgentTool
  ↓
getAgentTools() → Filters available tools, excluding recursive agents
  ↓
query() → Creates new Claude query context with agent prompt
  ↓
message stream → Processes messages with progress tracking
  ↓
Tool execution → Handles each tool request in agent context
  ↓
Result serialization → Extracts and formats final response
```

The architecture prioritizes:
- **Isolation**: Each agent operates in its own context
- **Security**: Explicit permission boundaries for tool access
- **Performance**: Parallel execution for read-only operations
- **Usability**: Clear progress indicators and result formatting

## Permission Handling

AgentTool simplifies permission by operating in read-only mode:

```typescript
needsPermissions() {
  return false // No permissions needed for the tool itself
}

async getAgentTools(dangerouslySkipPermissions) {
  // Only expose read-only tools to agents
  return (
    await (dangerouslySkipPermissions ? getTools() : getReadOnlyTools())
  ).filter(_ => _.name !== AgentTool.name)
}
```

This approach:
- Eliminates need for explicit permissions for agent launch
- Restricts agents to safe, read-only operations by default
- Prevents privilege escalation through recursive agent calls
- Supports the principle of least privilege

## Usage Examples

Common usage patterns:

1. **Keyword searching across multiple files**
   ```
   dispatch_agent(prompt: "Find all files that use logging and identify the logger initialization pattern")
   ```

2. **Multiple parallel searches**
   ```
   dispatch_agent(prompt: "Find how error handling is implemented in this codebase")
   dispatch_agent(prompt: "Locate all API endpoint definitions")
   ```

3. **Delegated code exploration**
   ```
   dispatch_agent(prompt: "Analyze how authentication works in this codebase and summarize the approach")
   ```

AgentTool is particularly valuable for offloading search-heavy operations, especially in large codebases, allowing more efficient use of context window and reduced round-trip interactions when exploring unfamiliar code.

