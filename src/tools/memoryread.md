# MemoryRead: Session Memory Access

MemoryRead retrieves information stored in a persistent memory system, enabling state preservation across conversations.

> **Note**: An interesting pattern in this code - the tool is included in "ANT_ONLY_TOOLS" with an empty prompt. It's implemented but disabled by default, functioning as a system component rather than a user-facing feature. This approach lets developers add experimental features without changing core code.

## Complete Prompt

```typescript
// Actual prompt and description are defined elsewhere in the application
export const PROMPT = ''
export const DESCRIPTION = ''
```

> **Tool Prompt: MemoryRead**
>
> Accesses the Claude memory system to retrieve stored information from previous sessions. The memory system allows Claude to maintain context and data across conversations. When called without a file path, lists all available memory files along with the contents of the root index.md file.

## How It Works

MemoryRead provides a simple interface to access persistent memory:

```typescript
const inputSchema = z.strictObject({
  file_path: z
    .string()
    .optional()
    .describe('Optional path to a specific memory file to read'),
})
```

The implementation enables two modes of operation - listing available memory files or reading a specific file:

```typescript
async *call({ file_path }) {
  mkdirSync(MEMORY_DIR, { recursive: true })

  // If a specific file is requested, return its contents
  if (file_path) {
    const fullPath = join(MEMORY_DIR, file_path)
    if (!existsSync(fullPath)) {
      throw new Error('Memory file does not exist')
    }
    const content = readFileSync(fullPath, 'utf-8')
    yield {
      type: 'result',
      data: { content },
      resultForAssistant: this.renderResultForAssistant({ content }),
    }
    return
  }

  // Otherwise return the index and file list
  const files = readdirSync(MEMORY_DIR, { recursive: true })
    .map(f => join(MEMORY_DIR, f.toString()))
    .filter(f => !lstatSync(f).isDirectory())
    .map(f => `- ${f}`)
    .join('\n')

  const indexPath = join(MEMORY_DIR, 'index.md')
  const index = existsSync(indexPath) ? readFileSync(indexPath, 'utf-8') : ''

  const quotes = "'''"
  const content = `Here are the contents of the root memory file, \`${indexPath}\`:
${quotes}
${index}
${quotes}

Files in the memory directory:
${files}`
  yield {
    type: 'result',
    data: { content },
    resultForAssistant: this.renderResultForAssistant({ content }),
  }
}
```

## Key Features

MemoryRead provides these important capabilities:

1. **Query Modes**
   - Index listing: Shows all available memory files
   - File access: Reads a specific memory file
   - Index content: Returns the main index.md content

2. **Storage System**
   - Files stored in `~/.koding/memory` directory
   - Creates directory structure as needed
   - Supports nested subdirectories

3. **Security Measures**
   - Path validation to prevent traversal attacks
   ```typescript
   async validateInput({ file_path }) {
     if (file_path) {
       const fullPath = join(MEMORY_DIR, file_path)
       if (!fullPath.startsWith(MEMORY_DIR)) {
         return { result: false, message: 'Invalid memory file path' }
       }
       if (!existsSync(fullPath)) {
         return { result: false, message: 'Memory file does not exist' }
       }
     }
     return { result: true }
   }
   ```
   - Existence verification before access
   - Read-only operation (paired with MemoryWrite)

4. **Configuration**
   - Currently disabled by default
   ```typescript
   async isEnabled() {
     // TODO: Use a statsig gate
     // TODO: Figure out how to do that without regressing app startup perf
     return false
   }
   ```
   - Read-only functionality
   - No permissions required

## Architecture

The MemoryRead tool follows a simple, filesystem-based architecture:

```
MemoryReadTool
  ↓
Input Validation → Checks path safety and file existence
  ↓
Storage Access → Directory creation and file reading
  ↓
Content Formatting → Index listing or individual file content
  ↓
Result Generation → Well-formatted output for Claude
```

Design priorities include:
- **Simplicity**: Direct filesystem access without caching
- **Persistence**: Files stored on disk for longevity
- **Flexibility**: Support for both listing and targeted reading
- **Security**: Path validation to prevent directory traversal

## Integration

MemoryRead works with MemoryWrite as a complementary pair:

```typescript
// No explicit permissions required
needsPermissions() {
  return false
}

// Read-only operation
isReadOnly() {
  return true
}
```

Together, these tools provide a simple but effective persistent storage system that maintains state between conversations.

## Usage Examples

Typical use cases:

1. **Retrieving memory index**
   ```
   MemoryRead()
   ```

2. **Reading specific files**
   ```
   MemoryRead(file_path: "user_preferences.md")
   ```

3. **Accessing nested data**
   ```
   MemoryRead(file_path: "projects/my_project/notes.md")
   ```

Key benefits of the memory system:
- Persists information across different sessions
- Maintains context for recurring tasks
- Stores user preferences and settings
- Builds knowledge specific to the user

This allows building a progressively refined understanding of user context and preferences without requiring the same information to be provided repeatedly.

