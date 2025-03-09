# MemoryReadTool (MemoryRead): Session Memory Access

MemoryReadTool provides Claude with the ability to retrieve information stored in a persistent memory system, enabling state preservation across conversations.

## Complete Prompt

```typescript
// Actual prompt and description are defined elsewhere in the application
export const PROMPT = ''
export const DESCRIPTION = ''
```

> **Tool Prompt: MemoryRead**
>
> Accesses the Claude memory system to retrieve stored information from previous sessions. The memory system allows Claude to maintain context and data across conversations. When called without a file path, lists all available memory files along with the contents of the root index.md file.

## Implementation Details

MemoryReadTool provides a straightforward interface to access persistent memory:

```typescript
const inputSchema = z.strictObject({
  file_path: z
    .string()
    .optional()
    .describe('Optional path to a specific memory file to read'),
})
```

The core implementation enables two modes of operation - listing available memory files or reading a specific file:

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

## Key Components

MemoryReadTool has several important features:

1. **Flexible Query Modes**
   - Index listing: Returns a list of all memory files
   - Specific file access: Reads a single memory file by path
   - Index.md content: Automatically returns the main index file content

2. **Storage Structure**
   - Files stored in `~/.koding/memory` by default
   - Directory creation if needed (on first use)
   - Support for subdirectories and hierarchy

3. **Security**
   - Path validation to prevent directory traversal
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
   - Existence checks before file access
   - Read-only operation (paired with MemoryWriteTool for writing)

4. **Tool Configuration**
   - Currently disabled by default
   ```typescript
   async isEnabled() {
     // TODO: Use a statsig gate
     // TODO: Figure out how to do that without regressing app startup perf
     return false
   }
   ```
   - Read-only operation
   - No permissions required

## Architecture

The MemoryReadTool follows a straightforward, filesystem-based approach:

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

This architecture prioritizes:
- **Simplicity**: Direct filesystem access with no caching layer
- **Persistence**: Files stored on disk for longevity
- **Flexibility**: Support for both listing and targeted reading
- **Security**: Path validation to prevent directory traversal

## Integration Approach

MemoryReadTool is designed to work with MemoryWriteTool as a complementary pair:

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

These tools work together to provide a simple but effective persistent storage mechanism that Claude can use to maintain state between conversations.

## Usage Examples

Common usage patterns:

1. **Retrieving the memory index**
   ```
   MemoryRead()
   ```

2. **Reading a specific memory file**
   ```
   MemoryRead(file_path: "user_preferences.md")
   ```

3. **Accessing notes in a subdirectory**
   ```
   MemoryRead(file_path: "projects/my_project/notes.md")
   ```

The memory system provides several key benefits:
- Stores persistent information across sessions
- Maintains context for long-running or recurring tasks
- Serves as a simple database for user preferences and settings
- Creates a knowledge base specific to the user's needs

This allows Claude to build a progressively refined understanding of the user's context, preferences, and ongoing work without requiring the user to repeatedly provide the same information.

