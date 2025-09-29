# Ink, Yoga, and Reactive UI System

A terminal-based reactive UI system can be built with Ink, Yoga, and React. This architecture renders rich, interactive components with responsive layouts in a text-based environment, showing how modern UI paradigms can work in terminal applications.

## Core UI Architecture

The UI architecture applies React component patterns to terminal rendering through the Ink library. This approach enables composition, state management, and declarative UIs in text-based interfaces.

### Entry Points and Initialization

A typical entry point initializes the application:

```tsx
// Main render entry point
render(
  <SentryErrorBoundary>
    <App persistDir={persistDir} />
  </SentryErrorBoundary>,
  {
    // Prevent Ink from exiting when no active components are rendered
    exitOnCtrlC: false,
  }
)
```

The application then mounts the REPL (Read-Eval-Print Loop) component, which serves as the primary container for the UI.

### Component Hierarchy

The UI component hierarchy follows this structure:

- **REPL** (`src/screens/REPL.tsx`) - Main container
  - **Logo** - Branding display
  - **Message Components** - Conversation rendering
    - AssistantTextMessage
    - AssistantToolUseMessage
    - UserTextMessage
    - UserToolResultMessage
  - **PromptInput** - User input handling
  - **Permission Components** - Tool use authorization
  - **Various dialogs and overlays**

### State Management

The application uses React hooks extensively for state management:

- **useState** for local component state (messages, loading, input mode)
- **useEffect** for side effects (terminal setup, message logging)
- **useMemo** for derived state and performance optimization
- **Custom hooks** for specialized functionality:
  - `useTextInput` - Handles cursor and text entry
  - `useArrowKeyHistory` - Manages command history
  - `useSlashCommandTypeahead` - Provides command suggestions

## Ink Terminal UI System

Ink allows React components to render in the terminal, enabling a component-based approach to terminal UI development.

### Ink Components

The application uses these core Ink components:

- **Box** - Container with flexbox-like layout properties
- **Text** - Terminal text with styling capabilities
- **Static** - Performance optimization for unchanging content
- **useInput** - Hook for capturing keyboard input

### Terminal Rendering Challenges

Terminal UIs face unique challenges addressed by the system:

1. **Limited layout capabilities** - Solved through Yoga layout engine
2. **Text-only interface** - Addressed with ANSI styling and borders
3. **Cursor management** - Custom `Cursor.ts` utility for text input
4. **Screen size constraints** - `useTerminalSize` for responsive design
5. **Rendering artifacts** - Special handling for newlines and clearing

### Terminal Input Handling

Input handling in the terminal requires special consideration:

```tsx
function useTextInput({
  value: originalValue,
  onChange,
  onSubmit,
  multiline = false,
  // ...
}: UseTextInputProps): UseTextInputResult {
  // Manage cursor position and text manipulation
  const cursor = Cursor.fromText(originalValue, columns, offset)
  
  function onInput(input: string, key: Key): void {
    // Handle special keys and input
    const nextCursor = mapKey(key)(input)
    if (nextCursor) {
      setOffset(nextCursor.offset)
      if (cursor.text !== nextCursor.text) {
        onChange(nextCursor.text)
      }
    }
  }
  
  return {
    onInput,
    renderedValue: cursor.render(cursorChar, mask, invert),
    offset,
    setOffset,
  }
}
```

## Yoga Layout System

Yoga provides a cross-platform layout engine that implements Flexbox for terminal UI layouts.

### Yoga Integration

Rather than direct usage, Yoga is integrated through:

1. The `yoga.wasm` WebAssembly module included in the package
2. Ink's abstraction layer that interfaces with Yoga
3. React components that use Yoga-compatible props

### Layout Patterns

The codebase uses these core layout patterns:

- **Flexbox Layouts** - Using `flexDirection="column"` or `"row"`
- **Width Controls** - With `width="100%"` or pixel values
- **Padding and Margins** - For spacing between elements
- **Borders** - Visual separation with border styling

### Styling Approach

Styling is applied through:

1. **Component Props** - Direct styling on Ink components
2. **Theme System** - In `theme.ts` with light/dark modes
3. **Terminal-specific styling** - ANSI colors and formatting

## Performance Optimizations

Terminal rendering requires special performance techniques:

### Static vs. Dynamic Rendering

The REPL component optimizes rendering by separating static from dynamic content:

```tsx
<Static key={`static-messages-${forkNumber}`} items={messagesJSX.filter(_ => _.type === 'static')}>
  {_ => _.jsx}
</Static>
{messagesJSX.filter(_ => _.type === 'transient').map(_ => _.jsx)}
```

### Memoization

Expensive operations are memoized to avoid recalculation:

```tsx
const messagesJSX = useMemo(() => {
  // Complex message processing
  return messages.map(/* ... */)
}, [messages, /* dependencies */])
```

### Content Streaming

Terminal output is streamed using generator functions:

```tsx
for await (const message of query([...messages, lastMessage], /* ... */)) {
  setMessages(oldMessages => [...oldMessages, message])
}
```

## Integration with Other Systems

The UI system integrates with other core components of an agentic system.

### Tool System Integration

Tool execution is visualized through specialized components:

- **AssistantToolUseMessage** - Shows tool execution requests
- **UserToolResultMessage** - Displays tool execution results
- Tool status tracking using ID sets for progress visualization

### Permission System Integration

The permission system uses UI components for user interaction:

- **PermissionRequest** - Base component for authorization requests
- **Tool-specific permission UIs** - For different permission types
- Risk-based styling with different colors based on potential impact

### State Coordination

The REPL coordinates state across multiple systems:

- Permission state (temporary vs. permanent approvals)
- Tool execution state (queued, in-progress, completed, error)
- Message history integration with tools and permissions
- User input mode (prompt vs. bash)

## Applying to Custom Systems

Ink/Yoga/React creates powerful terminal UIs with several advantages:

1. **Component reusability** - Terminal UI component libraries work like web components
2. **Modern state management** - React hooks handle complex state in terminal apps
3. **Flexbox layouts in text** - Yoga brings sophisticated layouts to text interfaces
4. **Performance optimization** - Static/dynamic content separation prevents flicker

Building similar terminal UI systems requires:

1. React renderer for terminals (Ink)
2. Layout engine (Yoga via WebAssembly)
3. Terminal-specific input handling
4. Text rendering optimizations

Combining these elements enables rich terminal interfaces for developer tools, CLI applications, and text-based programs that rival the sophistication of traditional GUI applications.