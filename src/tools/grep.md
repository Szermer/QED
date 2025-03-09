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

## What Makes It Special

GrepTool has some cool features:

1. **Speed**
   - Uses ripgrep (way faster than regular grep)
   - Caps results at 100 files to stay snappy
   - Tells you when there are too many matches
   - Can be canceled if it's taking too long

2. **Works Everywhere**
   - Comes with ripgrep for all platforms
   - Sets up properly on macOS with code signing
   - Deals with path differences between OSes

3. **Power Searching**
   - Full regex support for complex patterns
   - Doesn't care about case by default
   - Can filter by file types
   - Shows just file names, not every matching line

## How It's Built

GrepTool is structured like this:

```
GrepTool.tsx (UI component)
  ↓
ripGrep() in ripgrep.ts (Main logic)
  ↓
ripgrep CLI binary (The engine)
```

Some smart decisions in the design:

- Includes ripgrep binaries so it works out of the box
- Uses `-li` flags to just find files (not individual matches)
- Marked as read-only so it can run in parallel with other tools
- Shows newest files first so you see recent changes

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

GrepTool works great with GlobTool - use Glob to find files by name, then Grep to search their contents. It's especially good for finding code patterns like functions, imports, or error handling.

