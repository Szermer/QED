# GrepTool: Content Searching

GrepTool provides high-performance content searching across files using regular expressions. It's built on ripgrep, making it exceptionally fast even with large codebases.

## Complete Prompt

```typescript
// Tool Prompt: GrepTool
export const DESCRIPTION = `
- Fast content search tool that works with any codebase size
- Searches file contents using regular expressions
- Supports full regex syntax (eg. "log.*Error", "function\\s+\\w+", etc.)
- Filter files by pattern with the include parameter (eg. "*.js", "*.{ts,tsx}")
- Returns matching file paths sorted by modification time
- Use this tool when you need to find files containing specific patterns
- When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead
`
```

> **Tool Prompt: GrepTool**
>
> - Fast content search tool that works with any codebase size
> - Searches file contents using regular expressions
> - Supports full regex syntax (eg. "log.*Error", "function\\s+\\w+", etc.)
> - Filter files by pattern with the include parameter (eg. "*.js", "*.{ts,tsx}")
> - Returns matching file paths sorted by modification time
> - Use this tool when you need to find files containing specific patterns
> - When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead

## Implementation Details

GrepTool is implemented with two main components:

1. **The GrepTool React component** (`GrepTool.tsx`)
   - Handles user input validation with Zod schema
   - Manages the permission system integration
   - Formats results for the Claude UI and API

2. **The ripgrep wrapper** (`ripgrep.ts`)
   - Wraps the Rust-based ripgrep CLI tool
   - Handles platform-specific differences
   - Manages binary distribution and execution

Let's look at the core implementation:

```typescript
// Core search implementation from GrepTool.tsx
async *call({ pattern, path, include }, { abortController }) {
  const start = Date.now()
  const absolutePath = getAbsolutePath(path) || getCwd()

  // Build ripgrep arguments
  const args = ['-li', pattern]  // -l: files-with-matches, -i: case-insensitive
  if (include) {
    args.push('--glob', include)  // File pattern filtering
  }

  // Execute ripgrep search
  const results = await ripGrep(args, absolutePath, abortController.signal)

  // Get file stats for sorting by modification time
  const stats = await Promise.all(results.map(_ => stat(_)))
  const matches = results
    .map((_, i) => [_, stats[i]!] as const)
    .sort((a, b) => {
      // Sort by modification time (newest first)
      return (b[1].mtimeMs ?? 0) - (a[1].mtimeMs ?? 0)
    })
    .map(_ => _[0])

  // Return results
  const output = {
    filenames: matches,
    durationMs: Date.now() - start,
    numFiles: matches.length,
  }

  yield {
    type: 'result',
    resultForAssistant: this.renderResultForAssistant(output),
    data: output,
  }
}
```

The ripgrep integration is particularly interesting:

```typescript
// From ripgrep.ts - platform-specific optimizations
export async function ripGrep(
  args: string[],
  target: string,
  abortSignal: AbortSignal,
): Promise<string[]> {
  await codesignRipgrepIfNecessary()  // macOS-specific code signing
  const rg = ripgrepPath()  // Get platform-specific binary
  
  return new Promise(resolve => {
    execFile(
      ripgrepPath(),
      [...args, target],
      {
        maxBuffer: 1_000_000,  // 1MB buffer for large results
        signal: abortSignal,   // Support for cancellation
        timeout: 10_000,       // 10-second timeout
      },
      (error, stdout) => {
        if (error) {
          // Exit code 1 from ripgrep means "no matches found" - this is normal
          if (error.code !== 1) {
            logError(error)
          }
          resolve([])
        } else {
          resolve(stdout.trim().split('\n').filter(Boolean))
        }
      },
    )
  })
}
```

## Key Components

GrepTool has several critical features:

1. **Performance optimization**
   - Uses ripgrep, a Rust-based tool that's significantly faster than traditional grep
   - Limits result size with MAX_RESULTS constant (100)
   - Implements result truncation notifications
   - Supports abort signals for cancellation

2. **Platform independence**
   - Includes built-in ripgrep binaries for all platforms
   - Implements macOS code signing to avoid security issues
   - Handles platform-specific path differences

3. **Advanced search capabilities**
   - Full regex syntax support
   - Case-insensitive searching by default
   - File pattern filtering with glob syntax
   - Only reports files with matches, not individual match lines

## Architecture

The GrepTool architecture follows a layered approach:

```
GrepTool.tsx (React component)
  ↓
ripGrep() in ripgrep.ts (Core functionality)
  ↓
ripgrep CLI binary (Native implementation)
```

Notable design decisions:

- Bundling ripgrep binaries for all platforms ensures consistent availability
- The `-li` flag optimizes for file discovery rather than displaying matches
- Like GlobTool, it's marked as read-only to enable parallel execution
- Results are limited and sorted by modification time to prioritize recent changes

## Permission Handling

GrepTool uses the same simple permission model as GlobTool:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path || getCwd())
}
```

This checks if Claude has read access to the specified directory. The permission is granted once per directory, then applies to all grep operations within that directory.

## Usage Examples

Common usage patterns:

1. **Finding function definitions**
   ```
   GrepTool(pattern: "function\\s+getUserData")
   ```

2. **Searching with file type filtering**
   ```
   GrepTool(pattern: "import.*React", include: "*.tsx")
   ```

3. **Finding error handling**
   ```
   GrepTool(pattern: "catch.*Error", path: "/path/to/src")
   ```

GrepTool is most powerful when combined with GlobTool or when searching for specific code patterns like function definitions, imports, or error handling.

