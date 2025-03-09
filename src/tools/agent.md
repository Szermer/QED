# AgentTool: Your Research Assistant

AgentTool (dispatch_agent) lets you launch mini-Claudes to search and explore your codebase. This is great for finding things across multiple files or when you're not sure exactly where to look.

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

## How It Works

AgentTool creates a separate Claude to handle research tasks:

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

## What Makes It Special

AgentTool has some key features:

1. **Safety First**
   - Only gets read-only tools (no file editing or Bash)
   - Can't create more agents (no recursion)
   - Runs with clear boundaries

2. **Progress Updates**
   - Shows you what's happening in real time
   - Tracks how many tools it's using
   - Measures how long things take

3. **Parallel Power**
   - Run multiple agents at once
   - Each agent has its own space to work
   - Separate logs keep things organized

4. **Clear Communication**
   - Specialized prompting for search tasks
   - One-and-done execution model
   - Clean result formatting

## How It's Built

AgentTool follows this flow:

```
AgentTool
  ↓
getAgentTools() → Gets the safe tools, no recursive agents
  ↓
query() → Creates new Claude instance with search prompt
  ↓
message stream → Tracks progress and tool use
  ↓
Tool execution → Runs tools in isolated context
  ↓
Result formatting → Packages up the final answer
```

The design focuses on:
- **Separation**: Each agent works in its own space
- **Safety**: Clear boundaries for what tools are allowed
- **Speed**: Do multiple searches at once
- **Clarity**: Show progress and format results nicely

## Permissions

AgentTool keeps things simple with read-only mode:

```typescript
needsPermissions() {
  return false // Doesn't need its own permissions
}

async getAgentTools(dangerouslySkipPermissions) {
  // Only give agents read-only tools
  return (
    await (dangerouslySkipPermissions ? getTools() : getReadOnlyTools())
  ).filter(_ => _.name !== AgentTool.name)
}
```

This approach:
- Doesn't need to ask permission to start an agent
- Only lets agents do safe, read-only things
- Prevents agents from starting more agents
- Follows the principle of least privilege

## Examples

Here's how to use AgentTool:

1. **Find stuff across files**
   ```
   dispatch_agent(prompt: "Find all files that use logging and how they initialize it")
   ```

2. **Run multiple searches at once**
   ```
   dispatch_agent(prompt: "Find how error handling works in this codebase")
   dispatch_agent(prompt: "Find all API endpoint definitions")
   ```

3. **Explore code architecture**
   ```
   dispatch_agent(prompt: "Analyze how authentication works and summarize the approach")
   ```

AgentTool is great for exploring large codebases, saving context space, and cutting down on back-and-forth when you're hunting for information.

