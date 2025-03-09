# GlobTool: File Pattern Matching

GlobTool is a fast file-finding tool that searches for files matching glob patterns. It's optimized for performance with large codebases and works with standard glob syntax.

## Complete Prompt

```typescript
// Tool Prompt: GlobTool
export const DESCRIPTION = `- Fast file pattern matching tool that works with any codebase size
- Supports glob patterns like "**/*.js" or "src/**/*.ts"
- Returns matching file paths sorted by modification time
- Use this tool when you need to find files by name patterns
- When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead
`
```

> **Tool Prompt: GlobTool**
>
> - Fast file pattern matching tool that works with any codebase size
> - Supports glob patterns like "**/*.js" or "src/**/*.ts"
> - Returns matching file paths sorted by modification time
> - Use this tool when you need to find files by name patterns
> - When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead

## Implementation Details

Looking at the implementation, GlobTool has two main components:

1. **The GlobTool React component** (`GlobTool.tsx`)
   - Simple TypeScript interface with Zod schema validation
   - Provides schema, permissions, and renderer functions
   - Calls the underlying file utility function

2. **The glob utility function** (`file.ts`)
   - Wraps Node's `glob` library with smart options
   - Implements sorting and result limiting
   - Provides truncation information to prevent overwhelming the model

Let's look at the core implementation more closely:

```typescript
// From file.ts - the core file matching function
export async function glob(
  filePattern: string,
  cwd: string,
  { limit, offset }: { limit: number; offset: number },
  abortSignal: AbortSignal,
): Promise<{ files: string[]; truncated: boolean }> {
  // Uses Node's glob library
  const paths = await globLib([filePattern], {
    cwd,
    nocase: true,  // Case-insensitive matching
    nodir: true,   // Only return files, not directories
    signal: abortSignal,  // Support for cancellation
    stat: true,    // Get file stats for sorting
    withFileTypes: true,  // Return full file info objects
  })
  // Sort by modification time (newest last, reversed later)
  const sortedPaths = paths.sort((a, b) => (a.mtimeMs ?? 0) - (b.mtimeMs ?? 0))
  const truncated = sortedPaths.length > offset + limit
  return {
    files: sortedPaths
      .slice(offset, offset + limit)
      .map(path => path.fullpath()),
    truncated,  // Important flag to let Claude know results were limited
  }
}
```

The tool's React component handles Claude-specific formatting:

```typescript
// Formats results in a clean, readable format for Claude
renderResultForAssistant(output) {
  let result = output.filenames.join('\n')
  if (output.filenames.length === 0) {
    result = 'No files found'
  }
  // Only add truncation message if results were actually truncated
  else if (output.truncated) {
    result +=
      '\n(Results are truncated. Consider using a more specific path or pattern.)'
  }
  return result
}
```

## Key Components

The GlobTool has several critical features:

1. **Performance optimization**
   - Works efficiently with any codebase size via Node's glob library
   - Results sorted by modification time (newest files first)
   - Limited to 100 results to prevent overwhelming context
   - Supports cancellation via AbortSignal

2. **Pattern matching**
   - Supports standard glob syntax (**, *, ?, etc.)
   - Case-insensitive matching by default
   - Excludes directories from results (files only)

3. **Safety mechanisms**
   - Truncation detection and notification
   - Clear warning to switch to Agent for complex searches
   - Path safety validation via the filesystem permission system

## Architecture

GlobTool is structured as:

```
GlobTool.tsx (Tool interface)
  ↓
glob() in file.ts (Core functionality)
  ↓
Node's glob library (Underlying implementation)
```

The read-only designation is important - it enables:
- Parallel execution with other tools
- Simpler permission model
- No risk of filesystem modifications

## Permission Handling

GlobTool uses a simple permission model:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path || getCwd())
}
```

This single check verifies if Claude has read access to the target directory. The filesystem permission system includes additional safeguards:

- Path normalization to prevent directory traversal attacks
- Rejection of paths containing null bytes or other potential exploits
- Path comparison to ensure operations remain within allowed directories

## Usage Examples

Common usage patterns:

1. **Finding all JavaScript files**
   ```
   GlobTool(pattern: "**/*.js")
   ```

2. **Searching in a specific directory**
   ```
   GlobTool(pattern: "*.ts", path: "/path/to/src")
   ```

3. **Finding configuration files**
   ```
   GlobTool(pattern: "**/config.{json,yaml,yml}")
   ```

GlobTool is frequently used in conjunction with GrepTool - first finding files matching a pattern, then searching their contents.

