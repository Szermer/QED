# Core Architecture

Claude Code's architecture consists of three primary components that work together to create an effective AI-powered CLI:

## Terminal UI (React + Ink)

The UI layer leverages React Ink to deliver rich terminal interactions beyond standard CLI capabilities:

- Interactive permission prompts for secure tool execution
- Syntax-highlighted code snippets for better readability
- Real-time status updates during tool operations
- Markdown rendering directly within the terminal environment

React hooks provide clean state management, enabling complex interactive experiences while maintaining a terminal-based interface.

## Intelligence Layer (Claude API)

The intelligence layer connects with Claude through a streaming API interface:

- Parses responses to identify intended tool executions
- Extracts parameters from natural language instructions
- Validates input using Zod schemas to ensure correctness
- Handles errors gracefully when Claude provides invalid instructions

Communication flows bidirectionally - Claude triggers tool execution, and structured results stream back into the conversation context.

## Tools Layer

Each tool in the system follows a consistent pattern:

```typescript
const ExampleTool = {
  name: "example",
  description: "Does something useful",
  schema: z.object({ param: z.string() }),
  isReadOnly: () => true,
  needsPermissions: (input) => true,
  async *call(input) {
    // Execute and yield results
  }
} satisfies Tool;
```

This approach creates a plugin architecture where developers can add new capabilities by implementing the Tool interface. Available tools are dynamically loaded and presented to Claude, establishing an extensible capability framework.

## Reactive Command Loop

At its core, Claude Code operates through a reactive command loop - processing user input via Claude's intelligence, executing resulting actions, and displaying outcomes while streaming results in real-time.

The fundamental pattern powering this flow uses generators:

```typescript
// Core pattern enabling streaming UI
async function* query(input: string): AsyncGenerator<Message> {
  // Show user's message immediately
  yield createUserMessage(input);
  
  // Stream AI response as it arrives
  for await (const chunk of aiStream) {
    yield chunk;
    
    // Process tool use requests
    if (detectToolUse(chunk)) {
      // Execute tools and yield results
      for await (const result of executeTool(chunk)) {
        yield result;
      }
      
      // Continue conversation with tool results
      yield* continueWithToolResults(chunk);
    }
  }
}
```

This recursive generator approach keeps Claude Code responsive during complex operations. Rather than freezing while waiting for operations to complete, the UI updates continuously with real-time progress.

## Query Implementation Details

The complete query function handles all aspects of the conversation flow:

```typescript
async function* query(
  input: string, 
  context: QueryContext
): AsyncGenerator<Message> {
  // Process user input
  const userMessage = createUserMessage(input);
  yield userMessage;
  
  // Get streaming AI response
  const aiResponseGenerator = querySonnet(
    normalizeMessagesForAPI([...existingMessages, userMessage]),
    systemPrompt,
    context.maxTokens,
    context.tools,
    context.abortSignal,
    { dangerouslySkipPermissions: false }
  );
  
  // Stream response chunks
  for await (const chunk of aiResponseGenerator) {
    yield chunk;
    
    // Handle tool use requests
    if (chunk.message.content.some(c => c.type === 'tool_use')) {
      const toolUses = extractToolUses(chunk.message.content);
      
      // Execute tools (potentially in parallel)
      const toolResults = await executeTools(toolUses, context);
      
      // Yield tool results
      for (const result of toolResults) {
        yield result;
      }
      
      // Continue conversation recursively
      const continuationGenerator = query(
        null, // No new user input
        { 
          ...context,
          messages: [...existingMessages, userMessage, chunk, ...toolResults]
        }
      );
      
      // Yield continuation messages
      yield* continuationGenerator;
    }
  }
}
```

Key benefits of this implementation include:

1. **Immediate feedback**: Results appear as they become available through generator streaming.

2. **Seamless tool execution**: When Claude invokes tools, the function recursively calls itself with updated context, maintaining conversation flow.

3. **Responsive cancellation**: Abort signals propagate throughout the system for fast, clean cancellation.

4. **Comprehensive state management**: Each step preserves context, ensuring continuity between operations.

## Parallel Execution Engine

A distinctive feature of Claude Code is its parallel tool execution system. This capability dramatically improves performance when working with large codebases - tasks that might take minutes when executed sequentially often complete in seconds with parallel processing.

### Concurrent Generator Approach

Claude Code implements an elegant solution using async generators to process multiple operations in parallel while streaming results as they become available.

The core implementation breaks down into several manageable concepts:

#### 1. Generator State Tracking

```typescript
// Each generator has a state object tracking its progress
type GeneratorState<T> = {
  generator: AsyncGenerator<T>    // The generator itself
  lastYield: Promise<IteratorResult<T>>  // Its next pending result
  done: boolean                   // Whether it's finished
}

// We track all active generators in a map
const generatorStates = new Map<number, GeneratorState<T>>()

// We also track which generators are still running
const remaining = new Set(generators.map((_, i) => i))
```

#### 2. Concurrency Management

```typescript
// Control how many generators run simultaneously 
const { signal, maxConcurrency = MAX_CONCURRENCY } = options

// Start only a limited batch initially
const initialBatchSize = Math.min(generators.length, maxConcurrency)
for (let i = 0; i < initialBatchSize; i++) {
  if (generators[i]) {
    // Initialize each generator and start its first operation
    generatorStates.set(i, {
      generator: generators[i],
      lastYield: generators[i].next(),
      done: false,
    })
  }
}
```

#### 3. Non-blocking Result Collection

