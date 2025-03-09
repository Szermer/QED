# ArchitectTool (Architect): Software Architecture Planning

ArchitectTool provides specialized planning assistance to break down technical requirements into clear, actionable implementation plans. It functions as a software architect that analyzes requests without writing actual code.

## Complete Prompt

```typescript
export const ARCHITECT_SYSTEM_PROMPT = `You are an expert software architect. Your role is to analyze technical requirements and produce clear, actionable implementation plans.
These plans will then be carried out by a junior software engineer so you need to be specific and detailed. However do not actually write the code, just explain the plan.

Follow these steps for each request:
1. Carefully analyze requirements to identify core functionality and constraints
2. Define clear technical approach with specific technologies and patterns
3. Break down implementation into concrete, actionable steps at the appropriate level of abstraction

Keep responses focused, specific and actionable. 

IMPORTANT: Do not ask the user if you should implement the changes at the end. Just provide the plan as described above.
IMPORTANT: Do not attempt to write the code or use any string modification tools. Just provide the plan.`

export const DESCRIPTION =
  'Your go-to tool for any technical or coding task. Analyzes requirements and breaks them down into clear, actionable implementation steps. Use this whenever you need help planning how to implement a feature, solve a technical problem, or structure your code.'
```

> **Tool Prompt: Architect**
>
> Your go-to tool for any technical or coding task. Analyzes requirements and breaks them down into clear, actionable implementation steps. Use this whenever you need help planning how to implement a feature, solve a technical problem, or structure your code.

## Implementation Details

ArchitectTool creates a separate Claude instance with specialized architect instructions:

```typescript
export const ArchitectTool = {
  name: 'Architect',
  async *call({ prompt, context }, toolUseContext, canUseTool) {
    // Combine context and prompt if provided
    const content = context
      ? `<context>${context}</context>\n\n${prompt}`
      : prompt

    const userMessage = createUserMessage(content)
    const messages: Message[] = [userMessage]

    // Only allow file exploration tools in architect mode
    const allowedTools = (toolUseContext.options.tools ?? []).filter(_ =>
      FS_EXPLORATION_TOOLS.map(_ => _.name).includes(_.name),
    )

    // Query Claude with architect system prompt
    const lastResponse = await lastX(
      query(
        messages,
        [ARCHITECT_SYSTEM_PROMPT],
        await getContext(),
        canUseTool,
        {
          ...toolUseContext,
          options: { ...toolUseContext.options, tools: allowedTools },
        },
      ),
    )

    // Process and return text blocks
    const data = lastResponse.message.content.filter(_ => _.type === 'text')
    yield {
      type: 'result',
      data,
      resultForAssistant: this.renderResultForAssistant(data),
    }
  },
  isReadOnly() {
    return true
  },
  async isEnabled() {
    return false // Disabled by default, requires config enabling
  }
}
```

## Key Components

ArchitectTool has several critical features:

1. **Input Schema**
   - `prompt`: Required technical request to analyze
   - `context`: Optional additional context from prior conversation

2. **Limited Tool Access**
   - Defines specific allowed tools for exploration:
     ```typescript
     const FS_EXPLORATION_TOOLS: Tool[] = [
       BashTool,
       LSTool,
       FileReadTool,
       FileWriteTool,
       GlobTool,
       GrepTool,
     ]
     ```

3. **Specialized System Prompt**
   - Three-step process for requirement analysis
   - Focus on planning over implementation
   - Clear instructions to avoid writing code

4. **Context Handling**
   - Formats optional context in XML tags
   - Maintains separation between context and prompt

## Architecture

The ArchitectTool implements a simple query pattern:

```
ArchitectTool
  ↓
Input Processing → Format prompt and context
  ↓
Tool Filtering → Limit to file exploration tools
  ↓
Claude Query → Use specialized architect system prompt
  ↓
Result Processing → Extract and format text blocks
```

The architecture prioritizes:
- **Focus**: Specialized system prompt for architecture planning
- **Simplicity**: Single query with clear instructions
- **Limited scope**: Read-only operation with filtered tool access
- **Clear presentation**: Markdown-formatted output

## Permission Handling

ArchitectTool is designed with a simplified permission model:

```typescript
needsPermissions() {
  return false // No explicit permissions needed
}
```

This tool:
- Requires no explicit permissions from the user
- Operates in read-only mode
- Is disabled by default and must be explicitly enabled
- Filters available tools to maintain safe operation

## Usage Examples

Common usage patterns:

1. **Feature implementation planning**
   ```
   Architect(prompt: "How should I implement a rate limiting middleware for our Express API?")
   ```

2. **Architecture design with context**
   ```
   Architect(
     prompt: "What's the best way to structure a React app that uses GraphQL?", 
     context: "Our team is familiar with Redux but open to alternatives"
   )
   ```

3. **Technical problem solving**
   ```
   Architect(prompt: "How should we approach migrating from MongoDB to PostgreSQL in our Node.js app?")
   ```

ArchitectTool is particularly valuable for planning complex implementation tasks, helping bridge the gap between high-level requirements and concrete code changes. It enables more thoughtful architecture decisions before writing any code.

