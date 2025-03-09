# GrepTool: Search Inside Files

GrepTool searches through file contents using regex patterns. Built on ripgrep, it's blazing fast even in large codebases.

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

## How It Works

GrepTool has two main parts:

1. **The UI component** (`GrepTool.tsx`)
   - Validates your search params
   - Handles permissions
   - Formats the results nicely

2. **The ripgrep wrapper** (`ripgrep.ts`)
   - Runs the super-fast Rust-based ripgrep tool
   - Works across all platforms
   - Handles the nitty-gritty details

Here's what the search function looks like:

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

And here's how it connects to ripgrep:

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

## Key Features

GrepTool provides:

1. **Performance**
   - ripgrep-powered search engine
   - Result limit for responsiveness
   - Truncation indicators
   - Cancellation support

2. **Cross-platform**
   - Bundled ripgrep binaries
   - macOS code signing
   - OS-agnostic path handling

3. **Search capabilities**
   - Regex pattern matching
   - Case-insensitive by default
   - File type filtering
   - Filename-only results

## Architecture

GrepTool follows this structure:

```
GrepTool.tsx (UI component)
  ↓
ripGrep() in ripgrep.ts (Main logic)
  ↓
ripgrep CLI binary (The engine)
```

Key design choices:

- Bundled ripgrep binaries for immediate use
- `-li` flags for file-only matching
- Read-only designation allowing parallel execution
- Recency-based result sorting

## Permissions

GrepTool keeps permissions simple:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path || getCwd())
}
```

It just checks if Claude can read the directory you're searching in. Once you grant access to a directory, it applies to all searches in that directory.

## Examples

Here are some common searches:

1. **Find function definitions**
   ```
   GrepTool(pattern: "function\\s+getUserData")
   ```

2. **Search just specific file types**
   ```
   GrepTool(pattern: "import.*React", include: "*.tsx")
   ```

3. **Look for error handling**
   ```
   GrepTool(pattern: "catch.*Error", path: "/path/to/src")
   ```

GrepTool complements GlobTool - use Glob for file name patterns and Grep for content searching. Particularly effective for locating code patterns like function definitions, imports, and error handling.