```typescript
// Race to get results from whichever generator finishes first
const entries = Array.from(generatorStates.entries())
const nextResults = await Promise.race(
  entries.map(async ([index, state]) => {
    const result = await state.lastYield
    return { index, result }
  })
)

// Process whichever result came back first
const { index, result } = nextResults

// Immediately yield that result with tracking info
if (!result.done) {
  yield { ...result.value, generatorIndex: index }
  
  // Queue the next value from this generator without waiting
  const state = generatorStates.get(index)!
  state.lastYield = state.generator.next()
}
```

#### 4. Dynamic Generator Replacement

```typescript
// When a generator finishes, remove it
if (result.done) {
  remaining.delete(index)
  generatorStates.delete(index)
  
  // Calculate the next generator to start
  const nextGeneratorIndex = Math.min(
    generators.length - 1,
    Math.max(...Array.from(generatorStates.keys())) + 1
  )
  
  // If there's another generator waiting, start it
  if (
    nextGeneratorIndex >= 0 &&
    nextGeneratorIndex < generators.length &&
    !generatorStates.has(nextGeneratorIndex)
  ) {
    generatorStates.set(nextGeneratorIndex, {
      generator: generators[nextGeneratorIndex],
      lastYield: generators[nextGeneratorIndex].next(),
      done: false,
    })
  }
}
```

#### 5. Cancellation Support

```typescript
// Check for cancellation on every iteration
if (signal?.aborted) {
  throw new AbortError()
}
```

### The Complete Picture

These pieces work together to create a system that:

1. Runs a controlled number of operations concurrently
2. Returns results immediately as they become available from any operation
3. Dynamically starts new operations as others complete
4. Tracks which generator produced each result
5. Supports clean cancellation at any point

This approach maximizes throughput while maintaining order tracking, enabling Claude Code to process large codebases efficiently.

## Tool Execution Strategy

When Claude requests multiple tools, the system must decide how to execute them efficiently. A key insight drives this decision: read operations can run in parallel, but write operations need careful coordination.

### Smart Execution Paths

The tool executor makes an important distinction:

```typescript
async function executeTools(toolUses: ToolUseRequest[], context: QueryContext) {
  // First, check if all requested tools are read-only
  const allReadOnly = toolUses.every(toolUse => {
    const tool = findToolByName(toolUse.name);
    return tool && tool.isReadOnly();
  });
  
  let results: ToolResult[] = [];
  
  // Choose execution strategy based on tool types
  if (allReadOnly) {
    // Safe to run in parallel when all tools just read
    results = await runToolsConcurrently(toolUses, context);
  } else {
    // Run one at a time when any tool might modify state
    results = await runToolsSerially(toolUses, context);
  }
  
  // Ensure results match the original request order
  return sortToolResultsByRequestOrder(results, toolUses);
}
```

### Performance Optimizations

This seemingly simple approach contains several sophisticated optimizations:

#### Read vs. Write Classification

Each tool declares whether it's read-only through an `isReadOnly()` method:

```typescript
// Example tools showing classification
const ViewFileTool = {
  name: "View",
  // Marked as read-only - can run in parallel
  isReadOnly: () => true, 
  // Implementation...
}

const EditFileTool = {
  name: "Edit",
  // Marked as write - must run sequentially
  isReadOnly: () => false,
  // Implementation...
}
```

#### Smart Concurrency Control

The execution strategy balances resource usage with execution safety:

1. **Parallel for read operations**:
   - File readings, glob searches, and grep operations run simultaneously
   - Typically limits concurrency to ~10 operations at once
   - Uses the parallel execution engine discussed earlier

2. **Sequential for write operations**:
   - Any operation that might change state (file edits, bash commands)
   - Runs one at a time in the requested order
   - Prevents potential conflicts or race conditions

#### Ordering Preservation

Despite parallel execution, results maintain a predictable order:

```typescript
function sortToolResultsByRequestOrder(
  results: ToolResult[], 
  originalRequests: ToolUseRequest[]
): ToolResult[] {
  // Create mapping of tool IDs to their original position
  const orderMap = new Map(
    originalRequests.map((req, index) => [req.id, index])
  );
  
  // Sort results to match original request order
  return [...results].sort((a, b) => {
    return orderMap.get(a.id)! - orderMap.get(b.id)!;
  });
}
```

### Real-World Impact

The parallel execution strategy significantly improves performance for operations that would otherwise run sequentially, making Claude Code more responsive when working with multiple files or commands.

## Key Components and Design Patterns

The Claude Code architecture relies on several foundational components that work together:

### Core Files

- `utils/generators.ts`: Contains the parallel execution engine and generator utilities
- `query.ts`: Implements the reactive command loop and tool execution logic
- `Tool.ts`: Defines the interface all tools must implement
- `tools.ts`: Manages tool registration and discovery
- `permissions.ts`: Handles the security layer for tool execution

### UI Components

- `screens/REPL.tsx`: Renders the main conversation interface
- `PromptInput.tsx`: Manages user input and command history
- `services/claude.ts`: Handles API communication with Claude
- `utils/messages.tsx`: Processes message formatting and rendering

### Architectural Patterns

The codebase employs several consistent patterns:

- **Async Generators**: Enable streaming data throughout the system
- **Recursive Functions**: Power multi-turn conversations and tool usage
- **Plugin Architecture**: Allows extending the system with new tools
- **State Isolation**: Keeps tool executions from interfering with each other
- **Dynamic Concurrency**: Adjusts parallelism based on operation types