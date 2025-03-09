# Architect: Software Design Planning

Architect helps break down technical requirements into clear implementation plans. It analyzes requests and creates structured plans without writing actual code.

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

## How It Works

Architect creates a specialized Claude instance with architect-specific instructions:

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

Architect includes these important features:

1. **Input Parameters**
   - `prompt`: The technical request to analyze
   - `context`: Optional context from prior conversation

2. **Limited Tool Access**
   - Only allows specific file exploration tools:
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
   - Three-step analysis process for requirements
   - Planning-focused rather than implementation
   - Instructions to avoid writing actual code

4. **Context Handling**
   - Wraps context in XML tags
   - Keeps context separate from the main prompt

## Architecture

Architect follows a straightforward query pattern:

```
Input Processing → Format prompt and context
  ↓
Tool Filtering → Limit to file exploration tools
  ↓
Claude Query → Use specialized architect system prompt
  ↓
Result Processing → Extract and format text blocks
```

Design priorities:
- Focus on architecture planning with specialized prompt
- Simple process with clear instructions
- Read-only operation with limited tool access
- Markdown output for clear presentation

## Permissions

Architect uses a simplified permission model:

```typescript
needsPermissions() {
  return false // No explicit permissions needed
}
```

The tool:
- Needs no explicit user permissions
- Operates in read-only mode
- Is disabled by default until explicitly enabled
- Filters available tools for safe operation

## Usage Examples

Typical use cases:

1. **Planning feature implementation**
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

Architect helps bridge the gap between high-level requirements and concrete code changes, enabling thoughtful architecture decisions before implementation begins.

