# ThinkTool (Think): Internal Reasoning Capabilities

ThinkTool provides Claude with a dedicated mechanism to externalize its reasoning process, making complex thinking visible to users through a distinct visual representation.

## Complete Prompt

```typescript
export const DESCRIPTION =
  'This is a no-op tool that logs a thought. It is inspired by the tau-bench think tool.'
export const PROMPT = `Use the tool to think about something. It will not obtain new information or make any changes to the repository, but just log the thought. Use it when complex reasoning or brainstorming is needed. 

Common use cases:
1. When exploring a repository and discovering the source of a bug, call this tool to brainstorm several unique ways of fixing the bug, and assess which change(s) are likely to be simplest and most effective
2. After receiving test results, use this tool to brainstorm ways to fix failing tests
3. When planning a complex refactoring, use this tool to outline different approaches and their tradeoffs
4. When designing a new feature, use this tool to think through architecture decisions and implementation details
5. When debugging a complex issue, use this tool to organize your thoughts and hypotheses

The tool simply logs your thought process for better transparency and does not execute any code or make changes.`
```

> **Tool Prompt: Think**
>
> Use the tool to think about something. It will not obtain new information or make any changes to the repository, but just log the thought. Use it when complex reasoning or brainstorming is needed.
>
> Common use cases:
> 1. When exploring a repository and discovering the source of a bug, call this tool to brainstorm several unique ways of fixing the bug, and assess which change(s) are likely to be simplest and most effective
> 2. After receiving test results, use this tool to brainstorm ways to fix failing tests
> 3. When planning a complex refactoring, use this tool to outline different approaches and their tradeoffs
> 4. When designing a new feature, use this tool to think through architecture decisions and implementation details
> 5. When debugging a complex issue, use this tool to organize your thoughts and hypotheses
>
> The tool simply logs your thought process for better transparency and does not execute any code or make changes.

## Implementation Details

ThinkTool has a streamlined implementation focused on capturing reasoning:

```typescript
const thinkToolSchema = z.object({
  thought: z.string().describe('Your thoughts.'),
})

export const ThinkTool = {
  name: 'Think',
  userFacingName: () => 'Think',
  
  isEnabled: async () =>
    Boolean(process.env.THINK_TOOL) && (await checkGate('tengu_think_tool')),
  isReadOnly: () => true,
  needsPermissions: () => false,
  
  async *call(input, { messageId }) {
    logEvent('tengu_thinking', {
      messageId,
      thoughtLength: input.thought.length.toString(),
      method: 'tool',
      provider: USE_BEDROCK ? 'bedrock' : USE_VERTEX ? 'vertex' : '1p',
    })

    yield {
      type: 'result',
      resultForAssistant: 'Your thought has been logged.',
      data: { thought: input.thought },
    }
  },

  // This is never called -- it's special-cased in AssistantToolUseMessage
  renderToolUseMessage(input) {
    return input.thought
  },
}
```

## Key Components

ThinkTool provides several subtle but powerful features:

1. **Simple Schema Interface**
   - Single "thought" parameter for free-form reasoning
   - No complex validation or constraints
   - Designed for maximum flexibility in reasoning

2. **Special UI Integration**
   - Renders as a distinctive "thinking" message
   - Visual distinction from standard tool output
   - Special-cased handling in AssistantToolUseMessage component

3. **Analytics Tracking**
   - Logs usage events with Statsig
   - Captures thought length metrics
   - Tracks reasoning across different model providers

4. **Minimal Footprint**
   - No permissions required
   - No side effects (pure "thinking")
   - No state changes or modifications

## Architecture

ThinkTool follows a minimal "no-op" architecture:

```
ThinkTool
  ↓
Input Capture → Processes thought string
  ↓
Analytics Tracking → Logs usage metrics
  ↓
Custom Rendering → Special-case UI display
  ↓
No-Op Result → Returns simple confirmation
```

The architecture prioritizes:
- **Transparency**: Making Claude's reasoning visible
- **Simplicity**: Minimal implementation complexity
- **Visual Distinction**: Clear UI separation from actions
- **Measurement**: Analytics for reasoning patterns

## Feature Flag Control

ThinkTool employs a dual-control system for enabling:

```typescript
isEnabled: async () =>
  Boolean(process.env.THINK_TOOL) && (await checkGate('tengu_think_tool'))
```

This approach:
- Requires environment variable `THINK_TOOL` to be set
- Also requires Statsig feature gate `tengu_think_tool` to be enabled
- Provides multiple layers of activation control
- Supports staged rollout and experimental features

## Usage Examples

ThinkTool is particularly valuable for complex reasoning tasks:

1. **Bug Analysis and Solution Planning**
   ```
   Think(thought: "Looking at the error in the login form submission, there are several possible root causes:
   1. The form validation might be failing silently
   2. The API endpoint could be rejecting malformed requests
   3. CORS issues might be preventing the request
   
   The most likely cause is #2 based on the error logs. I should check:
   - Request payload format
   - API validation requirements
   - Response error codes")
   ```

2. **Architecture Design Reasoning**
   ```
   Think(thought: "For implementing the new notification system, I need to consider:
   - Real-time vs. polling approach
   - WebSocket integration complexities
   - Database schema for storing notification state
   - Front-end components for display
   
   A hybrid approach seems best: WebSockets for active users, with fallback to polling...")
   ```

3. **Refactoring Strategy**
   ```
   Think(thought: "To refactor this authentication module, I have several options:
   1. Incremental approach: Replace components one by one
   2. Parallel implementation: Build new system alongside old
   3. Complete rewrite with feature freeze
   
   Option 1 seems safest given the critical nature of auth...")
   ```

ThinkTool enhances explainability by:
- Making reasoning explicit rather than implicit
- Creating space for thorough exploration of options
- Separating analytical thinking from concrete actions
- Showing the problem-solving approach
- Making the reasoning process transparent

