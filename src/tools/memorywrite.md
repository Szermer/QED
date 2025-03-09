# MemoryWrite: Storing Session Data

MemoryWrite saves information to a persistent storage system, enabling data preservation across conversations.

> **Note**: This tool follows the same pattern as MemoryRead - part of `ANT_ONLY_TOOLS` array in `tools.ts` with an empty prompt defined in its `prompt.ts` file. The tool is disabled by default with `isEnabled()` returning `false`.
>
> The separation of read and write operations into distinct tools follows good engineering practices. For agentic system developers, this pattern provides clear security boundaries and simpler permission models. The filesystem-based implementation requires minimal dependencies and offers a straightforward path to more sophisticated storage solutions as needs evolve.

## Complete Prompt

```typescript
// Actual prompt and description are defined elsewhere in the application
export const PROMPT = ''
export const DESCRIPTION = ''
```

> **Tool Prompt: MemoryWrite**
>
> Writes data to the Claude memory system to store information for future sessions. The memory system allows Claude to maintain context and data across conversations. This lets you save structured information that can be retrieved in later sessions with the MemoryRead tool.

## How It Works

MemoryWrite provides a straightforward interface for storing persistent data:

```typescript
const inputSchema = z.strictObject({
  file_path: z.string().describe('Path to the memory file to write'),
  content: z.string().describe('Content to write to the file'),
})
```

The implementation is concise, focusing on safely storing data in a consistent location:

```typescript
async *call({ file_path, content }) {
  const fullPath = join(MEMORY_DIR, file_path)
  mkdirSync(dirname(fullPath), { recursive: true })
  writeFileSync(fullPath, content, 'utf-8')
  yield {
    type: 'result',
    data: 'Saved',
    resultForAssistant: 'Saved',
  }
}
```

## Key Features

MemoryWrite provides these important capabilities:

1. **Storage Management**
   - Writes files to `~/.koding/memory` directory
   - Creates parent directories automatically
   - Supports nested directory structure

2. **Security Measures**
   - Path validation to prevent traversal attacks
   ```typescript
   async validateInput({ file_path }) {
     const fullPath = join(MEMORY_DIR, file_path)
     if (!fullPath.startsWith(MEMORY_DIR)) {
       return { result: false, message: 'Invalid memory file path' }
     }
     return { result: true }
   }
   ```
   - Restricts writes to the designated memory directory

3. **Configuration**
   - Currently disabled by default
   ```typescript
   async isEnabled() {
     // TODO: Use a statsig gate
     // TODO: Figure out how to do that without regressing app startup perf
     return false
   }
   ```
   - Write operation (not read-only)
   - No permissions required
   ```typescript
   isReadOnly() {
     return false
   }
   
   needsPermissions() {
     return false
   }
   ```

## Architecture

The MemoryWrite tool follows a simple, direct architecture:

```
MemoryWriteTool
  ↓
Input Validation → Checks path safety
  ↓
Directory Creation → Ensures parent directories exist
  ↓
File Writing → Saves content to disk
  ↓
Result Generation → Returns success confirmation
```

Design priorities include:
- **Simplicity**: Direct filesystem access
- **Reliability**: Creates directories as needed
- **Security**: Validates paths before writing
- **Flexibility**: Supports any text content

## Integration

MemoryWrite works with MemoryRead as a complementary pair:

```typescript
// No explicit permissions required
needsPermissions() {
  return false
}

// Not a read-only operation
isReadOnly() {
  return false
}
```

Together, these tools provide a simple but effective persistent storage system that maintains state between conversations. If enabled, these tools would:

1. Allow users to persistently store information that survives across sessions 
2. Not require permission prompts (`needsPermissions()` returns `false`)
3. Create and write files to the `~/.koding/memory` directory
4. Support hierarchical data organization through directory structure
5. Allow for creating structured knowledge bases that can be accessed later

## Usage Examples

Typical use cases:

1. **Storing user preferences**
   ```
   MemoryWrite(file_path: "user_preferences.md", content: "Theme: dark\nIndentation: 2 spaces")
   ```

2. **Saving project context**
   ```
   MemoryWrite(file_path: "projects/my_project/context.md", content: "# Project Overview\nThis is a React application with TypeScript...")
   ```

3. **Creating structured information**
   ```
   MemoryWrite(file_path: "index.md", content: "# Memory Index\n- [User Preferences](user_preferences.md)\n- [Projects](projects/)")
   ```

## Memory System Implementation Patterns

This write tool demonstrates practical patterns for agentic system memory:

1. **Fixed Storage Location**: Using a dedicated path (`~/.koding/memory`) isolates persistent data from application code

2. **Automatic Path Creation**: The tool handles directory creation, letting developers focus on data structure rather than filesystem operations

3. **Path Validation**: Security checks prevent writing outside the designated memory directory

4. **Write-only Design**: Separation of read/write operations follows the principle of least privilege

5. **Permissionless Operation**: By operating within a constrained scope, the tool avoids disrupting user flow with permission requests

These patterns can be directly applied when implementing similar memory systems, balancing simplicity with security.